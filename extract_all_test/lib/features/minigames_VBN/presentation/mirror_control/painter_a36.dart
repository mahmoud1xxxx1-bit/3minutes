import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA36 extends CustomPainter {
  GamePainterA36({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFFFF9C4)); // White sand
    // Water Caustics (Animated overlapping light blue paths)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF81D4FA).withOpacity(0.6));
    final caustic = Paint()..color=Colors.white.withOpacity(0.3)..style=PaintingStyle.stroke..strokeWidth=3;
    for(double i=0; i<GameEngine.fieldSize; i+=80) {
        Path wave = Path();
        for(double j=0; j<=GameEngine.fieldSize; j+=40) {
            double jitter = math.sin(engine.time * 2 + i + j) * 15;
            if(j==0) wave.moveTo(i + jitter, j);
            else wave.quadraticBezierTo(i - jitter, j - 20, i + jitter, j);
        }
        canvas.drawPath(wave, caustic);
    }
    

    // WEATHER

    for (int i = 0; i < 15; i++) {
      double px = ((i * 100) + math.sin(engine.time*0.5 + i)*30) % GameEngine.fieldSize;
      double py = ((i * 120) + engine.time * -15) % GameEngine.fieldSize;
      if (py < 0) py += GameEngine.fieldSize;
      // Floating leaf on water
      canvas.save(); canvas.translate(px, py); canvas.rotate(engine.time*0.5 + i);
      canvas.drawOval(const Rect.fromLTWH(-8, -4, 16, 8), Paint()..color=const Color(0xFF4CAF50));
      canvas.restore();
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(5, 10)), Paint()..color=const Color(0xFF0277BD).withOpacity(0.4)); // underwater shadow
      // Coral Reef Block
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(15)), Paint()..color=const Color(0xFFFF8A65));
      // Coral pores
      for(double x = obs.left+10; x < obs.right; x+=60) {
          for(double y = obs.top+10; y < obs.bottom; y+=60) {
              canvas.drawCircle(Offset(x, y), 5, Paint()..color=const Color(0xFFD84315));
          }
      }
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
          // Open clam with glowing pearl
          canvas.drawArc(const Rect.fromLTWH(-15, -10, 30, 20), 0, math.pi, true, Paint()..color=const Color(0xFFE1BEE7)); // bottom shell
          canvas.drawCircle(const Offset(0, -5), 10, Paint()..color=Colors.white); // Pearl
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFFFFFF).withOpacity(0.8), Colors.transparent]));
          canvas.drawArc(const Rect.fromLTWH(-15, -20, 30, 20), math.pi, math.pi, true, Paint()..color=const Color(0xFFCE93D8)); // top shell open
      } else {
          // Closed clam
          canvas.drawOval(const Rect.fromLTWH(-12, -8, 24, 16), Paint()..color=const Color(0xFFCE93D8));
          canvas.drawLine(const Offset(-10, 0), const Offset(10, 0), Paint()..color=const Color(0xFF8E24AA)..strokeWidth=2);
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFF000000));
      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFFFFF9C4)..style=PaintingStyle.stroke..strokeWidth=4);
      // Whirlpool
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(-engine.time * 4);
      for(int a=0; a<4; a++) {
          canvas.rotate(math.pi/2);
          Path swirl = Path()..moveTo(0,0)..quadraticBezierTo(20, 0, 30, 30);
          canvas.drawPath(swirl, Paint()..color=const Color(0xFF81D4FA)..style=PaintingStyle.stroke..strokeWidth=3);
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
  @override bool shouldRepaint(covariant GamePainterA36 old) => true;
}
