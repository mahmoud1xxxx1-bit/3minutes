import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA32 extends CustomPainter {
  GamePainterA32({required this.engine, this.images});
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

    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF1B2A15)); // Dark night grass
    final grass = Paint()..color=const Color(0xFF2C4023)..strokeWidth=2;
    final rnd = math.Random(32);
    for(int i=0; i<300; i++) {
        double gx = rnd.nextDouble()*GameEngine.fieldSize;
        double gy = rnd.nextDouble()*GameEngine.fieldSize;
        canvas.drawLine(Offset(gx, gy), Offset(gx - 5, gy - 15), grass);
    }
    

    // WEATHER

    for (int i = 0; i < 40; i++) {
      double px = ((i * 65) + math.sin(engine.time*0.5 + i)*50) % GameEngine.fieldSize;
      double py = ((i * 80) + math.cos(engine.time*0.3 + i)*50) % GameEngine.fieldSize;
      // Fireflies
      canvas.drawCircle(Offset(px, py), 2, Paint()..color=const Color(0xFF00E5FF));
      canvas.drawCircle(Offset(px, py), 8, Paint()..shader=ui.Gradient.radial(Offset(px, py), 8, [const Color(0xFF00E5FF).withOpacity(0.5), Colors.transparent]));
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=Colors.black54);
      // Tall bamboo stalk (cylinder shading)
      canvas.drawRect(obs, Paint()..shader=ui.Gradient.linear(obs.centerLeft, obs.centerRight, [const Color(0xFF2E7D32), const Color(0xFF81C784), const Color(0xFF1B5E20)], [0.0, 0.5, 1.0]));
      // Bamboo joints
      for(double y = obs.top + 20; y < obs.bottom; y+=40) {
          canvas.drawLine(Offset(obs.left, y), Offset(obs.right, y), Paint()..color=const Color(0xFF1B5E20)..strokeWidth=4);
          canvas.drawLine(Offset(obs.left, y-2), Offset(obs.right, y-2), Paint()..color=const Color(0xFFAED581)..strokeWidth=2);
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
          // Glowing Spirit (Hitodama)
          Path spirit = Path()..moveTo(0, -15)..quadraticBezierTo(15, -15, 10, 5)..quadraticBezierTo(5, 25, 0, 15)..quadraticBezierTo(-5, 25, -10, 5)..quadraticBezierTo(-15, -15, 0, -15)..close();
          canvas.drawPath(spirit, Paint()..color=const Color(0xFF00E5FF));
          canvas.drawCircle(Offset.zero, tr*2, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*2, [const Color(0xFF00E5FF).withOpacity(0.6), Colors.transparent]));
      } else {
          // Stone lantern unlit
          canvas.drawRect(const Rect.fromLTWH(-8, -10, 16, 20), Paint()..color=const Color(0xFF546E7A));
          canvas.drawPath(Path()..moveTo(-15, -10)..lineTo(15, -10)..lineTo(0, -25)..close(), Paint()..color=const Color(0xFF37474F));
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawRect(Rect.fromCenter(center: center, width: 90, height: 90), Paint()..color=const Color(0xFF1B2A15));
      // Torii Gate viewed from top
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, -20), width: 80, height: 12), Paint()..color=const Color(0xFFB71C1C));
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, 20), width: 80, height: 12), Paint()..color=const Color(0xFFB71C1C));
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(-25, 0), width: 12, height: 70), Paint()..color=const Color(0xFF880E4F));
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(25, 0), width: 12, height: 70), Paint()..color=const Color(0xFF880E4F));
    
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
  @override bool shouldRepaint(covariant GamePainterA32 old) => true;
}
