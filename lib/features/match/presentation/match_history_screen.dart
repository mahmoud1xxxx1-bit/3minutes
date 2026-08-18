import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match history'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load match history.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _reload,
                        child: const Text('TRY AGAIN'),
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
              return const Center(child: Text('No finished matches yet.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
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
                final result = cancelled
                    ? 'CANCELLED'
                    : won
                        ? 'WIN'
                        : lost
                            ? 'LOSS'
                            : 'TIE';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        cancelled
                            ? Icons.close
                            : won
                                ? Icons.emoji_events_outlined
                                : lost
                                    ? Icons.remove
                                    : Icons.balance,
                      ),
                    ),
                    title: Text(match.opponentName(widget.uid)),
                    subtitle: Text(
                      '${mine.completedGames}/${match.gameCount} games • ${mine.totalScore} pts\n'
                      'Opponent ${opponent.completedGames}/${match.gameCount} • ${opponent.totalScore} pts',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      result,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
