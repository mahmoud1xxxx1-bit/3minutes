import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/presentation/rank_art/rank_atlas_data.dart';

void main() {
  test('approved rank atlas covers all eight tiers', () {
    expect(RankTier.values, hasLength(8));
    expect(RankAtlasData.columns * RankAtlasData.rows, RankTier.values.length);
    expect(RankAtlasData.cellSize, 96);
  });

  test('approved rank atlas payload is a WebP image', () {
    final bytes = RankAtlasData.bytes;
    expect(bytes.length, greaterThan(40000));
    expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
    expect(String.fromCharCodes(bytes.skip(8).take(4)), 'WEBP');
  });

  test('rank tier index maps uniquely into the atlas', () {
    final cells = <String>{};
    for (final tier in RankTier.values) {
      final column = tier.index % RankAtlasData.columns;
      final row = tier.index ~/ RankAtlasData.columns;
      cells.add('$column:$row');
    }
    expect(cells, hasLength(RankTier.values.length));
  });
}
