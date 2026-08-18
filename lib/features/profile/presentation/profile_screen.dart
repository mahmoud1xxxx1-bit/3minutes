import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../competition/domain/rank_progress.dart';
import '../../competition/domain/rank_tier.dart';
import '../../competition/presentation/rank_badge.dart';
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
  late String _avatarId;
  bool _saving = false;
  String? _error;

  static const _avatars = <String>[
    'default_01',
    'default_02',
    'default_03',
    'default_04',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.gameName);
    _avatarId = widget.profile.avatarId;
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
        avatarId: _avatarId,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).couldNotSaveProfile);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = widget.profile;
    final tier = RankPolicy.tierFor(profile.rankPoints);
    final rankProgress = RankProgressPolicy.forRp(profile.rankPoints);
    final xpTarget = ProgressionPolicy.xpRequiredForLevel(profile.level);
    final xpProgress = ProgressionPolicy.progressFraction(
      PlayerProgression(level: profile.level, xp: profile.xp),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GameSpacing.md),
          children: [
            _IdentityCard(profile: profile, tier: tier),
            const SizedBox(height: GameSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: l10n.wins,
                    value: '${profile.wins}',
                    icon: Icons.emoji_events_outlined,
                  ),
                ),
                const SizedBox(width: GameSpacing.sm),
                Expanded(
                  child: _Stat(
                    label: l10n.losses,
                    value: '${profile.losses}',
                    icon: Icons.close_rounded,
                  ),
                ),
                const SizedBox(width: GameSpacing.sm),
                Expanded(
                  child: _Stat(
                    label: l10n.stars,
                    value: '${profile.stars}',
                    icon: Icons.star_rounded,
                    iconColor: GameColors.rewardGold,
                  ),
                ),
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
            Text(
              l10n.editProfile,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: GameSpacing.sm),
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
            Text(
              l10n.avatar,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: GameSpacing.sm),
            Wrap(
              spacing: GameSpacing.md,
              runSpacing: GameSpacing.md,
              children: _avatars.map((avatarId) {
                final selected = avatarId == _avatarId;
                final number = _avatars.indexOf(avatarId) + 1;

                return InkWell(
                  onTap: _saving
                      ? null
                      : () => setState(() => _avatarId = avatarId),
                  borderRadius: BorderRadius.circular(GameRadii.pill),
                  child: AnimatedContainer(
                    duration: GameDurations.fast,
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? GameColors.accentSoft
                          : GameColors.surfaceRaised,
                      border: Border.all(
                        color: selected
                            ? GameColors.accent
                            : GameColors.surfaceStrong,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$number',
                      style: TextStyle(
                        color: selected
                            ? GameColors.accent
                            : GameColors.textStrong,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: GameSpacing.lg),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(GameSpacing.sm),
                decoration: BoxDecoration(
                  color: GameColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GameRadii.button),
                  border: Border.all(
                    color: GameColors.danger.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GameColors.danger),
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
            ],
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
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.tier});

  final PlayerProfile profile;
  final RankTier tier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GameRadii.panel),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [GameColors.surfaceRaised, GameColors.surface],
        ),
        border: Border.all(color: GameColors.surfaceStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GameColors.background,
              border: Border.all(color: GameColors.accent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: GameColors.accent.withValues(alpha: 0.14),
                  blurRadius: 22,
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, size: 44),
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: GameSpacing.sm),
                RankBadge(tier: tier),
                const SizedBox(height: GameSpacing.sm),
                Wrap(
                  spacing: GameSpacing.md,
                  runSpacing: GameSpacing.xs,
                  children: [
                    Text(
                      l10n.levelWithValue(profile.level),
                      style: const TextStyle(color: GameColors.muted),
                    ),
                    Text(
                      l10n.rpWithValue(profile.rankPoints),
                      style: const TextStyle(color: GameColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Column(
            children: [
              const Icon(
                Icons.star_rounded,
                color: GameColors.rewardGold,
                size: 28,
              ),
              Text(
                '${profile.stars}',
                style: const TextStyle(
                  color: GameColors.rewardGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: GameColors.surfaceStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                trailing,
                style: const TextStyle(
                  color: GameColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
        border: Border.all(
          color: GameColors.success.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        l10n.levelWithValue(level),
        style: const TextStyle(
          color: GameColors.success,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: GameSpacing.md,
        horizontal: GameSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: GameColors.surfaceStrong),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor ?? GameColors.accent),
          const SizedBox(height: GameSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: GameColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
