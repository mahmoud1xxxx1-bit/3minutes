import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';

class CompetitiveMatchmakingScreen extends StatefulWidget {
  const CompetitiveMatchmakingScreen({
    super.key,
    required this.wager,
    required this.playerName,
    required this.onCancel,
    required this.matchStream,
    required this.onMatched,
    this.popOnCancel = true,
  });

  final int wager;
  final String playerName;
  final Future<void> Function() onCancel;
  final Stream<CompetitiveMatchmakingViewState> matchStream;
  final ValueChanged<CompetitiveMatchmakingViewState> onMatched;
  final bool popOnCancel;

  @override
  State<CompetitiveMatchmakingScreen> createState() => _CompetitiveMatchmakingScreenState();
}

class _CompetitiveMatchmakingScreenState extends State<CompetitiveMatchmakingScreen> {
  StreamSubscription<CompetitiveMatchmakingViewState>? _subscription;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _subscription = widget.matchStream.listen((state) {
      if (state.matchId != null && mounted) widget.onMatched(state);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: SafeArea(
          child: StreamBuilder<CompetitiveMatchmakingViewState>(
            stream: widget.matchStream,
            initialData: CompetitiveMatchmakingViewState.searching(widget.wager),
            builder: (context, snapshot) {
              final state = snapshot.data ?? CompetitiveMatchmakingViewState.searching(widget.wager);
              final matched = state.matchId != null;
              final opponentName = state.opponentName.trim().isEmpty ? l10n.opponent : state.opponentName;
              return Padding(
                padding: const EdgeInsets.all(GameSpacing.lg),
                child: Column(
                  children: [
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: GameDurations.reveal,
                      child: Text(
                        matched ? l10n.opponentFound.toUpperCase() : l10n.findingOpponent.toUpperCase(),
                        key: ValueKey(matched),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: GameColors.goldGradient,
                        borderRadius: BorderRadius.circular(GameRadii.pill),
                        boxShadow: GameShadows.goldGlow,
                      ),
                      child: Text(
                        l10n.goldPot(widget.wager * 2),
                        style: const TextStyle(
                          color: GameColors.backgroundDeep,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    Row(
                      children: [
                        Expanded(child: _PlayerCard(name: widget.playerName, label: l10n.you.toUpperCase())),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l10n.vs, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                        ),
                        Expanded(
                          child: _PlayerCard(
                            name: matched ? opponentName : l10n.searching,
                            label: matched ? l10n.ready.toUpperCase() : l10n.online,
                            searching: !matched,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!matched)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          onPressed: _cancelling
                              ? null
                              : () async {
                                  setState(() => _cancelling = true);
                                  try {
                                    await widget.onCancel();
                                    if (!context.mounted || !widget.popOnCancel) return;
                                    Navigator.of(context).pop();
                                  } finally {
                                    if (mounted) setState(() => _cancelling = false);
                                  }
                                },
                          child: Text(_cancelling ? l10n.cancelling : l10n.cancelSearch),
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

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.name, required this.label, this.searching = false});

  final String name;
  final String label;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: GameDurations.normal,
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.surfaceGlass,
        borderRadius: BorderRadius.circular(GameRadii.panel),
        border: Border.all(color: searching ? GameColors.violet : GameColors.accentBright),
        boxShadow: searching ? GameShadows.card : GameShadows.primaryGlow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (searching)
            const SizedBox(width: 44, height: 44, child: CircularProgressIndicator())
          else
            const Icon(Icons.person_rounded, size: 54, color: GameColors.accentBright),
          const SizedBox(height: 14),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.textSoft, fontSize: 12)),
        ],
      ),
    );
  }
}

class CompetitiveMatchmakingViewState {
  const CompetitiveMatchmakingViewState({
    required this.wager,
    required this.matchId,
    required this.opponentName,
  });

  factory CompetitiveMatchmakingViewState.searching(int wager) =>
      CompetitiveMatchmakingViewState(wager: wager, matchId: null, opponentName: '');

  final int wager;
  final String? matchId;
  final String opponentName;
}
