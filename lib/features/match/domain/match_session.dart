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
    required this.rematchA,
    required this.rematchB,
    this.mode = 'ranked',
    this.wagerCoins = 0,
    this.wagerPotCoins = 0,
    this.wagerStatus,
    this.rematchMatchId,
    this.cancelledBy,
    this.countdownStartedAt,
    this.createdAt,
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
  final bool rematchA;
  final bool rematchB;
  final String mode;

  /// Server-authoritative stake contributed by each Ranked player.
  /// Legacy and non-Ranked sessions default to zero.
  final int wagerCoins;

  /// Server-authoritative total pot for the Ranked match.
  /// This is normally wagerCoins * 2 and defaults to zero for legacy/Quick.
  final int wagerPotCoins;

  /// Server lifecycle marker such as held, refunded, or settled.
  final String? wagerStatus;

  final String? rematchMatchId;
  final String? cancelledBy;
  final DateTime? countdownStartedAt;
  final DateTime? createdAt;

  bool get isQuick => mode == 'quick';
  bool get isRanked => !isQuick;
  bool get hasWager => isRanked && wagerCoins > 0 && wagerPotCoins > 0;

  bool containsPlayer(String uid) => playerAId == uid || playerBId == uid;

  String opponentName(String uid) => playerAId == uid ? playerBName : playerAName;

  String opponentAvatarId(String uid) =>
      playerAId == uid ? playerBAvatarId : playerAAvatarId;

  bool isReady(String uid) => playerAId == uid ? readyA : readyB;

  bool requestedRematch(String uid) => playerAId == uid ? rematchA : rematchB;

  MatchProgress progressFor(String uid) =>
      playerAId == uid ? progressA : progressB;

  MatchProgress opponentProgress(String uid) =>
      playerAId == uid ? progressB : progressA;
}
