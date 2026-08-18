class PlayerProgression {
  const PlayerProgression({
    required this.level,
    required this.xp,
  });

  final int level;
  final int xp;
}

class ProgressionPolicy {
  const ProgressionPolicy._();

  static int xpRequiredForLevel(int level) {
    final safeLevel = level < 1 ? 1 : level;
    return 100 + ((safeLevel - 1) * 50);
  }
}
