import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/data/cosmetic_catalog.dart';

void main() {
  test('cosmetic catalog is valid and ids are unique', () {
    expect(CosmeticCatalog.version, 1);
    expect(() => CosmeticCatalog.validate(), returnsNormally);

    final ids = CosmeticCatalog.items.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(CosmeticCatalog.items.every((item) => item.coinPrice >= 0), isTrue);
  });
}
