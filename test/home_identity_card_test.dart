import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/economy/domain/cosmetic_item.dart';
import 'package:game/features/economy/presentation/cosmetic_runtime.dart';
import 'package:game/features/home/presentation/home_identity_card.dart';
import 'package:game/features/profile/domain/player_profile.dart';
import 'package:game/l10n/app_localizations.dart';

Widget _host({required PlayerProfile profile, PlayerInventory? inventory}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: HomeIdentityCard(profile: profile, inventory: inventory),
    ),
  );
}

const _profile = PlayerProfile(
  uid: 'player-1',
  gameName: 'Legend',
  avatarId: 'avatar_free_vanguard',
  level: 17,
  xp: 500,
  rankPoints: 12000,
  stars: 42,
  wins: 100,
  losses: 10,
  gamesPlayed: 115,
  legendarySeasons: 3,
  peakRankTier: RankTier.legend,
);

void main() {
  testWidgets('equipped inventory cosmetics override home identity visuals',
      (tester) async {
    const inventory = PlayerInventory(
      coins: 1000,
      ownedCosmeticIds: {
        'avatar_coin_01',
        'frame_neon',
        'badge_crown',
        'name_champion',
        'aura_rank_flare',
        'background_grid',
      },
      equippedAvatarId: 'avatar_coin_01',
      equippedAvatarFrameId: 'frame_neon',
      equippedBadgeId: 'badge_crown',
      equippedNameStyleId: 'name_champion',
      equippedRankAuraId: 'aura_rank_flare',
      equippedProfileBackgroundId: 'background_grid',
    );

    await tester.pumpWidget(_host(profile: _profile, inventory: inventory));
    await tester.pump();

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, 'avatar_coin_01');
    expect(avatar.frameId, 'frame_neon');

    final name = tester.widget<CosmeticNameText>(
      find.byType(CosmeticNameText),
    );
    expect(name.styleId, 'name_champion');
    expect(find.byType(CosmeticBadgeView), findsOneWidget);
    expect(find.byType(CosmeticRankAura), findsOneWidget);
    expect(find.text('×3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home identity safely falls back to profile avatar',
      (tester) async {
    await tester.pumpWidget(_host(profile: _profile));
    await tester.pump();

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, _profile.avatarId);
    expect(avatar.frameId, isNull);
    expect(find.text('×3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
