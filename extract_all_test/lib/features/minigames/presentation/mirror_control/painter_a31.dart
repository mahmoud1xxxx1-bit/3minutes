import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA31 extends CustomPainter {
  GamePainterA31({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF3E2723)); // Dark rusted iron
    final rivet = Paint()..color=const Color(0xFF212121);
    final seam = Paint()..color=const Color(0xFF1B1B1B)..style=PaintingStyle.stroke..strokeWidth=4;
    for(double x=0; x<GameEngine.fieldSize; x+=200) {
       for(double y=0; y<GameEngine.fieldSize; y+=200) {
           canvas.drawRect(Rect.fromLTWH(x, y, 200, 200), seam);
           canvas.drawCircle(Offset(x+10, y+10), 4, rivet);
           canvas.drawCircle(Offset(x+190, y+10), 4, rivet);
           canvas.drawCircle(Offset(x+10, y+190), 4, rivet);
           canvas.drawCircle(Offset(x+190, y+190), 4, rivet);
       }
    }
    

    // WEATHER

    for (int i = 0; i < 40; i++) {
      double px = ((i * 45) + math.sin(engine.time + i)*20) % GameEngine.fieldSize;
      double py = GameEngine.fieldSize - ((engine.time * 150 + i * 90) % GameEngine.fieldSize);
      canvas.drawCircle(Offset(px, py), 15 + (i%10).toDouble(), Paint()..color=Colors.white.withOpacity(0.05)); // thick steam
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(10, 15)), Paint()..color=Colors.black54); // shadow
      // Brass Pipe/Boiler
      canvas.drawRect(obs, Paint()..color=const Color(0xFFBCAAA4)); 
      canvas.drawRect(obs, Paint()..shader = ui.Gradient.linear(obs.centerLeft, obs.centerRight, [const Color(0xFFD7CCC8), const Color(0xFF8D6E63), const Color(0xFF5D4037)], [0.0, 0.5, 1.0]));
      // Pipe joints
      canvas.drawRect(Rect.fromLTWH(obs.left-5, obs.top+10, obs.width+10, 15), Paint()..color=const Color(0xFFA1887F));
      canvas.drawRect(Rect.fromLTWH(obs.left-5, obs.bottom-25, obs.width+10, 15), Paint()..color=const Color(0xFFA1887F));
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
          // Glowing Pressure Gauge
          canvas.drawCircle(Offset.zero, 18, Paint()..color=const Color(0xFFFFD700)); // Brass rim
          canvas.drawCircle(Offset.zero, 14, Paint()..color=Colors.white); // Dial face
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFFFF9800).withOpacity(0.6), Colors.transparent]));
          canvas.save(); canvas.rotate(math.sin(engine.time * 20) * 0.5 + math.pi/4); // jittering needle
          canvas.drawLine(Offset.zero, const Offset(0, -10), Paint()..color=Colors.red..strokeWidth=3);
          canvas.drawCircle(Offset.zero, 3, Paint()..color=Colors.black);
          canvas.restore();
      } else {
          // Broken dark gauge
          canvas.drawCircle(Offset.zero, 15, Paint()..color=const Color(0xFF5D4037));
          canvas.drawCircle(Offset.zero, 12, Paint()..color=const Color(0xFF3E2723));
          canvas.drawLine(const Offset(-8, 8), const Offset(8, -8), Paint()..color=Colors.black..strokeWidth=2); // cracked glass
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 45, Paint()..color=const Color(0xFF3E2723));
      canvas.drawCircle(center, 35, Paint()..color=const Color(0xFF000000));
      // Giant exhaust fan
      canvas.save(); canvas.translate(center.dx, center.dy); canvas.rotate(engine.time * 5);
      for(int a=0; a<6; a++) {
         canvas.rotate(math.pi/3);
         Path blade = Path()..moveTo(0,0)..quadraticBezierTo(20, -10, 35, 0)..quadraticBezierTo(20, 10, 0, 0)..close();
         canvas.drawPath(blade, Paint()..color=const Color(0xFF8D6E63));
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
  @override bool shouldRepaint(covariant GamePainterA31 old) => true;
}
