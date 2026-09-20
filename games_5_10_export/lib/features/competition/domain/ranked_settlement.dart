import 'rank_tier.dart';

RankTier _tierFromWire(Object? value) {
  final name = value as String?;
  for (final tier in RankTier.values) {
    if (tier.name == name) return tier;
  }
  return RankTier.bronze;
}

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

  Map<String, Object> toMap() => {
        'uid': uid,
        'previousRp': previousRp,
        'nextRp': nextRp,
        'rpDelta': rpDelta,
        'previousTier': previousTier.name,
        'nextTier': nextTier.name,
        'xpAwarded': xpAwarded,
        'coinsAwarded': coinsAwarded,
      };

  factory RankedPlayerSettlement.fromMap(Map<Object?, Object?> map) {
    return RankedPlayerSettlement(
      uid: map['uid'] as String? ?? '',
      previousRp: (map['previousRp'] as num?)?.toInt() ?? 0,
      nextRp: (map['nextRp'] as num?)?.toInt() ?? 0,
      rpDelta: (map['rpDelta'] as num?)?.toInt() ?? 0,
      previousTier: _tierFromWire(map['previousTier']),
      nextTier: _tierFromWire(map['nextTier']),
      xpAwarded: (map['xpAwarded'] as num?)?.toInt() ?? 0,
      coinsAwarded: (map['coinsAwarded'] as num?)?.toInt() ?? 0,
    );
  }
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

  Map<String, Object> toMap() => {
        'matchId': matchId,
        'seasonId': seasonId,
        'playerA': playerA.toMap(),
        'playerB': playerB.toMap(),
        'settledAt': settledAt.toUtc().toIso8601String(),
      };

  factory RankedMatchSettlement.fromMap(Map<Object?, Object?> map) {
    final rawPlayerA = map['playerA'];
    final rawPlayerB = map['playerB'];
    final rawSettledAt = map['settledAt'] as String?;

    return RankedMatchSettlement(
      matchId: map['matchId'] as String? ?? '',
      seasonId: map['seasonId'] as String? ?? '',
      playerA: RankedPlayerSettlement.fromMap(
        rawPlayerA is Map
            ? Map<Object?, Object?>.from(rawPlayerA)
            : const <Object?, Object?>{},
      ),
      playerB: RankedPlayerSettlement.fromMap(
        rawPlayerB is Map
            ? Map<Object?, Object?>.from(rawPlayerB)
            : const <Object?, Object?>{},
      ),
      settledAt: DateTime.tryParse(rawSettledAt ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
