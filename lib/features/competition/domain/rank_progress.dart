import 'rank_tier.dart';

class RankProgress {
  const RankProgress({
    required this.tier,
    required this.currentRp,
    required this.tierStartRp,
    required this.nextTierStartRp,
  });

  final RankTier tier;
  final int currentRp;
  final int tierStartRp;
  final int? nextTierStartRp;

  bool get isMaxTier => nextTierStartRp == null;

  int get rpIntoTier => (currentRp - tierStartRp).clamp(0, 1 << 30);

  int? get rpToNextTier {
    final next = nextTierStartRp;
    if (next == null) return null;
    final remaining = next - currentRp;
    return remaining < 0 ? 0 : remaining;
  }

  double get fraction {
    final next = nextTierStartRp;
    if (next == null) return 1;
    final span = next - tierStartRp;
    if (span <= 0) return 1;
    return ((currentRp - tierStartRp) / span).clamp(0.0, 1.0);
  }
}

class RankProgressPolicy {
  const RankProgressPolicy._();

  static RankProgress forRp(int rankPoints) {
    final safeRp = rankPoints < 0 ? 0 : rankPoints;
    var index = 0;
    for (var i = 0; i < RankPolicy.bands.length; i++) {
      if (safeRp >= RankPolicy.bands[i].minimumRp) {
        index = i;
      } else {
        break;
      }
    }

    final band = RankPolicy.bands[index];
    final next = index + 1 < RankPolicy.bands.length
        ? RankPolicy.bands[index + 1]
        : null;

    return RankProgress(
      tier: band.tier,
      currentRp: safeRp,
      tierStartRp: band.minimumRp,
      nextTierStartRp: next?.minimumRp,
    );
  }
}
