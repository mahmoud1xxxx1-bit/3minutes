import 'package:flutter/material.dart';

import '../../../core/audio/game_audio_controller.dart';
import '../../../core/settings/game_settings_controller.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/game_glyphs.dart';
import '../../auth/data/auth_service.dart';

Future<bool> confirmSignOut(BuildContext context) async {
  final ar = Localizations.localeOf(context).languageCode == 'ar';
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(ar ? 'مغادرة الساحة؟' : 'LEAVE THE ARENA?'),
          content: Text(
            ar
                ? 'هل تريد تسجيل الخروج من حساب 3 Minutes؟'
                : 'Do you want to sign out of your 3 Minutes account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(ar ? 'البقاء' : 'STAY'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(ar ? 'تسجيل الخروج' : 'SIGN OUT'),
            ),
          ],
        ),
      ) ??
      false;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final settings = GameSettingsController.instance;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: Row(
          children: [
            const GameGlyph(
              type: GameGlyphType.settings,
              size: 24,
              color: GameColors.accentBright,
              active: true,
            ),
            const SizedBox(width: 10),
            Text(
              ar ? 'إعدادات الساحة' : 'ARENA SETTINGS',
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5),
            ),
          ],
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
                _Hero(
                  ar: ar,
                  music: settings.musicMuted ? 0 : settings.musicVolume,
                  sfx: settings.sfxMuted ? 0 : settings.sfxVolume,
                ),
                const SizedBox(height: GameSpacing.lg),
                _SectionTitle(
                  glyph: GameGlyphType.settings,
                  title: ar ? 'الصوت والموسيقى' : 'AUDIO CONTROL',
                  subtitle: ar
                      ? 'خصص صوت التجربة دون التأثير على اللعب التنافسي.'
                      : 'Tune the experience without affecting competitive play.',
                ),
                const SizedBox(height: GameSpacing.sm),
                ArenaCard(
                  accent: GameColors.accentBright,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _VolumeControl(
                        title: ar ? 'موسيقى اللعبة' : 'GAME MUSIC',
                        subtitle: ar
                            ? 'موسيقى القوائم والتركيز أثناء المواجهات.'
                            : 'Menu ambience and focused battle music.',
                        value: settings.musicVolume,
                        muted: settings.musicMuted,
                        accent: GameColors.violet,
                        onChanged: settings.setMusicVolume,
                        onMuteChanged: settings.setMusicMuted,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: GameSpacing.md),
                        child: Divider(height: 1),
                      ),
                      _VolumeControl(
                        title: ar ? 'المؤثرات الصوتية' : 'SOUND EFFECTS',
                        subtitle: ar
                            ? 'أصوات المواجهة والمكافآت والتفاعل.'
                            : 'Battle, reward and interface feedback.',
                        value: settings.sfxVolume,
                        muted: settings.sfxMuted,
                        accent: GameColors.accentBright,
                        onChanged: settings.setSfxVolume,
                        onMuteChanged: settings.setSfxMuted,
                      ),
                      const SizedBox(height: GameSpacing.md),
                      _ArenaAction(
                        label: ar ? 'اختبار صوت المكافأة' : 'TEST REWARD SOUND',
                        glyph: GameGlyphType.rewards,
                        color: GameColors.rewardGold,
                        enabled: !settings.sfxMuted,
                        onTap: () => GameAudioController.instance.playSfx(GameSfx.reward),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GameSpacing.lg),
                _SectionTitle(
                  glyph: GameGlyphType.shield,
                  title: ar ? 'نزاهة التجربة' : 'FAIR PLAY EXPERIENCE',
                  subtitle: ar
                      ? 'الصوت والمرئيات تجميلية ولا تغير التوقيت أو النتيجة.'
                      : 'Audio and visuals are cosmetic and never alter timing or results.',
                ),
                const SizedBox(height: GameSpacing.sm),
                ArenaCard(
                  accent: GameColors.success,
                  child: Row(
                    children: [
                      const _GlyphPlate(
                        glyph: GameGlyphType.shield,
                        color: GameColors.success,
                      ),
                      const SizedBox(width: GameSpacing.md),
                      Expanded(
                        child: Text(
                          ar
                              ? 'تُحفظ تفضيلاتك على هذا الجهاز وتُطبق فورًا. نتيجة المباراة تبقى تحت سلطة نظام اللعب فقط.'
                              : 'Preferences are stored on this device and apply instantly. Match outcome remains controlled only by the gameplay authority.',
                          style: const TextStyle(color: GameColors.textSoft, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GameSpacing.lg),
                _SectionTitle(
                  glyph: GameGlyphType.identity,
                  title: ar ? 'الحساب' : 'ACCOUNT',
                  subtitle: ar
                      ? 'إدارة جلسة اللاعب الحالية.'
                      : 'Manage your current player session.',
                ),
                const SizedBox(height: GameSpacing.sm),
                ArenaCard(
                  accent: GameColors.danger,
                  child: _ArenaAction(
                    label: ar ? 'تسجيل الخروج' : 'SIGN OUT',
                    glyph: GameGlyphType.identity,
                    color: GameColors.danger,
                    onTap: () async {
                      if (!await confirmSignOut(context) || !context.mounted) return;
                      await GameAudioController.instance.stopMusic();
                      await authService.signOut();
                    },
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

class _Hero extends StatelessWidget {
  const _Hero({required this.ar, required this.music, required this.sfx});
  final bool ar;
  final double music;
  final double sfx;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152D55), Color(0xFF1B2046), Color(0xFF09152C)],
        ),
        border: Border.all(color: GameColors.violet.withValues(alpha: .34)),
        boxShadow: const [BoxShadow(color: Color(0x332B72FF), blurRadius: 28)],
      ),
      child: Row(
        children: [
          const _GlyphPlate(
            glyph: GameGlyphType.settings,
            color: GameColors.accentBright,
            large: true,
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar ? 'اضبط تجربتك' : 'TUNE YOUR ARENA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  ar
                      ? 'صوت واضح، واجهة مركزة، ولا أي تأثير على عدالة المنافسة.'
                      : 'Clear sound, focused interface, zero effect on competitive fairness.',
                  style: const TextStyle(color: GameColors.textSoft, fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ArenaPill(label: '${(music * 100).round()}%', color: GameColors.violet),
                    const SizedBox(width: 6),
                    ArenaPill(label: '${(sfx * 100).round()}%', color: GameColors.accentBright),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.glyph, required this.title, required this.subtitle});
  final GameGlyphType glyph;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => ArenaSectionTitle(
        title: title,
        subtitle: subtitle,
        trailing: GameGlyph(
          type: glyph,
          size: 25,
          color: GameColors.accentBright,
        ),
      );
}

class _GlyphPlate extends StatelessWidget {
  const _GlyphPlate({required this.glyph, required this.color, this.large = false});
  final GameGlyphType glyph;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final side = large ? 62.0 : 46.0;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: .20), color.withValues(alpha: .06)],
        ),
        borderRadius: BorderRadius.circular(large ? 20 : 15),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      alignment: Alignment.center,
      child: GameGlyph(
        type: glyph,
        size: large ? 31 : 23,
        color: color,
        active: true,
      ),
    );
  }
}

