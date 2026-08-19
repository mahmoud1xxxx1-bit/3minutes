import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
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
    required this.seasonId,
    required this.backend,
  });

  final String uid;
  final String seasonId;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            copy.seasonPass,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          bottom: TabBar(
            indicatorColor: GameColors.accentBright,
            labelColor: GameColors.textStrong,
            unselectedLabelColor: GameColors.muted,
            tabs: [
              Tab(text: copy.missions),
              Tab(text: copy.achievements),
              Tab(text: copy.seasonPass),
            ],
          ),
        ),
        body: CosmicBackground(
          child: SafeArea(
            top: false,
            child: TabBarView(
              children: [
                _MissionsTab(uid: uid, seasonId: seasonId, backend: backend),
                _AchievementsTab(uid: uid, backend: backend),
                _SeasonPassTab(uid: uid, seasonId: seasonId, backend: backend),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _claim(
  BuildContext context,
  Future<void> Function() action,
) async {
  final copy = ProgressionCopy.of(context);
  try {
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.rewardClaimed)),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.rewardUnavailable)),
    );
  }
}

class _MissionsTab extends StatelessWidget {
  const _MissionsTab({
    required this.uid,
    required this.seasonId,
    required this.backend,
  });
  final String uid;
  final String seasonId;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    return StreamBuilder<Map<String, PlayerMissionState>>(
      stream: backend.watchMissions(uid, seasonId: seasonId),
      builder: (context, snapshot) {
        final states = snapshot.data ?? const <String, PlayerMissionState>{};
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            GameSpacing.md,
            GameSpacing.md,
            GameSpacing.md,
            110,
          ),
          children: [
            _ProtectionBanner(text: copy.serverProtected),
            const SizedBox(height: GameSpacing.lg),
            for (final cadence in MissionCadence.values) ...[
              Row(
                children: [
                  Icon(
                    cadence == MissionCadence.daily
                        ? Icons.today_rounded
                        : Icons.date_range_rounded,
                    color: cadence == MissionCadence.daily
                        ? GameColors.accentBright
                        : GameColors.violet,
                  ),
                  const SizedBox(width: GameSpacing.sm),
                  Text(
                    cadence == MissionCadence.daily ? copy.daily : copy.weekly,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: GameSpacing.sm),
              for (final definition in MissionCatalog.definitions
                  .where((item) => item.cadence == cadence)) ...[
                _MissionCard(
                  definition: definition,
                  state: states[definition.id],
                  copy: copy,
                  backend: backend,
                  seasonId: seasonId,
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
  const _MissionCard({
    required this.definition,
    required this.state,
    required this.copy,
    required this.backend,
    required this.seasonId,
  });
  final MissionDefinition definition;
  final PlayerMissionState? state;
  final ProgressionCopy copy;
  final ProgressionBackend backend;
  final String seasonId;

  @override
  Widget build(BuildContext context) {
    final progress = (state?.progress ?? 0).clamp(0, definition.target).toInt();
    final fraction = definition.target <= 0 ? 0.0 : progress / definition.target;
    final complete = state?.completed ?? false;
    final claimed = state?.claimedAt != null;
    final authorityReady = AppConfig.backendPhase == BackendPhase.blaze;

    return CosmicPanel(
      glow: complete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (complete ? GameColors.success : GameColors.accent)
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  complete ? Icons.check_rounded : Icons.bolt_rounded,
                  color: complete ? GameColors.success : GameColors.accentBright,
                ),
              ),
              const SizedBox(width: GameSpacing.sm),
              Expanded(
                child: Text(
                  copy.mission(definition.id),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '$progress/${definition.target}',
                style: const TextStyle(
                  color: GameColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(GameRadii.pill),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: GameColors.surfaceRaised,
              color: complete ? GameColors.success : GameColors.accentBright,
            ),
          ),
          const SizedBox(height: GameSpacing.sm),
          Wrap(
            spacing: GameSpacing.sm,
            runSpacing: GameSpacing.xs,
            children: [
              _RewardPill(
                icon: Icons.monetization_on_rounded,
                label: '${definition.coinReward} ${copy.coins}',
                color: GameColors.rewardGold,
              ),
              _RewardPill(
                icon: Icons.bolt_rounded,
                label: '${definition.seasonXpReward} ${copy.seasonXp}',
                color: GameColors.accentBright,
              ),
            ],
          ),
          if (complete) ...[
            const SizedBox(height: GameSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: !claimed && authorityReady
                    ? () => _claim(
                          context,
                          () => backend.claimMissionReward(
                            missionId: definition.id,
                            seasonId: seasonId,
                          ),
                        )
                    : null,
                icon: Icon(
                  claimed ? Icons.check_circle_rounded : Icons.redeem_rounded,
                ),
                label: Text(claimed ? copy.claimed : copy.claim),
              ),
            ),
          ],
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
          padding: const EdgeInsets.fromLTRB(
            GameSpacing.md,
            GameSpacing.md,
            GameSpacing.md,
            110,
          ),
          itemCount: AchievementCatalog.definitions.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: GameSpacing.sm),
          itemBuilder: (context, index) {
            final definition = AchievementCatalog.definitions[index];
            final state = states[definition.id];
            final progress =
                (state?.progress ?? 0).clamp(0, definition.target).toInt();
            final fraction = definition.target <= 0
                ? 0.0
                : progress / definition.target;
            final completed = state?.completed ?? false;
            final claimed = state?.rewardClaimedAt != null;
            final authorityReady = AppConfig.backendPhase == BackendPhase.blaze;

            return CosmicPanel(
              glow: completed,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: completed ? GameColors.cosmicGradient : null,
                          color: completed ? null : GameColors.accentSoft,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: completed ? GameShadows.primaryGlow : null,
                        ),
                        child: Icon(
                          completed
                              ? Icons.emoji_events_rounded
                              : Icons.lock_outline_rounded,
                          color: completed ? Colors.white : GameColors.accentBright,
                        ),
                      ),
                      const SizedBox(width: GameSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              copy.achievement(definition.id),
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: GameSpacing.xs),
                            LinearProgressIndicator(
                              value: fraction,
                              minHeight: 7,
                              backgroundColor: GameColors.surfaceRaised,
                              color: completed
                                  ? GameColors.rewardGold
                                  : GameColors.accentBright,
                            ),
                            const SizedBox(height: GameSpacing.xs),
                            Text(
                              '$progress/${definition.target} • ${definition.coinReward} ${copy.coins}',
                              style: const TextStyle(
                                color: GameColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (completed) ...[
                    const SizedBox(height: GameSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: !claimed && authorityReady
                            ? () => _claim(
                                  context,
                                  () => backend.claimAchievementReward(
                                    definition.id,
                                  ),
                                )
                            : null,
                        icon: Icon(
                          claimed
                              ? Icons.check_circle_rounded
                              : Icons.redeem_rounded,
                        ),
                        label: Text(claimed ? copy.claimed : copy.claim),
                      ),
                    ),
                  ],
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
  const _SeasonPassTab({
    required this.uid,
    required this.seasonId,
    required this.backend,
  });
  final String uid;
  final String seasonId;
  final ProgressionBackend backend;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    return StreamBuilder<PlayerSeasonPassState>(
      stream: backend.watchSeasonPass(uid, seasonId: seasonId),
      builder: (context, snapshot) {
        final state = snapshot.data ??
            PlayerSeasonPassState(
              seasonId: seasonId,
              seasonXp: 0,
              premiumUnlocked: false,
              claimedFreeLevels: const <int>{},
              claimedPremiumLevels: const <int>{},
            );
        final level = SeasonPassPolicy.levelForXp(state.seasonXp);
        final fraction = SeasonPassPolicy.progressFraction(state.seasonXp);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            GameSpacing.md,
            GameSpacing.md,
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
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: GameColors.cosmicGradient,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: GameShadows.primaryGlow,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: GameSpacing.md),
                      Expanded(
                        child: Text(
                          '${copy.seasonLevel} $level/${SeasonPassPolicy.maxLevel}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GameSpacing.md),
                  LinearProgressIndicator(
                    value: fraction,
                    minHeight: 10,
                    backgroundColor: GameColors.surfaceRaised,
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  Text(
                    '${state.seasonXp} ${copy.seasonXp}',
                    style: const TextStyle(color: GameColors.muted),
                  ),
                  if (!state.premiumUnlocked) ...[
                    const SizedBox(height: GameSpacing.sm),
                    Text(
                      copy.premiumPassLocked,
                      style: const TextStyle(
                        color: GameColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: GameSpacing.lg),
            for (var tier = 1; tier <= SeasonPassPolicy.maxLevel; tier++) ...[
              _SeasonTierRow(
                tier: tier,
                currentLevel: level,
                state: state,
                backend: backend,
                copy: copy,
              ),
              const SizedBox(height: GameSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _SeasonTierRow extends StatelessWidget {
  const _SeasonTierRow({
    required this.tier,
    required this.currentLevel,
    required this.state,
    required this.backend,
    required this.copy,
  });
  final int tier;
  final int currentLevel;
  final PlayerSeasonPassState state;
  final ProgressionBackend backend;
  final ProgressionCopy copy;

  @override
  Widget build(BuildContext context) {
    final unlocked = tier <= currentLevel;
    final authorityReady = AppConfig.backendPhase == BackendPhase.blaze;
    final freeClaimed = state.claimedFreeLevels.contains(tier);
    final premiumClaimed = state.claimedPremiumLevels.contains(tier);
    final freeCoins = SeasonPassPolicy.freeCoinRewardForLevel(tier);
    final premiumCoins = SeasonPassPolicy.premiumCoinRewardForLevel(tier);

    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked ? GameColors.accentSoft : GameColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$tier',
              style: TextStyle(
                color: unlocked ? GameColors.accentBright : GameColors.muted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: _TrackReward(
              label: copy.free,
              rewardCoins: freeCoins,
              unlocked: unlocked,
              claimed: freeClaimed,
              premium: false,
              onClaim: unlocked && !freeClaimed && authorityReady
                  ? () => _claim(
                        context,
                        () => backend.claimSeasonPassReward(
                          seasonId: state.seasonId,
                          level: tier,
                          track: SeasonPassClaimTrack.free,
                        ),
                      )
                  : null,
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: _TrackReward(
              label: copy.premium,
              rewardCoins: premiumCoins,
              unlocked: unlocked && state.premiumUnlocked,
              claimed: premiumClaimed,
              premium: true,
              onClaim:
                  unlocked && state.premiumUnlocked && !premiumClaimed && authorityReady
                      ? () => _claim(
                            context,
                            () => backend.claimSeasonPassReward(
                              seasonId: state.seasonId,
                              level: tier,
                              track: SeasonPassClaimTrack.premium,
                            ),
                          )
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackReward extends StatelessWidget {
  const _TrackReward({
    required this.label,
    required this.rewardCoins,
    required this.unlocked,
    required this.claimed,
    required this.premium,
    required this.onClaim,
  });
  final String label;
  final int rewardCoins;
  final bool unlocked;
  final bool claimed;
  final bool premium;
  final VoidCallback? onClaim;

  @override
  Widget build(BuildContext context) {
    final copy = ProgressionCopy.of(context);
    final color = premium ? GameColors.violet : GameColors.accentBright;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GameSpacing.sm,
        vertical: GameSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: unlocked ? .12 : .04),
        borderRadius: BorderRadius.circular(GameRadii.button),
        border: Border.all(
          color: color.withValues(alpha: unlocked ? .28 : .08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                claimed
                    ? Icons.check_circle_rounded
                    : unlocked
                        ? Icons.card_giftcard_rounded
                        : Icons.lock_outline_rounded,
                size: 16,
                color: claimed || unlocked ? color : GameColors.muted,
              ),
              const SizedBox(width: GameSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: unlocked ? color : GameColors.muted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$rewardCoins ${copy.coins}',
            style: const TextStyle(
              color: GameColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (unlocked) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 30,
              child: FilledButton(
                onPressed: claimed ? null : onClaim,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: Text(
                  claimed ? copy.claimed : copy.claim,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardPill extends StatelessWidget {
  const _RewardPill({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(GameRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionBanner extends StatelessWidget {
  const _ProtectionBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: GameColors.success),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: GameColors.muted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
