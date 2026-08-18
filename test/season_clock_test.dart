import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/season.dart';
import 'package:game/features/competition/domain/season_clock.dart';

void main() {
  final season = Season(
    id: 'season_1',
    startsAt: DateTime.utc(2026, 8, 1),
    endsAt: DateTime.utc(2026, 8, 31),
    number: 1,
  );

  test('active season exposes remaining time and progress', () {
    final clock = SeasonClockPolicy.at(
      season: season,
      now: DateTime.utc(2026, 8, 16),
    );

    expect(clock.active, isTrue);
    expect(clock.remaining, const Duration(days: 15));
    expect(clock.progress, 0.5);
  });

  test('closed season has zero remaining time', () {
    final clock = SeasonClockPolicy.at(
      season: season,
      now: DateTime.utc(2026, 8, 31),
    );

    expect(clock.active, isFalse);
    expect(clock.remaining, Duration.zero);
    expect(clock.progress, 1);
  });
}
