import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/mini_game_evidence.dart';
import '../../economy/data/cosmetic_loadout_repository.dart';
import '../../economy/domain/cosmetic_loadout.dart';
import '../../economy/presentation/cosmetic_runtime.dart';
import '../../minigames/data/game_registry.dart';
import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/presentation/mini_game_copy.dart';
import '../../minigames/presentation/mini_game_host.dart';
import '../data/match_backend.dart';
import '../domain/match_progress.dart';
import '../domain/match_ranking.dart';
import '../domain/match_runtime.dart';
import '../domain/match_session.dart';

class MatchPlayScreen extends StatefulWidget {
  const MatchPlayScreen({
    super.key,
    required this.matchId,
    required this.uid,
    required this.matchBackend,
  });

  final String matchId;
  final String uid;
  final MatchBackend matchBackend;

  @override
  State<MatchPlayScreen> createState() => _MatchPlayScreenState();
}

class _MatchPlayScreenState extends State<MatchPlayScreen> {
  Timer? _ticker;
  MatchRuntime? _runtime;
  bool _submitBusy = false;
  bool _finishing = false;
  bool _rematchBusy = false;
  String? _error;
  late final CosmeticLoadoutRepository _loadouts;
  String? _winnerLoadoutUid;
  Future<CosmeticLoadout>? _winnerLoadoutFuture;

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

  Future<CosmeticLoadout> _winnerLoadout(String uid) {
    if (_winnerLoadoutUid != uid || _winnerLoadoutFuture == null) {
      _winnerLoadoutUid = uid;
      _winnerLoadoutFuture = _loadouts.load(uid);
    }
    return _winnerLoadoutFuture!;
  }

  MatchRuntime? _ensureRuntime(MatchSession match) {
    final countdown = match.countdownStartedAt;
    if (countdown == null) return null;
    final progress = match.progressOf(widget.uid);
    final current = _runtime;
    final serverAhead = current != null &&
        (progress.completedGames > current.progress.completedGames ||
            progress.totalScore > current.progress.totalScore ||
            progress.elapsedMs > current.progress.elapsedMs);
    if (current == null || serverAhead) {
      _runtime = MatchRuntime(
        seed: match.seed,
        startedAt: countdown.add(const Duration(seconds: 3)),
        gameCount: AppConfig.gamesPerMatch,
        initialProgress: progress,
      );
    }
    return _runtime;
  }

