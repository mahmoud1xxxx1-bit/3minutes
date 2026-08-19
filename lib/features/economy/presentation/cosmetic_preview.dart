import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/cosmetic_item.dart';
import 'avatar_artwork.dart';

class CosmeticPreview extends StatelessWidget {
  const CosmeticPreview({
    super.key,
    required this.item,
    required this.rarityColor,
    this.size = 58,
  });

  final CosmeticItem item;
  final Color rarityColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glow = item.isAnimated ||
        item.rarity == CosmeticRarity.legendary ||
        item.rarity == CosmeticRarity.mythic;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              rarityColor.withValues(alpha: 0.20),
              GameColors.surfaceRaised,
            ],
          ),
          border: Border.all(
            color: rarityColor.withValues(alpha: glow ? 0.78 : 0.38),
            width: glow ? 1.8 : 1,
          ),
          boxShadow: glow
              ? [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.18),
                    blurRadius: size * 0.20,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: _visual(),
        ),
      ),
    );
  }

  Widget _visual() {
    if (item.slot == CosmeticSlot.avatar && AvatarArtwork.supports(item.id)) {
      return AvatarArtwork(
        avatarId: item.id,
        size: size * 0.84,
        borderRadius: size * 0.20,
      );
    }
    return switch (item.id) {
      'frame_classic' => _AvatarFrame(color: GameColors.rankSilver, glow: false),
      'frame_neon' => _AvatarFrame(color: GameColors.accent, glow: true),
      'frame_voltage' => _AvatarFrame(color: GameColors.rarityEpic, glow: true),
      'frame_prestige' => _AvatarFrame(color: GameColors.rewardGold, glow: true),
      'frame_elite' => _AvatarFrame(color: GameColors.rarityMythic, glow: true),
      'frame_obsidian' => const _ObsidianFrame(),
      'badge_timer' => _BadgeVisual(
          color: GameColors.rankDiamond,
          child: const Text('3', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ),
      'badge_crown' => _BadgeVisual(
          color: GameColors.rewardGold,
          child: const Icon(Icons.workspace_premium_rounded, size: 22),
        ),
      'background_grid' => const _GridVisual(),
      'background_arena' => const _ArenaVisual(),
      'background_constellation' => const _ConstellationVisual(),
      'background_void' => const _VoidVisual(),
      'name_bold' => _NameVisual(color: GameColors.rankSilver, fontWeight: FontWeight.w900),
      'name_champion' => _NameVisual(
          color: GameColors.rewardGold,
          fontWeight: FontWeight.w900,
          underline: true,
        ),
      'name_electric' => _NameVisual(color: GameColors.accent, fontWeight: FontWeight.w900),
      'name_royal' => _NameVisual(color: GameColors.rewardGold, fontWeight: FontWeight.w900),
      'emote_gg' => const _TextOrb(text: 'GG'),
      'victory_confetti' => const _IconOrb(icon: Icons.celebration_rounded),
      'victory_crown_burst' => const _IconOrb(icon: Icons.workspace_premium_rounded),
      'victory_lightning' => const _IconOrb(icon: Icons.bolt_rounded),
      'intro_redline' => const _IconOrb(icon: Icons.double_arrow_rounded),
      'intro_champion' => const _IconOrb(icon: Icons.emoji_events_rounded),
      'intro_portal' => const _PortalVisual(),
      'aura_storm' => const _AuraVisual(icon: Icons.thunderstorm_rounded),
      'aura_rank_flare' => const _AuraVisual(icon: Icons.local_fire_department_rounded),
      'aura_mythic_legacy' => const _AuraVisual(icon: Icons.auto_awesome_rounded),
      'room_arcade' => const _RoomVisual(icon: Icons.sports_esports_rounded),
      'room_cyber_royal' => const _RoomVisual(icon: Icons.diamond_rounded),
      _ => _fallbackForSlot(),
    };
  }

  Widget _fallbackForSlot() => switch (item.slot) {
        CosmeticSlot.avatar => const _IconOrb(icon: Icons.person_rounded),
        CosmeticSlot.avatarFrame => _AvatarFrame(color: rarityColor, glow: true),
        CosmeticSlot.badge => _BadgeVisual(
            color: rarityColor,
            child: const Icon(Icons.shield_rounded, size: 21),
          ),
        CosmeticSlot.profileBackground => const _ArenaVisual(),
        CosmeticSlot.nameStyle => _NameVisual(color: rarityColor, fontWeight: FontWeight.w900),
        CosmeticSlot.matchIntro => const _IconOrb(icon: Icons.play_circle_fill_rounded),
        CosmeticSlot.victoryEffect => const _IconOrb(icon: Icons.celebration_rounded),
        CosmeticSlot.rankAura => const _AuraVisual(icon: Icons.auto_awesome_rounded),
        CosmeticSlot.emote => const _TextOrb(text: '!'),
        CosmeticSlot.roomTheme => const _RoomVisual(icon: Icons.grid_view_rounded),
      };
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({required this.color, required this.glow});
  final Color color;
  final bool glow;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: glow ? 3 : 2),
          boxShadow: glow
              ? [BoxShadow(color: color.withValues(alpha: 0.28), blurRadius: 10)]
              : null,
        ),
        child: const Center(
          child: Icon(Icons.person_rounded, size: 21, color: GameColors.textStrong),
        ),
      );
}

