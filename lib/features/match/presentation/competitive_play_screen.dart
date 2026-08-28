import 'dart:async';

import 'package:flutter/material.dart';

import '../../economy/data/competitive_economy_service.dart';
import '../../economy/data/competitive_wallet_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/domain/player_profile.dart';
import '../data/competitive_match_firestore_repository.dart';
import 'competitive_matchmaking_screen.dart';
import 'competitive_ready_screen.dart';
import 'game_selection_screen.dart';
import 'wager_selection_screen.dart';

class CompetitivePlayScreen extends StatefulWidget {
  const CompetitivePlayScreen({
    super.key,
    required this.uid,
    required this.profileRepository,
    required this.walletRepository,
    required this.economyService,
    required this.matchRepository,
  });

  final String uid;
  final ProfileRepository profileRepository;
  final CompetitiveWalletRepository walletRepository;
  final CompetitiveEconomyService economyService;
  final CompetitiveMatchFirestoreRepository matchRepository;

  @override
  State<CompetitivePlayScreen> createState() => _CompetitivePlayScreenState();
}

class _CompetitivePlayScreenState extends State<CompetitivePlayScreen> {
  late Future<CompetitiveRecoveryResult> _recovery;

  @override
  void initState() {
    super.initState();
    _recovery = widget.economyService.recoverQueue();
  }

