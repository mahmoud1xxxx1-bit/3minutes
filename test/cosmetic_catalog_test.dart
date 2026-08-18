import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/data/cosmetic_catalog.dart';
import 'package:game/features/economy/domain/cosmetic_item.dart';

void main() {
  test('cosmetic catalog is valid and ids are unique', () {
    expect(CosmeticCatalog.version, 2);
    expect(() => CosmeticCatalog.validate(), returnsNormally);

    final ids = CosmeticCatalog.items.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(CosmeticCatalog.items.every((item) => item.coinPrice >= 0), isTrue);
  });

  test('shop has meaningful coin star and premium progression', () {
    final coinItems = CosmeticCatalog.forPriceType(CosmeticPriceType.coins);
    final starItems =
        CosmeticCatalog.forPriceType(CosmeticPriceType.prestigeStars);
    final premiumItems =
        CosmeticCatalog.forPriceType(CosmeticPriceType.premium);

    expect(coinItems.length, greaterThanOrEqualTo(12));
    expect(starItems.length, greaterThanOrEqualTo(8));
    expect(premiumItems.length, greaterThanOrEqualTo(5));
    expect(coinItems.map((item) => item.coinPrice).reduce((a, b) => a > b ? a : b),
        greaterThanOrEqualTo(30000));
    expect(starItems.map((item) => item.starPrice).reduce((a, b) => a > b ? a : b),
        250);
  });

  test('prestige star cosmetics can never also be premium', () {
    final starItems =
        CosmeticCatalog.forPriceType(CosmeticPriceType.prestigeStars);
    expect(starItems.every((item) => !item.isPremium), isTrue);
    expect(starItems.every((item) => item.premiumPriceCents == 0), isTrue);
  });
}
