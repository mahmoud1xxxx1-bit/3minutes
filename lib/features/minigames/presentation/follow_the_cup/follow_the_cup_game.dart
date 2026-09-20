import '../shared/minigame_environment.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/mini_game_contract.dart';
import '../../../../core/random/deterministic_rng.dart';
import 'package:game/features/minigames/presentation/shared/hearts_display.dart';
import '../../domain/follow_the_cup_plan.dart';

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
  const FollowTheCupGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<FollowTheCupGame> createState() => _FollowTheCupGameState();
}

class _FollowTheCupGameState extends State<FollowTheCupGame> with TickerProviderStateMixin {
  late DeterministicRng _rng;
  late Stopwatch _watch;
  
  late AnimationController _revealController;
  late AnimationController _swapController;
  late Ticker _ticker;
  Duration _lastTime = Duration.zero;

  GamePhase _phase = GamePhase.intro;

  int _round = 1;
  int _cupCount = 4; // Use 4 cups always as per the new plan
  late int _ballCupIndex; 
  
  late List<int> _currentPositions;
  late List<int> _targetPositions;
  
  List<CupSwap> _swapQueue = [];
  final List<Particle> _particles = [];
  
  int? _guessedCup; 
  bool _won = false;
  
  int _roundHearts = 1;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _rng = DeterministicRng(widget.config.seed);
    _watch = Stopwatch()..start();
    
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _swapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    
    _swapController.addListener(() {
      setState(() {});
    });
    _revealController.addListener(() {
      setState(() {});
    });
    
