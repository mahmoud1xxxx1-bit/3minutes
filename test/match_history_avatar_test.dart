import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/match/presentation/match_history_avatar.dart';

void main() {
  testWidgets('renders the exact opponent avatar with result status',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: MatchHistoryAvatar(
              avatarId: 'avatar_free_vanguard',
              statusColor: Colors.green,
              statusIcon: Icons.emoji_events_rounded,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('match-history-avatar-avatar_free_vanguard')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });
}
