import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'design_tokens.dart';

enum GameGlyphType {
  arena,
  season,
  squad,
  vault,
  identity,
  leaderboard,
  missions,
  history,
  settings,
  rewards,
  battle,
  trophy,
  timer,
  shield,
  more,
}

class GameGlyph extends StatelessWidget {
  const GameGlyph({
    super.key,
    required this.type,
    this.size = 26,
    this.color = GameColors.textSoft,
    this.active = false,
  });

  final GameGlyphType type;
  final double size;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final glyph = CustomPaint(
      size: Size.square(size),
      painter: _GameGlyphPainter(type: type, color: color, active: active),
    );
    if (!active) return glyph;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: .28), blurRadius: 18, spreadRadius: 1),
        ],
      ),
      child: glyph,
    );
  }
}

class _GameGlyphPainter extends CustomPainter {
  const _GameGlyphPainter({required this.type, required this.color, required this.active});

  final GameGlyphType type;
  final Color color;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final stroke = math.max(1.7, s * .075);
    final p = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = color.withValues(alpha: active ? .18 : .08);

    switch (type) {
      case GameGlyphType.arena:
        final path = Path()
          ..moveTo(c.dx, s * .09)
          ..lineTo(s * .82, s * .24)
          ..lineTo(s * .76, s * .66)
          ..lineTo(c.dx, s * .91)
          ..lineTo(s * .24, s * .66)
          ..lineTo(s * .18, s * .24)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, p);
        canvas.drawLine(Offset(s * .36, s * .58), Offset(s * .49, s * .34), p);
        canvas.drawLine(Offset(s * .49, s * .34), Offset(s * .63, s * .58), p);
        canvas.drawLine(Offset(s * .41, s * .49), Offset(s * .58, s * .49), p);
      case GameGlyphType.season:
        final crown = Path()
          ..moveTo(s * .18, s * .66)
          ..lineTo(s * .23, s * .30)
          ..lineTo(s * .42, s * .48)
          ..lineTo(c.dx, s * .20)
          ..lineTo(s * .59, s * .48)
          ..lineTo(s * .78, s * .30)
          ..lineTo(s * .83, s * .66)
          ..close();
        canvas.drawPath(crown, fill);
        canvas.drawPath(crown, p);
        canvas.drawLine(Offset(s * .25, s * .76), Offset(s * .76, s * .76), p);
        canvas.drawCircle(c, s * .055, Paint()..color = color);
      case GameGlyphType.squad:
        canvas.drawCircle(Offset(s * .36, s * .37), s * .13, p);
        canvas.drawCircle(Offset(s * .67, s * .42), s * .10, p);
        final body = Path()
          ..moveTo(s * .14, s * .78)
          ..quadraticBezierTo(s * .36, s * .57, s * .58, s * .78);
        canvas.drawPath(body, p);
        final body2 = Path()
          ..moveTo(s * .52, s * .76)
          ..quadraticBezierTo(s * .69, s * .60, s * .86, s * .76);
        canvas.drawPath(body2, p);
        canvas.drawCircle(Offset(s * .36, s * .37), s * .07, fill);
      case GameGlyphType.vault:
        final crate = RRect.fromRectAndRadius(Rect.fromLTWH(s * .18, s * .22, s * .64, s * .58), Radius.circular(s * .10));
        canvas.drawRRect(crate, fill);
        canvas.drawRRect(crate, p);
        canvas.drawLine(Offset(s * .18, s * .38), Offset(s * .82, s * .38), p);
        final gem = Path()
          ..moveTo(c.dx, s * .43)
          ..lineTo(s * .62, s * .54)
          ..lineTo(c.dx, s * .70)
          ..lineTo(s * .38, s * .54)
          ..close();
        canvas.drawPath(gem, p);
      case GameGlyphType.identity:
        final shield = Path()
          ..moveTo(c.dx, s * .10)
          ..lineTo(s * .78, s * .23)
          ..lineTo(s * .72, s * .64)
          ..quadraticBezierTo(c.dx, s * .88, s * .28, s * .64)
          ..lineTo(s * .22, s * .23)
          ..close();
        canvas.drawPath(shield, fill);
        canvas.drawPath(shield, p);
        canvas.drawCircle(Offset(c.dx, s * .40), s * .09, p);
        final user = Path()
          ..moveTo(s * .36, s * .66)
          ..quadraticBezierTo(c.dx, s * .55, s * .64, s * .66);
        canvas.drawPath(user, p);
      case GameGlyphType.leaderboard:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.17,s*.52,s*.16,s*.28), Radius.circular(3)), p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.42,s*.34,s*.16,s*.46), Radius.circular(3)), p);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.67,s*.44,s*.16,s*.36), Radius.circular(3)), p);
        canvas.drawCircle(Offset(c.dx,s*.20),s*.055,Paint()..color=color);
      case GameGlyphType.missions:
        final card = RRect.fromRectAndRadius(Rect.fromLTWH(s*.22,s*.15,s*.58,s*.70), Radius.circular(s*.09));
        canvas.drawRRect(card, p);
        canvas.drawLine(Offset(s*.34,s*.36),Offset(s*.67,s*.36),p);
        canvas.drawLine(Offset(s*.34,s*.52),Offset(s*.67,s*.52),p);
        canvas.drawLine(Offset(s*.34,s*.68),Offset(s*.57,s*.68),p);
        canvas.drawCircle(Offset(s*.24,s*.24),s*.05,Paint()..color=color);
      case GameGlyphType.history:
        canvas.drawArc(Rect.fromCircle(center:c,radius:s*.32), -.5, 5.3, false, p);
        canvas.drawLine(Offset(s*.21,s*.25),Offset(s*.20,s*.43),p);
        canvas.drawLine(Offset(s*.21,s*.25),Offset(s*.38,s*.28),p);
        canvas.drawLine(c,Offset(c.dx,s*.31),p);
        canvas.drawLine(c,Offset(s*.65,s*.58),p);
      case GameGlyphType.settings:
        canvas.drawCircle(c,s*.14,p);
        for (var i=0;i<8;i++) {
          final a=i*math.pi/4;
          final a1=Offset(c.dx+math.cos(a)*s*.27,c.dy+math.sin(a)*s*.27);
          final a2=Offset(c.dx+math.cos(a)*s*.40,c.dy+math.sin(a)*s*.40);
          canvas.drawLine(a1,a2,p);
        }
      case GameGlyphType.rewards:
        final gem = Path()
          ..moveTo(c.dx,s*.12)..lineTo(s*.78,s*.36)..lineTo(s*.65,s*.78)..lineTo(c.dx,s*.90)..lineTo(s*.35,s*.78)..lineTo(s*.22,s*.36)..close();
        canvas.drawPath(gem, fill); canvas.drawPath(gem,p);
        canvas.drawLine(Offset(s*.22,s*.36),Offset(s*.78,s*.36),p);
        canvas.drawLine(Offset(s*.39,s*.36),Offset(c.dx,s*.78),p);
        canvas.drawLine(Offset(s*.61,s*.36),Offset(c.dx,s*.78),p);
      case GameGlyphType.battle:
        canvas.drawLine(Offset(s*.27,s*.23),Offset(s*.72,s*.78),p);
        canvas.drawLine(Offset(s*.73,s*.23),Offset(s*.28,s*.78),p);
        canvas.drawLine(Offset(s*.20,s*.70),Offset(s*.34,s*.84),p);
        canvas.drawLine(Offset(s*.80,s*.70),Offset(s*.66,s*.84),p);
      case GameGlyphType.trophy:
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.34,s*.18,s*.32,s*.34), Radius.circular(s*.07)), p);
        canvas.drawArc(Rect.fromLTWH(s*.18,s*.22,s*.26,s*.24), math.pi/2, math.pi, false,p);
        canvas.drawArc(Rect.fromLTWH(s*.56,s*.22,s*.26,s*.24), -math.pi/2, math.pi, false,p);
        canvas.drawLine(Offset(c.dx,s*.52),Offset(c.dx,s*.72),p);
        canvas.drawLine(Offset(s*.36,s*.78),Offset(s*.64,s*.78),p);
      case GameGlyphType.timer:
        canvas.drawCircle(c,s*.31,p);
        canvas.drawLine(Offset(c.dx,s*.13),Offset(c.dx,s*.06),p);
        canvas.drawLine(c,Offset(s*.62,s*.37),p);
        canvas.drawLine(c,Offset(c.dx,s*.66),p);
      case GameGlyphType.shield:
        final path = Path()..moveTo(c.dx,s*.10)..lineTo(s*.77,s*.23)..lineTo(s*.71,s*.64)..quadraticBezierTo(c.dx,s*.88,s*.29,s*.64)..lineTo(s*.23,s*.23)..close();
        canvas.drawPath(path,fill); canvas.drawPath(path,p);
        canvas.drawLine(Offset(s*.39,s*.49),Offset(s*.48,s*.59),p);
        canvas.drawLine(Offset(s*.48,s*.59),Offset(s*.65,s*.38),p);
      case GameGlyphType.more:
        for (final x in [.28,.50,.72]) canvas.drawCircle(Offset(s*x,c.dy),s*.055,Paint()..color=color);
    }
  }

  @override
  bool shouldRepaint(covariant _GameGlyphPainter oldDelegate) => oldDelegate.type != type || oldDelegate.color != color || oldDelegate.active != active;
}
