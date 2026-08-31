import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../competition/data/mini_game_evidence_policy.dart';
import '../../competition/domain/mini_game_evidence.dart';
import '../../competition/domain/ranked_settlement_player.dart';
import '../../minigames/data/game_registry.dart';
import '../../minigames/domain/mini_game_contract.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/match_progress.dart';
import '../domain/match_session.dart';
import '../domain/match_ticket.dart';
import '../domain/ranked_wager.dart';
import 'firestore_match_backend.dart';
import 'match_backend.dart';

typedef RankedSettlementListener = void Function(
  String matchId,
  RankedSettlementPlayer settlement,
);

class CloudFunctionsMatchBackend implements
    MatchBackend,
    RankedWagerQueueBackend,
    MatchGameSelectionBackend,
    DetailedGameResultBackend,
    RankedSettlementResultBackend {
  CloudFunctionsMatchBackend({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirestoreMatchBackend? readBackend,
    this.onSettlement,
  })  : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2'),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _readBackend = readBackend ?? FirestoreMatchBackend();

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final FirestoreMatchBackend _readBackend;
  final RankedSettlementListener? onSettlement;

  Future<void> _call(String name, Map<String, Object?> data) async {
    await _functions.httpsCallable(name).call<void>(data);
  }

  @override
  Future<void> joinQueue(PlayerProfile profile) =>
      joinRankedQueueWithWager(profile, wager: RankedWager.gold100);

  @override
  Future<void> joinRankedQueueWithWager(
    PlayerProfile profile, {
    required RankedWager wager,
  }) => _call('joinRankedQueue', {
        'gameName': profile.gameName,
        'avatarId': profile.avatarId,
        'wagerGold': wager.gold,
      });

  @override
  Future<void> leaveQueue(String uid) => _call('leaveRankedQueue', const {});

  @override
  Future<void> clearTicket(String uid) => _call('clearRankedTicket', const {});

  @override
  Future<void> moveTicketToMatch({required String uid, required String matchId}) =>
      _call('syncRankedTicket', {'matchId': matchId});

  @override
  Stream<MatchTicket?> watchTicket(String uid) => _readBackend.watchTicket(uid);

  List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return List<String>.unmodifiable(value.whereType<String>());
  }

  MatchSession _withSelection(MatchSession base, Map<String, dynamic> data) {
    return MatchSession(
      id: base.id,
      playerAId: base.playerAId,
      playerAName: base.playerAName,
      playerAAvatarId: base.playerAAvatarId,
      playerBId: base.playerBId,
      playerBName: base.playerBName,
      playerBAvatarId: base.playerBAvatarId,
      seed: base.seed,
      gameCount: base.gameCount,
      registryVersion: base.registryVersion,
      status: base.status,
      readyA: base.readyA,
      readyB: base.readyB,
      progressA: base.progressA,
      progressB: base.progressB,
      rematchA: base.rematchA,
      rematchB: base.rematchB,
      playerAGameIds: _stringList(data['playerAGameIds']),
      playerBGameIds: _stringList(data['playerBGameIds']),
      lockedGameIds: _stringList(data['lockedGameIds']),
      mode: base.mode,
      wagerGold: (data['wagerGold'] as num?)?.toInt() ?? base.wagerGold,
      rematchMatchId: base.rematchMatchId,
      cancelledBy: base.cancelledBy,
      countdownStartedAt: base.countdownStartedAt,
      createdAt: base.createdAt,
    );
  }

  @override
  Stream<MatchSession?> watchMatch(String matchId) =>
      _readBackend.watchMatch(matchId).asyncMap((base) async {
        if (base == null) return null;
        final snapshot = await _firestore.collection('matches').doc(matchId).get();
        final data = snapshot.data();
        return data == null ? base : _withSelection(base, data);
      });

  @override
  Future<List<MatchSession>> loadHistory(String uid) => _readBackend.loadHistory(uid);

  @override
  Future<void> submitGameSelection({
    required String matchId,
    required String uid,
    required List<String> gameIds,
  }) => _call('submitRankedGameSelection', {
        'matchId': matchId,
        'gameIds': gameIds,
      });

  @override
  Future<void> markReady({required String matchId, required String uid}) =>
      _call('markRankedReady', {'matchId': matchId});

  @override
  Future<void> cancelMatch({required String matchId, required String uid}) =>
      _call('cancelRankedMatch', {'matchId': matchId});

  @override
  Future<void> finalizeMatch({required String matchId, required String uid}) async {
    final settlement = await finalizeMatchWithResult(matchId: matchId, uid: uid);
    if (settlement != null) onSettlement?.call(matchId, settlement);
  }

  @override
  Future<RankedSettlementPlayer?> finalizeMatchWithResult({
    required String matchId,
    required String uid,
  }) async {
    final response = await _functions
        .httpsCallable('settleRankedMatch')
        .call<Map<Object?, Object?>>({'matchId': matchId});
    final payload = Map<String, dynamic>.from(response.data);
    final playerA = RankedSettlementPlayer.fromPayload(payload['playerA'], uid: uid);
    if (playerA != null) return playerA;
    return RankedSettlementPlayer.fromPayload(payload['playerB'], uid: uid);
  }

  @override
  Future<void> requestRematch({required String matchId, required String uid}) =>
      _call('requestRankedRematch', {'matchId': matchId});

  @override
  Future<void> cancelRematchRequest({required String matchId, required String uid}) =>
      _call('cancelRankedRematch', {'matchId': matchId});

  @override
  Future<void> submitMiniGameResult({
    required String matchId,
    required String uid,
    required MiniGameResult result,
    required int gameCount,
  }) async {
    final match = await watchMatch(matchId).first;
    if (match == null) throw StateError('Ranked match not found.');
    if (match.registryVersion != GameRegistry.version) {
      throw StateError('Registry version mismatch.');
    }
    if (match.lockedGameIds.length != gameCount) {
      throw StateError('Ranked game selection is not locked.');
    }

    final current = match.progressFor(uid);
    final gameIndex = current.completedGames;
    final sequence = match.lockedGameIds
        .map((id) => GameRegistry.games.singleWhere((game) => game.id == id))
        .toList(growable: false);
    if (gameIndex >= sequence.length) throw StateError('Ranked game index is invalid.');

    final descriptor = sequence[gameIndex];
    final evidence = MiniGameEvidence(
      gameId: descriptor.id,
      gameVersion: descriptor.version,
      gameIndex: gameIndex,
      gameSeed: MiniGameEvidencePolicy.gameSeed(
        matchSeed: match.seed,
        gameIndex: gameIndex,
      ),
      completed: result.completed,
      progressStep: result.progressStep,
      progressStepCount: result.progressStepCount,
      score: result.score,
      accuracy: result.accuracy,
      mistakes: result.mistakes,
      durationMs: result.duration.inMilliseconds,
    );

    if (!MiniGameEvidencePolicy.isValidMatchEvidence(
      matchSeed: match.seed,
      gameCount: gameCount,
      evidence: [evidence],
      lockedGameIds: match.lockedGameIds,
    )) {
      throw StateError('Ranked mini-game result is outside the official contract.');
    }

    await _call('submitRankedGameResult', {
      'matchId': matchId,
      'evidence': evidence.toMap(),
    });
  }

  @override
  Future<void> submitProgress({
    required String matchId,
    required String uid,
    required MatchProgress progress,
    required int gameCount,
  }) {
    throw StateError(
      'Ranked matches require DetailedGameResultBackend so completion and progress cannot be lost.',
    );
  }
}