  void _refreshRecovery() {
    setState(() => _recovery = widget.economyService.recoverQueue());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerProfile?>(
      stream: widget.profileRepository.watchProfile(widget.uid),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        if (profile == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return FutureBuilder<CompetitiveRecoveryResult>(
          future: _recovery,
          builder: (context, recoverySnapshot) {
            if (recoverySnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (recoverySnapshot.hasError) {
              return _RecoveryError(onRetry: _refreshRecovery);
            }

            final recovery = recoverySnapshot.data!;
            final wager = recovery.wager;

            if (recovery.hasActiveMatch && wager != null) {
              return _SelectionAndReadyFlow(
                uid: widget.uid,
                matchId: recovery.matchId!,
                wager: wager,
                matchRepository: widget.matchRepository,
                economyService: widget.economyService,
              );
            }

            if (recovery.status == 'searching' && wager != null) {
              return _CompetitiveFlowCoordinator(
                uid: widget.uid,
                wager: wager,
                playerName: profile.gameName,
                initialMatchId: null,
                economyService: widget.economyService,
                matchRepository: widget.matchRepository,
                embedded: true,
                onFlowEnded: _refreshRecovery,
              );
            }

            return StreamBuilder(
              stream: widget.walletRepository.watchWallet(widget.uid),
              builder: (context, walletSnapshot) {
                final wallet = walletSnapshot.data;
                return WagerSelectionScreen(
                  goldBalance: wallet?.availableGold ?? 0,
                  onFindOpponent: (selectedWager) async {
                    final result = await widget.economyService.enterWager(
                      wager: selectedWager,
                      displayName: profile.gameName,
                      avatarId: profile.avatarId,
                    );
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => _CompetitiveFlowCoordinator(
                          uid: widget.uid,
                          wager: selectedWager,
                          playerName: profile.gameName,
                          initialMatchId: result.matchId,
                          economyService: widget.economyService,
                          matchRepository: widget.matchRepository,
                        ),
                      ),
                    );
                    if (mounted) _refreshRecovery();
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RecoveryError extends StatelessWidget {
  const _RecoveryError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: 12),
              const Text('Unable to restore competitive session.'),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('RETRY')),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetitiveFlowCoordinator extends StatefulWidget {
  const _CompetitiveFlowCoordinator({
    required this.uid,
    required this.wager,
    required this.playerName,
    required this.initialMatchId,
    required this.economyService,
    required this.matchRepository,
    this.embedded = false,
    this.onFlowEnded,
  });

  final String uid;
  final int wager;
  final String playerName;
  final String? initialMatchId;
  final CompetitiveEconomyService economyService;
  final CompetitiveMatchFirestoreRepository matchRepository;
  final bool embedded;
  final VoidCallback? onFlowEnded;

  @override
  State<_CompetitiveFlowCoordinator> createState() => _CompetitiveFlowCoordinatorState();
}

class _CompetitiveFlowCoordinatorState extends State<_CompetitiveFlowCoordinator> {
  bool _openingMatch = false;

  Stream<CompetitiveMatchmakingViewState> get _matchmakingStream {
    return widget.matchRepository.watchQueueTicket(widget.uid).asyncExpand((ticket) {
      final matchId = ticket?.matchId ?? widget.initialMatchId;
      if (matchId == null) {
        return Stream.value(CompetitiveMatchmakingViewState.searching(widget.wager));
      }
      return widget.matchRepository.watchMatch(matchId).map((match) {
        return CompetitiveMatchmakingViewState(
          wager: widget.wager,
          matchId: matchId,
          opponentName: match?.opponentNameFor(widget.uid) ?? 'Opponent',
        );
      });
    });
  }

  Future<void> _openMatch(CompetitiveMatchmakingViewState state) async {
    final matchId = state.matchId;
    if (matchId == null || _openingMatch) return;
    _openingMatch = true;
    final first = await widget.matchRepository
        .watchMatch(matchId)
        .where((event) => event != null)
        .first;
    if (!mounted || first == null) return;

    final page = _SelectionAndReadyFlow(
      uid: widget.uid,
      matchId: matchId,
      wager: widget.wager,
      matchRepository: widget.matchRepository,
      economyService: widget.economyService,
    );

    if (widget.embedded) {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
      if (mounted) widget.onFlowEnded?.call();
    } else {
      await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompetitiveMatchmakingScreen(
      wager: widget.wager,
      playerName: widget.playerName,
      matchStream: _matchmakingStream,
      onCancel: () async {
        await widget.economyService.leaveWager();
        widget.onFlowEnded?.call();
      },
      onMatched: (state) => unawaited(_openMatch(state)),
    );
  }
}

class _SelectionAndReadyFlow extends StatefulWidget {
  const _SelectionAndReadyFlow({
    required this.uid,
    required this.matchId,
    required this.wager,
    required this.matchRepository,
    required this.economyService,
  });

  final String uid;
  final String matchId;
  final int wager;
  final CompetitiveMatchFirestoreRepository matchRepository;
  final CompetitiveEconomyService economyService;

  @override
  State<_SelectionAndReadyFlow> createState() => _SelectionAndReadyFlowState();
}

class _SelectionAndReadyFlowState extends State<_SelectionAndReadyFlow> {
  bool _selectionLocked = false;
  bool _cancelling = false;
  bool _allowPop = false;

  static final List<SelectableGame> _slots = List<SelectableGame>.generate(
    16,
    (index) => SelectableGame(
      id: 'game_slot_${(index + 1).toString().padLeft(2, '0')}',
      name: 'Game ${(index + 1).toString().padLeft(2, '0')}',
    ),
    growable: false,
  );

  Future<void> _requestExit(CompetitiveMatchSnapshot match) async {
    if (_cancelling || _allowPop) return;
    if (match.status == 'countdown') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The match has started. Leaving now requires a forfeit.')),
      );
      return;
    }
    if (match.status != 'selectingGames' && match.status != 'waitingReady') return;

    setState(() => _cancelling = true);
    try {
      await widget.economyService.cancelMatch(widget.matchId);
      if (!mounted) return;
      setState(() {
        _allowPop = true;
        _cancelling = false;
      });
      Navigator.of(context).pop();
    } finally {
      if (mounted && !_allowPop) setState(() => _cancelling = false);
    }
  }

  Widget _guardExit(CompetitiveMatchSnapshot match, Widget child) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) unawaited(_requestExit(match));
      },
      child: Stack(
        children: [
          child,
          if (_cancelling)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompetitiveMatchSnapshot?>(
      stream: widget.matchRepository.watchMatch(widget.matchId),
      builder: (context, snapshot) {
        final match = snapshot.data;
        if (match == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final myPicks = match.myPicks(widget.uid);
        if (!_selectionLocked && myPicks.length == 2) {
          _selectionLocked = true;
        }

        if (!_selectionLocked) {
          return _guardExit(
            match,
            GameSelectionScreen(
              games: _slots,
              opponentGameIds: match.opponentPicks(widget.uid).toSet(),
              onConfirm: (gameIds) async {
                await widget.economyService.selectGames(
                  matchId: widget.matchId,
                  gameIds: gameIds,
                );
                if (mounted) setState(() => _selectionLocked = true);
              },
            ),
          );
        }

        final readyStream = widget.matchRepository
            .watchMatch(widget.matchId)
            .where((value) => value != null)
            .map((value) {
          final live = value!;
          return CompetitiveReadyViewState(
            status: live.status,
            meReady: live.myReady(widget.uid),
            opponentReady: live.opponentReady(widget.uid),
            startsAt: live.startsAt,
            deadline: live.deadline,
          );
        });

        return _guardExit(
          match,
          CompetitiveReadyScreen(
            matchId: widget.matchId,
            playerName: match.isPlayerA(widget.uid) ? match.playerAName : match.playerBName,
            opponentName: match.opponentNameFor(widget.uid),
            wager: widget.wager,
            stateStream: readyStream,
            onReady: () async {
              await widget.economyService.markReady(widget.matchId);
            },
            onStart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Match host ready for game integration.')),
              );
            },
          ),
        );
      },
    );
  }
}
