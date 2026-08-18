import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/cosmetic_item.dart';

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
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: rarityColor.withValues(alpha: 0.08),
          border: Border.all(color: rarityColor.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: _visual(),
        ),
      ),
    );
  }

  Widget _visual() {
    return switch (item.id) {
      'frame_classic' => _AvatarFrame(
          color: GameColors.rankSilver,
          glow: false,
        ),
      'frame_neon' => _AvatarFrame(
          color: GameColors.accent,
          glow: true,
        ),
      'badge_timer' => _BadgeVisual(
          color: GameColors.rankDiamond,
          child: const Text(
            '3',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ),
      'badge_crown' => _BadgeVisual(
          color: GameColors.rewardGold,
          child: const Icon(Icons.workspace_premium_rounded, size: 22),
        ),
      'background_grid' => const _GridVisual(),
      'background_arena' => const _ArenaVisual(),
      'name_bold' => _NameVisual(
          color: GameColors.rankSilver,
          fontWeight: FontWeight.w900,
        ),
      'name_champion' => _NameVisual(
          color: GameColors.rewardGold,
          fontWeight: FontWeight.w900,
          underline: true,
        ),
      _ => Icon(Icons.auto_awesome_rounded, color: rarityColor),
    };
  }
}

class _AvatarFrame extends StatelessWidget {
  const _AvatarFrame({required this.color, required this.glow});

  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: glow ? 3 : 2),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 21, color: GameColors.textStrong),
      ),
    );
  }
}

class _BadgeVisual extends StatelessWidget {
  const _BadgeVisual({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.65)),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(color: color),
        child: DefaultTextStyle(
          style: TextStyle(color: color),
          child: child,
        ),
      ),
    );
  }
}

class _GridVisual extends StatelessWidget {
  const _GridVisual();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const RadialGradient(
          colors: [Color(0xFF7B61FF), Color(0xFF111827)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class _NameVisual extends StatelessWidget {
  const _NameVisual({
    required this.color,
    required this.fontWeight,
    this.underline = false,
  });

  final Color color;
  final FontWeight fontWeight;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return Center(
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
}
