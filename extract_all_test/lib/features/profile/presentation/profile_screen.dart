import 'package:flutter/material.dart';

import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/rank_progress.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
import '../../competition/presentation/season_star_badge.dart';
import '../../economy/presentation/avatar_artwork.dart';
import '../../progression/domain/player_progression.dart';
import '../data/profile_repository.dart';
import '../domain/player_name_rules.dart';
import '../domain/player_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.profileRepository,
  });

  final PlayerProfile profile;
  final ProfileRepository profileRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.gameName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _localizedNameIssue(AppLocalizations l10n, PlayerNameIssue issue) {
    return switch (issue) {
      PlayerNameIssue.invalidLength => l10n.playerNameLengthError,
      PlayerNameIssue.missingLetterOrNumber => l10n.playerNameLetterNumberError,
      PlayerNameIssue.unsupportedCharacters => l10n.playerNameUnsupportedError,
    };
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    final issue = PlayerNameRules.issueFor(_nameController.text);
    if (issue != null) {
      setState(() => _error = _localizedNameIssue(l10n, issue));
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.profileRepository.updatePublicProfile(
        uid: widget.profile.uid,
        gameName: PlayerNameRules.normalize(_nameController.text),
        // Avatar ownership/equipment is managed by the cosmetic system. Never
        // replace it from this editor with legacy default IDs.
        avatarId: widget.profile.avatarId,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _error = l10n.couldNotSaveProfile);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final profile = widget.profile;
    final tier = RankPolicy.tierFor(profile.rankPoints);
    final rankProgress = RankProgressPolicy.forRp(profile.rankPoints);
    final xpTarget = ProgressionPolicy.xpRequiredForLevel(profile.level);
    final xpProgress = ProgressionPolicy.progressFraction(
      PlayerProgression(level: profile.level, xp: profile.xp),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.editProfile,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(GameSpacing.md),
            children: [
              CosmicPanel(
                child: Row(
                  children: [
                    ClipOval(
                      child: AvatarArtwork(
                        avatarId: profile.avatarId,
                        size: 82,
                        borderRadius: 41,
                      ),
                    ),
                    const SizedBox(width: GameSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.gameName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: GameSpacing.sm),
                          RankBadge(
                            tier: tier,
                            legendarySeasons: profile.legendarySeasons,
                          ),
                          const SizedBox(height: GameSpacing.sm),
                          SeasonStarBadge(stars: profile.stars),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GameSpacing.md),
              Row(
                children: [
                  Expanded(child: _Stat(label: l10n.wins, value: '${profile.wins}', icon: Icons.emoji_events_outlined)),
                  const SizedBox(width: GameSpacing.sm),
                  Expanded(child: _Stat(label: l10n.losses, value: '${profile.losses}', icon: Icons.close_rounded)),
                  const SizedBox(width: GameSpacing.sm),
                  Expanded(child: _Stat(label: l10n.stars, value: '${profile.stars}', icon: Icons.star_rounded, iconColor: GameColors.rewardGold)),
                ],
              ),
              const SizedBox(height: GameSpacing.md),
              _ProgressCard(
                title: l10n.rankProgress,
                leading: RankBadge(tier: tier, compact: true),
                trailing: rankProgress.isMaxTier
                    ? l10n.maxTier
                    : l10n.rpToNext(rankProgress.rpToNextTier ?? 0),
                value: rankProgress.fraction,
                color: GameColors.accent,
              ),
              const SizedBox(height: GameSpacing.sm),
              _ProgressCard(
                title: l10n.levelProgress,
                leading: _LevelPill(level: profile.level),
                trailing: l10n.xpProgressValue(profile.xp, xpTarget),
                value: xpProgress,
                color: GameColors.success,
              ),
              const SizedBox(height: GameSpacing.xl),
              TextField(
                controller: _nameController,
                enabled: !_saving,
                maxLength: PlayerNameRules.maxLength,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  labelText: l10n.playerName,
                  helperText: l10n.playerNameHelp,
                ),
              ),
              const SizedBox(height: GameSpacing.md),
              CosmicPanel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.photo_library_rounded, color: GameColors.accentBright),
                    const SizedBox(width: GameSpacing.sm),
                    Expanded(
                      child: Text(
                        ar
                            ? 'تغيير الصورة الرمزية يتم من المتجر أو مجموعة الصور المملوكة حتى تبقى الملكية صحيحة ولا يمكن تجاوز العناصر المقفلة.'
                            : 'Change your avatar from the Shop or owned collection so cosmetic ownership remains correct and locked items cannot be bypassed.',
                        style: const TextStyle(color: GameColors.textSoft, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: GameSpacing.sm),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GameColors.danger),
                ),
              ],
              const SizedBox(height: GameSpacing.lg),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.leading,
    required this.trailing,
    required this.value,
    required this.color,
  });

  final String title;
  final Widget leading;
  final String trailing;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => CosmicPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
                Text(trailing, style: const TextStyle(color: GameColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: GameSpacing.sm),
            Align(alignment: AlignmentDirectional.centerStart, child: leading),
            const SizedBox(height: GameSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(GameRadii.pill),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                color: color,
                backgroundColor: GameColors.surfaceRaised,
              ),
            ),
          ],
        ),
      );
}

class _LevelPill extends StatelessWidget {
  const _LevelPill({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: GameColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: GameColors.success.withValues(alpha: 0.45)),
      ),
      child: Text(
        l10n.levelWithValue(level),
        style: const TextStyle(color: GameColors.success, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon, this.iconColor});
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => CosmicPanel(
        padding: const EdgeInsets.symmetric(vertical: GameSpacing.md, horizontal: GameSpacing.xs),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor ?? GameColors.accent),
            const SizedBox(height: GameSpacing.xs),
            Text(value, maxLines: 1, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: GameColors.muted, fontSize: 11)),
          ],
        ),
      );
}
