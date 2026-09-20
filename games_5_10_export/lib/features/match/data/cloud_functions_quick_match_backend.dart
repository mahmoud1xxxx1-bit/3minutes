import 'package:cloud_functions/cloud_functions.dart';

import '../../competition/data/mini_game_evidence_policy.dart';
import '../../competition/domain/mini_game_evidence.dart';
import '../../minigames/data/game_registry.dart';
import '../../profile/domain/player_profile.dart';
import '../domain/match_progress.dart';
import '../domain/match_session.dart';
import '../domain/match_ticket.dart';
import 'firestore_match_backend.dart';
import 'match_backend.dart';

class CloudFunctionsQuickMatchBackend implements MatchBackend {
  CloudFunctionsQuickMatchBackend({
    FirebaseFunctions? functions,
    FirestoreMatchBackend? matchReadBackend,
  })  : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2'),
        _matchReadBackend = matchReadBackend ?? FirestoreMatchBackend();

  final FirebaseFunctions _functions;
  final FirestoreMatchBackend _matchReadBackend;

  Future<void> _call(String name, Map<String, Object?> data) async {
    await _functions.httpsCallable(name).call<void>(data);
  }

  @override
  Future<void> joinQueue(PlayerProfile profile) => _call('joinQuickQueue', {
        'gameName': profile.gameName,
        'avatarId': profile.avatarId,
      });

  @override
  Future<void> leaveQueue(String uid) => _call('leaveQuickQueue', const {});

  @override
  Future<void> clearTicket(String uid) => _call('clearQuickTicket', const {});

  @override
  Future<void> moveTicketToMatch({required String uid, required String matchId}) =>
      _call('syncQuickTicket', {'matchId': matchId});

  @override
  Stream<MatchTicket?> watchTicket(String uid) async* {
    while (true) {
      final response = await _functions
          .httpsCallable('getQuickTicket')
          .call<Map<Object?, Object?>>(const {});
      final data = Map<String, dynamic>.from(response.data);
      if (data['exists'] != true) {
        yield null;
      } else {
        final status = data['status'] as String? ?? MatchTicketStatus.waiting.name;
        yield MatchTicket(
          uid: uid,
          status: MatchTicketStatus.fromWire(status),
          matchId: data['matchId'] as String?,
        );
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Stream<MatchSession?> watchMatch(String matchId) => _matchReadBackend.watchMatch(matchId);

  @override
  Future<List<MatchSession>> loadHistory(String uid) => _matchReadBackend.loadHistory(uid);

  @override
  Future<void> markReady({required String matchId, required String uid}) =>
      _call('markQuickReady', {'matchId': matchId});

  @override
  Future<void> cancelMatch({required String matchId, required String uid}) =>
      _call('cancelQuickMatch', {'matchId': matchId});

  @override
  Future<void> finalizeMatch({required String matchId, required String uid}) =>
      _call('settleQuickMatch', {'matchId': matchId});

  @override
  Future<void> requestRematch({required String matchId, required String uid}) =>
      _call('requestQuickRematch', {'matchId': matchId});

  @override
  Future<void> cancelRematchRequest({required String matchId, required String uid}) =>
      _call('cancelQuickRematch', {'matchId': matchId});

  @override
  Future<void> submitProgress({
    required String matchId,
    required String uid,
    required MatchProgress progress,
    required int gameCount,
  }) async {
    final match = await watchMatch(matchId).first;
    if (match == null) throw StateError('Quick match not found.');
    if (match.registryVersion != GameRegistry.version) {
      throw StateError('Registry version mismatch.');
    }
    final current = match.progressFor(uid);
    if (progress.completedGames != current.completedGames + 1) {
      throw StateError('Quick progress must advance exactly one game.');
    }
    final gameIndex = current.completedGames;
    final sequence = GameRegistry.sequence(seed: match.seed, count: gameCount);
    if (gameIndex >= sequence.length) throw StateError('Quick game index is invalid.');

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

    if (score < 0 ||
        score > MiniGameEvidencePolicy.maxScorePerGame ||
        accuracy < 0 ||
        accuracy > 1 ||
        mistakes < 0 ||
        durationMs < 0 ||
        durationMs > MiniGameEvidencePolicy.maxMatchDurationMs) {
      throw StateError('Quick mini-game result is outside allowed bounds.');
    }

    await _call('submitQuickGameResult', {
      'matchId': matchId,
      'evidence': evidence.toMap(),
    });
  }
}
