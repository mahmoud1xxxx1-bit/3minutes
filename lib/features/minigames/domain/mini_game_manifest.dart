import 'mini_game_contract.dart';
import 'mini_game_engine.dart';

class MiniGameManifest {
  const MiniGameManifest({
    required this.id,
    required this.version,
    required this.titleAr,
    required this.titleEn,
    required this.category,
    required this.engine,
    required this.maxDuration,
    required this.minRawScore,
    required this.maxRawScore,
    this.enabled = true,
  }) : assert(id != ''),
       assert(version > 0),
       assert(minRawScore <= maxRawScore),
       assert(maxDuration > Duration.zero);

  final String id;
  final int version;
  final String titleAr;
  final String titleEn;
  final MiniGameCategory category;
  final MiniGameEngine engine;
  final Duration maxDuration;
  final int minRawScore;
  final int maxRawScore;
  final bool enabled;

  int normalizeScore(int rawScore) {
    if (maxRawScore == minRawScore) return rawScore >= maxRawScore ? 1000 : 0;
    final clamped = rawScore.clamp(minRawScore, maxRawScore);
    final ratio = (clamped - minRawScore) / (maxRawScore - minRawScore);
    return (ratio * 1000).round().clamp(0, 1000);
  }

  void validateResult(MiniGameResult result) {
    if (result.score < minRawScore || result.score > maxRawScore) {
      throw StateError(
        'Score ${result.score} is outside [$minRawScore, $maxRawScore] for $id v$version.',
      );
    }
    if (result.duration.isNegative || result.duration > maxDuration) {
      throw StateError(
        'Duration ${result.duration.inMilliseconds}ms is invalid for $id v$version.',
      );
    }
    if (result.accuracy.isNaN || result.accuracy < 0 || result.accuracy > 1) {
      throw StateError('Accuracy ${result.accuracy} is invalid for $id v$version.');
    }
    if (result.mistakes < 0) {
      throw StateError('Mistakes cannot be negative for $id v$version.');
    }
  }
}
