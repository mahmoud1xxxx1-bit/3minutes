import 'package:flutter_test/flutter_test.dart';
import 'package:three_minutes/features/competition/domain/rank_tier.dart';
import 'package:three_minutes/features/competition/domain/season_history.dart';

void main() {
  SeasonHistoryEntry entry({
    required String seasonId,
    required int seasonNumber,
    required RankTier peakTier,
  }) {
    return SeasonHistoryEntry(
      seasonId: seasonId,
      seasonNumber: seasonNumber,
      peakTier: peakTier,
      finalRankPoints: peakTier == RankTier.legend ? 10000 : 7000,
      finalStanding: 1,
      wins: 20,
      losses: 5,
      ties: 0,
      gamesPlayed: 25,
      starsAwarded: 1,
      closedAt: DateTime.utc(2026, seasonNumber, 1),
    );
  }

  test('Legendary prestige counts distinct Legendary seasons only', () {
    final history = <SeasonHistoryEntry>[
      entry(seasonId: 's1', seasonNumber: 1, peakTier: RankTier.legend),
      entry(seasonId: 's1', seasonNumber: 1, peakTier: RankTier.legend),
      entry(seasonId: 's2', seasonNumber: 2, peakTier: RankTier.grandmaster),
      entry(seasonId: 's3', seasonNumber: 3, peakTier: RankTier.legend),
    ];

    expect(LegendaryPrestigePolicy.count(history), 2);
  });

  test('Legendary prestige visual milestones are stable', () {
    expect(LegendaryPrestigePolicy.levelFor(0), LegendaryPrestigeLevel.none);
    expect(
      LegendaryPrestigePolicy.levelFor(1),
      LegendaryPrestigeLevel.legendary,
    );
    expect(
      LegendaryPrestigePolicy.levelFor(2),
      LegendaryPrestigeLevel.doubleHalo,
    );
    expect(
      LegendaryPrestigePolicy.levelFor(3),
      LegendaryPrestigeLevel.crowned,
    );
    expect(
      LegendaryPrestigePolicy.levelFor(5),
      LegendaryPrestigeLevel.aura,
    );
    expect(
      LegendaryPrestigePolicy.levelFor(10),
      LegendaryPrestigeLevel.legacy,
    );
    expect(
      LegendaryPrestigePolicy.levelFor(25),
      LegendaryPrestigeLevel.legacy,
    );
  });
}
