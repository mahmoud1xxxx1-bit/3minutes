import glob
import re

UNIFIED_IDENTITY = """
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
"""

paths = glob.glob(r"lib/features/minigames/presentation/mirror_control/painter_a*.dart")
for p in paths:
    with open(p, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find exitGate block
    match = re.search(r'if\s*\(\s*engine\.exitGate\s*!=\s*null\s*\)\s*\{', content)
    if not match:
        print("COULD NOT FIND EXITGATE IN " + p)
        continue
    
    start_idx = match.end() - 1 # points to {
    brace_count = 0
    end_idx = -1
    for i in range(start_idx, len(content)):
        if content[i] == '{': brace_count += 1
        elif content[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                end_idx = i
                break
    
    if end_idx == -1:
        print("COULD NOT FIND END OF EXITGATE IN " + p)
        continue
    
    # Now find the start of shouldRepaint
    match_sr = re.search(r'(@override\s+)?bool\s+shouldRepaint', content[end_idx:])
    if not match_sr:
        print("COULD NOT FIND SHOULDREPAINT IN " + p)
        continue
    
    sr_start = end_idx + match_sr.start()
    
    # We replace everything between end_idx + 1 and sr_start - 1 (we need to keep the closing } of paint, which is right before sr_start typically)
    # Wait, the closing brace of `paint` method is right before `shouldRepaint`.
    # Let's find the closing brace of `paint` by looking backwards from sr_start
    paint_close_idx = content.rfind('}', end_idx, sr_start)
    
    if paint_close_idx == -1:
        print("COULD NOT FIND CLOSE OF PAINT IN " + p)
        continue
        
    # Replace from end_idx+1 to paint_close_idx
    new_content = content[:end_idx+1] + "\n" + UNIFIED_IDENTITY + "\n  " + content[paint_close_idx:]
    
    # Also, some agents didn't import math or dart:ui or colors. We should make sure they are imported.
    # The unified identity uses `math.sin`, `Colors.black`, `ui.Image`, `MaskFilter`.
    if "import 'dart:math'" not in new_content:
        new_content = new_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:math' as math;")
    if "import 'dart:ui'" not in new_content:
        new_content = new_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:ui' as ui;")
        
    with open(p, 'w', encoding='utf-8') as f:
        f.write(new_content)

print("Unified identity applied to all files!")
