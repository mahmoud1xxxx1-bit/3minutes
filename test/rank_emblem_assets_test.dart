import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';

void main() {
  test('all eight rank tiers have a committed SVG emblem asset', () {
    const expected = <RankTier, String>{
      RankTier.bronze: 'assets/ranks/bronze.svg',
      RankTier.silver: 'assets/ranks/silver.svg',
      RankTier.gold: 'assets/ranks/gold.svg',
      RankTier.platinum: 'assets/ranks/platinum.svg',
      RankTier.diamond: 'assets/ranks/diamond.svg',
      RankTier.master: 'assets/ranks/master.svg',
      RankTier.grandmaster: 'assets/ranks/grandmaster.svg',
      RankTier.legend: 'assets/ranks/legendary.svg',
    };

    expect(RankTier.values, hasLength(8));
    expect(expected.keys.toSet(), RankTier.values.toSet());

    for (final path in expected.values) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: 'Missing rank asset: $path');
      final svg = file.readAsStringSync();
      expect(svg, contains('<svg'));
      expect(svg, contains('viewBox="0 0 256 256"'));
    }
  });
}
