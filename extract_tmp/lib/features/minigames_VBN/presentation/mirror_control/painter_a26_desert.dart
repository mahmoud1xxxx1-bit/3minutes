import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA26Desert extends CustomPainter {
  GamePainterA26Desert({required this.engine, this.images});

  final GameEngine engine;
  final Map<String, ui.Image>? images;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / GameEngine.fieldSize;
    final scaleY = size.height / GameEngine.fieldSize;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    final offsetX = (size.width - (GameEngine.fieldSize * scale)) / 2;
    final offsetY = (size.height - (GameEngine.fieldSize * scale)) / 2;

    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));

    // 1. Draw Background (Sand Dunes)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFEDC9AF)); // Desert sand

    final dunePaint = Paint()..color = const Color(0xFFD2B48C)..style = PaintingStyle.fill;
    final dunePath = Path()..moveTo(0, 100)..quadraticBezierTo(100, 50, 200, 120)..quadraticBezierTo(300, 180, GameEngine.fieldSize, 100)
      ..lineTo(GameEngine.fieldSize, GameEngine.fieldSize)..lineTo(0, GameEngine.fieldSize)..close();
    canvas.drawPath(dunePath, dunePaint);
    
    final dunePath2 = Path()..moveTo(0, 250)..quadraticBezierTo(150, 200, 250, 280)..quadraticBezierTo(350, 320, GameEngine.fieldSize, 200)
      ..lineTo(GameEngine.fieldSize, GameEngine.fieldSize)..lineTo(0, GameEngine.fieldSize)..close();
    canvas.drawPath(dunePath2, Paint()..color = const Color(0xFFC19A6B));

    // 2. Draw Obstacles (Cacti)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final cactusGreen = const Color(0xFF2E8B57);
      
      canvas.save();
      canvas.translate(obs.center.dx, obs.center.dy);
      
      // Main trunk
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-8, -obs.height/2, 16, obs.height), const Radius.circular(8)), Paint()..color = cactusGreen);
      
      // Arms
      if (i % 2 == 0) {
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8, -10, 12, 6), const Radius.circular(3)), Paint()..color = cactusGreen);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, -25, 6, 20), const Radius.circular(3)), Paint()..color = cactusGreen);
      } else {
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-20, 0, 12, 6), const Radius.circular(3)), Paint()..color = cactusGreen);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-20, -15, 6, 20), const Radius.circular(3)), Paint()..color = cactusGreen);
      }
      
      // Needles
      final needle = Paint()..color = const Color(0xFF006400)..strokeWidth = 1.0;
      canvas.drawLine(const Offset(-8, 0), const Offset(-12, -2), needle);
      canvas.drawLine(const Offset(8, -5), const Offset(12, -7), needle);
      canvas.drawLine(Offset(0, -obs.height/2), Offset(0, -obs.height/2 - 4), needle);
      
      canvas.restore();
    }

    // 3. Draw Targets (Water Canteens)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFF00BFFF).withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Gentle bob
      canvas.translate(0, math.sin(engine.time * 3 + i) * 2);
      
      final canteenColor = isNext ? const Color(0xFF20B2AA) : const Color(0xFF556B2F); // Teal / Olive
      
      // Canteen body
      canvas.drawCircle(Offset.zero, 10, Paint()..color = canteenColor);
      canvas.drawCircle(Offset.zero, 10, Paint()..color = Colors.black..style = PaintingStyle.stroke);
      
      // Cap
      canvas.drawRect(const Rect.fromLTWH(-3, -13, 6, 4), Paint()..color = Colors.black);
      // Strap
      canvas.drawArc(const Rect.fromLTWH(-12, -15, 24, 24), -math.pi, math.pi, false, Paint()..color = const Color(0xFF8B4513)..style = PaintingStyle.stroke..strokeWidth = 1.5);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Oasis Pond)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final water = Paint()..color = const Color(0xFF00BFFF);
      final palmTrunk = Paint()..color = const Color(0xFF8B4513);
      final palmLeaf = Paint()..color = const Color(0xFF228B22);

      // Pond
      canvas.drawOval(const Rect.fromLTWH(-35, -20, 70, 40), water);
      
      // Palm tree 1
      canvas.drawLine(const Offset(-25, 0), const Offset(-35, -30), palmTrunk..strokeWidth = 4);
      for(int j=0; j<5; j++) {
        canvas.save();
        canvas.translate(-35, -30);
        canvas.rotate(j * math.pi/2.5);
        canvas.drawPath(Path()..moveTo(0,0)..quadraticBezierTo(10, -5, 20, 0)..quadraticBezierTo(10, 5, 0, 0)..close(), palmLeaf);
        canvas.restore();
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

  @override
  bool shouldRepaint(covariant GamePainterA26Desert oldDelegate) => true; 
}
