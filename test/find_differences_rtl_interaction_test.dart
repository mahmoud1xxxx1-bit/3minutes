import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/find_differences_plan.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/presentation/find_differences/find_differences_game.dart';

void main() {
  const config = MiniGameConfig(seed: 20260820, difficulty: 0);

  Future<void> pumpGame(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SizedBox(
            width: 430,
            height: 760,
            child: FindDifferencesGame(config: config, onComplete: (_) {}),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> tapFirstDifference(WidgetTester tester) async {
    final plan = FindDifferencesPlan.fromSeed(seed: config.seed, difficulty: config.difficulty);
    final difference = plan.differences.first;
    final finder = find.byKey(const ValueKey('find-differences-board-b'));
    final size = tester.getSize(finder);
    final topLeft = tester.getTopLeft(finder);
    final local = Offset(
      difference.centerX / FindDifferencesPlan.logicalWidth * size.width,
      difference.centerY / FindDifferencesPlan.logicalHeight * size.height,
    );
    await tester.tapAt(topLeft + local);
    await tester.pump();
  }

  testWidgets('Arabic tap geometry finds the same logical difference', (tester) async {
    await pumpGame(tester, const Locale('ar'));
    await tapFirstDifference(tester);
    expect(find.text('وجدت: 1/3'), findsOneWidget);
    expect(find.text('الأخطاء: 0'), findsOneWidget);
  });

  testWidgets('English tap geometry finds the same logical difference', (tester) async {
    await pumpGame(tester, const Locale('en'));
    await tapFirstDifference(tester);
    expect(find.text('Found: 1/3'), findsOneWidget);
    expect(find.text('Mistakes: 0'), findsOneWidget);
  });

  test('logical coordinate conversion is direction agnostic', () {
    const board = Size(400, 300);
    const local = Offset(55, 51.5);
    final logical = findDifferencesLogicalPoint(local, board);
    expect(logical.dx, closeTo(110, .001));
    expect(logical.dy, closeTo(103, .001));
  });
}
