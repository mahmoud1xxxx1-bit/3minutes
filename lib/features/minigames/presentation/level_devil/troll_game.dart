import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'troll_engine.dart';

class TrollGame extends StatefulWidget {
  const TrollGame({super.key, required this.onWin, this.startRound = 1});
  final VoidCallback onWin;
  final int startRound;

  @override
  State<TrollGame> createState() => _TrollGameState();
}

class _TrollGameState extends State<TrollGame> with SingleTickerProviderStateMixin {
  late TrollEngine _engine;
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _engine = TrollEngine(round: widget.startRound);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    setState(() {
      _engine.update(dt);
      if (_engine.allComplete) {
        _ticker.stop();
        Future.delayed(const Duration(milliseconds: 500), widget.onWin);
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _engine.movingLeft = true;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) _engine.movingRight = true;
      if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.arrowUp) _engine.jumping = true;
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _engine.movingLeft = false;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) _engine.movingRight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF07080A), // Extremely dark blue/black
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 800 / 600,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: _TrollPainter(_engine),
                          size: Size.infinite,
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 5),
                                Text('${_engine.correctCount}/3', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 15),
                                const Icon(Icons.cancel, color: Colors.red, size: 20),
                                const SizedBox(width: 5),
                                Text('${_engine.errorCount}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Mobile Controls
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F111A),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _ControlButton(
                          icon: Icons.keyboard_arrow_left,
                          onDown: () => _engine.movingLeft = true,
                          onUp: () => _engine.movingLeft = false,
                        ),
                        const SizedBox(width: 20),
                        _ControlButton(
                          icon: Icons.keyboard_arrow_right,
                          onDown: () => _engine.movingRight = true,
                          onUp: () => _engine.movingRight = false,
                        ),
                      ],
                    ),
                    _ControlButton(
                      icon: Icons.keyboard_arrow_up,
                      color: const Color(0xFF00FFCC),
                      onDown: () => _engine.jumping = true,
                      onUp: () {}, // jump triggers once
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final Color color;

  const _ControlButton({required this.icon, required this.onDown, required this.onUp, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Icon(icon, size: 50, color: color),
      ),
    );
  }
}

class _TrollPainter extends CustomPainter {
  _TrollPainter(this.engine);
  final TrollEngine engine;

  @override
  void paint(Canvas canvas, Size size) {
    double scaleX = size.width / engine.logicalWidth;
    double scaleY = size.height / engine.logicalHeight;
    
    
    canvas.save();
    canvas.scale(scaleX, scaleY);
    if (engine.isMirrorLevel) {
       canvas.translate(engine.logicalWidth, 0);
       canvas.scale(-1, 1);
    }


    _drawBackground(canvas);

    // Apply Camera for world elements
    canvas.save();
    canvas.translate(-engine.cameraX, 0);

    _drawGrid(canvas);

    var paint = Paint();
    
    for (var e in engine.entities) {
      if (!e.isVisible) continue;

      if (e.type == TrollEntityType.block) {
        paint.color = e.color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(e.rect.toRect(), const Radius.circular(4)),
          paint
        );
        paint.color = Colors.white.withOpacity(0.05);
        canvas.drawRect(Rect.fromLTWH(e.rect.x, e.rect.y, e.rect.w, 4), paint);
        
      } else if (e.type == TrollEntityType.spike) {
        _drawSpike(canvas, e.rect, e.color, e.isInverted);
      } else if (e.type == TrollEntityType.door) {
        _drawDoor(canvas, e.rect, e.color);
      }
    }

    if (engine.isGhostLevel && engine.ghostHistory.isNotEmpty) {
      var ghostP = TrollEntity(
        id: "ghost", type: TrollEntityType.player,
        rect: RectD(engine.ghostHistory.first.dx, engine.ghostHistory.first.dy, engine.player.rect.w, engine.player.rect.h),
        color: const Color(0xFFFF3366)
      );
      _drawPlayer(canvas, ghostP, opacity: 0.5);
    }
    
