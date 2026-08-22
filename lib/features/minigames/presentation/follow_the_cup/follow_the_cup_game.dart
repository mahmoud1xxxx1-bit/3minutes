import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/follow_the_cup_plan.dart';
import '../../domain/mini_game_contract.dart';
import '../mini_game_copy.dart';

class FollowTheCupGame extends StatefulWidget {
  const FollowTheCupGame({super.key, required this.config, required this.onComplete});

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<FollowTheCupGame> createState() => _FollowTheCupGameState();
}

class _FollowTheCupGameState extends State<FollowTheCupGame> {
  late final FollowTheCupPlan _plan;
  late final Stopwatch _watch;
  late List<int> _positions;
  int _roundIndex = 0;
  int _correct = 0;
  int _mistakes = 0;
  int? _targetCup;
  int? _selectedCup;
  bool _showBall = false;
  bool _liftTarget = false;
  bool _choosing = false;
  bool _done = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _plan = FollowTheCupPlan.fromSeed(seed: widget.config.seed, difficulty: widget.config.difficulty);
    _positions = List<int>.generate(_plan.cupCount, (i) => i);
    _watch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playRound());
  }

  Future<void> _wait(int ms) async {
    await Future<void>.delayed(Duration(milliseconds: ms));
  }

  double _xFor(int position) {
    final left = _plan.cupCount == 3 ? .20 : .13;
    final right = _plan.cupCount == 3 ? .80 : .87;
    return left + (right - left) * position / (_plan.cupCount - 1);
  }

  Future<void> _playRound() async {
    if (!mounted || _done) return;
    final round = _plan.rounds[_roundIndex];
    _positions = List<int>.generate(_plan.cupCount, (i) => i);
    setState(() {
      _targetCup = round.startCup;
      _selectedCup = null;
      _showBall = true;
      _liftTarget = true;
      _choosing = false;
      _status = 'احفظ مكان الكرة';
    });
    await _wait(800);
    if (!mounted || _done) return;
    setState(() => _liftTarget = false);
    await _wait(260);
    if (!mounted || _done) return;
    setState(() { _showBall = false; _status = 'تابع الكأس'; });
    await _wait(200);

    for (final swap in round.swaps) {
      if (!mounted || _done) return;
      final aId = _positions.indexOf(swap.a);
      final bId = _positions.indexOf(swap.b);
      setState(() {
        final t = _positions[aId];
        _positions[aId] = _positions[bId];
        _positions[bId] = t;
      });
      await _wait(_plan.moveMs + _plan.pauseMs);
    }
    if (!mounted || _done) return;
    setState(() { _choosing = true; _status = 'اختر الكأس'; });
  }

  Future<void> _choose(int cupId) async {
    if (!_choosing || _done) return;
    final ok = cupId == _targetCup;
    setState(() {
      _choosing = false;
      _selectedCup = cupId;
      _showBall = true;
      _liftTarget = true;
      if (ok) { _correct++; _status = 'CORRECT'; } else { _mistakes++; _status = 'WRONG'; }
    });
    await _wait(900);
    if (!mounted || _done) return;
    setState(() { _showBall = false; _liftTarget = false; _selectedCup = null; });
    _roundIndex++;
    if (_roundIndex >= FollowTheCupPlan.roundCount) {
      _finish();
      return;
    }
    await _wait(250);
    await _playRound();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _watch.stop();
    final accuracy = _correct / FollowTheCupPlan.roundCount;
    widget.onComplete(MiniGameResult(
      completed: true,
      score: (accuracy * 10000).round(),
      accuracy: accuracy,
      mistakes: _mistakes,
      duration: _watch.elapsed,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final copy = MiniGameCopy.fromContext(context);
    final family = (_plan.familyIndex + 1).toString().padLeft(2, '0');
    final target = _targetCup;
    final ballX = target == null ? .5 : _xFor(_positions[target]);
    return Column(children: [
      Text(copy.followCupInstruction, textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _CupPill(label: '${copy.followCupCorrect}: $_correct/${FollowTheCupPlan.roundCount}'),
        const SizedBox(width: 8),
        _CupPill(label: '${copy.findDifferencesMistakes}: $_mistakes'),
      ]),
      const SizedBox(height: 10),
      Expanded(child: LayoutBuilder(builder: (context, c) {
        final width = c.maxWidth;
        final height = c.maxHeight;
        final cupWidth = math.min(92.0, width / (_plan.cupCount + .8));
        final cupHeight = cupWidth * 1.37;
        final top = math.max(72.0, height * .25);
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF061126), Color(0xFF091B35), Color(0xFF050A14)]),
            ),
            child: Stack(children: [
              Positioned(left: width * .06, right: width * .06, bottom: 34, height: 90,
                child: DecoratedBox(decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.elliptical(300, 80)),
                  gradient: const RadialGradient(colors: [Color(0xFF1A3A62), Color(0xFF0D203B), Color(0xFF030711)]),
                  boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 26, offset: Offset(0, 16))],
                ))),
              Positioned(top: 22, left: 0, right: 0, child: Text(_status, textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w900,
                  color: _status == 'WRONG' ? const Color(0xFFFF667E) : _status == 'CORRECT' ? const Color(0xFF4DDA9A) : const Color(0xFFFFCD68)))),
              if (_showBall)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: width * ballX - 12,
                  top: top + cupHeight - 12,
                  child: const _Ball(),
                ),
              for (var id = 0; id < _plan.cupCount; id++)
                AnimatedPositioned(
                  key: ValueKey('cup-$id'),
                  duration: Duration(milliseconds: _plan.moveMs),
                  curve: const Cubic(.22, .75, .18, 1),
                  left: width * _xFor(_positions[id]) - cupWidth / 2,
                  top: top - ((_liftTarget && id == target) ? 58 : 0) - ((_selectedCup == id) ? 5 : 0),
                  width: cupWidth,
                  height: cupHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _choosing ? () => _choose(id) : null,
                    child: _Cup(
                      good: _showBall && _roundIndex < _plan.rounds.length && id == target && _selectedCup != null,
                      bad: _selectedCup == id && id != target,
                    ),
                  ),
                ),
            ]),
          ),
        );
      })),
    ]);
  }
}

