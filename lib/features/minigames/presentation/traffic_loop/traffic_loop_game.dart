import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../mini_game_copy.dart';
import '../../domain/mini_game_contract.dart';
import 'traffic_engine.dart';
import 'dart:math';

class TrafficLoopGame extends StatefulWidget {
  const TrafficLoopGame({super.key, required this.config, required this.onComplete});
  final MiniGameConfig config;
  final void Function(MiniGameResult) onComplete;

  @override
  State<TrafficLoopGame> createState() => _TrafficLoopGameState();
}

class _TrafficLoopGameState extends State<TrafficLoopGame> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late TrafficEngine _engine;
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
    int goal = _currentRound == 1 ? 10 : _currentRound == 2 ? 15 : 20;
    _engine = TrafficEngine(goal: goal, seed: widget.config.seed ^ _currentRound);
  }

  void _onTick(Duration elapsed) {
    if (_finished) return;
    
    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    setState(() {
      _engine.update(dt);
      if (_engine.isRoundComplete) {
        _totalCorrect += _engine.correct;
        _totalMistakes += _engine.mistakes;
        
        if (_currentRound < _maxRounds) {
          _currentRound++;
          _initEngine();
        } else {
          _finishGame();
        }
      }
    });
  }

  void _finishGame() {
    _finished = true;
    _ticker.stop();
    final duration = DateTime.now().difference(_startTime);
    final accuracy = _totalMistakes == 0 ? 1.0 : (_totalCorrect / (_totalCorrect + _totalMistakes));
    
    // Total goal is 10 + 15 + 20 = 45. Score calculation (max 1000)
    int score = (accuracy * 1000).toInt();
    
    widget.onComplete(MiniGameResult(
      completed: true,
      score: score,
      accuracy: accuracy,
      mistakes: _totalMistakes,
      duration: duration,
    ));
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
    final copy = MiniGameCopy.fromContext(context);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Pill(label: '${copy.followCupCorrect}: ${_totalCorrect + _engine.correct} / 45'),
            const SizedBox(width: 8),
            _Pill(label: '${copy.findDifferencesMistakes}: ${_totalMistakes + _engine.mistakes}'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: const Color(0xFF0F172A),
                child: CustomPaint(
                  painter: _TrafficPainter(_engine),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _TrafficPainter extends CustomPainter {
  _TrafficPainter(this.engine);
  final TrafficEngine engine;

  @override
  void paint(Canvas canvas, Size size) {
    // 800x600 coordinate space mapping
    final double scaleX = size.width / 800.0;
    final double scaleY = size.height / 600.0;
    final double scale = min(scaleX, scaleY);
    
    canvas.save();
    canvas.translate((size.width - 800 * scale) / 2, (size.height - 600 * scale) / 2);
    canvas.scale(scale);

    // Draw Track
    final trackPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
      
    // Create a path combining entrance, loop, exit for drawing
    final fullTrack = Path()
      ..addPath(engine.entrancePath, Offset.zero)
      ..addPath(engine.loopPath, Offset.zero)
      ..addPath(engine.exitPath, Offset.zero);

    canvas.drawPath(fullTrack, trackPaint);
    
    // Draw Exit Green Arrow
    final arrowPaint = Paint()..color = Colors.greenAccent.withOpacity(0.8);
    final arrowPath = Path()
      ..moveTo(400, 50)
      ..lineTo(380, 80)
      ..lineTo(420, 80)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);

    // Draw center number
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${engine.goal - engine.correct}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.2),
          fontSize: 120,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(400 - textPainter.width / 2, 300 - textPainter.height / 2));

    // Draw Cars
    for (var car in engine.cars) {
      canvas.save();
      canvas.translate(car.position.dx, car.position.dy);
      canvas.rotate(car.rotation);
      
      // Glow
      final glowPaint = Paint()
        ..color = car.color.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(-5, 0), width: engine.carLength + 10, height: engine.carWidth + 10),
          const Radius.circular(8)
        ),
        glowPaint
      );

      // Body
      final carPaint = Paint()..color = car.color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: engine.carLength, height: engine.carWidth),
          const Radius.circular(6)
        ),
        carPaint
      );
      
      // Windows
      final windowPaint = Paint()..color = Colors.black87;
      canvas.drawRect(Rect.fromCenter(center: const Offset(-8, 0), width: 6, height: engine.carWidth - 6), windowPaint);
      canvas.drawRect(Rect.fromCenter(center: const Offset(8, 0), width: 6, height: engine.carWidth - 6), windowPaint);

      canvas.restore();
    }

    // Draw Particles
    for (var p in engine.particles) {
      final pPaint = Paint()..color = p.color.withOpacity(p.life.clamp(0.0, 1.0));
      final pPath = Path()
        ..moveTo(p.position.dx, p.position.dy - 4)
        ..lineTo(p.position.dx - 4, p.position.dy + 4)
        ..lineTo(p.position.dx + 4, p.position.dy + 4)
        ..close();
      canvas.drawPath(pPath, pPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrafficPainter oldDelegate) => true;
}
