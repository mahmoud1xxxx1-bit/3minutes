import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/season.dart';
import 'package:game/features/competition/domain/season_lifecycle_policy.dart';

void main() {
  test('next season starts exactly when current season ends', () {
    final current = Season(
      id: 'season_1',
      startsAt: DateTime.utc(2026, 8, 1),
      endsAt: DateTime.utc(2026, 8, 31),
      number: 1,
    );

    final next = SeasonLifecyclePolicy.nextSeason(current);

    expect(SeasonLifecyclePolicy.hasValidDuration(current), isTrue);
    expect(next.startsAt, current.endsAt);
    expect(next.duration, const Duration(days: 30));
    expect(next.number, 2);
    expect(
      SeasonLifecyclePolicy.isContiguous(current: current, next: next),
      isTrue,
    );
  });
}
