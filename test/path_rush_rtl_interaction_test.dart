import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/presentation/path_rush/path_rush_game.dart';

void main() {
  Future<void> pumpGame(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(
          body: SizedBox(
            width: 430,
            height: 760,
            child: PathRushGame(
              config: const MiniGameConfig(seed: 20260820, difficulty: 0),
              onComplete: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('approved RTL geometry stays 3-left 2-center 1-right', (tester) async {
    await pumpGame(tester);

    final x3 = tester.getCenter(find.text('3')).dx;
    final x2 = tester.getCenter(find.text('2')).dx;
    final x1 = tester.getCenter(find.text('1')).dx;

    expect(x3, lessThan(x2));
    expect(x2, lessThan(x1));
  });

  testWidgets('tapping visible 1 selects lane 1 control, never visible 3', (tester) async {
    await pumpGame(tester);

    await tester.tap(find.text('1'));
    await tester.pump(const Duration(milliseconds: 16));

    AnimatedContainer containerFor(String number) {
      final finder = find.ancestor(
        of: find.text(number),
        matching: find.byType(AnimatedContainer),
      );
      return tester.widget<AnimatedContainer>(finder.first);
    }

    final oneDecoration = containerFor('1').decoration! as BoxDecoration;
    final threeDecoration = containerFor('3').decoration! as BoxDecoration;

    expect(oneDecoration.boxShadow, isNotEmpty);
    expect(threeDecoration.boxShadow, isEmpty);
  });
}
