class SocialPlayerSummary {
  const SocialPlayerSummary({
    required this.uid,
    required this.displayName,
    required this.avatarId,
    required this.rankPoints,
    required this.level,
    required this.stars,
    this.legendarySeasons = 0,
  });

  final String uid;
  final String displayName;
  final String avatarId;
  final int rankPoints;
  final int level;
  final int stars;

  /// Permanent count of distinct seasons in which this player reached
  /// Legendary. Social surfaces may show this as Legendary ×N prestige.
  final int legendarySeasons;
}
