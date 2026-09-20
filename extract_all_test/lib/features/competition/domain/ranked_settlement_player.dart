import 'rank_tier.dart';

class RankedSettlementPlayer {
  const RankedSettlementPlayer({
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

  bool get promoted => nextTier.index > previousTier.index;
  bool get demoted => nextTier.index < previousTier.index;

  static RankedSettlementPlayer? fromPayload(
    Object? value, {
    required String uid,
  }) {
    if (value is! Map) return null;
    final data = Map<String, dynamic>.from(value);
    if (data['uid'] != uid) return null;

    final previousTier = _tier(data['previousTier']);
    final nextTier = _tier(data['nextTier']);
    if (previousTier == null || nextTier == null) return null;

    final previousRp = (data['previousRp'] as num?)?.toInt();
    final nextRp = (data['nextRp'] as num?)?.toInt();
    final rpDelta = (data['rpDelta'] as num?)?.toInt();
    final xpAwarded = (data['xpAwarded'] as num?)?.toInt();
    final coinsAwarded = (data['coinsAwarded'] as num?)?.toInt();
    if (previousRp == null ||
        nextRp == null ||
        rpDelta == null ||
        xpAwarded == null ||
        coinsAwarded == null ||
        previousRp < 0 ||
        nextRp < 0 ||
        xpAwarded < 0 ||
        coinsAwarded < 0 ||
        nextRp - previousRp != rpDelta) {
      return null;
    }

    return RankedSettlementPlayer(
      uid: uid,
      previousRp: previousRp,
      nextRp: nextRp,
      rpDelta: rpDelta,
      previousTier: previousTier,
      nextTier: nextTier,
      xpAwarded: xpAwarded,
      coinsAwarded: coinsAwarded,
    );
  }

  static RankTier? _tier(Object? value) {
    if (value is! String) return null;
    for (final tier in RankTier.values) {
      if (tier.name == value) return tier;
    }
    return null;
  }
}
