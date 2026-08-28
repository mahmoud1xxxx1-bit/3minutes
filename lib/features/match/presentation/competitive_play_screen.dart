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

class CompetitivePlayScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerProfile?>(
      stream: profileRepository.watchProfile(uid),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        return StreamBuilder(
          stream: walletRepository.watchWallet(uid),
          builder: (context, walletSnapshot) {
            final wallet = walletSnapshot.data;
            return WagerSelectionScreen(
              goldBalance: wallet?.availableGold ?? 0,
              onFindOpponent: (wager) async {
                if (profile == null) return;
                final result = await economyService.enterWager(
                  wager: wager,
                  displayName: profile.gameName,
                  avatarId: profile.avatarId,
                );
                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _CompetitiveFlowCoordinator(
                      uid: uid,
                      wager: wager,
                      playerName: profile.gameName,
                      initialMatchId: result.matchId,
                      economyService: economyService,
                      matchRepository: matchRepository,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
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
  });

  final String uid;
  final int wager;
  final String playerName;
  final String? initialMatchId;
  final CompetitiveEconomyService economyService;
  final CompetitiveMatchFirestoreRepository matchRepository;

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
    final first = await widget.matchRepository.watchMatch(matchId).where((event) => event != null).first;
    if (!mounted || first == null) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _SelectionAndReadyFlow(
          uid: widget.uid,
          matchId: matchId,
          wager: widget.wager,
          matchRepository: widget.matchRepository,
          economyService: widget.economyService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompetitiveMatchmakingScreen(
      wager: widget.wager,
      playerName: widget.playerName,
      matchStream: _matchmakingStream,
      onCancel: widget.economyService.leaveWager,
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

  static final List<SelectableGame> _slots = List<SelectableGame>.generate(
    16,
    (index) => SelectableGame(
      id: 'game_slot_${(index + 1).toString().padLeft(2, '0')}',
      name: 'Game ${(index + 1).toString().padLeft(2, '0')}',
    ),
    growable: false,
  );

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
          return GameSelectionScreen(
            games: _slots,
            opponentGameIds: match.opponentPicks(widget.uid).toSet(),
            onConfirm: (gameIds) async {
              await widget.economyService.selectGames(
                matchId: widget.matchId,
                gameIds: gameIds,
              );
              if (mounted) setState(() => _selectionLocked = true);
            },
          );
        }

        final readyStream = widget.matchRepository.watchMatch(widget.matchId).where((value) => value != null).map((value) {
          final live = value!;
          return CompetitiveReadyViewState(
            status: live.status,
            meReady: live.myReady(widget.uid),
            opponentReady: live.opponentReady(widget.uid),
            startsAt: live.startsAt,
            deadline: live.deadline,
          );
        });

        return CompetitiveReadyScreen(
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
        );
      },
    );
  }
}
