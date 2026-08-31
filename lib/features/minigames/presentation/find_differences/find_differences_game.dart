import 'dart:async';
import 'dart:math' as math;
import '../shared/minigame_environment.dart';
import 'package:flutter/material.dart';
import '../../domain/mini_game_contract.dart';
import '../mini_game_copy.dart';
import 'puzzle_model.dart';
import 'html_canvas.dart';

// Puzzles 01 to 30
import 'puzzles/puzzle_01.dart';
import 'puzzles/puzzle_02.dart';
import 'puzzles/puzzle_03.dart';
import 'puzzles/puzzle_04.dart';
import 'puzzles/puzzle_05.dart';
import 'puzzles/puzzle_06.dart';
import 'puzzles/puzzle_07.dart';
import 'puzzles/puzzle_08.dart';
import 'puzzles/puzzle_09.dart';
import 'puzzles/puzzle_10.dart';
import 'puzzles/puzzle_11.dart';
import 'puzzles/puzzle_12.dart';
import 'puzzles/puzzle_13.dart';
import 'puzzles/puzzle_14.dart';
import 'puzzles/puzzle_15.dart';
import 'puzzles/puzzle_16.dart';
import 'puzzles/puzzle_17.dart';
import 'puzzles/puzzle_18.dart';
import 'puzzles/puzzle_19.dart';
import 'puzzles/puzzle_20.dart';
import 'puzzles/puzzle_21.dart';
import 'puzzles/puzzle_22.dart';
import 'puzzles/puzzle_23.dart';
import 'puzzles/puzzle_24.dart';
import 'puzzles/puzzle_25.dart';
import 'puzzles/puzzle_26.dart';
import 'puzzles/puzzle_27.dart';
import 'puzzles/puzzle_28.dart';
import 'puzzles/puzzle_29.dart';
import 'puzzles/puzzle_30.dart';
import 'puzzles/puzzle_31.dart';
import 'puzzles/puzzle_32.dart';
import 'puzzles/puzzle_33.dart';
import 'puzzles/puzzle_34.dart';
import 'puzzles/puzzle_35.dart';
import 'puzzles/puzzle_36.dart';
import 'puzzles/puzzle_37.dart';
import 'puzzles/puzzle_38.dart';
import 'puzzles/puzzle_39.dart';
import 'puzzles/puzzle_40.dart';
import 'puzzles/puzzle_41.dart';
import 'puzzles/puzzle_42.dart';
import 'puzzles/puzzle_43.dart';
import 'puzzles/puzzle_44.dart';
import 'puzzles/puzzle_45.dart';


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
    final puzzles = [
      Puzzle01(), Puzzle02(), Puzzle03(), Puzzle04(), Puzzle05(),
      Puzzle06(), Puzzle07(), Puzzle08(), Puzzle09(), Puzzle10(),
      Puzzle11(), Puzzle12(), Puzzle13(), Puzzle14(), Puzzle15(),
      Puzzle16(), Puzzle17(), Puzzle18(), Puzzle19(), Puzzle20(),
      Puzzle21(), Puzzle22(), Puzzle23(), Puzzle24(), Puzzle25(),
      Puzzle26(), Puzzle27(), Puzzle28(), Puzzle29(), Puzzle30(),
      Puzzle31(), Puzzle32(), Puzzle33(), Puzzle34(), Puzzle35(),
      Puzzle36(), Puzzle37(), Puzzle38(), Puzzle39(), Puzzle40(),
      Puzzle41(), Puzzle42(), Puzzle43(), Puzzle44(), Puzzle45(),
    ];
    // Deterministic selection based on seed
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
    
    // Convert local tap coordinate to logical 800x600 coordinate
    final double logicalX = (localPosition.dx / boardSize.width) * 800.0;
    final double logicalY = (localPosition.dy / boardSize.height) * 600.0;
    
    Difference? tappedDifference;
    for (final difference in _puzzle.differences) {
      if (difference.hitBox.inflate(30.0).contains(Offset(logicalX, logicalY))) {
        tappedDifference = difference;
        break;
      }
    }

    if (tappedDifference == null || _found.contains(tappedDifference!.id)) {
      setState(() => _mistakes++);
      MinigameEnvironment.of(context).playError(localPosition);
      return;
    }

    setState(() => _found.add(tappedDifference!.id));
    MinigameEnvironment.of(context).updateScore(_found.length * 200);
    MinigameEnvironment.of(context).playSuccess(localPosition);
    
    if (_found.length >= 5) { // 5 is the fixed number of differences
      _finish();
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _watch.stop();

    final target = _puzzle.differences.length; // Always 5
    final progress = target == 0 ? 0.0 : _found.length / target;
    final attempts = math.max(1, _found.length + _mistakes);
    final accuracy = _found.isEmpty ? 0.0 : _found.length / attempts;
    final score = math.max(0, (progress * 100).round() - (_mistakes * 4)).toInt();

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
                label: 'A',
                puzzle: _puzzle,
                found: _found,
                altered: false,
                onTap: _tap,
              );
              final boardB = _DifferenceBoard(
                key: const ValueKey('find-differences-board-b'),
                label: 'B',
                puzzle: _puzzle,
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
    );
  }
}

class _FindPill extends StatelessWidget {
  const _FindPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF19DCE8).withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF52F2F2).withValues(alpha: .25)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF52F2F2),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _DifferenceBoard extends StatelessWidget {
  const _DifferenceBoard({
    super.key,
    required this.label,
    required this.puzzle,
    required this.found,
    required this.altered,
    required this.onTap,
  });

  final String label;
  final PuzzleDefinition puzzle;
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
                  painter: _PuzzlePainter(
                    puzzle: puzzle,
                    found: found,
                    altered: altered,
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

class _PuzzlePainter extends CustomPainter {
  _PuzzlePainter({
    required this.puzzle,
    required this.found,
    required this.altered,
  });

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
    
    // Draw base
    puzzle.drawBaseScene(htmlCanvas);
    
    // Apply differences if altered
    for (final diff in puzzle.differences) {
      if (altered) {
        diff.draw(htmlCanvas);
      }
      // Highlight found differences
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
  bool shouldRepaint(covariant _PuzzlePainter oldDelegate) {
    return oldDelegate.altered != altered || 
           oldDelegate.puzzle != puzzle || 
           oldDelegate.found.length != found.length;
  }
}



