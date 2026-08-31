import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/presentation/find_differences/find_differences_game.dart';
import 'package:game/features/minigames/presentation/shared/minigame_environment.dart';

void main() {
  const config = MiniGameConfig(seed: 20260820, difficulty: 0);

  testWidgets('Arabic tap geometry finds all 5 differences', (tester) async {
    int completions = 0;
    MiniGameResult? finalResult;
    final controller = MinigameEnvironmentController();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: MinigameEnvironment(
            controller: controller,
            child: SizedBox(
              width: 800,
              height: 1200,
              child: FindDifferencesGame(
                config: config, 
                onComplete: (res) {
                  completions++;
                  finalResult = res;
                }
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final finder = find.byKey(const ValueKey('find-differences-board-b'));
    expect(finder, findsOneWidget);
    
    final size = tester.getSize(finder);
    final topLeft = tester.getTopLeft(finder);
    
    final centers = [
      const Offset(645, 75),
      const Offset(150, 400),
      const Offset(650, 460),
      const Offset(310, 415),
      const Offset(300, 320),
    ];

    for (final center in centers) {
      final local = Offset(
        center.dx / 800.0 * size.width,
        center.dy / 600.0 * size.height,
      );
      await tester.tapAt(topLeft + local);
      await tester.pump();
    }

    expect(completions, 1);
    expect(finalResult, isNotNull);
    expect(finalResult!.completed, true);
    expect(finalResult!.mistakes, 0);
    expect(finalResult!.accuracy, 1.0);
  });
}
