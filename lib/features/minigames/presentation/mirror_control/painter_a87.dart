import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA87 extends CustomPainter {
  GamePainterA87({required this.engine, this.images});
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

    final rnd = math.Random(87);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF0F1A12));
    
    // Mossy patches
    for (int i=0; i<50; i++) {
        double rX = rnd.nextDouble() * GameEngine.fieldSize;
        double rY = rnd.nextDouble() * GameEngine.fieldSize;
        double rS = rnd.nextDouble() * 30 + 10;
        canvas.drawCircle(Offset(rX, rY), rS, Paint()..color = const Color(0xFF1E3A24).withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // Mist
    for (int i=0; i<10; i++) {
        double mx = (rnd.nextDouble() * GameEngine.fieldSize + engine.time * 5 * (i % 2 == 0 ? 1 : -1)) % GameEngine.fieldSize;
        double my = rnd.nextDouble() * GameEngine.fieldSize;
        canvas.drawCircle(Offset(mx, my), 100, Paint()..color=Colors.white.withOpacity(0.05)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black87); // Shadow
        
        // Ancient oaks/runestones
        canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(4)), Paint()..color=const Color(0xFF4A4A4A));
        canvas.drawRRect(RRect.fromRectAndRadius(obs.deflate(2), const Radius.circular(4)), Paint()..color=const Color(0xFF5A5A5A));
        
        // Vines
        final vinePath = Path();
        vinePath.moveTo(obs.left, obs.top + 10);
        vinePath.quadraticBezierTo(obs.left + obs.width / 2, obs.top + 20, obs.right, obs.top + 5);
        canvas.drawPath(vinePath, Paint()..color=const Color(0xFF2E8B57)..style=PaintingStyle.stroke..strokeWidth=3);
    }

    // ==========================================
    // 3. TARGETS
    // ==========================================
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue;
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];
        
        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            // Active glow - DO NOT MODIFY
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.amber.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withOpacity(0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }
        
        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withOpacity(isActive ? 1.0 : 0.3));
        
        // Glowing Celtic rune
        canvas.drawCircle(target, 16, Paint()..color=const Color(0xFF1B4021));
        canvas.drawCircle(target, 14, Paint()..color=const Color(0xFF66FF99)..style=PaintingStyle.stroke..strokeWidth=2);
        
        final runePath = Path();
        runePath.moveTo(target.dx - 8, target.dy - 8);
        runePath.lineTo(target.dx + 8, target.dy + 8);
        runePath.moveTo(target.dx + 8, target.dy - 8);
        runePath.lineTo(target.dx - 8, target.dy + 8);
        runePath.moveTo(target.dx, target.dy - 10);
        runePath.lineTo(target.dx, target.dy + 10);
        canvas.drawPath(runePath, Paint()..color=const Color(0xFFCCFFCC)..style=PaintingStyle.stroke..strokeWidth=2);
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=const Color(0xFF00FF88)..style=PaintingStyle.stroke..strokeWidth=8);
        canvas.drawCircle(engine.exitGate!, 40, Paint()..color=const Color(0xFF00FF88).withOpacity(0.3)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
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

  @override bool shouldRepaint(covariant GamePainterA87 old) => true;
}
