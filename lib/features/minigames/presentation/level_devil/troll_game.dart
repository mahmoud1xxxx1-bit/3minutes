import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../../../economy_manager.dart';
import '../../../../services/life_recovery_dialog.dart';
import 'troll_engine.dart';
import 'troll_stage_plan.dart';
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
    this.onFailAsync,
    this.onMainMenu,
    this.stageId = 1,
  });
  final void Function(int score) onWin;
  final VoidCallback? onFail;
  final Future<void> Function()? onFailAsync;
  final VoidCallback? onMainMenu;
  final int stageId;
  final int startRound;
  final int maxRounds;
  final int levelsPerMechanic;
  final int mechanicOffset;
  final int? stageSeedOverride;

  @override
  State<TrollGame> createState() => _TrollGameState();
}

enum _SeasonVisual { cosmic, inferno, wilds, circuit, frozen, rift }

_SeasonVisual _seasonForStage(int stageId) {
  if (stageId <= 20) return _SeasonVisual.cosmic;
  if (stageId <= 40) return _SeasonVisual.inferno;
  if (stageId <= 60) return _SeasonVisual.wilds;
  if (stageId <= 80) return _SeasonVisual.circuit;
  if (stageId <= 100) return _SeasonVisual.frozen;
  return _SeasonVisual.rift;
}

class _SeasonPalette {
  const _SeasonPalette({
    required this.top,
    required this.bottom,
    required this.mid,
    required this.rim,
    required this.platform,
    required this.platformDark,
    required this.accent,
    required this.motif,
  });

  final Color top;
  final Color bottom;
  final Color mid;
  final Color rim;
  final Color platform;
  final Color platformDark;
  final Color accent;
  final Color motif;
}

_SeasonPalette _paletteForSeason(_SeasonVisual season) {
  switch (season) {
    case _SeasonVisual.cosmic:
      return const _SeasonPalette(
        top: Color(0xFF111B57), bottom: Color(0xFF0B112A), mid: Color(0xFF18235D),
        rim: Color(0xFF39D9F6), platform: Color(0xFF20283A), platformDark: Color(0xFF151B2A),
        accent: Color(0xFF5CF5FF), motif: Color(0xFF438FD0),
      );
    case _SeasonVisual.inferno:
      return const _SeasonPalette(
        top: Color(0xFF301414), bottom: Color(0xFF100B0B), mid: Color(0xFF542019),
        rim: Color(0xFFFF7043), platform: Color(0xFF2A2220), platformDark: Color(0xFF191514),
        accent: Color(0xFFFF8A4C), motif: Color(0xFFC94B32),
      );
    case _SeasonVisual.wilds:
      return const _SeasonPalette(
        top: Color(0xFF122D25), bottom: Color(0xFF081412), mid: Color(0xFF1D4938),
        rim: Color(0xFF72C47A), platform: Color(0xFF28302A), platformDark: Color(0xFF181F1B),
        accent: Color(0xFF9BE28E), motif: Color(0xFF4B8060),
      );
    case _SeasonVisual.circuit:
      return const _SeasonPalette(
        top: Color(0xFF19152F), bottom: Color(0xFF0A0913), mid: Color(0xFF29234A),
        rim: Color(0xFFC66BFF), platform: Color(0xFF252331), platformDark: Color(0xFF15141E),
        accent: Color(0xFFD77BFF), motif: Color(0xFF7351A8),
      );
    case _SeasonVisual.frozen:
      return const _SeasonPalette(
        top: Color(0xFF132D46), bottom: Color(0xFF09131F), mid: Color(0xFF1C4661),
        rim: Color(0xFF7DDAFF), platform: Color(0xFF29343C), platformDark: Color(0xFF182127),
        accent: Color(0xFF9BE7FF), motif: Color(0xFF6FAFC8),
      );
    case _SeasonVisual.rift:
      return const _SeasonPalette(
        top: Color(0xFF15151C), bottom: Color(0xFF07070B), mid: Color(0xFF23232E),
        rim: Color(0xFFC7A6FF), platform: Color(0xFF28272F), platformDark: Color(0xFF17161C),
        accent: Color(0xFFE2C8FF), motif: Color(0xFF6E637C),
      );
  }
}

class _TrollGameState extends State<TrollGame> with SingleTickerProviderStateMixin {
  late TrollEngine _engine;
  late Ticker _ticker;
  late FocusNode _focusNode;
  Duration _lastTime = Duration.zero;
  bool _paused = false;
  _TrollResult? _result;
  int _rewardGold = 0;
  int _rewardGems = 0;
  bool _rewardFirstClear = false;

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