    if (engine.isChasedLevel) {
      paint.color = const Color(0xFF220000);
      canvas.drawRect(Rect.fromLTWH(engine.chaseWallX - 1000, 0, 1000, 800), paint);
      
      paint.color = const Color(0xFFFF1111);
      for (double y = 0; y < 800; y += 40) {
        _drawRightSpike(canvas, RectD(engine.chaseWallX, y, 40, 40), paint.color); 
      }
    }

    if (!engine.isDead || engine.playerScale > 0) {
      _drawPlayer(canvas, engine.player);
    }
    
    for (var p in engine.particles) {
      paint.color = p.color.withOpacity(p.life / p.maxLife);
      canvas.drawCircle(Offset(p.x, p.y), 4 * (p.life / p.maxLife), paint);
    }
    
    // Restore world camera
    canvas.restore();

    // --- SPOTLIGHT EFFECT ---
    if (engine.isSpotlightLevel) {
      final double screenPx = engine.player.rect.x + engine.player.rect.w / 2 - engine.cameraX;
      final double screenPy = engine.player.rect.y + engine.player.rect.h / 2;
      
      final Rect bgRect = Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight);
      
      canvas.saveLayer(bgRect, Paint());
      canvas.drawRect(bgRect, Paint()..color = const Color(0xE6030305)); // 90% opacity black

      final Paint holePaint = Paint()
        ..blendMode = BlendMode.clear
        ..shader = RadialGradient(
          colors: [Colors.transparent, const Color(0xE6030305)],
          stops: [0.15, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(screenPx, screenPy), radius: 250));
      
