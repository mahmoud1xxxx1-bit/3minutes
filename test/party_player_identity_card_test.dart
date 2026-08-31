import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/presentation/rank_badge.dart';
import 'package:game/features/economy/presentation/cosmetic_runtime.dart';
import 'package:game/features/social/domain/social_player_summary.dart';
import 'package:game/features/social/presentation/party_screen.dart';

void main() {
  testWidgets('party player card renders equipped public identity', (tester) async {
    const player = SocialPlayerSummary(
      uid: 'player-1',
      displayName: 'Legend',
      avatarId: 'avatar_free_vanguard',
      rankPoints: 12000,
      level: 27,
      stars: 84,
      legendarySeasons: 3,
      avatarFrameId: 'frame_neon',
      badgeId: 'badge_crown',
      nameStyleId: 'name_royal',
      rankAuraId: 'aura_rank_flare',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PartyPlayerIdentityCard(
            player: player,
            subtitle: 'Leader',
            trailing: Icon(Icons.more_horiz_rounded),
          ),
        ),
      ),
    );

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, 'avatar_free_vanguard');
    expect(avatar.frameId, 'frame_neon');

    final name = tester.widget<CosmeticNameText>(
      find.byType(CosmeticNameText),
    );
    expect(name.text, 'Legend');
    expect(name.styleId, 'name_royal');

    final badge = tester.widget<CosmeticBadgeView>(
      find.byType(CosmeticBadgeView),
    );
    expect(badge.badgeId, 'badge_crown');

    final rank = tester.widget<RankBadge>(find.byType(RankBadge));
    expect(rank.legendarySeasons, 3);

    expect(find.text('Leader'), findsOneWidget);
    expect(find.text('Lv 27'), findsOneWidget);
    expect(find.text('★ 84'), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsNothing);
  });

  testWidgets('party player card keeps identity without optional cosmetics', (tester) async {
    const player = SocialPlayerSummary(
      uid: 'player-2',
      displayName: 'Rookie',
      avatarId: 'avatar_free_vanguard',
      rankPoints: 0,
      level: 1,
      stars: 0,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PartyPlayerIdentityCard(
            player: player,
            trailing: SizedBox.shrink(),
          ),
        ),
      ),
    );

    expect(find.byType(CosmeticAvatarView), findsOneWidget);
    expect(find.byType(CosmeticBadgeView), findsNothing);
    expect(find.byType(RankBadge), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsNothing);
  });
}
