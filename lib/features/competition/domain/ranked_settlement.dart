import 'rank_tier.dart';

class RankedPlayerSettlement {
  const RankedPlayerSettlement({
    required this.uid,
    required this.previousRp,
    required this.nextRp,
    required this.rpDelta,
    required this.previousTier,
    required this.nextTier,
    required this.xpAwarded,
    required this.coinsAwarded,
  });

  final String uid;
  final int previousRp;
  final int nextRp;
  final int rpDelta;
  final RankTier previousTier;
  final RankTier nextTier;
  final int xpAwarded;
  final int coinsAwarded;
}

class RankedMatchSettlement {
  const RankedMatchSettlement({
    required this.matchId,
    required this.seasonId,
    required this.playerA,
    required this.playerB,
    required this.settledAt,
  });

  final String matchId;
  final String seasonId;
  final RankedPlayerSettlement playerA;
  final RankedPlayerSettlement playerB;
  final DateTime settledAt;
}
