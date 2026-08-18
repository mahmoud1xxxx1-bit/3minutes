import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../data/achievement_catalog.dart';
import '../data/mission_catalog.dart';
import '../data/progression_backend.dart';
import '../domain/achievement.dart';
import '../domain/mission.dart';
import '../domain/season_pass.dart';
import 'progression_copy.dart';

class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({
    super.key,
    required this.uid,
    required this.backend,
  });

  final String uid;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(copy.seasonPass, style: const TextStyle(fontWeight: FontWeight.w900)),
          bottom: TabBar(
            tabs: [
              Tab(text: copy.missions),
              Tab(text: copy.achievements),
              Tab(text: copy.seasonPass),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _MissionsTab(uid: uid, backend: backend),
              _AchievementsTab(uid: uid, backend: backend),
              _SeasonPassTab(uid: uid, backend: backend),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionsTab extends StatelessWidget {
  const _MissionsTab({required this.uid, required this.backend});
  final String uid;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    return StreamBuilder<Map<String, PlayerMissionState>>(
      stream: backend.watchMissions(uid),
      builder: (context, snapshot) {
        final states = snapshot.data ?? const <String, PlayerMissionState>{};
        return ListView(
          padding: const EdgeInsets.all(GameSpacing.md),
          children: [
            _ProtectionBanner(text: copy.serverProtected),
            const SizedBox(height: GameSpacing.lg),
            for (final cadence in MissionCadence.values) ...[
              Text(
                cadence == MissionCadence.daily ? copy.daily : copy.weekly,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: GameSpacing.sm),
              for (final definition in MissionCatalog.definitions.where((item) => item.cadence == cadence)) ...[
                _MissionCard(
                  definition: definition,
                  state: states[definition.id],
                  copy: copy,
                ),
                const SizedBox(height: GameSpacing.sm),
              ],
              const SizedBox(height: GameSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.definition, required this.state, required this.copy});
  final MissionDefinition definition;
  final PlayerMissionState? state;
  final ProgressionCopy copy;

  @override
  Widget build(BuildContext context) {
    final progress = (state?.progress ?? 0).clamp(0, definition.target);
    final fraction = definition.target <= 0 ? 0.0 : progress / definition.target;
    final complete = state?.completed ?? false;
    return Container(
      padding: const EdgeInsets.all(GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: complete ? GameColors.success.withValues(alpha: .45) : GameColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(copy.mission(definition.id), style: const TextStyle(fontWeight: FontWeight.w900))),
              Text('$progress/${definition.target}', style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: GameSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(GameRadii.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: GameColors.surfaceRaised,
              color: complete ? GameColors.success : GameColors.accent,
            ),
          ),
          const SizedBox(height: GameSpacing.sm),
          Wrap(
            spacing: GameSpacing.sm,
            children: [
              _RewardPill(icon: Icons.monetization_on_rounded, label: '${definition.coinReward} ${copy.coins}', color: GameColors.rewardGold),
              _RewardPill(icon: Icons.bolt_rounded, label: '${definition.seasonXpReward} ${copy.seasonXp}', color: GameColors.accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab({required this.uid, required this.backend});
  final String uid;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    return StreamBuilder<Map<String, PlayerAchievement>>(
      stream: backend.watchAchievements(uid),
      builder: (context, snapshot) {
        final states = snapshot.data ?? const <String, PlayerAchievement>{};
        return ListView.separated(
          padding: const EdgeInsets.all(GameSpacing.md),
          itemCount: AchievementCatalog.definitions.length,
          separatorBuilder: (context, index) => const SizedBox(height: GameSpacing.sm),
          itemBuilder: (context, index) {
            final definition = AchievementCatalog.definitions[index];
            final state = states[definition.id];
            final progress = (state?.progress ?? 0).clamp(0, definition.target);
            final fraction = definition.target <= 0 ? 0.0 : progress / definition.target;
            final completed = state?.completed ?? false;
            return Container(
              padding: const EdgeInsets.all(GameSpacing.md),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(GameRadii.card),
                border: Border.all(color: completed ? GameColors.rewardGold.withValues(alpha: .5) : GameColors.surfaceStrong),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (completed ? GameColors.rewardGold : GameColors.accent).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(completed ? Icons.emoji_events_rounded : Icons.lock_outline_rounded, color: completed ? GameColors.rewardGold : GameColors.accent),
                  ),
                  const SizedBox(width: GameSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(copy.achievement(definition.id), style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: GameSpacing.xs),
                        LinearProgressIndicator(value: fraction, minHeight: 7, backgroundColor: GameColors.surfaceRaised),
                        const SizedBox(height: GameSpacing.xs),
                        Text('$progress/${definition.target} • ${definition.coinReward} ${copy.coins}', style: const TextStyle(color: GameColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SeasonPassTab extends StatelessWidget {
  const _SeasonPassTab({required this.uid, required this.backend});
  final String uid;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    return StreamBuilder<PlayerSeasonPassState>(
      stream: backend.watchSeasonPass(uid),
      builder: (context, snapshot) {
        final state = snapshot.data ?? const PlayerSeasonPassState(
          seasonXp: 0,
          premiumUnlocked: false,
          claimedFreeLevels: <int>{},
          claimedPremiumLevels: <int>{},
        );
        final level = SeasonPassPolicy.levelForXp(state.seasonXp);
        final fraction = SeasonPassPolicy.progressFraction(state.seasonXp);
        return ListView(
          padding: const EdgeInsets.all(GameSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(GameSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(GameRadii.panel),
                gradient: const LinearGradient(colors: [GameColors.surfaceRaised, GameColors.surface]),
                border: Border.all(color: GameColors.rarityEpic.withValues(alpha: .35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${copy.seasonLevel} $level/${SeasonPassPolicy.maxLevel}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: GameSpacing.sm),
                  LinearProgressIndicator(value: fraction, minHeight: 10, backgroundColor: GameColors.surfaceRaised),
                  const SizedBox(height: GameSpacing.sm),
                  Text('${state.seasonXp} ${copy.seasonXp}', style: const TextStyle(color: GameColors.muted)),
                ],
              ),
            ),
            const SizedBox(height: GameSpacing.lg),
            for (var tier = 1; tier <= SeasonPassPolicy.maxLevel; tier++) ...[
              _SeasonTierRow(tier: tier, currentLevel: level, premiumUnlocked: state.premiumUnlocked, copy: copy),
              const SizedBox(height: GameSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _SeasonTierRow extends StatelessWidget {
  const _SeasonTierRow({required this.tier, required this.currentLevel, required this.premiumUnlocked, required this.copy});
  final int tier;
  final int currentLevel;
  final bool premiumUnlocked;
  final ProgressionCopy copy;

  @override
  Widget build(BuildContext context) {
    final unlocked = tier <= currentLevel;
    return Container(
      padding: const EdgeInsets.all(GameSpacing.sm),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: unlocked ? GameColors.accent.withValues(alpha: .3) : GameColors.surfaceStrong),
      ),
      child: Row(
        children: [
          SizedBox(width: 38, child: Text('$tier', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900))),
          Expanded(child: _TrackReward(label: copy.free, unlocked: unlocked, premium: false)),
          const SizedBox(width: GameSpacing.sm),
          Expanded(child: _TrackReward(label: copy.premium, unlocked: unlocked && premiumUnlocked, premium: true)),
        ],
      ),
    );
  }
}

class _TrackReward extends StatelessWidget {
  const _TrackReward({required this.label, required this.unlocked, required this.premium});
  final String label;
  final bool unlocked;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final color = premium ? GameColors.rarityEpic : GameColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GameSpacing.sm, vertical: GameSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: unlocked ? .14 : .05),
        borderRadius: BorderRadius.circular(GameRadii.button),
        border: Border.all(color: color.withValues(alpha: unlocked ? .35 : .12)),
      ),
      child: Row(
        children: [
          Icon(unlocked ? Icons.card_giftcard_rounded : Icons.lock_outline_rounded, size: 16, color: unlocked ? color : GameColors.muted),
          const SizedBox(width: GameSpacing.xs),
          Expanded(child: Text(label, style: TextStyle(color: unlocked ? color : GameColors.muted, fontWeight: FontWeight.w800, fontSize: 12))),
        ],
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: .1), borderRadius: BorderRadius.circular(GameRadii.pill)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 15, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11))]),
    );
  }
}

class _ProtectionBanner extends StatelessWidget {
  const _ProtectionBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.sm),
      decoration: BoxDecoration(color: GameColors.success.withValues(alpha: .08), borderRadius: BorderRadius.circular(GameRadii.card), border: Border.all(color: GameColors.success.withValues(alpha: .25))),
      child: Row(children: [const Icon(Icons.verified_user_rounded, color: GameColors.success), const SizedBox(width: GameSpacing.sm), Expanded(child: Text(text, style: const TextStyle(color: GameColors.muted, fontSize: 12)))]),
    );
  }
}
