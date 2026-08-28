import 'dart:async';

import 'package:flutter/material.dart';

import '../../economy/data/competitive_economy_service.dart';
import '../data/competitive_match_firestore_repository.dart';
import 'competitive_matchmaking_screen.dart';
import 'competitive_ready_screen.dart';
import 'game_selection_screen.dart';

class CompetitiveMatchmakingFlow extends StatefulWidget {
  const CompetitiveMatchmakingFlow({
    super.key,
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
  State<CompetitiveMatchmakingFlow> createState() => _CompetitiveMatchmakingFlowState();
}

class _CompetitiveMatchmakingFlowState extends State<CompetitiveMatchmakingFlow> {
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
    final match = await widget.matchRepository
        .watchMatch(matchId)
        .where((event) => event != null)
        .first;
    if (!mounted || match == null) return;

    final page = CompetitiveSessionFlow(
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
      popOnCancel: !widget.embedded,
      onCancel: () async {
        await widget.economyService.leaveWager();
        widget.onFlowEnded?.call();
      },
      onMatched: (state) => unawaited(_openMatch(state)),
    );
  }
}

class CompetitiveSessionFlow extends StatefulWidget {
  const CompetitiveSessionFlow({
    super.key,
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
  State<CompetitiveSessionFlow> createState() => _CompetitiveSessionFlowState();
}

class _CompetitiveSessionFlowState extends State<CompetitiveSessionFlow> {
  bool _selectionLocked = false;
  bool _working = false;
  bool _allowPop = false;
  bool _settlementStarted = false;

  static final List<SelectableGame> _slots = List<SelectableGame>.generate(
    16,
    (index) => SelectableGame(
      id: 'game_slot_${(index + 1).toString().padLeft(2, '0')}',
      name: 'Game ${(index + 1).toString().padLeft(2, '0')}',
    ),
    growable: false,
  );

  Future<void> _finishAndPop() async {
    if (!mounted) return;
    setState(() {
      _allowPop = true;
      _working = false;
    });
    Navigator.of(context).pop();
  }

  Future<void> _settlePending() async {
    if (_settlementStarted) return;
    _settlementStarted = true;
    setState(() => _working = true);
    try {
      await widget.economyService.settleMatch(widget.matchId);
      await _finishAndPop();
    } catch (_) {
      _settlementStarted = false;
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _concedeStartedMatch() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('LEAVE MATCH?'),
            content: Text(
              'The match has started. Leaving gives the opponent the win and your ${widget.wager} GOLD stake.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('STAY'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('LEAVE MATCH'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _working = true);
    try {
      await widget.economyService.forfeitMatch(widget.matchId);
      await widget.economyService.settleMatch(widget.matchId);
      await _finishAndPop();
    } finally {
      if (mounted && !_allowPop) setState(() => _working = false);
    }
  }

  Future<void> _requestExit(CompetitiveMatchSnapshot match) async {
    if (_working || _allowPop) return;

    if (match.status == 'countdown' || match.status == 'playing') {
      final startsAt = match.startsAt;
      if (startsAt == null || DateTime.now().isBefore(startsAt)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Countdown is active. The match is about to start.')),
        );
        return;
      }
      await _concedeStartedMatch();
      return;
    }

    if (match.status != 'selectingGames' && match.status != 'waitingReady') return;
    setState(() => _working = true);
    try {
      await widget.economyService.cancelMatch(widget.matchId);
      await _finishAndPop();
    } finally {
      if (mounted && !_allowPop) setState(() => _working = false);
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
          if (_working)
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

        if (match.status == 'awaitingSettlement' && !_settlementStarted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(_settlePending());
          });
        }
        if ((match.status == 'finished' || match.status == 'cancelled') && !_allowPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) unawaited(_finishAndPop());
          });
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
