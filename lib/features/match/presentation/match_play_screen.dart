import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../minigames/data/game_registry.dart';
import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/presentation/mini_game_host.dart';
import '../data/match_backend.dart';
import '../domain/match_outcome.dart';
import '../domain/match_runtime.dart';
import '../domain/match_session.dart';
import '../domain/match_settlement.dart';

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
  bool _submitting = false;
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

  MatchRuntime? _ensureRuntime(MatchSession match) {
    final countdownStartedAt = match.countdownStartedAt;
    if (countdownStartedAt == null) return null;

    final savedProgress = match.progressFor(widget.uid);
    final current = _runtime;
    final serverIsAhead = current != null &&
        (savedProgress.completedGames > current.progress.completedGames ||
            savedProgress.totalScore > current.progress.totalScore ||
            savedProgress.elapsedMs > current.progress.elapsedMs);

    if (current == null || serverIsAhead) {
      _runtime = MatchRuntime(
        seed: match.seed,
        startedAt: countdownStartedAt.add(const Duration(seconds: 3)),
        gameCount: match.gameCount,
        initialProgress: savedProgress,
      );
    }
    return _runtime;
  }

  Future<void> _completeGame(
    MatchSession match,
    MiniGameResult result,
  ) async {
    final runtime = _runtime;
    if (runtime == null || _submitting || runtime.isExpired(DateTime.now())) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final nextProgress = runtime.previewResult(result);
      await widget.matchBackend.submitProgress(
        matchId: match.id,
        uid: widget.uid,
        progress: nextProgress,
        gameCount: match.gameCount,
      );
      runtime.recordResult(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).tryAgain);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _clock(Duration remaining) {
    final totalSeconds = (remaining.inMilliseconds + 999) ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final runtime = _runtime;
    final canExit = runtime != null &&
        (runtime.allGamesCompleted || runtime.isExpired(DateTime.now()));
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: canExit,
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<MatchSession?>(
            stream: widget.matchBackend.watchMatch(widget.matchId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(GameSpacing.lg),
                    child: Text(
                      l10n.connectionLostRoom,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: GameColors.muted, height: 1.5),
                    ),
                  ),
                );
              }

              final match = snapshot.data;
              if (match == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (match.registryVersion != GameRegistry.version) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(GameSpacing.lg),
                    child: Text(
                      l10n.legacyMatchTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: GameColors.warning),
                    ),
                  ),
                );
              }

              final activeRuntime = _ensureRuntime(match);
              if (activeRuntime == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final now = DateTime.now();
              final remaining = activeRuntime.remaining(now);
              final expired = activeRuntime.isExpired(now);
              final localComplete = activeRuntime.allGamesCompleted;

              if (expired || localComplete) {
                return _MatchResultView(
                  uid: widget.uid,
                  match: match,
                  matchBackend: widget.matchBackend,
                  localCompletedGames: activeRuntime.progress.completedGames,
                );
              }

              final game = activeRuntime.currentGame!;
              final gameIndex = activeRuntime.progress.completedGames;
              final gameSeed = activeRuntime.seed ^ ((gameIndex + 1) * 0x45d9f3b);
              final opponentProgress =
                  match.opponentProgress(widget.uid).completedGames;

              return Padding(
                padding: const EdgeInsets.all(GameSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(GameSpacing.md),
                      decoration: BoxDecoration(
                        color: GameColors.surface,
                        borderRadius: BorderRadius.circular(GameRadii.card),
                        border: Border.all(color: GameColors.surfaceStrong),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: GameColors.accentSoft,
                              borderRadius: BorderRadius.circular(GameRadii.pill),
                            ),
                            child: Text(
                              '${gameIndex + 1}/${match.gameCount}',
                              style: const TextStyle(
                                color: GameColors.accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: GameSpacing.sm),
                          Expanded(
                            child: Text(
                              game.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: GameSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: remaining.inSeconds <= 20
                                  ? GameColors.danger.withValues(alpha: 0.10)
                                  : GameColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(GameRadii.pill),
                            ),
                            child: Text(
                              _clock(remaining),
                              style: TextStyle(
                                color: remaining.inSeconds <= 20
                                    ? GameColors.danger
                                    : GameColors.textStrong,
                                fontWeight: FontWeight.w900,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(GameRadii.pill),
                      child: LinearProgressIndicator(
                        value: gameIndex / match.gameCount,
                        minHeight: 6,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: GameSpacing.sm),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: GameColors.danger),
                      ),
                    ],
                    const SizedBox(height: GameSpacing.sm),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: GameColors.surface,
                          borderRadius: BorderRadius.circular(GameRadii.panel),
                          border: Border.all(color: GameColors.surfaceStrong),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AbsorbPointer(
                          absorbing: _submitting,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(GameSpacing.md),
                                  child: MiniGameHost(
                                    key: ValueKey('$gameIndex-${game.id}'),
                                    game: game,
                                    config: MiniGameConfig(
                                      seed: gameSeed,
                                      difficulty: 1,
                                    ),
                                    onComplete: (result) =>
                                        _completeGame(match, result),
                                  ),
                                ),
                              ),
                              if (_submitting)
                                const Positioned.fill(
                                  child: ColoredBox(
                                    color: Color(0x77080D14),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GameSpacing.md,
                        vertical: GameSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: GameColors.surface,
                        borderRadius: BorderRadius.circular(GameRadii.card),
                        border: Border.all(color: GameColors.surfaceStrong),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sports_esports_rounded,
                            size: 18,
                            color: GameColors.warning,
                          ),
                          const SizedBox(width: GameSpacing.xs),
                          Text(
                            '${l10n.opponent}: $opponentProgress/${match.gameCount}',
                            style: const TextStyle(
                              color: GameColors.muted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MatchResultView extends StatefulWidget {
  const _MatchResultView({
    required this.uid,
    required this.match,
    required this.matchBackend,
    required this.localCompletedGames,
  });

  final String uid;
  final MatchSession match;
  final MatchBackend matchBackend;
  final int localCompletedGames;

  @override
  State<_MatchResultView> createState() => _MatchResultViewState();
}

class _MatchResultViewState extends State<_MatchResultView> {
  bool _leaving = false;
  bool _rematchBusy = false;
  bool _switchingMatch = false;
  bool _finalizeStarted = false;
  String? _error;

  Future<void> _finalize() async {
    if (_finalizeStarted) return;
    _finalizeStarted = true;
    try {
      await widget.matchBackend.finalizeMatch(
        matchId: widget.match.id,
        uid: widget.uid,
      );
    } catch (_) {
      _finalizeStarted = false;
    }
  }

  Future<void> _requestRematch() async {
    if (_rematchBusy || _leaving) return;
    setState(() {
      _rematchBusy = true;
      _error = null;
    });
    try {
      await widget.matchBackend.requestRematch(
        matchId: widget.match.id,
        uid: widget.uid,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).tryAgain);
    } finally {
      if (mounted) setState(() => _rematchBusy = false);
    }
  }

  Future<void> _switchToRematch(String newMatchId) async {
    if (_switchingMatch) return;
    _switchingMatch = true;
    try {
      await widget.matchBackend.moveTicketToMatch(
        uid: widget.uid,
        matchId: newMatchId,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      _switchingMatch = false;
      if (mounted) setState(() => _error = AppLocalizations.of(context).tryAgain);
    }
  }

  Future<void> _backHome() async {
    if (_leaving || _switchingMatch) return;
    setState(() {
      _leaving = true;
      _error = null;
    });
    try {
      if (widget.match.requestedRematch(widget.uid) &&
          widget.match.rematchMatchId == null) {
        await widget.matchBackend.cancelRematchRequest(
          matchId: widget.match.id,
          uid: widget.uid,
        );
      }
      await widget.matchBackend.clearTicket(widget.uid);
    } catch (_) {
      if (mounted) {
        setState(() {
          _leaving = false;
          _error = AppLocalizations.of(context).tryAgain;
        });
      }
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final match = widget.match;
    final remoteLocal = match.progressFor(widget.uid);
    final waitingForFinalWrite = widget.localCompletedGames >= match.gameCount &&
        (remoteLocal.completedGames < match.gameCount ||
            remoteLocal.completedAt == null);

    if (waitingForFinalWrite) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: GameSpacing.md),
            Text(l10n.saving),
          ],
        ),
      );
    }

    final settled = MatchSettlement.isSettled(
      playerA: match.progressA,
      playerB: match.progressB,
      gameCount: match.gameCount,
      countdownStartedAt: match.countdownStartedAt,
      now: DateTime.now(),
    );

    if (!settled) {
      final opponent = match.opponentProgress(widget.uid);
      return Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: GameSpacing.lg),
            Text(
              l10n.waitingForOpponent,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: GameSpacing.sm),
            Text(
              l10n.historyOpponentResult(
                opponent.completedGames,
                match.gameCount,
                opponent.totalScore,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.muted),
            ),
          ],
        ),
      );
    }

    if (!_finalizeStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _finalize();
      });
    }

    final newMatchId = match.rematchMatchId;
    if (newMatchId != null && !_switchingMatch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _switchToRematch(newMatchId);
      });
    }

    if (_switchingMatch) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: GameSpacing.md),
            Text(l10n.gettingReady),
          ],
        ),
      );
    }

    final outcome = MatchOutcomeResolver.compare(
      playerA: match.progressA,
      playerB: match.progressB,
      gameCount: match.gameCount,
    );

    final iAmA = match.playerAId == widget.uid;
    final won = (outcome == MatchOutcome.playerA && iAmA) ||
        (outcome == MatchOutcome.playerB && !iAmA);
    final lost = (outcome == MatchOutcome.playerA && !iAmA) ||
        (outcome == MatchOutcome.playerB && iAmA);
    final title = won ? l10n.victory : (lost ? l10n.defeat : l10n.tie);
    final resultColor = won
        ? GameColors.success
        : lost
            ? GameColors.danger
            : GameColors.warning;
    final resultIcon = won
        ? Icons.emoji_events_rounded
        : lost
            ? Icons.trending_down_rounded
            : Icons.balance_rounded;
    final mine = match.progressFor(widget.uid);
    final opponent = match.opponentProgress(widget.uid);
    final requested = match.requestedRematch(widget.uid);
    final opponentRequested =
        match.playerAId == widget.uid ? match.rematchB : match.rematchA;

    return Padding(
      padding: const EdgeInsets.all(GameSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: resultColor.withValues(alpha: 0.10),
                border: Border.all(
                  color: resultColor.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: resultColor.withValues(alpha: 0.14),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: Icon(resultIcon, size: 54, color: resultColor),
            ),
          ),
          const SizedBox(height: GameSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: resultColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: GameSpacing.lg),
          Container(
            padding: const EdgeInsets.all(GameSpacing.md),
            decoration: BoxDecoration(
              color: GameColors.surface,
              borderRadius: BorderRadius.circular(GameRadii.panel),
              border: Border.all(color: GameColors.surfaceStrong),
            ),
            child: Column(
              children: [
                _ResultLine(
                  label: l10n.you,
                  games: mine.completedGames,
                  totalGames: match.gameCount,
                  score: mine.totalScore,
                  highlight: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: GameSpacing.sm),
                  child: Divider(height: 1),
                ),
                _ResultLine(
                  label: l10n.opponent,
                  games: opponent.completedGames,
                  totalGames: match.gameCount,
                  score: opponent.totalScore,
                ),
              ],
            ),
          ),
          const SizedBox(height: GameSpacing.md),
          if (requested || opponentRequested)
            Text(
              requested ? l10n.waitingForOpponent : l10n.opponentFound,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: GameColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: GameSpacing.sm),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.danger),
            ),
          ],
          const Spacer(),
          FilledButton.icon(
            onPressed:
                requested || _rematchBusy || _leaving ? null : _requestRematch,
            icon: const Icon(Icons.replay_rounded),
            label: Text(_rematchBusy ? l10n.gettingReady : l10n.rematch),
          ),
          const SizedBox(height: GameSpacing.sm),
          OutlinedButton.icon(
            onPressed: _leaving || _rematchBusy ? null : _backHome,
            icon: const Icon(Icons.home_rounded),
            label: Text(_leaving ? l10n.leaving : l10n.backToHome),
          ),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({
    required this.label,
    required this.games,
    required this.totalGames,
    required this.score,
    this.highlight = false,
  });

  final String label;
  final int games;
  final int totalGames;
  final int score;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: highlight ? GameColors.accent : GameColors.textStrong,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          '$games/$totalGames',
          style: const TextStyle(color: GameColors.muted),
        ),
        const SizedBox(width: GameSpacing.md),
        Text(
          '$score',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
