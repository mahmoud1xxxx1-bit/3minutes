import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/arena_copy.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/mission_catalog.dart';
import '../data/progression_backend.dart';
import '../domain/mission.dart';
import '../domain/season_pass.dart';
import 'premium_season_pass_screen.dart';
import 'progression_screen.dart';

class ArenaProgressionScreen extends StatelessWidget {
  const ArenaProgressionScreen({
    super.key,
    required this.uid,
    required this.seasonId,
    required this.backend,
  });

  final String uid;
  final String seasonId;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(copy.progression, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: StreamBuilder<PlayerSeasonPassState>(
            stream: backend.watchSeasonPass(uid, seasonId: seasonId),
            builder: (context, seasonSnapshot) {
              final season = seasonSnapshot.data;
              final seasonXp = season?.seasonXp ?? 0;
              final level = SeasonPassPolicy.levelForXp(seasonXp);
              final progress = SeasonPassPolicy.progressFraction(seasonXp);
              return StreamBuilder<Map<String, PlayerMissionState>>(
                stream: backend.watchMissions(uid, seasonId: seasonId),
                builder: (context, missionSnapshot) {
                  final states = missionSnapshot.data ?? const <String, PlayerMissionState>{};
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.sm, GameSpacing.md, 48),
                    children: [
                      _ProgressHero(
                        level: level,
                        seasonXp: seasonXp,
                        progress: progress,
                        premium: season?.premiumUnlocked ?? false,
                      ),
                      const SizedBox(height: GameSpacing.md),
                      _MissionSummary(states: states),
                      const SizedBox(height: GameSpacing.lg),
                      _MissionSection(
                        cadence: MissionCadence.daily,
                        states: states,
                        backend: backend,
                        seasonId: seasonId,
                      ),
                      const SizedBox(height: GameSpacing.lg),
                      _MissionSection(
                        cadence: MissionCadence.weekly,
                        states: states,
                        backend: backend,
                        seasonId: seasonId,
                      ),
                      const SizedBox(height: GameSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: ArenaPlayButton(
                              title: copy.achievements,
                              subtitle: copy.isArabic ? 'الشارات والإنجازات ومسار المكافآت الكامل' : 'Badges, achievements and full reward track',
                              icon: Icons.workspace_premium_rounded,
                              primary: false,
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProgressionScreen(uid: uid, seasonId: seasonId, backend: backend),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GameSpacing.sm),
                      ArenaPlayButton(
                        title: copy.seasonPass,
                        subtitle: copy.isArabic ? '30 مستوى ومكافآت مجانية وPremium' : '30 levels with free and Premium rewards',
                        icon: Icons.auto_awesome_rounded,
                        primary: false,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PremiumSeasonPassScreen(uid: uid, seasonId: seasonId, backend: backend),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.level,
    required this.seasonXp,
    required this.progress,
    required this.premium,
  });

  final int level;
  final int seasonXp;
  final double progress;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final intoLevel = SeasonPassPolicy.xpIntoLevel(seasonXp);
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172C55), Color(0xFF321F5A), Color(0xFF0A1730)],
        ),
        border: Border.all(color: GameColors.violet.withValues(alpha: .42)),
        boxShadow: const [BoxShadow(color: Color(0x302F69FF), blurRadius: 30, offset: Offset(0, 14))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: GameColors.cosmicGradient,
                  boxShadow: GameShadows.primaryGlow,
                ),
                child: Text('$level', style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${copy.level} $level', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      copy.isArabic ? 'واصل اللعب لفتح مستوى الموسم التالي' : 'Keep battling to unlock the next season level',
                      style: const TextStyle(color: GameColors.textSoft, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
              ArenaPill(
                label: premium ? 'PREMIUM' : 'FREE',
                icon: premium ? Icons.workspace_premium_rounded : Icons.stars_rounded,
                color: premium ? GameColors.rewardGold : GameColors.accentBright,
                solid: true,
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.lg),
          Row(
            children: [
              Text(copy.seasonPath, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
              const Spacer(),
              Text('$intoLevel/${SeasonPassPolicy.xpPerLevel} XP', style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          ArenaProgress(value: progress, color: premium ? GameColors.rewardGold : GameColors.violet, height: 10),
          const SizedBox(height: 10),
          Row(
            children: [
              _LevelNode(level: level, active: true),
              Expanded(child: Container(height: 1, color: GameColors.surfaceStrong)),
              _LevelNode(level: (level + 1).clamp(1, SeasonPassPolicy.maxLevel), active: false),
              Expanded(child: Container(height: 1, color: GameColors.surfaceStrong)),
              _LevelNode(level: (level + 2).clamp(1, SeasonPassPolicy.maxLevel), active: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  const _LevelNode({required this.level, required this.active});
  final int level;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? GameColors.violet : GameColors.surfaceRaised,
        border: Border.all(color: active ? GameColors.accentBright : GameColors.surfaceStrong),
      ),
      child: Text('$level', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: active ? Colors.white : GameColors.muted)),
    );
  }
}

class _MissionSummary extends StatelessWidget {
  const _MissionSummary({required this.states});
  final Map<String, PlayerMissionState> states;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final defs = MissionCatalog.definitions;
    final complete = defs.where((d) => states[d.id]?.completed ?? false).length;
    final unclaimed = defs.where((d) => (states[d.id]?.completed ?? false) && states[d.id]?.claimedAt == null).length;
    final earnedCoins = defs
        .where((d) => states[d.id]?.claimedAt != null)
        .fold<int>(0, (sum, d) => sum + d.coinReward);
    return Row(
      children: [
        ArenaMetric(label: copy.complete, value: '$complete/${defs.length}', icon: Icons.task_alt_rounded, color: GameColors.success),
        const SizedBox(width: 8),
        ArenaMetric(label: copy.rewardReady, value: '$unclaimed', icon: Icons.redeem_rounded, color: GameColors.rewardGold),
        const SizedBox(width: 8),
        ArenaMetric(label: copy.coins, value: '$earnedCoins', icon: Icons.monetization_on_rounded, color: GameColors.warning),
      ],
    );
  }
}

class _MissionSection extends StatelessWidget {
  const _MissionSection({
    required this.cadence,
    required this.states,
    required this.backend,
    required this.seasonId,
  });

  final MissionCadence cadence;
  final Map<String, PlayerMissionState> states;
  final ProgressionBackend backend;
  final String seasonId;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final definitions = MissionCatalog.definitions.where((item) => item.cadence == cadence).toList(growable: false);
    final daily = cadence == MissionCadence.daily;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ArenaSectionTitle(
          title: daily ? copy.daily : copy.weekly,
          subtitle: daily
              ? (copy.isArabic ? 'تتجدد يوميًا • تقدم سريع ومكافآت فورية' : 'Refreshes daily • fast progress and instant rewards')
              : (copy.isArabic ? 'أهداف أكبر ومكافآت أقوى طوال الأسبوع' : 'Bigger goals and stronger rewards all week'),
          icon: daily ? Icons.today_rounded : Icons.date_range_rounded,
        ),
        const SizedBox(height: GameSpacing.sm),
        for (var i = 0; i < definitions.length; i++) ...[
          _ArenaMissionCard(
            definition: definitions[i],
            state: states[definitions[i].id],
            backend: backend,
            seasonId: seasonId,
          ),
          if (i != definitions.length - 1) const SizedBox(height: GameSpacing.sm),
        ],
      ],
    );
  }
}

class _ArenaMissionCard extends StatefulWidget {
  const _ArenaMissionCard({
    required this.definition,
    required this.state,
    required this.backend,
    required this.seasonId,
  });

  final MissionDefinition definition;
  final PlayerMissionState? state;
  final ProgressionBackend backend;
  final String seasonId;

  @override
  State<_ArenaMissionCard> createState() => _ArenaMissionCardState();
}

class _ArenaMissionCardState extends State<_ArenaMissionCard> {
  bool _busy = false;

  Future<void> _claim() async {
    if (_busy || AppConfig.backendPhase != BackendPhase.blaze) return;
    setState(() => _busy = true);
    final copy = ArenaCopy.of(context);
    try {
      await widget.backend.claimMissionReward(
        missionId: widget.definition.id,
        seasonId: widget.seasonId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.isArabic ? 'تم استلام المكافأة' : 'Reward claimed'), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(copy.isArabic ? 'تعذر استلام المكافأة' : 'Could not claim reward'), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final definition = widget.definition;
    final state = widget.state;
    final progress = (state?.progress ?? 0).clamp(0, definition.target).toInt();
    final fraction = definition.target <= 0 ? 0.0 : progress / definition.target;
    final complete = state?.completed ?? false;
    final claimed = state?.claimedAt != null;
    final color = claimed
        ? GameColors.muted
        : complete
            ? GameColors.success
            : (definition.cadence == MissionCadence.daily ? GameColors.accentBright : GameColors.violet);

    return ArenaCard(
      accent: complete && !claimed ? GameColors.success : null,
      glow: complete && !claimed,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color.withValues(alpha: .11), borderRadius: BorderRadius.circular(15)),
            child: Icon(_icon(definition.metric, claimed), color: color, size: 22),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(copy.mission(definition.id), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                    const SizedBox(width: 6),
                    ArenaPill(
                      label: claimed ? copy.claimed : (complete ? copy.rewardReady : '$progress/${definition.target}'),
                      color: color,
                      solid: complete && !claimed,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ArenaProgress(value: fraction, color: color, height: 6),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    _Reward(icon: Icons.monetization_on_rounded, text: '+${definition.coinReward}', color: GameColors.rewardGold),
                    _Reward(icon: Icons.auto_awesome_rounded, text: '+${definition.seasonXpReward} XP', color: GameColors.violet),
                  ],
                ),
              ],
            ),
          ),
          if (complete && !claimed) ...[
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: copy.claim,
              onPressed: _busy || AppConfig.backendPhase != BackendPhase.blaze ? null : _claim,
              icon: _busy
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.redeem_rounded),
            ),
          ],
        ],
      ),
    );
  }

  IconData _icon(MissionMetric metric, bool claimed) {
    if (claimed) return Icons.done_all_rounded;
    return switch (metric) {
      MissionMetric.matchesPlayed => Icons.sports_esports_rounded,
      MissionMetric.wins => Icons.emoji_events_rounded,
      MissionMetric.friendMatches => Icons.groups_2_rounded,
    };
  }
}

class _Reward extends StatelessWidget {
  const _Reward({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
