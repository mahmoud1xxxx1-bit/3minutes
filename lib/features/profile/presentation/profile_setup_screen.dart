import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/profile_repository.dart';
import '../domain/player_name_rules.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    required this.uid,
    required this.profileRepository,
  });

  final String uid;
  final ProfileRepository profileRepository;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  bool _saving = false;
  String _avatarId = 'default_01';
  String? _error;

  static const _avatars = <String>[
    'default_01',
    'default_02',
    'default_03',
    'default_04',
  ];

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
      await widget.profileRepository.createProfile(
        uid: widget.uid,
        gameName: PlayerNameRules.normalize(_nameController.text),
        avatarId: _avatarId,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = AppLocalizations.of(context).couldNotCreateProfile);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.createProfile,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GameSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(GameSpacing.lg),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(GameRadii.panel),
                border: Border.all(color: GameColors.surfaceStrong),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.choosePlayerName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: GameSpacing.md),
                  TextField(
                    controller: _nameController,
                    enabled: !_saving,
                    maxLength: PlayerNameRules.maxLength,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    decoration: InputDecoration(
                      hintText: l10n.playerNameHelp,
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GameSpacing.md),
            Container(
              padding: const EdgeInsets.all(GameSpacing.lg),
              decoration: BoxDecoration(
                color: GameColors.surface,
                borderRadius: BorderRadius.circular(GameRadii.panel),
                border: Border.all(color: GameColors.surfaceStrong),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.chooseAvatar,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: GameSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: GameSpacing.md,
                    runSpacing: GameSpacing.md,
                    children: _avatars.map((avatarId) {
                      final selected = avatarId == _avatarId;
                      final number = _avatars.indexOf(avatarId) + 1;
                      return InkWell(
                        onTap: _saving
                            ? null
                            : () => setState(() => _avatarId = avatarId),
                        borderRadius: BorderRadius.circular(42),
                        child: AnimatedContainer(
                          duration: GameDurations.fast,
                          width: 66,
                          height: 66,
                          alignment: Alignment.center,
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
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: GameColors.accent.withValues(alpha: 0.12),
                                      blurRadius: 16,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            '$number',
                            style: TextStyle(
                              color: selected
                                  ? GameColors.accent
                                  : GameColors.textStrong,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GameSpacing.xl),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(GameSpacing.md),
                decoration: BoxDecoration(
                  color: GameColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(GameRadii.card),
                  border: Border.all(
                    color: GameColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GameColors.danger),
                ),
              ),
              const SizedBox(height: GameSpacing.md),
            ],
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.continueAction),
            ),
          ],
        ),
      ),
    );
  }
}