      canvas.drawCircle(Offset(screenPx, screenPy), 250, holePaint);
      canvas.restore();
    }

    // --- TIME FREEZE EFFECT ---
    if (engine.isTimeFreezeLevel) {
      bool playerIsMoving = engine.player.vx.abs() > 5 || engine.player.vy.abs() > 5 || engine.movingLeft || engine.movingRight || engine.jumping;
      final Rect bgRect = Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight);
      
      Paint freezePaint = Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          colors: [
            Colors.transparent, 
            playerIsMoving ? const Color(0x3300AAFF) : const Color(0x6600AAFF)
          ],
          stops: [0.5, 1.0],
        ).createShader(bgRect);
        
      canvas.drawRect(bgRect, freezePaint);
      
      if (!playerIsMoving && !engine.isDead && !engine.roundWon) {
        TextSpan span = const TextSpan(style: TextStyle(color: Color(0xFF00AAFF), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4), text: "TIME FROZEN");
        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(engine.logicalWidth/2 - tp.width/2, 50));
      }
    }

    
    // --- LAVA EFFECT ---
    if (engine.isLavaLevel) {
      double lavaScreenY = engine.lavaY; // lava is static in world, wait, screen space?
      // No, world space! Need to apply camera.
      canvas.save();
      canvas.translate(-engine.cameraX, 0);
      Paint lavaPaint = Paint()..color = const Color(0xDDFF3300);
      canvas.drawRect(Rect.fromLTWH(engine.cameraX - 500, engine.lavaY, 2000, 800), lavaPaint);
      lavaPaint.color = const Color(0xFFFF8800);
      canvas.drawRect(Rect.fromLTWH(engine.cameraX - 500, engine.lavaY, 2000, 10), lavaPaint);
      canvas.restore();
    }
    
    // --- BLINK EFFECT ---
    if (engine.isBlinkLevel) {
       if (engine.blinkTimer % 3.5 > 2.5) { // 2.5s visible, 1.0s pitch black
         Paint blinkPaint = Paint()..color = Colors.black;
         canvas.drawRect(Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight), blinkPaint);
       }
    }

    // UI Layer (overlay, text, wipe)
    if (engine.isDead) {
      paint.color = Colors.black.withOpacity(1.0 - engine.deathTimer);
      canvas.drawRect(Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight), paint);
    }

    if (engine.roundWon) {
      double r = 800 * (1.0 - engine.transitionTimer);
      if (r < 0) r = 0;
      
      // Calculate screen position of player
      double screenX = engine.player.rect.x - engine.cameraX;
      double screenY = engine.player.rect.y;

      var path = Path()
        ..addRect(Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight))
        ..addOval(Rect.fromCircle(
            center: Offset(screenX + 20, screenY + 20), 
            radius: r))
        ..fillType = PathFillType.evenOdd;
      paint.color = const Color(0xFF07080A);
      canvas.drawPath(path, paint);
    }
    // Removed ROUND text to keep the player surprised
    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final Rect bgRect = Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight);
    
    Color gradStart, gradEnd, moonColor, backMount, frontMount;

    if (engine.round >= 58) {
      // C20: Absolute Chaos
      gradStart = const Color(0xFF220000); gradEnd = const Color(0xFF000000); moonColor = const Color(0xFFFF0000); backMount = const Color(0xFF110000); frontMount = const Color(0xFF050000);
    } else if (engine.round >= 55) {
      // C19: Mirror Mode
      gradStart = const Color(0xFF333333); gradEnd = const Color(0xFF111111); moonColor = const Color(0xFFFFFFFF); backMount = const Color(0xFF222222); frontMount = const Color(0xFF0A0A0A);
    } else if (engine.round >= 52) {
      // C18: Blinking
      gradStart = const Color(0xFF000022); gradEnd = const Color(0xFF000000); moonColor = const Color(0xFF0000FF); backMount = const Color(0xFF000011); frontMount = const Color(0xFF000005);
    } else if (engine.round >= 49) {
      // C17: Slippery Ice
      gradStart = const Color(0xFFCCFFFF); gradEnd = const Color(0xFF88CCFF); moonColor = const Color(0xFFFFFFFF); backMount = const Color(0xFF66AADD); frontMount = const Color(0xFF4488BB);
    } else if (engine.round >= 46) {
      // C16: Wind
      gradStart = const Color(0xFF88AA88); gradEnd = const Color(0xFF446644); moonColor = const Color(0xFFAAFFCC); backMount = const Color(0xFF335533); frontMount = const Color(0xFF112211);
    } else if (engine.round >= 43) {
      // C15: Dash
      gradStart = const Color(0xFF550055); gradEnd = const Color(0xFF220022); moonColor = const Color(0xFFFF00FF); backMount = const Color(0xFF330033); frontMount = const Color(0xFF110011);
    } else if (engine.round >= 40) {
      // C14: Tiny
      gradStart = const Color(0xFF005500); gradEnd = const Color(0xFF002200); moonColor = const Color(0xFF00FF00); backMount = const Color(0xFF003300); frontMount = const Color(0xFF001100);
    } else if (engine.round >= 37) {
      // C13: Flappy
      gradStart = const Color(0xFF005555); gradEnd = const Color(0xFF002222); moonColor = const Color(0xFF00FFFF); backMount = const Color(0xFF003333); frontMount = const Color(0xFF001111);
    } else if (engine.round >= 34) {
      // C12: Low Gravity
      gradStart = const Color(0xFF555555); gradEnd = const Color(0xFF222222); moonColor = const Color(0xFFCCCCCC); backMount = const Color(0xFF333333); frontMount = const Color(0xFF111111);
    } else if (engine.round >= 31) {
      // C11: Lava
      gradStart = const Color(0xFF440000); gradEnd = const Color(0xFF220000); moonColor = const Color(0xFFFF5500); backMount = const Color(0xFF330000); frontMount = const Color(0xFF110000);
    } else if (engine.round >= 28) {

      // C10: Void Purple
      gradStart = const Color(0xFF330033);
      gradEnd = const Color(0xFF000000);
      moonColor = const Color(0xFFFF00FF);
      backMount = const Color(0xFF1A001A);
      frontMount = const Color(0xFF0D000D);
    } else if (engine.round >= 25) {
      // C9: Industrial Orange
      gradStart = const Color(0xFF442200);
      gradEnd = const Color(0xFF110500);
      moonColor = const Color(0xFFFF6600);
      backMount = const Color(0xFF331100);
      frontMount = const Color(0xFF1A0800);
    } else if (engine.round >= 22) {
      // C8: Pitch Black / Blood Red
      gradStart = const Color(0xFF110000);
      gradEnd = const Color(0xFF000000);
      moonColor = const Color(0xFFFF0000);
      backMount = const Color(0xFF0A0000);
      frontMount = const Color(0xFF050000);
    } else if (engine.round >= 19) {
      // C7: Teal / Ocean
      gradStart = const Color(0xFF003344);
      gradEnd = const Color(0xFF001122);
      moonColor = const Color(0xFF00FFCC);
      backMount = const Color(0xFF002233);
      frontMount = const Color(0xFF000A11);
    } else if (engine.round >= 16) {
      // C6: Golden / Amber
      gradStart = const Color(0xFF553311);
      gradEnd = const Color(0xFF221100);
      moonColor = const Color(0xFFFFCC00);
      backMount = const Color(0xFF331A00);
      frontMount = const Color(0xFF1A0D00);
    } else if (engine.round >= 13) {
      // C5: Ice Blue
      gradStart = const Color(0xFF004466);
      gradEnd = const Color(0xFF001133);
      moonColor = const Color(0xFFBBE4FF);
      backMount = const Color(0xFF003355);
      frontMount = const Color(0xFF001122);
    } else if (engine.round >= 10) {
      // C4: Glitch Purple
      gradStart = const Color(0xFF4A148C);
      gradEnd = const Color(0xFF1A0033);
      moonColor = const Color(0xFFFF00FF);
      backMount = const Color(0xFF2A0D45);
      frontMount = const Color(0xFF110422);
    } else if (engine.round >= 7) {
      // C3: Hacker Green
      gradStart = const Color(0xFF004411);
      gradEnd = const Color(0xFF001A00);
      moonColor = const Color(0xFF00FF44);
      backMount = const Color(0xFF003311);
      frontMount = const Color(0xFF001A05);
    } else if (engine.round >= 4) {
      // C2: Crimson Red
      gradStart = const Color(0xFF7A1C2C);
      gradEnd = const Color(0xFF3A0D16);
      moonColor = const Color(0xFFFF1133);
      backMount = const Color(0xFF4A0F1B);
      frontMount = const Color(0xFF1F060A);
    } else {
      // C1: Twilight Blue
      gradStart = const Color(0xFF3B3B6D);
      gradEnd = const Color(0xFF1A1A3A);
      moonColor = const Color(0xFF00E5FF);
      backMount = const Color(0xFF1D2645);
      frontMount = const Color(0xFF0E1428);
    }

    Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradStart, gradEnd],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Parallax values
    double moonX = 400 - (engine.cameraX * 0.05);
    double backMountainOffset = -(engine.cameraX * 0.2) % 800;
    double frontMountainOffset = -(engine.cameraX * 0.5) % 800;
    
    Paint paint = Paint();

    // Glowing Moon
    paint.color = moonColor.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(Offset(moonX, 300), 100, paint);
    paint.color = moonColor.withOpacity(0.6);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(moonX, 300), 60, paint);
    paint.maskFilter = null;

    // Back Mountains (drawn twice for seamless tiling)
    paint.color = backMount;
    for (int i = 0; i < 2; i++) {
      double startX = backMountainOffset + (i * 800);
      var path = Path()
        ..moveTo(startX, 600)
        ..lineTo(startX, 300)
        ..lineTo(startX + 200, 150)
        ..lineTo(startX + 450, 400)
        ..lineTo(startX + 600, 200)
        ..lineTo(startX + 800, 350)
        ..lineTo(startX + 800, 600)
        ..close();
      canvas.drawPath(path, paint);
    }

    // Front Mountains (drawn twice for seamless tiling)
    paint.color = frontMount;
    for (int i = 0; i < 2; i++) {
      double startX = frontMountainOffset + (i * 800);
      var path = Path()
        ..moveTo(startX, 600)
        ..lineTo(startX, 450)
        ..lineTo(startX + 300, 250)
        ..lineTo(startX + 550, 450)
        ..lineTo(startX + 800, 300)
        ..lineTo(startX + 800, 600)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawGrid(Canvas canvas) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..strokeWidth = 1;
    // Extend grid to maxMapWidth
    for(double i=0; i<=engine.maxMapWidth; i+=40) {
      canvas.drawLine(Offset(i, 0), Offset(i, 600), paint);
    }
    for(double i=0; i<=600; i+=40) {
      canvas.drawLine(Offset(0, i), Offset(engine.maxMapWidth, i), paint);
    }
  }

  void _drawSpike(Canvas canvas, RectD rect, Color color, bool inverted) {
    var paint = Paint()..color = color;
    var path = Path();
    
    if (inverted) { 
      path.moveTo(rect.x, rect.y);
      path.lineTo(rect.x + rect.w, rect.y);
      path.lineTo(rect.x + rect.w / 2, rect.y + rect.h);
    } else { // Floor spike, point UP.
      path.moveTo(rect.x + rect.w / 2, rect.y);
      path.lineTo(rect.x + rect.w, rect.y + rect.h);
      path.lineTo(rect.x, rect.y + rect.h);
    }
    
    path.close();
    
    // Add glow
    paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawPath(path, paint);
    paint.maskFilter = null;
    canvas.drawPath(path, paint);
  }

  void _drawRightSpike(Canvas canvas, RectD rect, Color color) {
    var paint = Paint()..color = color;
    var path = Path();
    
    path.moveTo(rect.x, rect.y);
    path.lineTo(rect.x + rect.w, rect.y + rect.h / 2);
    path.lineTo(rect.x, rect.y + rect.h);
    path.close();
    
    paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawPath(path, paint);
    paint.maskFilter = null;
    canvas.drawPath(path, paint);
  }

  void _drawDoor(Canvas canvas, RectD rect, Color color) {
    var paint = Paint()..color = color;
    var r = RRect.fromRectAndRadius(rect.toRect(), const Radius.circular(8));
    canvas.drawRRect(r, paint);
    paint.color = const Color(0xFF07080A);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(rect.x + 5, rect.y + 5, rect.w - 10, rect.h - 5), 
      const Radius.circular(6)
    ), paint);
    paint.color = color.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawRRect(r, paint);
    paint.maskFilter = null;
  }

  void _drawPlayer(Canvas canvas, TrollEntity p, {double opacity = 1.0}) {
    var paint = Paint()..color = p.color.withOpacity(opacity);
    
    canvas.save();
    canvas.translate(p.rect.x + p.rect.w/2, p.rect.y + p.rect.h/2);
    canvas.scale(engine.playerScale, engine.playerScale);
    
    if (engine.isGravityInverted && opacity == 1.0) { // Flip only actual player upside down
      canvas.scale(1.0, -1.0);
    }
    
    canvas.translate(-(p.rect.x + p.rect.w/2), -(p.rect.y + p.rect.h/2));

    var r = RRect.fromRectAndRadius(p.rect.toRect(), const Radius.circular(6));
    canvas.drawRRect(r, paint);
    
    paint.color = p.color.withOpacity(0.4 * opacity);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(r, paint);
    paint.maskFilter = null;

    paint.color = const Color(0xFF07080A);
    double eyeOffset = engine.playerFaceDir * 4;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(p.rect.x + 8 + eyeOffset, p.rect.y + 8, 4, 8), 
      const Radius.circular(2)
    ), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(p.rect.x + 18 + eyeOffset, p.rect.y + 8, 4, 8), 
      const Radius.circular(2)
    ), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrollPainter oldDelegate) => true;
}
