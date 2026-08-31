import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../minigames_VBN/presentation/mini_game_copy.dart';
import '../../domain/hidden_pigeon_plan.dart';
import '../../domain/mini_game_contract.dart';
import 'master_pigeon_painter.dart';
import 'pigeon_painter.dart';

class HiddenPigeonGame extends StatefulWidget {
  const HiddenPigeonGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<HiddenPigeonGame> createState() => _HiddenPigeonGameState();
}

class _HiddenPigeonGameState extends State<HiddenPigeonGame>
    with SingleTickerProviderStateMixin {
  late final HiddenPigeonPlan _plan;
  late final Stopwatch _watch;

  int _roundIndex = 0;
  int _hintsLeft = 3;
  int _hearts = 3;
  int _clearedRounds = 0;
  bool _finished = false;

  Set<int> _foundPigeons = {};
  int? _hintedPigeon;
  int _totalMistakes = 0;

  @override
  void initState() {
    super.initState();
    _plan = HiddenPigeonPlan.fromSeed(
      widget.config.seed,
      widget.config.difficulty,
    );
    _watch = Stopwatch()..start();
  }

  @override
  void dispose() {
    _watch.stop();
    super.dispose();
  }

  void _onPigeonTapped(int index) {
    if (_finished || _foundPigeons.contains(index)) return;

    setState(() {
      _foundPigeons.add(index);
      if (_hintedPigeon == index) _hintedPigeon = null;
    });

    if (_foundPigeons.length == 10) {
      _clearedRounds++;
      Future.delayed(const Duration(milliseconds: 500), _advanceRound);
    }
  }

  void _onBackgroundTapped() {
    if (_finished) return;
    if (_hearts > 1) {
      setState(() {
        _hearts--;
        _totalMistakes++;
      });
      return;
    }

    setState(() {
      _hearts = 0;
      _totalMistakes++;
    });

    // Losing all three hearts means the objective has failed. We finish the
    // mini-game immediately instead of silently advancing and later reporting
    // a false success. The reached round remains report-only progress.
    Future.delayed(const Duration(milliseconds: 500), _finishFailure);
  }

  void _finishFailure() {
    if (!mounted || _finished) return;
    _finished = true;
    _watch.stop();
    widget.onComplete(
      MiniGameResult(
        completed: false,
        score: 0,
        accuracy: _accuracy,
        mistakes: _totalMistakes,
        duration: _watch.elapsed,
        progressStep: _clearedRounds,
        progressStepCount: 3,
      ),
    );
  }

  double get _accuracy {
    final found = _clearedRounds * 10 + _foundPigeons.length;
    final attempts = found + _totalMistakes;
    if (attempts <= 0) return 0;
    return (found / attempts).clamp(0.0, 1.0).toDouble();
  }

  void _useHint() {
    if (_finished || _hintsLeft <= 0 || _foundPigeons.length >= 10) return;
    final unfound = List.generate(10, (i) => i)
        .where((i) => !_foundPigeons.contains(i))
        .toList(growable: false);
    if (unfound.isEmpty) return;

    // The board positions are already deterministic. The hint only reveals an
    // existing target and does not affect competitive scoring.
    final hintIndex = unfound[widget.config.seed.abs() % unfound.length];
    setState(() {
      _hintsLeft--;
      _hintedPigeon = hintIndex;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _hintedPigeon == hintIndex) {
        setState(() => _hintedPigeon = null);
      }
    });
  }

  void _advanceRound() {
    if (!mounted || _finished) return;
    if (_roundIndex < 2) {
      setState(() {
        _roundIndex++;
        _foundPigeons.clear();
        _hearts = 3;
        _hintedPigeon = null;
      });
      return;
    }

    _finished = true;
    _watch.stop();
    widget.onComplete(
      MiniGameResult(
        completed: _clearedRounds == 3,
        score: _clearedRounds == 3 ? 1000 : 0,
        accuracy: _accuracy,
        mistakes: _totalMistakes,
        duration: _watch.elapsed,
        progressStep: _clearedRounds,
        progressStepCount: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final round = _plan.rounds[_roundIndex];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      index < _hearts
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent,
                      size: 36,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CustomPaint(
                            painter: PigeonPainter(
                              Colors.white,
                              isSolid: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_foundPigeons.length}/10',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      MiniGameCopy.fromContext(context)
                          .hiddenPigeonInstruction,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _useHint,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3498DB),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3498DB)
                                .withValues(alpha: .5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    Positioned(
                      right: -5,
                      bottom: -5,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE74C3C),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text(
                          '$_hintsLeft',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: _onBackgroundTapped,
                              child: Container(
                                color: Colors.black,
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: MasterPigeonPainter(
                                    _plan.seed,
                                    _roundIndex,
                                  ),
                                ),
                              ),
                            ),
                            for (int i = 0; i < 10; i++)
                              Positioned(
                                left: round.pigeons[i].x *
                                        constraints.maxWidth -
                                    22.5,
                                top: round.pigeons[i].y *
                                        constraints.maxHeight -
                                    22.5,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _onPigeonTapped(i),
                                  child: _PigeonWidget(
                                    found: _foundPigeons.contains(i),
                                    isHinted: _hintedPigeon == i,
                                    colorIndex: i % 3,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PigeonWidget extends StatelessWidget {
  const _PigeonWidget({
    required this.found,
    required this.isHinted,
    required this.colorIndex,
  });

  final bool found;
  final bool isHinted;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    if (found) {
      return Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.greenAccent, width: 3),
          color: Colors.green.withValues(alpha: .3),
        ),
        child: const Center(
          child: Icon(Icons.check, color: Colors.greenAccent, size: 24),
        ),
      );
    }

    final colors = [Colors.black, Colors.black, Colors.black];
    Widget pigeon = CustomPaint(
      size: const Size(45, 45),
      painter: PigeonPainter(colors[colorIndex]),
    );

    if (isHinted) {
      pigeon = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.yellowAccent.withValues(alpha: .8),
              blurRadius: 10,
              spreadRadius: 10,
            ),
          ],
        ),
        child: pigeon,
      );
    }

    return SizedBox(width: 45, height: 45, child: pigeon);
  }
}

class BlendMask extends SingleChildRenderObjectWidget {
  const BlendMask({
    super.key,
    required this.blendMode,
    this.opacity = 1,
    super.child,
  });

  final BlendMode blendMode;
  final double opacity;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBlendMask(blendMode, opacity);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderBlendMask renderObject,
  ) {
    renderObject.blendMode = blendMode;
    renderObject.opacity = opacity;
  }
}

class RenderBlendMask extends RenderProxyBox {
  RenderBlendMask(this.blendMode, this.opacity);

  BlendMode blendMode;
  double opacity;

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.saveLayer(
      offset & size,
      Paint()
        ..blendMode = blendMode
        ..color = Color.fromRGBO(255, 255, 255, opacity),
    );
    super.paint(context, offset);
    context.canvas.restore();
  }
}
