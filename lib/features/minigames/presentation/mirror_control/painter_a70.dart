import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA70 extends CustomPainter {
  GamePainterA70({required this.engine, this.images});
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

    final rnd = math.Random(70);

    // 1. FLOOR & BACKGROUND (Sunken Pirate Galleon)
    final bgRect = const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize);
    canvas.drawRect(
      bgRect,
      Paint()..shader = ui.Gradient.linear(
        const Offset(0, 0),
        const Offset(0, GameEngine.fieldSize),
        [const Color(0xFF001B3D), const Color(0xFF000510)],
      )
    );

    // Water rays
    for (int i = 0; i < 5; i++) {
      final rayPath = Path();
      double startX = rnd.nextDouble() * GameEngine.fieldSize;
      rayPath.moveTo(startX, 0);
      rayPath.lineTo(startX + 100, 0);
      rayPath.lineTo(startX + 300 - rnd.nextDouble()*200, GameEngine.fieldSize);
      rayPath.lineTo(startX - 100 - rnd.nextDouble()*200, GameEngine.fieldSize);
      rayPath.close();
      canvas.drawPath(rayPath, Paint()..color = Colors.lightBlueAccent.withValues(alpha: 0.05)..blendMode = BlendMode.screen);
    }

    // Wooden deck planks in background
    for (double y = 0; y < GameEngine.fieldSize; y+=80) {
      canvas.drawLine(Offset(0, y), Offset(GameEngine.fieldSize, y), Paint()..color=const Color(0xFF111111)..strokeWidth=2);
      for (double x = 0; x < GameEngine.fieldSize; x+=150) {
         if (rnd.nextBool()) {
             canvas.drawLine(Offset(x, y), Offset(x, y + 80), Paint()..color=const Color(0xFF111111)..strokeWidth=2);
         }
      }
    }

    // 2. WEATHER / PARTICLES (Bubbles)
    for (int i = 0; i < 150; i++) {
      double px = (rnd.nextDouble() * GameEngine.fieldSize + math.sin(engine.time + i) * 10) % GameEngine.fieldSize;
      double py = (GameEngine.fieldSize - (rnd.nextDouble() * GameEngine.fieldSize + engine.time * (20 + rnd.nextInt(30)))) % GameEngine.fieldSize;
      canvas.drawCircle(Offset(px, py), rnd.nextDouble() * 4 + 1, Paint()..color = Colors.white.withValues(alpha: 0.3)..style = PaintingStyle.stroke);
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54);
        
        // Algae-covered wooden crates
        canvas.drawRect(obs, Paint()..color=const Color(0xFF3E2723));
        canvas.drawRect(obs.deflate(4), Paint()..color=const Color(0xFF4E342E));
        
        // Iron bands
        canvas.drawRect(Rect.fromLTRB(obs.left, obs.top + 5, obs.right, obs.top + 10), Paint()..color=const Color(0xFF222222));
        canvas.drawRect(Rect.fromLTRB(obs.left, obs.bottom - 10, obs.right, obs.bottom - 5), Paint()..color=const Color(0xFF222222));
        
        // Seaweed hanging
        final seaweedPath = Path();
        seaweedPath.moveTo(obs.left, obs.top);
        for(double x=obs.left; x<=obs.right; x+=40) {
           seaweedPath.quadraticBezierTo(x+5, obs.top+20+math.sin(engine.time*3+x)*5, x+10, obs.top);
        }
        canvas.drawPath(seaweedPath, Paint()..color=Colors.green.shade900..style=PaintingStyle.fill);
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
        
        // Gold Coin
        canvas.drawCircle(target, 15, Paint()..color=Colors.amber);
        canvas.drawCircle(target, 10, Paint()..color=Colors.orangeAccent..style=PaintingStyle.stroke..strokeWidth=2);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.blueAccent..style=PaintingStyle.stroke..strokeWidth=8);
        canvas.drawArc(Rect.fromCircle(center: engine.exitGate!, radius: 35), engine.time*2, math.pi, false, Paint()..color=Colors.cyanAccent..style=PaintingStyle.stroke..strokeWidth=4);
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

  @override bool shouldRepaint(covariant GamePainterA70 old) => true;
}
