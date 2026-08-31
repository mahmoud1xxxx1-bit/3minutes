import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA7Graveyard extends CustomPainter {
  GamePainterA7Graveyard({required this.engine, this.images});

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

    // 1. Draw Background (Creepy Purple Night)
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 1.5,
        colors: [Color(0xFF2B1A3B), Color(0xFF0F0818)], // Deep purple to black
      ).createShader(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize));
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), bgPaint);

    // Fog patches
    final fogPaint = Paint()
      ..color = const Color(0xFF554477).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (int i = 0; i < 6; i++) {
      double px = (i * 250.0 + math.sin(engine.time * 0.5) * 50) % GameEngine.fieldSize;
      double py = (i * 150.0 + math.cos(engine.time * 0.3) * 50) % GameEngine.fieldSize;
      canvas.drawOval(Rect.fromCenter(center: Offset(px, py), width: 300, height: 150), fogPaint);
    }

    // 2. Draw Obstacles (Tombstones and Dead Trees)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      bool isTree = i % 3 == 0;
      
      if (isTree) {
        // Dead tree
        final treePaint = Paint()..color = const Color(0xFF1A1A1A);
        
        canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(5)), treePaint);
        
        // Branches
        final branchPaint = Paint()
          ..color = const Color(0xFF1A1A1A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;
        double cx = obs.center.dx;
        double cy = obs.center.dy;
        
        final bPath = Path();
        bPath.moveTo(cx, cy - 10);
        bPath.quadraticBezierTo(cx - 20, cy - 30, cx - 15, cy - 40);
        bPath.moveTo(cx, cy - 5);
        bPath.quadraticBezierTo(cx + 20, cy - 20, cx + 10, cy - 35);
        canvas.drawPath(bPath, branchPaint);
        
      } else {
        // Tombstone
        final stoneBase = Paint()
          ..color = const Color(0xFF444455)
          ..style = PaintingStyle.fill;
        final stoneTop = Paint()
          ..color = const Color(0xFF555566)
          ..style = PaintingStyle.fill;
        
        final stoneRect = Rect.fromLTWH(obs.left + 5, obs.top, obs.width - 10, obs.height);
        canvas.drawRRect(RRect.fromRectAndCorners(stoneRect, topLeft: const Radius.circular(15), topRight: const Radius.circular(15)), stoneBase);
        canvas.drawRRect(RRect.fromRectAndCorners(stoneRect.deflate(3), topLeft: const Radius.circular(12), topRight: const Radius.circular(12)), stoneTop);
        
        // RIP text or cross
        final engravePaint = Paint()..color = const Color(0xFF222233)..strokeWidth = 2.0;
        canvas.drawLine(Offset(obs.center.dx, obs.top + 10), Offset(obs.center.dx, obs.top + 20), engravePaint);
        canvas.drawLine(Offset(obs.center.dx - 4, obs.top + 14), Offset(obs.center.dx + 4, obs.top + 14), engravePaint);
      }
    }

    // 3. Draw Targets (Glowing Jack-o'-lanterns / Pumpkins)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFF5500).withValues(alpha: 0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      final pumpkinPaint = Paint()
        ..color = isNext ? const Color(0xFFFF6600) : const Color(0xFFAA4400)
        ..style = PaintingStyle.fill;
      final linePaint = Paint()
        ..color = isNext ? const Color(0xFFCC4400) : const Color(0xFF883300)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawOval(Rect.fromCenter(center: target, width: 20, height: 16), pumpkinPaint);
      canvas.drawArc(Rect.fromCenter(center: target, width: 20, height: 16), -math.pi/2, math.pi, false, linePaint);
      canvas.drawArc(Rect.fromCenter(center: target, width: 10, height: 16), -math.pi/2, math.pi, false, linePaint);
      
      // Stem
      canvas.drawRect(Rect.fromLTWH(target.dx - 2, target.dy - 11, 4, 4), Paint()..color = const Color(0xFF228822));

      // Carved face
      final faceColor = isNext ? Colors.yellowAccent : Colors.black;
      final facePaint = Paint()..color = faceColor;
      // Eyes
      final leftEye = Path()..moveTo(target.dx - 5, target.dy - 3)..lineTo(target.dx - 2, target.dy - 3)..lineTo(target.dx - 3.5, target.dy - 6)..close();
      final rightEye = Path()..moveTo(target.dx + 5, target.dy - 3)..lineTo(target.dx + 2, target.dy - 3)..lineTo(target.dx + 3.5, target.dy - 6)..close();
      canvas.drawPath(leftEye, facePaint);
      canvas.drawPath(rightEye, facePaint);
      // Mouth
      final mouth = Path()..moveTo(target.dx - 6, target.dy + 2)..lineTo(target.dx + 6, target.dy + 2)..lineTo(target.dx, target.dy + 6)..close();
      canvas.drawPath(mouth, facePaint);

      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: isNext ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(canvas, target - Offset(textPainter.width / 2, -15));
    }

    // 4. Draw Exit Gate (Crypt Door / Mausoleum)
    if (engine.exitGate != null) {
      final gateGlow = Paint()
        ..color = const Color(0xFF66FF66).withValues(alpha: 0.3) // Eerie green glow
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(engine.exitGate!, 45, gateGlow);

      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final cryptStone = Paint()..color = const Color(0xFF333333);
      final cryptDark = Paint()..color = const Color(0xFF111111);

      // Structure
      canvas.drawRect(const Rect.fromLTWH(-35, -30, 70, 60), cryptStone);
      // Roof triangle
      final roofPath = Path()..moveTo(-40, -30)..lineTo(0, -50)..lineTo(40, -30)..close();
      canvas.drawPath(roofPath, cryptStone);
      
      // Doorway
      canvas.drawRRect(RRect.fromRectAndCorners(const Rect.fromLTWH(-20, -10, 40, 40), topLeft: const Radius.circular(20), topRight: const Radius.circular(20)), cryptDark);

      // Eerie green mist inside
      final mistPaint = Paint()
        ..color = const Color(0xAA33FF33)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      double mistWobble = math.sin(engine.time * 5) * 5;
      canvas.drawCircle(Offset(0, 15 + mistWobble), 10, mistPaint);

      canvas.restore();

      final textSpan = const TextSpan(
        text: 'CRYPT',
        style: TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.w900, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      textPainter.paint(canvas, engine.exitGate! - Offset(textPainter.width / 2, textPainter.height / 2 + 40));
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
  bool shouldRepaint(covariant GamePainterA7Graveyard oldDelegate) {
    return true; 
  }
}
