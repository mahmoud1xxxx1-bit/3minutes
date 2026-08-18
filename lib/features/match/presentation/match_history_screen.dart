import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/match_backend.dart';
import '../domain/match_outcome.dart';
import '../domain/match_session.dart';

class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({
    super.key,
    required this.uid,
    required this.matchBackend,
  });

  final String uid;
  final MatchBackend matchBackend;

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  late Future<List<MatchSession>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.matchBackend.loadHistory(widget.uid);
  }

  void _reload() {
    setState(() => _future = widget.matchBackend.loadHistory(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.matchHistory),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<MatchSession>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(GameSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded,
                          size: 48, color: GameColors.muted),
                      const SizedBox(height: GameSpacing.md),
                      Text(l10n.couldNotLoadHistory,
                          textAlign: TextAlign.center),
                      const SizedBox(height: GameSpacing.md),
                      FilledButton(
                        onPressed: _reload,
                        child: Text(l10n.tryAgain),
                      ),
                    ],
                  ),
                ),
              );
            }

            final items = (snapshot.data ?? const <MatchSession>[])
                .where(
                  (match) =>
                      match.status == MatchStatus.finished ||
                      match.status == MatchStatus.cancelled,
                )
                .toList(growable: false);
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded,
                        size: 52, color: GameColors.muted),
                    const SizedBox(height: GameSpacing.md),
                    Text(l10n.noFinishedMatches,
                        style: const TextStyle(color: GameColors.muted)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(GameSpacing.md),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: GameSpacing.sm),
              itemBuilder: (context, index) {
                final match = items[index];
                final mine = match.progressFor(widget.uid);
                final opponent = match.opponentProgress(widget.uid);
                final cancelled = match.status == MatchStatus.cancelled;
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

                final label = cancelled
                    ? l10n.cancelled
                    : won
                        ? l10n.win
                        : lost
                            ? l10n.loss
                            : l10n.tie;
                final color = cancelled
                    ? GameColors.muted
                    : won
                        ? GameColors.success
                        : lost
                            ? GameColors.danger
                            : GameColors.warning;
                final icon = cancelled
                    ? Icons.close_rounded
                    : won
                        ? Icons.emoji_events_rounded
                        : lost
                            ? Icons.trending_down_rounded
                            : Icons.balance_rounded;

                return Container(
                  padding: const EdgeInsets.all(GameSpacing.md),
                  decoration: BoxDecoration(
                    color: GameColors.surface,
                    borderRadius: BorderRadius.circular(GameRadii.card),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.12),
                        ),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: GameSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.opponentName(widget.uid),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.historyMyResult(
                                mine.completedGames,
                                match.gameCount,
                                mine.totalScore,
                              ),
                              style: const TextStyle(color: GameColors.muted),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.historyOpponentResult(
                                opponent.completedGames,
                                match.gameCount,
                                opponent.totalScore,
                              ),
                              style: const TextStyle(
                                color: GameColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: GameSpacing.sm),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
