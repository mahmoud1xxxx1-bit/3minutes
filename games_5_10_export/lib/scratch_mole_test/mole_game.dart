import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum HitResult { normal, golden, decoy, empty, missed }

class Particle {
  double x, y, vx, vy, life, maxLife, size;
  Color color;
  bool isSmoke;
  bool isCoin;

  Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.color, required this.life,
    required this.maxLife, required this.size,
    required this.isSmoke,
    this.isCoin = false,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    if (!isSmoke) vy += 800 * dt; // gravity
    else size += 15 * dt; // smoke expands
    life -= dt;
  }
}

class FloatingText {
  double x, y;
  String text;
  Color color;
  double life;
  double maxLife;

  FloatingText({required this.x, required this.y, required this.text, required this.color, required this.life, required this.maxLife});
  
  void update(double dt) {
    y -= 80 * dt; 
    life -= dt;
  }
}

class MalletStrike {
  double x, y;
  double life = 0.25; 
  MalletStrike(this.x, this.y);
  void update(double dt) => life -= dt;
}

class MoleTestScreen extends StatefulWidget {
  const MoleTestScreen({super.key});
  @override
  State<MoleTestScreen> createState() => _MoleTestScreenState();
}

class _MoleTestScreenState extends State<MoleTestScreen> with TickerProviderStateMixin {
  final List<GlobalKey<_MoleSlotState>> _slotKeys = List.generate(9, (i) => GlobalKey<_MoleSlotState>());
  Timer? _gameLoop;
  int _score = 0;
  int _mistakes = 0;
  int _combo = 0;

  late AnimationController _shakeController;
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;

  final List<MalletStrike> _mallets = [];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeController.addListener(() => setState(() {}));
    
