import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../domain/mini_game_contract.dart';
import '../mini_game_host.dart';

enum HitResult { miss, hit, golden, decoy }

class MalletStrike {
  double x, y;
  double life = 1.0;
  MalletStrike(this.x, this.y);
  void update(double dt) => life -= dt * 3;
}

class Particle {
  double x, y, vx, vy, life, maxLife, size;
  Color color;
  bool isSmoke;
  Particle({required this.x, required this.y, required this.vx, required this.vy, required this.life, required this.maxLife, required this.size, required this.color, this.isSmoke = false});
  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    if (!isSmoke) vy += 800 * dt; // gravity
    life -= dt;
  }
}

class FloatingText {
  double x, y, life, maxLife;
  String text;
  Color color;
  FloatingText({required this.x, required this.y, required this.life, required this.maxLife, required this.text, required this.color});
  void update(double dt) {
    y -= 80 * dt; 
    life -= dt;
  }
}

class MoleStrikeGame extends StatefulWidget {
  final MiniGameConfig config;
  final Function(MiniGameResult) onComplete;
  const MoleStrikeGame({super.key, required this.config, required this.onComplete});
  @override
  State<MoleStrikeGame> createState() => _MoleStrikeGameState();
}

class _MoleStrikeGameState extends State<MoleStrikeGame> with TickerProviderStateMixin {
  final List<GlobalKey<_MoleSlotState>> _slotKeys = List.generate(9, (i) => GlobalKey<_MoleSlotState>());
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
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeController.addListener(() => setState(() {}));
    _ticker = createTicker(_onTick)..start();
    _startGame();
  }

  void _startGame() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted || _isDone) return;
      int r = _rng.nextInt(9);
      bool isGolden = _rng.nextDouble() < 0.1;
      bool isDecoy = _rng.nextDouble() < 0.15;
      _slotKeys[r].currentState?.trigger(isDecoy: isDecoy, isGolden: isGolden);
    });
  }

  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) _lastTime = elapsed;
    double dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    
    // MinigameEnvironment.of(context).updateTimeProgress((_watch.elapsedMilliseconds / 30000).clamp(0.0, 1.0));
    
    if (_mallets.isNotEmpty) {
      setState(() {
        for (var m in _mallets) m.update(dt);
        _mallets.removeWhere((m) => m.life <= 0);
      });
    }
    if (_watch.elapsedMilliseconds >= 30000) _finishGame();
  }

  void _onHit(HitResult result) {
    if (_isDone) return;
    setState(() {
      if (result == HitResult.hit) { _score += 10; _combo++; }
      else if (result == HitResult.golden) { _score += 50; _combo += 2; }
      else if (result == HitResult.decoy) { _mistakes++; _combo = 0; _shakeController.forward(from: 0.0); }
      else { _combo = 0; }
    });
  }

  void _handleGlobalTap(TapDownDetails details) {
    if (_isDone) return;
    setState(() {
      _mallets.add(MalletStrike(details.localPosition.dx, details.localPosition.dy));
    });
  }

  void _finishGame() {
    if (_isDone) return;
    _isDone = true;
    _gameLoop?.cancel();
    _watch.stop();
    
    double acc = 1.0;
    widget.onComplete(MiniGameResult(
      completed: true,
      score: _score,
      accuracy: acc,
      mistakes: _mistakes,
      duration: _watch.elapsed,
    ));
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _shakeController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  Widget _buildMallet(double life) {
    double angle = (1.0 - life) * math.pi / 2;
    return Transform.rotate(
      angle: angle,
      alignment: Alignment.bottomRight,
      child: Container(
        width: 80, height: 80,
        alignment: Alignment.bottomRight,
        child: CustomPaint(painter: _MalletPainter()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double shakeOffset = math.sin(_shakeController.value * math.pi * 5) * 15 * (1 - _shakeController.value);
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleGlobalTap,
      child: Stack(
        children: [
          Container(color: Colors.transparent),
          
          Positioned(
            top: 10, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Mistakes: $_mistakes', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ],
            ),
          ),
          
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(shakeOffset, 0),
              child: Center(
                child: SizedBox(
                  width: 600,
                  height: 600,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return MoleSlot(key: _slotKeys[index], onHit: _onHit, getCombo: () => _combo);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          for (var m in _mallets)
            Positioned(
              left: m.x - 80,
              top: m.y - 80,
              child: _buildMallet(m.life),
            ),
            
          if (_isDone)
            const Center(
              child: Text(
                "TIME UP!",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                  shadows: [Shadow(color: Colors.black, blurRadius: 20)],
                ),
              ),
            ),
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
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 10, 60, 25), const Radius.circular(8)), head);
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
    _riseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
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
      for (var p in _particles) p.update(dt);
      _particles.removeWhere((p) => p.life <= 0);
      needsSetState = true;
    }
    if (_floatingTexts.isNotEmpty) {
      for (var f in _floatingTexts) f.update(dt);
      _floatingTexts.removeWhere((f) => f.life <= 0);
      needsSetState = true;
    }
    if (needsSetState) setState(() {});
  }

  void trigger({required bool isDecoy, required bool isGolden}) async {
    if (_isActive || _isWarning) return;
    
    setState(() {
      _isDecoy = isDecoy;
      _isGolden = isGolden;
      _isWarning = true;
      _isSquashed = false;
    });
    
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    
    setState(() {
      _isWarning = false;
      _isActive = true;
    });
    
    await _riseController.forward();
    
    int visibleTime = _isGolden ? 500 : 800; 
    await Future.delayed(Duration(milliseconds: visibleTime));
    if (!mounted || _isSquashed) return;
    
    await _riseController.reverse();
    if (mounted) {
      setState(() => _isActive = false);
    }
  }

  void _handleTap() {
    if (!_isActive || _isSquashed) {
      _spawnDust();
      widget.onHit(HitResult.miss);
      return;
    }
    
    setState(() { _isSquashed = true; });
    _riseController.reverse();
    
    HitResult res = _isDecoy ? HitResult.decoy : (_isGolden ? HitResult.golden : HitResult.hit);
    _spawnHitEffects(res);
    widget.onHit(res);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isActive = false);
    });
  }

  void _spawnDust() {
    for (int i=0; i<8; i++) {
      _particles.add(Particle(
        x: 45 + (math.Random().nextDouble() - 0.5) * 20, y: 80,
        vx: (math.Random().nextDouble() - 0.5) * 100, vy: -math.Random().nextDouble() * 100,
        color: const Color(0xFF4A3525), life: 0.2 + math.Random().nextDouble() * 0.3, maxLife: 0.5, size: 4, isSmoke: true,
      ));
    }
  }

  void _spawnHitEffects(HitResult res) {
    int combo = widget.getCombo();
    if (res == HitResult.hit || res == HitResult.golden) {
      String t = res == HitResult.golden ? "+50" : "+10";
      Color c = res == HitResult.golden ? Colors.amberAccent : Colors.greenAccent;
      if (combo > 1) t += " (x$combo)";
      _floatingTexts.add(FloatingText(x: 45, y: 40, text: t, color: c, life: 1.0, maxLife: 1.0));
      for (int i=0; i<15; i++) {
        _particles.add(Particle(
          x: 45, y: 50,
          vx: (math.Random().nextDouble() - 0.5) * 300, vy: -math.Random().nextDouble() * 300 - 100,
          color: c, life: 0.3 + math.Random().nextDouble() * 0.5, maxLife: 1.0, size: 6,
        ));
      }
    } else if (res == HitResult.decoy) {
      _floatingTexts.add(FloatingText(x: 45, y: 30, text: "BOOM", color: Colors.redAccent, life: 1.0, maxLife: 1.0));
      for (int i=0; i<25; i++) {
        _particles.add(Particle(
          x: 45 + (math.Random().nextDouble() - 0.5) * 40, y: 50,
          vx: (math.Random().nextDouble() - 0.5) * 200, vy: -math.Random().nextDouble() * 300 - 50,
          color: Colors.grey.shade800, life: 0.5 + math.Random().nextDouble() * 0.8, maxLife: 1.3, size: 25, isSmoke: true,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double yOffset = 1.0 - _riseController.value;
    double scaleY = _isSquashed ? 0.3 : 1.0;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _handleTap(),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: Container(color: Colors.transparent)),
          // 1. Back of the Hole (Abyss)
          Positioned(
            left: 0, right: 0, bottom: -5, height: 45,
            child: CustomPaint(painter: _HoleBackPainter(isWarning: _isWarning)),
          ),
          
          // 2. Mole
          if (_isActive || _riseController.value > 0)
            FractionalTranslation(
              translation: Offset(0, yOffset),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()..scale(_isSquashed ? 1.2 : 1.0, scaleY, 1.0),
                child: SizedBox(
                  width: 90, height: 100,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(child: CustomPaint(painter: _SquirrelPainter(decoy: _isDecoy, golden: _isGolden))),
                    ],
                  ),
                ),
              ),
            ),
            
          // 3. Front of the Hole (Dirt Mound Cover)
          Positioned(
            left: 0, right: 0, bottom: -5, height: 45,
            child: CustomPaint(painter: _HoleFrontPainter(isWarning: _isWarning)),
          ),

          // 4. Particles
          Positioned.fill(
            child: CustomPaint(
              painter: _ParticlePainter(particles: _particles, texts: _floatingTexts),
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
    canvas.drawOval(Rect.fromLTWH(0, 5, size.width, size.height - 10), dirtPaint);

    Paint abyssPaint = Paint()..color = const Color(0xFF150F0B);
    if (isWarning) {
      abyssPaint.color = Colors.redAccent.shade700;
      abyssPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    }
    canvas.drawOval(Rect.fromLTWH(8, 12, size.width - 16, size.height - 24), abyssPaint);
    
    Paint innerDepth = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawOval(Rect.fromLTWH(8, 12, size.width - 16, size.height - 24), innerDepth);
  }
  @override
  bool shouldRepaint(covariant _HoleBackPainter oldDelegate) => oldDelegate.isWarning != isWarning;
}

class _HoleFrontPainter extends CustomPainter {
  final bool isWarning;
  _HoleFrontPainter({required this.isWarning});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, size.height / 2 + 1, size.width, size.height / 2));
    
    Paint dirtPaint = Paint()..color = const Color(0xFF4A3525);
    canvas.drawOval(Rect.fromLTWH(0, 5, size.width, size.height - 10), dirtPaint);

    Paint rimPaint = Paint()
      ..color = const Color(0xFF6B4D36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawOval(Rect.fromLTWH(0, 5, size.width, size.height - 10), rimPaint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _HoleFrontPainter oldDelegate) => oldDelegate.isWarning != isWarning;
}

