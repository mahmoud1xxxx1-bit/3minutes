import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/competition_backend.dart';
import '../domain/leaderboard_entry.dart';
import '../domain/season_history.dart';
import '../domain/season_reset_policy.dart';
import '../domain/season_reward_policy.dart';
import 'rank_badge.dart';

class SeasonPlayerProgressPanel extends StatelessWidget {
  const SeasonPlayerProgressPanel({
    super.key,
    required this.uid,
    required this.backend,
    required this.liveEnabled,
  });

  final String uid;
  final CompetitionBackend backend;
  final bool liveEnabled;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (!liveEnabled) {
      return CosmicPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Title(
              icon: Icons.workspace_premium_rounded,
              text: ar ? 'تقدمك الموسمي' : 'Your season progress',
            ),
            const SizedBox(height: GameSpacing.sm),
            Text(
              ar
                  ? 'إحصاءات الموسم المباشرة غير متاحة في هذه النسخة التجريبية. عند توفر المنافسات الكاملة سيظهر هنا Peak Rank الحقيقي وسجل الفوز والخسارة والتعادل وتوقع مكافآت نهاية الموسم.'
                  : 'Live season statistics are unavailable in this test build. The full competitive version shows your real Peak Rank, W/L/T record, and projected season rewards here.',
              style: const TextStyle(color: GameColors.muted, height: 1.45),
            ),
            const SizedBox(height: GameSpacing.sm),
            Text(
              ar
                  ? 'نجوم الهيبة دائمة ولا تُستهلك. مكافأة نهاية الموسم وإعادة ضبط RP تعتمدان على أعلى رتبة تصل إليها خلال الموسم.'
                  : 'Prestige Stars are permanent and never spent. Season rewards and RP reset use the highest tier you reach during the season.',
              style: const TextStyle(
                color: GameColors.rewardGold,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<LeaderboardEntry?>(
      stream: backend.watchPlayerCompetition(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CosmicPanel(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return CosmicPanel(
            child: Text(
              ar ? 'تعذر تحميل تقدمك الموسمي.' : 'Could not load your season progress.',
              textAlign: TextAlign.center,
            ),
          );
        }
        final entry = snapshot.data;
        if (entry == null) {
          return CosmicPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(
                  icon: Icons.workspace_premium_rounded,
                  text: ar ? 'تقدمك الموسمي' : 'Your season progress',
                ),
                const SizedBox(height: GameSpacing.sm),
                Text(
                  ar
                      ? 'لم تُسجل لك مباراة Ranked في الموسم الحالي بعد.'
                      : 'You have not recorded a Ranked match in the current season yet.',
                  style: const TextStyle(color: GameColors.muted),
                ),
              ],
            ),
          );
        }

        final peak = entry.effectivePeakTier;
        final stars = SeasonRewardPolicy.starsForPeakTier(peak);
        final resetRp = SeasonResetPolicy.startingRpForPeakTier(peak);
        return CosmicPanel(
          glow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Title(
                icon: Icons.workspace_premium_rounded,
                text: ar ? 'تقدمك الموسمي' : 'Your season progress',
              ),
              const SizedBox(height: GameSpacing.md),
              Wrap(
                spacing: GameSpacing.sm,
                runSpacing: GameSpacing.sm,
                children: [
                  _RankMetric(
                    label: ar ? 'الرتبة الحالية' : 'Current rank',
                    badge: RankBadge(
                      tier: entry.tier,
                      legendarySeasons: entry.legendarySeasons,
                      compact: true,
                    ),
                  ),
                  _RankMetric(
                    label: ar ? 'Peak Rank' : 'Peak Rank',
                    badge: RankBadge(
                      tier: peak,
                      legendarySeasons: peak == entry.tier ? entry.legendarySeasons : 0,
                      compact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.md),
              Wrap(
                spacing: GameSpacing.sm,
                runSpacing: GameSpacing.sm,
                children: [
                  _Metric(label: ar ? 'RP الحالي' : 'Current RP', value: '${entry.rankPoints}', icon: Icons.bolt_rounded),
                  _Metric(label: ar ? 'فوز' : 'Wins', value: '${entry.wins}', icon: Icons.emoji_events_rounded),
                  _Metric(label: ar ? 'خسارة' : 'Losses', value: '${entry.losses}', icon: Icons.close_rounded),
                  _Metric(label: ar ? 'تعادل' : 'Ties', value: '${entry.ties}', icon: Icons.drag_handle_rounded),
                ],
              ),
              const SizedBox(height: GameSpacing.md),
              Container(
                padding: const EdgeInsets.all(GameSpacing.md),
                decoration: BoxDecoration(
                  color: GameColors.rewardGold.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(GameRadii.card),
                  border: Border.all(color: GameColors.rewardGold.withValues(alpha: .24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: GameColors.rewardGold, size: 30),
                    const SizedBox(width: GameSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ar ? 'إذا انتهى الموسم الآن' : 'If the season ended now',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ar
                                ? '+$stars Prestige Stars دائمة • بداية الموسم التالي: $resetRp RP'
                                : '+$stars permanent Prestige Stars • Next season starts at $resetRp RP',
                            style: const TextStyle(color: GameColors.textSoft, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
              Text(
                ar
                    ? 'القيمة تحسب من Peak Rank وسترتفع تلقائيًا إذا وصلت إلى رتبة أعلى قبل إغلاق الموسم.'
                    : 'This projection is based on Peak Rank and automatically improves if you reach a higher tier before season close.',
                style: const TextStyle(color: GameColors.muted, fontSize: 11, height: 1.35),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SeasonHistoryPanel extends StatefulWidget {
  const SeasonHistoryPanel({
    super.key,
    required this.uid,
    required this.backend,
    required this.liveEnabled,
  });

  final String uid;
  final CompetitionBackend backend;
  final bool liveEnabled;

  @override
  State<SeasonHistoryPanel> createState() => _SeasonHistoryPanelState();
}

class _SeasonHistoryPanelState extends State<SeasonHistoryPanel> {
  late Future<List<SeasonHistoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.liveEnabled
        ? widget.backend.loadSeasonHistory(widget.uid)
        : Future<List<SeasonHistoryEntry>>.value(const []);
  }

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (!widget.liveEnabled) return const SizedBox.shrink();

    return FutureBuilder<List<SeasonHistoryEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CosmicPanel(child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return CosmicPanel(
            child: Text(
              ar ? 'تعذر تحميل سجل المواسم.' : 'Could not load season history.',
              textAlign: TextAlign.center,
            ),
          );
        }
        final history = snapshot.data ?? const <SeasonHistoryEntry>[];
        return CosmicPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Title(
                icon: Icons.history_rounded,
                text: ar ? 'سجل المواسم' : 'Season history',
              ),
              const SizedBox(height: GameSpacing.sm),
              if (history.isEmpty)
                Text(
                  ar ? 'لا يوجد موسم مكتمل في السجل بعد.' : 'No completed season is recorded yet.',
                  style: const TextStyle(color: GameColors.muted),
                )
              else
                for (var i = 0; i < history.length; i++) ...[
                  _HistoryRow(entry: history[i]),
                  if (i != history.length - 1)
                    Divider(color: GameColors.surfaceStrong.withValues(alpha: .8)),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});
  final SeasonHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          RankBadge(tier: entry.peakTier, compact: true),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar ? 'الموسم ${entry.seasonNumber}' : 'Season ${entry.seasonNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  'W ${entry.wins} • L ${entry.losses} • T ${entry.ties} • ${entry.finalRankPoints} RP',
                  style: const TextStyle(color: GameColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (entry.finalStanding != null)
                Text('#${entry.finalStanding}', style: const TextStyle(fontWeight: FontWeight.w900)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: GameColors.rewardGold, size: 16),
                  Text('+${entry.starsAwarded}', style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: GameColors.rewardGold),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 118),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: GameColors.surfaceStrong.withValues(alpha: .58),
          borderRadius: BorderRadius.circular(GameRadii.card),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: GameColors.accentBright),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(label, style: const TextStyle(color: GameColors.muted, fontSize: 9)),
              ],
            ),
          ],
        ),
      );
}

class _RankMetric extends StatelessWidget {
  const _RankMetric({required this.label, required this.badge});
  final String label;
  final Widget badge;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: GameColors.surfaceStrong.withValues(alpha: .58),
          borderRadius: BorderRadius.circular(GameRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: GameColors.muted, fontSize: 9)),
            const SizedBox(height: 4),
            badge,
          ],
        ),
      );
}
