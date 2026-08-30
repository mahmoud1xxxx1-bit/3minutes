import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Premium competitive visual primitives shared by Home, matchmaking,
/// pre-match, results and progression. Keeping the surfaces here prevents the
/// five core flows from drifting into unrelated styles.
class ArenaCard extends StatelessWidget {
  const ArenaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GameSpacing.md),
    this.accent,
    this.glow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final bool glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final edge = accent ?? GameColors.surfaceStrong;
    final body = AnimatedContainer(
      duration: GameDurations.normal,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xEE111E3E), Color(0xEE09142C)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: edge.withValues(alpha: accent == null ? .75 : .42)),
        boxShadow: glow
            ? [
                BoxShadow(color: edge.withValues(alpha: .15), blurRadius: 28, spreadRadius: 1),
                const BoxShadow(color: Color(0x44000000), blurRadius: 22, offset: Offset(0, 12)),
              ]
            : const [BoxShadow(color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class ArenaSectionTitle extends StatelessWidget {
  const ArenaSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: GameColors.accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: GameColors.accentBright),
          ),
          const SizedBox(width: GameSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: .2,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: GameColors.muted,
                        height: 1.35,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: GameSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

class ArenaMetric extends StatelessWidget {
  const ArenaMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = GameColors.accentBright,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: GameColors.surfaceRaised.withValues(alpha: .58),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withValues(alpha: .16)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: GameColors.muted, fontSize: 9, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class ArenaProgress extends StatelessWidget {
  const ArenaProgress({
    super.key,
    required this.value,
    this.color = GameColors.accentBright,
    this.height = 8,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GameRadii.pill),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCubic,
        builder: (context, animated, _) => LinearProgressIndicator(
          value: animated,
          minHeight: height,
          backgroundColor: GameColors.surfaceRaised,
          color: color,
        ),
      ),
    );
  }
}

class ArenaPill extends StatelessWidget {
  const ArenaPill({
    super.key,
    required this.label,
    this.icon,
    this.color = GameColors.accentBright,
    this.solid = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: solid ? color.withValues(alpha: .18) : GameColors.surfaceRaised.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: .24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class ArenaPlayButton extends StatelessWidget {
  const ArenaPlayButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.icon = Icons.bolt_rounded,
    this.primary = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: GameSpacing.md, vertical: 17),
          decoration: BoxDecoration(
            gradient: primary && enabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF20E4EA), Color(0xFF5F72F6), Color(0xFF8E4DDE)],
                  )
                : const LinearGradient(colors: [Color(0xFF101E3D), Color(0xFF0C1730)]),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: primary && enabled
                  ? Colors.white.withValues(alpha: .16)
                  : GameColors.surfaceStrong,
            ),
            boxShadow: primary && enabled
                ? const [
                    BoxShadow(color: Color(0x4419DCE8), blurRadius: 26, offset: Offset(0, 10)),
                    BoxShadow(color: Color(0x267957F5), blurRadius: 36),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary && enabled ? Colors.white.withValues(alpha: .15) : GameColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: enabled ? (primary ? Colors.white : GameColors.accentBright) : GameColors.muted,
                ),
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled ? GameColors.textStrong : GameColors.muted,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: enabled ? GameColors.textSoft : GameColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: enabled ? GameColors.textStrong : GameColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class ArenaRadar extends StatefulWidget {
  const ArenaRadar({super.key, this.size = 230});
  final double size;

  @override
  State<ArenaRadar> createState() => _ArenaRadarState();
}

class _ArenaRadarState extends State<ArenaRadar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          painter: _RadarPainter(progress: reduceMotion ? .25 : _controller.value),
          child: child,
        ),
        child: Center(
          child: Container(
            width: widget.size * .42,
            height: widget.size * .42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFF163C5A), Color(0xFF09162D)]),
              border: Border.all(color: GameColors.accentBright.withValues(alpha: .44)),
              boxShadow: GameShadows.primaryGlow,
            ),
            child: const Icon(Icons.radar_rounded, size: 40, color: GameColors.accentBright),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = GameColors.surfaceStrong.withValues(alpha: .8);
    for (final factor in [.38, .62, .88]) {
      canvas.drawCircle(center, radius * factor, ring);
    }
    final angle = (progress * math.pi * 2) - math.pi / 2;
    final sweep = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Colors.transparent, GameColors.accentBright, Colors.transparent],
        stops: [0.0, .14, .28],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawCircle(center, radius * .88, sweep);
    canvas.restore();

    final dot = Paint()..color = GameColors.violet;
    final p = Offset(center.dx + math.cos(angle) * radius * .67, center.dy + math.sin(angle) * radius * .67);
    canvas.drawCircle(p, 4, dot);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.progress != progress;
}
