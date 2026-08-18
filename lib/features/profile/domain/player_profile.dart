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
  final int gamesPlayed;

  factory PlayerProfile.fromMap(String uid, Map<String, dynamic> map) {
    return PlayerProfile(
      uid: uid,
      gameName: (map['gameName'] as String?) ?? 'Player',
      avatarId: (map['avatarId'] as String?) ?? 'default_01',
      level: (map['level'] as num?)?.toInt() ?? 1,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      rankPoints: (map['rankPoints'] as num?)?.toInt() ?? 0,
      stars: (map['stars'] as num?)?.toInt() ?? 0,
      wins: (map['wins'] as num?)?.toInt() ?? 0,
      losses: (map['losses'] as num?)?.toInt() ?? 0,
      gamesPlayed: (map['gamesPlayed'] as num?)?.toInt() ?? 0,
    );
  }
}
