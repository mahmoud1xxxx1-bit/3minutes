import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/mini_game_contract.dart';
import '../shared/minigame_environment.dart';
import 'key_escape_levels.dart';

class KeyEscapeGame extends StatefulWidget {
  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  const KeyEscapeGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  @override
  State<KeyEscapeGame> createState() => _KeyEscapeGameState();
}

class _KeyEscapeGameState extends State<KeyEscapeGame> {
  late List<PuzzleBlock> _blocks;
  PuzzleBlock? _draggingBlock;
  double _minDrag = 0;
  double _maxDrag = 0;

  bool _isRoundOver = false;
  bool _roundWon = false;

  late int _baseLevel;
  int _puzzleInStage = 0;
  int _currentLevel = 0;

  int _moves = 0;
  int _initialX = 0;
  int _initialY = 0;

  int get _targetMoves => KeyEscapeLevels.getTargetMoves(_currentLevel);
  int get _mistakes => math.max(0, _moves - _targetMoves);

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.config.seed);
    _baseLevel = rng.nextInt(90);
    _startStage();
  }

  void _startStage() {
    _puzzleInStage = 0;
    _loadPuzzle();
  }

  void _loadPuzzle() {
    setState(() {
      _currentLevel = (_baseLevel + _puzzleInStage) % 90;
      _blocks = KeyEscapeLevels.getLevel(_currentLevel);
      _moves = 0;
      _isRoundOver = false;
      _roundWon = false;
    });
  }

  void _nextPuzzle() {
    setState(() {
      _puzzleInStage++;
      if (_puzzleInStage >= 3) {
        widget.onComplete(
          const MiniGameResult(
            completed: true,
            score: 100,
            accuracy: 1.0,
            mistakes: 0,
            duration: Duration.zero,
          ),
        );
      } else {
        _loadPuzzle();
      }
    });
  }

  void _onPanStart(
    DragStartDetails details,
    PuzzleBlock block,
    double cellSize,
  ) {
    if (_isRoundOver) return;
    _draggingBlock = block;
    _initialX = block.x;
    _initialY = block.y;

    if (block.isHorizontal) {
      _minDrag = 0;
      _maxDrag = block.isTarget ? 6.0 : (6.0 - block.length);
      for (var other in _blocks) {
        if (other.id == block.id) continue;
        bool overlapY =
            (block.y < other.y + (other.isHorizontal ? 1 : other.length)) &&
            (block.y + 1 > other.y);
        if (overlapY) {
          if (other.x < block.x) {
            _minDrag = math.max(
              _minDrag,
              other.x + (other.isHorizontal ? other.length : 1).toDouble(),
            );
          } else {
            _maxDrag = math.min(_maxDrag, other.x - block.length.toDouble());
          }
        }
      }
    } else {
      _minDrag = 0;
      _maxDrag = 6.0 - block.length;
      for (var other in _blocks) {
        if (other.id == block.id) continue;
        bool overlapX =
            (block.x < other.x + (other.isHorizontal ? other.length : 1)) &&
            (block.x + 1 > other.x);
        if (overlapX) {
          if (other.y < block.y) {
            _minDrag = math.max(
              _minDrag,
              other.y + (other.isHorizontal ? 1 : other.length).toDouble(),
            );
          } else {
            _maxDrag = math.min(_maxDrag, other.y - block.length.toDouble());
          }
        }
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double cellSize) {
    if (_draggingBlock == null || _isRoundOver) return;
    setState(() {
      if (_draggingBlock!.isHorizontal) {
        _draggingBlock!.logicalX += details.delta.dx / cellSize;
        _draggingBlock!.logicalX = _draggingBlock!.logicalX.clamp(
          _minDrag,
          _maxDrag,
        );
      } else {
        _draggingBlock!.logicalY += details.delta.dy / cellSize;
        _draggingBlock!.logicalY = _draggingBlock!.logicalY.clamp(
          _minDrag,
          _maxDrag,
        );
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggingBlock == null || _isRoundOver) return;
    setState(() {
      _draggingBlock!.logicalX = _draggingBlock!.logicalX.roundToDouble();
      _draggingBlock!.logicalY = _draggingBlock!.logicalY.roundToDouble();
      _draggingBlock!.x = _draggingBlock!.logicalX.toInt();
      _draggingBlock!.y = _draggingBlock!.logicalY.toInt();

      if (_draggingBlock!.x != _initialX || _draggingBlock!.y != _initialY) {
        _moves++;
      }

      if (_draggingBlock!.isTarget && _draggingBlock!.logicalX >= 5.0) {
        _isRoundOver = true;
        _roundWon = true;
        try {
          MinigameEnvironment.of(context).playSuccess(const Offset(200, 200));
        } catch (e) {}
        Future.delayed(const Duration(seconds: 1), _nextPuzzle);
      } else if (_mistakes >= 3) {
        // Failed the puzzle
        _isRoundOver = true;
        _roundWon = false;
        try {
          MinigameEnvironment.of(context).playError(const Offset(200, 200));
        } catch (e) {}
        Future.delayed(const Duration(seconds: 1), () {
          widget.onComplete(
            const MiniGameResult(
              completed: false,
              score: 0,
              accuracy: 0.0,
              mistakes: 3,
              duration: Duration.zero,
            ),
          );
        });
      }

      _draggingBlock = null;
    });
  }

  Widget _buildBlock(PuzzleBlock block, double cellSize) {
    return Positioned(
      left: block.logicalX * cellSize,
      top: block.logicalY * cellSize,
      width: (block.isHorizontal ? block.length : 1) * cellSize,
      height: (block.isHorizontal ? 1 : block.length) * cellSize,
      child: GestureDetector(
        onPanStart: (details) => _onPanStart(details, block, cellSize),
        onPanUpdate: (details) => _onPanUpdate(details, cellSize),
        onPanEnd: _onPanEnd,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: CustomPaint(
            painter: _GlossyBlockPainter(
              isHorizontal: block.isHorizontal,
              isTarget: block.isTarget,
              length: block.length,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _MagicBackgroundPainter())),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Round ${_puzzleInStage + 1} / 3',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.purpleAccent, blurRadius: 12)],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.purpleAccent.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'MOVES',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '$_moves / $_targetMoves',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        const Text(
                          'MISTAKES',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            3,
                            (index) => Icon(
                              Icons.close,
                              color: index < _mistakes
                                  ? Colors.red
                                  : Colors.white24,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double boardSize = math.min(
                        math.min(
                          constraints.maxWidth * 0.9,
                          constraints.maxHeight * 0.9,
                        ),
                        450,
                      );
                      double cellSize = boardSize / 6;

                      return Container(
                        width: boardSize + 24,
                        height: boardSize,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: boardSize,
                          height: boardSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF23143F),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF5D2E8C),
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5D2E8C).withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                right: -24,
                                top: 2 * cellSize,
                                width: 24,
                                height: cellSize,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellowAccent.withOpacity(0.3),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.yellowAccent,
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.exit_to_app,
                                      color: Colors.yellowAccent,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),

                              CustomPaint(
                                size: Size(boardSize, boardSize),
                                painter: _GridPainter(cellSize: cellSize),
                              ),

                              ..._blocks.map((b) => _buildBlock(b, cellSize)),

                              if (_isRoundOver)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _roundWon ? 'SOLVED!' : 'FAILED!',
                                        style: TextStyle(
                                          fontSize: 54,
                                          fontWeight: FontWeight.w900,
                                          color: _roundWon
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black,
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final double cellSize;
  _GridPainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 2;
    for (int i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlossyBlockPainter extends CustomPainter {
  final bool isHorizontal;
  final bool isTarget;
  final int length;

  _GlossyBlockPainter({
    required this.isHorizontal,
    required this.isTarget,
    required this.length,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    // Drop Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(3, 5)),
      Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    Color colorStart;
    Color colorEnd;
    if (isTarget) {
      colorStart = const Color(0xFFFFEA7E);
      colorEnd = const Color(0xFFF29B12);
    } else if (isHorizontal) {
      colorStart = const Color(0xFF00E5FF);
      colorEnd = const Color(0xFF007AFF);
    } else {
      colorStart = const Color(0xFFFF4081);
      colorEnd = const Color(0xFFC51162);
    }

    final Paint basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorStart, colorEnd],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(rrect, basePaint);

    final Path borderPath = Path()..addRRect(rrect);
    final Path innerPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
          const Radius.circular(8),
        ),
      );
    final Path bevel = Path.combine(
      PathOperation.difference,
      borderPath,
      innerPath,
    );

    canvas.drawPath(
      bevel,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.black.withOpacity(0.3),
          ],
        ).createShader(Offset.zero & size),
    );

    final Path highlight = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(6, 6, size.width - 12, size.height * 0.4),
          const Radius.circular(6),
        ),
      );
    canvas.drawPath(
      highlight,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    Paint detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    if (isTarget) {
      TextPainter tp = TextPainter(
        text: const TextSpan(
          text: '🗝️',
          style: TextStyle(
            fontSize: 32,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
      );
    } else {
      if (isHorizontal) {
        for (int i = 1; i < length * 2; i++) {
          double x = i * (size.width / (length * 2));
          canvas.drawLine(
            Offset(x, size.height * 0.2),
            Offset(x, size.height * 0.8),
            detailPaint,
          );
        }
      } else {
        for (int i = 1; i < length * 2; i++) {
          double y = i * (size.height / (length * 2));
          canvas.drawLine(
            Offset(size.width * 0.2, y),
            Offset(size.width * 0.8, y),
            detailPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MagicBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final math.Random r = math.Random(42);
    Paint starPaint = Paint()..color = Colors.white.withOpacity(0.5);
    for (int i = 0; i < 100; i++) {
      double x = r.nextDouble() * size.width;
      double y = r.nextDouble() * size.height;
      double s = r.nextDouble() * 3 + 1;
      canvas.drawCircle(
        Offset(x, y),
        s,
        starPaint..color = Colors.white.withOpacity(r.nextDouble() * 0.5 + 0.1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
