import 'season.dart';

class SeasonClock {
  const SeasonClock({
    required this.active,
    required this.remaining,
    required this.progress,
  });

  final bool active;
  final Duration remaining;
  final double progress;
}

class SeasonClockPolicy {
  const SeasonClockPolicy._();

  static SeasonClock at({
    required Season season,
    required DateTime now,
  }) {
    if (now.isBefore(season.startsAt)) {
      return const SeasonClock(
        active: false,
        remaining: Duration.zero,
        progress: 0,
      );
    }

    if (!now.isBefore(season.endsAt)) {
      return const SeasonClock(
        active: false,
        remaining: Duration.zero,
        progress: 1,
      );
    }

    final totalMs = season.duration.inMilliseconds;
    final elapsedMs = now.difference(season.startsAt).inMilliseconds;
    final fraction = totalMs <= 0
        ? 1.0
        : (elapsedMs / totalMs).clamp(0.0, 1.0).toDouble();

    return SeasonClock(
      active: true,
      remaining: season.endsAt.difference(now),
      progress: fraction,
    );
  }
}
