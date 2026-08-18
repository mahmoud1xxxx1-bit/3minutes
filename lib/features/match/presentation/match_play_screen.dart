import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../minigames/data/game_registry.dart';
import '../../minigames/domain/mini_game_contract.dart';
import '../../minigames/presentation/mini_game_host.dart';
import '../data/match_backend.dart';
import '../domain/match_outcome.dart';
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
      setState(() {
        _error = 'Could not save this game result. Check your connection and try again.';
      });
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

    return PopScope(
      canPop: canExit,
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<MatchSession?>(
            stream: widget.matchBackend.watchMatch(widget.matchId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Connection to the match was lost. Reopen the match when your connection returns; your saved progress will be restored.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final match = snapshot.data;
              if (match == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (match.registryVersion != GameRegistry.version) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'This match uses a different game version. Update the app before playing.',
                      textAlign: TextAlign.center,
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

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${gameIndex + 1}/${match.gameCount}  ${game.title}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          _clock(remaining),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: gameIndex / match.gameCount),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: _submitting,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: MiniGameHost(
                                key: ValueKey('$gameIndex-${game.id}'),
                                game: game,
                                config: MiniGameConfig(seed: gameSeed, difficulty: 1),
                                onComplete: (result) => _completeGame(match, result),
                              ),
                            ),
                            if (_submitting)
                              const Positioned.fill(
                                child: ColoredBox(
                                  color: Color(0x55000000),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Opponent: ${match.opponentProgress(widget.uid).completedGames}/${match.gameCount}',
                      textAlign: TextAlign.center,
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
      setState(() => _error = 'Could not request a rematch. Try again.');
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
      if (mounted) {
        setState(() => _error = 'Rematch is ready, but reconnecting failed. Try again.');
      }
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
          _error = 'Could not leave the result screen. Try again.';
        });
      }
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final remoteLocal = match.progressFor(widget.uid);
    final waitingForFinalWrite = widget.localCompletedGames >= match.gameCount &&
        (remoteLocal.completedGames < match.gameCount || remoteLocal.completedAt == null);

    if (waitingForFinalWrite) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finalizing your progress...'),
          ],
        ),
      );
    }

    final bothCompleted = match.progressA.completedGames >= match.gameCount &&
        match.progressB.completedGames >= match.gameCount;
    final start = match.countdownStartedAt?.add(const Duration(seconds: 3));
    final deadline = start?.add(AppConfig.matchDuration);
    final timerEnded = deadline != null && !DateTime.now().isBefore(deadline);
    final settled = bothCompleted || timerEnded;

    if (!settled) {
      final opponent = match.opponentProgress(widget.uid);
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'WAITING FOR OPPONENT',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              '${opponent.completedGames}/${match.gameCount} games completed',
              textAlign: TextAlign.center,
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing rematch...'),
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
    final title = won ? 'YOU WIN' : (lost ? 'YOU LOSE' : 'TIE');
    final mine = match.progressFor(widget.uid);
    final opponent = match.opponentProgress(widget.uid);
    final requested = match.requestedRematch(widget.uid);
    final opponentRequested =
        match.playerAId == widget.uid ? match.rematchB : match.rematchA;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            '${mine.completedGames}/${match.gameCount} games  •  ${mine.totalScore} pts',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Opponent: ${opponent.completedGames}/${match.gameCount}  •  ${opponent.totalScore} pts',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (requested)
            Text(
              opponentRequested
                  ? 'Both players accepted. Preparing match...'
                  : 'Waiting for opponent to accept rematch...',
              textAlign: TextAlign.center,
            )
          else if (opponentRequested)
            const Text('Opponent wants a rematch.', textAlign: TextAlign.center),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: requested || _rematchBusy || _leaving ? null : _requestRematch,
            child: Text(
              _rematchBusy
                  ? 'REQUESTING...'
                  : requested
                      ? 'REMATCH REQUESTED'
                      : 'REMATCH',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _leaving || _rematchBusy ? null : _backHome,
            child: Text(_leaving ? 'LEAVING...' : 'BACK TO HOME'),
          ),
        ],
      ),
    );
  }
}
