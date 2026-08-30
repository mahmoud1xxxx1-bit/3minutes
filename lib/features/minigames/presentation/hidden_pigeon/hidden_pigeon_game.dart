import 'package:flutter/material.dart';
import '../../../minigames_VBN/presentation/mini_game_copy.dart';
import 'package:flutter/rendering.dart';
import '../../domain/mini_game_contract.dart';
import '../../domain/hidden_pigeon_plan.dart';
import 'pigeon_painter.dart';
import 'master_pigeon_painter.dart';

class HiddenPigeonGame extends StatefulWidget {
  const HiddenPigeonGame({super.key, required this.config, required this.onComplete});

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<HiddenPigeonGame> createState() => _HiddenPigeonGameState();
}

class _HiddenPigeonGameState extends State<HiddenPigeonGame> with SingleTickerProviderStateMixin {
  late final HiddenPigeonPlan _plan;
  late final Stopwatch _watch;
  
  int _roundIndex = 0;
  int _hintsLeft = 3;
  int _hearts = 3;
  
  Set<int> _foundPigeons = {};
  int? _hintedPigeon;
  
  int _totalMistakes = 0;

  @override
  void initState() {
    super.initState();
    _plan = HiddenPigeonPlan.fromSeed(widget.config.seed, widget.config.difficulty);
    _watch = Stopwatch()..start();
  }

  void _onPigeonTapped(int index) {
    if (_foundPigeons.contains(index)) return;
    
    setState(() {
      _foundPigeons.add(index);
      if (_hintedPigeon == index) {
        _hintedPigeon = null;
      }
    });

    if (_foundPigeons.length == 10) {
      Future.delayed(const Duration(milliseconds: 500), _nextRound);
    }
  }

  void _onBackgroundTapped() {
    if (_hearts > 1) {
      setState(() {
        _hearts--;
        _totalMistakes++;
      });
    } else {
      setState(() {
        _hearts = 0;
        _totalMistakes += 5;
      });
      Future.delayed(const Duration(milliseconds: 500), _nextRound);
    }
  }

  void _useHint() {
    if (_hintsLeft > 0 && _foundPigeons.length < 10) {
      final unfound = List.generate(10, (i) => i).where((i) => !_foundPigeons.contains(i)).toList();
      if (unfound.isNotEmpty) {
        unfound.shuffle();
        setState(() {
          _hintsLeft--;
          _hintedPigeon = unfound.first;
        });
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _hintedPigeon != null) {
            setState(() {
              _hintedPigeon = null;
            });
          }
        });
      }
    }
  }

  void _nextRound() {
    if (!mounted) return;
    if (_roundIndex < 2) {
      setState(() {
        _roundIndex++;
        _foundPigeons.clear();
        _hearts = 3; 
      });
    } else {
      _watch.stop();
      final ms = _watch.elapsedMilliseconds;
      widget.onComplete(MiniGameResult(completed: true, score: 0, accuracy: 1.0, mistakes: _totalMistakes, duration: Duration(milliseconds: ms)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = _plan.rounds[_roundIndex];
    
    return Column(
      children: [
        // HUD
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(3, (index) => Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(
                    index < _hearts ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
                    size: 36,
                  ),
                )),
              ),
                              Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24, height: 24,
                            child: CustomPaint(painter: PigeonPainter(Colors.white, isSolid: true)),
                          ),
                          const SizedBox(width: 8),
                          Text('/10', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        MiniGameCopy.fromContext(context).hiddenPigeonInstruction,
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
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: const Color(0xFF3498DB),
                        boxShadow: [BoxShadow(color: const Color(0xFF3498DB).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Icon(Icons.search, color: Colors.black, size: 32),
                    ),
                    Positioned(
                      right: -5, bottom: -5,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, 
                          color: const Color(0xFFE74C3C),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Text('$_hintsLeft', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Game Area
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0, 
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0, // Allow 4x zoom!
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background tappable area
                            GestureDetector(
                              onTap: _onBackgroundTapped,
                              child: Container(
                                color: Colors.black, // fallback
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: MasterPigeonPainter(_plan.seed, _roundIndex),
                                ),
                              ),
                            ),
                            
                            // Pigeons
                            for (int i = 0; i < 10; i++)
                              Positioned(
                                // Pigeon is 40x40. We subtract 20 to center it exactly on the generated point.
                                left: round.pigeons[i].x * constraints.maxWidth - 22.5,
                                top: round.pigeons[i].y * constraints.maxHeight - 22.5,
                                child: GestureDetector(
                                  // Accurate touch bounds!
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _onPigeonTapped(i),
                                  child: _PigeonWidget(roundIndex: _roundIndex,
                                    found: _foundPigeons.contains(i),
                                    isHinted: _hintedPigeon == i,
                                    colorIndex: i % 3,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }
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
  final int roundIndex;
  final bool found;
  final bool isHinted;
  final int colorIndex;

  const _PigeonWidget({super.key, required this.roundIndex, required this.found, required this.isHinted, required this.colorIndex});

  @override
  Widget build(BuildContext context) {
    if (found) {
      return Container(
        width: 45, height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.greenAccent, width: 3),
          color: Colors.green.withOpacity(0.3),
        ),
        child: const Center(child: Icon(Icons.check, color: Colors.greenAccent, size: 24)),
      );
    }

    final colors = [
      Colors.black,
      Colors.black,
      Colors.black,
    ];

    Widget pigeon = CustomPaint(
      size: const Size(45, 45),
      painter: PigeonPainter(colors[colorIndex]),
    );

    if (isHinted) {
      pigeon = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.yellowAccent.withOpacity(0.8), blurRadius: 10, spreadRadius: 10)],
        ),
        child: pigeon,
      );
    }

    return SizedBox(
      width: 45, height: 45,
      child: pigeon,
    );
  }
}

class BlendMask extends SingleChildRenderObjectWidget {
  final BlendMode blendMode;
  final double opacity;

  const BlendMask({
    super.key,
    required this.blendMode,
    this.opacity = 1.0,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBlendMask(blendMode, opacity);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBlendMask renderObject) {
    renderObject.blendMode = blendMode;
    renderObject.opacity = opacity;
  }
}

class RenderBlendMask extends RenderProxyBox {
  BlendMode blendMode;
  double opacity;

  RenderBlendMask(this.blendMode, this.opacity);

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
