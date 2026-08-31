import 'package:flutter/material.dart';

import '../../../core/theme/arena_copy.dart';
import '../../../core/theme/arena_ui.dart';
import '../../../core/theme/design_tokens.dart';
import '../../economy/presentation/avatar_artwork.dart';

class ArenaVersusStage extends StatelessWidget {
  const ArenaVersusStage({
    super.key,
    required this.myName,
    required this.myAvatarId,
    required this.myReady,
    required this.opponentName,
    required this.opponentAvatarId,
    required this.opponentReady,
    required this.gameCount,
    required this.ranked,
    this.countdown,
  });

  final String myName;
  final String myAvatarId;
  final bool myReady;
  final String opponentName;
  final String opponentAvatarId;
  final bool opponentReady;
  final int gameCount;
  final bool ranked;
  final int? countdown;

  @override
  Widget build(BuildContext context) {
    final copy = ArenaCopy.of(context);
    final starting = countdown != null;
    return ArenaCard(
      accent: starting ? GameColors.success : GameColors.violet,
      glow: starting,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ArenaPill(
                label: ranked ? copy.rankedArena : copy.quickMatch,
                icon: ranked ? Icons.military_tech_rounded : Icons.flash_on_rounded,
                color: ranked ? GameColors.warning : GameColors.accentBright,
                solid: true,
              ),
              const SizedBox(width: 7),
              ArenaPill(
                label: copy.gamesCount(gameCount),
                icon: Icons.sports_esports_rounded,
                color: GameColors.violet,
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _Fighter(
                  name: myName,
                  avatarId: myAvatarId,
                  label: copy.you,
                  ready: myReady,
                  color: GameColors.accentBright,
                ),
              ),
              const SizedBox(width: 8),
              _VersusCore(countdown: countdown),
              const SizedBox(width: 8),
              Expanded(
                child: _Fighter(
                  name: opponentName,
                  avatarId: opponentAvatarId,
                  label: copy.rival,
                  ready: opponentReady,
                  color: GameColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.lg),
          AnimatedSwitcher(
            duration: GameDurations.normal,
            child: starting
                ? Column(
                    key: ValueKey('countdown-$countdown'),
                    children: [
                      Text(
                        copy.matchStarts,
                        style: const TextStyle(color: GameColors.muted, fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        countdown == 0 ? 'GO!' : '${countdown ?? 3}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: countdown == 0 ? GameColors.success : GameColors.textStrong,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.8,
                            ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('ready-state'),
                    children: [
                      Expanded(child: _ReadyMeter(ready: myReady, label: myReady ? copy.locked : copy.waiting, color: GameColors.accentBright)),
                      const SizedBox(width: 8),
                      Expanded(child: _ReadyMeter(ready: opponentReady, label: opponentReady ? copy.locked : copy.waiting, color: GameColors.warning)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Fighter extends StatelessWidget {
  const _Fighter({
    required this.name,
    required this.avatarId,
    required this.label,
    required this.ready,
    required this.color,
  });

  final String name;
  final String avatarId;
  final String label;
  final bool ready;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: GameDurations.normal,
          width: 84,
          height: 84,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: ready ? .28 : .08),
            border: Border.all(color: color.withValues(alpha: ready ? .82 : .24), width: ready ? 2.4 : 1.2),
            boxShadow: ready ? [BoxShadow(color: color.withValues(alpha: .18), blurRadius: 26)] : null,
          ),
          child: ClipOval(
            child: ColoredBox(
              color: GameColors.surface,
              child: AvatarArtwork(avatarId: avatarId, size: 78, borderRadius: 39),
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _VersusCore extends StatelessWidget {
  const _VersusCore({required this.countdown});
  final int? countdown;

  @override
  Widget build(BuildContext context) {
    final text = countdown == null ? 'VS' : (countdown == 0 ? 'GO' : '$countdown');
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: countdown == null
            ? const LinearGradient(colors: [Color(0xFF263554), Color(0xFF141C33)])
            : GameColors.cosmicGradient,
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        boxShadow: countdown == null ? null : GameShadows.primaryGlow,
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: .5)),
    );
  }
}

class _ReadyMeter extends StatelessWidget {
  const _ReadyMeter({required this.ready, required this.label, required this.color});
  final bool ready;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: ready ? .11 : .035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: ready ? .28 : .10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(ready ? Icons.lock_rounded : Icons.hourglass_top_rounded, color: ready ? color : GameColors.muted, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ready ? color : GameColors.muted, fontSize: 8, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
