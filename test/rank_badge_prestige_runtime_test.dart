import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/presentation/rank_badge.dart';
import 'package:game/l10n/app_localizations.dart';

Widget _host(RankBadge badge) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: badge)),
  );
}

void main() {
  testWidgets('Legendary rank badge exposes permanent season repetition count',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const RankBadge(
          tier: RankTier.legend,
          legendarySeasons: 3,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('×3'), findsOneWidget);
    expect(find.byType(RankBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Legendary count is visible from the first earned season',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const RankBadge(
          tier: RankTier.legend,
          legendarySeasons: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('×1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-Legendary ranks never display Legendary repetition data',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const RankBadge(
          tier: RankTier.grandmaster,
          legendarySeasons: 99,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('×99'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