class _ObsidianFrame extends StatelessWidget {
  const _ObsidianFrame();
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [Color(0xFF202535), Color(0xFF7B61FF), Color(0xFF05070B), Color(0xFF202535)],
          ),
          boxShadow: [
            BoxShadow(color: GameColors.rarityEpic.withValues(alpha: 0.25), blurRadius: 10),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: const DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: GameColors.surface),
          child: Icon(Icons.person_rounded, color: GameColors.textStrong),
        ),
      );
}

class _BadgeVisual extends StatelessWidget {
  const _BadgeVisual({required this.color, required this.child});
  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.65)),
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: color),
          child: DefaultTextStyle(style: TextStyle(color: color), child: child),
        ),
      );
}

class _GridVisual extends StatelessWidget {
  const _GridVisual();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.rankDiamond.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArenaVisual extends StatelessWidget {
  const _ArenaVisual();
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const RadialGradient(colors: [Color(0xFF7B61FF), Color(0xFF111827)]),
        ),
        child: const Center(child: Icon(Icons.bolt_rounded, color: Colors.white, size: 24)),
      );
}

class _ConstellationVisual extends StatelessWidget {
  const _ConstellationVisual();
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [Color(0xFF141A35), Color(0xFF30205C)]),
        ),
        child: const Center(child: Icon(Icons.auto_awesome_rounded, color: GameColors.rewardGold)),
      );
}

class _VoidVisual extends StatelessWidget {
  const _VoidVisual();
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const RadialGradient(colors: [Color(0xFF6337A8), Color(0xFF05060B)]),
        ),
        child: const Center(child: Icon(Icons.blur_circular_rounded, color: Colors.white)),
      );
}

class _NameVisual extends StatelessWidget {
  const _NameVisual({required this.color, required this.fontWeight, this.underline = false});
  final Color color;
  final FontWeight fontWeight;
  final bool underline;
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          'Aa',
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: fontWeight,
            decoration: underline ? TextDecoration.underline : null,
            decorationColor: color,
          ),
        ),
      );
}

class _IconOrb extends StatelessWidget {
  const _IconOrb({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Icon(icon, color: Colors.white, size: 27));
}

class _TextOrb extends StatelessWidget {
  const _TextOrb({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      );
}

class _AuraVisual extends StatelessWidget {
  const _AuraVisual({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: GameColors.rarityMythic, width: 2),
          boxShadow: [
            BoxShadow(color: GameColors.rarityMythic.withValues(alpha: 0.30), blurRadius: 12),
          ],
        ),
        child: Center(child: Icon(icon, color: GameColors.rarityMythic, size: 23)),
      );
}

class _PortalVisual extends StatelessWidget {
  const _PortalVisual();
  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [Color(0xFF00D4FF), Color(0xFF7B61FF), Color(0xFFFF4FD8), Color(0xFF00D4FF)],
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: const DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, color: GameColors.surface),
          child: Icon(Icons.arrow_forward_rounded, color: Colors.white),
        ),
      );
}

class _RoomVisual extends StatelessWidget {
  const _RoomVisual({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GameColors.accent.withValues(alpha: 0.5)),
        ),
        child: Center(child: Icon(icon, color: GameColors.accent, size: 25)),
      );
}
