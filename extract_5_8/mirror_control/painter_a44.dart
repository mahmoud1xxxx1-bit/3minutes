import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA44 extends CustomPainter {
  GamePainterA44({required this.engine, this.images});
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

    // Black and white checkered marble
    for(double x=0; x<GameEngine.fieldSize; x+=100) {
       for(double y=0; y<GameEngine.fieldSize; y+=100) {
           bool isBlack = ((x/100).floor() + (y/100).floor()) % 2 == 0;
           canvas.drawRect(Rect.fromLTWH(x, y, 100, 100), Paint()..color=isBlack ? const Color(0xFF212121) : const Color(0xFFF5F5F5));
       }
    }
    // Stained glass light projection over the floor
    canvas.drawRect(const Rect.fromLTWH(200, 200, 600, 600), Paint()..shader = ui.Gradient.sweep(const Offset(500, 500), [Colors.red.withOpacity(0.2), Colors.blue.withOpacity(0.2), Colors.green.withOpacity(0.2), Colors.yellow.withOpacity(0.2), Colors.red.withOpacity(0.2)], [0.0, 0.25, 0.5, 0.75, 1.0]));
    

    // WEATHER

    for (int i = 0; i < 15; i++) {
      double px = ((i * 95) + engine.time * 20) % GameEngine.fieldSize;
      double py = ((i * 130) + engine.time * -30) % GameEngine.fieldSize;
      if(py < 0) py += GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), 2, Paint()..color=Colors.white.withOpacity(0.3)); // holy motes
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(10, 20)), Paint()..color=Colors.black54);
      // Stone pillar base
      canvas.drawRect(obs, Paint()..color=const Color(0xFF757575));
      canvas.drawRect(obs, Paint()..color=const Color(0xFF424242)..style=PaintingStyle.stroke..strokeWidth=4);
      // Gothic arches carved in stone
      canvas.drawPath(Path()..moveTo(obs.left+10, obs.bottom)..lineTo(obs.left+10, obs.top+20)..quadraticBezierTo(obs.center.dx, obs.top, obs.right-10, obs.top+20)..lineTo(obs.right-10, obs.bottom), Paint()..color=const Color(0xFF424242)..style=PaintingStyle.stroke..strokeWidth=3);
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
          // Glowing Holy Chalice
          canvas.drawPath(Path()..moveTo(-10, -15)..lineTo(10, -15)..lineTo(5, 5)..lineTo(-5, 5)..close(), Paint()..color=const Color(0xFFFFD700));
          canvas.drawLine(const Offset(0, 5), const Offset(0, 15), Paint()..color=const Color(0xFFFFD700)..strokeWidth=4);
          canvas.drawLine(const Offset(-10, 15), const Offset(10, 15), Paint()..color=const Color(0xFFFFD700)..strokeWidth=4);
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFFD700).withOpacity(0.5), Colors.transparent]));
          // Light beam from above
          canvas.drawRect(const Rect.fromLTWH(-10, -100, 20, 100), Paint()..shader=ui.Gradient.linear(const Offset(0, -100), const Offset(0, 0), [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.4)]));
      } else {
          // Empty stone bowl
          canvas.drawRect(const Rect.fromLTWH(-8, -5, 16, 10), Paint()..color=const Color(0xFF616161));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 45, Paint()..color=const Color(0xFF424242));
      canvas.drawCircle(center, 40, Paint()..color=const Color(0xFF000000));
      // Rose window mandala
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 0.5);
      for(int a=0; a<8; a++) {
          canvas.rotate(math.pi/4);
          Path petal = Path()..moveTo(0,0)..quadraticBezierTo(15, -20, 0, -35)..quadraticBezierTo(-15, -20, 0, 0);
          canvas.drawPath(petal, Paint()..color=[Colors.red, Colors.blue][a%2].withOpacity(0.8));
          canvas.drawPath(petal, Paint()..color=const Color(0xFF424242)..style=PaintingStyle.stroke..strokeWidth=2);
      }
      canvas.drawCircle(Offset.zero, 10, Paint()..color=Colors.yellow);
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
  @override bool shouldRepaint(covariant GamePainterA44 old) => true;
}
