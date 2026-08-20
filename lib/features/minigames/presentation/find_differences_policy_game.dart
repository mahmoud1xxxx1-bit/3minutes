import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/find_differences_plan.dart';
import '../domain/mini_game_contract.dart';
import 'find_differences_game.dart' show FindDifferencesScenePainter;
import 'mini_game_copy.dart';

/// Policy-compliant production host for Find the Differences.
///
/// This game intentionally has no internal countdown, timeout, scene/variant
/// identifier, or player-visible content-selection metadata. Session timing is
/// owned by the outer game/session policy. The stopwatch below is measurement
/// only, used to populate MiniGameResult.duration when the puzzle is completed.
class FindDifferencesPolicyGame extends StatefulWidget {
  const FindDifferencesPolicyGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<FindDifferencesPolicyGame> createState() => _FindDifferencesPolicyGameState();
}

class _FindDifferencesPolicyGameState extends State<FindDifferencesPolicyGame> {
  late final FindDifferencesPlan _plan;
  late final Stopwatch _measurement;
  final Set<String> _found = <String>{};
  int _mistakes = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _plan = FindDifferencesPlan.fromSeed(
      seed: widget.config.seed,
      difficulty: widget.config.difficulty,
    );
    _measurement = Stopwatch()..start();
  }

  @override
  void dispose() {
    _measurement.stop();
    super.dispose();
  }

  void _tap(Offset localPosition, Size boardSize) {
    if (_done || boardSize.width <= 0 || boardSize.height <= 0) return;
    final logical = Offset(
      localPosition.dx / boardSize.width * FindDifferencesPlan.logicalWidth,
      localPosition.dy / boardSize.height * FindDifferencesPlan.logicalHeight,
    );
    final difference = _plan.hitTest(logical.dx, logical.dy, _found);
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
    _measurement.stop();
    final target = _plan.differences.length;
    final progress = target == 0 ? 0.0 : _found.length / target;
    final attempts = (_found.length + _mistakes).clamp(1, 9999);
    final accuracy = _found.isEmpty ? 0.0 : _found.length / attempts;
    final score = math.max(0, (progress * 100).round() - (_mistakes * 4)).toInt();
    widget.onComplete(
      MiniGameResult(
        completed: true,
        score: score,
        accuracy: accuracy,
        mistakes: _mistakes,
        duration: _measurement.elapsed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = MiniGameCopy.fromContext(context);
    return Column(
      children: [
        Text(
          copy.findDifferencesInstruction,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            _StatusPill(
              key: const ValueKey('find-differences-found'),
              label: '${copy.findDifferencesFound}: ${_found.length}/${_plan.differences.length}',
            ),
            _StatusPill(
              key: const ValueKey('find-differences-mistakes'),
              label: '${copy.findDifferencesMistakes}: $_mistakes',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 560;
              final boardA = _DifferenceBoard(
                key: const ValueKey('find-differences-board-a'),
                label: 'A',
                plan: _plan,
                found: _found,
                altered: false,
                onTap: _tap,
              );
              final boardB = _DifferenceBoard(
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
                          Expanded(child: boardA),
                          const SizedBox(height: 8),
                          Expanded(child: boardB),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: boardA),
                          const SizedBox(width: 8),
                          Expanded(child: boardB),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({super.key, required this.label});
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
