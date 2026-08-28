import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';

class CompetitiveReadyScreen extends StatefulWidget {
  const CompetitiveReadyScreen({
    super.key,
    required this.matchId,
    required this.playerName,
    required this.opponentName,
    required this.wager,
    required this.stateStream,
    required this.onReady,
    required this.onStart,
  });

  final String matchId;
  final String playerName;
  final String opponentName;
  final int wager;
  final Stream<CompetitiveReadyViewState> stateStream;
  final Future<void> Function() onReady;
  final VoidCallback onStart;

  @override
  State<CompetitiveReadyScreen> createState() => _CompetitiveReadyScreenState();
}

class _CompetitiveReadyScreenState extends State<CompetitiveReadyScreen> {
  bool _busy = false;
  bool _sentReady = false;
  bool _started = false;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int? _countdownSeconds(DateTime? startsAt) {
    final milliseconds = startsAt?.difference(_now).inMilliseconds;
    if (milliseconds == null) return null;
    if (milliseconds <= 0) return 0;
    return (milliseconds / 1000).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: SafeArea(
          child: StreamBuilder<CompetitiveReadyViewState>(
            stream: widget.stateStream,
            builder: (context, snapshot) {
              final state = snapshot.data ?? const CompetitiveReadyViewState();
              final seconds = _countdownSeconds(state.startsAt);

              if (state.status == 'countdown' && seconds == 0 && !_started) {
                _started = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) widget.onStart();
                });
              }

              return Padding(
                padding: const EdgeInsets.all(GameSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      '${widget.wager * 2} GOLD POT',
                      style: const TextStyle(
                        color: GameColors.rewardGoldBright,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    if (seconds != null)
                      Text(
                        seconds == 0 ? 'GO!' : '$seconds',
                        style: const TextStyle(
                          fontSize: 92,
                          fontWeight: FontWeight.w900,
                          color: GameColors.accentBright,
                        ),
                      )
                    else ...[
                      const Text(
                        'MATCH LOBBY',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 28),
                      _ReadyPlayer(name: widget.playerName, ready: state.meReady || _sentReady),
                      const SizedBox(height: 12),
                      _ReadyPlayer(name: widget.opponentName, ready: state.opponentReady),
                    ],
                    const Spacer(),
                    if (seconds == null)
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: FilledButton(
                          onPressed: _busy || _sentReady
                              ? null
                              : () async {
                                  setState(() => _busy = true);
                                  try {
                                    await widget.onReady();
                                    if (mounted) setState(() => _sentReady = true);
                                  } finally {
                                    if (mounted) setState(() => _busy = false);
                                  }
                                },
                          child: Text(
                            _sentReady ? 'READY ✓' : _busy ? 'SETTING READY…' : 'READY',
                          ),
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

class _ReadyPlayer extends StatelessWidget {
  const _ReadyPlayer({required this.name, required this.ready});
  final String name;
  final bool ready;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: GameColors.surfaceGlass,
          borderRadius: BorderRadius.circular(GameRadii.card),
          border: Border.all(color: ready ? GameColors.success : GameColors.surfaceStrong),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            Text(
              ready ? 'READY' : 'WAITING',
              style: TextStyle(
                color: ready ? GameColors.success : GameColors.textSoft,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
}

class CompetitiveReadyViewState {
  const CompetitiveReadyViewState({
    this.status = 'waitingReady',
    this.meReady = false,
    this.opponentReady = false,
    this.startsAt,
    this.deadline,
  });

  final String status;
  final bool meReady;
  final bool opponentReady;
  final DateTime? startsAt;
  final DateTime? deadline;
}
