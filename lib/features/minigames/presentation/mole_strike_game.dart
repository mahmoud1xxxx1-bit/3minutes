import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/mini_game_contract.dart';
import '../domain/mole_strike_plan.dart';
import 'mini_game_copy.dart';

class MoleStrikeGame extends StatefulWidget {
  const MoleStrikeGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<MoleStrikeGame> createState() => _MoleStrikeGameState();
}

class _MoleStrikeGameState extends State<MoleStrikeGame> {
  late final MoleStrikePlan _plan;
  late final Stopwatch _watch;
  final List<Timer> _timers = <Timer>[];

  int _waveIndex = 0;
  int _hits = 0;
  int _mistakes = 0;
  int? _realHole;
  int? _decoyHole;
  final Set<int> _warningHoles = <int>{};
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _plan = MoleStrikePlan.fromSeed(
      seed: widget.config.seed,
      difficulty: widget.config.difficulty,
    );
    _watch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleWave();
    });
  }

  @override
  void dispose() {
    _cancelTimers();
    _watch.stop();
    super.dispose();
  }

  void _cancelTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  Timer _later(Duration duration, void Function() callback) {
    late final Timer timer;
    timer = Timer(duration, () {
      _timers.remove(timer);
      if (mounted && !_done) callback();
    });
    _timers.add(timer);
    return timer;
  }

  void _scheduleWave() {
    if (_done || _waveIndex >= _plan.waves.length) return;
    final wave = _plan.waves[_waveIndex++];

    setState(() {
      _warningHoles
        ..clear()
        ..add(wave.realHole);
      if (wave.decoyHole != null) _warningHoles.add(wave.decoyHole!);
    });

    const warning = Duration(milliseconds: 85);
    _later(warning, () {
      setState(() {
        _warningHoles.remove(wave.realHole);
        _realHole = wave.realHole;
      });

      _later(Duration(milliseconds: wave.visibleMs), () {
        if (_realHole == wave.realHole) {
          setState(() {
            _realHole = null;
            _mistakes++;
          });
        }
      });
    });

    final decoy = wave.decoyHole;
    if (decoy != null) {
      _later(Duration(milliseconds: 85 + wave.decoyLagMs), () {
        setState(() {
          _warningHoles.remove(decoy);
          _decoyHole = decoy;
        });
        _later(Duration(milliseconds: wave.visibleMs), () {
          if (_decoyHole == decoy) setState(() => _decoyHole = null);
        });
      });
    }

    final occupiedMs = 85 +
        math
            .max(
              wave.visibleMs,
              decoy == null ? 0 : wave.decoyLagMs + wave.visibleMs,
            )
            .toInt();
    _later(Duration(milliseconds: occupiedMs + wave.gapMs), _scheduleWave);
  }

  void _tapHole(int hole) {
    if (_done) return;

    if (_decoyHole == hole) {
      setState(() {
        _decoyHole = null;
        _mistakes++;
      });
      return;
    }

    if (_realHole != hole) return;

    setState(() {
      _realHole = null;
      _hits++;
    });

    if (_hits >= MoleStrikePlan.goal) _finish();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _cancelTimers();
    _watch.stop();

    final accuracy = MoleStrikePlan.goal /
        (MoleStrikePlan.goal + _mistakes).clamp(MoleStrikePlan.goal, 9999);
    final score = math.max(20, 100 - (_mistakes * 5)).toInt();

    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: score,
        accuracy: accuracy,
        mistakes: _mistakes,
        duration: _watch.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = MiniGameCopy.fromContext(context);
    final family = (_plan.familyIndex + 1).toString().padLeft(2, '0');

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Text(
              copy.moleStrikeInstruction,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatusPill(
                  label: '${copy.moleStrikeHits}: $_hits/${MoleStrikePlan.goal}',
                ),
                const SizedBox(width: 8),
                _StatusPill(label: 'F$family'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return _MoleSlot(
                    warning: _warningHoles.contains(index),
                    real: _realHole == index,
                    decoy: _decoyHole == index,
                    onTap: () => _tapHole(index),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.primary.withValues(alpha: .25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MoleSlot extends StatelessWidget {
  const _MoleSlot({
    required this.warning,
    required this.real,
    required this.decoy,
    required this.onTap,
  });

  final bool warning;
  final bool real;
  final bool decoy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: real || decoy ? onTap : null,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 10,
            right: 10,
            bottom: 8,
            height: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.all(Radius.elliptical(60, 22)),
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF020612),
                    warning
                        ? colors.primary.withValues(alpha: .45)
                        : const Color(0xFF102044),
                    Colors.transparent,
                  ],
                  stops: const [0, .62, 1],
                ),
                boxShadow: warning
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: .30),
                          blurRadius: 12,
                        ),
                      ]
                    : const [],
              ),
            ),
          ),
          AnimatedSlide(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutBack,
            offset: real || decoy ? Offset.zero : const Offset(0, .72),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: real || decoy ? 1 : 0,
              child: SizedBox(
                width: 86,
                height: 96,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(
                      child: CustomPaint(painter: _SquirrelPainter()),
                    ),
                    if (decoy)
                      Positioned(
                        top: 2,
                        right: 0,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF526D),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SquirrelPainter extends CustomPainter {
  const _SquirrelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 86;
    final sy = size.height / 96;
    canvas.save();
    canvas.scale(sx, sy);

    final tail = Paint()
      ..color = const Color(0xFF9B6038)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final tailPath = Path()
      ..moveTo(65, 30)
      ..cubicTo(88, 4, 96, 24, 78, 36)
      ..cubicTo(96, 38, 92, 64, 70, 58);
    canvas.drawPath(tailPath, tail);

    final fur = Paint()..color = const Color(0xFFC98754);
    final cream = Paint()..color = const Color(0xFFFFE0B8);
    final dark = Paint()..color = const Color(0xFF3C261D);
    final pink = Paint()..color = const Color(0xFFEFA491);
    final nut = Paint()..color = const Color(0xFF9E6238);

    canvas.drawOval(const Rect.fromLTWH(17, 10, 24, 30), fur);
    canvas.drawOval(const Rect.fromLTWH(47, 10, 24, 30), fur);
    canvas.drawCircle(const Offset(44, 50), 30, fur);
    canvas.drawOval(const Rect.fromLTWH(25, 49, 38, 31), cream);
    canvas.drawCircle(const Offset(34, 44), 4, dark);
    canvas.drawCircle(const Offset(54, 44), 4, dark);
    canvas.drawCircle(const Offset(44, 53), 5, dark);
    canvas.drawOval(const Rect.fromLTWH(25, 55, 8, 5), pink);
    canvas.drawOval(const Rect.fromLTWH(55, 55, 8, 5), pink);
    canvas.drawOval(const Rect.fromLTWH(37, 67, 15, 22), nut);
    canvas.drawArc(
      const Rect.fromLTWH(34, 64, 21, 10),
      math.pi,
      math.pi,
      false,
      dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
