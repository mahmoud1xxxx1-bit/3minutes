import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA43 extends CustomPainter {
  GamePainterA43({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFB71C1C)); // Deep red tissue
    // Pulsating veins
    final vein = Paint()..color=const Color(0xFFD32F2F)..style=PaintingStyle.stroke..strokeWidth=10..strokeCap=StrokeCap.round;
    final rnd = math.Random(43);
    for(int i=0; i<15; i++) {
        Path v = Path()..moveTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        v.quadraticBezierTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        canvas.drawPath(v, vein);
    }
    

    // WEATHER

    for (int i = 0; i < 20; i++) {
      double px = ((i * 85) + engine.time * 40) % GameEngine.fieldSize;
      double py = ((i * 140) + math.sin(engine.time*2 + i)*30) % GameEngine.fieldSize;
      // White blood cells / antibodies floating
      canvas.drawCircle(Offset(px, py), 6, Paint()..color=Colors.white.withValues(alpha: 0.6));
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black45);
      // Giant Red Blood Cell (donut-like shading)
      canvas.drawRect(obs, Paint()..color=const Color(0xFFE53935));
      canvas.drawRect(obs.deflate(6.0), Paint()..color=const Color(0xFFC62828)); // indent
      canvas.drawRect(obs.shift(const Offset(-5, -5)).deflate(10.0), Paint()..color=const Color(0xFFEF5350).withValues(alpha: 0.5)); // highlight
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 15), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.black26);
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Glowing DNA Helix
          canvas.save(); canvas.rotate(engine.time * 3);
          for(double y=-15; y<=15; y+=40) {
              double x = math.sin(y*0.3 + engine.time*5) * 10;
              canvas.drawCircle(Offset(x, y), 3, Paint()..color=const Color(0xFF00E5FF));
              canvas.drawCircle(Offset(-x, y), 3, Paint()..color=const Color(0xFFFF00FF));
              canvas.drawLine(Offset(x, y), Offset(-x, y), Paint()..color=Colors.white.withValues(alpha: 0.5)..strokeWidth=1);
          }
          canvas.restore();
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFF00E5FF).withValues(alpha: 0.4), Colors.transparent]));
      } else {
          // Dead protein
          canvas.drawCircle(Offset.zero, 8, Paint()..color=const Color(0xFF880E4F));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFF4A148C)); // Cell nucleus
      canvas.drawCircle(center, 35, Paint()..color=const Color(0xFF7B1FA2));
      canvas.drawCircle(center, 20, Paint()..color=const Color(0xFFE1BEE7)); // Nucleolus
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 2);
      for(int a=0; a<8; a++) {
         canvas.rotate(math.pi/4);
         canvas.drawCircle(const Offset(25, 0), 4, Paint()..color=const Color(0xFFEA80FC));
      }
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
  @override bool shouldRepaint(covariant GamePainterA43 old) => true;
}