class _ArenaAction extends StatelessWidget {
  const _ArenaAction({
    required this.label,
    required this.glyph,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final GameGlyphType glyph;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final actual = enabled ? color : GameColors.muted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              GameGlyph(type: glyph, size: 24, color: actual, active: enabled),
              const SizedBox(width: GameSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: actual, fontWeight: FontWeight.w900, letterSpacing: .3),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: actual.withValues(alpha: .10),
                ),
                alignment: Alignment.center,
                child: Text('›', style: TextStyle(color: actual, fontSize: 20, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.muted,
    required this.accent,
    required this.onChanged,
    required this.onMuteChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final bool muted;
  final Color accent;
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
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: accent.withValues(alpha: .18)),
              ),
              alignment: Alignment.center,
              child: GameGlyph(
                type: GameGlyphType.settings,
                size: 21,
                color: muted ? GameColors.muted : accent,
              ),
            ),
            const SizedBox(width: GameSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: GameColors.muted, fontSize: 11, height: 1.35),
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
            Expanded(
              child: Slider(
                value: value,
                onChanged: muted ? null : onChanged,
                activeColor: accent,
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                muted ? 'OFF' : '${(value * 100).round()}%',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: muted ? GameColors.muted : accent,
                  fontWeight: FontWeight.w900,
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
