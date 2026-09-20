import 'package:flutter/material.dart';

import '../../../core/audio/game_audio_controller.dart';
import '../../../core/settings/game_settings_controller.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../auth/data/auth_service.dart';

Future<bool> confirmSignOut(BuildContext context) async {
  final ar = Localizations.localeOf(context).languageCode == 'ar';
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(ar ? 'تسجيل الخروج؟' : 'Sign out?'),
          content: Text(
            ar
                ? 'هل أنت متأكد من تسجيل الخروج من اللعبة؟'
                : 'Are you sure you want to sign out of the game?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(ar ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.logout_rounded),
              label: Text(ar ? 'تسجيل الخروج' : 'Sign out'),
            ),
          ],
        ),
      ) ??
      false;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final settings = GameSettingsController.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          ar ? 'الإعدادات' : 'Settings',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: settings,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(
                GameSpacing.md,
                GameSpacing.sm,
                GameSpacing.md,
                GameSpacing.xl,
              ),
              children: [
                _SectionTitle(
                  icon: Icons.graphic_eq_rounded,
                  title: ar ? 'الصوت والموسيقى' : 'Audio',
                ),
                const SizedBox(height: GameSpacing.sm),
                CosmicPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _VolumeControl(
                        icon: Icons.music_note_rounded,
                        title: ar ? 'موسيقى اللعبة' : 'Game music',
                        subtitle: ar
                            ? 'موسيقى هادئة في القوائم وموسيقى تركيز أثناء المباراة.'
                            : 'Calm menu ambience and focused in-match music.',
                        value: settings.musicVolume,
                        muted: settings.musicMuted,
                        onChanged: settings.setMusicVolume,
                        onMuteChanged: settings.setMusicMuted,
                      ),
                      const Divider(height: GameSpacing.xl),
                      _VolumeControl(
                        icon: Icons.volume_up_rounded,
                        title: ar ? 'المؤثرات الصوتية' : 'Sound effects',
                        subtitle: ar
                            ? 'أصوات البداية والمكافآت والتفاعل داخل الواجهة.'
                            : 'Match start, reward, and interface feedback sounds.',
                        value: settings.sfxVolume,
                        muted: settings.sfxMuted,
                        onChanged: settings.setSfxVolume,
                        onMuteChanged: settings.setSfxMuted,
                      ),
                      const SizedBox(height: GameSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: settings.sfxMuted
                            ? null
                            : () => GameAudioController.instance.playSfx(
                                  GameSfx.reward,
                                ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          ar ? 'تجربة صوت المؤثرات' : 'Preview sound effect',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GameSpacing.lg),
                _SectionTitle(
                  icon: Icons.info_outline_rounded,
                  title: ar ? 'تجربة اللعب' : 'Game experience',
                ),
                const SizedBox(height: GameSpacing.sm),
                CosmicPanel(
                  child: Text(
                    ar
                        ? 'إعدادات الصوت محفوظة على هذا الجهاز وتُطبق فورًا. الموسيقى والمؤثرات تجميلية فقط ولا تؤثر على توقيت المباراة أو نتيجتها.'
                        : 'Audio preferences are stored on this device and apply immediately. Music and SFX are experiential only and never affect match timing or results.',
                    style: const TextStyle(
                      color: GameColors.textSoft,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: GameSpacing.lg),
                _SectionTitle(
                  icon: Icons.account_circle_rounded,
                  title: ar ? 'الحساب' : 'Account',
                ),
                const SizedBox(height: GameSpacing.sm),
                CosmicPanel(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (!await confirmSignOut(context) || !context.mounted) {
                          return;
                        }
                        await GameAudioController.instance.stopMusic();
                        await authService.signOut();
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: GameColors.danger,
                      ),
                      label: Text(
                        ar ? 'تسجيل الخروج' : 'Sign out',
                        style: const TextStyle(color: GameColors.danger),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: GameColors.accentBright),
          const SizedBox(width: GameSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      );
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.muted,
    required this.onChanged,
    required this.onMuteChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final bool muted;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool> onMuteChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: GameColors.accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: GameColors.accentBright),
            ),
            const SizedBox(width: GameSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: GameColors.muted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: !muted, onChanged: (value) => onMuteChanged(!value)),
          ],
        ),
        const SizedBox(height: GameSpacing.sm),
        Row(
          children: [
            const Icon(Icons.volume_mute_rounded, color: GameColors.muted),
            Expanded(
              child: Slider(
                value: value,
                onChanged: muted ? null : onChanged,
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                '${(value * 100).round()}%',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: GameColors.textSoft,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
