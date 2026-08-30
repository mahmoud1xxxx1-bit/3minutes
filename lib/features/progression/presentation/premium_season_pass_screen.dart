import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/progression_backend.dart';
import '../domain/season_pass.dart';
import 'premium_season_pass_card.dart';

class PremiumSeasonPassScreen extends StatelessWidget {
  const PremiumSeasonPassScreen({
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
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          ar ? 'بطاقة الموسم المميزة' : 'Premium Season Pass',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: StreamBuilder<PlayerSeasonPassState>(
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
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  GameSpacing.md,
                  GameSpacing.sm,
                  GameSpacing.md,
                  GameSpacing.xl,
                ),
                children: [
                  PremiumSeasonPassCard(
                    uid: uid,
                    seasonId: seasonId,
                    unlocked: state.premiumUnlocked,
                  ),
                  const SizedBox(height: GameSpacing.md),
                  CosmicPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: GameColors.rewardGold,
                            ),
                            const SizedBox(width: GameSpacing.sm),
                            Expanded(
                              child: Text(
                                ar ? 'تقدم Premium' : 'Premium progress',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '$level/${SeasonPassPolicy.maxLevel}',
                              style: const TextStyle(
                                color: GameColors.accentBright,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: GameSpacing.md),
                        LinearProgressIndicator(
                          value: SeasonPassPolicy.progressFraction(state.seasonXp),
                          minHeight: 9,
                          backgroundColor: GameColors.surfaceRaised,
                        ),
                        const SizedBox(height: GameSpacing.sm),
                        Text(
                          ar
                              ? '${state.seasonXp} خبرة موسم — تقدمك يأتي من اللعب والمهام.'
                              : '${state.seasonXp} Season XP — progression comes from play and missions.',
                          style: const TextStyle(color: GameColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GameSpacing.md),
                  CosmicPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          ar ? 'محطات نجوم الهيبة' : 'Prestige Star milestones',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: GameSpacing.sm),
                        Text(
                          ar
                              ? 'شراء Premium لا يمنح النجوم فورًا. يجب أن تصل للمستويات التالية باللعب، وكل محطة تمنح نجمة هيبة دائمة واحدة.'
                              : 'Buying Premium does not instantly grant Stars. Reach these levels through play; each milestone grants one permanent Prestige Star.',
                          style: const TextStyle(
                            color: GameColors.textSoft,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: GameSpacing.md),
                        Wrap(
                          spacing: GameSpacing.sm,
                          runSpacing: GameSpacing.sm,
                          children: const [6, 12, 18, 24, 30]
                              .map(
                                (milestone) => _Milestone(
                                  level: milestone,
                                  reached: level >= milestone,
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GameSpacing.sm),
                  Text(
                    ar
                        ? 'مكافآت Premium لا تمنح أي قوة تنافسية؛ الرتبة والنتيجة وRP تبقى معتمدة على اللعب فقط.'
                        : 'Premium rewards never grant competitive power; rank, match result and RP remain gameplay-only.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: GameColors.muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Milestone extends StatelessWidget {
  const _Milestone({required this.level, required this.reached});

  final int level;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.rewardGold.withValues(alpha: reached ? .15 : .06),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(
          color: GameColors.rewardGold.withValues(alpha: reached ? .55 : .20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reached ? Icons.star_rounded : Icons.star_border_rounded,
            color: GameColors.rewardGold,
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(
            ar ? 'المستوى $level' : 'Level $level',
            style: const TextStyle(
              color: GameColors.rewardGold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
