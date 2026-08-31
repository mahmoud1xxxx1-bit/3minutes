// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, non_constant_identifier_names, empty_catches, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;

import '../../domain/mini_game_contract.dart';
import 'advanced_traffic_engine.dart';
import 'dart:math';
import '../shared/minigame_environment.dart';

class TrafficLoopGame extends StatefulWidget {
  const TrafficLoopGame({
    super.key,
    required this.config,
    required this.onComplete,
    this.trackId = 1,
  });
  final MiniGameConfig config;
  final void Function(MiniGameResult) onComplete;
  final int trackId;

  @override
  State<TrafficLoopGame> createState() => _TrafficLoopGameState();
}

class _TrafficLoopGameState extends State<TrafficLoopGame>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late FlawlessTrafficEngine _engine;
  Duration _lastTime = Duration.zero;

  final int _maxRounds = 3;
  int _currentRound = 1;
  int _totalCorrect = 0;
  int _totalMistakes = 0;

  late DateTime _startTime;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initEngine();
    _ticker = createTicker(_onTick)..start();
  }

  void _initEngine() {
    _lastCorrect = 0;
    _lastMistakes = 0;
    int goal = _currentRound == 1
        ? 10
        : _currentRound == 2
        ? 15
        : 20;
    _engine = FlawlessTrafficEngine(
      goal: goal,
      seed: widget.config.seed ^ _currentRound,
      trackId: 1,
      round: _currentRound,
    );
  }

  bool _isTransitioning = false;
  double _transitionTimer = 0.0;
  bool _didSwap = false;

  int _lastCorrect = 0;
  int _lastMistakes = 0;

  void _onTick(Duration elapsed) {
    if (_finished) return;

    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    if (!mounted) return;
    final timeElapsed = DateTime.now().difference(_startTime).inMilliseconds;
    MinigameEnvironment.of(
      context,
    ).updateTimeProgress((timeElapsed / 30000).clamp(0.0, 1.0));

    setState(() {
      if (!_isTransitioning) {
        _engine.update(dt);

        if (_engine.correct > _lastCorrect) {
          MinigameEnvironment.of(
            context,
          ).updateScore(_totalCorrect + _engine.correct);
          MinigameEnvironment.of(context).playSuccess(Offset.zero);
          _lastCorrect = _engine.correct;
        }
        if (_engine.mistakes > _lastMistakes) {
          MinigameEnvironment.of(context).playError(Offset.zero);
          _lastMistakes = _engine.mistakes;
        }

        if (_engine.isRoundComplete) {
          _isTransitioning = true;
          _transitionTimer = 0.0;
          _totalCorrect += _engine.correct;
          _totalMistakes += _engine.mistakes;
        }
      } else {
        if (_transitionTimer < 1.0) {
          _engine.update(dt);
        }

        _transitionTimer += dt;
        if (_transitionTimer >= 1.5 && !_didSwap) {
          _didSwap = true;
          if (_currentRound < _maxRounds) {
            _currentRound++;
            _initEngine();
          } else {
            _finishGame();
            return;
          }
        }
        if (_transitionTimer >= 2.0) {
          _isTransitioning = false;
          _didSwap = false;
        }
      }
    });
  }

  void _finishGame() {
    _finished = true;
    _ticker.stop();
    final duration = DateTime.now().difference(_startTime);
    final accuracy = _totalMistakes == 0
        ? 1.0
        : (_totalCorrect / (_totalCorrect + _totalMistakes));

    int score = (accuracy * 1000).toInt();

    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: score,
        accuracy: accuracy,
        mistakes: _totalMistakes,
        duration: duration,
      ),
    );
  }

  void _handleTap() {
    if (_finished) return;
    if (_engine.tap()) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: _engine.crashFlash > 0 ? 8.0 : 0.0),
              duration: const Duration(milliseconds: 50),
              builder: (context, shake, child) {
                return Transform.translate(
                  offset: Offset(
                    shake * (Random().nextDouble() - 0.5),
                    shake * (Random().nextDouble() - 0.5),
                  ),
                  child: CustomPaint(
                    painter: _TrafficPainter(
                      _engine,
                      _isTransitioning ? _transitionTimer : 0.0,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),
            if (_engine.nearMissTimer > 0)
              Positioned(
                top: 60,
                child: Opacity(
                  opacity: (_engine.nearMissTimer / 2.0).clamp(0.0, 1.0),
                  child: const Text(
                    'Close Call!',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                    ),
                  ),
                ),
              ),
            if (_engine.comboTimer > 0)
              Positioned(
                top: 100,
                child: Opacity(
                  opacity: (_engine.comboTimer / 3.0).clamp(0.0, 1.0),
                  child: Text(
                    '${_engine.comboCount}x COMBO!',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(color: Colors.blueAccent, blurRadius: 15),
                        Shadow(color: Colors.white, blurRadius: 5),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted
// deleted

class _TrafficPainter extends CustomPainter {
  _TrafficPainter(this.engine, this.transitionTimer);
  final FlawlessTrafficEngine engine;
  final double transitionTimer;

  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + 15.0),
          paint,
        );
        distance += 35.0;
      }
    }
  }

  void _drawArrows(Canvas canvas, ui.PathMetric metric) {
    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (double s = 50; s < metric.length; s += 200) {
      final tangent = metric.getTangentForOffset(s);
      if (tangent != null) {
        canvas.save();
        canvas.translate(tangent.position.dx, tangent.position.dy);
        canvas.rotate(tangent.angle);
        final arrowPath = Path()
          ..moveTo(10, 0)
          ..lineTo(-10, -10)
          ..lineTo(-5, 0)
          ..lineTo(-10, 10)
          ..close();
        canvas.drawPath(arrowPath, arrowPaint);
        canvas.restore();
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Color bg1, bg2, trOuter, trInner, dshColor;
    if (engine.trackId <= 5) {
      bg1 = const Color(0xFF1A1D27);
      bg2 = const Color(0xFF13151C);
      trOuter = const Color(0xFF282D3D);
      trInner = const Color(0xFF343A4E);
      dshColor = Colors.white.withOpacity(0.2);
    } else if (engine.trackId <= 10) {
      bg1 = const Color(0xFF221128);
      bg2 = const Color(0xFF14081A);
      trOuter = const Color(0xFF2D1B36);
      trInner = const Color(0xFF452754);
      dshColor = const Color(0xFFE893FF).withOpacity(0.2);
    } else if (engine.trackId <= 15) {
      bg1 = const Color(0xFF2B1410);
      bg2 = const Color(0xFF1A0A08);
      trOuter = const Color(0xFF3D1E16);
      trInner = const Color(0xFF5C291A);
      dshColor = const Color(0xFFFF9D80).withOpacity(0.2);
    } else {
      bg1 = const Color(0xFF0D2418);
      bg2 = const Color(0xFF07140C);
      trOuter = const Color(0xFF133621);
      trInner = const Color(0xFF1D5434);
      dshColor = const Color(0xFF80FFB3).withOpacity(0.2);
    }

    Color toGray(Color c) {
      int gray = ((c.red + c.green + c.blue) / 3).round();
      Color g = Color.fromARGB(c.alpha, gray, gray, gray);
      return Color.lerp(c, g, engine.grayscaleFraction)!;
    }

    bg1 = toGray(bg1);
    bg2 = toGray(bg2);
    trOuter = toGray(trOuter);
    trInner = toGray(trInner);
    dshColor = toGray(dshColor);

    final double scaleX = size.width / 800.0;
    final double scaleY = size.height / 600.0;
    final double baseScale = min(scaleX, scaleY);

    canvas.save();
    canvas.translate(
      (size.width - 800 * baseScale) / 2,
      (size.height - 600 * baseScale) / 2,
    );
    canvas.scale(baseScale);

    // Draw full background
    final Rect bgRect = const Rect.fromLTWH(0, 0, 800, 600);
    final gradient = RadialGradient(colors: [bg1, bg2], radius: 0.8);
    canvas.drawRect(bgRect, Paint()..shader = gradient.createShader(bgRect));

    if (engine.cameraZoom < 1.0) {
      canvas.translate(400, 250);
      canvas.scale(engine.cameraZoom, engine.cameraZoom);
      canvas.translate(-400, -250);
    }

    // Highly optimized skid marks drawing
    for (var skid in engine.skids) {
      final p = Paint()
        ..color = Colors.black.withOpacity(skid.alpha)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(skid.position.dx, skid.position.dy);
      canvas.rotate(skid.heading);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, -9), width: 14, height: 4),
          const Radius.circular(2),
        ),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, 9), width: 14, height: 4),
          const Radius.circular(2),
        ),
        p,
      );
      canvas.restore();
    }

    final trackOuterPaint = Paint()
      ..color = trOuter
      ..style = PaintingStyle.stroke
      ..strokeWidth = 75.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trackPaint = Paint()
      ..color = trInner
      ..style = PaintingStyle.stroke
      ..strokeWidth = 65.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashPaint = Paint()
      ..color = dshColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(engine.entrancePath, trackOuterPaint);
    canvas.drawPath(engine.loopPath, trackOuterPaint);

    canvas.drawPath(engine.entrancePath, trackPaint);
    canvas.drawPath(engine.loopPath, trackPaint);

    drawDashedPath(canvas, engine.entrancePath, dashPaint);
    drawDashedPath(canvas, engine.loopPath, dashPaint);

    _drawArrows(canvas, engine.loopMetric);
    _drawArrows(canvas, engine.entranceMetric);



    ui.Tangent? tStop = engine.entranceMetric.getTangentForOffset(
      engine.stopLineS,
    );
    if (tStop != null) {
      canvas.save();
      canvas.translate(tStop.position.dx, tStop.position.dy);
      canvas.rotate(tStop.angle);

      final startLinePaint = Paint()
        ..color = toGray(Colors.white.withOpacity(0.8))
        ..style = PaintingStyle.fill;

      for (double y = -30; y < 30; y += 8) {
        canvas.drawRect(Rect.fromLTWH(-4, y, 8, 4), startLinePaint);
      }

      if (engine.lineGlow > 0) {
        final glowLinePaint = Paint()
          ..color = engine.lineGlowColor.withOpacity(engine.lineGlow * 0.8)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..strokeWidth = 6;
        canvas.drawLine(
          const Offset(-8, -32),
          const Offset(-8, 32),
          glowLinePaint,
        );
      }

      canvas.restore();
    }

    int remaining = engine.goal - engine.correct;
    if (remaining < 0) remaining = 0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$remaining',
        style: TextStyle(
          color: engine.crashFlash > 0
              ? Colors.redAccent.withOpacity(0.4 + engine.crashFlash * 0.4)
              : Colors.white.withOpacity(0.15),
          fontSize: 160,
          fontWeight: FontWeight.w900,
          shadows: engine.crashFlash > 0
              ? [
                  Shadow(
                    color: Colors.redAccent,
                    blurRadius: 20 * engine.crashFlash,
                  ),
                ]
              : [],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(400 - textPainter.width / 2, 250 - textPainter.height / 2),
    );

    void _drawCar(
      Canvas c,
      Offset pos,
      double heading,
      Color color,
      double alpha,
      bool isMoving,
      double brakeAlpha,
    ) {
      c.save();
      c.translate(pos.dx, pos.dy);
      c.rotate(heading);

      final double clen = 32.0;
      final double cw = 18.0;

      if (alpha == 1.0 && isMoving) {
        final tailPaint = Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, 0),
            Offset(-clen * 1.5, 0),
            [color.withOpacity(0.6), color.withOpacity(0.0)],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        c.drawRect(
          Rect.fromLTWH(-clen * 1.5, -cw / 2 + 2, clen * 1.5, cw - 4),
          tailPaint,
        );
      }

      final wheelPaint = Paint()
        ..color = const Color(0xFF0A0A0E).withOpacity(alpha);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(-9, -10), width: 10, height: 4),
          const Radius.circular(2),
        ),
        wheelPaint,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(-9, 10), width: 10, height: 4),
          const Radius.circular(2),
        ),
        wheelPaint,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(9, -10), width: 10, height: 4),
          const Radius.circular(2),
        ),
        wheelPaint,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(9, 10), width: 10, height: 4),
          const Radius.circular(2),
        ),
        wheelPaint,
      );

      if (alpha == 1.0) {
        final glowPaint = Paint()
          ..color = color.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: clen, height: cw),
            const Radius.circular(6),
          ),
          glowPaint,
        );
      }

      final carPaint = Paint()..color = color.withOpacity(alpha);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: clen, height: cw),
          const Radius.circular(6),
        ),
        carPaint,
      );

      final roofPaint = Paint()
        ..color = const Color(0xFF13151C).withOpacity(alpha);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(0, 0),
            width: 16,
            height: cw - 6,
          ),
          const Radius.circular(3),
        ),
        roofPaint,
      );

      final spoilerPaint = Paint()
        ..color = const Color(0xFF0A0A0E).withOpacity(alpha);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: const Offset(-14, 0),
            width: 4,
            height: cw - 4,
          ),
          const Radius.circular(1),
        ),
        spoilerPaint,
      );

      final headlightPaint = Paint()..color = Colors.white.withOpacity(alpha);
      c.drawCircle(const Offset(13, -5), 2.5, headlightPaint);
      c.drawCircle(const Offset(13, 5), 2.5, headlightPaint);

      // Brake Lights (Lightweight)
      if (brakeAlpha > 0) {
        final brakePaint = Paint()
          ..color = Colors.redAccent.withOpacity(brakeAlpha * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        c.drawCircle(const Offset(-15, -6), 3.0, brakePaint);
        c.drawCircle(const Offset(-15, 6), 3.0, brakePaint);
      }

      if (alpha == 1.0 && isMoving) {
        final beamPaint = Paint()
          ..shader = ui.Gradient.linear(
            const Offset(13, 0),
            Offset(clen * 2, 0),
            [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)],
          );
        c.drawPath(
          Path()
            ..moveTo(13, -6)
            ..lineTo(clen * 2, -15)
            ..lineTo(clen * 2, 15)
            ..lineTo(13, 6)
            ..close(),
          beamPaint,
        );
      }

      c.restore();
    }

    // Wrecks are fully opaque and permanent now (alpha = 1.0)
    for (var dc in engine.destroyedCars) {
      _drawCar(canvas, dc.position, dc.heading, dc.color, 1.0, false, 0.0);
    }

    if (engine.comboTimer > 0) {
      double alpha = (engine.comboTimer / 3.0).clamp(0.0, 1.0);
      final trailPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(alpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);

      for (var car in engine.cars) {
        if (car.type == CarType.player && car.lane == CarLane.loop) {
          double start = car.s - 80.0;
          double end = car.s;
          if (start < 0) {
            Path p1 = engine.loopMetric.extractPath(
              engine.loopMetric.length + start,
              engine.loopMetric.length,
            );
            Path p2 = engine.loopMetric.extractPath(0, end);
            canvas.drawPath(p1, trailPaint);
            canvas.drawPath(p2, trailPaint);
          } else {
            Path p = engine.loopMetric.extractPath(start, end);
            canvas.drawPath(p, trailPaint);
          }
        }
      }
    }

    for (var car in engine.cars) {
      Color cColor = car.isCrashed ? car.color : toGray(car.color);
      _drawCar(
        canvas,
        car.position,
        car.heading,
        cColor,
        1.0,
        car.velocity > 5.0,
        car.brakeAlpha,
      );
    }

    for (var p in engine.particles) {
      final pPaint = Paint()..color = p.color;
      final pPath = Path()
        ..moveTo(p.position.dx, p.position.dy - 3)
        ..lineTo(p.position.dx - 3, p.position.dy + 3)
        ..lineTo(p.position.dx + 3, p.position.dy + 3)
        ..close();
      canvas.drawPath(pPath, pPaint);
    }

    // Draw weather particles
    for (var w in engine.weather) {
      canvas.drawCircle(w.position, w.size, Paint()..color = toGray(w.color));
    }

    canvas.restore();

    // Draw transition over EVERYTHING
    if (transitionTimer > 1.0) {
      double t = transitionTimer < 1.5
          ? (transitionTimer - 1.0) / 0.5
          : (2.0 - transitionTimer) / 0.5;

      t = t.clamp(0.0, 1.0);

      int cols = 16;
      int rows = 12;
      double sqW = size.width / cols;
      double sqH = size.height / rows;

      var paint = Paint();
      for (int i = 0; i < cols; i++) {
        for (int j = 0; j < rows; j++) {
          paint.color = (i + j) % 2 == 0 ? Colors.black : Colors.white;

          double delay = (i + j) / (cols + rows) * 0.5;
          double localT = (t - delay) / 0.5;
          localT = localT.clamp(0.0, 1.0);
          localT = 1.0 - pow(1.0 - localT, 3).toDouble();

          if (localT > 0) {
            double cx = i * sqW + sqW / 2;
            double cy = j * sqH + sqH / 2;
            double w = sqW * localT;
            double h = sqH * localT;
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset(cx, cy),
                width: w + 1,
                height: h + 1,
              ),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrafficPainter oldDelegate) => true;
}

