import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/domain/mini_game_contract.dart';
import 'package:game/features/minigames/presentation/find_differences_policy_game.dart';

void main() {
  Future<int> pumpPolicyGame(WidgetTester tester, Locale locale) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        home: Scaffold(
          body: SizedBox(
            width: 430,
            height: 760,
            child: FindDifferencesPolicyGame(
              config: const MiniGameConfig(seed: 20260820, difficulty: 1),
              onComplete: (_) => completions++,
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
      await pumpPolicyGame(tester, locale);

      expect(find.byKey(const ValueKey('find-differences-found')), findsOneWidget);
      expect(find.byKey(const ValueKey('find-differences-mistakes')), findsOneWidget);
      expect(find.textContaining('S01-'), findsNothing);
      expect(find.textContaining('Time'), findsNothing);
      expect(find.textContaining('الوقت'), findsNothing);
      expect(find.textContaining('20.0'), findsNothing);
      expect(find.textContaining('18.0'), findsNothing);
      expect(find.textContaining('22.0'), findsNothing);
    });

    testWidgets('find differences never auto-completes from an internal timeout in ${locale.languageCode}', (tester) async {
      var completions = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          home: Scaffold(
            body: SizedBox(
              width: 430,
              height: 760,
              child: FindDifferencesPolicyGame(
                config: const MiniGameConfig(seed: 20260820, difficulty: 0),
                onComplete: (_) => completions++,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 30));
      expect(completions, 0);
    });
  }
}