class _SquirrelPainter extends CustomPainter {
  const _SquirrelPainter({required this.decoy, required this.golden});
  final bool decoy;
  final bool golden;
  
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100, sy = size.height / 100;
    canvas.save(); canvas.scale(sx, sy);
    
    Color mainFurColor1 = decoy ? const Color(0xFF6B4C9A) : const Color(0xFFD97736);
    Color mainFurColor2 = decoy ? const Color(0xFF3B2A59) : const Color(0xFF8B4513);
    
    if (golden) {
      mainFurColor1 = const Color(0xFFFFD700);
      mainFurColor2 = const Color(0xFFB8860B);
    }
    
    final Paint furPaint = Paint()..shader = LinearGradient(
      colors: [mainFurColor1, mainFurColor2],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));
    
    final Paint bellyPaint = Paint()..shader = LinearGradient(
      colors: decoy ? [const Color(0xFFC4B5E3), const Color(0xFF8C7BA6)] : [const Color(0xFFFFECCC), const Color(0xFFE2C29A)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0, 0, 100, 100));

    final Paint darkPaint = Paint()..color = const Color(0xFF1E1E1E);
    final Paint pinkPaint = Paint()..color = const Color(0xFFF28F79);
    final Paint whitePaint = Paint()..color = Colors.white;

    Path tailPath = Path();
    if (decoy) {
      tailPath.moveTo(70, 70); tailPath.lineTo(100, 60); tailPath.lineTo(85, 40); tailPath.lineTo(95, 20); tailPath.lineTo(75, 25); tailPath.lineTo(60, 5); tailPath.lineTo(55, 30);
    } else {
      tailPath.moveTo(60, 70); tailPath.cubicTo(120, 70, 110, 10, 70, 20); tailPath.cubicTo(60, 20, 50, 40, 50, 50);
    }
    canvas.drawPath(tailPath, furPaint);

    canvas.save(); canvas.translate(25, 25); canvas.rotate(-0.5); canvas.drawOval(const Rect.fromLTWH(-15, -15, 30, 40), furPaint); canvas.drawOval(const Rect.fromLTWH(-8, -8, 16, 25), pinkPaint); canvas.restore();
    canvas.save(); canvas.translate(75, 25); canvas.rotate(0.5); canvas.drawOval(const Rect.fromLTWH(-15, -15, 30, 40), furPaint); canvas.drawOval(const Rect.fromLTWH(-8, -8, 16, 25), pinkPaint); canvas.restore();

    canvas.drawOval(const Rect.fromLTWH(20, 30, 60, 65), furPaint);
    canvas.drawOval(const Rect.fromLTWH(30, 45, 40, 45), bellyPaint);

    canvas.drawCircle(const Offset(35, 45), 6, darkPaint); canvas.drawCircle(const Offset(65, 45), 6, darkPaint);
    canvas.drawCircle(const Offset(33, 43), 2, whitePaint); canvas.drawCircle(const Offset(63, 43), 2, whitePaint);
    canvas.drawOval(const Rect.fromLTWH(45, 55, 10, 6), pinkPaint);

    if (golden) {
      Path crown = Path()..moveTo(35, 30)..lineTo(30, 10)..lineTo(45, 20)..lineTo(50, 5)..lineTo(55, 20)..lineTo(70, 10)..lineTo(65, 30)..close();
      canvas.drawPath(crown, Paint()..color=Colors.amberAccent);
    }

    if (decoy) {
      canvas.drawCircle(const Offset(50, 75), 18, darkPaint);
      canvas.drawCircle(const Offset(45, 70), 5, Paint()..color=Colors.white.withOpacity(0.3));
      canvas.drawRect(const Rect.fromLTWH(45, 53, 10, 5), Paint()..color=Colors.grey);
      Path fusePath = Path()..moveTo(50, 53)..quadraticBezierTo(60, 45, 55, 35);
      canvas.drawPath(fusePath, Paint()..color=Colors.brown..style=PaintingStyle.stroke..strokeWidth=2);
      canvas.drawCircle(const Offset(55, 35), 4, Paint()..color=Colors.orangeAccent);
      canvas.drawCircle(const Offset(55, 35), 2, Paint()..color=Colors.yellowAccent);
    } else {
      Path gemPath = Path()..moveTo(50, 60)..lineTo(65, 70)..lineTo(50, 90)..lineTo(35, 70)..close();
      Paint gemPaint = Paint()..shader = const LinearGradient(
        colors: [Color(0xFF67E8F9), Color(0xFF06B6D4), Color(0xFF0891B2)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(35, 60, 30, 30));
      canvas.drawPath(gemPath, gemPaint);
      Path gemHigh = Path()..moveTo(50, 60)..lineTo(62, 70)..lineTo(50, 85)..close();
      canvas.drawPath(gemHigh, Paint()..color=Colors.white.withOpacity(0.4));
    }

    canvas.drawOval(const Rect.fromLTWH(28, 68, 12, 12), furPaint); canvas.drawOval(const Rect.fromLTWH(60, 68, 12, 12), furPaint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _SquirrelPainter oldDelegate) => oldDelegate.decoy != decoy || oldDelegate.golden != golden;
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final List<FloatingText> texts;
  _ParticlePainter({required this.particles, required this.texts});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      Paint paint = Paint()..color = p.color.withOpacity(opacity);
      if (p.isSmoke) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(p.x, p.y), p.size * (1.5 - opacity), paint);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset(p.x, p.y), width: p.size, height: p.size), paint);
      }
    }
    
    for (var f in texts) {
      double opacity = (f.life / f.maxLife).clamp(0.0, 1.0);
      TextPainter tp = TextPainter(
        text: TextSpan(text: f.text, style: TextStyle(color: f.color.withOpacity(opacity), fontSize: 24, fontWeight: FontWeight.bold, shadows: const [Shadow(color: Colors.black, blurRadius: 4)])),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(f.x - tp.width / 2, f.y - tp.height / 2));
    }
  }
  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
