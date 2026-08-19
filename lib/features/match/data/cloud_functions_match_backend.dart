import 'package:cloud_functions/cloud_functions.dart';

import '../../competition/data/mini_game_evidence_policy.dart';
import '../../competition/domain/mini_game_evidence.dart';
import '../../competition/domain/ranked_settlement_player.dart';
import '../../minigames/data/game_registry.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/match_progress.dart';
import '../domain/match_session.dart';
import '../domain/match_ticket.dart';
import 'firestore_match_backend.dart';
import 'match_backend.dart';

class CloudFunctionsMatchBackend
    implements MatchBackend, RankedSettlementResultBackend {
  CloudFunctionsMatchBackend({
    FirebaseFunctions? functions,
    FirestoreMatchBackend? readBackend,
  })  : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2'),
        _readBackend = readBackend ?? FirestoreMatchBackend();

  final FirebaseFunctions _functions;
  final FirestoreMatchBackend _readBackend;

  Future<void> _call(String name, Map<String, Object?> data) async {
    await _functions.httpsCallable(name).call<void>(data);
  }

  @override
  Future<void> joinQueue(PlayerProfile profile) => _call('joinRankedQueue', {
        'gameName': profile.gameName,
        'avatarId': profile.avatarId,
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

  @override
  Stream<MatchSession?> watchMatch(String matchId) => _readBackend.watchMatch(matchId);

  @override
  Future<List<MatchSession>> loadHistory(String uid) => _readBackend.loadHistory(uid);

  @override
  Future<void> markReady({required String matchId, required String uid}) =>
      _call('markRankedReady', {'matchId': matchId});

  @override
  Future<void> cancelMatch({required String matchId, required String uid}) =>
      _call('cancelRankedMatch', {'matchId': matchId});

  @override
  Future<void> finalizeMatch({required String matchId, required String uid}) async {
    await finalizeMatchWithResult(matchId: matchId, uid: uid);
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
  Future<void> submitProgress({
    required String matchId,
    required String uid,
    required MatchProgress progress,
    required int gameCount,
  }) async {
    final match = await watchMatch(matchId).first;
    if (match == null) throw StateError('Ranked match not found.');
    if (match.registryVersion != GameRegistry.version) {
      throw StateError('Registry version mismatch.');
    }
    final current = match.progressFor(uid);
    if (progress.completedGames != current.completedGames + 1) {
      throw StateError('Ranked progress must advance exactly one game.');
    }
    final gameIndex = current.completedGames;
    final sequence = GameRegistry.sequence(seed: match.seed, count: gameCount);
    if (gameIndex >= sequence.length) throw StateError('Ranked game index is invalid.');

    final score = progress.totalScore - current.totalScore;
    final accuracy = progress.accuracyTotal - current.accuracyTotal;
    final mistakes = progress.mistakes - current.mistakes;
    final durationMs = progress.elapsedMs - current.elapsedMs;
    final evidence = MiniGameEvidence(
      gameId: sequence[gameIndex].id,
      gameIndex: gameIndex,
      gameSeed: MiniGameEvidencePolicy.gameSeed(
        matchSeed: match.seed,
        gameIndex: gameIndex,
      ),
      score: score,
      accuracy: accuracy,
      mistakes: mistakes,
      durationMs: durationMs,
    );
    if (!MiniGameEvidencePolicy.isValidMatchEvidence(
      matchSeed: match.seed,
      gameCount: gameCount,
      evidence: [evidence],
    )) {
      // Single-item validation only works for index zero, so apply the bounds
      // here and let the server validate the complete ordered evidence chain.
      if (score < 0 ||
          score > MiniGameEvidencePolicy.maxScorePerGame ||
          accuracy < 0 ||
          accuracy > 1 ||
          mistakes < 0 ||
          durationMs < 0 ||
          durationMs > MiniGameEvidencePolicy.maxMatchDurationMs) {
        throw StateError('Ranked mini-game result is outside allowed bounds.');
      }
    }

    await _call('submitRankedGameResult', {
      'matchId': matchId,
      'evidence': evidence.toMap(),
    });
  }
}
