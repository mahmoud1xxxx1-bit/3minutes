import '../domain/competitive_match.dart';

abstract interface class CompetitiveMatchBackend {
  Stream<CompetitiveMatch?> watchCurrentMatch(String uid);

  Future<void> joinQueue({required String uid, required int wager});
  Future<void> leaveQueue({required String uid});

  Future<void> selectGames({
    required String matchId,
    required String uid,
    required List<String> gameIds,
  });

  Future<void> setReady({
    required String matchId,
    required String uid,
    required bool ready,
  });

  Future<void> surrender({required String matchId, required String uid});
}
