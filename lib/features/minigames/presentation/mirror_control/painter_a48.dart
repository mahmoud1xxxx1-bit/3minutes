import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA48 extends CustomPainter {
  GamePainterA48({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF263238)); // Dark cave ground
    // Piles of gold coins everywhere
    final rnd = math.Random(48);
    for(int i=0; i<300; i++) {
        double px = rnd.nextDouble()*GameEngine.fieldSize;
        double py = rnd.nextDouble()*GameEngine.fieldSize;
        canvas.drawCircle(Offset(px, py), 6, Paint()..color=const Color(0xFFFFD700));
        canvas.drawCircle(Offset(px, py), 6, Paint()..color=const Color(0xFFF57F17)..style=PaintingStyle.stroke..strokeWidth=1);
    }
    

    // WEATHER

    // Dripping cave water and glittering jewels
    for (int i = 0; i < 20; i++) {
      double px = ((i * 85) + math.sin(engine.time + i)*10) % GameEngine.fieldSize;
      double py = ((i * 130) + engine.time * 80) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 3, Paint()..color=Colors.lightBlueAccent.withValues(alpha: 0.6));
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black87);
      // Treasure Chest
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(5)), Paint()..color=const Color(0xFF5D4037));
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.top+10, obs.width, 5), Paint()..color=const Color(0xFF212121)); // iron bands
      canvas.drawRect(Rect.fromLTWH(obs.left, obs.bottom-15, obs.width, 5), Paint()..color=const Color(0xFF212121));
      canvas.drawCircle(obs.center, 6, Paint()..color=const Color(0xFFFFD700)); // gold lock
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 15), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.black54);
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // Cursed Aztec Gold Medallion
          canvas.drawCircle(Offset.zero, 16, Paint()..color=const Color(0xFFFFD700));
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFFF57F17)..style=PaintingStyle.stroke..strokeWidth=3);
          canvas.drawCircle(Offset.zero, 5, Paint()..color=Colors.red); // cursed center
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [Colors.red.withValues(alpha: 0.5), Colors.transparent]));
      } else {
          // Regular dull coin
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFF8D6E63));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawRect(Rect.fromCenter(center: center, width: 80, height: 80), Paint()..color=const Color(0xFF212121)); // Open vault door
      canvas.drawCircle(center, 30, Paint()..color=const Color(0xFF000000));
      // Ship steering wheel shape inside vault
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 2);
      for(int a=0; a<6; a++) {
         canvas.rotate(math.pi/3);
         canvas.drawLine(const Offset(0, 0), const Offset(40, 0), Paint()..color=const Color(0xFF5D4037)..strokeWidth=6);
      }
      canvas.drawCircle(Offset.zero, 15, Paint()..color=const Color(0xFF5D4037));
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
  @override bool shouldRepaint(covariant GamePainterA48 old) => true;
}
