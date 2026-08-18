import 'match_progress.dart';

enum MatchStatus {
  waitingReady,
  countdown,
  playing,
  finished,
  cancelled;

  static MatchStatus fromWire(String value) {
    return MatchStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => MatchStatus.waitingReady,
    );
  }
}

class MatchSession {
  const MatchSession({
    required this.id,
    required this.playerAId,
    required this.playerAName,
    required this.playerAAvatarId,
    required this.playerBId,
    required this.playerBName,
    required this.playerBAvatarId,
    required this.seed,
    required this.gameCount,
    required this.registryVersion,
    required this.status,
    required this.readyA,
    required this.readyB,
    required this.progressA,
    required this.progressB,
    this.countdownStartedAt,
  });

  final String id;
  final String playerAId;
  final String playerAName;
  final String playerAAvatarId;
  final String playerBId;
  final String playerBName;
  final String playerBAvatarId;
  final int seed;
  final int gameCount;
  final int registryVersion;
  final MatchStatus status;
  final bool readyA;
  final bool readyB;
  final MatchProgress progressA;
  final MatchProgress progressB;
  final DateTime? countdownStartedAt;

  bool containsPlayer(String uid) => playerAId == uid || playerBId == uid;

  String opponentName(String uid) => playerAId == uid ? playerBName : playerAName;

  String opponentAvatarId(String uid) =>
      playerAId == uid ? playerBAvatarId : playerAAvatarId;

  bool isReady(String uid) => playerAId == uid ? readyA : readyB;

  MatchProgress progressFor(String uid) =>
      playerAId == uid ? progressA : progressB;

  MatchProgress opponentProgress(String uid) =>
      playerAId == uid ? progressB : progressA;
}
