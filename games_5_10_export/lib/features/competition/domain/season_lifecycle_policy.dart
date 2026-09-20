import 'season.dart';

class SeasonLifecyclePolicy {
  const SeasonLifecyclePolicy._();

  static bool hasValidDuration(Season season) =>
      season.duration == SeasonPolicy.duration;

  static Season nextSeason(Season current) {
    return Season(
      id: 'season_${current.number + 1}',
      startsAt: current.endsAt,
      endsAt: SeasonPolicy.endFor(current.endsAt),
      number: current.number + 1,
    );
  }

  static bool isContiguous({required Season current, required Season next}) =>
      current.endsAt == next.startsAt &&
      next.number == current.number + 1 &&
      hasValidDuration(next);
}
