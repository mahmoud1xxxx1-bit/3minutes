import 'package:flutter/material.dart';

import 'design_tokens.dart';

class CosmicBackground extends StatelessWidget {
  const CosmicBackground({
    super.key,
    required this.child,
    this.showOrbs = true,
  });

  final Widget child;
  final bool showOrbs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: GameColors.cosmicBackgroundGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showOrbs) ...[
            const PositionedDirectional(
              top: -90,
              start: -70,
              child: _CosmicOrb(
                size: 220,
                colors: [Color(0x337957F5), Color(0x0019DCE8)],
              ),
            ),
            const PositionedDirectional(
              top: 170,
              end: -110,
              child: _CosmicOrb(
                size: 260,
                colors: [Color(0x2519DCE8), Color(0x00D454E8)],
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _CosmicOrb extends StatelessWidget {
  const _CosmicOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}

class CosmicPrimaryButton extends StatelessWidget {
  const CosmicPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : GameColors.cosmicGradient,
        color: onPressed == null ? GameColors.surfaceRaised : null,
        borderRadius: BorderRadius.circular(GameRadii.button),
        boxShadow: onPressed == null ? null : GameShadows.primaryGlow,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}

class CosmicPanel extends StatelessWidget {
  const CosmicPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GameSpacing.md),
    this.glow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: GameColors.surfaceGlass,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(
          color: glow
              ? GameColors.accent.withValues(alpha: 0.32)
              : GameColors.surfaceStrong,
          width: 0.8,
        ),
        boxShadow: glow ? GameShadows.primaryGlow : GameShadows.card,
      ),
      child: child,
    );
  }
}
