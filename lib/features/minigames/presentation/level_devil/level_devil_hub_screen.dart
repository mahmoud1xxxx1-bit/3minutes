import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import 'troll_game.dart';
import 'troll_stage_plan.dart';

class LevelDevilHubScreen extends StatefulWidget {
  const LevelDevilHubScreen({super.key});

  @override
  State<LevelDevilHubScreen> createState() => _LevelDevilHubScreenState();
}

class _LevelDevilHubScreenState extends State<LevelDevilHubScreen> {
  int _season = 1;

  int get _startStage => _season == 6 ? 101 : ((_season - 1) * 20) + 1;
  int get _count => _season == 6 ? 75 : 20;

  void _openStage(int stageId) {
    final plan = TrollStagePlan.fromStageId(stageId);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => TrollGame(
          startRound: plan.localStage,
          maxRounds: 1,
          levelsPerMechanic: plan.levelsPerMechanic,
          mechanicOffset: plan.mechanicOffset,
          onWin: (_) => Navigator.of(context).pop(),
          onFail: () => Navigator.of(context).pop(),
        ),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: .985, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final isSeasonSix = _season == 6;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CosmicBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: GameColors.background.withOpacity(.92),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                title: const Text('LVL LOOL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.md, GameSpacing.md, GameSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        arabic ? 'اختر عالمك' : 'CHOOSE YOUR WORLD',
                        style: const TextStyle(color: GameColors.textStrong, fontSize: 27, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        arabic
                            ? 'كل مرحلة تحتفظ برقمها وهويتها الأصلية.'
                            : 'Every stage keeps its original number and identity.',
                        style: const TextStyle(color: GameColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: GameSpacing.md),
                      SizedBox(
                        height: 104,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 6,
                          separatorBuilder: (_, __) => const SizedBox(width: GameSpacing.sm),
                          itemBuilder: (_, index) {
                            final season = index + 1;
                            final selected = season == _season;
                            final count = season == 6 ? 75 : 20;
                            return _SeasonCard(
                              season: season,
                              count: count,
                              selected: selected,
                              onTap: () => setState(() => _season = season),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.sm, GameSpacing.md, GameSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isSeasonSix ? 'SEASON 6 • 75 STAGES' : 'SEASON $_season • 20 STAGES',
                          style: const TextStyle(color: GameColors.textStrong, fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: GameColors.accentSoft,
                          borderRadius: BorderRadius.circular(GameRadii.pill),
                          border: Border.all(color: GameColors.accent.withOpacity(.25)),
                        ),
                        child: Text(
                          '$_startStage–$_startStage + $_count - 1',
                          style: const TextStyle(color: GameColors.accentBright, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.sm, GameSpacing.md, 36),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final stageId = $_startStage + index;
                      final plan = TrollStagePlan.fromStageId(stageId);
                      return _StageCard(
                        stageId: stageId,
                        difficulty: plan.difficulty,
                        mechanicId: plan.mechanicId,
                        onTap: () => _openStage(stageId),
                      );
                    },
                    childCount: _count,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: .96,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.season, required this.count, required this.selected, required this.onTap});
  final int season;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: GameDurations.normal,
          width: 132,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: selected ? GameColors.cosmicGradient : null,
            color: selected ? null : GameColors.surfaceGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? GameColors.accent.withOpacity(.65) : GameColors.surfaceStrong),
            boxShadow: selected ? GameShadows.primaryGlow : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                season == 6 ? Icons.auto_awesome_rounded : Icons.public_rounded,
                color: selected ? GameColors.backgroundDeep : GameColors.accentBright,
                size: 25,
              ),
              const Spacer(),
              Text(
                'SEASON $season',
                style: TextStyle(color: selected ? GameColors.backgroundDeep : GameColors.textStrong, fontWeight: FontWeight.w900, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '$count stages',
                style: TextStyle(color: selected ? GameColors.backgroundDeep.withOpacity(.72) : GameColors.muted, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.stageId, required this.difficulty, required this.mechanicId, required this.onTap});
  final int stageId;
  final int difficulty;
  final int mechanicId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final difficultyColor = switch (difficulty) {
      1 => GameColors.success,
      2 => GameColors.warning,
      _ => GameColors.danger,
    };
    final difficultyLabel = switch (difficulty) {
      1 => 'EASY',
      2 => 'MED',
      _ => 'HARD',
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: GameColors.surfaceGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GameColors.surfaceStrong),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF152B50), Color(0xFF0A1429)]),
                    shape: BoxShape.circle,
                    border: Border.all(color: difficultyColor.withOpacity(.5)),
                  ),
                  child: Text(
                    '$stageId',
                    style: const TextStyle(color: GameColors.textStrong, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  difficultyLabel,
                  style: TextStyle(color: difficultyColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(height: 3),
                Text(
                  'MECHANIC $mechanicId',
                  style: const TextStyle(color: GameColors.muted, fontSize: 8, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
