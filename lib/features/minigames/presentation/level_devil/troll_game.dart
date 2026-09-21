import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../../economy_manager.dart';
import '../../../../services/life_recovery_dialog.dart';
import 'troll_engine.dart';
import '../../../../core/navigation/game_orientation.dart';

enum _TrollResult { dead, failed, victory }

enum TrollGameExit { nextStage, stageSelect }

class TrollGame extends StatefulWidget {
  const TrollGame({
    super.key,
    required this.onWin,
    this.startRound = 1,
    this.maxRounds = 2,
    this.levelsPerMechanic = 3,
    this.mechanicOffset = 0,
    this.stageSeedOverride,
    this.onFail,
    this.stageId = 1,
  });
  final void Function(int score) onWin;
  final VoidCallback? onFail;
  final int stageId;
  final int startRound;
  final int maxRounds;
  final int levelsPerMechanic;
  final int mechanicOffset;
  final int? stageSeedOverride;

  @override
  State<TrollGame> createState() => _TrollGameState();
}

class _TrollGameState extends State<TrollGame> with SingleTickerProviderStateMixin {
  late TrollEngine _engine;
  late Ticker _ticker;
  late FocusNode _focusNode;
  Duration _lastTime = Duration.zero;
  bool _paused = false;
  _TrollResult? _result;
  int _deathCount = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _engine = TrollEngine(
      round: widget.startRound,
      maxRounds: widget.maxRounds,
      levelsPerMechanic: widget.levelsPerMechanic,
      mechanicOffset: widget.mechanicOffset,
      stageSeedOverride: widget.stageSeedOverride,
    );
    GameOrientation.enterGame();
    _ticker = createTicker(_onTick)..start();
  }


  void _onTick(Duration elapsed) {
    if (_lastTime == Duration.zero) {
      _lastTime = elapsed;
      return;
    }
    final dt = (elapsed - _lastTime).inMicroseconds / 1000000.0;
    _lastTime = elapsed;

    _engine.update(dt);

    if (_engine.allComplete) {
      _ticker.stop();
      if (_result == null && mounted) {
        final won = _engine.completedAsWin;
        if (!won) _deathCount++;
        setState(() {
          _result = won
              ? _TrollResult.victory
              : (_deathCount >= 2 ? _TrollResult.failed : _TrollResult.dead);
        });
        if (!won) {
          // A life is consumed for every actual death. Navigation is never
          // performed here; the player must choose from the result overlay.
          await widget.onFail?.call();
        }
      }
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    GameOrientation.leaveGame();
    super.dispose();
  }

  void _togglePause() {
    if (_engine.allComplete) return;
    setState(() {
      _paused = !_paused;
      _lastTime = Duration.zero;
    });
    if (_paused) {
      _ticker.stop();
      HapticFeedback.mediumImpact();
    } else {
      _ticker.start();
      HapticFeedback.lightImpact();
      _focusNode.requestFocus();
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _engine.movingLeft = true;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) _engine.movingRight = true;
      if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.arrowUp) _engine.jumping = true;
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _engine.movingLeft = false;
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) _engine.movingRight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode..requestFocus(),
      onKeyEvent: _onKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF07080A),
        body: Stack(
          children: [
            // Main Game Area
            Column(
              children: [
                Expanded(
                  child: SizedBox.expand(
                    child: ClipRect(
                      child: CustomPaint(
                        painter: _TrollPainter(_engine),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Mobile-first HUD
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Row(
                    children: [
                      const _LifeHud(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Center(
                          child: _hudPill(
                            icon: Icons.bolt_rounded,
                            color: const Color(0xFF5CF5FF),
                            text: 'STAGE ${_engine.round}',
                          ),
                        ),
                      ),
                      _hudButton(
                        icon: _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        onTap: _togglePause,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Season 1 controls: compact gear-style directional control on the left.
// Jump is intentionally gesture-based: tap/press anywhere on the right side.
            Positioned.fill(
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      left: 18,
                      bottom: 14,
                      child: _buildGearControl(),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      width: MediaQuery.of(context).size.width * 0.48,
                      height: MediaQuery.of(context).size.height * 0.58,
                      child: Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: (_) {
                          if (!_paused && !_engine.allComplete) {
                            HapticFeedback.lightImpact();
                            _engine.jumping = true;
                          }
                        },
                        onPointerUp: (_) => _engine.jumping = false,
                        onPointerCancel: (_) => _engine.jumping = false,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_result != null)
              Positioned.fill(
                child: _buildResultOverlay(),
              ),

            if (_paused && _result == null)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xCC02040A),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(28),
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1530),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0x335CF5FF)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x6619DCE8), blurRadius: 32),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFF5CF5FF), size: 58),
                          const SizedBox(height: 14),
                          const Text('PAUSED', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 8),
                          const Text('Take a breath. Your stage is waiting.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.icon(
                                onPressed: _togglePause,
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('RESUME'),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.exit_to_app_rounded),
                                label: const Text('EXIT'),
                              ),
                            ],
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
  }

  Widget _buildResultOverlay() {
    final result = _result!;
    final isVictory = result == _TrollResult.victory;
    final isFinalFailure = result == _TrollResult.failed;
    final title = isVictory ? 'STAGE CLEAR' : (isFinalFailure ? 'STAGE FAILED' : 'YOU DIED');
    final subtitle = isVictory
        ? 'Stage ${widget.stageId} complete.'
        : isFinalFailure
            ? 'This run has used both attempts.'
            : 'The layout is unchanged. Try the same stage again.';
    final accent = isVictory ? const Color(0xFF5CF5FF) : const Color(0xFFFF5478);

    return ColoredBox(
      color: const Color(0xCC02040A),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
            decoration: BoxDecoration(
              color: const Color(0xF20A1124),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent.withOpacity(.42), width: 1.2),
              boxShadow: [
                BoxShadow(color: accent.withOpacity(.20), blurRadius: 34, spreadRadius: 1),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(.10),
                    border: Border.all(color: accent.withOpacity(.42)),
                  ),
                  child: Icon(
                    isVictory ? Icons.bolt_rounded : Icons.close_rounded,
                    color: accent,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'STAGE ${widget.stageId}',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (isVictory) ...[
                  const SizedBox(height: 14),
                  Text(
                    '+${_engine.totalScore} SCORE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                if (isVictory && widget.stageId < 175)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _goNextStage,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('NEXT STAGE'),
                    ),
                  ),
                if (isVictory && widget.stageId < 175) const SizedBox(height: 10),
                if (!isFinalFailure)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _retryStage,
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(isVictory ? 'REPLAY' : 'RETRY'),
                    ),
                  ),
                if (!isFinalFailure) const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _goStageSelect,
                    icon: const Icon(Icons.grid_view_rounded),
                    label: Text(isVictory && widget.stageId >= 175 ? 'BACK TO WORLDS' : 'STAGE SELECT'),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _goMainMenu,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('MAIN MENU'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _retryStage() async {
    if (!mounted) return;

    if (_result == _TrollResult.dead && _deathCount >= 1) {
      final economy = await EconomyManager.checkEconomy();
      if ((economy['lives'] as int? ?? 0) <= 0) {
        if (!mounted) return;
        await showLifeRecoveryDialog(context);
        return;
      }
    }

    final seed = _engine.stageSeed;
    setState(() {
      _engine = TrollEngine(
        round: widget.startRound,
        maxRounds: widget.maxRounds,
        levelsPerMechanic: widget.levelsPerMechanic,
        mechanicOffset: widget.mechanicOffset,
        stageSeedOverride: seed,
      );
      _result = null;
      _paused = false;
      _lastTime = Duration.zero;
    });
    _ticker.start();
    _focusNode.requestFocus();
    HapticFeedback.mediumImpact();
  }

  void _goNextStage() {
    if (!mounted) return;
    Navigator.of(context).pop(TrollGameExit.nextStage);
  }

  void _goStageSelect() {
    if (!mounted) return;
    Navigator.of(context).pop(TrollGameExit.stageSelect);
  }

  void _goMainMenu() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _hudPill({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xD90A1124),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _hudButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: const Color(0xD90A1124),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildJoypadButton({
    required IconData icon,
    required VoidCallback onDown,
    required VoidCallback onUp,
    bool primary = false,
  }) {
    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: primary ? 82 : 72,
        height: primary ? 82 : 72,
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFF5CF5FF), Color(0xFF7A5CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: primary ? null : const Color(0xCC0A1124),
          shape: BoxShape.circle,
          border: Border.all(
            color: primary ? const Color(0x885CF5FF) : const Color(0x33FFFFFF),
            width: 1.5,
          ),
          boxShadow: primary
              ? const [BoxShadow(color: Color(0x445CF5FF), blurRadius: 22)]
              : null,
        ),
        child: Icon(
          icon,
          color: primary ? const Color(0xFF04101D) : Colors.white70,
          size: primary ? 40 : 36,
        ),
      ),
    );
  }

  Widget _buildGearControl() {
    return Listener(
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 154,
        height: 86,
        child: CustomPaint(
          painter: _SeasonOneGearPainter(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) {
                  HapticFeedback.selectionClick();
                  _engine.movingLeft = true;
                },
                onPointerUp: (_) => _engine.movingLeft = false,
                onPointerCancel: (_) => _engine.movingLeft = false,
                child: const SizedBox(
                  width: 58,
                  height: 72,
                  child: Center(
                    child: Icon(Icons.chevron_left_rounded, color: Colors.white, size: 38),
                  ),
                ),
              ),
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) {
                  HapticFeedback.selectionClick();
                  _engine.movingRight = true;
                },
                onPointerUp: (_) => _engine.movingRight = false,
                onPointerCancel: (_) => _engine.movingRight = false,
                child: const SizedBox(
                  width: 58,
                  height: 72,
                  child: Center(
                    child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeasonOneGearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = Paint()..color = const Color(0xE50A1124);
    final border = Paint()
      ..color = const Color(0x6648DFF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final gear = Path();
    const teeth = 10;
    final rOuter = 39.0;
    final rInner = 31.0;
    for (int i = 0; i < teeth * 2; i++) {
      final a = -pi / 2 + i * pi / teeth;
      final r = i.isEven ? rOuter : rInner;
      final p = Offset(
        center.dx + cos(a) * r,
        center.dy + sin(a) * r,
      );
      if (i == 0) {
        gear.moveTo(p.dx, p.dy);
      } else {
        gear.lineTo(p.dx, p.dy);
      }
    }
    gear.close();
    canvas.drawPath(gear, outer);
    canvas.drawPath(gear, border);

    final hub = Paint()..color = const Color(0xFF101A32);
    canvas.drawCircle(center, 13, hub);
    canvas.drawCircle(
      center,
      13,
      Paint()
        ..color = const Color(0x443DDCF4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _SeasonOneGearPainter oldDelegate) => false;
}

class _LifeHud extends StatefulWidget {
  const _LifeHud();
  @override State<_LifeHud> createState() => _LifeHudState();
}
class _LifeHudState extends State<_LifeHud> {
  int _lives = 10;
  int _max = 10;
  @override void initState() { super.initState(); _refresh(); }
  Future<void> _refresh() async {
    final s = await EconomyManager.checkEconomy();
    if (!mounted) return;
    setState(() { _lives = s['lives'] as int? ?? 10; _max = s['maxLives'] as int? ?? 10; });
    Future.delayed(const Duration(seconds: 1), _refresh);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xD90A1124),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x66FF5478)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: Color(0xFFFF5478), size: 17),
          const SizedBox(width: 6),
          Text('$_lives/$_max', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}
class _TrollPainter extends CustomPainter {
  _TrollPainter(this.engine);
  final TrollEngine engine;

  @override
  void paint(Canvas canvas, Size size) {
    double scaleX = size.width / engine.logicalWidth;
    double scaleY = size.height / engine.logicalHeight;
    
    
    canvas.save();
    canvas.scale(scaleX, scaleY);
    if (engine.isMirrorLevel) {
       canvas.translate(engine.logicalWidth, 0);
       canvas.scale(-1, 1);
    }


    _drawBackground(canvas);

    // Apply Camera for world elements
    canvas.save();
    canvas.translate(-engine.cameraX, 0);

    _drawGrid(canvas);

    var paint = Paint();
    
    for (var e in engine.entities) {
      if (!e.isVisible) continue;

      if (e.type == TrollEntityType.block) {
        // ── TimedPlatform blink effect ──────────────────────────────────────
        // Find any TimedPlatformTrap that owns this block and check its state
        final timedTrap = engine.traps.whereType<TimedPlatformTrap>().where(
          (t) => t.blockIds.contains(e.id)
        ).firstOrNull;

        if (timedTrap != null) {
          // Invisible → skip
          if (!timedTrap.isCurrentlyVisible) continue;
          // Blink when < 0.7s remaining before disappear
          final timeLeft = timedTrap.showDuration - timedTrap.elapsedVisible;
          if (timeLeft < 0.7) {
            final blink = (sin(timedTrap.elapsedVisible * 18) + 1) / 2;
            if (blink < 0.35) continue; // skip this frame = blink
          }
          // Draw with orange tint to distinguish from regular blocks
          paint.color = const Color(0xFFFF8800).withValues(alpha: 0.9);
        } else {
          paint.color = e.color;
        }

        if (engine.round <= 20) {
          // Season 1 approved visual: dark stone platform with a thin cyan rim.
          paint.color = const Color(0xFF20283A);
          canvas.drawRRect(
            RRect.fromRectAndRadius(e.rect.toRect(), const Radius.circular(3)),
            paint,
          );
          paint.color = const Color(0xFF4E5A72);
          canvas.drawRect(Rect.fromLTWH(e.rect.x, e.rect.y, e.rect.w, 3), paint);
          paint.color = const Color(0xFF151B2A);
          canvas.drawRect(
            Rect.fromLTWH(e.rect.x, e.rect.y + 3, e.rect.w, e.rect.h - 3),
            paint,
          );
          paint.color = const Color(0xFF39D9F6).withValues(alpha: 0.72);
          canvas.drawRect(Rect.fromLTWH(e.rect.x, e.rect.y, e.rect.w, 2), paint);
        } else {
          canvas.drawRRect(
            RRect.fromRectAndRadius(e.rect.toRect(), const Radius.circular(4)),
            paint
          );
          paint.color = Colors.white.withValues(alpha: 0.05);
          canvas.drawRect(Rect.fromLTWH(e.rect.x, e.rect.y, e.rect.w, 4), paint);
        }

      } else if (e.type == TrollEntityType.spike) {
        _drawSpike(canvas, e.rect, e.color, e.isInverted);
      } else if (e.type == TrollEntityType.door) {
        // ── FakeDoor: drawn identically to real door ─────────────────────
        _drawDoor(canvas, e.rect, e.color);
      }
    }

    // ── GravityFlipZone visual (drawn after entities, before player) ──────
    for (final trap in engine.traps.whereType<GravityFlipZoneTrap>()) {
      final zr = trap.zone;
      // Animated purple shimmer using time
      final shimmer = ((sin(engine.stageSeed * 0.173) + 1) * 0.075 + 0.15).clamp(0.0, 1.0);
      paint.color = const Color(0xFF9900FF).withValues(alpha: 0.18 + shimmer * 0.12);
      canvas.drawRect(zr.toRect(), paint);
      // Border
      paint.color = const Color(0xFF9900FF).withValues(alpha: 0.7);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawRect(zr.toRect(), paint);
      paint.style = PaintingStyle.fill;
      // Label
      final tp = TextPainter(
        text: const TextSpan(
          text: '⚡',
          style: TextStyle(fontSize: 18, color: Color(0xFFDD88FF)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(zr.x + zr.w / 2 - 9, zr.y + zr.h / 2 - 9));
    }


    if (engine.isGhostLevel && engine.ghostHistory.isNotEmpty) {
      var ghostP = TrollEntity(
        id: "ghost", type: TrollEntityType.player,
        rect: RectD(engine.ghostHistory.first.dx, engine.ghostHistory.first.dy, engine.player.rect.w, engine.player.rect.h),
        color: const Color(0xFFFF3366)
      );
      _drawPlayer(canvas, ghostP, opacity: 0.5);
    }
    
    if (engine.isChasedLevel) {
      paint.color = const Color(0xFF220000);
      canvas.drawRect(Rect.fromLTWH(engine.chaseWallX - 1000, 0, 1000, 800), paint);
      
      paint.color = const Color(0xFFFF1111);
      for (double y = 0; y < 800; y += 40) {
        _drawRightSpike(canvas, RectD(engine.chaseWallX, y, 40, 40), paint.color); 
      }
    }

    if (!engine.isDead || engine.playerScale > 0) {
      _drawPlayer(canvas, engine.player);
    }
    
    for (var p in engine.particles) {
      paint.color = p.color.withOpacity(p.life / p.maxLife);
      canvas.drawCircle(Offset(p.x, p.y), 4 * (p.life / p.maxLife), paint);
    }
    
    // Restore world camera
    canvas.restore();

    // --- SPOTLIGHT EFFECT ---
    if (engine.isSpotlightLevel) {
      final double screenPx = engine.player.rect.x + engine.player.rect.w / 2 - engine.cameraX;
      final double screenPy = engine.player.rect.y + engine.player.rect.h / 2;
      
      final Rect bgRect = Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight);
      
      canvas.saveLayer(bgRect, Paint());
      canvas.drawRect(bgRect, Paint()..color = const Color(0xE6030305)); // 90% opacity black

      final Paint holePaint = Paint()
        ..blendMode = BlendMode.clear
        ..shader = RadialGradient(
          colors: [Colors.transparent, const Color(0xE6030305)],
          stops: [0.15, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(screenPx, screenPy), radius: 250));
      
      canvas.drawCircle(Offset(screenPx, screenPy), 250, holePaint);
      canvas.restore();
    }

    // --- TIME FREEZE EFFECT ---
    if (engine.isTimeFreezeLevel) {
      bool playerIsMoving = engine.player.vx.abs() > 5 || engine.player.vy.abs() > 5 || engine.movingLeft || engine.movingRight || engine.jumping;
      final Rect bgRect = Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight);
      
      Paint freezePaint = Paint()
        ..blendMode = BlendMode.srcOver
        ..shader = RadialGradient(
          colors: [
            Colors.transparent, 
            playerIsMoving ? const Color(0x3300AAFF) : const Color(0x6600AAFF)
          ],
          stops: [0.5, 1.0],
        ).createShader(bgRect);
        
      canvas.drawRect(bgRect, freezePaint);
      
      if (!playerIsMoving && !engine.isDead && !engine.roundWon) {
        TextSpan span = const TextSpan(style: TextStyle(color: Color(0xFF00AAFF), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4), text: "TIME FROZEN");
        TextPainter tp = TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(engine.logicalWidth/2 - tp.width/2, 50));
      }
    }

    
    // --- LAVA EFFECT ---
    if (engine.isLavaLevel) {
      double lavaScreenY = engine.lavaY; // lava is static in world, wait, screen space?
      // No, world space! Need to apply camera.
      canvas.save();
      canvas.translate(-engine.cameraX, 0);
      Paint lavaPaint = Paint()..color = const Color(0xDDFF3300);
      canvas.drawRect(Rect.fromLTWH(engine.cameraX - 500, engine.lavaY, 2000, 800), lavaPaint);
      lavaPaint.color = const Color(0xFFFF8800);
      canvas.drawRect(Rect.fromLTWH(engine.cameraX - 500, engine.lavaY, 2000, 10), lavaPaint);
      canvas.restore();
    }
    
    // --- BLINK EFFECT ---
    if (engine.isBlinkLevel) {
       if (engine.blinkTimer % 3.5 > 2.5) { // 2.5s visible, 1.0s pitch black
         Paint blinkPaint = Paint()..color = Colors.black;
         canvas.drawRect(Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight), blinkPaint);
       }
    }

    // UI Layer (overlay, text, wipe)
    if (engine.isDead) {
      paint.color = Colors.black.withOpacity(1.0 - engine.deathTimer);
      canvas.drawRect(Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight), paint);
    }

    if (engine.roundWon) {
      double r = 800 * (1.0 - engine.transitionTimer);
      if (r < 0) r = 0;
      
      // Calculate screen position of player
      double screenX = engine.player.rect.x - engine.cameraX;
      double screenY = engine.player.rect.y;

      var path = Path()
        ..addRect(Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight))
        ..addOval(Rect.fromCircle(
            center: Offset(screenX + 20, screenY + 20), 
            radius: r))
        ..fillType = PathFillType.evenOdd;
      paint.color = const Color(0xFF07080A);
      canvas.drawPath(path, paint);
    }
    // Removed ROUND text to keep the player surprised
    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    if (engine.round <= 20) {
      _drawSeasonOneBackground(canvas);
      return;
    }
    final Rect bgRect = Rect.fromLTWH(0, 0, engine.logicalWidth, engine.logicalHeight);
    
    Color gradStart, gradEnd, moonColor, backMount, frontMount;

    if (engine.round >= 58) {
      // C20: Absolute Chaos
      gradStart = const Color(0xFF220000); gradEnd = const Color(0xFF000000); moonColor = const Color(0xFFFF0000); backMount = const Color(0xFF110000); frontMount = const Color(0xFF050000);
    } else if (engine.round >= 55) {
      // C19: Mirror Mode
      gradStart = const Color(0xFF333333); gradEnd = const Color(0xFF111111); moonColor = const Color(0xFFFFFFFF); backMount = const Color(0xFF222222); frontMount = const Color(0xFF0A0A0A);
    } else if (engine.round >= 52) {
      // C18: Blinking
      gradStart = const Color(0xFF000022); gradEnd = const Color(0xFF000000); moonColor = const Color(0xFF0000FF); backMount = const Color(0xFF000011); frontMount = const Color(0xFF000005);
    } else if (engine.round >= 49) {
      // C17: Slippery Ice
      gradStart = const Color(0xFFCCFFFF); gradEnd = const Color(0xFF88CCFF); moonColor = const Color(0xFFFFFFFF); backMount = const Color(0xFF66AADD); frontMount = const Color(0xFF4488BB);
    } else if (engine.round >= 46) {
      // C16: Wind
      gradStart = const Color(0xFF88AA88); gradEnd = const Color(0xFF446644); moonColor = const Color(0xFFAAFFCC); backMount = const Color(0xFF335533); frontMount = const Color(0xFF112211);
    } else if (engine.round >= 43) {
      // C15: Dash
      gradStart = const Color(0xFF550055); gradEnd = const Color(0xFF220022); moonColor = const Color(0xFFFF00FF); backMount = const Color(0xFF330033); frontMount = const Color(0xFF110011);
    } else if (engine.round >= 40) {
      // C14: Tiny
      gradStart = const Color(0xFF005500); gradEnd = const Color(0xFF002200); moonColor = const Color(0xFF00FF00); backMount = const Color(0xFF003300); frontMount = const Color(0xFF001100);
    } else if (engine.round >= 37) {
      // C13: Flappy
      gradStart = const Color(0xFF005555); gradEnd = const Color(0xFF002222); moonColor = const Color(0xFF00FFFF); backMount = const Color(0xFF003333); frontMount = const Color(0xFF001111);
    } else if (engine.round >= 34) {
      // C12: Low Gravity
      gradStart = const Color(0xFF555555); gradEnd = const Color(0xFF222222); moonColor = const Color(0xFFCCCCCC); backMount = const Color(0xFF333333); frontMount = const Color(0xFF111111);
    } else if (engine.round >= 31) {
      // C11: Lava
      gradStart = const Color(0xFF440000); gradEnd = const Color(0xFF220000); moonColor = const Color(0xFFFF5500); backMount = const Color(0xFF330000); frontMount = const Color(0xFF110000);
    } else if (engine.round >= 28) {

      // C10: Void Purple
      gradStart = const Color(0xFF330033);
      gradEnd = const Color(0xFF000000);
      moonColor = const Color(0xFFFF00FF);
      backMount = const Color(0xFF1A001A);
      frontMount = const Color(0xFF0D000D);
    } else if (engine.round >= 25) {
      // C9: Industrial Orange
      gradStart = const Color(0xFF442200);
      gradEnd = const Color(0xFF110500);
      moonColor = const Color(0xFFFF6600);
      backMount = const Color(0xFF331100);
      frontMount = const Color(0xFF1A0800);
    } else if (engine.round >= 22) {
      // C8: Pitch Black / Blood Red
      gradStart = const Color(0xFF110000);
      gradEnd = const Color(0xFF000000);
      moonColor = const Color(0xFFFF0000);
      backMount = const Color(0xFF0A0000);
      frontMount = const Color(0xFF050000);
    } else if (engine.round >= 19) {
      // C7: Teal / Ocean
      gradStart = const Color(0xFF003344);
      gradEnd = const Color(0xFF001122);
      moonColor = const Color(0xFF00FFCC);
      backMount = const Color(0xFF002233);
      frontMount = const Color(0xFF000A11);
    } else if (engine.round >= 16) {
      // C6: Golden / Amber
      gradStart = const Color(0xFF553311);
      gradEnd = const Color(0xFF221100);
      moonColor = const Color(0xFFFFCC00);
      backMount = const Color(0xFF331A00);
      frontMount = const Color(0xFF1A0D00);
    } else if (engine.round >= 13) {
      // C5: Ice Blue
      gradStart = const Color(0xFF004466);
      gradEnd = const Color(0xFF001133);
      moonColor = const Color(0xFFBBE4FF);
      backMount = const Color(0xFF003355);
      frontMount = const Color(0xFF001122);
    } else if (engine.round >= 10) {
      // C4: Glitch Purple
      gradStart = const Color(0xFF4A148C);
      gradEnd = const Color(0xFF1A0033);
      moonColor = const Color(0xFFFF00FF);
      backMount = const Color(0xFF2A0D45);
      frontMount = const Color(0xFF110422);
    } else if (engine.round >= 7) {
      // C3: Hacker Green
      gradStart = const Color(0xFF004411);
      gradEnd = const Color(0xFF001A00);
      moonColor = const Color(0xFF00FF44);
      backMount = const Color(0xFF003311);
      frontMount = const Color(0xFF001A05);
    } else if (engine.round >= 4) {
      // C2: Crimson Red
      gradStart = const Color(0xFF7A1C2C);
      gradEnd = const Color(0xFF3A0D16);
      moonColor = const Color(0xFFFF1133);
      backMount = const Color(0xFF4A0F1B);
      frontMount = const Color(0xFF1F060A);
    } else {
      // C1: Twilight Blue
      gradStart = const Color(0xFF3B3B6D);
      gradEnd = const Color(0xFF1A1A3A);
      moonColor = const Color(0xFF00E5FF);
      backMount = const Color(0xFF1D2645);
      frontMount = const Color(0xFF0E1428);
    }

    Paint bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradStart, gradEnd],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // Parallax values
    double moonX = 400 - (engine.cameraX * 0.05);
    double backMountainOffset = -(engine.cameraX * 0.2) % 800;
    double frontMountainOffset = -(engine.cameraX * 0.5) % 800;
    
    Paint paint = Paint();

    // Glowing Moon
    paint.color = moonColor.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    canvas.drawCircle(Offset(moonX, 300), 100, paint);
    paint.color = moonColor.withOpacity(0.6);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(moonX, 300), 60, paint);
    paint.maskFilter = null;

    // Back Mountains (drawn twice for seamless tiling)
    paint.color = backMount;
    for (int i = 0; i < 2; i++) {
      double startX = backMountainOffset + (i * 800);
      var path = Path()
        ..moveTo(startX, 600)
        ..lineTo(startX, 300)
        ..lineTo(startX + 200, 150)
        ..lineTo(startX + 450, 400)
        ..lineTo(startX + 600, 200)
        ..lineTo(startX + 800, 350)
        ..lineTo(startX + 800, 600)
        ..close();
      canvas.drawPath(path, paint);
    }

    // Front Mountains (drawn twice for seamless tiling)
    paint.color = frontMount;
    for (int i = 0; i < 2; i++) {
      double startX = frontMountainOffset + (i * 800);
      var path = Path()
        ..moveTo(startX, 600)
        ..lineTo(startX, 450)
        ..lineTo(startX + 300, 250)
        ..lineTo(startX + 550, 450)
        ..lineTo(startX + 800, 300)
        ..lineTo(startX + 800, 600)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawSeasonOneBackground(Canvas canvas) {
    final w = engine.logicalWidth;
    final h = engine.logicalHeight;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // Approved Season 1 direction: deep indigo sky, large moon, angular
    // mountains, restrained cyan/purple accents, no visual clutter.
    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF111B57),
          Color(0xFF18235D),
          Color(0xFF0B112A),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // Very subtle grid, matching the LVL LOOL visual language.
    final grid = Paint()
      ..color = const Color(0x142D4C92)
      ..strokeWidth = 1;
    for (double x = 0; x <= w; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y <= h; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }

    // Moon glow.
    final moonX = 405 - (engine.cameraX * 0.05);
    final moonCenter = Offset(moonX, 275);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: const [
          Color(0x6638D8FF),
          Color(0x2638D8FF),
          Color(0x0038D8FF),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: 145));
    canvas.drawCircle(moonCenter, 145, glow);
    final moon = Paint()..color = const Color(0xFF438FD0).withValues(alpha: 0.78);
    canvas.drawCircle(moonCenter, 72, moon);
    final moonShade = Paint()..color = const Color(0xFF24548C).withValues(alpha: 0.38);
    canvas.drawCircle(Offset(moonX + 18, 260), 64, moonShade);

    final backOffset = -(engine.cameraX * 0.18) % 800;
    final frontOffset = -(engine.cameraX * 0.42) % 800;

    // Back angular mountains.
    final back = Paint()..color = const Color(0xFF1B2A58);
    for (int i = 0; i < 2; i++) {
      final sx = backOffset + i * 800;
      final p = Path()
        ..moveTo(sx, 500)
        ..lineTo(sx + 105, 420)
        ..lineTo(sx + 205, 315)
        ..lineTo(sx + 315, 230)
        ..lineTo(sx + 455, 345)
        ..lineTo(sx + 610, 285)
        ..lineTo(sx + 800, 410)
        ..lineTo(sx + 800, 520)
        ..close();
      canvas.drawPath(p, back);
    }

    // Front dark mountain ridge.
    final front = Paint()..color = const Color(0xFF101A38);
    for (int i = 0; i < 2; i++) {
      final sx = frontOffset + i * 800;
      final p = Path()
        ..moveTo(sx, 545)
        ..lineTo(sx + 180, 440)
        ..lineTo(sx + 315, 365)
        ..lineTo(sx + 485, 475)
        ..lineTo(sx + 625, 385)
        ..lineTo(sx + 800, 500)
        ..lineTo(sx + 800, 560)
        ..close();
      canvas.drawPath(p, front);
    }

    // Restrained cyan edge lights on a few mountain facets.
    final edge = Paint()
      ..color = const Color(0xFF2CCFF1).withValues(alpha: 0.46)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(70 - engine.cameraX * 0.18, 465),
      Offset(190 - engine.cameraX * 0.18, 360),
      edge,
    );
    canvas.drawLine(
      Offset(525 - engine.cameraX * 0.18, 345),
      Offset(615 - engine.cameraX * 0.18, 430),
      edge,
    );

    // Small floating crystalline islands are environmental decoration only.
    final islandPaint = Paint()..color = const Color(0xFF182340);
    void island(double x, double y, double width) {
      final top = Rect.fromLTWH(x, y, width, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(top, const Radius.circular(2)),
        islandPaint,
      );
      final p = Path()
        ..moveTo(x + 8, y + 10)
        ..lineTo(x + width * .50, y + 42)
        ..lineTo(x + width - 8, y + 10)
        ..close();
      canvas.drawPath(p, islandPaint);
      final rim = Paint()..color = const Color(0xFF36D9F4).withValues(alpha: 0.72);
      canvas.drawRect(Rect.fromLTWH(x, y, width, 2), rim);
    }
    island(505 - engine.cameraX * 0.12, 252, 112);
    island(690 - engine.cameraX * 0.12, 318, 94);

    // A few crystals, deliberately sparse.
    final crystal = Paint()..color = const Color(0xFF52E6FF);
    void crystalAt(double x, double y, double s) {
      final p = Path()
        ..moveTo(x, y - s)
        ..lineTo(x + s * .55, y)
        ..lineTo(x, y + s)
        ..lineTo(x - s * .55, y)
        ..close();
      canvas.drawPath(p, crystal);
    }
    crystalAt(560 - engine.cameraX * 0.12, 235, 10);
    crystalAt(742 - engine.cameraX * 0.12, 300, 9);
  }

  void _drawGrid(Canvas canvas) {

    var paint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..strokeWidth = 1;
    // Extend grid to maxMapWidth
    for(double i=0; i<=engine.maxMapWidth; i+=40) {
      canvas.drawLine(Offset(i, 0), Offset(i, 600), paint);
    }
    for(double i=0; i<=600; i+=40) {
      canvas.drawLine(Offset(0, i), Offset(engine.maxMapWidth, i), paint);
    }
  }

  // Standard spike — multiple sharp triangles, taller and more dangerous-looking
  void _drawSpike(Canvas canvas, RectD rect, Color color, bool inverted) {
    // Professional, clean, symmetrical Geometry Dash style 2-tone spikes
    final count = (rect.w / 18.0).round().clamp(1, 6);
    final tw = rect.w / count;
    final spikeH = rect.h * 0.90; // Tall and sharp

    final paint = Paint();
    
    for (int i = 0; i < count; i++) {
      final lx = rect.x + i * tw;
      final rx = rect.x + (i + 1) * tw;
      final mx = (lx + rx) / 2;
      
      final leftPath = Path();
      final rightPath = Path();
      
      if (inverted) {
        // Ceiling spike (points down)
        leftPath.moveTo(mx, rect.y); leftPath.lineTo(lx, rect.y); leftPath.lineTo(mx, rect.y + spikeH);
        rightPath.moveTo(mx, rect.y); rightPath.lineTo(mx, rect.y + spikeH); rightPath.lineTo(rx, rect.y);
      } else {
        // Floor spike (points up)
        leftPath.moveTo(mx, rect.y); leftPath.lineTo(lx, rect.y + spikeH); leftPath.lineTo(mx, rect.y + spikeH);
        rightPath.moveTo(mx, rect.y); rightPath.lineTo(mx, rect.y + spikeH); rightPath.lineTo(rx, rect.y + spikeH);
      }
      leftPath.close();
      rightPath.close();

      // 1. Draw soft drop shadow for depth
      final shadowPath = Path();
      if (inverted) {
        shadowPath.moveTo(lx, rect.y); shadowPath.lineTo(rx, rect.y); shadowPath.lineTo(mx, rect.y + spikeH + 4);
      } else {
        shadowPath.moveTo(mx, rect.y - 4); shadowPath.lineTo(rx, rect.y + spikeH); shadowPath.lineTo(lx, rect.y + spikeH);
      }
      shadowPath.close();
      paint.color = Colors.black.withOpacity(0.4);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(shadowPath, paint);
      paint.maskFilter = null;
      
      // 2. Draw Left Half (Base Color - Bright)
      paint.color = color;
      canvas.drawPath(leftPath, paint);
      
      // 3. Draw Right Half (Darker for clean 2D shading)
      int r = (color.red * 0.65).toInt();
      int g = (color.green * 0.65).toInt();
      int b = (color.blue * 0.65).toInt();
      paint.color = Color.fromARGB(color.alpha, r, g, b);
      canvas.drawPath(rightPath, paint);
      
      // 4. Draw bright center highlight edge
      final edge = Path();
      if (inverted) {
        edge.moveTo(mx, rect.y); edge.lineTo(mx, rect.y + spikeH);
      } else {
        edge.moveTo(mx, rect.y + spikeH); edge.lineTo(mx, rect.y);
      }
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;
      paint.color = Colors.white.withOpacity(0.5);
      canvas.drawPath(edge, paint);
      paint.style = PaintingStyle.fill;
    }
  }

  void _drawBurstSpike(Canvas canvas, RectD rect, Color color) {
    final paint = Paint()..color = color;
    final cx = rect.x + rect.w / 2;
    final cy = rect.y + rect.h;
    
    // If it's deep underground (hidden), draw a glowing crack on the floor instead
    if (rect.y > 500) {
      paint.color = Colors.redAccent.withOpacity(0.6 + 0.4 * sin(DateTime.now().millisecondsSinceEpoch/150));
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final crack = Path()
        ..moveTo(cx - 10, cy - rect.h)
        ..lineTo(cx - 3, cy - rect.h + 2)
        ..lineTo(cx + 2, cy - rect.h - 1)
        ..lineTo(cx + 12, cy - rect.h + 1);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawPath(crack, paint);
      paint.style = PaintingStyle.fill;
      paint.maskFilter = null;
      return;
    }
    
    // Outer glow for erupting spike
    paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);
    paint.color = color.withOpacity(0.9);
    canvas.drawCircle(Offset(cx, cy - 10), 20, paint);
    paint.maskFilter = null;
    
    // Main enormous spike
    paint.color = color;
    final path = Path()
      ..moveTo(cx, rect.y - 15) // Extra sharp tip
      ..lineTo(cx + rect.w * 0.5, cy)
      ..lineTo(cx - rect.w * 0.5, cy)
      ..close();
    canvas.drawPath(path, paint);
    
    // Sharp edge highlight
    paint.color = Colors.white.withOpacity(0.5);
    final shine = Path()
      ..moveTo(cx, rect.y - 15)
      ..lineTo(cx + 4, cy - 10)
      ..lineTo(cx - 1, cy - 10)
      ..close();
    canvas.drawPath(shine, paint);
  }

  void _drawRightSpike(Canvas canvas, RectD rect, Color color) {
    var paint = Paint()..color = color;
    var path = Path();
    
    path.moveTo(rect.x, rect.y);
    path.lineTo(rect.x + rect.w, rect.y + rect.h / 2);
    path.lineTo(rect.x, rect.y + rect.h);
    path.close();
    
    paint.maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    canvas.drawPath(path, paint);
    paint.maskFilter = null;
    canvas.drawPath(path, paint);
  }

  void _drawDoor(Canvas canvas, RectD rect, Color color) {
    // A magical circular portal with pearls/sparkles
    final cx = rect.x + rect.w / 2;
    final cy = rect.y + rect.h / 2;
    // Radius slightly larger than the previous box
    final r = (rect.w > rect.h ? rect.w : rect.h) * 0.65;
    
    double time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // 1. Outer mystical glow
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 30)
      ..color = const Color(0xFF00E5FF).withOpacity(0.8);
    canvas.drawCircle(Offset(cx, cy), r, paint);
    
    // 2. Portal Void (Swirling Gradient)
    paint.maskFilter = null;
    paint.shader = ui.Gradient.radial(
      Offset(cx, cy),
      r,
      [const Color(0xFF001133), const Color(0xFF00E5FF)],
      [0.0, 1.0],
    );
    canvas.drawCircle(Offset(cx, cy), r, paint);
    paint.shader = null;
    
    // 3. Spinning Magical Runes / Ring
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    paint.color = const Color(0xFFE0FFFF).withOpacity(0.7);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.8), time * 2, 4.5, false, paint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.9), -time * 1.5, 4.5, false, paint);
    paint.style = PaintingStyle.fill;
    
    // 4. Floating Pearls
    final pearlCount = 7;
    for (int i = 0; i < pearlCount; i++) {
       double angle = time * 1.2 + (i * 2 * 3.14159 / pearlCount);
       double px = cx + cos(angle) * (r * 1.05);
       double py = cy + sin(angle) * (r * 1.05) + sin(time * 3 + i) * 5;
       
       // Pearl glow
       paint.color = Colors.white.withOpacity(0.9);
       paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
       canvas.drawCircle(Offset(px, py), 6, paint);
       
       // Pearl core
       paint.maskFilter = null;
       paint.color = Colors.white;
       canvas.drawCircle(Offset(px, py), 3, paint);
    }
  }

  void _drawPlayer(Canvas canvas, TrollEntity p, {double opacity = 1.0}) {
    var paint = Paint()..color = p.color.withOpacity(opacity);
    
    canvas.save();
    canvas.translate(p.rect.x + p.rect.w/2, p.rect.y + p.rect.h/2);
    canvas.scale(engine.playerScale, engine.playerScale);
    
    if (engine.isGravityInverted && opacity == 1.0) { // Flip only actual player upside down
      canvas.scale(1.0, -1.0);
    }
    
    canvas.translate(-(p.rect.x + p.rect.w/2), -(p.rect.y + p.rect.h/2));

    var r = RRect.fromRectAndRadius(p.rect.toRect(), const Radius.circular(6));
    canvas.drawRRect(r, paint);
    
    paint.color = p.color.withOpacity(0.4 * opacity);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(r, paint);
    paint.maskFilter = null;

    paint.color = const Color(0xFF07080A);
    double eyeOffset = engine.playerFaceDir * 4;
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(p.rect.x + 8 + eyeOffset, p.rect.y + 8, 4, 8), 
      const Radius.circular(2)
    ), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(p.rect.x + 18 + eyeOffset, p.rect.y + 8, 4, 8), 
      const Radius.circular(2)
    ), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrollPainter oldDelegate) => true;
}