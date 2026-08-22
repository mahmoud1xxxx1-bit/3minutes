import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/mini_game_contract.dart';
import '../../domain/path_rush_plan.dart';
import '../mini_game_copy.dart';

class PathRushGame extends StatefulWidget {
  const PathRushGame({super.key, required this.config, required this.onComplete});

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<PathRushGame> createState() => _PathRushGameState();
}

class _PathRushGameState extends State<PathRushGame>
    with SingleTickerProviderStateMixin {
  late final PathRushPlan _plan;
  late final Stopwatch _watch;
  late final AnimationController _runner;
  int _roundIndex = 0;
  int _correct = 0;
  int _mistakes = 0;
  int? _selectedLane;
  int? _selectedTarget;
  bool? _lastCorrect;
  bool _locked = false;
  bool _done = false;

  PathRushRound get _round => _plan.rounds[_roundIndex];

  @override
  void initState() {
    super.initState();
    _plan = PathRushPlan.fromSeed(
      seed: widget.config.seed,
      difficulty: widget.config.difficulty,
    );
    _watch = Stopwatch()..start();
    _runner = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _plan.travelMs),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _runner.dispose();
    _watch.stop();
    super.dispose();
  }

  Future<void> _choose(int number) async {
    if (_locked || _done) return;
    _locked = true;
    final lane = _round.pathForNumber(number);
    final target = _round.endPermutation[lane];
    final ok = target == _round.correctTarget;
    setState(() {
      _selectedLane = lane;
      _selectedTarget = target;
      _lastCorrect = null;
    });
    _runner.duration = Duration(milliseconds: _plan.travelMs);
    await _runner.forward(from: 0);
    if (!mounted || _done) return;
    setState(() {
      _lastCorrect = ok;
      if (ok) {
        _correct++;
      } else {
        _mistakes++;
      }
    });
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (!mounted || _done) return;
    if (_roundIndex >= PathRushPlan.roundCount - 1) {
      _finish();
      return;
    }
    setState(() {
      _roundIndex++;
      _selectedLane = null;
      _selectedTarget = null;
      _lastCorrect = null;
      _locked = false;
      _runner.value = 0;
    });
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _watch.stop();
    final accuracy = _correct / PathRushPlan.roundCount;
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: _correct * 1000,
        accuracy: accuracy,
        mistakes: _mistakes,
        duration: _watch.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = MiniGameCopy.fromContext(context);
    final family = (_round.familyIndex + 1).toString().padLeft(2, '0');
    return Column(
      children: [
        Text(
          copy.pathRushInstruction,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PathPill(label: '${copy.pathRushRound}: ${_roundIndex + 1}/3'),
            const SizedBox(width: 8),
            _PathPill(label: 'F$family'),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF213B63)),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF07182E), Color(0xFF08182C), Color(0xFF07101E)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(child: _CharacterCard(animal: _round.animal)),
                ),
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Text(
                    _lastCorrect == true
                        ? 'CORRECT'
                        : _lastCorrect == false
                            ? 'WRONG'
                            : copy.pathRushChoose,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _lastCorrect == true
                          ? const Color(0xFF4DDA9A)
                          : _lastCorrect == false
                              ? const Color(0xFFFF667E)
                              : const Color(0xFFC4CEE0),
                    ),
                  ),
                ),
                Positioned(
                  top: 110,
                  left: 20,
                  right: 20,
                  child: Row(
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StartButton(number: 3, selected: _selectedLane == 0, enabled: !_locked, onTap: () => _choose(3)),
                      _StartButton(number: 2, selected: _selectedLane == 1, enabled: !_locked, onTap: () => _choose(2)),
                      _StartButton(number: 1, selected: _selectedLane == 2, enabled: !_locked, onTap: () => _choose(1)),
                    ],
                  ),
                ),
                Positioned(
                  top: 158,
                  left: 16,
                  right: 16,
                  bottom: 116,
                  child: CustomPaint(
                    painter: _MazePainter(
                      round: _round,
                      selectedLane: _selectedLane,
                      progress: _runner.value,
                      reveal: _lastCorrect != null,
                      correct: _lastCorrect ?? false,
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 10,
                  height: 96,
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _TargetCard(
                              target: _round.targets[i],
                              good: _lastCorrect != null && i == _round.correctTarget,
                              bad: _lastCorrect == false && i == _selectedTarget,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PathPill extends StatelessWidget {
  const _PathPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF19DCE8).withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF52F2F2).withValues(alpha: .25)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF52F2F2), fontSize: 11, fontWeight: FontWeight.w900),
        ),
      );
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.number, required this.selected, required this.enabled, required this.onTap});
  final int number;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(center: Alignment(-.3, -.3), colors: [Color(0xFF4A3B22), Color(0xFF181323)]),
            border: Border.all(color: const Color(0xFFFFCD68).withValues(alpha: .65), width: 2),
            boxShadow: selected ? const [BoxShadow(color: Color(0x77FFCD68), blurRadius: 24)] : const [],
          ),
          child: Text('$number', style: const TextStyle(color: Color(0xFFFFCD68), fontSize: 18, fontWeight: FontWeight.w900)),
        ),
      );
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.target, required this.good, required this.bad});
  final (String, String) target;
  final bool good;
  final bool bad;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF102044), Color(0xFF0A1730)]),
          border: Border.all(color: good ? const Color(0xFF4DDA9A) : bad ? const Color(0xFFFF667E) : const Color(0xFF294D77)),
          boxShadow: good ? const [BoxShadow(color: Color(0x444DDA9A), blurRadius: 20)] : bad ? const [BoxShadow(color: Color(0x44FF667E), blurRadius: 20)] : const [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(target.$2, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 2),
            Text(target.$1, style: const TextStyle(color: Color(0xFFC4CEE0), fontWeight: FontWeight.w900, fontSize: 11)),
          ],
        ),
      );
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.animal});
  final PathAnimal animal;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xE8071226), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF2B4D73))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFF17365B), Color(0xFF0D1D35)])),
              child: CustomPaint(painter: _AnimalPainter(animal.id)),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('الشخصية', style: TextStyle(color: Color(0xFF8293B2), fontSize: 9)),
                Text(animal.arName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      );
}

