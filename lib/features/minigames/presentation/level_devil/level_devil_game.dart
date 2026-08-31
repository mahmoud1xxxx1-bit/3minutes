import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../domain/mini_game_contract.dart';
import 'level_devil_engine.dart';

class LevelDevilGame extends StatefulWidget {
  const LevelDevilGame({
    super.key,
    required this.config,
    required this.onComplete,
  });

  final MiniGameConfig config;
  final ValueChanged<MiniGameResult> onComplete;

  @override
  State<LevelDevilGame> createState() => _LevelDevilGameState();
}

class _LevelDevilGameState extends State<LevelDevilGame>
    with SingleTickerProviderStateMixin {
  static const int _roundCount = 3;
  static const int _startingLives = 3;

  late LevelDevilEngine _engine;
  late final Ticker _ticker;
  final FocusNode _focusNode = FocusNode();
  final Stopwatch _elapsed = Stopwatch();

  Duration _lastTime = Duration.zero;
  int _round = 1;
  int _lives = _startingLives;
  int _deaths = 0;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _engine = LevelDevilEngine(levelId: _round);
    _elapsed.start();
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onTick(Duration elapsed) {
    if (_reported) return;
    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    setState(() {
      _engine.update(dt);
      if (_engine.isWon) {
        _handleRoundWon();
      } else if (_engine.isDead) {
        _handleDeath();
      }
    });
  }

  void _handleRoundWon() {
    if (_round >= _roundCount) {
      _finish(completed: true, progressStep: _roundCount);
      return;
    }
    _round += 1;
    _engine = LevelDevilEngine(levelId: _round);
  }

  void _handleDeath() {
    _deaths += 1;
    _lives -= 1;
    if (_lives <= 0) {
      _finish(completed: false, progressStep: _round - 1);
      return;
    }
    _engine = LevelDevilEngine(levelId: _round);
  }

  void _finish({required bool completed, required int progressStep}) {
    if (_reported) return;
    _reported = true;
    _elapsed.stop();
    _ticker.stop();
    final accuracy = ((_roundCount - _deaths.clamp(0, _roundCount)) / _roundCount)
        .clamp(0.0, 1.0)
        .toDouble();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onComplete(
        MiniGameResult(
          completed: completed,
          score: completed ? 1000 : 0,
          accuracy: accuracy,
          mistakes: _deaths,
          duration: _elapsed.elapsed,
          progressStep: completed ? _roundCount : progressStep,
          progressStepCount: _roundCount,
        ),
      );
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    _elapsed.stop();
    super.dispose();
  }

  void _onKeyEvent(KeyEvent event) {
    if (_reported) return;
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _engine.movingLeft = true;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _engine.movingRight = true;
      }
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _engine.jumping = true;
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _engine.movingLeft = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _engine.movingRight = false;
      }
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _engine.jumping = false;
      }
    }
  }

  Widget _holdButton({
    required IconData icon,
    required VoidCallback onDown,
    required VoidCallback onUp,
    Color color = Colors.blueGrey,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: Container(
        width: 70,
        height: 58,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 36, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _onKeyEvent,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF171A22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(
                  'ROUND $_round/$_roundCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                ...List.generate(
                  _startingLives,
                  (index) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      index < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: index < _lives ? Colors.redAccent : Colors.white38,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '✕ $_deaths',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: AspectRatio(
              aspectRatio: 800 / 600,
              child: ColoredBox(
                color: Colors.black,
                child: CustomPaint(
                  painter: _LevelDevilPainter(_engine),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _holdButton(
                icon: Icons.arrow_left_rounded,
                onDown: () => _engine.movingLeft = true,
                onUp: () => _engine.movingLeft = false,
              ),
              _holdButton(
                icon: Icons.keyboard_arrow_up_rounded,
                color: Colors.redAccent,
                onDown: () => _engine.jumping = true,
                onUp: () => _engine.jumping = false,
              ),
              _holdButton(
                icon: Icons.arrow_right_rounded,
                onDown: () => _engine.movingRight = true,
                onUp: () => _engine.movingRight = false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelDevilPainter extends CustomPainter {
  _LevelDevilPainter(this.engine);
  final LevelDevilEngine engine;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 800;
    final scaleY = size.height / 600;

    canvas.save();
    canvas.scale(scaleX, scaleY);
    final paint = Paint();

    for (final entity in engine.entities) {
      paint.color = entity.color;
      if (entity.type == EntityType.spike) {
        final path = Path()
          ..moveTo(entity.rect.left + entity.rect.w / 2, entity.rect.top)
          ..lineTo(entity.rect.right, entity.rect.bottom)
          ..lineTo(entity.rect.left, entity.rect.bottom)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawRect(entity.rect.toRect(), paint);
      }
    }

    paint.color = engine.player.color;
    canvas.drawRect(engine.player.rect.toRect(), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LevelDevilPainter oldDelegate) => true;
}