  Future<void> _completeGame(
    MatchSession match,
    MiniGameResult result,
  ) async {
    final runtime = _runtime;
    if (runtime == null || _submitBusy || runtime.isExpired(DateTime.now())) return;
    final game = runtime.currentGame;
    if (game == null) return;
    final gameIndex = runtime.progress.completedGames;
    final gameSeed = runtime.seed ^ ((gameIndex + 1) * 0x45d9f3b);
    final evidence = MiniGameEvidence(
      gameId: game.id,
      gameIndex: gameIndex,
      gameSeed: gameSeed,
      score: result.score,
      accuracy: result.accuracy,
      mistakes: result.mistakes,
      durationMs: result.duration.inMilliseconds,
    );
    setState(() {
      _submitBusy = true;
      _error = null;
    });
    try {
      final next = runtime.previewResult(result);
      await widget.matchBackend.submitProgress(
        matchId: match.id,
        uid: widget.uid,
        progress: next,
        evidence: evidence,
      );
      runtime.recordResult(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).couldNotSaveProgress);
    } finally {
      if (mounted) setState(() => _submitBusy = false);
    }
  }

  Future<void> _finishMatch(MatchSession match) async {
    if (_finishing || match.status == MatchStatus.finished) return;
    _finishing = true;
    try {
      await widget.matchBackend.finishMatch(
        matchId: match.id,
        uid: widget.uid,
      );
    } catch (_) {
      // Another player may have finished the shared document first.
    } finally {
      _finishing = false;
    }
  }

  Future<void> _requestRematch(MatchSession match) async {
    if (_rematchBusy) return;
    setState(() {
      _rematchBusy = true;
      _error = null;
    });
    try {
      final newMatchId = await widget.matchBackend.requestRematch(
        matchId: match.id,
        uid: widget.uid,
      );
      if (newMatchId != null && mounted) {
        await widget.matchBackend.clearTicket(widget.uid);
        await widget.matchBackend.syncTicket(
          uid: widget.uid,
          matchId: newMatchId,
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => MatchRoomScreen(
              matchId: newMatchId,
              uid: widget.uid,
              matchBackend: widget.matchBackend,
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).rematchCouldNotStart);
    } finally {
      if (mounted) setState(() => _rematchBusy = false);
    }
  }

  Future<void> _cancelRematch(MatchSession match) async {
    if (_rematchBusy) return;
    setState(() {
      _rematchBusy = true;
      _error = null;
    });
    try {
      await widget.matchBackend.cancelRematch(
        matchId: match.id,
        uid: widget.uid,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).couldNotCancelRematch);
    } finally {
      if (mounted) setState(() => _rematchBusy = false);
    }
  }

  Future<void> _leaveResults(MatchSession match) async {
    try {
      await widget.matchBackend.cancelRematch(matchId: match.id, uid: widget.uid);
    } catch (_) {}
    try {
      await widget.matchBackend.clearTicket(widget.uid);
    } catch (_) {}
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _clock(Duration remaining) {
    final totalSeconds = (remaining.inMilliseconds + 999) ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: GameColors.background,
        body: CosmicBackground(
          showOrbs: false,
          child: SafeArea(
            child: StreamBuilder<MatchSession?>(
              stream: widget.matchBackend.watchMatch(widget.matchId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _MessageCard(text: l10n.connectionLostMatch);
                }
                final match = snapshot.data;
                if (match == null) return const Center(child: CircularProgressIndicator());
                if (match.status == MatchStatus.cancelled) {
                  return _CancelledView(
                    opponentLeft: match.cancelledBy != widget.uid,
                    onExit: () => _leaveResults(match),
                  );
                }
                if (match.registryVersion != GameRegistry.version) {
                  return _MessageCard(text: l10n.legacyMatchTitle, color: GameColors.warning);
                }
                final runtime = _ensureRuntime(match);
                if (runtime == null) return const Center(child: CircularProgressIndicator());

                final now = DateTime.now();
                final remaining = runtime.remaining(now);
                final expired = runtime.isExpired(now);
                if (expired && match.status != MatchStatus.finished) {
                  unawaited(_finishMatch(match));
                }

                if (match.status == MatchStatus.finished || expired) {
                  final playerA = MatchPlayerResult(
                    playerId: match.playerAId,
                    progress: match.progressA,
                  );
                  final playerB = MatchPlayerResult(
                    playerId: match.playerBId,
                    progress: match.progressB,
                  );
                  final outcome = MatchRanking.compare(playerA, playerB);
                  final winnerUid = switch (outcome) {
                    MatchOutcome.playerA => match.playerAId,
                    MatchOutcome.playerB => match.playerBId,
                    MatchOutcome.tie => null,
                  };
                  return _MatchResultView(
                    match: match,
                    uid: widget.uid,
                    outcome: outcome,
                    rematchBusy: _rematchBusy,
                    error: _error,
                    winnerLoadout: winnerUid == null ? null : _winnerLoadout(winnerUid),
                    onRematch: () => _requestRematch(match),
                    onCancelRematch: () => _cancelRematch(match),
                    onExit: () => _leaveResults(match),
                  );
                }

                if (runtime.allGamesCompleted) {
                  return _WaitingForOpponentView(
                    opponentName: match.opponentName(widget.uid),
                    opponentProgress: match.opponentProgress(widget.uid),
                    remaining: remaining,
                  );
                }

                final game = runtime.currentGame!;
                final gameIndex = runtime.progress.completedGames;
                final gameSeed = runtime.seed ^ ((gameIndex + 1) * 0x45d9f3b);
                return Padding(
                  padding: const EdgeInsets.all(GameSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RankedHud(
                        gameIndex: gameIndex,
                        remainingLabel: _clock(remaining),
                        danger: remaining.inSeconds <= 20,
                        myProgress: runtime.progress,
                        opponentProgress: match.opponentProgress(widget.uid),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: GameSpacing.xs),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.danger)),
                      ],
                      const SizedBox(height: GameSpacing.sm),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: GameColors.surface,
                            borderRadius: BorderRadius.circular(GameRadii.panel),
                            border: Border.all(color: GameColors.surfaceStrong, width: .8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AbsorbPointer(
                            absorbing: _submitBusy,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(GameSpacing.md),
                                    child: MiniGameHost(
                                      key: ValueKey('$gameIndex-${game.id}'),
                                      game: game,
                                      config: MiniGameConfig(seed: gameSeed, difficulty: 1),
                                      onComplete: (result) => _completeGame(match, result),
                                    ),
                                  ),
                                ),
                                if (_submitBusy)
                                  const Positioned.fill(
                                    child: ColoredBox(
                                      color: Color(0x77080D14),
                                      child: Center(child: CircularProgressIndicator()),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: GameSpacing.xs),
                      Text(
                        MiniGameCopy.fromContext(context).title(game.id),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RankedHud extends StatelessWidget {
  const _RankedHud({
    required this.gameIndex,
    required this.remainingLabel,
    required this.danger,
    required this.myProgress,
    required this.opponentProgress,
  });

  final int gameIndex;
  final String remainingLabel;
  final bool danger;
  final MatchProgress myProgress;
  final MatchProgress opponentProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(color: GameColors.accentSoft, borderRadius: BorderRadius.circular(GameRadii.pill)),
                child: Text(
                  '${l10n.gameLabel} ${gameIndex + 1}/${AppConfig.gamesPerMatch}',
                  style: const TextStyle(color: GameColors.accentBright, fontWeight: FontWeight.w900),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: danger ? GameColors.danger.withValues(alpha: .10) : GameColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(GameRadii.pill),
                ),
                child: Text(
                  remainingLabel,
                  style: TextStyle(
                    color: danger ? GameColors.danger : GameColors.textStrong,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.sm),
          Row(
            children: [
              Expanded(child: _ProgressStrip(label: l10n.you, progress: myProgress, accent: GameColors.accentBright)),
              const SizedBox(width: GameSpacing.sm),
              Expanded(child: _ProgressStrip(label: l10n.opponent, progress: opponentProgress, accent: GameColors.warning)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({required this.label, required this.progress, required this.accent});
  final String label;
  final MatchProgress progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final value = progress.completedGames / AppConfig.gamesPerMatch;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 11))),
            Text('${progress.completedGames}/${AppConfig.gamesPerMatch}', style: const TextStyle(color: GameColors.muted, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(GameRadii.pill),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 6,
            backgroundColor: GameColors.surfaceRaised,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _WaitingForOpponentView extends StatelessWidget {
  const _WaitingForOpponentView({required this.opponentName, required this.opponentProgress, required this.remaining});
  final String opponentName;
  final MatchProgress opponentProgress;
  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: CosmicPanel(
          glow: true,
          padding: const EdgeInsets.all(GameSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 64, color: GameColors.accentBright),
              const SizedBox(height: GameSpacing.md),
              Text(l10n.waitingForOpponent, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: GameSpacing.sm),
              Text(
                '$opponentName • ${opponentProgress.completedGames}/${AppConfig.gamesPerMatch}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: GameColors.muted),
              ),
              const SizedBox(height: GameSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(GameRadii.pill),
                child: LinearProgressIndicator(
                  value: (opponentProgress.completedGames / AppConfig.gamesPerMatch).clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: GameColors.surfaceRaised,
                ),
              ),
              const SizedBox(height: GameSpacing.md),
              Text('${remaining.inSeconds}s', style: const TextStyle(color: GameColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchResultView extends StatelessWidget {
  const _MatchResultView({
    required this.match,
    required this.uid,
    required this.outcome,
    required this.rematchBusy,
    required this.error,
    required this.winnerLoadout,
    required this.onRematch,
    required this.onCancelRematch,
    required this.onExit,
  });

  final MatchSession match;
  final String uid;
  final MatchOutcome outcome;
  final bool rematchBusy;
  final String? error;
  final Future<CosmeticLoadout>? winnerLoadout;
  final VoidCallback onRematch;
  final VoidCallback onCancelRematch;
  final VoidCallback onExit;

  bool get _won =>
      (outcome == MatchOutcome.playerA && match.playerAId == uid) ||
      (outcome == MatchOutcome.playerB && match.playerBId == uid);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final my = match.progressOf(uid);
    final opponent = match.opponentProgress(uid);
    final rematchAccepted = match.rematchAcceptedBy(uid);
    final opponentAccepted = match.opponentRematchAccepted(uid);
    final winnerName = switch (outcome) {
      MatchOutcome.playerA => match.playerAName,
      MatchOutcome.playerB => match.playerBName,
      MatchOutcome.tie => '',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(GameSpacing.lg, GameSpacing.xl, GameSpacing.lg, GameSpacing.xl),
      children: [
        if (winnerLoadout != null)
          FutureBuilder<CosmeticLoadout>(
            future: winnerLoadout,
            builder: (context, snapshot) {
              final effect = snapshot.data?.victoryEffectId;
              if (effect != null) {
                return CosmeticVictoryEffect(effectId: effect, winnerName: winnerName, height: 240);
              }
              return _DefaultResultHero(won: _won, outcome: outcome);
            },
          )
        else
          _DefaultResultHero(won: _won, outcome: outcome),
        const SizedBox(height: GameSpacing.lg),
        _ResultRow(label: l10n.you, progress: my, accent: GameColors.accentBright),
        const SizedBox(height: GameSpacing.sm),
        _ResultRow(label: l10n.opponent, progress: opponent, accent: GameColors.warning),
        const SizedBox(height: GameSpacing.lg),
        CosmicPanel(
          child: Text(
            l10n.rankingRule,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.muted, height: 1.45),
          ),
        ),
        const SizedBox(height: GameSpacing.lg),
        if (!rematchAccepted)
          CosmicPrimaryButton(
            onPressed: rematchBusy ? null : onRematch,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh_rounded),
                const SizedBox(width: GameSpacing.sm),
                Text(rematchBusy ? l10n.pleaseWait : l10n.rematch),
              ],
            ),
          )
        else
          Column(
            children: [
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_rounded),
                label: Text(opponentAccepted ? l10n.startingRematch : l10n.waitingForOpponent),
              ),
              const SizedBox(height: GameSpacing.sm),
              TextButton(
                onPressed: rematchBusy ? null : onCancelRematch,
                child: Text(l10n.cancelRematch),
              ),
            ],
          ),
        const SizedBox(height: GameSpacing.sm),
        OutlinedButton.icon(
          onPressed: rematchBusy ? null : onExit,
          icon: const Icon(Icons.home_rounded),
          label: Text(l10n.backToHome),
        ),
        if (error != null) ...[
          const SizedBox(height: GameSpacing.sm),
          Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.danger)),
        ],
      ],
    );
  }
}

class _DefaultResultHero extends StatelessWidget {
  const _DefaultResultHero({required this.won, required this.outcome});
  final bool won;
  final MatchOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: won ? GameColors.cosmicGradient : null,
              color: won ? null : GameColors.accentSoft,
              boxShadow: won ? GameShadows.primaryGlow : null,
            ),
            child: Icon(
              won ? Icons.emoji_events_rounded : Icons.sports_esports_rounded,
              size: 58,
              color: won ? Colors.white : GameColors.accentBright,
            ),
          ),
        ),
        const SizedBox(height: GameSpacing.sm),
        Text(
          outcome == MatchOutcome.tie ? l10n.draw : (won ? l10n.victory : l10n.defeat),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: won ? GameColors.rewardGold : GameColors.textStrong,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.progress, required this.accent});
  final String label;
  final MatchProgress progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CosmicPanel(
      glow: true,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${l10n.score}: ${progress.totalScore}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${l10n.accuracy}: ${(progress.averageAccuracy * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
              Text('${l10n.mistakes}: ${progress.mistakes}', style: const TextStyle(color: GameColors.muted, fontSize: 12)),
              Text('${progress.elapsedMs}ms', style: const TextStyle(color: GameColors.muted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelledView extends StatelessWidget {
  const _CancelledView({required this.opponentLeft, required this.onExit});
  final bool opponentLeft;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: CosmicPanel(
          glow: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded, size: 64, color: GameColors.danger),
              const SizedBox(height: GameSpacing.md),
              Text(opponentLeft ? l10n.opponentLeft : l10n.matchCancelled, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: GameSpacing.lg),
              FilledButton(onPressed: onExit, child: Text(l10n.backToHome)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.text, this.color = GameColors.muted});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: CosmicPanel(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: color))),
      ),
    );
  }
}

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
  bool _opening = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MatchSession?>(
      stream: widget.matchBackend.watchMatch(widget.matchId),
      builder: (context, snapshot) {
        final match = snapshot.data;
        if (match != null && match.countdownStartedAt != null && !_opening) {
          _opening = true;
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
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
