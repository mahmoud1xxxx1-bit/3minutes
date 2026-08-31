import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/minigames/data/game_registry.dart';
import 'package:game/features/minigames/presentation/mini_game_copy.dart';

void main() {
  Future<Map<String, String>> titlesFor(
    WidgetTester tester,
    Locale locale,
  ) async {
    final result = <String, String>{};
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            final copy = MiniGameCopy.fromContext(context);
            for (final game in GameRegistry.games) {
              result[game.id] = copy.title(game.id);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return result;
  }

  testWidgets('all approved mini-games expose English and Arabic titles',
      (tester) async {
    final english = await titlesFor(tester, const Locale('en'));
    final arabic = await titlesFor(tester, const Locale('ar'));

    expect(english.length, GameRegistry.games.length);
    expect(arabic.length, GameRegistry.games.length);
    for (final game in GameRegistry.games) {
      expect(english[game.id], isNotEmpty);
      expect(arabic[game.id], isNotEmpty);
    }
  });
}