Path _curve(List<PathPoint> points, Size size) {
  Offset scale(PathPoint point) => Offset(point.x / 430 * size.width, point.y / 280 * size.height);
  final first = scale(points.first);
  final path = Path()..moveTo(first.dx, first.dy);
  for (var i = 0; i < points.length - 1; i++) {
    final p0 = scale(points[i == 0 ? i : i - 1]);
    final p1 = scale(points[i]);
    final p2 = scale(points[i + 1]);
    final p3 = scale(points[i + 2 < points.length ? i + 2 : i + 1]);
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path;
}

class _MazePainter extends CustomPainter {
  const _MazePainter({required this.round, required this.selectedLane, required this.progress, required this.reveal, required this.correct});
  final PathRushRound round;
  final int? selectedLane;
  final double progress;
  final bool reveal;
  final bool correct;

  @override
  void paint(Canvas canvas, Size size) {
    final paths = round.paths.map((points) => _curve(points, size)).toList();
    for (final path in paths) {
      canvas.drawPath(path, Paint()..color = const Color(0xCC020612)..style = PaintingStyle.stroke..strokeWidth = 11..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
      canvas.drawPath(path, Paint()..color = const Color(0xFFF1DDA5)..style = PaintingStyle.stroke..strokeWidth = 5.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    }
    final lane = selectedLane;
    if (lane == null) return;
    final path = paths[lane];
    final color = reveal && !correct ? const Color(0xFFFF334F) : const Color(0xFF19DCE8);
    if (reveal) {
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: .35)..style = PaintingStyle.stroke..strokeWidth = 15..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)..strokeCap = StrokeCap.round);
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round);
      canvas.drawPath(path, Paint()..color = correct ? const Color(0xFFEFFFFF) : const Color(0xFFFFD9DE)..style = PaintingStyle.stroke..strokeWidth = 2.3..strokeCap = StrokeCap.round);
    }
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final tangent = metric.getTangentForOffset(metric.length * progress.clamp(0, 1));
    if (tangent != null) {
      canvas.drawCircle(tangent.position, 11, Paint()..color = color.withValues(alpha: .35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(tangent.position, 8, Paint()..color = Colors.white);
      canvas.drawCircle(tangent.position, 6, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _MazePainter oldDelegate) =>
      oldDelegate.round != round || oldDelegate.selectedLane != selectedLane || oldDelegate.progress != progress || oldDelegate.reveal != reveal || oldDelegate.correct != correct;
}

class _AnimalPainter extends CustomPainter {
  const _AnimalPainter(this.id);
  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 64;
    canvas.save();
    canvas.translate((size.width - 64 * s) / 2, (size.height - 64 * s) / 2);
    canvas.scale(s);
    final dark = Paint()..color = const Color(0xFF151515);
    switch (id) {
      case 'rabbit':
        final fur = Paint()..color = const Color(0xFFEEF2F7);
        final ear = Paint()..color = const Color(0xFFD8DDE8);
        final pink = Paint()..color = const Color(0xFFE58B9A);
        canvas.drawOval(const Rect.fromLTWH(14, -2, 16, 32), ear);
        canvas.drawOval(const Rect.fromLTWH(34, -2, 16, 32), ear);
        canvas.drawCircle(const Offset(32, 38), 21, fur);
        canvas.drawCircle(const Offset(24, 34), 3, dark);
        canvas.drawCircle(const Offset(40, 34), 3, dark);
        canvas.drawCircle(const Offset(32, 40), 3, pink);
      case 'monkey':
        final fur = Paint()..color = const Color(0xFF8F5F3B);
        final face = Paint()..color = const Color(0xFFD8AD75);
        canvas.drawCircle(const Offset(16, 32), 10, fur);
        canvas.drawCircle(const Offset(48, 32), 10, fur);
        canvas.drawCircle(const Offset(32, 34), 23, fur);
        canvas.drawOval(const Rect.fromLTWH(16, 25, 32, 28), face);
        canvas.drawCircle(const Offset(24, 31), 3, dark);
        canvas.drawCircle(const Offset(40, 31), 3, dark);
      case 'lion':
        canvas.drawCircle(const Offset(32, 32), 28, Paint()..color = const Color(0xFFC77926));
        canvas.drawCircle(const Offset(32, 34), 21, Paint()..color = const Color(0xFFE8B55C));
        canvas.drawCircle(const Offset(24, 31), 3, dark);
        canvas.drawCircle(const Offset(40, 31), 3, dark);
      case 'panda':
        canvas.drawCircle(const Offset(18, 18), 10, Paint()..color = const Color(0xFF111827));
        canvas.drawCircle(const Offset(46, 18), 10, Paint()..color = const Color(0xFF111827));
        canvas.drawCircle(const Offset(32, 35), 23, Paint()..color = const Color(0xFFF4F4F5));
        canvas.drawOval(const Rect.fromLTWH(16, 23, 14, 18), Paint()..color = const Color(0xFF111827));
        canvas.drawOval(const Rect.fromLTWH(34, 23, 14, 18), Paint()..color = const Color(0xFF111827));
      case 'cat':
        final fur = Paint()..color = const Color(0xFFD89B5C);
        final shape = Path()
          ..moveTo(13, 22)
          ..lineTo(20, 7)
          ..lineTo(29, 17)
          ..quadraticBezierTo(32, 16, 35, 17)
          ..lineTo(44, 7)
          ..lineTo(51, 22)
          ..quadraticBezierTo(55, 29, 53, 39)
          ..quadraticBezierTo(50, 55, 32, 56)
          ..quadraticBezierTo(14, 55, 11, 39)
          ..quadraticBezierTo(9, 29, 13, 22)
          ..close();
        canvas.drawPath(shape, fur);
        canvas.drawCircle(const Offset(24, 32), 3, dark);
        canvas.drawCircle(const Offset(40, 32), 3, dark);
      default:
        final fur = Paint()..color = const Color(0xFFC99563);
        canvas.drawOval(const Rect.fromLTWH(5, 12, 20, 38), Paint()..color = const Color(0xFF7B5134));
        canvas.drawOval(const Rect.fromLTWH(39, 12, 20, 38), Paint()..color = const Color(0xFF7B5134));
        canvas.drawCircle(const Offset(32, 34), 22, fur);
        canvas.drawCircle(const Offset(24, 31), 3, dark);
        canvas.drawCircle(const Offset(40, 31), 3, dark);
        canvas.drawOval(const Rect.fromLTWH(27, 37, 10, 8), Paint()..color = const Color(0xFF2B211C));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AnimalPainter oldDelegate) => oldDelegate.id != id;
}