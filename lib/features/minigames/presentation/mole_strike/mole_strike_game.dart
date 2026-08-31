import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../domain/mini_game_contract.dart';
import '../shared/minigame_environment.dart';

enum HitResult { hit, golden, decoy, miss }

class MalletStrike {
  double x, y, life, maxLife;
  MalletStrike({
    required this.x,
    required this.y,
    required this.life,
    required this.maxLife,
  });
  void update(double dt) => life -= dt;
}

class Particle {
  double x, y, vx, vy, life, maxLife, size;
  Color color;
  bool isSmoke;
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.color,
    this.isSmoke = false,
  });
  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    if (!isSmoke) vy += 800 * dt;
    life -= dt;
  }
}

class FloatingText {
  double x, y, life, maxLife;
  String text;
  Color color;
  FloatingText({
    required this.x,
    required this.y,
    required this.life,
    required this.maxLife,
    required this.text,
    required this.color,
  });
  void update(double dt) {
    y -= 80 * dt;
    life -= dt;
  }
}

class MoleStrikeGame extends StatefulWidget {
  final MiniGameConfig config;
  final Function(MiniGameResult) onComplete;
  const MoleStrikeGame({
    super.key,
    required this.config,
    required this.onComplete,
  });
  @override
  State<MoleStrikeGame> createState() => _MoleStrikeGameState();
}

