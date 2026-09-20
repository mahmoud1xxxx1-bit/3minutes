import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA29Bee extends CustomPainter {
  GamePainterA29Bee({required this.engine, this.images});

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

    // 1. Draw Background (Honeycomb)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFDAA520)); // Goldenrod

    final hexPaint = Paint()..color = const Color(0xFFB8860B)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    
    double hexRadius = 20.0;
    double hexHeight = hexRadius * 2;
    double hexWidth = math.sqrt(3) * hexRadius;
    
    for (double y = 0; y < GameEngine.fieldSize + hexHeight; y += hexHeight * 0.75) {
      bool offset = ((y / (hexHeight * 0.75)).round() % 2) != 0;
      for (double x = 0; x < GameEngine.fieldSize + hexWidth; x += hexWidth) {
        double px = x + (offset ? hexWidth / 2 : 0);
        
        final hex = Path();
        for (int j = 0; j < 6; j++) {
          double a = (math.pi / 3) * j + (math.pi / 6);
          double hx = px + math.cos(a) * hexRadius;
          double hy = y + math.sin(a) * hexRadius;
          if (j == 0) hex.moveTo(hx, hy);
          else hex.lineTo(hx, hy);
        }
        hex.close();
        canvas.drawPath(hex, hexPaint);
      }
    }

    // 2. Draw Obstacles (Wax Blocks / Sticky Honey)
    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      
      final wax = Paint()..color = const Color(0xFFF0E68C);
      final honey = Paint()..color = const Color(0xFFFFA500);
      
      canvas.drawRRect(RRect.fromRectAndRadius(obs, const Radius.circular(5)), wax);
      
      // Dripping honey on top
      final drip = Path()..moveTo(obs.left, obs.top)..lineTo(obs.right, obs.top)
                         ..quadraticBezierTo(obs.right - 5, obs.top + 10, obs.center.dx, obs.top + 5)
                         ..quadraticBezierTo(obs.left + 5, obs.top + 15, obs.left, obs.top)..close();
      canvas.drawPath(drip, honey);
    }

    // 3. Draw Targets (Nectar Flowers)
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      
      final target = engine.targets[i];
      final isNext = i == engine.currentTargetIndex;
      
      if (isNext) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFF69B4).withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(target, GameEngine.targetRadius * 1.5, glowPaint);
      }

      canvas.save();
      canvas.translate(target.dx, target.dy);
      // Gentle spin
      canvas.rotate(engine.time + i);
      
      final petal = isNext ? const Color(0xFFFF1493) : const Color(0xFFFFB6C1);
      final center = const Color(0xFFFFD700);
      
      for(int p=0; p<5; p++) {
        canvas.rotate(math.pi * 2 / 5);
        canvas.drawCircle(const Offset(0, -6), 5, Paint()..color = petal);
      }
      canvas.drawCircle(Offset.zero, 4, Paint()..color = center);

      canvas.restore();
    }

    // 4. Draw Exit Gate (Queen's Chamber)
    if (engine.exitGate != null) {
      canvas.save();
      canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);

      final royalJelly = Paint()..color = const Color(0xFFFFFACD);
      final border = Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 4;

      // Large Hexagon
      final hex = Path();
      for (int j = 0; j < 6; j++) {
        double a = (math.pi / 3) * j;
        double px = math.cos(a) * 30;
        double py = math.sin(a) * 30;
        if (j == 0) hex.moveTo(px, py);
        else hex.lineTo(px, py);
      }
      hex.close();
      
      canvas.drawPath(hex, royalJelly);
      canvas.drawPath(hex, border);
      
      // Crown symbol
      final crown = Path()..moveTo(-10, 5)..lineTo(-15, -5)..lineTo(-5, 0)..lineTo(0, -10)..lineTo(5, 0)..lineTo(15, -5)..lineTo(10, 5)..close();
      canvas.drawPath(crown, Paint()..color = const Color(0xFFFF8C00));

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
  bool shouldRepaint(covariant GamePainterA29Bee oldDelegate) => true;
}

extension on Color {
  Paint get paint => Paint()..color = this;
}
