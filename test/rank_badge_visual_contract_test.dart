import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/presentation/rank_badge.dart';
import 'package:game/l10n/app_localizations.dart';

void main() {
  test('top rank display label is Legendary', () {
    expect(RankTier.legend.label, 'Legendary');
  });

  testWidgets('Legendary prestige milestones render safely', (tester) async {
    for (final seasons in <int>[0, 1, 2, 3, 5, 10]) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: RankBadge(
                tier: RankTier.legend,
                legendarySeasons: seasons,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'Legendary ×$seasons');
      expect(find.text('Legendary'), findsOneWidget);
      if (seasons > 0) {
        expect(find.text('×$seasons'), findsOneWidget);
      }
    }
  });
}
