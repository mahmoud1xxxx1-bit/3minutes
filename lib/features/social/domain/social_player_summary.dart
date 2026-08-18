class SocialPlayerSummary {
  const SocialPlayerSummary({
    required this.uid,
    required this.displayName,
    required this.avatarId,
    required this.rankPoints,
    required this.level,
    required this.stars,
  });

  final String uid;
  final String displayName;
  final String avatarId;
  final int rankPoints;
  final int level;
  final int stars;
}
