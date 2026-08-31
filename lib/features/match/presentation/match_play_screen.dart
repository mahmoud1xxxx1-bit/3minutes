import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../minigames/data/game_registry.dart';
import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/presentation/mini_game_host.dart';
import '../data/match_backend.dart';
import '../domain/match_runtime.dart';
import '../domain/match_session.dart';
import 'arena_match_result_view.dart';

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
    if (match.isRanked && !match.gameSelectionLocked) return null;

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
        lockedGameIds: match.isRanked ? match.lockedGameIds : null,
        initialProgress: savedProgress,
      );
    }
    return _runtime;
  }

  Future<void> _completeGame(MatchSession match, MiniGameResult result) async {
    final runtime = _runtime;
    if (runtime == null || _submitting || runtime.isExpired(DateTime.now())) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      if (match.isRanked) {
        final backend = widget.matchBackend;
        if (backend is! DetailedGameResultBackend) {
          throw StateError(
            'Ranked matches require the detailed mini-game result backend.',
          );
        }
        await (backend as DetailedGameResultBackend).submitMiniGameResult(
          matchId: match.id,
          uid: widget.uid,
          result: result,
          gameCount: match.gameCount,
        );
      } else {
        final nextProgress = runtime.previewResult(result);
        await widget.matchBackend.submitProgress(
          matchId: match.id,
          uid: widget.uid,
          progress: nextProgress,
          gameCount: match.gameCount,
        );
      }
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
        backgroundColor: GameColors.background,
        body: CosmicBackground(
          showOrbs: false,
          child: SafeArea(
            child: StreamBuilder<MatchSession?>(
              stream: widget.matchBackend.watchMatch(widget.matchId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _CenteredMessage(
                    text: l10n.connectionLostRoom,
                    color: GameColors.muted,
                  );
                }

                final match = snapshot.data;
                if (match == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (match.registryVersion != GameRegistry.version) {
                  return _CenteredMessage(
                    text: l10n.legacyMatchTitle,
                    color: GameColors.warning,
                  );
                }
                if (match.isRanked && !match.gameSelectionLocked) {
                  return const _CenteredMessage(
                    text: 'The four-game set is not locked yet.',
                    color: GameColors.warning,
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
                  return ArenaMatchResultView(
                    uid: widget.uid,
                    match: match,
                    matchBackend: widget.matchBackend,
                    localCompletedGames: activeRuntime.progress.completedGames,
                  );
                }

                final game = activeRuntime.currentGame!;
                final gameIndex = activeRuntime.progress.completedGames;
                final gameSeed =
                    activeRuntime.seed ^ ((gameIndex + 1) * 0x45d9f3b);
                final opponentProgress =
                    match.opponentProgress(widget.uid).completedGames;

                return Padding(
                  padding: const EdgeInsets.all(GameSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RankedHud(
                        gameIndex: gameIndex,
                        gameCount: match.gameCount,
                        gameTitle: game.title.isEmpty
                            ? game.id.replaceAll('_', ' ')
                            : game.title,
                        remaining: remaining,
                        clock: _clock(remaining),
                      ),
                      const SizedBox(height: GameSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(GameRadii.pill),
                        child: LinearProgressIndicator(
                          value: gameIndex / match.gameCount,
                          minHeight: 5,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: GameSpacing.xs),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: GameColors.danger),
                        ),
                      ],
                      const SizedBox(height: GameSpacing.xs),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: GameColors.surface,
                            borderRadius: BorderRadius.circular(GameRadii.panel),
                            border: Border.all(
                              color: GameColors.surfaceStrong,
                              width: .8,
                            ),
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
                      const SizedBox(height: GameSpacing.xs),
                      _OpponentStrip(
                        label: l10n.opponent,
                        progress: opponentProgress,
                        gameCount: match.gameCount,
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
    required this.gameCount,
    required this.gameTitle,
    required this.remaining,
    required this.clock,
  });

  final int gameIndex;
  final int gameCount;
  final String gameTitle;
  final Duration remaining;
  final String clock;

  @override
  Widget build(BuildContext context) {
    final danger = remaining.inSeconds <= 20;
    return CosmicPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: GameSpacing.sm,
        vertical: GameSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: GameColors.accentSoft,
              borderRadius: BorderRadius.circular(GameRadii.pill),
            ),
            child: Text(
              '${gameIndex + 1}/$gameCount',
              style: const TextStyle(
                color: GameColors.accentBright,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Text(
              gameTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: danger
                  ? GameColors.danger.withValues(alpha: .10)
                  : GameColors.surfaceRaised,
              borderRadius: BorderRadius.circular(GameRadii.pill),
              border: danger
                  ? Border.all(
                      color: GameColors.danger.withValues(alpha: .25),
                    )
                  : null,
            ),
            child: Text(
              clock,
              style: TextStyle(
                color: danger ? GameColors.danger : GameColors.textStrong,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpponentStrip extends StatelessWidget {
  const _OpponentStrip({
    required this.label,
    required this.progress,
    required this.gameCount,
  });

  final String label;
  final int progress;
  final int gameCount;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: GameSpacing.md,
        vertical: GameSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sports_esports_rounded,
            size: 17,
            color: GameColors.warning,
          ),
          const SizedBox(width: GameSpacing.xs),
          Text(
            '$label: $progress/$gameCount',
            style: const TextStyle(
              color: GameColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GameSpacing.lg),
        child: CosmicPanel(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, height: 1.5),
          ),
        ),
      ),
    );
  }
}
