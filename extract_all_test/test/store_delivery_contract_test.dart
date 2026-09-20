import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/data/cosmetic_catalog.dart';
import 'package:game/features/economy/domain/cosmetic_item.dart';
import 'package:game/features/economy/domain/equipment_policy.dart';
import 'package:game/features/economy/presentation/avatar_artwork.dart';
import 'package:game/features/economy/presentation/cosmetic_runtime.dart';

void main() {
  test('all 45 catalog avatars have shipped artwork mappings', () {
    expect(CosmeticCatalog.avatars.length, 45);
    for (final avatar in CosmeticCatalog.avatars) {
      expect(
        AvatarArtwork.supports(avatar.id),
        isTrue,
        reason: '${avatar.id} is sold/earned but has no artwork mapping',
      );
    }
  });

  test('every cosmetic slot has at least one real catalog item', () {
    for (final slot in CosmeticSlot.values) {
      expect(
        CosmeticCatalog.items.any((item) => item.slot == slot),
        isTrue,
        reason: 'No deliverable exists for slot ${slot.name}',
      );
    }
  });

  test('high-value named cosmetics keep approved slot and unlock cost', () {
    void verify(
      String id,
      CosmeticSlot slot,
      CosmeticPriceType priceType, {
      int coins = 0,
      int stars = 0,
      int cents = 0,
    }) {
      final item = CosmeticCatalog.byId(id);
      expect(item, isNotNull, reason: '$id must remain in the shop');
      expect(item!.slot, slot, reason: '$id slot changed');
      expect(item.priceType, priceType, reason: '$id unlock path changed');
      expect(item.coinPrice, coins, reason: '$id coin price changed');
      expect(item.starPrice, stars, reason: '$id star threshold changed');
      expect(item.premiumPriceCents, cents, reason: '$id premium fallback changed');
    }

    verify('name_bold', CosmeticSlot.nameStyle, CosmeticPriceType.coins, coins: 500);
    verify('frame_classic', CosmeticSlot.avatarFrame, CosmeticPriceType.coins, coins: 750);
    verify('badge_timer', CosmeticSlot.badge, CosmeticPriceType.coins, coins: 1200);
    verify('background_grid', CosmeticSlot.profileBackground, CosmeticPriceType.coins, coins: 1600);
    verify('emote_gg', CosmeticSlot.emote, CosmeticPriceType.coins, coins: 2200);
    verify('frame_voltage', CosmeticSlot.avatarFrame, CosmeticPriceType.coins, coins: 7000);
    verify('room_arcade', CosmeticSlot.roomTheme, CosmeticPriceType.coins, coins: 16000);
    verify('aura_storm', CosmeticSlot.rankAura, CosmeticPriceType.coins, coins: 30000);
    verify('intro_champion', CosmeticSlot.matchIntro, CosmeticPriceType.prestigeStars, stars: 45);
    verify('victory_crown_burst', CosmeticSlot.victoryEffect, CosmeticPriceType.prestigeStars, stars: 120);
    verify('aura_mythic_legacy', CosmeticSlot.rankAura, CosmeticPriceType.prestigeStars, stars: 250);
    verify('intro_portal', CosmeticSlot.matchIntro, CosmeticPriceType.premium, cents: 399);
    verify('victory_lightning', CosmeticSlot.victoryEffect, CosmeticPriceType.premium, cents: 399);
    verify('room_cyber_royal', CosmeticSlot.roomTheme, CosmeticPriceType.premium, cents: 499);
  });

  test('equipment policy routes every slot without touching other slots', () {
    const base = PlayerInventory(
      coins: 999999,
      prestigeStars: 999,
      ownedCosmeticIds: {
        'avatar_free_vanguard',
        'frame_voltage',
        'badge_timer',
        'background_grid',
        'name_bold',
        'intro_portal',
        'victory_crown_burst',
        'aura_mythic_legacy',
        'emote_gg',
        'room_cyber_royal',
      },
    );

    final expected = <CosmeticSlot, String>{
      CosmeticSlot.avatar: 'avatar_free_vanguard',
      CosmeticSlot.avatarFrame: 'frame_voltage',
      CosmeticSlot.badge: 'badge_timer',
      CosmeticSlot.profileBackground: 'background_grid',
      CosmeticSlot.nameStyle: 'name_bold',
      CosmeticSlot.matchIntro: 'intro_portal',
      CosmeticSlot.victoryEffect: 'victory_crown_burst',
      CosmeticSlot.rankAura: 'aura_mythic_legacy',
      CosmeticSlot.emote: 'emote_gg',
      CosmeticSlot.roomTheme: 'room_cyber_royal',
    };

    for (final entry in expected.entries) {
      final item = CosmeticCatalog.byId(entry.value)!;
      final next = EquipmentPolicy.previewEquip(inventory: base, item: item);
      final equipped = switch (entry.key) {
        CosmeticSlot.avatar => next.equippedAvatarId,
        CosmeticSlot.avatarFrame => next.equippedAvatarFrameId,
        CosmeticSlot.badge => next.equippedBadgeId,
        CosmeticSlot.profileBackground => next.equippedProfileBackgroundId,
        CosmeticSlot.nameStyle => next.equippedNameStyleId,
        CosmeticSlot.matchIntro => next.equippedMatchIntroId,
        CosmeticSlot.victoryEffect => next.equippedVictoryEffectId,
        CosmeticSlot.rankAura => next.equippedRankAuraId,
        CosmeticSlot.emote => next.equippedEmoteId,
        CosmeticSlot.roomTheme => next.equippedRoomThemeId,
      };
      expect(equipped, entry.value, reason: '${entry.key.name} delivery failed');
      expect(next.coins, base.coins, reason: 'equipping must never spend Coins');
      expect(next.prestigeStars, base.prestigeStars, reason: 'equipping must never spend Stars');
    }
  });

  for (final id in <String>[
    'name_bold',
    'frame_classic',
    'badge_timer',
    'background_grid',
    'emote_gg',
    'frame_neon',
    'name_champion',
    'frame_voltage',
    'background_arena',
    'victory_confetti',
    'name_electric',
    'room_arcade',
    'intro_redline',
    'aura_storm',
    'badge_crown',
    'frame_prestige',
    'aura_rank_flare',
    'intro_champion',
    'background_constellation',
    'name_royal',
    'victory_crown_burst',
    'frame_elite',
    'aura_mythic_legacy',
    'frame_obsidian',
    'background_void',
    'intro_portal',
    'victory_lightning',
    'room_cyber_royal',
  ]) {
    testWidgets('$id has an applied in-game preview', (tester) async {
      final item = CosmeticCatalog.byId(id)!;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 420,
                height: 420,
                child: CosmeticAppliedPreview(item: item),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$id preview threw an exception');
      expect(find.byType(CosmeticAppliedPreview), findsOneWidget);
    });
  }
}