  void _onTick(Duration elapsed) async {
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
        Map<String, dynamic>? reward;
        var noLivesRemaining = false;
        if (won) {
          // Settle the economy from the immutable global stage id, not the
          // local mechanic round. This keeps Season 6 rewards correct.
          reward = await EconomyManager.processWin(widget.stageId);
        } else {
          // Every actual death consumes one life. Attempts are NOT capped at
          // two: the player may retry while lives remain.
          if (widget.onFailAsync != null) {
            await widget.onFailAsync!();
          } else {
            widget.onFail?.call();
          }
          final economy = await EconomyManager.checkEconomy();
          noLivesRemaining = (economy['lives'] as int? ?? 0) <= 0;
        }

        if (!mounted) return;
        setState(() {
          _result = won
              ? _TrollResult.victory
              : (noLivesRemaining ? _TrollResult.failed : _TrollResult.dead);
          if (reward != null) {
            _rewardGold = reward['gold'] as int? ?? 0;
            _rewardGems = reward['gems'] as int? ?? 0;
            _rewardFirstClear = reward['isFirst'] == true;
          }
        });
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
                        painter: _TrollPainter(_engine, widget.stageId),
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
                            color: _paletteForSeason(_seasonForStage(widget.stageId)).accent,
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

            // Compact gear-style directional control on the left for every season.
// Jump remains gesture-based: tap/press anywhere on the right side.
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
            ? 'No lives remaining. Recover a life to retry this stage.'
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
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withOpacity(.24)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _rewardFirstClear ? 'FIRST CLEAR REWARD' : 'CLEAR REWARD',
                          style: TextStyle(
                            color: accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (_rewardGems > 0)
                          Text(
                            '+${_rewardGems} GEMS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        else if (_rewardGold > 0)
                          Text(
                            '+${_rewardGold} GOLD',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                        else
                          const Text(
                            'NO REWARD',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
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

    if (_result == _TrollResult.dead) {
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
      _rewardGold = 0;
      _rewardGems = 0;
      _rewardFirstClear = false;
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
    if (widget.onMainMenu != null) {
      widget.onMainMenu!();
      return;
    }
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
          painter: _SeasonGearPainter(_paletteForSeason(_seasonForStage(widget.stageId)).rim),
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

class _SeasonGearPainter extends CustomPainter {
  const _SeasonGearPainter(this.accent);
  final Color accent;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = Paint()..color = const Color(0xE50A1124);
    final border = Paint()
      ..color = accent.withValues(alpha: 0.40)
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
  bool shouldRepaint(covariant _SeasonGearPainter oldDelegate) => oldDelegate.accent != accent;
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
  _TrollPainter(this.engine, this.stageId);
  final TrollEngine engine;
  final int stageId;

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
    _drawSeasonMechanicLayer(canvas);

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

        final season = _seasonForStage(stageId);
        if (season == _SeasonVisual.cosmic) {
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
          final palette = _paletteForSeason(_seasonForStage(stageId));
          paint.color = palette.platform;
          canvas.drawRRect(
            RRect.fromRectAndRadius(e.rect.toRect(), const Radius.circular(4)),
            paint,
          );
          paint.color = palette.platformDark;
          canvas.drawRect(
            Rect.fromLTWH(e.rect.x, e.rect.y + 3, e.rect.w, e.rect.h - 3),
            paint,
          );
          paint.color = palette.rim.withValues(alpha: 0.82);
          canvas.drawRect(
            Rect.fromLTWH(e.rect.x, e.rect.y, e.rect.w, 2),
            paint,
          );
        }

      } else if (e.type == TrollEntityType.spike) {
        final seasonAccent = _paletteForSeason(_seasonForStage(stageId)).accent;
        _drawSpike(canvas, e.rect, seasonAccent, e.isInverted);
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
    final season = _seasonForStage(stageId);
    final palette = _paletteForSeason(season);
    final w = engine.logicalWidth;
    final h = engine.logicalHeight;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // Season 1 is the approved visual master. It remains deliberately
    // restrained; the other seasons inherit its composition language but
    // become real worlds rather than recoloured backgrounds.
    if (season == _SeasonVisual.cosmic) {
      _drawSeasonOneBackground(canvas);
      return;
    }

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [palette.top, palette.mid, palette.bottom],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final grid = Paint()
      ..color = palette.rim.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    for (double x = 0; x <= w; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y <= h; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }

    final parallax = -(engine.cameraX * 0.18) % 800;
    final deep = Paint()..color = palette.bottom.withValues(alpha: 0.76);
    final mid = Paint()..color = palette.mid.withValues(alpha: 0.72);

    switch (season) {
      case _SeasonVisual.inferno:
        // Season 2 — Inferno Forge: obsidian, furnace glow and forged rock.
        final glow = Paint()
          ..shader = RadialGradient(
            colors: [palette.motif.withValues(alpha: 0.34), Colors.transparent],
          ).createShader(Rect.fromCircle(center: Offset(410, 430), radius: 230));
        canvas.drawCircle(Offset(410, 430), 230, glow);

        for (int i = 0; i < 2; i++) {
          final sx = parallax + i * 800;
          final p = Path()
            ..moveTo(sx, 530)
            ..lineTo(sx + 110, 410)
            ..lineTo(sx + 210, 470)
            ..lineTo(sx + 335, 330)
            ..lineTo(sx + 470, 445)
            ..lineTo(sx + 610, 365)
            ..lineTo(sx + 800, 475)
            ..lineTo(sx + 800, 560)
            ..close();
          canvas.drawPath(p, mid);
        }
        final lava = Paint()..color = palette.accent.withValues(alpha: 0.18);
        canvas.drawRect(Rect.fromLTWH(0, 535, w, 65), lava);
        for (double x = parallax - 40; x < w + 800; x += 120) {
          canvas.drawLine(Offset(x, 535), Offset(x + 42, 560), lava..strokeWidth = 3);
        }
        break;

      case _SeasonVisual.wilds:
        // Season 3 — Ancient Wilds: ruins, roots and deep forest silhouettes.
        final mist = Paint()
          ..shader = RadialGradient(
            colors: [palette.motif.withValues(alpha: 0.22), Colors.transparent],
          ).createShader(Rect.fromCircle(center: Offset(410, 250), radius: 260));
        canvas.drawCircle(Offset(410, 250), 260, mist);

        for (int i = 0; i < 2; i++) {
          final sx = parallax + i * 800;
          final ruin = Path()
            ..moveTo(sx, 545)
            ..lineTo(sx + 90, 425)
            ..lineTo(sx + 150, 485)
            ..lineTo(sx + 250, 355)
            ..lineTo(sx + 340, 445)
            ..lineTo(sx + 470, 320)
            ..lineTo(sx + 610, 430)
            ..lineTo(sx + 730, 365)
            ..lineTo(sx + 800, 445)
            ..lineTo(sx + 800, 560)
            ..close();
          canvas.drawPath(ruin, deep);
        }
        final tree = Paint()..color = palette.motif.withValues(alpha: 0.22);
        for (double x = parallax - 20; x < w + 800; x += 150) {
          canvas.drawRect(Rect.fromLTWH(x + 42, 270, 12, 245), tree);
          canvas.drawCircle(Offset(x + 48, 245), 58, tree);
        }
        break;

      case _SeasonVisual.circuit:
        // Season 4 — Neon Circuit: industrial panels and circuit traces.
        final panel = Paint()..color = palette.motif.withValues(alpha: 0.12);
        for (int i = 0; i < 5; i++) {
          final x = (i * 190.0) + parallax * 0.35;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, 120 + (i.isEven ? 30 : 0), 135, 250),
              const Radius.circular(10),
            ),
            panel,
          );
        }
        final trace = Paint()
          ..color = palette.accent.withValues(alpha: 0.24)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        for (int i = 0; i < 7; i++) {
          final y = 110.0 + i * 62;
          final path = Path()
            ..moveTo(0, y)
            ..lineTo(120, y)
            ..lineTo(155, y + 28)
            ..lineTo(300, y + 28)
            ..lineTo(335, y);
          canvas.drawPath(path, trace);
        }
        break;

      case _SeasonVisual.frozen:
        // Season 5 — Frozen Abyss: cave geometry, ice sheets and cold glow.
        final aurora = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.motif.withValues(alpha: 0.18),
              Colors.transparent,
              palette.accent.withValues(alpha: 0.08),
            ],
          ).createShader(rect);
        canvas.drawRect(rect, aurora);
        final ice = Paint()..color = palette.motif.withValues(alpha: 0.24);
        for (int i = 0; i < 7; i++) {
          final x = ((i * 145.0) + parallax * 0.25) % 900;
          final top = Path()
            ..moveTo(x, 0)
            ..lineTo(x + 28, 0)
            ..lineTo(x + 15, 92 + (i % 3) * 22)
            ..close();
          canvas.drawPath(top, ice);
        }
        for (int i = 0; i < 5; i++) {
          final x = ((i * 190.0) + 80 + parallax * 0.18) % 900;
          final bottom = Path()
            ..moveTo(x, 600)
            ..lineTo(x + 36, 600)
            ..lineTo(x + 18, 490 - (i % 2) * 30)
            ..close();
          canvas.drawPath(bottom, ice);
        }
        break;

      case _SeasonVisual.rift:
        // Season 6 — The Rift: fractured planes around a dark void.
        final voidPaint = Paint()
          ..shader = RadialGradient(
            colors: [const Color(0xFF020205), palette.bottom],
          ).createShader(Rect.fromCircle(center: Offset(410, 310), radius: 280));
        canvas.drawCircle(Offset(410, 310), 280, voidPaint);

        final fracture = Paint()
          ..color = palette.accent.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        for (int i = 0; i < 7; i++) {
          final x = 50.0 + i * 125.0 + parallax * 0.12;
          final path = Path()
            ..moveTo(x, 80)
            ..lineTo(x - 24, 180)
            ..lineTo(x + 16, 255)
            ..lineTo(x - 12, 355)
            ..lineTo(x + 28, 475);
          canvas.drawPath(path, fracture);
        }
        break;

      case _SeasonVisual.cosmic:
        break;
    }

    // Low-contrast horizon keeps the playable geometry readable without
    // turning the environment into decoration overload.
    canvas.drawRect(
      Rect.fromLTWH(0, h - 72, w, 72),
      Paint()..color = palette.bottom.withValues(alpha: 0.30),
    );
  }

  void _drawSeasonMechanicLayer(Canvas canvas) {
    final plan = TrollStagePlan.fromStageId(stageId);
    final season = _seasonForStage(stageId);
    final palette = _paletteForSeason(season);
    final accent = palette.accent.withValues(alpha: 0.24);
    final strong = palette.accent.withValues(alpha: 0.42);
    final worldWidth = engine.maxMapWidth;

    final p = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // The mechanic is deliberately part of the environment. It is not a
    // second UI layer: every cue is placed in world coordinates and scrolls
    // with the level.
    switch (plan.mechanicId) {
      case 1: // Appearing spikes
        for (double x = 22 * 40; x < worldWidth; x += 260) {
          canvas.drawLine(Offset(x, 515), Offset(x + 18, 496), p);
          canvas.drawLine(Offset(x + 18, 496), Offset(x + 36, 515), p);
        }
        break;
      case 2: // Erratic spikes / thwomps
        for (double x = 420; x < worldWidth; x += 320) {
          canvas.drawRect(Rect.fromLTWH(x, 42, 56, 5), p);
          canvas.drawLine(Offset(x + 28, 47), Offset(x + 28, 82), p);
        }
        break;
      case 3: // Falling floor
        for (double x = 600; x < worldWidth; x += 360) {
          final crack = Path()
            ..moveTo(x, 515)
            ..lineTo(x + 18, 532)
            ..lineTo(x + 8, 548)
            ..lineTo(x + 30, 565);
          canvas.drawPath(crack, p);
        }
        break;
      case 4: // Spotlight
        canvas.drawCircle(
          Offset(engine.player.rect.x + 20, engine.player.rect.y + 20),
          210,
          Paint()
            ..color = palette.accent.withValues(alpha: 0.06)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        break;
      case 5: // Time freeze
        for (int i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(260 + i * 170.0, 110),
            22 + i * 5,
            p,
          );
        }
        break;
      case 6: // Inverted gravity
        for (double x = 220; x < worldWidth; x += 300) {
          canvas.drawLine(Offset(x, 70), Offset(x, 105), strongPaint(strong));
          canvas.drawLine(Offset(x - 7, 80), Offset(x, 70), strongPaint(strong));
          canvas.drawLine(Offset(x + 7, 80), Offset(x, 70), strongPaint(strong));
        }
        break;
      case 7: // Bouncy
        for (double x = 500; x < worldWidth; x += 280) {
          canvas.drawArc(Rect.fromLTWH(x, 505, 48, 26), pi, pi, false, p);
          canvas.drawLine(Offset(x + 8, 532), Offset(x + 40, 532), p);
        }
        break;
      case 8: // Ghost shadow
        for (double x = 420; x < worldWidth; x += 260) {
          canvas.drawOval(Rect.fromLTWH(x, 440, 28, 46), p);
        }
        break;
      case 9: // Conveyor
        for (double x = 430; x < worldWidth; x += 110) {
          _drawArrow(canvas, Offset(x, 510), accent);
        }
        break;
      case 10: // Wall chase
        canvas.drawLine(
          Offset(engine.chaseWallX, 40),
          Offset(engine.chaseWallX, 555),
          strongPaint(strong),
        );
        break;
      case 11: // Rising lava
        canvas.drawLine(
          Offset(engine.cameraX - 100, engine.lavaY),
          Offset(engine.cameraX + 900, engine.lavaY),
          strongPaint(strong),
        );
        break;
      case 12: // Low gravity
        for (int i = 0; i < 9; i++) {
          final x = 120.0 + i * 87;
          canvas.drawCircle(Offset(x, 170 + (i % 3) * 70.0), 3, p);
        }
        break;
      case 13: // Flappy
        for (double x = 520; x < worldWidth; x += 300) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, 80, 26, 150), const Radius.circular(6)),
            p,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, 360, 26, 130), const Radius.circular(6)),
            p,
          );
        }
        break;
      case 14: // Tiny character
        for (double x = 520; x < worldWidth; x += 250) {
          canvas.drawRect(Rect.fromLTWH(x, 445, 42, 6), p);
          canvas.drawRect(Rect.fromLTWH(x + 12, 425, 18, 20), p);
        }
        break;
      case 15: // Dash
        for (double x = 450; x < worldWidth; x += 220) {
          canvas.drawLine(Offset(x, 250), Offset(x + 70, 250), strongPaint(strong));
          canvas.drawLine(Offset(x + 50, 242), Offset(x + 70, 250), strongPaint(strong));
          canvas.drawLine(Offset(x + 50, 258), Offset(x + 70, 250), strongPaint(strong));
        }
        break;
      case 16: // Wind
        for (double y = 160; y < 460; y += 70) {
          canvas.drawLine(Offset(300, y), Offset(430, y - 22), p);
          canvas.drawLine(Offset(390, y - 29), Offset(430, y - 22), p);
        }
        break;
      case 17: // Ice floor
        for (double x = 420; x < worldWidth; x += 250) {
          canvas.drawLine(Offset(x, 512), Offset(x + 36, 535), p);
          canvas.drawLine(Offset(x + 36, 535), Offset(x + 72, 512), p);
        }
        break;
      case 18: // Screen blink
        canvas.drawRect(
          Rect.fromLTWH(12, 12, engine.logicalWidth - 24, engine.logicalHeight - 24),
          p,
        );
        break;
      case 19: // Mirror controls
        canvas.drawLine(Offset(engine.cameraX + 400, 40), Offset(engine.cameraX + 400, 555), p);
        break;
      case 20: // Absolute chaos
        for (double x = 500; x < worldWidth; x += 210) {
          canvas.drawCircle(Offset(x, 110 + (x % 160)), 5, p);
        }
        break;
      default:
        break;
    }
  }

  Paint strongPaint(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  void _drawArrow(Canvas canvas, Offset at, Color color) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawLine(Offset(at.dx - 16, at.dy), Offset(at.dx + 16, at.dy), paint);
    canvas.drawLine(Offset(at.dx + 8, at.dy - 7), Offset(at.dx + 16, at.dy), paint);
    canvas.drawLine(Offset(at.dx + 8, at.dy + 7), Offset(at.dx + 16, at.dy), paint);
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
    final palette = _paletteForSeason(_seasonForStage(stageId));
    final cx = rect.x + rect.w / 2;
    final cy = rect.y + rect.h / 2;
    final r = (rect.w > rect.h ? rect.w : rect.h) * 0.52;

    final glow = Paint()
      ..color = palette.accent.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 18);
    canvas.drawCircle(Offset(cx, cy), r, glow);

    final outer = Paint()
      ..color = palette.platformDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r, outer);

    final ring = Paint()
      ..color = palette.rim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(cx, cy), r, ring);

    final inner = Paint()
      ..shader = RadialGradient(
        colors: [palette.accent.withValues(alpha: 0.9), palette.bottom],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * .78));
    canvas.drawCircle(Offset(cx, cy), r * .78, inner);

    // Angular season gate: the exit is unmistakable, but its material belongs
    // to the current world rather than being a generic magical portal.
    final gate = Path()
      ..moveTo(cx, cy - r * .55)
      ..lineTo(cx + r * .45, cy)
      ..lineTo(cx, cy + r * .55)
      ..lineTo(cx - r * .45, cy)
      ..close();
    canvas.drawPath(
      gate,
      Paint()..color = palette.rim.withValues(alpha: 0.22),
    );
    canvas.drawPath(
      gate,
      Paint()
        ..color = palette.accent.withValues(alpha: 0.82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
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