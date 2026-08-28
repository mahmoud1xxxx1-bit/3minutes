import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
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
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: GameColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(ar ? 'سجل المباريات' : 'MATCH HISTORY'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
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
                  label: Text(ar ? 'إعادة المحاولة' : 'RETRY'),
                ),
              );
            }
            final entries = snapshot.data ?? const <CompetitiveHistoryEntry>[];
            if (entries.isEmpty) {
              return Center(child: Text(ar ? 'لا توجد مباريات بعد' : 'No matches yet'));
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
    final resultColor = switch (entry.result) {
      'win' => GameColors.success,
      'loss' => GameColors.danger,
      _ => GameColors.warning,
    };
    final resultLabel = entry.result.toUpperCase();
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
                    Text(entry.opponentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text(dateLabel,
                        style: const TextStyle(color: GameColors.textSoft, fontSize: 12)),
                  ],
                ),
              ),
              Text(resultLabel,
                  style: TextStyle(color: resultColor, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Value(label: 'WAGER', value: '${entry.wager}', color: GameColors.rewardGoldBright),
              _Value(label: 'GOLD', value: _delta(entry.goldDelta), color: GameColors.rewardGoldBright),
              _Value(label: 'COINS', value: _delta(entry.coinsDelta), color: GameColors.coin),
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
          Text(label,
              style: const TextStyle(color: GameColors.textSoft, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      );
}
