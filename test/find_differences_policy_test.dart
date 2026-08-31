import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/presentation/find_differences/find_differences_game.dart';
import 'package:game/features/minigames/presentation/shared/minigame_environment.dart';

void main() {
  Future<int> pumpGame(WidgetTester tester, Locale locale) async {
    var completions = 0;
    final controller = MinigameEnvironmentController();
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
          body: MinigameEnvironment(
            controller: controller,
            child: SizedBox(
              width: 430,
              height: 760,
              child: FindDifferencesGame(
                config: const MiniGameConfig(seed: 20260820, difficulty: 1),
                onComplete: (_) => completions++,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return completions;
  }

  for (final locale in const [Locale('ar'), Locale('en')]) {
    testWidgets('find differences hides timer and internal variant in ${locale.languageCode}', (tester) async {
      await pumpGame(tester, locale);
      
      expect(find.byType(FindDifferencesGame), findsOneWidget);
      expect(find.textContaining('S01-'), findsNothing);
      expect(find.textContaining('Time'), findsNothing);
      expect(find.textContaining('Ø§Ù„ÙˆÙ‚Øª'), findsNothing);
      expect(find.textContaining('20.0'), findsNothing);
      expect(find.textContaining('18.0'), findsNothing);
      expect(find.textContaining('22.0'), findsNothing);
    });

    testWidgets('find differences never auto-completes from an internal timeout in ${locale.languageCode}', (tester) async {
      var completions = 0;
      final controller = MinigameEnvironmentController();
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
            body: MinigameEnvironment(
              controller: controller,
              child: SizedBox(
                width: 430,
                height: 760,
                child: FindDifferencesGame(
                  config: const MiniGameConfig(seed: 20260820, difficulty: 0),
                  onComplete: (_) => completions++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(completions, 0); // Should not auto-complete
    });
  }
}
