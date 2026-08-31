import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA33 extends CustomPainter {
  GamePainterA33({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF0D1117));
    // City grid far below
    final dimNeon = Paint()..color=const Color(0xFF00FFFF).withOpacity(0.1)..strokeWidth=1;
    for(double i=0; i<GameEngine.fieldSize; i+=40) {
       canvas.drawLine(Offset(i, 0), Offset(i, GameEngine.fieldSize), dimNeon);
       canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i), dimNeon);
    }
    // Rooftop surface
    canvas.drawRect(const Rect.fromLTWH(50, 50, GameEngine.fieldSize-100, GameEngine.fieldSize-100), Paint()..color=const Color(0xFF1A202C));
    canvas.drawRect(const Rect.fromLTWH(50, 50, GameEngine.fieldSize-100, GameEngine.fieldSize-100), Paint()..color=const Color(0xFFFF007F)..style=PaintingStyle.stroke..strokeWidth=3);
    

    // WEATHER

    for (int i = 0; i < 50; i++) {
      double px = ((i * 35) + engine.time * 20) % GameEngine.fieldSize;
      double py = ((i * 90) + engine.time * 400) % GameEngine.fieldSize;
      canvas.drawLine(Offset(px, py), Offset(px-3, py+15), Paint()..color=const Color(0xFF00FFFF).withOpacity(0.6)..strokeWidth=2); // Cyber rain
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      // AC Unit / Server box
      canvas.drawRect(obs.shift(const Offset(0, 25)), Paint()..color=Colors.black87); // deep shadow
      canvas.drawRect(obs, Paint()..color=const Color(0xFF2D3748));
      canvas.drawRect(obs, Paint()..color=const Color(0xFF4A5568)..style=PaintingStyle.stroke..strokeWidth=2);
      // Spinning AC fan
      if (obs.width >= 40 && obs.height >= 40) {
          canvas.drawCircle(obs.center, 15, Paint()..color=const Color(0xFF1A202C));
          canvas.save(); canvas.translate(obs.center.dx, obs.center.dy); canvas.rotate(engine.time * 10);
          canvas.drawLine(const Offset(-15, 0), const Offset(15, 0), Paint()..color=const Color(0xFFA0AEC0)..strokeWidth=4);
          canvas.drawLine(const Offset(0, -15), const Offset(0, 15), Paint()..color=const Color(0xFFA0AEC0)..strokeWidth=4);
          canvas.restore();
      }
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Neon Kanji hologram
          double flicker = (math.sin(engine.time * 30) > 0.8) ? 0.3 : 1.0;
          canvas.drawRect(const Rect.fromLTWH(-15, -15, 30, 30), Paint()..color=const Color(0xFFFF007F).withOpacity(0.2 * flicker));
          canvas.drawLine(const Offset(-10, -5), const Offset(10, -5), Paint()..color=const Color(0xFFFF007F).withOpacity(flicker)..strokeWidth=3);
          canvas.drawLine(const Offset(0, -10), const Offset(0, 10), Paint()..color=const Color(0xFFFF007F).withOpacity(flicker)..strokeWidth=3);
          canvas.drawLine(const Offset(-8, 8), const Offset(8, 8), Paint()..color=const Color(0xFFFF007F).withOpacity(flicker)..strokeWidth=3);
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFF007F).withOpacity(0.4 * flicker), Colors.transparent]));
      } else {
          // Offline node
          canvas.drawRect(const Rect.fromLTWH(-10, -10, 20, 20), Paint()..color=const Color(0xFF2D3748));
          canvas.drawCircle(Offset.zero, 3, Paint()..color=Colors.red.withOpacity(0.5));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFF1A202C));
      canvas.drawCircle(center, 35, Paint()..color=const Color(0xFF00FFFF)..style=PaintingStyle.stroke..strokeWidth=6);
      canvas.drawCircle(center, 35, Paint()..shader = ui.Gradient.radial(center, 45, [const Color(0xFF00FFFF).withOpacity(0.4), Colors.transparent]));
    
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
  @override bool shouldRepaint(covariant GamePainterA33 old) => true;
}
