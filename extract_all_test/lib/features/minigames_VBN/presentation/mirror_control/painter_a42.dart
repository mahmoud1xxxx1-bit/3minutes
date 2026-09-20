import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA42 extends CustomPainter {
  GamePainterA42({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF5D4037)); // Wood floor
    final plank = Paint()..color=const Color(0xFF3E2723)..style=PaintingStyle.stroke..strokeWidth=3;
    for(double x=0; x<GameEngine.fieldSize; x+=60) canvas.drawLine(Offset(x, 0), Offset(x, GameEngine.fieldSize), plank);
    // Huge fur rug in center
    canvas.drawOval(Rect.fromCenter(center: const Offset(GameEngine.fieldSize/2, GameEngine.fieldSize/2), width: 600, height: 400), Paint()..color=const Color(0xFF8D6E63));
    canvas.drawOval(Rect.fromCenter(center: const Offset(GameEngine.fieldSize/2, GameEngine.fieldSize/2), width: 580, height: 380), Paint()..color=const Color(0xFF795548)..style=PaintingStyle.stroke..strokeWidth=5);
    

    // WEATHER

    // Embers from the firepit
    for (int i = 0; i < 30; i++) {
      double px = ((i * 55) + math.sin(engine.time + i)*30) % GameEngine.fieldSize;
      double py = GameEngine.fieldSize - ((engine.time * 80 + i * 110) % GameEngine.fieldSize);
      canvas.drawCircle(Offset(px, py), 2, Paint()..color=const Color(0xFFFF9800)); 
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54);
      // Wooden Pillar
      canvas.drawRect(obs, Paint()..color=const Color(0xFF4E342E));
      canvas.drawRect(obs, Paint()..color=const Color(0xFF3E2723)..style=PaintingStyle.stroke..strokeWidth=4);
      // Viking Shield attached
      canvas.drawCircle(obs.center + const Offset(0, 15), 15, Paint()..color=const Color(0xFF1565C0)); // Blue shield
      canvas.drawCircle(obs.center + const Offset(0, 15), 15, Paint()..color=const Color(0xFFBCAAA4)..style=PaintingStyle.stroke..strokeWidth=2); // iron rim
      canvas.drawCircle(obs.center + const Offset(0, 15), 4, Paint()..color=const Color(0xFFBCAAA4)); // iron boss
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
          // Glowing Rune (Fehu)
          canvas.drawRect(const Rect.fromLTWH(-15, -20, 30, 40), Paint()..color=const Color(0xFF4E342E)); // stone tablet
          canvas.drawLine(const Offset(-5, -10), const Offset(-5, 10), Paint()..color=const Color(0xFFFFD54F)..strokeWidth=3);
          canvas.drawLine(const Offset(-5, -5), const Offset(5, -12), Paint()..color=const Color(0xFFFFD54F)..strokeWidth=3);
          canvas.drawLine(const Offset(-5, 2), const Offset(5, -5), Paint()..color=const Color(0xFFFFD54F)..strokeWidth=3);
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFFD54F).withOpacity(0.4), Colors.transparent]));
      } else {
          // Empty stone
          canvas.drawRect(const Rect.fromLTWH(-12, -15, 24, 30), Paint()..color=const Color(0xFF5D4037));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFF212121)); // Iron firepit
      canvas.drawCircle(center, 35, Paint()..color=const Color(0xFFFF3D00)); // Fire
      canvas.drawCircle(center, 25, Paint()..color=const Color(0xFFFFD54F)); // Core
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 5);
      Path flame = Path()..moveTo(0,-30)..quadraticBezierTo(20, -10, 0, 10)..quadraticBezierTo(-20, -10, 0, -30)..close();
      canvas.drawPath(flame, Paint()..color=const Color(0xFFFFF59D));
      canvas.restore();
    
    }

    // ==========================================
    // 5. UNIFIED CHASER IDENTITY
    // ==========================================
    if (images != null && images!['enemy'] != null) {
      if (engine.chaserInWall) {
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 1.5, Paint()..color = Colors.black87);
          canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 0.8, Paint()..color = Colors.black);
          final eyeGlow = Paint()..color = Colors.red.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 8, eyeGlow);
          canvas.drawCircle(engine.chaserPos + const Offset(-6, -4), 3, Paint()..color = Colors.white);
          canvas.drawCircle(engine.chaserPos + const Offset(6, -4), 3, Paint()..color = Colors.white);
      } else {
          canvas.drawCircle(engine.chaserPos + const Offset(0, 15), GameEngine.chaserRadius, Paint()..color=Colors.black.withOpacity(0.35));
          if(engine.chaserStunTimer <= GameEngine.recoveryDuration) {
             double pulse = 1.0 + math.sin(engine.time * 20) * 0.1;
             canvas.drawCircle(engine.chaserPos, GameEngine.chaserRadius * 2.5 * pulse, Paint()..color = Colors.redAccent.withOpacity(0.3));
          }
          canvas.save(); canvas.translate(engine.chaserPos.dx, engine.chaserPos.dy);
          if (engine.chaserVelocity.dx > 0) canvas.scale(-1, 1);
          canvas.translate(0, math.sin(engine.time * 6) * 4); 
          
          Paint chaserPaint = (engine.chaserStunTimer > GameEngine.recoveryDuration) 
              ? (Paint()..color=Colors.grey.withOpacity(0.5)) 
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
      canvas.drawCircle(engine.playerPos + const Offset(0, 15), GameEngine.playerRadius, Paint()..color=Colors.black.withOpacity(0.35));
      
      double vLen = engine.playerVelocity.distance;
      if (vLen > 0) {
        canvas.save(); canvas.translate(engine.playerPos.dx, engine.playerPos.dy);
        canvas.rotate(math.atan2(engine.playerVelocity.dy, engine.playerVelocity.dx));
        canvas.drawOval(Rect.fromCenter(center: const Offset(-20, 0), width: 40, height: 10), Paint()..color=Colors.white.withOpacity(0.5));
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
  @override bool shouldRepaint(covariant GamePainterA42 old) => true;
}
