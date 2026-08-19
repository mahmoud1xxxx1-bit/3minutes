import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/presentation/rank_legacy_showcase.dart';

void main() {
  testWidgets('legacy showcase renders earned historical emblem separately', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: RankLegacyShowcase(tier: RankTier.diamond),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('LEGACY SHOWCASE'), findsOneWidget);
    expect(find.text('Diamond'), findsOneWidget);
    expect(find.byIcon(Icons.history_edu_rounded), findsOneWidget);
  });
}
