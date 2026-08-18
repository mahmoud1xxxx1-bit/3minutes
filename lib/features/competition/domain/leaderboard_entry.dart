import 'rank_tier.dart';

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.gameName,
    required this.avatarId,
    required this.rankPoints,
    required this.stars,
    required this.wins,
    required this.losses,
    this.legendarySeasons = 0,
  });

  final String uid;
  final String gameName;
  final String avatarId;
  final int rankPoints;
  final int stars;
  final int wins;
  final int losses;
  final int legendarySeasons;

  RankTier get tier => RankPolicy.tierFor(rankPoints);
  int get gamesPlayed => wins + losses;
}
