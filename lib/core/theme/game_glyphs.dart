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
    final p = Paint()
      ..color = color
      ..strokeWidth = math.max(1.7, s * .075)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = color.withValues(alpha: active ? .18 : .08);

    switch (type) {
      case GameGlyphType.arena:
        _arena(canvas, s, c, p, fill);
        break;
      case GameGlyphType.season:
        _season(canvas, s, c, p, fill);
        break;
      case GameGlyphType.squad:
        _squad(canvas, s, p, fill);
        break;
      case GameGlyphType.vault:
        _vault(canvas, s, c, p, fill);
        break;
      case GameGlyphType.identity:
        _identity(canvas, s, c, p, fill);
        break;
      case GameGlyphType.leaderboard:
        _leaderboard(canvas, s, c, p);
        break;
      case GameGlyphType.missions:
        _missions(canvas, s, p);
        break;
      case GameGlyphType.history:
        _history(canvas, s, c, p);
        break;
      case GameGlyphType.settings:
        _settings(canvas, s, c, p);
        break;
      case GameGlyphType.rewards:
        _rewards(canvas, s, c, p, fill);
        break;
      case GameGlyphType.battle:
        _battle(canvas, s, p);
        break;
      case GameGlyphType.trophy:
        _trophy(canvas, s, c, p);
        break;
      case GameGlyphType.timer:
        _timer(canvas, s, c, p);
        break;
      case GameGlyphType.shield:
        _shield(canvas, s, c, p, fill);
        break;
      case GameGlyphType.more:
        for (final x in <double>[.28, .50, .72]) {
          canvas.drawCircle(Offset(s * x, c.dy), s * .055, Paint()..color = color);
        }
        break;
    }
  }

  void _arena(Canvas canvas, double s, Offset c, Paint p, Paint fill) {
    final path = Path()
      ..moveTo(c.dx, s * .08)
      ..lineTo(s * .82, s * .23)
      ..lineTo(s * .76, s * .67)
      ..lineTo(c.dx, s * .92)
      ..lineTo(s * .24, s * .67)
      ..lineTo(s * .18, s * .23)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, p);
    canvas.drawLine(Offset(s * .35, s * .60), Offset(s * .49, s * .33), p);
    canvas.drawLine(Offset(s * .49, s * .33), Offset(s * .64, s * .60), p);
    canvas.drawLine(Offset(s * .41, s * .49), Offset(s * .58, s * .49), p);
  }

  void _season(Canvas canvas, double s, Offset c, Paint p, Paint fill) {
    final crown = Path()
      ..moveTo(s * .18, s * .67)
      ..lineTo(s * .23, s * .29)
      ..lineTo(s * .42, s * .47)
      ..lineTo(c.dx, s * .19)
      ..lineTo(s * .59, s * .47)
      ..lineTo(s * .78, s * .29)
      ..lineTo(s * .83, s * .67)
      ..close();
    canvas.drawPath(crown, fill);
    canvas.drawPath(crown, p);
    canvas.drawLine(Offset(s * .25, s * .77), Offset(s * .76, s * .77), p);
    canvas.drawCircle(c, s * .055, Paint()..color = color);
  }

  void _squad(Canvas canvas, double s, Paint p, Paint fill) {
    canvas.drawCircle(Offset(s * .35, s * .35), s * .13, p);
    canvas.drawCircle(Offset(s * .68, s * .41), s * .10, p);
    canvas.drawCircle(Offset(s * .35, s * .35), s * .07, fill);
    canvas.drawPath(Path()..moveTo(s*.13,s*.79)..quadraticBezierTo(s*.35,s*.56,s*.58,s*.79), p);
    canvas.drawPath(Path()..moveTo(s*.52,s*.77)..quadraticBezierTo(s*.69,s*.60,s*.86,s*.77), p);
  }

  void _vault(Canvas canvas, double s, Offset c, Paint p, Paint fill) {
    final box = RRect.fromRectAndRadius(Rect.fromLTWH(s*.17,s*.22,s*.66,s*.59), Radius.circular(s*.10));
    canvas.drawRRect(box, fill);
    canvas.drawRRect(box, p);
    canvas.drawLine(Offset(s*.17,s*.39), Offset(s*.83,s*.39), p);
    final gem = Path()..moveTo(c.dx,s*.45)..lineTo(s*.62,s*.55)..lineTo(c.dx,s*.70)..lineTo(s*.38,s*.55)..close();
    canvas.drawPath(gem, p);
  }

  void _identity(Canvas canvas, double s, Offset c, Paint p, Paint fill) {
    _shield(canvas, s, c, p, fill);
    canvas.drawCircle(Offset(c.dx,s*.40), s*.085, p);
    canvas.drawPath(Path()..moveTo(s*.36,s*.66)..quadraticBezierTo(c.dx,s*.55,s*.64,s*.66), p);
  }

  void _leaderboard(Canvas canvas, double s, Offset c, Paint p) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.16,s*.54,s*.17,s*.27), const Radius.circular(3)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.415,s*.34,s*.17,s*.47), const Radius.circular(3)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.67,s*.45,s*.17,s*.36), const Radius.circular(3)), p);
    canvas.drawCircle(Offset(c.dx,s*.20), s*.055, Paint()..color=color);
  }

  void _missions(Canvas canvas, double s, Paint p) {
    final card = RRect.fromRectAndRadius(Rect.fromLTWH(s*.22,s*.14,s*.58,s*.72), Radius.circular(s*.09));
    canvas.drawRRect(card,p);
    for (final y in <double>[.35,.52,.69]) {
      canvas.drawLine(Offset(s*.35,s*y), Offset(s*.67,s*y), p);
    }
    canvas.drawCircle(Offset(s*.25,s*.24), s*.045, Paint()..color=color);
  }

  void _history(Canvas canvas, double s, Offset c, Paint p) {
    canvas.drawArc(Rect.fromCircle(center:c,radius:s*.32), -.45, 5.35, false, p);
    canvas.drawLine(Offset(s*.20,s*.25),Offset(s*.20,s*.43),p);
    canvas.drawLine(Offset(s*.20,s*.25),Offset(s*.38,s*.28),p);
    canvas.drawLine(c,Offset(c.dx,s*.31),p);
    canvas.drawLine(c,Offset(s*.65,s*.58),p);
  }

  void _settings(Canvas canvas, double s, Offset c, Paint p) {
    canvas.drawCircle(c,s*.14,p);
    for (var i=0;i<8;i++) {
      final a=i*math.pi/4;
      canvas.drawLine(
        Offset(c.dx+math.cos(a)*s*.27,c.dy+math.sin(a)*s*.27),
        Offset(c.dx+math.cos(a)*s*.40,c.dy+math.sin(a)*s*.40),
        p,
      );
    }
  }

  void _rewards(Canvas canvas, double s, Offset c, Paint p, Paint fill) {
    final gem=Path()..moveTo(c.dx,s*.11)..lineTo(s*.79,s*.36)..lineTo(s*.65,s*.79)..lineTo(c.dx,s*.90)..lineTo(s*.35,s*.79)..lineTo(s*.21,s*.36)..close();
    canvas.drawPath(gem,fill); canvas.drawPath(gem,p);
    canvas.drawLine(Offset(s*.21,s*.36),Offset(s*.79,s*.36),p);
    canvas.drawLine(Offset(s*.39,s*.36),Offset(c.dx,s*.79),p);
    canvas.drawLine(Offset(s*.61,s*.36),Offset(c.dx,s*.79),p);
  }

  void _battle(Canvas canvas, double s, Paint p) {
    canvas.drawLine(Offset(s*.27,s*.22),Offset(s*.73,s*.78),p);
    canvas.drawLine(Offset(s*.73,s*.22),Offset(s*.27,s*.78),p);
    canvas.drawLine(Offset(s*.20,s*.70),Offset(s*.34,s*.84),p);
    canvas.drawLine(Offset(s*.80,s*.70),Offset(s*.66,s*.84),p);
  }

  void _trophy(Canvas canvas, double s, Offset c, Paint p) {
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s*.34,s*.17,s*.32,s*.35), Radius.circular(s*.07)),p);
    canvas.drawArc(Rect.fromLTWH(s*.18,s*.22,s*.26,s*.24), math.pi/2, math.pi, false,p);
    canvas.drawArc(Rect.fromLTWH(s*.56,s*.22,s*.26,s*.24), -math.pi/2, math.pi, false,p);
    canvas.drawLine(Offset(c.dx,s*.52),Offset(c.dx,s*.72),p);
    canvas.drawLine(Offset(s*.36,s*.79),Offset(s*.64,s*.79),p);
  }

  void _timer(Canvas canvas, double s, Offset c, Paint p) {
    canvas.drawCircle(c,s*.31,p);
    canvas.drawLine(Offset(c.dx,s*.13),Offset(c.dx,s*.06),p);
    canvas.drawLine(c,Offset(s*.63,s*.37),p);
    canvas.drawLine(c,Offset(c.dx,s*.66),p);
  }

  void _shield(Canvas canvas, double s, Offset c, Paint p, Paint fill) {
    final path=Path()..moveTo(c.dx,s*.09)..lineTo(s*.78,s*.23)..lineTo(s*.71,s*.64)..quadraticBezierTo(c.dx,s*.89,s*.29,s*.64)..lineTo(s*.22,s*.23)..close();
    canvas.drawPath(path,fill); canvas.drawPath(path,p);
  }

  @override
  bool shouldRepaint(covariant _GameGlyphPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color || oldDelegate.active != active;
}
