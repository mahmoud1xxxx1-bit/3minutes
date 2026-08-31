import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA103 extends CustomPainter {
  GamePainterA103({required this.engine, this.images});
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

    final rnd = math.Random(103);

    // ==========================================
    // 1. ARTISTIC BACKGROUND AND FLOOR
    // ==========================================
    // Giant Green Leaves background
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = const Color(0xFF1E3F20));
    
    // Draw huge leaf veins
    final leafPaint = Paint()..color = const Color(0xFF2E5E30)..style = PaintingStyle.stroke..strokeWidth = 10;
    canvas.drawLine(const Offset(0, 0), const Offset(GameEngine.fieldSize, GameEngine.fieldSize), leafPaint);
    canvas.drawLine(const Offset(GameEngine.fieldSize, 0), const Offset(0, GameEngine.fieldSize), leafPaint);
    
    for(double i=0; i<GameEngine.fieldSize; i+=150) {
        canvas.drawLine(Offset(i, i), Offset(i + 150, i), leafPaint..strokeWidth = 4);
        canvas.drawLine(Offset(i, i), Offset(i, i + 150), leafPaint);
    }
    
    // Glowing fairy lights scattered
    for(int i=0; i<40; i++) {
        final lx = rnd.nextDouble() * GameEngine.fieldSize;
        final ly = rnd.nextDouble() * GameEngine.fieldSize;
        final p = math.sin(engine.time * 5 + i);
        if (p > 0) {
            canvas.drawCircle(Offset(lx, ly), 3 + p*2, Paint()..color = Colors.amber.withValues(alpha: 0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
            canvas.drawCircle(Offset(lx, ly), 1 + p, Paint()..color = Colors.white);
        }
    }

    // ==========================================
    // 2. OBSTACLES
    // ==========================================
    for (int i = 0; i < engine.obstacles.length; i++) {
        final obs = engine.obstacles[i];
        
        // Shadow
        canvas.drawRect(obs.shift(const Offset(0, 15)), Paint()..color=Colors.black54); 
        
        // Wooden platform
        canvas.drawRect(obs, Paint()..color=const Color(0xFF6B4226));
        
        // Wood grain
        final grain = Paint()..color=const Color(0xFF4A2B18)..style=PaintingStyle.stroke..strokeWidth=2;
        for(double y=obs.top + 5; y<obs.bottom; y+=60) {
            canvas.drawPath(Path()..moveTo(obs.left, y)..quadraticBezierTo(obs.left + obs.width/2, y + (i%2==0?5:-5), obs.right, y), grain);
        }
        
        // Moss on top edge
        canvas.drawRect(Rect.fromLTWH(obs.left, obs.top, obs.width, 8), Paint()..color = const Color(0xFF4C9A2A));
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
        
        // Glowing fairy / acorn
        canvas.drawCircle(target, 12, Paint()..color=Colors.greenAccent);
        canvas.drawArc(Rect.fromCircle(center: target - const Offset(0, 5), radius: 12), math.pi, math.pi, true, Paint()..color=const Color(0xFF8B4513)); // Acorn cap
        
        canvas.restore();
    }

    // ==========================================
    // 4. EXIT GATE
    // ==========================================
    if (engine.exitGate != null) {
        canvas.drawCircle(engine.exitGate!, 45, Paint()..color=Colors.greenAccent.withValues(alpha: 0.8)..style=PaintingStyle.stroke..strokeWidth=8);
        for(int i=0; i<8; i++) {
            double a = engine.time * 2 + i * math.pi/4;
            canvas.drawCircle(engine.exitGate! + Offset(math.cos(a)*45, math.sin(a)*45), 5, Paint()..color=Colors.amber);
        }
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

  @override bool shouldRepaint(covariant GamePainterA103 old) => true;
}