class _CupPill extends StatelessWidget {
  const _CupPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: const Color(0xFF19DCE8).withValues(alpha: .10), borderRadius: BorderRadius.circular(999), border: Border.all(color: const Color(0xFF52F2F2).withValues(alpha: .25))),
    child: Text(label, style: const TextStyle(color: Color(0xFF52F2F2), fontSize: 11, fontWeight: FontWeight.w900)),
  );
}

class _Ball extends StatelessWidget {
  const _Ball();
  @override
  Widget build(BuildContext context) => Container(width: 24, height: 24,
    decoration: const BoxDecoration(shape: BoxShape.circle,
      gradient: RadialGradient(center: Alignment(-.35, -.35), colors: [Colors.white, Color(0xFFFFF1B5), Color(0xFFFFCD68), Color(0xFFD37D18), Color(0xFF6F3608)]),
      boxShadow: [BoxShadow(color: Color(0xBBFFCD68), blurRadius: 18), BoxShadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 8))]));
}

class _Cup extends StatelessWidget {
  const _Cup({required this.good, required this.bad});
  final bool good; final bool bad;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _CupPainter(good: good, bad: bad));
}

class _CupPainter extends CustomPainter {
  const _CupPainter({required this.good, required this.bad});
  final bool good; final bool bad;
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100, sy = size.height / 140;
    canvas.save(); canvas.scale(sx, sy);
    final shadow = Paint()..color = const Color(0xBF061222);
    canvas.drawOval(const Rect.fromLTWH(14, 108, 72, 20), shadow);
    final body = Path()..moveTo(27, 18)..lineTo(73, 18)..lineTo(88, 114)..quadraticBezierTo(89, 129, 73, 129)..lineTo(27, 129)..quadraticBezierTo(11, 129, 12, 114)..close();
    final rect = const Rect.fromLTWH(10, 18, 80, 111);
    final paint = Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFFEDF9FF), Color(0xFFBDE8F4), Color(0xFF6FA9BF), Color(0xFF3F6786), Color(0xFF24405F), Color(0xFF152741)]).createShader(rect);
    if (good || bad) { paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 5); canvas.drawPath(body, Paint()..color = good ? const Color(0xFF4DDA9A) : const Color(0xFFFF667E)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)); }
    canvas.drawPath(body, paint);
    canvas.drawOval(const Rect.fromLTWH(26, 10.5, 48, 15), Paint()..color = const Color(0xFF10243A));
    canvas.drawOval(const Rect.fromLTWH(32, 13.5, 36, 9), Paint()..color = const Color(0xFF06111F));
    canvas.drawArc(const Rect.fromLTWH(26, 10.5, 48, 15), 0, math.pi * 2, false, Paint()..color = const Color(0xFF53EAF0)..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawLine(const Offset(31, 31), const Offset(39, 104), Paint()..color = Colors.white.withValues(alpha: .18)..strokeWidth = 4..strokeCap = StrokeCap.round);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _CupPainter oldDelegate) => oldDelegate.good != good || oldDelegate.bad != bad;
}
