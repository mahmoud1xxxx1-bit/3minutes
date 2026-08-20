import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/find_differences_plan.dart';
import '../domain/mini_game_contract.dart';
import 'mini_game_copy.dart';

class FindDifferencesGame extends StatefulWidget {
  const FindDifferencesGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<FindDifferencesGame> createState() => _FindDifferencesGameState();
}

class _FindDifferencesGameState extends State<FindDifferencesGame> {
  late final FindDifferencesPlan _plan;
  late final Stopwatch _watch;
  Timer? _timer;
  final Set<String> _found = <String>{};
  int _mistakes = 0;
  Duration _remaining = Duration.zero;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _plan = FindDifferencesPlan.fromSeed(
      seed: widget.config.seed,
      difficulty: widget.config.difficulty,
    );
    _remaining = _plan.duration;
    _watch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _done) return;
      final left = _plan.duration - _watch.elapsed;
      if (left <= Duration.zero) {
        setState(() => _remaining = Duration.zero);
        _finish();
      } else {
        setState(() => _remaining = left);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _watch.stop();
    super.dispose();
  }

  void _tap(Offset localPosition, Size boardSize) {
    if (_done || boardSize.width <= 0 || boardSize.height <= 0) return;
    final logicalX = localPosition.dx / boardSize.width * FindDifferencesPlan.logicalWidth;
    final logicalY = localPosition.dy / boardSize.height * FindDifferencesPlan.logicalHeight;
    final difference = _plan.hitTest(logicalX, logicalY, _found);
    if (difference == null) {
      setState(() => _mistakes++);
      return;
    }
    setState(() => _found.add(difference.id));
    if (_found.length == _plan.differences.length) _finish();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    _watch.stop();
    final target = _plan.differences.length;
    final progress = target == 0 ? 0.0 : _found.length / target;
    final accuracy = _found.isEmpty
        ? 0.0
        : _found.length / (_found.length + _mistakes).clamp(1, 9999);
    final score = math.max(0, (progress * 100).round() - (_mistakes * 4));
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
    final code = 'S01-${(_plan.variantIndex + 1).toString().padLeft(2, '0')}';
    final seconds = (_remaining.inMilliseconds / 1000).clamp(0, 999).toStringAsFixed(1);
    return Column(
      children: [
        Text(
          copy.findDifferencesInstruction,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            _FindPill(label: code),
            _FindPill(label: '${copy.findDifferencesFound}: ${_found.length}/${_plan.differences.length}'),
            _FindPill(label: '${copy.findDifferencesMistakes}: $_mistakes'),
            _FindPill(label: '${copy.findDifferencesTime}: $seconds'),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 560;
              final first = _DifferenceBoard(
                key: const ValueKey('find-differences-board-a'),
                label: 'A',
                plan: _plan,
                found: _found,
                altered: false,
                onTap: _tap,
              );
              final second = _DifferenceBoard(
                key: const ValueKey('find-differences-board-b'),
                label: 'B',
                plan: _plan,
                found: _found,
                altered: true,
                onTap: _tap,
              );
              return Directionality(
                textDirection: TextDirection.ltr,
                child: vertical
                    ? Column(
                        children: [
                          Expanded(child: first),
                          const SizedBox(height: 8),
                          Expanded(child: second),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: first),
                          const SizedBox(width: 8),
                          Expanded(child: second),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FindPill extends StatelessWidget {
  const _FindPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF19DCE8).withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF52F2F2).withValues(alpha: .25)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF52F2F2),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _DifferenceBoard extends StatelessWidget {
  const _DifferenceBoard({
    super.key,
    required this.label,
    required this.plan,
    required this.found,
    required this.altered,
    required this.onTap,
  });

  final String label;
  final FindDifferencesPlan plan;
  final Set<String> found;
  final bool altered;
  final void Function(Offset position, Size size) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => onTap(details.localPosition, boardSize),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: FindDifferencesScenePainter(
                    plan: plan,
                    found: found,
                    altered: altered,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xE8071226),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF52779A)),
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

@visibleForTesting
Offset findDifferencesLogicalPoint(Offset localPosition, Size boardSize) {
  return Offset(
    localPosition.dx / boardSize.width * FindDifferencesPlan.logicalWidth,
    localPosition.dy / boardSize.height * FindDifferencesPlan.logicalHeight,
  );
}

class FindDifferencesScenePainter extends CustomPainter {
  const FindDifferencesScenePainter({
    required this.plan,
    required this.found,
    required this.altered,
  });

  final FindDifferencesPlan plan;
  final Set<String> found;
  final bool altered;

  bool _has(String id) => altered && plan.differences.any((d) => d.id == id);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(
      size.width / FindDifferencesPlan.logicalWidth,
      size.height / FindDifferencesPlan.logicalHeight,
    );
    _paintScene(canvas);
    for (final difference in plan.differences) {
      if (_has(difference.id)) _paintDifference(canvas, difference);
      if (found.contains(difference.id)) _paintFound(canvas, difference);
    }
    canvas.restore();
  }

  void _paintScene(Canvas c) {
    final wall = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF202B3F), Color(0xFF151522)],
      ).createShader(const Rect.fromLTWH(0, 0, 800, 600));
    c.drawRect(const Rect.fromLTWH(0, 0, 800, 600), wall);
    c.drawRect(const Rect.fromLTWH(0, 470, 800, 130), Paint()..color = const Color(0xFF7B5D49));

    final frame = RRect.fromRectAndRadius(const Rect.fromLTWH(55, 55, 250, 205), const Radius.circular(14));
    c.drawRRect(frame, Paint()..color = const Color(0xFF0C1622));
    final skyRect = const Rect.fromLTWH(68, 68, 224, 179);
    c.drawRRect(
      RRect.fromRectAndRadius(skyRect, const Radius.circular(8)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF173D5D), Color(0xFF0C1C31)],
        ).createShader(skyRect),
    );
    if (!_has('moon_missing')) {
      c.drawCircle(
        const Offset(110, 103),
        28,
        Paint()..color = _has('moon_color') ? const Color(0xFFFF9B67) : const Color(0xFFF8DF8F),
      );
      c.drawCircle(const Offset(124, 95), 30, Paint()..color = const Color(0xFF173D5D));
    }
    final hills = Path()
      ..moveTo(68, 210)
      ..quadraticBezierTo(130, 155, 205, 210)
      ..quadraticBezierTo(255, 165, 292, 205)
      ..lineTo(292, 247)
      ..lineTo(68, 247)
      ..close();
    c.drawPath(hills, Paint()..color = const Color(0xFF15382F));

    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(338, 65, 180, 135), const Radius.circular(10)),
      Paint()..color = const Color(0xFF141B27),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(352, 79, 152, 107), const Radius.circular(6)),
      Paint()..color = const Color(0xFF1D4054),
    );
    c.drawCircle(
      const Offset(430, 115),
      24,
      Paint()..color = _has('painting_detail') ? const Color(0xFF69D8FF) : const Color(0xFFE5BD70),
    );
    final mountains = Path()
      ..moveTo(360, 180)
      ..lineTo(400, 135)
      ..lineTo(435, 170)
      ..lineTo(466, 125)
      ..lineTo(495, 180)
      ..close();
    c.drawPath(mountains, Paint()..color = const Color(0xFF4F9878));

    c.drawCircle(const Offset(620, 118), 55, Paint()..color = const Color(0xFF101721));
    c.drawCircle(
      const Offset(620, 118),
      55,
      Paint()
        ..color = const Color(0xFFE7ECE7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    final clockPaint = Paint()
      ..color = const Color(0xFFE7ECE7)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawLine(const Offset(620, 118), const Offset(620, 82), clockPaint);
    c.drawLine(
      const Offset(620, 118),
      _has('clock_time') ? const Offset(653, 90) : const Offset(646, 92),
      clockPaint,
    );

    c.drawRect(const Rect.fromLTWH(590, 210, 150, 13), Paint()..color = const Color(0xFF6B4A35));
    if (!_has('book_color')) c.drawRect(const Rect.fromLTWH(610, 160, 22, 50), Paint()..color = const Color(0xFF61B9C5));
    if (_has('book_color')) c.drawRect(const Rect.fromLTWH(610, 160, 22, 50), Paint()..color = const Color(0xFFFF7A90));
    if (!_has('book_missing')) c.drawRect(const Rect.fromLTWH(640, 148, 22, 62), Paint()..color = const Color(0xFFE2BF67));
    c.drawRect(
      _has('book_short') ? const Rect.fromLTWH(670, 182, 22, 28) : const Rect.fromLTWH(670, 166, 22, 44),
      Paint()..color = const Color(0xFF7B91D5),
    );

    c.drawLine(
      const Offset(700, 325),
      const Offset(700, 475),
      Paint()
        ..color = _has('lamp_stem') ? const Color(0xFFFF6C83) : const Color(0xFFCBD6D9)
        ..strokeWidth = 8,
    );
    final shade = Path()
      ..moveTo(650, 265)
      ..lineTo(750, 265)
      ..lineTo(730, 325)
      ..lineTo(670, 325)
      ..close();
    c.drawPath(shade, Paint()..color = _has('lamp_shade') ? const Color(0xFFF1AD4F) : const Color(0xFF55A9A8));
    c.drawOval(const Rect.fromLTWH(645, 472, 110, 26), Paint()..color = const Color(0xFFBBC0C7));

    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(180, 330, 390, 160), const Radius.circular(30)),
      Paint()..color = const Color(0xFF4B6D78),
    );
    _cushion(c, const Rect.fromLTWH(235, 355, 90, 75), _has('cushion_left') ? const Color(0xFF718CAF) : const Color(0xFFD37172));
    _cushion(c, const Rect.fromLTWH(342, 363, 90, 67), _has('cushion_middle') ? const Color(0xFF68B887) : const Color(0xFFDC9B67));
    _cushion(c, const Rect.fromLTWH(450, 356, 88, 74), _has('cushion_right') ? const Color(0xFFB779C7) : const Color(0xFFD9E1D8));

    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(250, 480, 360, 34), const Radius.circular(12)),
      Paint()..color = _has('table_top') ? const Color(0xFF6E86A3) : const Color(0xFFA06A46),
    );
    c.drawRect(const Rect.fromLTWH(285, 510, 20, 80), Paint()..color = const Color(0xFF6A4634));
    if (!_has('table_leg')) c.drawRect(const Rect.fromLTWH(555, 510, 20, 80), Paint()..color = const Color(0xFF6A4634));

    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(270, 430, 62, 58), const Radius.circular(10)),
      Paint()..color = _has('mug_color') ? const Color(0xFFE9776E) : const Color(0xFFECE9DB),
    );
    if (!_has('mug_handle')) {
      c.drawArc(
        const Rect.fromLTWH(310, 440, 36, 36),
        -math.pi / 2,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFFECE9DB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
    }

    c.drawOval(const Rect.fromLTWH(390, 440, 160, 44), Paint()..color = const Color(0xFF2D414C));
    c.drawCircle(const Offset(440, 447), 18, Paint()..color = _has('fruit_color') ? const Color(0xFF80A7FF) : const Color(0xFFEFC35C));
    c.drawCircle(const Offset(470, 450), 18, Paint()..color = _has('fruit_color_2') ? const Color(0xFFFFD768) : const Color(0xFFE97876));
    if (!_has('fruit_missing')) c.drawCircle(const Offset(500, 453), 18, Paint()..color = const Color(0xFF6BC083));

    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(70, 395, 90, 95), const Radius.circular(18)),
      Paint()..color = _has('plant_pot') ? const Color(0xFF4D7599) : const Color(0xFF8D5A3D),
    );
    for (var i = 0; i < 5; i++) {
      if (_has('plant_leaf') && i == 0) continue;
      c.drawOval(
        Rect.fromCenter(center: Offset(85 + i * 18, 300 + i * 8), width: 36, height: 72),
        Paint()..color = const Color(0xFF66B77A),
      );
    }
  }

  void _cushion(Canvas c, Rect rect, Color color) {
    c.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), Paint()..color = color);
  }

  void _paintDifference(Canvas c, FindDifference difference) {
    if (difference.id == 'painting_peak') {
      final path = _pathFor(difference);
      c.drawPath(path, Paint()..color = const Color(0xFFFF7B85));
    }
  }

  void _paintFound(Canvas c, FindDifference difference) {
    final center = Offset(difference.centerX, difference.centerY);
    c.drawCircle(
      center,
      20,
      Paint()
        ..color = const Color(0xFF55FFAE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  Path _pathFor(FindDifference difference) {
    final path = Path();
    if (difference.shape == FindDifferenceShape.rect) {
      path.addRect(Rect.fromLTWH(difference.x, difference.y, difference.width, difference.height));
    } else if (difference.shape == FindDifferenceShape.circle) {
      path.addOval(Rect.fromLTWH(difference.x, difference.y, difference.width, difference.height));
    } else if (difference.points.isNotEmpty) {
      path.moveTo(difference.points.first.x, difference.points.first.y);
      for (final point in difference.points.skip(1)) {
        path.lineTo(point.x, point.y);
      }
      path.close();
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant FindDifferencesScenePainter oldDelegate) {
    return oldDelegate.plan != plan ||
        oldDelegate.altered != altered ||
        !setEquals(oldDelegate.found, found);
  }
}