    _ticker = createTicker(_onTick)..start();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRound();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _revealController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_phase == GamePhase.result) {
      double dt = 1/60; // Approximate
      for (var p in _particles) p.update(dt);
      _particles.removeWhere((p) => p.life <= 0);
      setState(() {});
    }
  }

  void _startRound() {
    _roundHearts = 1;
    _runSequence();
  }

  Future<void> _runSequence() async {
    _cupCount = 4;
    
    _ballCupIndex = _rng.nextInt(_cupCount);
    _currentPositions = List.generate(_cupCount, (i) => i);
    _targetPositions = List.from(_currentPositions);
    _guessedCup = null;
    _won = false;
    _swapQueue.clear();
    _particles.clear();
    
    if (!mounted) return;
    setState(() => _phase = GamePhase.intro);
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    setState(() => _phase = GamePhase.reveal);
    await _revealController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!mounted) return;
    await _revealController.reverse();
    setState(() => _phase = GamePhase.hide);
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    setState(() => _phase = GamePhase.shuffle);
    
    final plan = FollowTheCupPlan.fromSeed(seed: widget.config.seed + _round, difficulty: widget.config.difficulty);
    _swapQueue = List.from(plan.rounds[0].swaps); // We use the first round plan logic per sequence
    
    _playNextSwap();
  }

  void _playNextSwap() {
    if (!mounted || _phase != GamePhase.shuffle) return;
    
    if (_swapQueue.isEmpty) {
      setState(() => _phase = GamePhase.guess);
      return;
    }
    
    final swap = _swapQueue.removeAt(0);
    _targetPositions = List.from(_currentPositions);
    
    int indexA = _targetPositions.indexWhere((val) => val == swap.a);
    int indexB = _targetPositions.indexWhere((val) => val == swap.b);
    
    _targetPositions[indexA] = swap.b;
    _targetPositions[indexB] = swap.a;
    
    _swapController.forward(from: 0.0).then((_) {
      _currentPositions = List.from(_targetPositions);
      _playNextSwap();
    });
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
        
        if (_won) { 
          _totalScore += 500;
          MinigameEnvironment.of(context).playSuccess(details.globalPosition); 
        } else { 
          _roundHearts = 0;
          MinigameEnvironment.of(context).playError(details.globalPosition); 
        }
        
        _spawnParticles(size, clickedSlot!);
      });
      
      _revealController.forward().then((_) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 2000), () {
           if (!mounted) return;
           _revealController.reset();
           if (_round < 2) { // 2 rounds total
             _round++;
             _startRound();
           } else {
             _finishGame();
           }
        });
      });
    }
  }
  
  void _finishGame() {
    _watch.stop();
    widget.onComplete(MiniGameResult(
      completed: true, score: _totalScore, accuracy: 1.0, mistakes: 0, duration: _watch.elapsed,
    ));
  }
  
  void _spawnParticles(Size size, int clickedSlot) {
    double spacing = size.width / (_cupCount + 1);
    double cx = spacing * (clickedSlot + 1);
    double cy = size.height / 2 + 30; 
    
    // Using simple math.Random for visual particles is okay as it doesn't affect gameplay logic fairness
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
        
        return GestureDetector(
          onTapUp: (d) => _onTapUp(d, size),
          child: Stack(
            children: [
              Container(color: Colors.transparent),
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
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    HeartsDisplay(maxHearts: 1, currentHearts: _roundHearts),
                    const SizedBox(height: 10),
                    Text(
                      _getPhaseText(context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3))]
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }


  String _getPhaseText(BuildContext context) {
    bool isArabic = true;
    try {
      isArabic = Localizations.localeOf(context).languageCode == 'ar';
    } catch (_) {}
    
    switch (_phase) {
      case GamePhase.intro: return isArabic ? "الجولة $_round: استعد..." : "Round $_round: Get Ready...";
      case GamePhase.reveal: return isArabic ? "ركز على الكرة!" : "Watch the Ball!";
      case GamePhase.hide: return "";
      case GamePhase.shuffle: return isArabic ? "تتبع القبعة..." : "Follow the Hat...";
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
      double endSlotX = spacing * (targetPositions[c] + 1);
      
      double cx = startSlotX + (endSlotX - startSlotX) * swapProgress;
      
      double arc = 0;
      if (startSlotX != endSlotX) {
        double sign = (endSlotX > startSlotX) ? 1 : -1;
        arc = sin(swapProgress * pi) * 60 * sign;
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
      _drawMagicHat(canvas, data.x, data.y, baseY, data.shadowArcOffset, spacing);
    }
  }
  
  double liftAmount(int cupIndex) {
    if (phase == GamePhase.reveal || phase == GamePhase.hide) return revealProgress * 120;
    if (phase == GamePhase.result && (cupIndex == guessedCup || cupIndex == ballCupIndex)) return revealProgress * 120;
    return 0;
  }

  void _drawMagicHat(Canvas canvas, double x, double y, double baseY, double arcOffset, double spacing) {
    double scale = (spacing * 0.9) / 140.0;
    if (scale > 1.2) scale = 1.2;
    
    double heightFromTable = baseY - y;
    double shadowWidth = (110 * scale) - (heightFromTable * 0.3).clamp(0, 60);
    double shadowAlpha = (0.6 - (heightFromTable * 0.003)).clamp(0.0, 0.6);
    
    Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: shadowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawOval(Rect.fromCenter(center: Offset(x, baseY), width: shadowWidth, height: 20 * scale), shadowPaint);

    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);

    Paint brimPaint = Paint()..color = const Color(0xFF2E1065);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 140, height: 40), brimPaint);
    
    Path body = Path();
    body.moveTo(-45, -100);
    body.lineTo(45, -100);
    body.lineTo(50, 0);
    body.lineTo(-50, 0);
    body.close();
    
    Paint bodyPaint = Paint()..shader = const LinearGradient(
      colors: [Color(0xFF3B0764), Color(0xFF6B21A8), Color(0xFF9333EA), Color(0xFF6B21A8), Color(0xFF2E1065)],
      stops: [0.0, 0.2, 0.5, 0.8, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(const Rect.fromLTWH(-50, -100, 100, 100));
    canvas.drawPath(body, bodyPaint);
    
    Path ribbon = Path();
    ribbon.moveTo(-48, -25);
    ribbon.quadraticBezierTo(0, -15, 48, -25);
    ribbon.lineTo(50, -5);
    ribbon.quadraticBezierTo(0, 5, -50, -5);
    ribbon.close();
    
    Paint ribbonPaint = Paint()..shader = const LinearGradient(
      colors: [Color(0xFFB45309), Color(0xFFF59E0B), Color(0xFFFCD34D), Color(0xFFF59E0B), Color(0xFF92400E)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(const Rect.fromLTWH(-50, -25, 100, 20));
    canvas.drawPath(ribbon, ribbonPaint);
    
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, -100), width: 90, height: 25), brimPaint);
    canvas.restore();
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