    _ticker = createTicker(_onTick)..start();
    _startGame();
  }

  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) _lastTime = elapsed;
    double dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    
    if (_mallets.isNotEmpty) {
      setState(() {
        for (var m in _mallets) m.update(dt);
        _mallets.removeWhere((m) => m.life <= 0);
      });
    }
  }

  void _startGame() {
    _gameLoop = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      int activeSlot = math.Random().nextInt(9);
      
      double rand = math.Random().nextDouble();
      bool isDecoy = false;
      bool isGolden = false;
      
      if (rand < 0.20) isDecoy = true;
      else if (rand < 0.35) isGolden = true; // 15% chance for golden
      
      _slotKeys[activeSlot].currentState?.trigger(isDecoy: isDecoy, isGolden: isGolden);
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _shakeController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  void _onHit(HitResult result) {
    setState(() {
      if (result == HitResult.decoy || result == HitResult.empty || result == HitResult.missed) {
        _combo = 0;
        if (result != HitResult.missed) _mistakes++;
        if (result == HitResult.decoy) {
          _shakeController.forward(from: 0.0); // Camera Shake on bomb
        }
      } else {
        _combo++;
        _score += (result == HitResult.golden ? 3 : 1);
      }
    });
  }

  void _handleGlobalTap(TapDownDetails details) {
    setState(() {
      _mallets.add(MalletStrike(details.localPosition.dx, details.localPosition.dy));
    });
  }

  @override
  Widget build(BuildContext context) {
    double shakeOffset = math.sin(_shakeController.value * math.pi * 5) * 15 * (1 - _shakeController.value);
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleGlobalTap,
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("🎯 $_score", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                    if (_combo > 1)
                      Text("🔥 COMBO x$_combo", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                    Text("❌ $_mistakes", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
                  ],
                ),
                const SizedBox(height: 40),
                Expanded(
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
              ],
            ),
          ),
          
          // Mallet Layer
          for (var m in _mallets)
            Positioned(
              left: m.x - 40,
              top: m.y - 80,
              child: _buildMallet(m.life),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMallet(double life) {
    // Rotates from 45 degrees to 0 degrees quickly
    double progress = 1.0 - (life / 0.25).clamp(0.0, 1.0);
    double angle = (1.0 - math.min(progress * 3, 1.0)) * 0.8;
    
    return Transform(
      alignment: Alignment.bottomRight,
      transform: Matrix4.identity()..rotateZ(angle),
      child: SizedBox(
        width: 80, height: 80,
        child: CustomPaint(painter: _MalletPainter()),
      ),
    );
  }
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
    
    if (needsSetState && mounted) setState(() {});
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
    
    int visibleTime = _isGolden ? 500 : 800; // Golden is faster
    await Future.delayed(Duration(milliseconds: visibleTime));
    if (!mounted) return;
    
    if (_isActive && !_isSquashed) {
      // Missed it
      await _riseController.reverse();
      if (mounted) {
        setState(() => _isActive = false);
        if (!_isDecoy) widget.onHit(HitResult.missed); // Lost combo because missed a real one
      }
    }
  }

  void _handleTap() {
    if (!_isActive || _isSquashed) {
      // Empty hit (Dirt dust)
      widget.onHit(HitResult.empty);
      _spawnDust();
      return;
    }
    
    setState(() {
      _isSquashed = true;
    });
    
    HitResult res = _isDecoy ? HitResult.decoy : (_isGolden ? HitResult.golden : HitResult.normal);
    widget.onHit(res);
    _spawnHitEffects(res);
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _riseController.reverse();
        setState(() => _isActive = false);
      }
    });
  }
  
  void _spawnDust() {
    for (int i=0; i<8; i++) {
      _particles.add(Particle(
        x: 45 + (math.Random().nextDouble() - 0.5) * 30, y: 70,
        vx: (math.Random().nextDouble() - 0.5) * 80,
        vy: -math.Random().nextDouble() * 150 - 50,
        color: const Color(0xFF5E422C).withValues(alpha: 0.8),
        life: 0.3 + math.Random().nextDouble() * 0.4,
        maxLife: 0.7, size: 10 + math.Random().nextDouble()*10, isSmoke: true,
      ));
    }
  }

  void _spawnHitEffects(HitResult res) {
    int combo = widget.getCombo();
    
    if (res == HitResult.golden) {
      _floatingTexts.add(FloatingText(x: 45, y: 30, text: "+3", color: Colors.yellowAccent, life: 1.0, maxLife: 1.0));
      if (combo > 1) _floatingTexts.add(FloatingText(x: 45, y: 0, text: "COMBO!", color: Colors.orangeAccent, life: 1.0, maxLife: 1.0));
      for (int i=0; i<20; i++) {
        _particles.add(Particle(
          x: 45, y: 50,
          vx: (math.Random().nextDouble() - 0.5) * 400,
          vy: -math.Random().nextDouble() * 500 - 150,
          color: Colors.amberAccent,
          life: 0.5 + math.Random().nextDouble() * 0.5,
          maxLife: 1.0, size: 12, isSmoke: false, isCoin: true,
        ));
      }
    } else if (res == HitResult.normal) {
      _floatingTexts.add(FloatingText(x: 45, y: 30, text: "+1", color: Colors.greenAccent, life: 1.0, maxLife: 1.0));
      if (combo > 1) _floatingTexts.add(FloatingText(x: 45, y: 0, text: "x$combo", color: Colors.orangeAccent, life: 0.8, maxLife: 0.8));
      for (int i=0; i<15; i++) {
        _particles.add(Particle(
          x: 45, y: 50,
          vx: (math.Random().nextDouble() - 0.5) * 300,
          vy: -math.Random().nextDouble() * 400 - 100,
          color: Colors.greenAccent,
          life: 0.5 + math.Random().nextDouble() * 0.5,
          maxLife: 1.0, size: 8, isSmoke: false,
        ));
      }
    } else if (res == HitResult.decoy) {
      _floatingTexts.add(FloatingText(x: 45, y: 30, text: "BOOM", color: Colors.redAccent, life: 1.0, maxLife: 1.0));
      for (int i=0; i<25; i++) {
        _particles.add(Particle(
          x: 45 + (math.Random().nextDouble() - 0.5) * 40, y: 50,
          vx: (math.Random().nextDouble() - 0.5) * 200,
          vy: -math.Random().nextDouble() * 300 - 50,
          color: Colors.grey.shade800,
          life: 0.5 + math.Random().nextDouble() * 0.8,
          maxLife: 1.3, size: 25, isSmoke: true,
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
      onTapDown: (_) => _handleTap(), // Using onTapDown for faster response
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
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

class _MalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Handle
    canvas.drawRect(const Rect.fromLTWH(35, 20, 10, 60), Paint()..color=const Color(0xFF8B4513));
    // Head
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 10, 60, 25), const Radius.circular(8)), Paint()..color=const Color(0xFFD22B2B));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(5, 12, 70, 21), const Radius.circular(5)), Paint()..color=const Color(0xFF991B1B));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HoleBackPainter extends CustomPainter {
  final bool isWarning;
  _HoleBackPainter({required this.isWarning});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the back part of the dirt ring
    Paint dirtPaint = Paint()..color = const Color(0xFF4A3525);
    canvas.drawOval(Rect.fromLTWH(0, 5, size.width, size.height - 10), dirtPaint);

    // 2. Draw the dark abyss (the hole itself)
    Paint abyssPaint = Paint()..color = const Color(0xFF150F0B);
    if (isWarning) {
      abyssPaint.color = Colors.redAccent.shade700;
      abyssPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    }
    // Draw the deep hole
    canvas.drawOval(Rect.fromLTWH(8, 12, size.width - 16, size.height - 24), abyssPaint);
    
    // Add inner shadow/depth rim to the abyss
    Paint innerDepth = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
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
    // Clip the top half so it only draws the front lip over the squirrel!
    canvas.clipRect(Rect.fromLTWH(0, size.height / 2 + 1, size.width, size.height / 2));
    
    // Front dirt ring
    Paint dirtPaint = Paint()..color = const Color(0xFF4A3525);
    canvas.drawOval(Rect.fromLTWH(0, 5, size.width, size.height - 10), dirtPaint);

    // Nice bright highlight rim on the front edge to give it 3D thickness
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
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      } else if (p.isCoin) {
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
        canvas.drawCircle(Offset(p.x, p.y), p.size * 0.7, Paint()..color=Colors.yellow.withValues(alpha: opacity));
      } else {
        canvas.save();
        canvas.translate(p.x, p.y);
        canvas.rotate(p.life * 10);
        Path star = Path();
        star.moveTo(0, -p.size);
        star.lineTo(p.size*0.3, -p.size*0.3);
        star.lineTo(p.size, 0);
        star.lineTo(p.size*0.3, p.size*0.3);
        star.lineTo(0, p.size);
        star.lineTo(-p.size*0.3, p.size*0.3);
        star.lineTo(-p.size, 0);
        star.lineTo(-p.size*0.3, -p.size*0.3);
        star.close();
        canvas.drawPath(star, paint);
        canvas.restore();
      }
    }
    
    for (var f in texts) {
      double opacity = (f.life / f.maxLife).clamp(0.0, 1.0);
      TextPainter tp = TextPainter(
        text: TextSpan(text: f.text, style: TextStyle(color: f.color.withValues(alpha: opacity), fontSize: 24, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black.withValues(alpha: opacity), blurRadius: 4)])),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(f.x - tp.width/2, f.y - tp.height/2));
    }
  }
  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
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

    Path bodyPath = Path();
    bodyPath.moveTo(30, 20); bodyPath.quadraticBezierTo(50, 5, 70, 20); bodyPath.quadraticBezierTo(90, 50, 80, 90); bodyPath.quadraticBezierTo(50, 100, 20, 90); bodyPath.quadraticBezierTo(10, 50, 30, 20);
    canvas.drawPath(bodyPath, furPaint);

    Path bellyPath = Path();
    bellyPath.moveTo(35, 55); bellyPath.quadraticBezierTo(50, 45, 65, 55); bellyPath.quadraticBezierTo(75, 85, 60, 95); bellyPath.quadraticBezierTo(50, 100, 40, 95); bellyPath.quadraticBezierTo(25, 85, 35, 55);
    canvas.drawPath(bellyPath, bellyPaint);

    Path maskPath = Path();
    maskPath.moveTo(20, 40); maskPath.quadraticBezierTo(50, 45, 80, 40); maskPath.quadraticBezierTo(85, 55, 70, 60); maskPath.quadraticBezierTo(50, 55, 30, 60); maskPath.quadraticBezierTo(15, 55, 20, 40);
    canvas.drawPath(maskPath, darkPaint);

    if (decoy) {
      canvas.drawCircle(const Offset(35, 48), 6, whitePaint); canvas.drawCircle(const Offset(65, 48), 6, whitePaint);
      canvas.drawCircle(const Offset(35, 48), 2.5, Paint()..color=Colors.redAccent); canvas.drawCircle(const Offset(65, 48), 2.5, Paint()..color=Colors.redAccent);
      canvas.drawLine(const Offset(25, 40), const Offset(42, 45), Paint()..color=Colors.black..strokeWidth=4..strokeCap=StrokeCap.round);
      canvas.drawLine(const Offset(75, 40), const Offset(58, 45), Paint()..color=Colors.black..strokeWidth=4..strokeCap=StrokeCap.round);
    } else {
      canvas.drawCircle(const Offset(35, 48), 8, whitePaint); canvas.drawCircle(const Offset(65, 48), 8, whitePaint);
      canvas.drawCircle(const Offset(37, 48), 5, darkPaint); canvas.drawCircle(const Offset(63, 48), 5, darkPaint);
      canvas.drawCircle(const Offset(35, 46), 2, whitePaint); canvas.drawCircle(const Offset(61, 46), 2, whitePaint);
    }

    canvas.drawOval(const Rect.fromLTWH(45, 58, 10, 6), pinkPaint);
    canvas.drawOval(const Rect.fromLTWH(20, 55, 12, 8), Paint()..color=pinkPaint.color.withValues(alpha: 0.6));
    canvas.drawOval(const Rect.fromLTWH(68, 55, 12, 8), Paint()..color=pinkPaint.color.withValues(alpha: 0.6));

    if (golden) {
      // Crown for golden mole
      Path crown = Path();
      crown.moveTo(35, 20); crown.lineTo(30, -5); crown.lineTo(42, 10); crown.lineTo(50, -10); crown.lineTo(58, 10); crown.lineTo(70, -5); crown.lineTo(65, 20); crown.close();
      canvas.drawPath(crown, Paint()..color=Colors.amberAccent);
    }

    if (decoy) {
      canvas.drawCircle(const Offset(50, 75), 18, darkPaint);
      canvas.drawCircle(const Offset(45, 70), 5, Paint()..color=Colors.white.withValues(alpha: 0.3));
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
      canvas.drawPath(gemHigh, Paint()..color=Colors.white.withValues(alpha: 0.4));
    }

    canvas.drawOval(const Rect.fromLTWH(28, 68, 12, 12), furPaint); canvas.drawOval(const Rect.fromLTWH(60, 68, 12, 12), furPaint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _SquirrelPainter oldDelegate) => oldDelegate.decoy != decoy || oldDelegate.golden != golden;
}
