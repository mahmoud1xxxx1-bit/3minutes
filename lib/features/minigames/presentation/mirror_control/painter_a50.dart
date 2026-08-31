import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'game_engine.dart';

class GamePainterA50 extends CustomPainter {
  GamePainterA50({required this.engine, this.images});
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

    // FLOOR

    // Shattered reality: Huge intersecting polygons of various colors representing all past worlds
    canvas.drawRect(const Rect.fromLTWH(0, 0, GameEngine.fieldSize, GameEngine.fieldSize), Paint()..color = Colors.black);
    final rnd = math.Random(50);
    final colors = [Colors.red, Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.cyan, Colors.yellow];
    for(int i=0; i<30; i++) {
        Path shard = Path()..moveTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        shard.lineTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        shard.lineTo(rnd.nextDouble()*GameEngine.fieldSize, rnd.nextDouble()*GameEngine.fieldSize);
        shard.close();
        // Slow shifting pulse
        double op = 0.1 + math.sin(engine.time + i)*0.1;
        canvas.drawPath(shard, Paint()..color=colors[i%colors.length].withValues(alpha: op.abs()));
        canvas.drawPath(shard, Paint()..color=Colors.white.withValues(alpha: 0.2)..style=PaintingStyle.stroke..strokeWidth=2);
    }
    

    // WEATHER

    // Rising shards of glass
    for (int i = 0; i < 25; i++) {
      double px = ((i * 75) + math.sin(engine.time*0.5 + i)*40) % GameEngine.fieldSize;
      double py = ((i * 120) - engine.time * 80) % GameEngine.fieldSize;
      if (py < 0) py += GameEngine.fieldSize;
      canvas.save(); canvas.translate(px, py); canvas.rotate(engine.time + i);
      canvas.drawRect(const Rect.fromLTWH(-5, -10, 10, 20), Paint()..color=Colors.white.withValues(alpha: 0.6));
      canvas.restore();
    }
    

    // OBSTACLES

    for (int i = 0; i < engine.obstacles.length; i++) {
      final obs = engine.obstacles[i];
      // Standing Mirrors
      canvas.drawRect(obs.shift(const Offset(0, 20)), Paint()..color=Colors.white.withValues(alpha: 0.2)); // reflection
      canvas.drawRect(obs, Paint()..color=const Color(0xFFCFD8DC)); // mirror glass
      canvas.drawRect(obs, Paint()..color=const Color(0xFF455A64)..style=PaintingStyle.stroke..strokeWidth=4); // dark frame
      // Diagonal glare
      canvas.drawLine(obs.bottomLeft + const Offset(5, -5), obs.topRight + const Offset(-5, 5), Paint()..color=Colors.white..strokeWidth=6);
    }
    

    // TARGETS
    for (int i = 0; i < engine.targets.length; i++) {
      if (i < engine.currentTargetIndex) continue;
      final target = engine.targets[i];
      final tr = GameEngine.targetRadius; 
      double floatOffset = math.sin(engine.time * 4 + i) * 5;

      final isNext = i == engine.currentTargetIndex;
      canvas.drawOval(Rect.fromCenter(center: target + const Offset(0, 15), width: tr*1.5, height: tr*0.8), Paint()..color=Colors.white.withValues(alpha: 0.2));
      canvas.save(); canvas.translate(target.dx, target.dy - floatOffset);
      if (isNext) {
          // The Ultimate Core (Mandala)
          canvas.save(); canvas.rotate(engine.time * 3);
          for(int a=0; a<8; a++) {
              canvas.rotate(math.pi/4);
              canvas.drawOval(const Rect.fromLTWH(0, -5, 25, 10), Paint()..color=Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
          }
          canvas.restore();
          canvas.drawCircle(Offset.zero, 12, Paint()..color=Colors.white);
          canvas.drawCircle(Offset.zero, tr*3, Paint()..shader = ui.Gradient.radial(Offset.zero, tr*3, [Colors.white.withValues(alpha: 0.7), Colors.transparent]));
      } else {
          // Shattered dark core
          canvas.drawCircle(Offset.zero, 10, Paint()..color=Colors.black);
          canvas.drawLine(const Offset(-8, -8), const Offset(8, 8), Paint()..color=Colors.white..strokeWidth=2);
      }
      canvas.restore();
    
    }

    // EXIT GATE
    if (engine.exitGate != null) {
      final center = engine.exitGate!;

      canvas.drawCircle(center, 50, Paint()..color=Colors.white);
      canvas.drawCircle(center, 40, Paint()..color=Colors.black);
      // The final portal - pulsating white hole
      double pulse = 20 + math.sin(engine.time * 10) * 10;
      canvas.drawCircle(center, pulse, Paint()..color=Colors.white);
      canvas.drawCircle(center, 40, Paint()..shader = ui.Gradient.radial(center, 40, [Colors.white.withValues(alpha: 0.8), Colors.transparent]));
    
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
  @override bool shouldRepaint(covariant GamePainterA50 old) => true;
}
