import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/competition_backend.dart';
import '../domain/rank_tier.dart';
import '../domain/season.dart';
import '../domain/season_clock.dart';
import '../domain/season_reward_policy.dart';
import 'rank_badge.dart';
import 'season_player_progress_panel.dart';

class SeasonScreen extends StatelessWidget {
  const SeasonScreen({
    super.key,
    required this.uid,
    required this.competitionBackend,
    this.onOpenMissions,
  });

  final String uid;
  final CompetitionBackend competitionBackend;
  final VoidCallback? onOpenMissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final liveEnabled = AppConfig.liveLeaderboardEnabled;
    final ar = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.season, style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          if (onOpenMissions != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: TextButton.icon(
                onPressed: onOpenMissions,
                icon: const Icon(Icons.task_alt_rounded, color: GameColors.rewardGold),
                label: Text(
                  ar ? 'المهام' : 'Missions',
                  style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              GameSpacing.md,
              GameSpacing.sm,
              GameSpacing.md,
              110,
            ),
            children: [
              CosmicPanel(
                glow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: GameColors.cosmicGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: GameShadows.primaryGlow,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 29),
                        ),
                        const SizedBox(width: GameSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.seasonCompetition, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 3),
                              Text(l10n.seasonDuration(SeasonPolicy.duration.inDays), style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.md),
                    Text(
                      l10n.seasonStarsExplanation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GameColors.muted, height: 1.45),
                    ),
                  ],
                ),
              ),
              if (onOpenMissions != null) ...[
                const SizedBox(height: GameSpacing.md),
                _MissionsGateway(onTap: onOpenMissions!),
              ],
              const SizedBox(height: GameSpacing.md),
              if (liveEnabled)
                _LiveSeasonCard(competitionBackend: competitionBackend)
              else
                CosmicPanel(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: GameColors.accentSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lock_clock_rounded, color: GameColors.accentBright),
                      ),
                      const SizedBox(width: GameSpacing.sm),
                      Expanded(child: Text(l10n.liveStandingsLocked, style: const TextStyle(color: GameColors.muted))),
                    ],
                  ),
                ),
              const SizedBox(height: GameSpacing.md),
              SeasonPlayerProgressPanel(
                uid: uid,
                backend: competitionBackend,
                liveEnabled: liveEnabled,
              ),
              if (liveEnabled) ...[
                const SizedBox(height: GameSpacing.md),
                SeasonHistoryPanel(
                  uid: uid,
                  backend: competitionBackend,
                  liveEnabled: liveEnabled,
                ),
              ],
              const SizedBox(height: GameSpacing.lg),
              Row(
                children: [
                  const Icon(Icons.military_tech_rounded, color: GameColors.rewardGold),
                  const SizedBox(width: GameSpacing.sm),
                  Text(
                    l10n.rankLadder,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.sm),
              for (final band in RankPolicy.bands) ...[
                _SeasonRewardCard(band: band),
                const SizedBox(height: GameSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionsGateway extends StatelessWidget {
  const _MissionsGateway({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameRadii.panel),
        child: Ink(
          padding: const EdgeInsets.all(GameSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameRadii.panel),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [Color(0xFF2D245F), Color(0xFF12344D), Color(0xFF10162C)],
            ),
            border: Border.all(color: GameColors.rewardGold.withValues(alpha: .42)),
            boxShadow: [
              BoxShadow(color: GameColors.rewardGold.withValues(alpha: .10), blurRadius: 24),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: GameColors.rewardGold.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: GameColors.rewardGold.withValues(alpha: .35)),
                ),
                child: const Icon(Icons.task_alt_rounded, color: GameColors.rewardGold, size: 32),
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ar ? 'مهام الموسم' : 'SEASON MISSIONS',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GameColors.rewardGold.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(GameRadii.pill),
                          ),
                          child: Text(
                            ar ? 'مكافآت' : 'REWARDS',
                            style: const TextStyle(color: GameColors.rewardGold, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ar
                          ? 'المهام اليومية والأسبوعية والإنجازات وSeason Pass — تابع تقدمك واستلم مكافآتك من هنا.'
                          : 'Daily and weekly missions, achievements, and Season Pass — track progress and claim rewards here.',
                      style: const TextStyle(color: GameColors.textSoft, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MissionPill(icon: Icons.today_rounded, text: ar ? 'يومية' : 'Daily'),
                        const SizedBox(width: 6),
                        _MissionPill(icon: Icons.date_range_rounded, text: ar ? 'أسبوعية' : 'Weekly'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, color: GameColors.rewardGold, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionPill extends StatelessWidget {
  const _MissionPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: GameColors.accentBright),
        const SizedBox(width: 3),
        Text(text, style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _LiveSeasonCard extends StatefulWidget {
  const _LiveSeasonCard({required this.competitionBackend});
  final CompetitionBackend competitionBackend;

  @override
  State<_LiveSeasonCard> createState() => _LiveSeasonCardState();
}

class _LiveSeasonCardState extends State<_LiveSeasonCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<Season?>(
      stream: widget.competitionBackend.watchCurrentSeason(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return _MessageCard(message: l10n.couldNotLoadSeason);
        final season = snapshot.data;
        if (season == null) return _MessageCard(message: l10n.noActiveSeason);
        final clock = SeasonClockPolicy.at(season: season, now: _now);
        final remaining = clock.remaining;
        return CosmicPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.seasonNumber(season.number), style: const TextStyle(fontWeight: FontWeight.w900))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: GameSpacing.sm, vertical: GameSpacing.xs),
                    decoration: BoxDecoration(
                      color: GameColors.rewardGold.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(GameRadii.pill),
                      border: Border.all(color: GameColors.rewardGold.withValues(alpha: .22)),
                    ),
                    child: Text(
                      clock.active
                          ? l10n.seasonRemaining(remaining.inDays, remaining.inHours.remainder(24))
                          : l10n.seasonClosed,
                      style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(GameRadii.pill),
                child: LinearProgressIndicator(value: clock.progress, minHeight: 9),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeasonRewardCard extends StatelessWidget {
  const _SeasonRewardCard({required this.band});
  final RankBand band;

  @override
  Widget build(BuildContext context) {
    final stars = SeasonRewardPolicy.starsForPeakTier(band.tier);
    return CosmicPanel(
      padding: const EdgeInsets.symmetric(horizontal: GameSpacing.md, vertical: GameSpacing.sm),
      child: Row(
        children: [
          RankBadge(tier: band.tier),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: GameSpacing.sm, vertical: GameSpacing.xs),
            decoration: BoxDecoration(
              color: GameColors.rewardGold.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(GameRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: GameColors.rewardGold, size: 20),
                const SizedBox(width: 4),
                Text('$stars', style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => CosmicPanel(child: Text(message, textAlign: TextAlign.center));
}
