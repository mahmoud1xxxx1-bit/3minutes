import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA73 extends CustomPainter {
  GamePainterA73({required this.engine, this.images});
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

    final rnd = math.Random(73);

    // 1. FLOOR & BACKGROUND (Crystal Resonance Cavern)
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize),
      Paint()..shader = ui.Gradient.radial(
        const Offset(GameEngine.fieldSize/2, GameEngine.fieldSize/2),
        GameEngine.fieldSize,
        [const Color(0xFF2A0044), const Color(0xFF0D001A)],
      )
    );

    // Background Crystals
    for (int i = 0; i < 30; i++) {
      double cx = rnd.nextDouble() * GameEngine.fieldSize;
      double cy = rnd.nextDouble() * GameEngine.fieldSize;
      
      final crystalPath = Path();
      crystalPath.moveTo(cx, cy - rnd.nextDouble()*100 - 50);
      crystalPath.lineTo(cx + rnd.nextDouble()*30 + 10, cy);
      crystalPath.lineTo(cx, cy + rnd.nextDouble()*100 + 50);
      crystalPath.lineTo(cx - rnd.nextDouble()*30 - 10, cy);
      crystalPath.close();

      canvas.drawPath(crystalPath, Paint()..color = const Color(0x33FF00FF)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawPath(crystalPath, Paint()..color = const Color(0x22FFFFFF)..style = PaintingStyle.stroke..strokeWidth=2);
    }

    // 2. WEATHER / PARTICLES (Sparkles)
    for (int i = 0; i < 200; i++) {
      double px = (rnd.nextDouble() * GameEngine.fieldSize + math.cos(engine.time + i*0.1) * 10) % GameEngine.fieldSize;
      double py = (rnd.nextDouble() * GameEngine.fieldSize + math.sin(engine.time + i*0.1) * 10) % GameEngine.fieldSize;
      double alpha = (0.5 + 0.5 * math.sin(engine.time*3 + i)).clamp(0.0, 1.0);
      
      canvas.drawCircle(Offset(px, py), rnd.nextDouble() * 2 + 1, Paint()..color = Colors.cyanAccent.withOpacity(alpha));
    }

    // 3. OBSTACLES
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54);
        
        // Amethyst Crystal Blocks
        canvas.drawRect(obs, Paint()..color=const Color(0xFF5E35B1));
        
        // Crystal facets
        final path = Path();
        path.moveTo(obs.left, obs.top);
        path.lineTo(obs.left + obs.width/2, obs.top + obs.height/2);
        path.lineTo(obs.right, obs.top);
        canvas.drawPath(path, Paint()..color=Colors.white24);
        
        final path2 = Path();
        path2.moveTo(obs.left, obs.bottom);
        path2.lineTo(obs.left + obs.width/2, obs.top + obs.height/2);
        path2.lineTo(obs.right, obs.bottom);
        canvas.drawPath(path2, Paint()..color=Colors.black26);
        
        canvas.drawRect(obs, Paint()..color=Colors.purpleAccent..style=PaintingStyle.stroke..strokeWidth=1);
    }

    // 4. TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
        if (i < engine.currentTargetIndex) continue; 
        
        bool isActive = (i == engine.currentTargetIndex);
        final target = engine.targets[i];

        if (isActive) {
            double p = 1.0 + math.sin(engine.time*8)*0.2;
            canvas.drawCircle(target, 35*p, Paint()..color=Colors.pinkAccent.withOpacity(0.6)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 3));
            canvas.drawCircle(target, 20*p, Paint()..color=Colors.white.withOpacity(0.8)..maskFilter=const MaskFilter.blur(BlurStyle.normal, 5));
        }

        canvas.saveLayer(Rect.fromCenter(center: target, width: 80, height: 80), Paint()..color=Colors.white.withOpacity(isActive ? 1.0 : 0.3));
        
        // Diamond Target
        final diamond = Path();
        diamond.moveTo(target.dx, target.dy - 15);
        diamond.lineTo(target.dx + 15, target.dy);
        diamond.lineTo(target.dx, target.dy + 15);
        diamond.lineTo(target.dx - 15, target.dy);
        diamond.close();
        canvas.drawPath(diamond, Paint()..color=Colors.cyanAccent);
        
        canvas.restore();
    }

    // 5. EXIT GATE
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.purpleAccent..style=PaintingStyle.stroke..strokeWidth=8);
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2..maskFilter=const MaskFilter.blur(BlurStyle.normal, 2));
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

  @override bool shouldRepaint(covariant GamePainterA73 old) => true;
}
