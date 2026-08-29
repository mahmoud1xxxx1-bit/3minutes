import 'dart:math' as math;
import '../shared/minigame_environment.dart';
import 'package:flutter/material.dart';
import '../../domain/mini_game_contract.dart';
import 'puzzle_model.dart';
import 'html_canvas.dart';
import 'puzzles/puzzle_01.dart';

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
  late final PuzzleDefinition _puzzle;
  late final Stopwatch _watch;
  final Set<String> _found = <String>{};
  int _mistakes = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _puzzle = _selectPuzzle(widget.config.seed);
    _watch = Stopwatch()..start();
  }

  PuzzleDefinition _selectPuzzle(int seed) {
    final puzzles = [Puzzle01()];
    final index = (seed.abs()) % puzzles.length;
    return puzzles[index];
  }

  @override
  void dispose() {
    _watch.stop();
    super.dispose();
  }

  void _tap(Offset localPosition, Size boardSize) {
    if (_done || boardSize.width <= 0 || boardSize.height <= 0) return;
    final logicalX = (localPosition.dx / boardSize.width) * 800.0;
    final logicalY = (localPosition.dy / boardSize.height) * 600.0;
    Difference? tappedDifference;
    for (final difference in _puzzle.differences) {
      if (difference.hitBox.inflate(30.0).contains(Offset(logicalX, logicalY))) {
        tappedDifference = difference;
        break;
      }
    }
    if (tappedDifference == null || _found.contains(tappedDifference.id)) {
      setState(() => _mistakes++);
      MinigameEnvironment.of(context).playError(localPosition);
      return;
    }
    setState(() => _found.add(tappedDifference!.id));
    MinigameEnvironment.of(context).updateScore(_found.length * 200);
    MinigameEnvironment.of(context).playSuccess(localPosition);
    if (_found.length >= 5) _finish();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _watch.stop();
    final target = _puzzle.differences.length;
    final progress = target == 0 ? 0.0 : _found.length / target;
    final attempts = math.max(1, _found.length + _mistakes);
    final accuracy = _found.isEmpty ? 0.0 : _found.length / attempts;
    final score = math.max(0, (progress * 100).round() - (_mistakes * 4)).toInt();
    widget.onComplete(MiniGameResult(
      completed: true,
      score: score,
      accuracy: accuracy,
      mistakes: _mistakes,
      duration: _watch.elapsed,
    ));
  }

  @override
  Widget build(BuildContext context) {
    MinigameEnvironment.of(context).updateTimeProgress((_watch.elapsedMilliseconds / 30000).clamp(0.0, 1.0));
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1427),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF233B6A)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical = constraints.maxWidth < 560;
          final boardA = _DifferenceBoard(
            key: const ValueKey('find-differences-board-a'),
            puzzle: _puzzle,
            found: _found,
            altered: false,
            onTap: _tap,
          );
          final boardB = _DifferenceBoard(
            key: const ValueKey('find-differences-board-b'),
            puzzle: _puzzle,
            found: _found,
            altered: true,
            onTap: _tap,
          );
          return Directionality(
            textDirection: TextDirection.ltr,
            child: vertical
                ? Column(children: [Expanded(child: boardA), const SizedBox(height: 8), Expanded(child: boardB)])
                : Row(children: [Expanded(child: boardA), const SizedBox(width: 8), Expanded(child: boardB)]),
          );
        },
      ),
    );
  }
}

class _DifferenceBoard extends StatelessWidget {
  const _DifferenceBoard({
    super.key,
    required this.puzzle,
    required this.found,
    required this.altered,
    required this.onTap,
  });

  final PuzzleDefinition puzzle;
  final Set<String> found;
  final bool altered;
  final void Function(Offset position, Size size) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final boardSize = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => onTap(details.localPosition, boardSize),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CustomPaint(
            painter: _PuzzlePainter(puzzle: puzzle, found: found, altered: altered),
          ),
        ),
      );
    });
  }
}

class _PuzzlePainter extends CustomPainter {
  _PuzzlePainter({required this.puzzle, required this.found, required this.altered});
  final PuzzleDefinition puzzle;
  final Set<String> found;
  final bool altered;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 800.0;
    final scaleY = size.height / 600.0;
    final htmlCanvas = HtmlCanvas(canvas, size);
    htmlCanvas.save();
    htmlCanvas.scale(scaleX, scaleY);
    puzzle.drawBaseScene(htmlCanvas);
    for (final diff in puzzle.differences) {
      if (altered) diff.draw(htmlCanvas);
      if (found.contains(diff.id)) {
        htmlCanvas.save();
        htmlCanvas.strokeStyle = '#55FFAE';
        htmlCanvas.lineWidth = 4;
        htmlCanvas.beginPath();
        htmlCanvas.arc(diff.mark.dx, diff.mark.dy, 25, 0, math.pi * 2);
        htmlCanvas.stroke();
        htmlCanvas.restore();
      }
    }
    htmlCanvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PuzzlePainter oldDelegate) =>
      oldDelegate.altered != altered || oldDelegate.puzzle != puzzle || oldDelegate.found.length != found.length;
}
