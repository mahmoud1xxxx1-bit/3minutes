import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/profile/domain/player_profile.dart';

void main() {
  test('lifetime peak unlocks every earned emblem and nothing above it', () {
    final profile = PlayerProfile.fromMap('u1', {
      'gameName': 'Player',
      'avatarId': 'default_01',
      'rankPoints': 900,
      'peakRankTier': 'diamond',
    });

    expect(profile.isRankEmblemUnlocked(RankTier.bronze), isTrue);
    expect(profile.isRankEmblemUnlocked(RankTier.silver), isTrue);
    expect(profile.isRankEmblemUnlocked(RankTier.gold), isTrue);
    expect(profile.isRankEmblemUnlocked(RankTier.platinum), isTrue);
    expect(profile.isRankEmblemUnlocked(RankTier.diamond), isTrue);
    expect(profile.isRankEmblemUnlocked(RankTier.master), isFalse);
    expect(profile.isRankEmblemUnlocked(RankTier.grandmaster), isFalse);
    expect(profile.isRankEmblemUnlocked(RankTier.legend), isFalse);
  });

  test('invalid showcase tier cannot survive profile parsing', () {
    final profile = PlayerProfile.fromMap('u1', {
      'rankPoints': 900,
      'peakRankTier': 'gold',
      'showcaseRankTier': 'legend',
    });

    expect(profile.peakRankTier, RankTier.gold);
    expect(profile.showcaseRankTier, isNull);
  });

  test('migrated profile falls back to current tier as lifetime peak', () {
    final profile = PlayerProfile.fromMap('u1', {
      'rankPoints': 5100,
    });

    expect(profile.peakRankTier, RankTier.master);
    expect(profile.isRankEmblemUnlocked(RankTier.master), isTrue);
    expect(profile.isRankEmblemUnlocked(RankTier.grandmaster), isFalse);
  });

  test('negative legendary prestige is normalized to zero', () {
    final profile = PlayerProfile.fromMap('u1', {
      'rankPoints': 0,
      'legendarySeasons': -4,
    });

    expect(profile.legendarySeasons, 0);
  });
}
