import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/data/cosmetic_catalog.dart';
import 'package:game/features/economy/presentation/cosmetic_runtime.dart';

void main() {
  testWidgets('every animated cosmetic renders and advances without exceptions',
      (tester) async {
    final animatedItems = CosmeticCatalog.items
        .where((item) => item.isAnimated)
        .toList(growable: false);

    expect(animatedItems, isNotEmpty);

    for (final item in animatedItems) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 360,
                child: CosmeticAppliedPreview(item: item),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull, reason: '${item.id} initial frame');
      await tester.pump(const Duration(milliseconds: 120));
      expect(tester.takeException(), isNull, reason: '${item.id} animated frame');
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull, reason: '${item.id} later frame');
    }
  });
}
