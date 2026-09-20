import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/data/cosmetic_catalog.dart';
import 'package:game/features/economy/domain/cosmetic_item.dart';
import 'package:game/features/economy/presentation/avatar_artwork.dart';

void main() {
  group('cosmetic delivery contract', () {
    test('all 45 catalog avatars have artwork delivery support', () {
      final avatars = CosmeticCatalog.items
          .where((item) => item.slot == CosmeticSlot.avatar)
          .toList(growable: false);

      expect(avatars, hasLength(45));
      for (final avatar in avatars) {
        expect(
          AvatarArtwork.supports(avatar.id),
          isTrue,
          reason: '${avatar.id} is sold/unlocked but has no avatar artwork mapping.',
        );
      }
    });

    test('every non-avatar cosmetic is mapped to an implemented runtime id', () {
      const supportedBySlot = <CosmeticSlot, Set<String>>{
        CosmeticSlot.avatarFrame: {
          'frame_classic',
          'frame_neon',
          'frame_voltage',
          'frame_prestige',
          'frame_elite',
          'frame_obsidian',
        },
        CosmeticSlot.badge: {
          'badge_timer',
          'badge_crown',
        },
        CosmeticSlot.profileBackground: {
          'background_grid',
          'background_arena',
          'background_constellation',
          'background_void',
        },
        CosmeticSlot.nameStyle: {
          'name_bold',
          'name_champion',
          'name_electric',
          'name_royal',
        },
        CosmeticSlot.matchIntro: {
          'intro_redline',
          'intro_champion',
          'intro_portal',
        },
        CosmeticSlot.victoryEffect: {
          'victory_confetti',
          'victory_crown_burst',
          'victory_lightning',
        },
        CosmeticSlot.rankAura: {
          'aura_storm',
          'aura_rank_flare',
          'aura_mythic_legacy',
        },
        CosmeticSlot.emote: {
          'emote_gg',
        },
        CosmeticSlot.roomTheme: {
          'room_arcade',
          'room_cyber_royal',
        },
      };

      for (final item in CosmeticCatalog.items) {
        if (item.slot == CosmeticSlot.avatar) continue;
        final supported = supportedBySlot[item.slot];
        expect(
          supported,
          isNotNull,
          reason: 'No runtime delivery contract exists for ${item.slot}.',
        );
        expect(
          supported!.contains(item.id),
          isTrue,
          reason: '${item.id} exists in the shop but is not implemented by its runtime slot.',
        );
      }
    });

    test('delivery contract has no orphan runtime ids', () {
      final catalogIds = CosmeticCatalog.items.map((item) => item.id).toSet();
      const runtimeIds = <String>{
        'frame_classic',
        'frame_neon',
        'frame_voltage',
        'frame_prestige',
        'frame_elite',
        'frame_obsidian',
        'badge_timer',
        'badge_crown',
        'background_grid',
        'background_arena',
        'background_constellation',
        'background_void',
        'name_bold',
        'name_champion',
        'name_electric',
        'name_royal',
        'intro_redline',
        'intro_champion',
        'intro_portal',
        'victory_confetti',
        'victory_crown_burst',
        'victory_lightning',
        'aura_storm',
        'aura_rank_flare',
        'aura_mythic_legacy',
        'emote_gg',
        'room_arcade',
        'room_cyber_royal',
      };

      expect(runtimeIds.difference(catalogIds), isEmpty);
    });
  });
}
