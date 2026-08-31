import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/domain/cosmetic_loadout.dart';
import 'package:game/features/economy/presentation/cosmetic_runtime.dart';
import 'package:game/features/match/presentation/social_result_identity.dart';

void main() {
  testWidgets('winner header uses match avatar when loadout is empty',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SocialResultWinnerHeader(
            winnerUid: 'winner-1',
            winnerName: 'Winner',
            winnerAvatarId: 'avatar_free_vanguard',
            loadout: CosmeticLoadout(),
            placementLabel: 'VICTORY',
            isWinner: true,
          ),
        ),
      ),
    );

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, 'avatar_free_vanguard');
    expect(find.text('Winner'), findsOneWidget);
    expect(find.text('VICTORY'), findsOneWidget);
  });

  testWidgets('winner equipped identity overrides result presentation',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SocialResultWinnerHeader(
            winnerUid: 'winner-2',
            winnerName: 'Champion',
            winnerAvatarId: 'avatar_free_vanguard',
            loadout: CosmeticLoadout(
              avatarId: 'avatar_free_arc',
              avatarFrameId: 'frame_classic',
              badgeId: 'badge_crown',
              nameStyleId: 'name_bold',
              profileBackgroundId: 'background_grid',
            ),
            placementLabel: '#2',
            isWinner: false,
          ),
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

  testWidgets('placement avatar keeps participant identity and podium state',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SocialPlacementAvatar(
            avatarId: 'avatar_free_arc',
            position: 1,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('social-placement-avatar-avatar_free_arc')),
      findsOneWidget,
    );
  });
}
