import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum GamePhase { intro, reveal, hide, shuffle, guess, result }

class Particle {
  double x, y;
  double vx, vy;
  Color color;
  double life;
  double maxLife;
  double size;
  bool isSmoke;

  Particle({
    required this.x, required this.y,
    required this.vx, required this.vy,
    required this.color, required this.life,
    required this.maxLife, required this.size,
    required this.isSmoke,
  });

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    if (!isSmoke) {
      vy += 800 * dt; // gravity
    } else {
      size += 15 * dt; // smoke expansion
    }
    life -= dt;
  }
}

class FollowTheCupGame extends StatefulWidget {
  const FollowTheCupGame({super.key});

  @override
  State<FollowTheCupGame> createState() => _FollowTheCupGameState();
}

class _FollowTheCupGameState extends State<FollowTheCupGame> with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _swapController;
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;

  GamePhase _phase = GamePhase.intro;

  int _round = 1;
  int _cupCount = 3;
  late int _ballCupIndex; 
  
  late List<int> _currentPositions;
  late List<int> _targetPositions;
  
  final List<List<int>> _swapQueue = [];
  final List<Particle> _particles = [];
  
  bool _currentIsFake = false;
  int _fakeTargetA = -1;
  int _fakeTargetB = -1;
  
  int? _guessedCup; 
  bool _won = false;
  
  int _correctGuesses = 0;
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _swapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    
    _swapController.addListener(() {
      setState(() {});
    });
    _revealController.addListener(() {
      setState(() {});
    });
    
    _ticker = createTicker(_onTick)..start();
    
    _startRound();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _revealController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) _lastTime = elapsed;
    double dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    
    if (_particles.isNotEmpty) {
      setState(() {
        for (var p in _particles) {
          p.update(dt);
        }
        _particles.removeWhere((p) => p.life <= 0);
      });
    }
  }

  void _startRound() {
    if (_round == 1) _cupCount = 3;
    else if (_round == 2) _cupCount = 3;
    else if (_round == 3) _cupCount = 4;
    
    _ballCupIndex = Random().nextInt(_cupCount);
    _currentPositions = List.generate(_cupCount, (i) => i);
    _targetPositions = List.from(_currentPositions);
    _guessedCup = null;
    _won = false;
    _swapQueue.clear();
    _particles.clear();
    
    _startGameSequence();
  }

  Future<void> _startGameSequence() async {
    setState(() => _phase = GamePhase.intro);
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() => _phase = GamePhase.reveal);
    await _revealController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    
    setState(() => _phase = GamePhase.hide);
    await _revealController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));
    
    _generateSwaps();
    setState(() => _phase = GamePhase.shuffle);
    _playNextSwap();
  }

  void _generateSwaps() {
    int swapCount = _round == 1 ? 8 : (_round == 2 ? 12 : 15);
    int lastSlot1 = -1, lastSlot2 = -1;
    
    for (int i = 0; i < swapCount; i++) {
      int slot1 = Random().nextInt(_cupCount);
      int slot2 = Random().nextInt(_cupCount);
      while (slot1 == slot2 || (slot1 == lastSlot1 && slot2 == lastSlot2)) {
        slot1 = Random().nextInt(_cupCount);
        slot2 = Random().nextInt(_cupCount);
      }
      
      // Removed Fake Swaps as per user request
      _swapQueue.add([slot1, slot2, 0]);
      
      lastSlot1 = slot1;
      lastSlot2 = slot2;
    }
  }

  Future<void> _playNextSwap() async {
    if (_swapQueue.isEmpty) {
      setState(() => _phase = GamePhase.guess);
      return;
    }
    
    final swap = _swapQueue.removeAt(0);
    int slotA = swap[0];
    int slotB = swap[1];
    
    int cupA = _currentPositions.indexWhere((s) => s == slotA);
    int cupB = _currentPositions.indexWhere((s) => s == slotB);
    
    _targetPositions = List.from(_currentPositions);
    _targetPositions[cupA] = slotB;
    _targetPositions[cupB] = slotA;
    
    _currentIsFake = false; // Always false
    
    _swapController.reset();
    
    int baseDuration = _round == 1 ? 400 : (_round == 2 ? 300 : 250);
    int durationMs = baseDuration + Random().nextInt(100);
    _swapController.duration = Duration(milliseconds: durationMs);
    
    // Smooth standard swap curve without distracting bounces
    await _swapController.animateTo(1.0, curve: Curves.easeInOut);
    
    _currentPositions = List.from(_targetPositions);
    
    _playNextSwap();
  }

  void _onTapUp(TapUpDetails details, Size size) {
    if (_phase != GamePhase.guess) return;
    
    double spacing = size.width / (_cupCount + 1);
    double hitY = size.height / 2;
    
    int? clickedSlot;
    for (int s = 0; s < _cupCount; s++) {
      double cx = spacing * (s + 1);
      Rect hitBox = Rect.fromCenter(center: Offset(cx, hitY), width: 100, height: 150);
      if (hitBox.contains(details.localPosition)) {
        clickedSlot = s;
        break;
      }
    }
    
    if (clickedSlot != null) {
      int clickedCup = _currentPositions.indexWhere((pos) => pos == clickedSlot);
      setState(() {
        _guessedCup = clickedCup;
        _won = (clickedCup == _ballCupIndex);
        _phase = GamePhase.result;
        if (_won) _correctGuesses++;
        else _mistakes++;
        
        _spawnParticles(size, clickedSlot!);
      });
      
      _revealController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
           _revealController.reset();
           if (_round < 3) {
             _round++;
             _startRound();
           } else {
             _round = 1;
             _correctGuesses = 0;
             _mistakes = 0;
             _startRound();
           }
        });
      });
    }
  }
  
  void _spawnParticles(Size size, int clickedSlot) {
    double spacing = size.width / (_cupCount + 1);
    double cx = spacing * (clickedSlot + 1);
    double cy = size.height / 2 + 30;
    
    if (_won) {
      for (int i=0; i<60; i++) {
        _particles.add(Particle(
          x: cx, y: cy,
          vx: (Random().nextDouble() - 0.5) * 600,
          vy: -Random().nextDouble() * 600 - 200,
          color: Random().nextBool() ? Colors.amberAccent : Colors.yellowAccent,
          life: 1.0 + Random().nextDouble(),
          maxLife: 2.0,
          size: 6 + Random().nextDouble() * 6,
          isSmoke: false,
        ));
      }
    } else {
      for (int i=0; i<40; i++) {
        _particles.add(Particle(
          x: cx + (Random().nextDouble() - 0.5) * 60,
          y: cy,
          vx: (Random().nextDouble() - 0.5) * 100,
          vy: -Random().nextDouble() * 200 - 50,
          color: const Color(0xFF64748B), 
          life: 1.0 + Random().nextDouble() * 1.5,
          maxLife: 2.5,
          size: 15 + Random().nextDouble() * 20,
          isSmoke: true,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        double? resultX;
        if (_phase == GamePhase.result && _guessedCup != null) {
          double spacing = size.width / (_cupCount + 1);
          int visualIndex = _currentPositions[_guessedCup!];
          resultX = spacing * (visualIndex + 1);
        }

        return GestureDetector(
          onTapUp: (d) => _onTapUp(d, size),
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: CupPainter(
                  cupCount: _cupCount,
                  ballCupIndex: _ballCupIndex,
                  currentPositions: _currentPositions,
                  targetPositions: _targetPositions,
                  swapProgress: _swapController.value,
                  revealProgress: _revealController.value,
                  phase: _phase,
                  guessedCup: _guessedCup,
                  won: _won,
                  particles: _particles,
                  isFakeSwap: _currentIsFake,
                  fakeTargetA: _fakeTargetA,
                  fakeTargetB: _fakeTargetB,
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Text(
                  _getPhaseText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3))]
                  ),
                ),
              ),
              if (_phase == GamePhase.result && resultX != null)
                Positioned(
                  top: (size.height / 2 + 50) - 260,
                  left: resultX - 100,
                  width: 200,
                  child: Text(
                    _won ? "أحسنت!" : "خطأ!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _won ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(color: Colors.black87, blurRadius: 15, offset: Offset(0, 5))]
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getPhaseText() {
    bool isArabic = true;
    switch (_phase) {
      case GamePhase.intro: return isArabic ? "الجولة $_round: استعد..." : "Round $_round: Get Ready...";
      case GamePhase.reveal: return isArabic ? "ركز على الكرة!" : "Watch the Ball!";
      case GamePhase.hide: return "";
      case GamePhase.shuffle: return isArabic ? "تتبع الكوب..." : "Follow the Cup...";
      case GamePhase.guess: return isArabic ? "أين الكرة؟" : "Where is it?";
      case GamePhase.result: return _won 
          ? (isArabic ? "رائع!" : "Awesome!") 
          : (isArabic ? "حظاً أوفر" : "Better Luck Next Time");
    }
  }
}

class CupPainter extends CustomPainter {
  CupPainter({
    required this.cupCount,
    required this.ballCupIndex,
    required this.currentPositions,
    required this.targetPositions,
    required this.swapProgress,
    required this.revealProgress,
    required this.phase,
    required this.guessedCup,
    required this.won,
    required this.particles,
    required this.isFakeSwap,
    required this.fakeTargetA,
    required this.fakeTargetB,
  });

  final int cupCount;
  final int ballCupIndex;
  final List<int> currentPositions;
  final List<int> targetPositions;
  final double swapProgress;
  final double revealProgress;
  final GamePhase phase;
  final int? guessedCup;
  final bool won;
  final List<Particle> particles;
  final bool isFakeSwap;
  final int fakeTargetA;
  final int fakeTargetB;

  @override
  void paint(Canvas canvas, Size size) {
    double spacing = size.width / (cupCount + 1);
    double baseY = size.height / 2 + 50;

    Paint tablePaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.width, size.height - baseY), tablePaint);
    
    Paint edgePaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.width, 10), edgePaint);

    List<_CupDrawData> drawData = [];
    
    for (int c = 0; c < cupCount; c++) {
      double startSlotX = spacing * (currentPositions[c] + 1);
      
      // Determine visual end slot (might be fake)
      int endLogicalSlot = targetPositions[c];
      if (isFakeSwap) {
         if (currentPositions[c] == fakeTargetA) endLogicalSlot = fakeTargetB;
         else if (currentPositions[c] == fakeTargetB) endLogicalSlot = fakeTargetA;
      }
      
      double endSlotX = spacing * (endLogicalSlot + 1);
      
      // If fake, progress goes 0 -> 0.5 -> 0 using sine wave
      double effectiveProgress = isFakeSwap && startSlotX != endSlotX 
          ? sin(swapProgress * pi) * 0.5 
          : swapProgress;
          
      double cx = startSlotX + (endSlotX - startSlotX) * effectiveProgress;
      
      double arc = 0;
      if (startSlotX != endSlotX) {
        double sign = (endSlotX > startSlotX) ? 1 : -1;
        // Bouncy arch
        arc = sin((isFakeSwap ? effectiveProgress * 2 : swapProgress) * pi) * 60 * sign;
      }
      
      double cy = baseY + arc;
      
      double lift = liftAmount(c);
      
      drawData.add(_CupDrawData(
        logicalIndex: c,
        x: cx,
        y: cy - lift,
        zIndex: cy,
        shadowArcOffset: arc,
      ));
    }
    
    _CupDrawData ballData = drawData[ballCupIndex];
    if (liftAmount(ballCupIndex) > 20) {
      Paint glowPaint = Paint()..color = Colors.blueAccent.withValues(alpha: 0.8)
                             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(Offset(ballData.x, baseY - 20), 40, glowPaint);
                             
      Paint ballPaint = Paint()..color = Colors.cyanAccent;
      canvas.drawCircle(Offset(ballData.x, baseY - 20), 25, ballPaint);
      
      Paint highlight = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(ballData.x - 8, baseY - 28), 8, highlight);
    }

    for (var p in particles) {
      double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      Paint paint = Paint()..color = p.color.withValues(alpha: opacity);
      
      if (p.isSmoke) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
      } else {
        canvas.save();
        canvas.translate(p.x, p.y);
        canvas.rotate(p.life * 5);
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size), paint);
        canvas.restore();
      }
    }

    drawData.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    
    for (var data in drawData) {
      _drawMagicHat(canvas, data.x, data.y, baseY, data.shadowArcOffset);
    }
  }
  
  double liftAmount(int cupIndex) {
    if (phase == GamePhase.reveal || phase == GamePhase.hide) return revealProgress * 120;
    if (phase == GamePhase.result && (cupIndex == guessedCup || cupIndex == ballCupIndex)) return revealProgress * 120;
    return 0;
  }

  void _drawMagicHat(Canvas canvas, double x, double y, double baseY, double arcOffset) {
    // 1. Dynamic Shadow
    double heightFromTable = baseY - y;
    double shadowWidth = 110 - (heightFromTable * 0.3).clamp(0, 60);
    double shadowAlpha = (0.6 - (heightFromTable * 0.003)).clamp(0.0, 0.6);
    
    Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: shadowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(x, baseY), width: shadowWidth, height: 20), shadowPaint);

    // 2. Magic Hat Brim (Bottom ellipse)
    Paint brimPaint = Paint()..color = const Color(0xFF2E1065); // Very Dark Purple
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y), width: 140, height: 40), brimPaint);
    
    // 3. Hat Body (Cylinder)
    Path body = Path();
    body.moveTo(x - 45, y - 100);
    body.lineTo(x + 45, y - 100);
    body.lineTo(x + 50, y);
    body.lineTo(x - 50, y);
    body.close();
    
    Paint bodyPaint = Paint()..shader = LinearGradient(
      colors: const [Color(0xFF3B0764), Color(0xFF6B21A8), Color(0xFF9333EA), Color(0xFF6B21A8), Color(0xFF2E1065)],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(x - 50, y - 100, 100, 100));
    canvas.drawPath(body, bodyPaint);
    
    // 4. Magic Glowing Ribbon
    Path ribbon = Path();
    ribbon.moveTo(x - 48, y - 25);
    ribbon.quadraticBezierTo(x, y - 15, x + 48, y - 25);
    ribbon.lineTo(x + 50, y - 5);
    ribbon.quadraticBezierTo(x, y + 5, x - 50, y - 5);
    ribbon.close();
    
    Paint ribbonPaint = Paint()..shader = LinearGradient(
      colors: const [Color(0xFFB45309), Color(0xFFF59E0B), Color(0xFFFCD34D), Color(0xFFF59E0B), Color(0xFF92400E)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(x - 50, y - 25, 100, 20));
    canvas.drawPath(ribbon, ribbonPaint);
    
    // 5. Hat Top (Top ellipse)
    Paint topPaint = Paint()..color = const Color(0xFFD8B4FE); // Light purple edge
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 100), width: 90, height: 25), topPaint);
    
    Paint topInnerPaint = Paint()..color = const Color(0xFF1E1B4B); // Dark inside/top
    canvas.drawOval(Rect.fromCenter(center: Offset(x, y - 100), width: 80, height: 18), topInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CupPainter oldDelegate) => true;
}

class _CupDrawData {
  final int logicalIndex;
  final double x;
  final double y;
  final double zIndex;
  final double shadowArcOffset;
  
  _CupDrawData({
    required this.logicalIndex, 
    required this.x, 
    required this.y, 
    required this.zIndex,
    required this.shadowArcOffset,
  });
}
