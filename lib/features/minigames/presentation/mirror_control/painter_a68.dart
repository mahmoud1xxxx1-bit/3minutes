import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA68 extends CustomPainter {
  GamePainterA68({required this.engine, this.images});
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

    final rnd = math.Random(68);

    // 1. FLOOR & BACKGROUND (Medieval Castle Dungeon)
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF2A2A2A));
    
    // Stone floor tiles
    for (double y = 0; y < GameEngine.fieldSize; y+=60) {
        for (double x = 0; x < GameEngine.fieldSize; x+=80) {
            double offsetX = (y % 120 == 0) ? 0 : 40;
            canvas.drawRect(Rect.fromLTWH(x + offsetX, y, 78, 58), Paint()..color=Colors.blueGrey[800]!);
            canvas.drawRect(Rect.fromLTWH(x + offsetX, y, 78, 58), Paint()..color=Colors.black38..style=PaintingStyle.stroke..strokeWidth=2);
        }
    }
    
    // Torches
    for (int i = 0; i < 6; i++) {
        double tx = rnd.nextDouble() * GameEngine.fieldSize;
        double ty = rnd.nextDouble() * GameEngine.fieldSize;
        
        canvas.drawCircle(Offset(tx, ty), 60, Paint()..color=Colors.orange.withValues(alpha: 0.15)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        
        Path flame = Path();
        flame.moveTo(tx, ty - 20);
        flame.quadraticBezierTo(tx + 10, ty - 10, tx, ty + 10);
        flame.quadraticBezierTo(tx - 10, ty - 10, tx, ty - 20);
        
        canvas.drawPath(flame, Paint()..color=Colors.orangeAccent..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        canvas.drawPath(flame, Paint()..color=Colors.yellow.withValues(alpha: 0.8));
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=Colors.black87..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
        
        canvas.drawRect(obs, Paint()..color=const Color(0xFF454545));
        canvas.drawRect(obs, Paint()..color=Colors.black54..style=PaintingStyle.stroke..strokeWidth=4);
        
        // Bricks
        for (double by = obs.top + 15; by < obs.bottom; by+=60) {
            canvas.drawLine(Offset(obs.left, by), Offset(obs.right, by), Paint()..color=Colors.black87..strokeWidth=2);
        }
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.yellowAccent.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }
        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Golden goblet
        Path goblet = Path();
        goblet.moveTo(target.dx - 10, target.dy - 10);
        goblet.lineTo(target.dx + 10, target.dy - 10);
        goblet.lineTo(target.dx + 5, target.dy + 5);
        goblet.lineTo(target.dx + 8, target.dy + 15);
        goblet.lineTo(target.dx - 8, target.dy + 15);
        goblet.lineTo(target.dx - 5, target.dy + 5);
        goblet.close();
        
        canvas.drawPath(goblet, Paint()..color=Colors.amber);
        canvas.drawPath(goblet, Paint()..color=Colors.black87..style=PaintingStyle.stroke..strokeWidth=1);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate!, width: 70, height: 90), Paint()..color=Colors.black);
        Path arch = Path();
        arch.moveTo(engine.exitGate!.dx - 35, engine.exitGate!.dy + 45);
        arch.lineTo(engine.exitGate!.dx - 35, engine.exitGate!.dy - 10);
        arch.quadraticBezierTo(engine.exitGate!.dx, engine.exitGate!.dy - 55, engine.exitGate!.dx + 35, engine.exitGate!.dy - 10);
        arch.lineTo(engine.exitGate!.dx + 35, engine.exitGate!.dy + 45);
        canvas.drawPath(arch, Paint()..color=Colors.grey[700]!..style=PaintingStyle.stroke..strokeWidth=10);
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

  @override bool shouldRepaint(covariant GamePainterA68 old) => true;
}
