import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA40 extends CustomPainter {
  GamePainterA40({required this.engine, this.images});
  final GameEngine engine;
  final Map<String, ui.Image>? images;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameEngine.fieldSize;
    final scaleY = size.height / GameEngine.fieldSize;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    canvas.translate((size.width - (GameEngine.fieldSize * scale)) / 2, (size.height - (GameEngine.fieldSize * scale)) / 2);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));

    // FLOOR

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFECEFF1)); // Marble floor
    final tile = Paint()..color=const Color(0xFFCFD8DC)..style=PaintingStyle.stroke..strokeWidth=2;
    for(double x=0; x<GameEngine.fieldSize; x+=100) {
       for(double y=0; y<GameEngine.fieldSize; y+=100) {
           canvas.drawRect(Rect.fromLTWH(x, y, 100, 100), tile);
           canvas.drawRect(Rect.fromLTWH(x+40, y+40, 20, 20), Paint()..color=const Color(0xFFB0BEC5));
       }
    }
    // Giant Magic Circle over floor
    canvas.save(); canvas.translate(GameEngine.fieldSize/2, GameEngine.fieldSize/2); canvas.rotate(-engine.time * 0.2);
    canvas.drawCircle(Offset.zero, 400, Paint()..color=const Color(0xFF1976D2).withValues(alpha: 0.2)..style=PaintingStyle.stroke..strokeWidth=10);
    canvas.drawCircle(Offset.zero, 380, Paint()..color=const Color(0xFF1976D2).withValues(alpha: 0.2)..style=PaintingStyle.stroke..strokeWidth=2);
    canvas.drawRect(const Rect.fromLTWH(-270, -270, 540, 540), Paint()..color=const Color(0xFF1976D2).withValues(alpha: 0.2)..style=PaintingStyle.stroke..strokeWidth=5);
    canvas.restore();
    

    // WEATHER

    // Floating magic letters/runes
    for (int i = 0; i < 20; i++) {
      double px = ((i * 65) + engine.time * 30) % GameEngine.fieldSize;
      double py = ((i * 110) - engine.time * 50) % GameEngine.fieldSize;
      if (py < 0) py += GameEngine.fieldSize;
      canvas.drawRect(Rect.fromLTWH(px, py, 6, 8), Paint()..color=const Color(0xFF1976D2).withValues(alpha: 0.6));
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=Colors.black26);
      canvas.drawRect(obs, Paint()..color=const Color(0xFF5D4037)); // Wood bookshelf
      canvas.drawRect(obs, Paint()..color=const Color(0xFF4E342E)..style=PaintingStyle.stroke..strokeWidth=3);
      // Floating open book on top
      canvas.save(); canvas.translate(obs.center.dx, obs.center.dy + math.sin(engine.time * 3 + i)*5);
      canvas.drawRect(const Rect.fromLTWH(-20, -12, 40, 24), Paint()..color=const Color(0xFF3E2723)); // cover
      canvas.drawRect(const Rect.fromLTWH(-18, -10, 36, 20), Paint()..color=const Color(0xFFFFF8E1)); // pages
      canvas.drawLine(const Offset(0, -10), const Offset(0, 10), Paint()..color=const Color(0xFF3E2723)..strokeWidth=2); // spine crease
      canvas.restore();
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 15), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.black12);
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Floating lit candle
          canvas.drawRect(const Rect.fromLTWH(-5, -15, 10, 25), Paint()..color=const Color(0xFFFFF9C4)); // wax
          // Flame
          Path flame = Path()..moveTo(0, -25)..quadraticBezierTo(5, -15, 0, -15)..quadraticBezierTo(-5, -15, 0, -25)..close();
          canvas.drawPath(flame, Paint()..color=const Color(0xFFFF9800));
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFF9800).withValues(alpha: 0.4), Colors.transparent]));
      } else {
          // Melted unlit candle
          canvas.drawRect(const Rect.fromLTWH(-5, 0, 10, 10), Paint()..color=const Color(0xFFE0E0E0));
          canvas.drawLine(const Offset(0, 0), const Offset(0, -4), Paint()..color=Colors.black..strokeWidth=2);
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 45, Paint()..color=const Color(0xFF1976D2));
      canvas.drawCircle(center, 35, Paint()..color=const Color(0xFF000000));
      // Magic portal spiral
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 6);
      Path spiral = Path();
      for(double a=0; a<math.pi*4; a+=10.2) {
          double r = a * 3;
          if(a==0) {
            spiral.moveTo(r*math.cos(a), r*math.sin(a));
          } else {
            spiral.lineTo(r*math.cos(a), r*math.sin(a));
          }
      }
      canvas.drawPath(spiral, Paint()..color=const Color(0xFF64B5F6)..style=PaintingStyle.stroke..strokeWidth=3);
      canvas.restore();
    
    }

    // ==========================================
    // 5. UNIFIED CHASER IDENTITY
    // ==========================================
    if (images != null && images!['enemy'] != null) {
      if (engine.chaserInWall) {
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 1.5, Paint()..color = Colors.black87);
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 0.8, Paint()..color = Colors.black);
          final eyeGlow = Paint()..color = Colors.red.withValues(alpha: 0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 3, Paint()..color = Colors.white);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 3, Paint()..color = Colors.white);
      } else {
          canvas.drawCircle(engine.chaserPos + const Offset(0, 15), GameEngine.chaserRadius, Paint()..color=Colors.black.withValues(alpha: 0.35));
          if(engine.chaserStunTimer <= GameEngine.recoveryDuration) {
             double pulse = 1.0 + math.sin(engine.time * 20) * 0.1;
             canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 2.5 * pulse, Paint()..color = Colors.redAccent.withValues(alpha: 0.3));
          }
          canvas.save(); canvas.translate(engine.chaserPos.dx, engine.chaserPos.dy);
          if (engine.chaserVelocity.dx > 0) canvas.scale(-1, 1);
          canvas.translate(0, math.sin(engine.time * 6) * 4); 
          
          Paint chaserPaint = (engine.chaserStunTimer > GameEngine.recoveryDuration) 
              ? (Paint()..color=Colors.grey.withValues(alpha: 0.5)) 
              : Paint();
              
          canvas.drawImageRect(images!['enemy']!, 
              Rect.fromLTWH(0,0, images!['enemy']!.width.toDouble(), images!['enemy']!.height.toDouble()), 
              Rect.fromCenter(center: Offset.zero, width: GameEngine.chaserRadius*2.5, height: GameEngine.chaserRadius*2.5), 
              chaserPaint);
          canvas.restore();
      }
    }

    // ==========================================
    // 6. UNIFIED PLAYER IDENTITY
    // ==========================================
    if (images != null && images!['player'] != null) {
      canvas.drawCircle(engine.playerPos + const Offset(0, 15), GameEngine.playerRadius, Paint()..color=Colors.black.withValues(alpha: 0.35));
      
      double vLen = engine.playerVelocity.distance;
      if (vLen > 0) {
        canvas.save(); canvas.translate(engine.playerPos.dx, engine.playerPos.dy);
        canvas.rotate(math.atan2(engine.playerVelocity.dy, engine.playerVelocity.dx));
        canvas.drawOval(Rect.fromCenter(center: const Offset(-20, 0), width: 40, height: 10), Paint()..color=Colors.white.withValues(alpha: 0.5));
        canvas.restore();
      }
      
      canvas.save(); canvas.translate(engine.playerPos.dx, engine.playerPos.dy);
      if (engine.playerVelocity.dx > 0) canvas.scale(-1, 1);
      if (vLen > 0) canvas.translate(0, math.sin(engine.time * 20) * 3);
      
      canvas.drawImageRect(images!['player']!, 
          Rect.fromLTWH(0, 0, images!['player']!.width.toDouble(), images!['player']!.height.toDouble()), 
          Rect.fromCenter(center: Offset.zero, width: GameEngine.playerRadius*2.8, height: GameEngine.playerRadius*2.8), 
          Paint());
      canvas.restore();
    }

  }
  @override bool shouldRepaint(covariant GamePainterA40 old) => true;
}
