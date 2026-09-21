import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/cosmic_background.dart';
import '../../../../core/theme/design_tokens.dart';
import 'troll_game.dart';
import '../../../../economy_manager.dart';
import '../../../../services/life_recovery_dialog.dart';
import 'troll_stage_plan.dart';

class LevelDevilHubScreen extends StatefulWidget {
  const LevelDevilHubScreen({super.key, this.inline = false});
  final bool inline;

  @override
  State<LevelDevilHubScreen> createState() => _LevelDevilHubScreenState();
}

class _LevelDevilHubScreenState extends State<LevelDevilHubScreen> {
  int _season = 1;

  int get _startStage => _season == 6 ? 101 : ((_season - 1) * 20) + 1;
  int get _count => _season == 6 ? 75 : 20;

  Future<void> _openStage(int stageId) async {
    final plan = TrollStagePlan.fromStageId(stageId);
    final start = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _StageIntro(plan: plan),
    );
    if (start != true || !mounted) return;
    final economy = await EconomyManager.checkEconomy();
    if ((economy['lives'] as int? ?? 0) <= 0) {
      if (!mounted) return;
      await showLifeRecoveryDialog(context);
      return;
    }
    HapticFeedback.mediumImpact();
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 240),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => TrollGame(
          startRound: plan.localStage,
          maxRounds: 1,
          levelsPerMechanic: plan.levelsPerMechanic,
          mechanicOffset: plan.mechanicOffset,
          onWin: (_) => Navigator.of(context).pop(),
          onFail: () async {\n            await EconomyManager.deductLife();\n            if (context.mounted) Navigator.of(context).pop();\n          },
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
    final seasonSix = _season == 6;
    return Scaffold(
      backgroundColor: GameColors.background,
      body: CosmicBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (!widget.inline)
                SliverAppBar(
                  pinned: true,
                  backgroundColor: GameColors.background.withOpacity(.94),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  title: const Text('LVL LOOL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                  centerTitle: true,
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(18, widget.inline ? 18 : 8, 18, 8),
                sliver: SliverToBoxAdapter(child: _hero(seasonSix)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                sliver: SliverToBoxAdapter(child: _seasonSelector()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          seasonSix ? 'SEASON 6 • 75 STAGES' : 'SEASON ' + _season.toString() + ' • 20 STAGES',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ),
                      _rangeBadge(),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 130),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final stageId = _startStage + index;
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.sizeOf(context).width >= 500 ? 3 : 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: .86,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(bool seasonSix) {
    return CosmicPanel(
      glow: true,
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: GameColors.cosmicGradient,
              boxShadow: GameShadows.primaryGlow,
            ),
            child: Icon(
              seasonSix ? Icons.auto_awesome_rounded : Icons.public_rounded,
              color: GameColors.backgroundDeep,
              size: 31,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WORLDS / SEASONS', style: TextStyle(color: GameColors.accentBright, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                SizedBox(height: 4),
                Text('CHOOSE YOUR WORLD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 2),
                Text('175 stages • original stage identities preserved', style: TextStyle(color: GameColors.muted, fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seasonSelector() {
    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final season = index + 1;
          final count = season == 6 ? 75 : 20;
          final selected = season == _season;
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _season = season);
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: GameDurations.normal,
                width: 118,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: selected ? GameColors.cosmicGradient : null,
                  color: selected ? null : GameColors.surfaceGlass,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? GameColors.accent.withOpacity(.7) : GameColors.surfaceStrong),
                  boxShadow: selected ? GameShadows.primaryGlow : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      season == 6 ? Icons.auto_awesome_rounded : Icons.public_rounded,
                      color: selected ? GameColors.backgroundDeep : GameColors.accentBright,
                      size: 20,
                    ),
                    const Spacer(),
                    Text(
                      'SEASON ' + season.toString(),
                      style: TextStyle(
                        color: selected ? GameColors.backgroundDeep : GameColors.textStrong,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      count.toString() + ' STAGES',
                      style: TextStyle(
                        color: selected ? GameColors.backgroundDeep.withOpacity(.7) : GameColors.muted,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _rangeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.accentSoft,
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: GameColors.accent.withOpacity(.25)),
      ),
      child: Text(
        _startStage.toString() + '–' + (_startStage + _count - 1).toString(),
        style: const TextStyle(color: GameColors.accentBright, fontWeight: FontWeight.w900, fontSize: 10),
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
    final color = switch (difficulty) {
      1 => GameColors.success,
      2 => GameColors.warning,
      _ => GameColors.danger,
    };
    final label = switch (difficulty) {
      1 => 'EASY',
      2 => 'MEDIUM',
      _ => 'HARD',
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: GameColors.surfaceGlass,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(.28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(9)),
                    child: Text(label, style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .6)),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GameColors.backgroundDeep,
                    border: Border.all(color: color.withOpacity(.7), width: 1.4),
                    boxShadow: [BoxShadow(color: color.withOpacity(.12), blurRadius: 16)],
                  ),
                  child: Text(stageId.toString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 8),
                Text('MECHANIC ' + mechanicId.toString(), style: const TextStyle(color: GameColors.muted, fontSize: 8, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Icon(
                    i < difficulty ? Icons.star_rounded : Icons.star_border_rounded,
                    color: i < difficulty ? color : GameColors.surfaceStrong,
                    size: 12,
                  )),
                ),
                const SizedBox(height: 6),
                Text('TAP TO PLAY', style: TextStyle(color: color.withOpacity(.9), fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageIntro extends StatelessWidget {
  const _StageIntro({required this.plan});
  final TrollStagePlan plan;

  @override
  Widget build(BuildContext context) {
    final color = switch (plan.difficulty) {
      1 => GameColors.success,
      2 => GameColors.warning,
      _ => GameColors.danger,
    };
    final label = switch (plan.difficulty) {
      1 => 'EASY',
      2 => 'MEDIUM',
      _ => 'HARD',
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CosmicPanel(
          glow: true,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: GameColors.cosmicGradient, boxShadow: GameShadows.primaryGlow),
                child: Center(child: Text(plan.stageId.toString(), style: const TextStyle(color: GameColors.backgroundDeep, fontSize: 23, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(height: 12),
              const Text('STAGE READY', style: TextStyle(color: GameColors.accentBright, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 5),
              Text('STAGE ' + plan.stageId.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(99), border: Border.all(color: color.withOpacity(.3))),
                child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              Text('MECHANIC ' + plan.mechanicId.toString(), style: const TextStyle(color: GameColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
              const SizedBox(height: 15),
              const Text('Gameplay will switch to fullscreen landscape mode.', textAlign: TextAlign.center, style: TextStyle(color: GameColors.textSoft, fontSize: 11)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('START STAGE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
