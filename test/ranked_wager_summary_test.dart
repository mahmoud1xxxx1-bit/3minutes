import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/presentation/ranked_wager_summary.dart';

void main() {
  testWidgets('shows authoritative wager and pot values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RankedWagerSummary(wagerCoins: 100, potCoins: 200),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('ranked-wager-summary')), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('compact summary keeps wager and pot together', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RankedWagerSummary(
            wagerCoins: 75,
            potCoins: 150,
            compact: true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ranked-wager-summary-compact')),
      findsOneWidget,
    );
    expect(find.textContaining('75'), findsOneWidget);
    expect(find.textContaining('150'), findsOneWidget);
  });
}
