import '../shared/minigame_environment.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../domain/mini_game_contract.dart';
import '../../../../core/random/deterministic_rng.dart';

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
      vy += 800 * dt;
    } else {
      size += 15 * dt;
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
  int _cupCount = 3;
  late int _ballCupIndex;
  late List<int> _currentPositions;
  late List<int> _targetPositions;
  final List<List<int>> _swapQueue = [];
  final List<Particle> _particles = [];
  int? _guessedCup;
  bool _won = false;
  int _correctGuesses = 0;
  int _mistakes = 0;

  @override
  void initState() {
    super.initState();
    _rng = DeterministicRng(widget.config.seed);
    _watch = Stopwatch()..start();
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _swapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _swapController.addListener(() => setState(() {}));
    _revealController.addListener(() => setState(() {}));
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startRound());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _revealController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    MinigameEnvironment.of(context).updateTimeProgress((_watch.elapsedMilliseconds / 30000).clamp(0.0, 1.0));
    if (_lastTime == Duration.zero) _lastTime = elapsed;
    final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;
    if (_particles.isNotEmpty) {
      setState(() {
        for (final p in _particles) { p.update(dt); }
        _particles.removeWhere((p) => p.life <= 0);
      });
    }
  }

  void _startRound() => _runSequence();

  Future<void> _runSequence() async {
    _cupCount = _round == 1 ? 3 : 4;
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
    setState(() => _phase = GamePhase.hide);
    await _revealController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _generateSwaps();
    setState(() => _phase = GamePhase.shuffle);
    _playNextSwap();
  }

  void _generateSwaps() {
    final swapCount = _round == 1 ? 12 : (_round == 2 ? 18 : 25);
    int lastSlot1 = -1, lastSlot2 = -1;
    for (int i = 0; i < swapCount; i++) {
      int slot1 = _rng.nextInt(_cupCount);
      int slot2 = _rng.nextInt(_cupCount);
      while (slot1 == slot2 || (slot1 == lastSlot1 && slot2 == lastSlot2)) {
        slot1 = _rng.nextInt(_cupCount);
        slot2 = _rng.nextInt(_cupCount);
      }
      _swapQueue.add([slot1, slot2]);
      lastSlot1 = slot1;
      lastSlot2 = slot2;
    }
  }

  Future<void> _playNextSwap() async {
    if (!mounted) return;
    if (_swapQueue.isEmpty) {
      setState(() => _phase = GamePhase.guess);
      return;
    }
    final swap = _swapQueue.removeAt(0);
    final slotA = swap[0];
    final slotB = swap[1];
    final cupA = _currentPositions.indexWhere((s) => s == slotA);
    final cupB = _currentPositions.indexWhere((s) => s == slotB);
    _targetPositions = List.from(_currentPositions);
    _targetPositions[cupA] = slotB;
    _targetPositions[cupB] = slotA;
    _swapController.reset();
    final baseDuration = _round == 1 ? 300 : (_round == 2 ? 180 : 120);
    _swapController.duration = Duration(milliseconds: baseDuration + _rng.nextInt(50));
    await _swapController.animateTo(1.0, curve: Curves.easeInOut);
    if (!mounted) return;
    _currentPositions = List.from(_targetPositions);
    _playNextSwap();
  }

  void _onTapUp(TapUpDetails details, Size size) {
    if (_phase != GamePhase.guess) return;
    final spacing = size.width / (_cupCount + 1);
    final hitY = size.height / 2;
    int? clickedSlot;
    for (int s = 0; s < _cupCount; s++) {
      final cx = spacing * (s + 1);
      final hitBox = Rect.fromCenter(center: Offset(cx, hitY), width: 100, height: 150);
      if (hitBox.contains(details.localPosition)) { clickedSlot = s; break; }
    }
    if (clickedSlot == null) return;
    final clickedCup = _currentPositions.indexWhere((pos) => pos == clickedSlot);
    setState(() {
      _guessedCup = clickedCup;
      _won = clickedCup == _ballCupIndex;
      _phase = GamePhase.result;
      if (_won) { _correctGuesses++; } else { _mistakes++; }
      MinigameEnvironment.of(context).updateScore((_correctGuesses * 1000 / 3).round());
      if (_won) {
        MinigameEnvironment.of(context).playSuccess(details.globalPosition);
      } else {
        MinigameEnvironment.of(context).playError(details.globalPosition);
      }
      _spawnParticles(size, clickedSlot!);
    });
    _revealController.forward().then((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        _revealController.reset();
        if (_round < 3) {
          _round++;
          _startRound();
        } else {
          _finishGame();
        }
      });
    });
  }

  void _finishGame() {
    _watch.stop();
    final passed = _correctGuesses >= 2;
    final attempts = _correctGuesses + _mistakes;
    final accuracy = attempts == 0 ? 0.0 : _correctGuesses / attempts;
    widget.onComplete(MiniGameResult(
      completed: passed,
      score: (_correctGuesses * 1000 / 3).round(),
      accuracy: accuracy,
      mistakes: _mistakes,
      duration: _watch.elapsed,
    ));
  }

  void _spawnParticles(Size size, int clickedSlot) {
    final spacing = size.width / (_cupCount + 1);
    final cx = spacing * (clickedSlot + 1);
    final cy = size.height / 2 + 30;
    if (_won) {
      for (int i = 0; i < 60; i++) {
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
      for (int i = 0; i < 40; i++) {
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
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onTapUp: (d) => _onTapUp(d, size),
        child: Stack(children: [
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
            top: 50, left: 0, right: 0,
            child: Text(
              _getPhaseText(context),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3))],
              ),
            ),
          ),
        ]),
      );
    });
  }

  String _getPhaseText(BuildContext context) {
    bool isArabic = true;
    try { isArabic = Localizations.localeOf(context).languageCode == 'ar'; } catch (_) {}
    switch (_phase) {
      case GamePhase.intro: return isArabic ? 'الجولة $_round: استعد...' : 'Round $_round: Get Ready...';
      case GamePhase.reveal: return isArabic ? 'ركز على الكرة!' : 'Watch the Ball!';
      case GamePhase.hide: return '';
      case GamePhase.shuffle: return isArabic ? 'تتبع القبعة...' : 'Follow the Hat...';
      case GamePhase.guess: return isArabic ? 'أين الكرة؟' : 'Where is it?';
      case GamePhase.result: return _won ? (isArabic ? 'رائع!' : 'Awesome!') : (isArabic ? 'حظاً أوفر' : 'Better Luck Next Time');
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
    final spacing = size.width / (cupCount + 1);
    final baseY = size.height / 2 + 50;
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.width, size.height - baseY), Paint()..color = const Color(0xFF1E293B));
    canvas.drawRect(Rect.fromLTWH(0, baseY, size.width, 10), Paint()..color = const Color(0xFF334155));
    final drawData = <_CupDrawData>[];
    for (int c = 0; c < cupCount; c++) {
      final startSlotX = spacing * (currentPositions[c] + 1);
      final endSlotX = spacing * (targetPositions[c] + 1);
      final cx = startSlotX + (endSlotX - startSlotX) * swapProgress;
      double arc = 0;
      if (startSlotX != endSlotX) {
        final sign = endSlotX > startSlotX ? 1 : -1;
        arc = sin(swapProgress * pi) * 60 * sign;
      }
      final cy = baseY + arc;
      final lift = liftAmount(c);
      drawData.add(_CupDrawData(logicalIndex: c, x: cx, y: cy - lift, zIndex: cy, shadowArcOffset: arc));
    }
    final ballData = drawData[ballCupIndex];
    if (liftAmount(ballCupIndex) > 20) {
      final glowPaint = Paint()
        ..color = Colors.blueAccent.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(Offset(ballData.x, baseY - 20), 40, glowPaint);
      canvas.drawCircle(Offset(ballData.x, baseY - 20), 25, Paint()..color = Colors.cyanAccent);
      canvas.drawCircle(Offset(ballData.x - 8, baseY - 28), 8, Paint()..color = Colors.white);
    }
    for (final p in particles) {
      final opacity = (p.life / p.maxLife).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
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
    for (final data in drawData) {
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
    final heightFromTable = baseY - y;
    final shadowWidth = (110 * scale) - (heightFromTable * 0.3).clamp(0, 60);
    final shadowAlpha = (0.6 - (heightFromTable * 0.003)).clamp(0.0, 0.6);
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: shadowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(Rect.fromCenter(center: Offset(x, baseY), width: shadowWidth, height: 20 * scale), shadowPaint);
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale, scale);
    final brimPaint = Paint()..color = const Color(0xFF2E1065);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 140, height: 40), brimPaint);
    final body = Path()
      ..moveTo(-45, -100)
      ..lineTo(45, -100)
      ..lineTo(50, 0)
      ..lineTo(-50, 0)
      ..close();
    final bodyPaint = Paint()..shader = const LinearGradient(
      colors: [Color(0xFF3B0764), Color(0xFF6B21A8), Color(0xFF9333EA), Color(0xFF6B21A8), Color(0xFF2E1065)],
      stops: [0.0, 0.2, 0.5, 0.8, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(const Rect.fromLTWH(-50, -100, 100, 100));
    canvas.drawPath(body, bodyPaint);
    final ribbon = Path()
      ..moveTo(-48, -25)
      ..quadraticBezierTo(0, -15, 48, -25)
      ..lineTo(50, -5)
      ..quadraticBezierTo(0, 5, -50, -5)
      ..close();
    final ribbonPaint = Paint()..shader = const LinearGradient(
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
  _CupDrawData({required this.logicalIndex, required this.x, required this.y, required this.zIndex, required this.shadowArcOffset});
}
