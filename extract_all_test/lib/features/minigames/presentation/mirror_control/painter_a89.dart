import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA89 extends CustomPainter {
  GamePainterA89({required this.engine, this.images});
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

    final rnd = math.Random(89);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    // Distorted checkered floor
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFF0F0F0));
    
    final checkerPaint = Paint()..color = const Color(0xFF202020);
    double tileSize = 60.0;
    
    canvas.save();
    canvas.translate(GameEngine.fieldSize / 2, GameEngine.fieldSize / 2);
    canvas.rotate(math.sin(engine.time * 0.5) * 0.1);
    canvas.translate(-GameEngine.fieldSize / 2, -GameEngine.fieldSize / 2);

    for (double x = -tileSize * 2; x < GameEngine.fieldSize + tileSize * 2; x += tileSize) {
        for (double y = -tileSize * 2; y < GameEngine.fieldSize + tileSize * 2; y += tileSize) {
            int i = (x / tileSize).floor();
            int j = (y / tileSize).floor();
            if ((i + j) % 2 == 0) {
                // Distort each tile slightly based on position
                double distortX = math.sin(y * 0.05 + engine.time) * 10;
                double distortY = math.cos(x * 0.05 + engine.time) * 10;
                
                final path = Path();
                path.moveTo(x + distortX, y + distortY);
                path.lineTo(x + tileSize + distortX, y + distortY);
                path.lineTo(x + tileSize - distortX, y + tileSize - distortY);
                path.lineTo(x - distortX, y + tileSize - distortY);
                path.close();
                
                canvas.drawPath(path, checkerPaint);
            }
        }
    }
    canvas.restore();

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(10, 10)), Paint()..color=Colors.black54..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3)); // Floating Shadow
        
        // Floating doors or blocks
        final blockGradient = ui.Gradient.linear(
            obs.topLeft, obs.bottomRight, [const Color(0xFF7A6B9B), const Color(0xFF9E84BD)]
        );
        
        final obsPath = Path();
        double d = math.sin(engine.time * 2 + i) * 5;
        obsPath.moveTo(obs.left, obs.top + d);
        obsPath.lineTo(obs.right, obs.top - d);
        obsPath.lineTo(obs.right, obs.bottom - d);
        obsPath.lineTo(obs.left, obs.bottom + d);
        obsPath.close();
        
        canvas.drawPath(obsPath, Paint()..shader=blockGradient);
        canvas.drawPath(obsPath, Paint()..color=Colors.white30..style=PaintingStyle.stroke..strokeWidth=2);
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
        
        // Melting clock look
        final clockPath = Path();
        clockPath.addOval(Rect.fromCenter(center: target, width: 30, height: 20));
        clockPath.addOval(Rect.fromCenter(center: target + const Offset(5, 10), width: 15, height: 25));
        
        canvas.drawPath(clockPath, Paint()..color=const Color(0xFFFFCCAA));
        canvas.drawPath(clockPath, Paint()..color=Colors.black87..style=PaintingStyle.stroke..strokeWidth=2);
        
        canvas.drawLine(target, target + const Offset(-5, -3), Paint()..color=Colors.black..strokeWidth=2);
        canvas.drawLine(target, target + const Offset(8, 2), Paint()..color=Colors.black..strokeWidth=2);
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.save();
        canvas.translate(engine.exitGate!.dx, engine.exitGate!.dy);
        canvas.rotate(engine.time);
        // Surreal spiral exit
        final spiralPath = Path();
        for (double t = 0; t < math.pi * 4; t+=10.1) {
            double r = t * 4;
            double x = r * math.cos(t);
            double y = r * math.sin(t);
            if (t == 0) spiralPath.moveTo(x, y);
            else spiralPath.lineTo(x, y);
        }
        canvas.drawPath(spiralPath, Paint()..color=Colors.deepPurple..style=PaintingStyle.stroke..strokeWidth=6);
        canvas.drawPath(spiralPath, Paint()..color=Colors.purpleAccent..style=PaintingStyle.stroke..strokeWidth=2);
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

  @override bool shouldRepaint(covariant GamePainterA89 old) => true;
}
