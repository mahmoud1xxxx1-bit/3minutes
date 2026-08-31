import 'package:flutter/material.dart';

import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../data/competition_backend.dart';
import '../domain/weekly_leaderboard_entry.dart';

class WeeklyLeaderboardPanel extends StatefulWidget {
  const WeeklyLeaderboardPanel({super.key, required this.competitionBackend});

  final CompetitionBackend competitionBackend;

  @override
  State<WeeklyLeaderboardPanel> createState() => _WeeklyLeaderboardPanelState();
}

class _WeeklyLeaderboardPanelState extends State<WeeklyLeaderboardPanel> {
  WeeklyLeaderboardKind _kind = WeeklyLeaderboardKind.rp;
  late Future<List<WeeklyLeaderboardEntry>> _future;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _future = widget.competitionBackend.loadWeeklyLeaderboard(_kind);
  }

  void _select(WeeklyLeaderboardKind kind) {
    if (_kind == kind) return;
    setState(() {
      _kind = kind;
      _future = widget.competitionBackend.loadWeeklyLeaderboard(_kind);
    });
  }

  void _reload() {
    setState(() => _future = widget.competitionBackend.loadWeeklyLeaderboard(_kind));
  }

  @override
  Widget build(BuildContext context) {
    final ar = _isArabic;
    final gold = _kind == WeeklyLeaderboardKind.gold;
    final accent = gold ? GameColors.rewardGold : GameColors.accentBright;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ArenaSectionTitle(
          title: ar ? 'منافسة الأسبوع' : 'WEEKLY COMPETITION',
          subtitle: ar
              ? 'RP للمهارة • Gold للقوة الاقتصادية والاستراتيجية'
              : 'RP for skill • Gold for economic and strategic strength',
          icon: Icons.workspace_premium_rounded,
        ),
        const SizedBox(height: GameSpacing.sm),
        ArenaCard(
          accent: accent,
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<WeeklyLeaderboardKind>(
                segments: [
                  ButtonSegment(
                    value: WeeklyLeaderboardKind.rp,
                    icon: const Icon(Icons.military_tech_rounded),
                    label: Text(ar ? 'RP الأسبوعي' : 'Weekly RP'),
                  ),
                  ButtonSegment(
                    value: WeeklyLeaderboardKind.gold,
                    icon: const Icon(Icons.paid_rounded),
                    label: Text(ar ? 'Gold الأسبوعي' : 'Weekly Gold'),
                  ),
                ],
                selected: {_kind},
                showSelectedIcon: false,
                onSelectionChanged: (selection) => _select(selection.first),
              ),
              const SizedBox(height: GameSpacing.md),
              _RewardStrip(kind: _kind, arabic: ar),
              const SizedBox(height: GameSpacing.md),
              FutureBuilder<List<WeeklyLeaderboardEntry>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        const GameGlyph(
                          type: GameGlyphType.shield,
                          size: 34,
                          color: GameColors.muted,
                        ),
                        const SizedBox(height: GameSpacing.sm),
                        Text(
                          ar ? 'تعذر تحميل ترتيب الأسبوع.' : 'Could not load weekly standings.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: GameColors.textSoft),
                        ),
                        const SizedBox(height: GameSpacing.sm),
                        OutlinedButton(
                          onPressed: _reload,
                          child: Text(ar ? 'إعادة المحاولة' : 'Try again'),
                        ),
                      ],
                    );
                  }
                  final entries = snapshot.data ?? const <WeeklyLeaderboardEntry>[];
                  if (entries.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        ar
                            ? 'لا توجد نتائج هذا الأسبوع بعد. أول مواجهة أو حركة Gold ستبدأ الترتيب.'
                            : 'No weekly results yet. The first ranked match or Gold event starts the board.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: GameColors.muted, height: 1.4),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var index = 0; index < entries.length; index++) ...[
                        _WeeklyRow(
                          position: index + 1,
                          entry: entries[index],
                          kind: _kind,
                          arabic: ar,
                        ),
                        if (index + 1 < entries.length)
                          const SizedBox(height: GameSpacing.sm),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardStrip extends StatelessWidget {
  const _RewardStrip({required this.kind, required this.arabic});

  final WeeklyLeaderboardKind kind;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final gold = kind == WeeklyLeaderboardKind.gold;
    final first = gold ? '3000 Gold + 5★' : '3000 Gold';
    final second = gold ? '2500 Gold + 1★' : '2000 Gold';
    final third = gold ? '2000 Gold' : '1500 Gold';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.background.withValues(alpha: .28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.surfaceStrong),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Prize(position: '1', value: first)),
              Expanded(child: _Prize(position: '2', value: second)),
              Expanded(child: _Prize(position: '3', value: third)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            arabic ? 'كل عضو نشط آخر: 300 Gold' : 'Every other active member: 300 Gold',
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.textSoft, fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Prize extends StatelessWidget {
  const _Prize({required this.position, required this.value});
  final String position;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text('#$position', style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800)),
        ],
      );
}

class _WeeklyRow extends StatelessWidget {
  const _WeeklyRow({
    required this.position,
    required this.entry,
    required this.kind,
    required this.arabic,
  });

  final int position;
  final WeeklyLeaderboardEntry entry;
  final WeeklyLeaderboardKind kind;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final podium = position <= 3;
    final color = switch (position) {
      1 => GameColors.rewardGold,
      2 => GameColors.rankSilver,
      3 => GameColors.rankBronze,
      _ => GameColors.accentBright,
    };
    final scoreLabel = kind == WeeklyLeaderboardKind.rp
        ? '${entry.score >= 0 ? '+' : ''}${entry.score} RP'
        : '${entry.score >= 0 ? '+' : ''}${entry.score} Gold';
    final activity = kind == WeeklyLeaderboardKind.rp
        ? (arabic ? '${entry.activityCount} مواجهات' : '${entry.activityCount} matches')
        : (arabic ? '${entry.activityCount} حركات اقتصادية' : '${entry.activityCount} economy events');

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: GameColors.background.withValues(alpha: .24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: podium ? .34 : .12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .12),
            ),
            child: Text('#$position', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.gameName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(activity, style: const TextStyle(color: GameColors.muted, fontSize: 9)),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Text(scoreLabel, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
