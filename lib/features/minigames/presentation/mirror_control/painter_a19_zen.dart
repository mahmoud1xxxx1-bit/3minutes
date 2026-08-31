import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA19Zen extends CustomPainter {
  GamePainterA19Zen({required this.engine, this.images});

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

    // 1. Draw Background (Raked Sand)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFF5F5DC)); // Beige

    final rakePaint = Paint()..color = const Color(0xFFE8E8D0)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    
    // Concentric circles in sand around the center
    for (double r = 20; r < GameEngine.fieldSize * 1.5; r+=60) {
      canvas.drawCircle(const Offset(GameEngine.fieldSize / 2, GameEngine.fieldSize / 2), r, rakePaint);
    }

    // 2. Draw Obstacles (Zen Rocks & Bonsai)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      if (i % 2 == 0) {
        // Rock
        final rockColor = const Color(0xFF708090); // Slate gray
        final path = Path()..moveTo(obs.left + 5, obs.top)..lineTo(obs.right - 5, obs.top + 2)
          ..lineTo(obs.right, obs.bottom - 5)..lineTo(obs.left, obs.bottom)..close();
        canvas.drawPath(path, Paint()..color = rockColor);
        canvas.drawCircle(Offset(obs.center.dx - 2, obs.center.dy - 2), 4, Paint()..color = const Color(0xFF8899A6)); // highlight
        
        // Rake marks around rock
        canvas.drawCircle(obs.center, obs.width/2 + 5, rakePaint);
        canvas.drawCircle(obs.center, obs.width/2 + 10, rakePaint);
      } else {
        // Bonsai planter
        canvas.drawRect(Rect.fromLTWH(obs.left, obs.bottom - 10, obs.width, 10), Paint()..color = const Color(0xFF8B4513));
        // Trunk
        canvas.drawLine(Offset(obs.center.dx, obs.bottom - 10), Offset(obs.center.dx - 5, obs.top + 10), Paint()..color = const Color(0xFF5C4033)..strokeWidth = 3);
        // Leaves
        canvas.drawCircle(Offset(obs.center.dx - 5, obs.top + 10), 12, Paint()..color = const Color(0xFF228B22));
        canvas.drawCircle(Offset(obs.center.dx + 5, obs.top + 15), 8, Paint()..color = const Color(0xFF006400));
      }
    }

    // 3. Draw Targets (Lotus Flowers)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFF69B4).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Gentle floating/breathing
      double scale = 1.0 + math.sin(engine.time * 2 + i) * 0.1;
      canvas.scale(scale, scale);
      
      final petal = Paint()..color = isNext ? const Color(0xFFFF69B4) : const Color(0xFFFFB6C1);
      final center = Paint()..color = const Color(0xFFFFD700);
      
      for(int p=0; p<6; p++) {
        canvas.rotate(math.pi / 3);
        final path = Path()..moveTo(0, 0)..quadraticBezierTo(5, -10, 0, -15)..quadraticBezierTo(-5, -10, 0, 0)..close();
        canvas.drawPath(path, petal);
      }
      canvas.drawCircle(Offset.zero, 4, center);
      
      canvas.restore();
    }

    // 4. Draw Exit Gate (Moon Gate)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final brick = Paint()..color = const Color(0xFF808080)..style = PaintingStyle.stroke..strokeWidth = 6.0;
      final opening = Paint()..color = const Color(0x66000000);

      // Circle opening
      canvas.drawCircle(Offset.zero, 25, opening);
      canvas.drawCircle(Offset.zero, 25, brick);
      
      // Path leading through
      canvas.drawRect(const Rect.fromLTWH(-10, 10, 20, 15), Paint()..color = const Color(0xFFD3D3D3));

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

  @override
  bool shouldRepaint(covariant GamePainterA19Zen oldDelegate) => true; 
}
