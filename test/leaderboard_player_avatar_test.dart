import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/presentation/leaderboard_player_avatar.dart';

void main() {
  testWidgets('renders the exact leaderboard avatar id', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: LeaderboardPlayerAvatar(
              avatarId: 'avatar_free_vanguard',
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('leaderboard-avatar-avatar_free_vanguard')),
      findsOneWidget,
    );
  });

  testWidgets('podium avatar keeps the same player identity', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: LeaderboardPlayerAvatar(
              avatarId: 'avatar_free_arc',
              podium: true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('leaderboard-avatar-avatar_free_arc')),
      findsOneWidget,
    );
  });
}
