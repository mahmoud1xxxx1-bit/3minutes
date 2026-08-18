import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../minigames/data/game_registry.dart';
import '../data/match_backend.dart';
import '../domain/match_session.dart';
import 'match_play_screen.dart';

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

  @override
  void initState() {
    super.initState();
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
      await widget.matchBackend.markReady(
        matchId: widget.matchId,
        uid: widget.uid,
      );
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.stay),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _cancelBusy = true;
      _error = null;
    });
    try {
      await widget.matchBackend.cancelMatch(
        matchId: widget.matchId,
        uid: widget.uid,
      );
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
        MaterialPageRoute<void>(
          builder: (_) => MatchPlayScreen(
            matchId: widget.matchId,
            uid: widget.uid,
            matchBackend: widget.matchBackend,
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(l10n.matchRoom),
              leading: match?.status == MatchStatus.waitingReady &&
                      match?.registryVersion == GameRegistry.version
                  ? IconButton(
                      tooltip: l10n.leaveMatch,
                      onPressed: _cancelBusy ? null : _cancelMatch,
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
            ),
            body: CosmicBackground(
              child: SafeArea(
                top: false,
                child: _buildBody(context, snapshot, match),
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
  ) {
    final l10n = AppLocalizations.of(context);
    if (snapshot.hasError) {
      return _CenterPanel(
        child: Text(
          l10n.connectionLostRoom,
          textAlign: TextAlign.center,
          style: const TextStyle(color: GameColors.muted, height: 1.5),
        ),
      );
    }
    if (match == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (match.registryVersion != GameRegistry.version) {
      return _CenterPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.system_update_alt_rounded,
              size: 52,
              color: GameColors.warning,
            ),
            const SizedBox(height: GameSpacing.md),
            Text(
              l10n.legacyMatchTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: GameSpacing.sm),
            Text(
              l10n.legacyMatchDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.muted),
            ),
            const SizedBox(height: GameSpacing.lg),
            FilledButton(
              onPressed: _cancelBusy ? null : _clearLegacyMatch,
              child: Text(_cancelBusy ? l10n.removing : l10n.removeOldMatch),
            ),
            if (_error != null) ...[
              const SizedBox(height: GameSpacing.sm),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: GameColors.danger),
              ),
            ],
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
            const Icon(
              Icons.person_off_rounded,
              size: 58,
              color: GameColors.danger,
            ),
            const SizedBox(height: GameSpacing.md),
            Text(
              opponentLeft ? l10n.opponentLeft : l10n.matchCancelled,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: GameSpacing.lg),
            FilledButton(
              onPressed: _leaveCancelledMatch,
              child: Text(l10n.backToHome),
            ),
          ],
        ),
      );
    }

    final countdown = _countdown(match);
    if (countdown == 0) _openPlay();

    final myName = match.playerAId == widget.uid
        ? match.playerAName
        : match.playerBName;
    final opponentReady =
        match.playerAId == widget.uid ? match.readyB : match.readyA;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GameSpacing.md,
        GameSpacing.sm,
        GameSpacing.md,
        GameSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlayerPanel(
            label: l10n.you,
            name: myName,
            ready: match.isReady(widget.uid),
            accent: GameColors.accentBright,
          ),
          const SizedBox(height: GameSpacing.sm),
          _PlayerPanel(
            label: l10n.opponent,
            name: match.opponentName(widget.uid),
            ready: opponentReady,
            accent: GameColors.warning,
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: GameDurations.normal,
            child: countdown != null
                ? Column(
                    key: ValueKey(countdown),
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: GameColors.cosmicGradient,
                          boxShadow: GameShadows.primaryGlow,
                        ),
                        child: Text(
                          countdown == 0 ? l10n.go : '$countdown',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      const SizedBox(height: GameSpacing.md),
                      Text(
                        l10n.bothPlayersReady,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  )
                : CosmicPanel(
                    key: const ValueKey('instructions'),
                    child: Text(
                      l10n.readyInstructions,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: GameColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ),
          ),
          const Spacer(),
          if (countdown == null && !match.isReady(widget.uid))
            CosmicPrimaryButton(
              onPressed: _readyBusy || _cancelBusy ? null : _markReady,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on_rounded),
                  const SizedBox(width: GameSpacing.sm),
                  Text(_readyBusy ? l10n.gettingReady : l10n.ready),
                ],
              ),
            )
          else if (countdown == null)
            FilledButton.icon(
              onPressed: null,
              icon: const Icon(Icons.hourglass_top_rounded),
              label: Text(l10n.waitingForOpponent),
            ),
          if (_error != null) ...[
            const SizedBox(height: GameSpacing.sm),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.danger),
            ),
          ],
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
        child: CosmicPanel(
          glow: true,
          padding: const EdgeInsets.all(GameSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.label,
    required this.name,
    required this.ready,
    required this.accent,
  });

  final String label;
  final String name;
  final bool ready;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CosmicPanel(
      glow: ready,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ready ? GameColors.cosmicGradient : null,
              color: ready ? null : accent.withValues(alpha: .12),
            ),
            child: Icon(
              ready ? Icons.check_rounded : Icons.person_rounded,
              color: ready ? Colors.white : accent,
            ),
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(label, style: const TextStyle(color: GameColors.muted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (ready ? GameColors.success : GameColors.surfaceRaised)
                  .withValues(alpha: ready ? .12 : 1),
              borderRadius: BorderRadius.circular(GameRadii.pill),
            ),
            child: Text(
              ready ? l10n.ready : l10n.waiting,
              style: TextStyle(
                color: ready ? GameColors.success : GameColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
