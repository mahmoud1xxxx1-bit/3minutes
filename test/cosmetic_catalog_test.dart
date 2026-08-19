import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/data/cosmetic_catalog.dart';
import 'package:game/features/economy/domain/cosmetic_item.dart';

void main() {
  test('cosmetic catalog v3 is valid and ids are unique', () {
    expect(CosmeticCatalog.version, 3);
    expect(() => CosmeticCatalog.validate(), returnsNormally);

    final ids = CosmeticCatalog.items.map((item) => item.id).toList();
    expect(ids.toSet().length, ids.length);
    expect(CosmeticCatalog.items.every((item) => item.coinPrice >= 0), isTrue);
  });

  test('avatar library is exactly 45 with approved unlock distribution', () {
    final avatars = CosmeticCatalog.avatars;
    expect(avatars.length, 45);

    int count(CosmeticPriceType type) =>
        avatars.where((item) => item.priceType == type).length;

    expect(count(CosmeticPriceType.free), 5);
    expect(count(CosmeticPriceType.coins), 20);
    expect(count(CosmeticPriceType.premium), 10);
    expect(count(CosmeticPriceType.prestigeStars), 5);
    expect(count(CosmeticPriceType.achievement) +
        count(CosmeticPriceType.seasonalPlacement), 5);
  });

  test('coin avatar prices are the approved doubled progression', () {
    final prices = CosmeticCatalog.avatars
        .where((item) => item.priceType == CosmeticPriceType.coins)
        .map((item) => item.coinPrice)
        .toList();
    expect(
      prices,
      [
        1600,
        2000,
        2400,
        2800,
        3200,
        3600,
        4000,
        4400,
        4800,
        5200,
        5600,
        6000,
        6400,
        6800,
        7200,
        7600,
        8400,
        9200,
        10000,
        11000,
      ],
    );
  });

  test('premium avatar fallback prices are doubled and ordered', () {
    final prices = CosmeticCatalog.avatars
        .where((item) => item.priceType == CosmeticPriceType.premium)
        .map((item) => item.premiumPriceCents)
        .toList();
    expect(prices, [998, 998, 1198, 1198, 1398, 1398, 1598, 1598, 1998, 1998]);
  });

  test('five prestige avatars use permanent non-consuming thresholds', () {
    final prices = CosmeticCatalog.avatars
        .where((item) => item.priceType == CosmeticPriceType.prestigeStars)
        .map((item) => item.starPrice)
        .toList();
    expect(prices, [3, 5, 10, 20, 35]);
  });

  test('shop still has meaningful coin star and premium progression', () {
    final coinItems = CosmeticCatalog.forPriceType(CosmeticPriceType.coins);
    final starItems = CosmeticCatalog.forPriceType(CosmeticPriceType.prestigeStars);
    final premiumItems = CosmeticCatalog.forPriceType(CosmeticPriceType.premium);

    expect(coinItems.length, greaterThanOrEqualTo(30));
    expect(starItems.length, greaterThanOrEqualTo(13));
    expect(premiumItems.length, greaterThanOrEqualTo(15));
    expect(
      coinItems.map((item) => item.coinPrice).reduce((a, b) => a > b ? a : b),
      greaterThanOrEqualTo(30000),
    );
    expect(
      starItems.map((item) => item.starPrice).reduce((a, b) => a > b ? a : b),
      250,
    );
  });

  test('prestige star cosmetics can never also be premium', () {
    final starItems = CosmeticCatalog.forPriceType(CosmeticPriceType.prestigeStars);
    expect(starItems.every((item) => !item.isPremium), isTrue);
    expect(starItems.every((item) => item.premiumPriceCents == 0), isTrue);
  });

  test('every cosmetic has one and only one unlock path', () {
    for (final item in CosmeticCatalog.items) {
      final paths = <bool>[
        item.isFree,
        item.coinPrice > 0,
        item.starPrice > 0,
        item.isPremium || item.premiumPriceCents > 0,
        item.requiredAchievementId != null,
      ].where((value) => value).length;
      expect(paths, 1, reason: item.id);
    }
  });
}
