import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/domain/cosmetic_loadout.dart';
import 'package:game/features/economy/presentation/cosmetic_runtime.dart';
import 'package:game/features/match/presentation/matchmaking_player_identity.dart';

Widget _host(CosmeticLoadout loadout) => MaterialApp(
      home: Scaffold(
        body: MatchmakingPlayerIdentity(
          avatarId: 'avatar_free_vanguard',
          displayName: 'Player One',
          loadout: loadout,
        ),
      ),
    );

void main() {
  testWidgets('falls back to the profile avatar while loadout is empty',
      (tester) async {
    await tester.pumpWidget(_host(const CosmeticLoadout()));

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, 'avatar_free_vanguard');
    expect(avatar.frameId, isNull);
    expect(find.text('Player One'), findsOneWidget);
  });

  testWidgets('equipped identity overrides matchmaking visuals',
      (tester) async {
    await tester.pumpWidget(
      _host(
        const CosmeticLoadout(
          avatarId: 'avatar_free_arc',
          avatarFrameId: 'frame_classic',
          badgeId: 'badge_crown',
          nameStyleId: 'name_bold',
        ),
      ),
    );

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, 'avatar_free_arc');
    expect(avatar.frameId, 'frame_classic');
    expect(find.byType(CosmeticBadgeView), findsOneWidget);
  });
}
