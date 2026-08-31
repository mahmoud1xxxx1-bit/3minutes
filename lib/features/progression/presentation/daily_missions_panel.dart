import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/arena_copy.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/mission_catalog.dart';
import '../data/progression_backend.dart';
import '../domain/mission.dart';

class DailyMissionsPanel extends StatelessWidget {
  const DailyMissionsPanel({
    super.key,
    required this.uid,
    required this.seasonId,
    required this.backend,
    required this.onOpenAll,
  });

  final String uid;
  final String seasonId;
  final ProgressionBackend backend;
  final VoidCallback onOpenAll;

  Future<void> _claim(
    BuildContext context,
    MissionDefinition definition,
  ) async {
    final copy = ArenaCopy.of(context);
    try {
      await backend.claimMissionReward(
        missionId: definition.id,
        seasonId: seasonId,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.isArabic ? 'تم استلام مكافأة المهمة' : 'Mission reward claimed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.isArabic ? 'تعذر استلام المكافأة الآن' : 'Reward unavailable right now'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final daily = MissionCatalog.definitions
        .where((mission) => mission.cadence == MissionCadence.daily)
        .toList(growable: false);

    return StreamBuilder<Map<String, PlayerMissionState>>(
      stream: backend.watchMissions(uid, seasonId: seasonId),
      builder: (context, snapshot) {
        final states = snapshot.data ?? const <String, PlayerMissionState>{};
        final completed = daily.where((m) => states[m.id]?.completed ?? false).length;
        return ArenaCard(
          accent: completed == daily.length ? GameColors.success : GameColors.violet,
          glow: completed == daily.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ArenaSectionTitle(
                title: copy.dailyMissions,
                subtitle: copy.dailyMissionsSubtitle,
                icon: Icons.task_alt_rounded,
                trailing: ArenaPill(
                  label: '$completed/${daily.length}',
                  color: completed == daily.length ? GameColors.success : GameColors.violet,
                  solid: completed == daily.length,
                ),
              ),
              const SizedBox(height: GameSpacing.md),
              for (var i = 0; i < daily.length; i++) ...[
                _MissionRow(
                  definition: daily[i],
                  state: states[daily[i].id],
                  canClaim: AppConfig.backendPhase == BackendPhase.blaze,
                  onClaim: () => _claim(context, daily[i]),
                ),
                if (i != daily.length - 1) const SizedBox(height: GameSpacing.sm),
              ],
              const SizedBox(height: GameSpacing.md),
              TextButton.icon(
                onPressed: onOpenAll,
                icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                label: Text(
                  copy.allMissions,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.definition,
    required this.state,
    required this.canClaim,
    required this.onClaim,
  });

  final MissionDefinition definition;
  final PlayerMissionState? state;
  final bool canClaim;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final progress = (state?.progress ?? 0).clamp(0, definition.target).toInt();
    final fraction = definition.target <= 0 ? 0.0 : progress / definition.target;
    final complete = state?.completed ?? false;
    final claimed = state?.claimedAt != null;
    final color = claimed
        ? GameColors.muted
        : complete
            ? GameColors.success
            : GameColors.accentBright;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.background.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .14)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              claimed
                  ? Icons.done_all_rounded
                  : complete
                      ? Icons.redeem_rounded
                      : _iconFor(definition.metric),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.mission(definition.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(child: ArenaProgress(value: fraction, color: color, height: 6)),
                    const SizedBox(width: 8),
                    Text(
                      '$progress/${definition.target}',
                      style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w800, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _RewardChip(icon: Icons.monetization_on_rounded, value: '+${definition.coinReward}', color: GameColors.rewardGold),
                    _RewardChip(icon: Icons.auto_awesome_rounded, value: '+${definition.seasonXpReward} XP', color: GameColors.violet),
                  ],
                ),
              ],
            ),
          ),
          if (complete && !claimed) ...[
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: copy.claim,
              onPressed: canClaim ? onClaim : null,
              icon: const Icon(Icons.redeem_rounded, size: 19),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(MissionMetric metric) => switch (metric) {
        MissionMetric.matchesPlayed => Icons.sports_esports_rounded,
        MissionMetric.wins => Icons.emoji_events_rounded,
        MissionMetric.friendMatches => Icons.groups_2_rounded,
      };
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.icon, required this.value, required this.color});

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 3),
        Text(value, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
