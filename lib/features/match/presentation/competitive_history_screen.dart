import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../economy/presentation/avatar_artwork.dart';
import '../data/competitive_history_repository.dart';

class CompetitiveHistoryScreen extends StatefulWidget {
  const CompetitiveHistoryScreen({super.key, required this.repository});

  final CompetitiveHistoryRepository repository;

  @override
  State<CompetitiveHistoryScreen> createState() => _CompetitiveHistoryScreenState();
}

class _CompetitiveHistoryScreenState extends State<CompetitiveHistoryScreen> {
  late Future<List<CompetitiveHistoryEntry>> _history;

  @override
  void initState() {
    super.initState();
    _history = widget.repository.load(limit: 50);
  }

  void _reload() {
    setState(() => _history = widget.repository.load(limit: 50));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.matchHistory),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.arenaGradient),
        child: FutureBuilder<List<CompetitiveHistoryEntry>>(
          future: _history,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: FilledButton.icon(
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              );
            }
            final entries = snapshot.data ?? const <CompetitiveHistoryEntry>[];
            if (entries.isEmpty) {
              return Center(child: Text(l10n.noFinishedMatches));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              itemCount: entries.length,
              itemBuilder: (context, index) => _HistoryCard(entry: entries[index]),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});
  final CompetitiveHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resultColor = switch (entry.result) {
      'win' => GameColors.success,
      'loss' => GameColors.danger,
      _ => GameColors.warning,
    };
    final resultLabel = switch (entry.result) {
      'win' => l10n.win,
      'loss' => l10n.loss,
      _ => l10n.tie,
    };
    final time = entry.completedAt;
    final dateLabel = time == null
        ? '—'
        : '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameColors.surfaceGlass,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: GameColors.surfaceStrong),
        boxShadow: GameShadows.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              AvatarArtwork(
                avatarId: entry.opponentAvatarId,
                size: 46,
                borderRadius: 23,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.opponentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Text(dateLabel, style: const TextStyle(color: GameColors.textSoft, fontSize: 12)),
                  ],
                ),
              ),
              Text(resultLabel, style: TextStyle(color: resultColor, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: GameColors.surfaceRaised,
              borderRadius: BorderRadius.circular(GameRadii.card),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${entry.myTotalScore}', style: const TextStyle(color: GameColors.success, fontSize: 20, fontWeight: FontWeight.w900)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(l10n.vs, style: const TextStyle(color: GameColors.textSoft)),
                ),
                Text('${entry.opponentTotalScore}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          if (entry.games.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final game in entry.games)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        game.gameId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: GameColors.textSoft, fontSize: 12),
                      ),
                    ),
                    Text('${game.myScore}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(l10n.vs, style: const TextStyle(color: GameColors.textSoft, fontSize: 11)),
                    ),
                    Text('${game.opponentScore}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Value(label: 'GOLD', value: '${entry.wager}', color: GameColors.rewardGoldBright),
              _Value(label: 'GOLD Δ', value: _delta(entry.goldDelta), color: GameColors.rewardGoldBright),
              _Value(label: l10n.coins.toUpperCase(), value: _delta(entry.coinsDelta), color: GameColors.coin),
              _Value(label: 'RP', value: _delta(entry.rpDelta), color: GameColors.rp),
            ],
          ),
        ],
      ),
    );
  }

  static String _delta(int value) => '${value >= 0 ? '+' : ''}$value';
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: GameColors.textSoft, fontSize: 10, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      );
}
