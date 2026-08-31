import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA104 extends CustomPainter {
  GamePainterA104({required this.engine, this.images});
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

    final rnd = math.Random(104);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    // Mirror Dimension Background
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF111111));
    
    // Shattered glass shards in background
    for(int i=0; i<30; i++) {
        final cx = rnd.nextDouble() * GameEngine.fieldSize;
        final cy = rnd.nextDouble() * GameEngine.fieldSize;
        final size = rnd.nextDouble() * 100 + 50;
        
        final path = Path();
        path.moveTo(cx, cy);
        path.lineTo(cx + rnd.nextDouble()*size - size/2, cy + rnd.nextDouble()*size);
        path.lineTo(cx + rnd.nextDouble()*size, cy - rnd.nextDouble()*size/2);
        path.close();
        
        double shiftX = math.sin(engine.time * 2 + i) * 10;
        
        canvas.save();
        canvas.translate(shiftX, 0);
        
        // Inverted colors / glassy look
        canvas.drawPath(path, Paint()
            ..color = Colors.white.withValues(alpha: 0.05 + rnd.nextDouble()*0.1)
            ..style = PaintingStyle.fill
            ..blendMode = BlendMode.difference);
            
        canvas.drawPath(path, Paint()
            ..color = Colors.cyanAccent.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
            
        canvas.restore();
    }
    
    // Grid of inverted reality
    final gridPaint = Paint()..color=Colors.purpleAccent.withValues(alpha: 0.2)..style=PaintingStyle.stroke..strokeWidth=2;
    for(double i=0; i<GameEngine.fieldSize; i+=120) {
        canvas.drawLine(Offset(i, 0), Offset(i + math.sin(engine.time)*50, GameEngine.fieldSize), gridPaint);
        canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i + math.cos(engine.time)*50), gridPaint);
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        // Reflection below
        canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=Colors.cyanAccent.withValues(alpha: 0.2)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        
        // Glass block
        canvas.drawRect(obs, Paint()..color=const Color(0xFF222222).withValues(alpha: 0.8));
        canvas.drawRect(obs, Paint()..color=Colors.white.withValues(alpha: 0.5)..style=PaintingStyle.stroke..strokeWidth=2);
        
        // Internal fracture
        canvas.drawLine(obs.topLeft, obs.bottomRight, Paint()..color=Colors.cyanAccent.withValues(alpha: 0.6)..strokeWidth=1);
        canvas.drawLine(obs.bottomLeft, obs.topRight, Paint()..color=Colors.purpleAccent.withValues(alpha: 0.6)..strokeWidth=1);
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
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.amber.withValues(alpha: 0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withValues(alpha: 0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }
        
        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withValues(alpha: isActive ? 1.0 : 0.3));
        
        // Prism target
        canvas.save();
        canvas.translate(target.dx, target.dy);
        canvas.rotate(engine.time * 3);
        final prismPath = Path()
            ..moveTo(0, -15)
            ..lineTo(13, 10)
            ..lineTo(-13, 10)
            ..close();
        canvas.drawPath(prismPath, Paint()..color=Colors.cyanAccent);
        canvas.drawPath(prismPath, Paint()..color=Colors.purpleAccent..style=PaintingStyle.stroke..strokeWidth=2);
        canvas.restore();
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate!, width: 70, height: 70), Paint()..color=Colors.white.withValues(alpha: 0.8)..style=PaintingStyle.stroke..strokeWidth=5);
        canvas.save();
        canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);
        canvas.rotate(math.pi/4);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 70, height: 70), Paint()..color=Colors.cyanAccent.withValues(alpha: 0.8)..style=PaintingStyle.stroke..strokeWidth=5);
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

  @override bool shouldRepaint(covariant GamePainterA104 old) => true;
}
