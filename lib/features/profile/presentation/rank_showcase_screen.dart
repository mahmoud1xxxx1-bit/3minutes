import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../competition/presentation/rank_emblem.dart';
import '../data/profile_repository.dart';
import '../domain/player_profile.dart';

class RankShowcaseScreen extends StatefulWidget {
  const RankShowcaseScreen({
    super.key,
    required this.profile,
    required this.profileRepository,
  });

  final PlayerProfile profile;
  final ProfileRepository profileRepository;

  @override
  State<RankShowcaseScreen> createState() => _RankShowcaseScreenState();
}

class _RankShowcaseScreenState extends State<RankShowcaseScreen> {
  RankTier? _selectedTier;
  RankTier? _savingTier;
  String? _error;

  bool get _selectionEnabled => AppConfig.rankedAuthorityEnabled;

  @override
  void initState() {
    super.initState();
    _selectedTier = widget.profile.showcaseRankTier;
  }

  Future<void> _select(RankTier tier) async {
    if (!_selectionEnabled ||
        _savingTier != null ||
        !widget.profile.isRankEmblemUnlocked(tier)) {
      return;
    }
    setState(() {
      _savingTier = tier;
      _error = null;
    });
    try {
      await widget.profileRepository.selectRankShowcase(tier);
      if (!mounted) return;
      setState(() => _selectedTier = tier);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = Localizations.localeOf(context).languageCode == 'ar'
            ? 'تعذر تجهيز الشارة الآن.'
            : 'Could not equip this emblem right now.';
      });
    } finally {
      if (mounted) setState(() => _savingTier = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final currentTier = RankPolicy.tierFor(widget.profile.rankPoints);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          ar ? 'شارات الرتب' : 'Rank Emblems',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              GameSpacing.md,
              GameSpacing.sm,
              GameSpacing.md,
              GameSpacing.xl,
            ),
            children: [
              CosmicPanel(
                glow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          color: GameColors.accentBright,
                        ),
                        const SizedBox(width: GameSpacing.sm),
                        Expanded(
                          child: Text(
                            ar ? 'سجل إنجازاتك' : 'Your rank legacy',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GameSpacing.sm),
                    Text(
                      ar
                          ? 'كل رتبة تصل إليها تُفتح نهائيًا للعرض. اختيار شارة قديمة لا يغيّر رتبتك التنافسية الحالية.'
                          : 'Every tier you reach is permanently unlocked for display. Equipping an older emblem never changes your current competitive rank.',
                      style: const TextStyle(
                        color: GameColors.textSoft,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: GameSpacing.md),
                    Row(
                      children: [
                        Text(
                          ar ? 'رتبتك الحالية' : 'Current rank',
                          style: const TextStyle(
                            color: GameColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        RankBadge(
                          tier: currentTier,
                          compact: true,
                          legendarySeasons: widget.profile.legendarySeasons,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_selectionEnabled) ...[
                const SizedBox(height: GameSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(GameSpacing.md),
                  decoration: BoxDecoration(
                    color: GameColors.accentSoft,
                    borderRadius: BorderRadius.circular(GameRadii.card),
                    border: Border.all(
                      color: GameColors.accentBright.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.visibility_rounded,
                        color: GameColors.accentBright,
                        size: 20,
                      ),
                      const SizedBox(width: GameSpacing.sm),
                      Expanded(
                        child: Text(
                          ar
                              ? 'يمكنك الآن مشاهدة جميع الشارات التي كسبتها. تجهيز شارة تاريخية للعرض العام يتفعّل بعد تشغيل خادم المنافسة الآمن؛ لا يتم إرسال أي اختيار من هذه الشاشة أثناء وضع Spark.'
                              : 'You can view every emblem you have earned now. Equipping a historical emblem for public display activates with the secure competition server; this screen sends no selection while Spark mode is active.',
                          style: const TextStyle(
                            color: GameColors.textSoft,
                            height: 1.4,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: GameSpacing.sm),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GameColors.danger),
                ),
              ],
              const SizedBox(height: GameSpacing.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: RankTier.values.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: GameSpacing.sm,
                  mainAxisSpacing: GameSpacing.sm,
                  childAspectRatio: 0.92,
                ),
                itemBuilder: (context, index) {
                  final tier = RankTier.values[index];
                  final unlocked = widget.profile.isRankEmblemUnlocked(tier);
                  final selected = _selectedTier == tier;
                  final saving = _savingTier == tier;
                  return _RankEmblemCard(
                    tier: tier,
                    unlocked: unlocked,
                    selected: selected,
                    saving: saving,
                    selectionEnabled: _selectionEnabled,
                    legendarySeasons: widget.profile.legendarySeasons,
                    onTap: unlocked && _selectionEnabled ? () => _select(tier) : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankEmblemCard extends StatelessWidget {
  const _RankEmblemCard({
    required this.tier,
    required this.unlocked,
    required this.selected,
    required this.saving,
    required this.selectionEnabled,
    required this.legendarySeasons,
    required this.onTap,
  });

  final RankTier tier;
  final bool unlocked;
  final bool selected;
  final bool saving;
  final bool selectionEnabled;
  final int legendarySeasons;
  final VoidCallback? onTap;

  Color get _rankColor => switch (tier) {
        RankTier.bronze => GameColors.rankBronze,
        RankTier.silver => GameColors.rankSilver,
        RankTier.gold => GameColors.rankGold,
        RankTier.platinum => GameColors.rankPlatinum,
        RankTier.diamond => GameColors.rankDiamond,
        RankTier.master => GameColors.rankMaster,
        RankTier.grandmaster => GameColors.rankGrandmaster,
        RankTier.legend => GameColors.rankLegend,
      };

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final color = _rankColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GameRadii.card),
      child: AnimatedContainer(
        duration: GameDurations.normal,
        padding: const EdgeInsets.all(GameSpacing.md),
        decoration: BoxDecoration(
          color: unlocked
              ? color.withValues(alpha: selected ? 0.14 : 0.07)
              : GameColors.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(GameRadii.card),
          border: Border.all(
            color: selected
                ? color
                : unlocked
                    ? color.withValues(alpha: 0.32)
                    : GameColors.surfaceStrong,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.24),
                    blurRadius: 24,
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: unlocked ? 1 : 0.22,
                  child: RankEmblem(tier: tier, size: 82),
                ),
                if (!unlocked)
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: GameColors.surfaceGlass,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: GameColors.muted,
                    ),
                  ),
                if (saving)
                  const SizedBox.square(
                    dimension: 32,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
              ],
            ),
            const SizedBox(height: GameSpacing.sm),
            Text(
              tier.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: unlocked ? color : GameColors.muted,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            if (tier == RankTier.legend && legendarySeasons > 0) ...[
              const SizedBox(height: 3),
              Text(
                'Legendary ×$legendarySeasons',
                style: const TextStyle(
                  color: GameColors.rewardGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            const SizedBox(height: 5),
            Text(
              selected
                  ? (ar ? 'مجهّزة للعرض' : 'Equipped')
                  : unlocked
                      ? selectionEnabled
                          ? (ar ? 'اضغط للتجهيز' : 'Tap to equip')
                          : (ar ? 'مفتوحة للعرض' : 'Unlocked to view')
                      : (ar ? 'غير مكتسبة' : 'Locked'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? color : GameColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