class _MoleStrikeGameState extends State<MoleStrikeGame>
    with TickerProviderStateMixin {
  final List<GlobalKey<_MoleSlotState>> _slotKeys = List.generate(
    12,
    (i) => GlobalKey<_MoleSlotState>(),
  );
  Timer? _gameLoop;
  int _score = 0;
  int _mistakes = 0;
  int _combo = 0;
  late AnimationController _shakeController;
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  final List<MalletStrike> _mallets = [];
  bool _isDone = false;
  late math.Random _rng;
  late Stopwatch _watch;

  @override
  void initState() {
    super.initState();
    _rng = math.Random(widget.config.seed);
    _watch = Stopwatch()..start();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeController.addListener(() => setState(() {}));
    _ticker = createTicker(_onTick)..start();
    _startGame();
  }

  void _startGame() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 650), (timer) {
      if (!mounted || _isDone) return;
      int r = _rng.nextInt(12);
      bool isGolden = _rng.nextDouble() < 0.1;
      bool isDecoy = _rng.nextDouble() < 0.15;
      bool isArmored = (!isDecoy && !isGolden) && _rng.nextDouble() < 0.3;
      _slotKeys[r].currentState?.trigger(
        isDecoy: isDecoy,
        isGolden: isGolden,
        isArmored: isArmored,
      );
    });
  }

  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) _lastTime = elapsed;
    double dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    if (!mounted) return;

    if (_watch.elapsedMilliseconds > 30000 && !_isDone) {
      _finishGame();
    }

    if (_mallets.isNotEmpty) {
      for (var m in _mallets) {
        m.update(dt);
      }
      _mallets.removeWhere((m) => m.life <= 0);
      setState(() {});
    }
  }

  void _finishGame() {
    setState(() => _isDone = true);
    _gameLoop?.cancel();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      widget.onComplete(
        MiniGameResult(
          completed: _score > 0,
          score: _score,
          accuracy: 1.0,
          mistakes: _mistakes,
          duration: const Duration(seconds: 30),
        ),
      );
    });
  }

  void _handleHit(int index, HitResult result, Offset globalPos) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPos = box.globalToLocal(globalPos);

    setState(() {
      _mallets.add(
        MalletStrike(
          x: localPos.dx,
          y: localPos.dy - 30,
          life: 0.15,
          maxLife: 0.15,
        ),
      );

      if (result == HitResult.decoy) {
        _score -= 100;
        _combo = 0;
        _mistakes++;
        _shakeController.forward(from: 0);
        try {
          MinigameEnvironment.of(context).playError(globalPos);
        } catch (_) {}
      } else if (result == HitResult.hit) {
        _combo++;
        _score += 50 * _combo;
        try {
          MinigameEnvironment.of(context).playSuccess(globalPos);
        } catch (_) {}
      } else if (result == HitResult.golden) {
        _combo += 2;
        _score += 200 * _combo;
        try {
          MinigameEnvironment.of(context).playSuccess(globalPos);
        } catch (_) {}
      }

      MinigameEnvironment.of(context).updateScore(_score, newCombo: _combo);
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _shakeController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  Widget _buildMallet(MalletStrike m) {
    double angle = (1.0 - m.life) * math.pi / 2;
    return Transform.rotate(
      angle: angle,
      alignment: Alignment.bottomRight,
      child: CustomPaint(size: const Size(80, 80), painter: _MalletPainter()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double shake =
        math.sin(_shakeController.value * math.pi * 6) *
        10 *
        (1 - _shakeController.value);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Mistakes: $_mistakes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _mistakes > 0 ? Colors.redAccent : Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: Transform.translate(
              offset: Offset(shake, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double boardSize = math.min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  boardSize = math.min(boardSize * 0.9, 600);
                  return Container(
                    width: boardSize,
                    height: boardSize,
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return MoleSlot(
                          key: _slotKeys[index],
                          onHit: (res) {
                            RenderBox box =
                                _slotKeys[index].currentContext!
                                        .findRenderObject()
                                    as RenderBox;
                            Offset pos = box.localToGlobal(
                              Offset(box.size.width / 2, box.size.height / 2),
                            );
                            _handleHit(index, res, pos);
                          },
                          getCombo: () => _combo,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          for (var m in _mallets)
            Positioned(left: m.x - 40, top: m.y - 40, child: _buildMallet(m)),
        ],
      ),
    );
  }
}

class _MalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint handle = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(const Rect.fromLTWH(35, 20, 10, 60), handle);
    Paint head = Paint()..color = const Color(0xFFD22B2B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 10, 60, 25),
        const Radius.circular(8),
      ),
      head,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MoleSlot extends StatefulWidget {
  final Function(HitResult) onHit;
  final int Function() getCombo;
  const MoleSlot({super.key, required this.onHit, required this.getCombo});
  @override
  State<MoleSlot> createState() => _MoleSlotState();
}

class _MoleSlotState extends State<MoleSlot> with TickerProviderStateMixin {
  bool _isDecoy = false;
  bool _isGolden = false;
  bool _isArmored = false;
  int _hitsToKill = 1;
  bool _isActive = false;
  bool _isWarning = false;
  bool _isSquashed = false;

  late AnimationController _riseController;
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;
  final List<Particle> _particles = [];
  final List<FloatingText> _floatingTexts = [];

  @override
  void initState() {
    super.initState();
    _riseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _riseController.addListener(() => setState(() {}));
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _riseController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) _lastTime = elapsed;
    double dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    bool needsSetState = false;
    if (_particles.isNotEmpty) {
      for (var p in _particles) {
        p.update(dt);
      }
      _particles.removeWhere((p) => p.life <= 0);
      needsSetState = true;
    }
    if (_floatingTexts.isNotEmpty) {
      for (var f in _floatingTexts) {
        f.update(dt);
      }
      _floatingTexts.removeWhere((f) => f.life <= 0);
      needsSetState = true;
    }
    if (needsSetState) setState(() {});
  }

  void trigger({
    required bool isDecoy,
    required bool isGolden,
    required bool isArmored,
  }) async {
    if (_isActive || _isWarning) return;

    setState(() {
      _isDecoy = isDecoy;
      _isGolden = isGolden;
      _isArmored = isArmored;
      _hitsToKill = isArmored ? 2 : 1;
      _isWarning = true;
      _isSquashed = false;
    });

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() {
      _isWarning = false;
      _isActive = true;
    });

    await _riseController.forward();

    // Exact 0.7 second window!
    int visibleTime = 700;
    await Future.delayed(Duration(milliseconds: visibleTime));

    if (!mounted || !_isActive) return;

    await _riseController.reverse();
    if (!mounted) return;

    setState(() {
      _isActive = false;
      if (!_isDecoy && !_isSquashed) {
        widget.onHit(HitResult.miss);
      }
    });
  }

  void _handleTap() {
    if (!_isActive || _isSquashed) return;

    _hitsToKill--;
    if (_hitsToKill > 0 && _isArmored) {
      // Show metal spark or clang effect
      _spawnSparks();
      try {
        MinigameEnvironment.of(context).playSuccess(Offset.zero);
      } catch (_) {}
      return;
    }

    setState(() {
      _isSquashed = true;
      _isActive = false;
      _riseController.reverse();
    });

    _spawnParticles();

    if (_isDecoy) {
      widget.onHit(HitResult.decoy);
      _spawnText("-100", Colors.redAccent);
    } else if (_isGolden) {
      widget.onHit(HitResult.golden);
      _spawnText("GOLD!", Colors.yellowAccent);
    } else {
      widget.onHit(HitResult.hit);
      _spawnText("+50", Colors.lightGreenAccent);
    }
  }

  void _spawnSparks() {
    math.Random r = math.Random();
    for (int i = 0; i < 5; i++) {
      _particles.add(
        Particle(
          x: 50,
          y: 30,
          vx: (r.nextDouble() - 0.5) * 400,
          vy: -r.nextDouble() * 300,
          life: 0.3,
          maxLife: 0.3,
          size: r.nextDouble() * 6 + 3,
          color: Colors.white,
        ),
      );
    }
  }

  void _spawnParticles() {
    math.Random r = math.Random();
    Color pc = _isGolden
        ? Colors.yellowAccent
        : (_isDecoy ? Colors.black : const Color(0xFFD97736));
    for (int i = 0; i < 10; i++) {
      _particles.add(
        Particle(
          x: 50,
          y: 50,
          vx: (r.nextDouble() - 0.5) * 300,
          vy: -r.nextDouble() * 300 - 100,
          life: 0.5 + r.nextDouble() * 0.3,
          maxLife: 0.8,
          size: r.nextDouble() * 8 + 4,
          color: pc,
        ),
      );
    }
    _particles.add(
      Particle(
        x: 50,
        y: 60,
        vx: 0,
        vy: -50,
        life: 0.5,
        maxLife: 0.5,
        size: 40,
        color: Colors.white,
        isSmoke: true,
      ),
    );
  }

  void _spawnText(String txt, Color col) {
    _floatingTexts.add(
      FloatingText(
        x: 50,
        y: 30,
        life: 1.0,
        maxLife: 1.0,
        text: txt,
        color: col,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double riseY = (1.0 - _riseController.value) * 100;
    if (_isSquashed) riseY += 30;

    return GestureDetector(
      onTapDown: (_) => _handleTap(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: -5,
            height: 45,
            child: CustomPaint(
              painter: _HoleBackPainter(isWarning: _isWarning),
            ),
          ),

          if (_isActive || _riseController.value > 0)
            Positioned(
              left: 10,
              right: 10,
              bottom: 0,
              height: 100,
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(0, riseY),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CustomPaint(
                        size: const Size(80, 100),
                        painter: _SquirrelPainter(
                          decoy: _isDecoy,
                          golden: _isGolden,
                          armored: _isArmored && _hitsToKill > 0,
                        ),
                      ),
                      if (_isSquashed)
                        Positioned(
                          top: 10,
                          right: 0,
                          child: Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size:
                                24 +
                                (widget.getCombo() * 2).clamp(0, 20).toDouble(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: -5,
            height: 45,
            child: CustomPaint(
              painter: _HoleFrontPainter(isWarning: _isWarning),
            ),
          ),

          Positioned.fill(
            child: CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                texts: _floatingTexts,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoleBackPainter extends CustomPainter {
  final bool isWarning;
  _HoleBackPainter({required this.isWarning});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dirtPaint = Paint()..color = const Color(0xFF4A3525);
    canvas.drawOval(
      Rect.fromLTWH(0, 5, size.width, size.height - 10),
      dirtPaint,
    );

    Paint abyssPaint = Paint()..color = const Color(0xFF150F0B);
    if (isWarning) {
      abyssPaint.color = Colors.redAccent.shade700;
      abyssPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    }
    canvas.drawOval(
      Rect.fromLTWH(8, 12, size.width - 12, size.height - 24),
      abyssPaint,
    );

    Paint innerDepth = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(
      Rect.fromLTWH(8, 12, size.width - 12, size.height - 24),
      innerDepth,
    );
  }

  @override
  bool shouldRepaint(covariant _HoleBackPainter oldDelegate) =>
      oldDelegate.isWarning != isWarning;
}

class _HoleFrontPainter extends CustomPainter {
  final bool isWarning;
  _HoleFrontPainter({required this.isWarning});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, size.height / 2 + 1, size.width, size.height / 2),
    );

    Paint dirtPaint = Paint()..color = const Color(0xFF4A3525);
    canvas.drawOval(
      Rect.fromLTWH(0, 5, size.width, size.height - 10),
      dirtPaint,
    );

    Paint rimPaint = Paint()
      ..color = const Color(0xFF6B4D36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(
      Rect.fromLTWH(0, 5, size.width, size.height - 10),
      rimPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HoleFrontPainter oldDelegate) =>
      oldDelegate.isWarning != isWarning;
}

class _SquirrelPainter extends CustomPainter {
  const _SquirrelPainter({
    required this.decoy,
    required this.golden,
    required this.armored,
  });
  final bool decoy;
  final bool golden;
  final bool armored;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100, sy = size.height / 100;
    canvas.save();
    canvas.scale(sx, sy);

    Color mainFurColor1 = decoy
        ? const Color(0xFF6B4C9A)
        : const Color(0xFFD97736);
    Color mainFurColor2 = decoy
        ? const Color(0xFF3B2A59)
        : const Color(0xFF8B4513);

    if (golden) {
      mainFurColor1 = const Color(0xFFFFD700);
      mainFurColor2 = const Color(0xFFB8860B);
    }

    final Paint furPaint = Paint()
      ..shader = LinearGradient(
        colors: [mainFurColor1, mainFurColor2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

    final Paint bellyPaint = Paint()
      ..shader = LinearGradient(
        colors: decoy
            ? [const Color(0xFFC4B5E3), const Color(0xFF8C7BA6)]
            : [const Color(0xFFFFECCC), const Color(0xFFE2C29A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

    final Paint darkPaint = Paint()..color = const Color(0xFF1E1E1E);
    final Paint pinkPaint = Paint()..color = const Color(0xFFF28F79);
    final Paint whitePaint = Paint()..color = Colors.white;

    Path tailPath = Path();
    if (decoy) {
      tailPath.moveTo(70, 70);
      tailPath.lineTo(100, 60);
      tailPath.lineTo(85, 40);
      tailPath.lineTo(95, 20);
      tailPath.lineTo(75, 25);
      tailPath.lineTo(60, 5);
      tailPath.lineTo(55, 30);
    } else {
      tailPath.moveTo(60, 70);
      tailPath.cubicTo(120, 70, 110, 10, 70, 20);
      tailPath.cubicTo(60, 20, 50, 40, 50, 50);
    }
    canvas.drawPath(tailPath, furPaint);

    canvas.save();
    canvas.translate(25, 25);
    canvas.rotate(-0.5);
    canvas.drawOval(const Rect.fromLTWH(-15, -15, 30, 40), furPaint);
    canvas.drawOval(const Rect.fromLTWH(-8, -8, 12, 25), pinkPaint);
    canvas.restore();
    canvas.save();
    canvas.translate(75, 25);
    canvas.rotate(0.5);
    canvas.drawOval(const Rect.fromLTWH(-15, -15, 30, 40), furPaint);
    canvas.drawOval(const Rect.fromLTWH(-8, -8, 12, 25), pinkPaint);
    canvas.restore();

    canvas.drawOval(const Rect.fromLTWH(20, 30, 60, 65), furPaint);
    canvas.drawOval(const Rect.fromLTWH(30, 45, 40, 45), bellyPaint);

    canvas.drawCircle(const Offset(35, 45), 6, darkPaint);
    canvas.drawCircle(const Offset(65, 45), 6, darkPaint);
    canvas.drawCircle(const Offset(33, 43), 2, whitePaint);
    canvas.drawCircle(const Offset(63, 43), 2, whitePaint);
    canvas.drawOval(const Rect.fromLTWH(45, 55, 10, 6), pinkPaint);

    if (golden) {
      Path crown = Path()
        ..moveTo(35, 30)
        ..lineTo(30, 10)
        ..lineTo(45, 20)
        ..lineTo(50, 5)
        ..lineTo(55, 20)
        ..lineTo(70, 10)
        ..lineTo(65, 30)
        ..close();
      canvas.drawPath(crown, Paint()..color = Colors.amberAccent);
    }

    if (armored) {
      // Draw metal helmet
      Path helmet = Path();
      helmet.addArc(const Rect.fromLTWH(20, 20, 60, 40), math.pi, math.pi);
      canvas.drawPath(helmet, Paint()..color = Colors.grey.shade400);
      canvas.drawPath(
        helmet,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.grey.shade800
          ..strokeWidth = 2,
      );
      // Helmet shine
      canvas.drawArc(
        const Rect.fromLTWH(25, 25, 50, 30),
        math.pi + 0.2,
        1.0,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white.withValues(alpha: 0.5)
          ..strokeWidth = 3,
      );
    }

    if (decoy) {
      canvas.drawCircle(const Offset(50, 75), 18, darkPaint);
      canvas.drawCircle(
        const Offset(45, 70),
        5,
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
      canvas.drawRect(
        const Rect.fromLTWH(45, 53, 10, 5),
        Paint()..color = Colors.grey,
      );
      Path fusePath = Path()
        ..moveTo(50, 53)
        ..quadraticBezierTo(60, 45, 55, 35);
      canvas.drawPath(
        fusePath,
        Paint()
          ..color = Colors.brown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.drawCircle(
        const Offset(55, 35),
        4,
        Paint()..color = Colors.orangeAccent,
      );
      canvas.drawCircle(
        const Offset(55, 35),
        2,
        Paint()..color = Colors.yellowAccent,
      );
    } else if (!decoy && !armored && !golden) {
      // Just normal mole, holding an acorn
      canvas.drawOval(
        const Rect.fromLTWH(45, 70, 10, 15),
        Paint()..color = const Color(0xFF8B4513),
      );
    }

    canvas.drawOval(const Rect.fromLTWH(28, 68, 12, 12), furPaint);
    canvas.drawOval(const Rect.fromLTWH(60, 68, 12, 12), furPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SquirrelPainter oldDelegate) =>
      oldDelegate.decoy != decoy ||
      oldDelegate.golden != golden ||
      oldDelegate.armored != armored;
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final List<FloatingText> texts;
  _ParticlePainter({required this.particles, required this.texts});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      Paint paint = Paint()..color = p.color.withValues(alpha: opacity);
      if (p.isSmoke) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(p.x, p.y), p.size * (1.5 - opacity), paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(p.x, p.y),
            width: p.size,
            height: p.size,
          ),
          paint,
        );
      }
    }

    for (var f in texts) {
      double opacity = (f.life / f.maxLife).clamp(0.0, 1.0);
      TextPainter tp = TextPainter(
        text: TextSpan(
          text: f.text,
          style: TextStyle(
            color: f.color.withValues(alpha: opacity),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(f.x - tp.width / 2, f.y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}


