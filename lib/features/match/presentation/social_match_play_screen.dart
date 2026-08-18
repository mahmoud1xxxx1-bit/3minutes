import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/mini_game_evidence.dart';
import '../../minigames/data/game_registry.dart';
import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/presentation/mini_game_copy.dart';
import '../../minigames/presentation/mini_game_host.dart';
import '../data/social_match_backend.dart';
import '../domain/match_runtime.dart';
import '../domain/multiplayer_match.dart';
import '../domain/multiplayer_result.dart';

class SocialMatchPlayScreen extends StatefulWidget {
  const SocialMatchPlayScreen({
    super.key,
    required this.matchId,
    required this.uid,
    required this.matchBackend,
  });

  final String matchId;
  final String uid;
  final SocialMatchBackend matchBackend;

  @override
  State<SocialMatchPlayScreen> createState() => _SocialMatchPlayScreenState();
}

class _SocialMatchPlayScreenState extends State<SocialMatchPlayScreen> {
  Timer? _ticker;
  MatchRuntime? _runtime;
  bool _submitting = false;
  bool _settlementRequested = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() {});
    });
    unawaited(
      widget.matchBackend.setConnectionState(
        matchId: widget.matchId,
        uid: widget.uid,
        state: ParticipantConnectionState.connected,
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(
      widget.matchBackend.setConnectionState(
        matchId: widget.matchId,
        uid: widget.uid,
        state: ParticipantConnectionState.disconnected,
      ),
    );
    super.dispose();
  }

  MatchParticipant? _me(MultiplayerMatch match) {
    for (final participant in match.participants) {
      if (participant.uid == widget.uid) return participant;
    }
    return null;
  }

  MatchRuntime? _ensureRuntime(MultiplayerMatch match) {
    final startedAt = match.countdownStartedAt;
    final me = _me(match);
    if (startedAt == null || me == null) return null;

    final current = _runtime;
    final saved = me.progress;
    final serverAhead = current != null &&
        (saved.completedGames > current.progress.completedGames ||
            saved.totalScore > current.progress.totalScore ||
            saved.elapsedMs > current.progress.elapsedMs);

    if (current == null || serverAhead) {
      _runtime = MatchRuntime(
        seed: match.seed,
        startedAt: startedAt.add(const Duration(seconds: 3)),
        gameCount: AppConfig.gamesPerMatch,
        initialProgress: saved,
      );
    }
    return _runtime;
  }

  Future<void> _completeGame(
    MultiplayerMatch match,
    MiniGameResult result,
  ) async {
    final runtime = _runtime;
    if (runtime == null || _submitting || runtime.isExpired(DateTime.now())) {
      return;
    }
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
      _submitting = true;
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
      if (mounted) setState(() => _error = AppLocalizations.of(context).tryAgain);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _requestSettlement(MultiplayerMatch match) {
    if (_settlementRequested) return;
    _settlementRequested = true;
    unawaited(widget.matchBackend.settleMatch(match.id));
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
            child: StreamBuilder<MultiplayerMatch?>(
              stream: widget.matchBackend.watchMatch(widget.matchId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _MessageCard(text: l10n.connectionLostRoom);
                }
                final match = snapshot.data;
                if (match == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (match.registryVersion != GameRegistry.version) {
                  return _MessageCard(
                    text: l10n.legacyMatchTitle,
                    color: GameColors.warning,
                  );
                }

                final runtime = _ensureRuntime(match);
                if (runtime == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final now = DateTime.now();
                final remaining = runtime.remaining(now);
                final expired = runtime.isExpired(now);
                final everyoneFinished = match.participants.every(
                  (participant) =>
                      participant.progress.completedGames >=
                      AppConfig.gamesPerMatch,
                );

                if (expired || everyoneFinished) {
                  _requestSettlement(match);
                  return _SocialResultView(uid: widget.uid, match: match);
                }

                if (runtime.allGamesCompleted) {
                  return _WaitingForPlayersView(
                    match: match,
                    remaining: remaining,
                  );
                }

                final game = runtime.currentGame!;
                final gameIndex = runtime.progress.completedGames;
                final gameSeed =
                    runtime.seed ^ ((gameIndex + 1) * 0x45d9f3b);
                return Padding(
                  padding: const EdgeInsets.all(GameSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SocialMatchHud(
                        match: match,
                        uid: widget.uid,
                        gameIndex: gameIndex,
                        remainingLabel: _clock(remaining),
                        danger: remaining.inSeconds <= 20,
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
                                    padding:
                                        const EdgeInsets.all(GameSpacing.md),
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
                      Text(
                        MiniGameCopy.fromContext(context).title(game.id),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GameColors.muted,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
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

class _SocialMatchHud extends StatelessWidget {
  const _SocialMatchHud({
    required this.match,
    required this.uid,
    required this.gameIndex,
    required this.remainingLabel,
    required this.danger,
  });

  final MultiplayerMatch match;
  final String uid;
  final int gameIndex;
  final String remainingLabel;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: GameColors.accentSoft,
                  borderRadius: BorderRadius.circular(GameRadii.pill),
                ),
                child: Text(
                  '${gameIndex + 1}/${AppConfig.gamesPerMatch}',
                  style: const TextStyle(
                    color: GameColors.accentBright,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: danger
                      ? GameColors.danger.withValues(alpha: .10)
                      : GameColors.surfaceRaised,
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
              for (final participant in match.participants)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _MiniProgress(
                      participant: participant,
                      isSelf: participant.uid == uid,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.participant, required this.isSelf});

  final MatchParticipant participant;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final value =
        participant.progress.completedGames / AppConfig.gamesPerMatch;
    final initial = participant.displayName.trim().isEmpty
        ? '?'
        : participant.displayName.trim().characters.first;
    return Column(
      children: [
        Text(
          isSelf ? '●' : initial,
          maxLines: 1,
          style: TextStyle(
            color: isSelf ? GameColors.accentBright : GameColors.muted,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(GameRadii.pill),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 5,
            backgroundColor: GameColors.surfaceRaised,
          ),
        ),
      ],
    );
  }
}

class _WaitingForPlayersView extends StatelessWidget {
  const _WaitingForPlayersView({required this.match, required this.remaining});

  final MultiplayerMatch match;
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
              const Icon(
                Icons.hourglass_top_rounded,
                size: 64,
                color: GameColors.accentBright,
              ),
              const SizedBox(height: GameSpacing.md),
              Text(
                l10n.waitingForOpponent,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GameSpacing.lg),
              for (final participant in match.participants)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(participant.displayName)),
                      Text(
                        '${participant.progress.completedGames}/${AppConfig.gamesPerMatch}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: GameSpacing.md),
              Text(
                '${remaining.inSeconds}s',
                style: const TextStyle(color: GameColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialResultView extends StatelessWidget {
  const _SocialResultView({required this.uid, required this.match});

  final String uid;
  final MultiplayerMatch match;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placements = MultiplayerResultPolicy.rank(match.participants);
    final byUid = {
      for (final participant in match.participants) participant.uid: participant,
    };
    final myPlacement = placements.firstWhere((item) => item.uid == uid);
    final first = myPlacement.position == 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        GameSpacing.lg,
        GameSpacing.xl,
        GameSpacing.lg,
        GameSpacing.xl,
      ),
      children: [
        Center(
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: first ? GameColors.cosmicGradient : null,
              color: first ? null : GameColors.accentSoft,
              boxShadow: first ? GameShadows.primaryGlow : null,
            ),
            child: Icon(
              first ? Icons.emoji_events_rounded : Icons.leaderboard_rounded,
              size: 58,
              color: first ? Colors.white : GameColors.accentBright,
            ),
          ),
        ),
        const SizedBox(height: GameSpacing.sm),
        Text(
          first ? l10n.victory : '#${myPlacement.position}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: first ? GameColors.rewardGold : GameColors.textStrong,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: GameSpacing.lg),
        for (var index = 0; index < placements.length; index++) ...[
          Builder(
            builder: (context) {
              final placement = placements[index];
              final participant = byUid[placement.uid]!;
              final isSelf = participant.uid == uid;
              return CosmicPanel(
                glow: isSelf,
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        '#${placement.position}',
                        style: TextStyle(
                          color: placement.position == 1
                              ? GameColors.rewardGold
                              : GameColors.textStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        participant.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${participant.progress.completedGames}/${AppConfig.gamesPerMatch} • ${participant.progress.totalScore}',
                      style: const TextStyle(
                        color: GameColors.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: GameSpacing.sm),
        ],
        const SizedBox(height: GameSpacing.md),
        Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'مباريات الأصدقاء لا تمنح RP.'
              : 'Friend matches do not award RP.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: GameColors.rewardGold,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: GameSpacing.lg),
        CosmicPrimaryButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_rounded),
              const SizedBox(width: GameSpacing.sm),
              Text(l10n.home),
            ],
          ),
        ),
      ],
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
        child: CosmicPanel(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          ),
        ),
      ),
    );
  }
}
