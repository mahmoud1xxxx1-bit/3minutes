import '../../competition/domain/rank_tier.dart';

class PlayerProfile {
  const PlayerProfile({
    required this.uid,
    required this.gameName,
    required this.avatarId,
    required this.level,
    required this.xp,
    required this.rankPoints,
    required this.stars,
    required this.wins,
    required this.losses,
    required this.gamesPlayed,
    this.ties = 0,
    this.bestWinStreak = 0,
    this.legendarySeasons = 0,
    this.peakRankTier = RankTier.bronze,
    this.showcaseRankTier,
    this.friendCode,
    this.selectedTitleId,
    this.showcaseAchievementIds = const <String>[],
  });

  final String uid;
  final String gameName;
  final String avatarId;
  final int level;
  final int xp;
  final int rankPoints;
  final int stars;
  final int wins;
  final int losses;
  final int ties;
  final int gamesPlayed;
  final int bestWinStreak;

  /// Number of distinct completed seasons in which this player reached
  /// Legendary as their peak tier. This is permanent prestige, not currency.
  final int legendarySeasons;

  /// Lifetime highest Ranked tier. Every tier up to this one is permanently
  /// unlocked for profile/showcase display even after seasonal RP resets.
  final RankTier peakRankTier;

  /// Optional historical emblem chosen for profile/showcase presentation.
  /// Competitive surfaces must continue to use RankPolicy.tierFor(rankPoints).
  final RankTier? showcaseRankTier;

  final String? friendCode;
  final String? selectedTitleId;
  final List<String> showcaseAchievementIds;

  double get winRate => gamesPlayed <= 0 ? 0 : wins / gamesPlayed;

  bool isRankEmblemUnlocked(RankTier tier) => tier.index <= peakRankTier.index;

  factory PlayerProfile.fromMap(String uid, Map<String, dynamic> map) {
    final achievements = (map['showcaseAchievementIds'] as List<dynamic>?)
            ?.whereType<String>()
            .take(3)
            .toList(growable: false) ??
        const <String>[];

    final rawLegendarySeasons = (map['legendarySeasons'] as num?)?.toInt() ?? 0;
    final rankPoints = (map['rankPoints'] as num?)?.toInt() ?? 0;
    final currentTier = RankPolicy.tierFor(rankPoints);
    final peakRankTier = _rankTierFromName(map['peakRankTier']) ?? currentTier;
    final requestedShowcaseTier = _rankTierFromName(map['showcaseRankTier']);
    final showcaseRankTier = requestedShowcaseTier != null &&
            requestedShowcaseTier.index <= peakRankTier.index
        ? requestedShowcaseTier
        : null;

    return PlayerProfile(
      uid: uid,
      gameName: (map['gameName'] as String?) ?? 'Player',
      avatarId: (map['avatarId'] as String?) ?? 'default_01',
      level: (map['level'] as num?)?.toInt() ?? 1,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      rankPoints: rankPoints,
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      losses: (map['losses'] as num?)?.toInt() ?? 0,
      ties: (map['ties'] as num?)?.toInt() ?? 0,
      gamesPlayed: (map['gamesPlayed'] as num?)?.toInt() ?? 0,
      bestWinStreak: (map['bestWinStreak'] as num?)?.toInt() ?? 0,
      legendarySeasons: rawLegendarySeasons < 0 ? 0 : rawLegendarySeasons,
      peakRankTier: peakRankTier,
      showcaseRankTier: showcaseRankTier,
      friendCode: map['friendCode'] as String?,
      selectedTitleId: map['selectedTitleId'] as String?,
      showcaseAchievementIds: achievements,
    );
  }

  static RankTier? _rankTierFromName(Object? value) {
    if (value is! String) return null;
    for (final tier in RankTier.values) {
      if (tier.name == value) return tier;
    }
    return null;
  }
}

class ProfileShowcasePolicy {
  const ProfileShowcasePolicy._();

  static const int maxShowcaseAchievements = 3;

  static List<String> normalizeAchievements(Iterable<String> ids) {
    final unique = <String>[];
    for (final id in ids) {
      if (id.trim().isEmpty || unique.contains(id)) continue;
      unique.add(id);
      if (unique.length == maxShowcaseAchievements) break;
    }
    return List.unmodifiable(unique);
  }
}
