import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/rank_tier.dart';

class RankEmblem extends StatelessWidget {
  const RankEmblem({
    super.key,
    required this.tier,
    this.size = 44,
  });

  final RankTier tier;
  final double size;

  Color get color => switch (tier) {
        RankTier.bronze => GameColors.rankBronze,
        RankTier.silver => GameColors.rankSilver,
        RankTier.gold => GameColors.rankGold,
        RankTier.platinum => GameColors.rankPlatinum,
        RankTier.diamond => GameColors.rankDiamond,
        RankTier.master => GameColors.rankMaster,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RankEmblemPainter(
          tier: tier,
          color: color,
        ),
      ),
    );
  }
}

class _RankEmblemPainter extends CustomPainter {
  const _RankEmblemPainter({
    required this.tier,
    required this.color,
  });

  final RankTier tier;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.16);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.92);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.4, size.width * 0.055)
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final dark = Paint()
      ..style = PaintingStyle.fill
      ..color = GameColors.background;

    canvas.drawCircle(center, size.width * 0.49, outer);

    switch (tier) {
      case RankTier.bronze:
        final shield = _polygon(center, size.width * 0.34, 5, -math.pi / 2);
        canvas.drawPath(shield, fill);
        canvas.drawPath(shield, stroke);
        canvas.drawCircle(center, size.width * 0.10, dark);
      case RankTier.silver:
        final shield = _polygon(center, size.width * 0.35, 6, math.pi / 6);
        canvas.drawPath(shield, fill);
        canvas.drawPath(shield, stroke);
        canvas.drawCircle(center, size.width * 0.12, dark);
      case RankTier.gold:
        final crown = Path()
          ..moveTo(size.width * 0.20, size.height * 0.62)
          ..lineTo(size.width * 0.25, size.height * 0.31)
          ..lineTo(size.width * 0.42, size.height * 0.48)
          ..lineTo(size.width * 0.50, size.height * 0.23)
          ..lineTo(size.width * 0.58, size.height * 0.48)
          ..lineTo(size.width * 0.75, size.height * 0.31)
          ..lineTo(size.width * 0.80, size.height * 0.62)
          ..close();
        canvas.drawPath(crown, fill);
        canvas.drawPath(crown, stroke);
      case RankTier.platinum:
        final hex = _polygon(center, size.width * 0.34, 6, 0);
        canvas.drawPath(hex, fill);
        canvas.drawPath(hex, stroke);
        final inner = _polygon(center, size.width * 0.18, 6, math.pi / 6);
        canvas.drawPath(inner, dark);
      case RankTier.diamond:
        final diamond = Path()
          ..moveTo(size.width * 0.50, size.height * 0.14)
          ..lineTo(size.width * 0.82, size.height * 0.46)
          ..lineTo(size.width * 0.50, size.height * 0.86)
          ..lineTo(size.width * 0.18, size.height * 0.46)
          ..close();
        canvas.drawPath(diamond, fill);
        canvas.drawPath(diamond, stroke);
        canvas.drawLine(
          Offset(size.width * 0.18, size.height * 0.46),
          Offset(size.width * 0.82, size.height * 0.46),
          stroke,
        );
        canvas.drawLine(
          Offset(size.width * 0.50, size.height * 0.14),
          Offset(size.width * 0.50, size.height * 0.86),
          stroke,
        );
      case RankTier.master:
        final star = _star(center, size.width * 0.36, size.width * 0.16, 5);
        canvas.drawPath(star, fill);
        canvas.drawPath(star, stroke);
        canvas.drawCircle(center, size.width * 0.09, dark);
    }
  }

  Path _polygon(Offset center, double radius, int sides, double rotation) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = rotation + (math.pi * 2 * i / sides);
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Path _star(
    Offset center,
    double outerRadius,
    double innerRadius,
    int points,
  ) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + math.pi * i / points;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _RankEmblemPainter oldDelegate) {
    return oldDelegate.tier != tier || oldDelegate.color != color;
  }
}
