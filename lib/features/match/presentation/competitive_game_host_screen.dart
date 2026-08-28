import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../economy/data/competitive_economy_service.dart';
import '../application/competitive_game_host.dart';
import 'competitive_result_screen.dart';

class CompetitiveGameHostScreen extends StatefulWidget {
  const CompetitiveGameHostScreen({
    super.key,
    required this.host,
    required this.isPlayerA,
    this.onDone,
  });

  final CompetitiveGameHost host;
  final bool isPlayerA;
  final VoidCallback? onDone;

  @override
  State<CompetitiveGameHostScreen> createState() => _CompetitiveGameHostScreenState();
}

class _CompetitiveGameHostScreenState extends State<CompetitiveGameHostScreen> {
  CompetitiveHostProgress? _progress;
  CompetitiveHostResult? _result;
  Object? _error;
  bool _started = false;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = _readRemaining();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() => _remaining = _readRemaining());
    });
    unawaited(_run());
  }

  Duration _readRemaining() {
    final value = widget.host.deadline.difference(DateTime.now());
    return value.isNegative ? Duration.zero : value;
  }

  Future<void> _run() async {
    if (_started) return;
    _started = true;
    try {
      for (final gameId in widget.host.gameOrder) {
        if (!widget.host.registry.supports(gameId)) {
          throw StateError('Game integration is not installed yet: $gameId');
        }
      }
      final result = await widget.host.run(
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  CompetitiveSettlementPlayer _mySettlement(CompetitiveSettlementResult settlement) =>
      widget.isPlayerA ? settlement.playerA : settlement.playerB;

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      final finalized = result.finalized;
      final settlement = result.settlement;
      final mine = _mySettlement(settlement);
      final myOutcome = finalized.outcome == 'tie'
          ? CompetitiveResultOutcome.draw
          : (widget.isPlayerA ? finalized.outcome == 'playerA' : finalized.outcome == 'playerB')
              ? CompetitiveResultOutcome.victory
              : CompetitiveResultOutcome.defeat;
      final games = finalized.games.map((game) {
        return GameResultLine(
          name: game.gameId,
          myScore: widget.isPlayerA ? game.playerAScore : game.playerBScore,
          opponentScore: widget.isPlayerA ? game.playerBScore : game.playerAScore,
        );
      }).toList(growable: false);
      return CompetitiveResultScreen(
        outcome: myOutcome,
        games: games,
        goldDelta: mine.goldDelta,
        coinsDelta: mine.coinsDelta,
        rpDelta: mine.rpDelta,
        onContinue: widget.onDone ?? () => Navigator.of(context).pop(),
      );
    }

    final seconds = (_remaining.inMilliseconds / 1000).ceil();
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(GameSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _progress == null ? 'GAME HOST' : 'GAME ${_progress!.gameIndex + 1}/4',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                    Text(
                      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: GameColors.rewardGoldBright,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_error != null) ...[
                  const Icon(Icons.extension_off_rounded, size: 64, color: GameColors.textSoft),
                  const SizedBox(height: 16),
                  const Text(
                    'GAME INTEGRATION REQUIRED',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The competitive platform is ready. This selected game has not been connected to the Game Contract yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: GameColors.textSoft),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _progress?.gameId ?? 'Preparing match…',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
