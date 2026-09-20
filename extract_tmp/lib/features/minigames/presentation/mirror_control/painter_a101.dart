import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA101 extends CustomPainter {
  GamePainterA101({required this.engine, this.images});
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

    final rnd = math.Random(101);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    // Tatami mats floor
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFFCDBA96));
    
    // Draw tatami mat grid and texture
    final matPaint = Paint()..color = const Color(0xFF8B7E66)..style = PaintingStyle.stroke..strokeWidth = 2;
    for (double i = 0; i < GameEngine.fieldSize; i+=100) {
      canvas.drawLine(Offset(i, 0), Offset(i, GameEngine.fieldSize), matPaint);
      canvas.drawLine(Offset(0, i), Offset(GameEngine.fieldSize, i), matPaint);
      
      // Mat border (greenish cloth)
      canvas.drawRect(Rect.fromLTWH(i-5, 0, 10, GameEngine.fieldSize), Paint()..color = const Color(0xFF2E4C34));
      canvas.drawRect(Rect.fromLTWH(0, i-5, GameEngine.fieldSize, 10), Paint()..color = const Color(0xFF2E4C34));
    }
    
    // Bamboo shadows from edges
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.15);
    for (int i=0; i<5; i++) {
        canvas.drawOval(Rect.fromLTWH(-50 + i*150.0, -100, 30, GameEngine.fieldSize + 200), shadowPaint);
        canvas.drawOval(Rect.fromLTWH(-50 + i*150.0 + math.sin(engine.time+i)*20, -100, 30, GameEngine.fieldSize + 200), shadowPaint);
    }
    
    // Shoji screens along the top edge
    for (double i=0; i<GameEngine.fieldSize; i+=200) {
      canvas.drawRect(Rect.fromLTWH(i+10, 10, 180, 80), Paint()..color = Colors.white.withOpacity(0.8));
      canvas.drawRect(Rect.fromLTWH(i+10, 10, 180, 80), Paint()..color = const Color(0xFF5C4033)..style = PaintingStyle.stroke..strokeWidth = 4);
      for(double j=0; j<180; j+=45) {
          canvas.drawLine(Offset(i+10+j, 10), Offset(i+10+j, 90), Paint()..color = const Color(0xFF5C4033)..strokeWidth = 2);
      }
      canvas.drawLine(Offset(i+10, 50), Offset(i+190, 50), Paint()..color = const Color(0xFF5C4033)..strokeWidth = 2);
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        // Shadow
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54); 
        
        // Wooden Block / Pillar (Shoji screen base / wooden partition)
        canvas.drawRect(obs, Paint()..color=const Color(0xFF5C4033));
        canvas.drawRect(obs.deflate(4), Paint()..color=const Color(0xFF8B5A2B));
        
        // Katana resting on the partition
        canvas.drawLine(Offset(obs.left - 5, obs.top + obs.height/2), Offset(obs.right + 5, obs.top + obs.height/2), Paint()..color=const Color(0xFFB0C4DE)..strokeWidth=3);
        canvas.drawLine(Offset(obs.left - 5, obs.top + obs.height/2), Offset(obs.left + 15, obs.top + obs.height/2), Paint()..color=const Color(0xFF333333)..strokeWidth=5); // Hilt
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
        
        // Glowing Sakura (Cherry Blossom) as target
        canvas.save();
        canvas.translate(target.dx, target.dy);
        canvas.rotate(engine.time * 2);
        final petalPaint = Paint()..color = const Color(0xFFFFB7C5);
        for(int j=0; j<5; j++) {
            canvas.rotate(math.pi*2/5);
            canvas.drawOval(const Rect.fromLTRB(0, -5, 20, 5), petalPaint);
        }
        canvas.drawCircle(Offset.zero, 5, Paint()..color=Colors.yellowAccent);
        canvas.restore();
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=const Color(0xFF8B0000)..style=PaintingStyle.stroke..strokeWidth=8); // Deep red Torii gate style
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate!, width: 90, height: 10), Paint()..color=const Color(0xFF8B0000));
        canvas.drawRect(Rect.fromCenter(center: engine.exitGate! - const Offset(0, 30), width: 110, height: 15), Paint()..color=const Color(0xFF8B0000));
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

  @override bool shouldRepaint(covariant GamePainterA101 old) => true;
}
