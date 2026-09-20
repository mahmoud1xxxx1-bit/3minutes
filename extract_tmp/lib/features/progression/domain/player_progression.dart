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

  static PlayerProgression applyXp({
    required PlayerProgression current,
    required int earnedXp,
  }) {
    var level = current.level < 1 ? 1 : current.level;
    var xp = current.xp < 0 ? 0 : current.xp;
    var remaining = earnedXp < 0 ? 0 : earnedXp;

    while (remaining > 0) {
      final required = xpRequiredForLevel(level);
      final needed = required - xp;
      if (remaining < needed) {
        xp += remaining;
        remaining = 0;
      } else {
        remaining -= needed;
        level += 1;
        xp = 0;
      }
    }

    return PlayerProgression(level: level, xp: xp);
  }

  static double progressFraction(PlayerProgression progression) {
    final required = xpRequiredForLevel(progression.level);
    if (required <= 0) return 0;
    final safeXp = progression.xp.clamp(0, required);
    return safeXp / required;
  }
}
