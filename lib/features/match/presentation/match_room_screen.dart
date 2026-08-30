import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/arena_copy.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../economy/data/cosmetic_loadout_repository.dart';
import '../../economy/domain/cosmetic_loadout.dart';
import '../../economy/presentation/cosmetic_runtime.dart';
import '../../minigames/data/game_registry.dart';
import '../data/match_backend.dart';
import '../domain/match_session.dart';
import 'arena_versus_stage.dart';
import 'audio_match_play_screen.dart';

class MatchRoomScreen extends StatefulWidget {
  const MatchRoomScreen({
    super.key,
    required this.matchId,
    required this.uid,
    required this.matchBackend,
  });

  final String matchId;
  final String uid;
  final MatchBackend matchBackend;

  @override
  State<MatchRoomScreen> createState() => _MatchRoomScreenState();
}

class _MatchRoomScreenState extends State<MatchRoomScreen> {
  Timer? _ticker;
  bool _readyBusy = false;
  bool _cancelBusy = false;
  bool _navigating = false;
  String? _error;
  late final CosmeticLoadoutRepository _loadouts;

  @override
  void initState() {
    super.initState();
    _loadouts = CosmeticLoadoutRepository();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _markReady() async {
    if (_readyBusy || _cancelBusy) return;
    setState(() {
      _readyBusy = true;
      _error = null;
    });
    try {
      await widget.matchBackend.markReady(matchId: widget.matchId, uid: widget.uid);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).couldNotReady);
    } finally {
      if (mounted) setState(() => _readyBusy = false);
    }
  }

  Future<void> _cancelMatch() async {
    if (_cancelBusy || _readyBusy) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveMatchQuestion),
        content: Text(l10n.leaveMatchDescription),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.stay)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.leave)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _cancelBusy = true;
      _error = null;
    });
    try {
      await widget.matchBackend.cancelMatch(matchId: widget.matchId, uid: widget.uid);
      await widget.matchBackend.clearTicket(widget.uid);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).couldNotLeaveMatch);
    } finally {
      if (mounted) setState(() => _cancelBusy = false);
    }
  }

  Future<void> _clearLegacyMatch() async {
    if (_cancelBusy) return;
    setState(() {
      _cancelBusy = true;
      _error = null;
    });
    try {
      await widget.matchBackend.clearTicket(widget.uid);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).couldNotRemoveOldMatch);
    } finally {
      if (mounted) setState(() => _cancelBusy = false);
    }
  }

  int? _countdown(MatchSession match) {
    final startedAt = match.countdownStartedAt;
    if (startedAt == null) return null;
    final goAt = startedAt.add(const Duration(seconds: 3));
    final remainingMs = goAt.difference(DateTime.now()).inMilliseconds;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }

  void _openPlay() {
    if (_navigating) return;
    _navigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: AudioMatchPlayScreen(
              matchId: widget.matchId,
              uid: widget.uid,
              matchBackend: widget.matchBackend,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _leaveCancelledMatch() async {
    await widget.matchBackend.clearTicket(widget.uid);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: StreamBuilder<MatchSession?>(
        stream: widget.matchBackend.watchMatch(widget.matchId),
        builder: (context, snapshot) {
          final match = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: CosmicBackground(
              child: SafeArea(
                child: _buildBody(context, snapshot, match, l10n),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<MatchSession?> snapshot,
    MatchSession? match,
    AppLocalizations l10n,
  ) {
    final copy = ArenaCopy.of(context);
    if (snapshot.hasError) {
      return _CenterPanel(child: Text(l10n.connectionLostRoom, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.muted, height: 1.5)));
    }
    if (match == null) return const Center(child: CircularProgressIndicator());

    if (match.registryVersion != GameRegistry.version) {
      return _CenterPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.system_update_alt_rounded, size: 52, color: GameColors.warning),
            const SizedBox(height: GameSpacing.md),
            Text(l10n.legacyMatchTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: GameSpacing.sm),
            Text(l10n.legacyMatchDescription, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.muted)),
            const SizedBox(height: GameSpacing.lg),
            FilledButton(onPressed: _cancelBusy ? null : _clearLegacyMatch, child: Text(_cancelBusy ? l10n.removing : l10n.removeOldMatch)),
          ],
        ),
      );
    }

    if (match.status == MatchStatus.cancelled) {
      final opponentLeft = match.cancelledBy != widget.uid;
      return _CenterPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_rounded, size: 58, color: GameColors.danger),
            const SizedBox(height: GameSpacing.md),
            Text(opponentLeft ? l10n.opponentLeft : l10n.matchCancelled, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: GameSpacing.lg),
            FilledButton(onPressed: _leaveCancelledMatch, child: Text(l10n.backToHome)),
          ],
        ),
      );
    }

    final countdown = _countdown(match);
    if (countdown == 0) _openPlay();

    final iAmA = match.playerAId == widget.uid;
    final myName = iAmA ? match.playerAName : match.playerBName;
    final myAvatar = iAmA ? match.playerAAvatarId : match.playerBAvatarId;
    final opponentName = match.opponentName(widget.uid);
    final opponentAvatar = match.opponentAvatarId(widget.uid);
    final opponentReady = iAmA ? match.readyB : match.readyA;
    final bothReady = match.isReady(widget.uid) && opponentReady;

    return Padding(
      padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.sm, GameSpacing.md, GameSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.leaveMatch,
                onPressed: match.status == MatchStatus.waitingReady && !_cancelBusy ? _cancelMatch : null,
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.readyCheck, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(copy.rankedRules, style: const TextStyle(color: GameColors.muted, fontSize: 9)),
                  ],
                ),
              ),
              ArenaPill(
                label: bothReady ? copy.locked : copy.waiting,
                icon: bothReady ? Icons.lock_rounded : Icons.sync_rounded,
                color: bothReady ? GameColors.success : GameColors.warning,
                solid: bothReady,
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.lg),
          ArenaVersusStage(
            myName: myName,
            myAvatarId: myAvatar,
            myReady: match.isReady(widget.uid),
            opponentName: opponentName,
            opponentAvatarId: opponentAvatar,
            opponentReady: opponentReady,
            gameCount: match.gameCount,
            ranked: match.isRanked,
            countdown: countdown,
          ),
          const SizedBox(height: GameSpacing.md),
          if (countdown != null)
            FutureBuilder<CosmeticLoadout>(
              future: _loadouts.load(widget.uid),
              builder: (context, loadoutSnapshot) {
                final loadout = loadoutSnapshot.data ?? const CosmeticLoadout();
                if (loadout.matchIntroId == null) return const SizedBox.shrink();
                return CosmeticMatchIntro(
                  introId: loadout.matchIntroId!,
                  playerName: myName,
                  opponentName: opponentName,
                  height: 155,
                );
              },
            )
          else
            ArenaCard(
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: GameColors.violet),
                  const SizedBox(width: GameSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.readyInstructions,
                      style: const TextStyle(color: GameColors.muted, height: 1.45, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: GameSpacing.sm),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.danger)),
          ],
          const Spacer(),
          if (countdown == null && !match.isReady(widget.uid))
            ArenaPlayButton(
              title: _readyBusy ? l10n.gettingReady : l10n.ready,
              subtitle: copy.isArabic ? 'ثبّت جاهزيتك وابدأ العد التنازلي' : 'Lock in and trigger the countdown',
              icon: Icons.flash_on_rounded,
              onPressed: _readyBusy || _cancelBusy ? null : _markReady,
            )
          else if (countdown == null)
            ArenaCard(
              accent: GameColors.success,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: GameSpacing.sm),
                  Text(l10n.waitingForOpponent, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CenterPanel extends StatelessWidget {
  const _CenterPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: ArenaCard(glow: true, padding: const EdgeInsets.all(GameSpacing.lg), child: child),
      ),
    );
  }
}
