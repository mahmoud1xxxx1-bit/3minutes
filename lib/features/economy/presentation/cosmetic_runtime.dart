import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/cosmetic_item.dart';
import 'avatar_artwork.dart';

Color cosmeticRarityColor(CosmeticRarity rarity) => switch (rarity) {
      CosmeticRarity.common => GameColors.rarityCommon,
      CosmeticRarity.rare => GameColors.rarityRare,
      CosmeticRarity.epic => GameColors.rarityEpic,
      CosmeticRarity.legendary => GameColors.rarityLegendary,
      CosmeticRarity.mythic => GameColors.rarityMythic,
    };

class CosmeticAvatarView extends StatelessWidget {
  const CosmeticAvatarView({
    super.key,
    required this.avatarId,
    this.frameId,
    this.size = 104,
  });

  final String avatarId;
  final String? frameId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final frame = frameId;
    final frameColors = switch (frame) {
      'frame_classic' => const [GameColors.rankSilver, Color(0xFF66758C)],
      'frame_neon' => const [GameColors.accentBright, GameColors.violet],
      'frame_voltage' => const [Color(0xFF86F5FF), Color(0xFF7E58FF), Color(0xFFFFD86B)],
      'frame_prestige' => const [GameColors.rewardGold, Color(0xFFFFF0B0)],
      'frame_elite' => const [Color(0xFFFFD86B), Color(0xFFC37BFF), Color(0xFF6AA8FF)],
      'frame_obsidian' => const [Color(0xFF151827), Color(0xFF7957F5), Color(0xFF05060B)],
      _ => const [GameColors.surfaceStrong, GameColors.accent],
    };
    final premiumFrame = frame != null;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: [...frameColors, frameColors.first]),
          boxShadow: premiumFrame
              ? [
                  BoxShadow(
                    color: frameColors.first.withValues(alpha: .34),
                    blurRadius: size * .18,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(frame == null ? 2 : size * .045),
          child: ClipOval(
            child: AvatarArtwork(
              avatarId: avatarId,
              size: size,
              borderRadius: size,
            ),
          ),
        ),
      ),
    );
  }
}

class CosmeticNameText extends StatelessWidget {
  const CosmeticNameText({
    super.key,
    required this.text,
    this.styleId,
    this.fontSize = 22,
    this.textAlign,
  });

  final String text;
  final String? styleId;
  final double fontSize;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    final style = switch (styleId) {
      'name_bold' => base.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: .4,
          color: GameColors.textStrong,
        ),
      'name_champion' => base.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: GameColors.rewardGold,
          decoration: TextDecoration.underline,
          decorationColor: GameColors.rewardGold,
          decorationThickness: 1.6,
          shadows: const [Shadow(color: Color(0x66FFCD68), blurRadius: 10)],
        ),
      'name_electric' => base.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: GameColors.accentBright,
          letterSpacing: .8,
          shadows: const [
            Shadow(color: Color(0xAA19DCE8), blurRadius: 8),
            Shadow(color: Color(0x887957F5), blurRadius: 14),
          ],
        ),
      'name_royal' => base.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFE39A),
          letterSpacing: 1.1,
          shadows: const [
            Shadow(color: Color(0x99FFCD68), blurRadius: 12),
            Shadow(color: Color(0x667957F5), blurRadius: 18),
          ],
        ),
      _ => base.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: GameColors.textStrong,
        ),
    };
    return Text(text, style: style, textAlign: textAlign, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class CosmeticBadgeView extends StatelessWidget {
  const CosmeticBadgeView({super.key, required this.badgeId, this.size = 42});

  final String badgeId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final crown = badgeId == 'badge_crown';
    final color = crown ? GameColors.rewardGold : GameColors.rankDiamond;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: .34), GameColors.surfaceRaised],
        ),
        border: Border.all(color: color.withValues(alpha: .8), width: 1.5),
        boxShadow: [BoxShadow(color: color.withValues(alpha: .2), blurRadius: 12)],
      ),
      child: crown
          ? Icon(Icons.workspace_premium_rounded, color: color, size: size * .62)
          : Text(
              '3',
              style: TextStyle(color: color, fontSize: size * .52, fontWeight: FontWeight.w900),
            ),
    );
  }
}

class CosmeticProfileBackground extends StatelessWidget {
  const CosmeticProfileBackground({
    super.key,
    required this.backgroundId,
    required this.child,
    this.borderRadius = 24,
  });

  final String? backgroundId;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final decoration = switch (backgroundId) {
      'background_grid' => const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0A1632), Color(0xFF102D4A)]),
        ),
      'background_arena' => const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.25,
            colors: [Color(0xFF392077), Color(0xFF111A38), Color(0xFF050A18)],
          ),
        ),
      'background_constellation' => const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF101C3D), Color(0xFF281B5A), Color(0xFF091123)],
          ),
        ),
      'background_void' => const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(.35, -.25),
            radius: 1.2,
            colors: [Color(0xFF7136B5), Color(0xFF181028), Color(0xFF03050B)],
          ),
        ),
      _ => const BoxDecoration(color: GameColors.surfaceGlass),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: decoration,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (backgroundId == 'background_grid') const Positioned.fill(child: _GridOverlay()),
            if (backgroundId == 'background_constellation')
              const Positioned.fill(child: _StarOverlay(count: 18)),
            if (backgroundId == 'background_void')
              const Positioned.fill(child: _VoidRings()),
            child,
          ],
        ),
      ),
    );
  }
}

class CosmeticRankAura extends StatelessWidget {
  const CosmeticRankAura({
    super.key,
    required this.auraId,
    required this.child,
    this.padding = 12,
  });

  final String? auraId;
  final Widget child;
  final double padding;

  @override
  Widget build(BuildContext context) {
    if (auraId == null) return child;
    final colors = switch (auraId) {
      'aura_storm' => const [Color(0xFF52F2F2), Color(0xFF6AA8FF)],
      'aura_rank_flare' => const [Color(0xFFFFCD68), Color(0xFFFF8D54)],
      'aura_mythic_legacy' => const [Color(0xFFC37BFF), Color(0xFFFFD86B), Color(0xFF6AA8FF)],
      _ => const [GameColors.violet, GameColors.accentBright],
    };
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: [...colors, colors.first]),
        boxShadow: [
          BoxShadow(color: colors.first.withValues(alpha: .28), blurRadius: 22, spreadRadius: 2),
          if (auraId == 'aura_mythic_legacy')
            BoxShadow(color: colors[1].withValues(alpha: .18), blurRadius: 34, spreadRadius: 3),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(shape: BoxShape.circle, color: GameColors.backgroundDeep),
        child: Padding(padding: const EdgeInsets.all(5), child: child),
      ),
    );
  }
}

class CosmeticRoomTheme extends StatelessWidget {
  const CosmeticRoomTheme({
    super.key,
    required this.themeId,
    required this.child,
    this.borderRadius = 24,
  });

  final String? themeId;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (themeId) {
      'room_arcade' => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07152C), Color(0xFF13265F), Color(0xFF3B175B)],
        ),
      'room_cyber_royal' => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF241546), Color(0xFF10182F), Color(0xFF080B18)],
        ),
      _ => const LinearGradient(colors: [GameColors.surface, GameColors.background]),
    };
    final accent = themeId == 'room_cyber_royal' ? GameColors.rewardGold : GameColors.accentBright;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          border: Border.all(color: accent.withValues(alpha: themeId == null ? .18 : .52)),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: themeId == null
              ? null
              : [BoxShadow(color: accent.withValues(alpha: .14), blurRadius: 24)],
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (themeId == 'room_arcade') const Positioned.fill(child: _ArcadeOverlay()),
            if (themeId == 'room_cyber_royal') const Positioned.fill(child: _RoyalOverlay()),
            child,
          ],
        ),
      ),
    );
  }
}

class CosmeticMatchIntro extends StatelessWidget {
  const CosmeticMatchIntro({
    super.key,
    required this.introId,
    required this.playerName,
    required this.opponentName,
    this.height = 220,
  });

  final String introId;
  final String playerName;
  final String opponentName;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = switch (introId) {
      'intro_redline' => GameColors.danger,
      'intro_champion' => GameColors.rewardGold,
      'intro_portal' => GameColors.accentBright,
      _ => GameColors.violet,
    };
    final icon = switch (introId) {
      'intro_redline' => Icons.double_arrow_rounded,
      'intro_champion' => Icons.emoji_events_rounded,
      'intro_portal' => Icons.blur_circular_rounded,
      _ => Icons.flash_on_rounded,
    };
    return SizedBox(
      height: height,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: .26), GameColors.backgroundDeep, GameColors.violetSoft],
          ),
          borderRadius: BorderRadius.circular(GameRadii.panel),
          border: Border.all(color: color.withValues(alpha: .55)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: .17), blurRadius: 28)],
        ),
        child: Stack(
          children: [
            if (introId == 'intro_portal')
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: .7), width: 4),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: .35), blurRadius: 30)],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: Icon(icon, color: color, size: 36),
            ),
            Center(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      playerName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                  Text('VS', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 24)),
                  Expanded(
                    child: Text(
                      opponentName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CosmeticVictoryEffect extends StatelessWidget {
  const CosmeticVictoryEffect({
    super.key,
    required this.effectId,
    required this.winnerName,
    this.height = 220,
  });

  final String effectId;
  final String winnerName;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = switch (effectId) {
      'victory_confetti' => GameColors.cosmicPink,
      'victory_crown_burst' => GameColors.rewardGold,
      'victory_lightning' => GameColors.accentBright,
      _ => GameColors.success,
    };
    final icon = switch (effectId) {
      'victory_confetti' => Icons.celebration_rounded,
      'victory_crown_burst' => Icons.workspace_premium_rounded,
      'victory_lightning' => Icons.bolt_rounded,
      _ => Icons.emoji_events_rounded,
    };
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color.withValues(alpha: .28), GameColors.surface, GameColors.backgroundDeep],
          ),
          borderRadius: BorderRadius.circular(GameRadii.panel),
          border: Border.all(color: color.withValues(alpha: .5)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (effectId == 'victory_confetti') const Positioned.fill(child: _ConfettiOverlay()),
            if (effectId == 'victory_crown_burst') const Positioned.fill(child: _BurstOverlay()),
            if (effectId == 'victory_lightning') const Positioned.fill(child: _LightningOverlay()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 62),
                const SizedBox(height: 10),
                Text(
                  winnerName,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 4),
                const Text('VICTORY', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CosmeticEmoteBubble extends StatelessWidget {
  const CosmeticEmoteBubble({super.key, required this.emoteId, this.compact = false});

  final String emoteId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 18, vertical: compact ? 7 : 12),
      decoration: BoxDecoration(
        color: GameColors.surfaceRaised,
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: GameColors.accentBright.withValues(alpha: .45)),
        boxShadow: GameShadows.card,
      ),
      child: const Text(
        'GG',
        style: TextStyle(color: GameColors.accentBright, fontWeight: FontWeight.w900, fontSize: 18),
      ),
    );
  }
}

class CosmeticAppliedPreview extends StatelessWidget {
  const CosmeticAppliedPreview({
    super.key,
    required this.item,
    this.playerName = 'PLAYER',
    this.opponentName = 'RIVAL',
    this.avatarId = 'avatar_free_vanguard',
  });

  final CosmeticItem item;
  final String playerName;
  final String opponentName;
  final String avatarId;

  @override
  Widget build(BuildContext context) {
    return switch (item.slot) {
      CosmeticSlot.avatar => _IdentityPreview(
          avatarId: item.id,
          playerName: playerName,
        ),
      CosmeticSlot.avatarFrame => _IdentityPreview(
          avatarId: avatarId,
          frameId: item.id,
          playerName: playerName,
        ),
      CosmeticSlot.badge => _IdentityPreview(
          avatarId: avatarId,
          badgeId: item.id,
          playerName: playerName,
        ),
      CosmeticSlot.profileBackground => CosmeticProfileBackground(
          backgroundId: item.id,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _IdentityPreview(avatarId: avatarId, playerName: playerName, transparent: true),
          ),
        ),
      CosmeticSlot.nameStyle => _IdentityPreview(
          avatarId: avatarId,
          nameStyleId: item.id,
          playerName: playerName,
        ),
      CosmeticSlot.matchIntro => CosmeticMatchIntro(
          introId: item.id,
          playerName: playerName,
          opponentName: opponentName,
        ),
      CosmeticSlot.victoryEffect => CosmeticVictoryEffect(
          effectId: item.id,
          winnerName: playerName,
        ),
      CosmeticSlot.rankAura => _RankAuraPreview(auraId: item.id),
      CosmeticSlot.emote => Center(child: CosmeticEmoteBubble(emoteId: item.id)),
      CosmeticSlot.roomTheme => CosmeticRoomTheme(
          themeId: item.id,
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: _RoomMock(),
          ),
        ),
    };
  }
}

class _IdentityPreview extends StatelessWidget {
  const _IdentityPreview({
    required this.avatarId,
    required this.playerName,
    this.frameId,
    this.badgeId,
    this.nameStyleId,
    this.transparent = false,
  });

  final String avatarId;
  final String playerName;
  final String? frameId;
  final String? badgeId;
  final String? nameStyleId;
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: transparent
          ? null
          : BoxDecoration(
              color: GameColors.surfaceGlass,
              borderRadius: BorderRadius.circular(GameRadii.panel),
              border: Border.all(color: GameColors.surfaceStrong),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CosmeticAvatarView(avatarId: avatarId, frameId: frameId, size: 122),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: CosmeticNameText(text: playerName, styleId: nameStyleId, fontSize: 22)),
              if (badgeId != null) ...[
                const SizedBox(width: 8),
                CosmeticBadgeView(badgeId: badgeId!, size: 38),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RankAuraPreview extends StatelessWidget {
  const _RankAuraPreview({required this.auraId});
  final String auraId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CosmeticRankAura(
        auraId: auraId,
        padding: 14,
        child: Container(
          width: 110,
          height: 110,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: GameColors.surface),
          child: const Icon(Icons.military_tech_rounded, size: 58, color: GameColors.rankLegend),
        ),
      ),
    );
  }
}

class _RoomMock extends StatelessWidget {
  const _RoomMock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('PRIVATE ROOM', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 14,
          runSpacing: 14,
          children: List.generate(
            4,
            (index) => Container(
              width: 88,
              height: 72,
              decoration: BoxDecoration(
                color: GameColors.surfaceGlass,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: index == 0 ? GameColors.rewardGold : GameColors.surfaceStrong),
              ),
              child: Icon(index == 0 ? Icons.workspace_premium_rounded : Icons.person_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridOverlayPainter());
}

class _GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = GameColors.accentBright.withValues(alpha: .13)..strokeWidth = 1;
    const step = 28.0;
    for (var x = 0.0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (var y = 0.0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarOverlay extends StatelessWidget {
  const _StarOverlay({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _StarPainter(count));
}

class _StarPainter extends CustomPainter {
  const _StarPainter(this.count);
  final int count;
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint()..color = Colors.white.withValues(alpha: .45);
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), 1 + random.nextDouble() * 1.5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VoidRings extends StatelessWidget {
  const _VoidRings();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _VoidPainter());
}

class _VoidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .72, size.height * .35);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        center,
        45 + i * 24,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = GameColors.violet.withValues(alpha: .12 - i * .015),
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArcadeOverlay extends StatelessWidget {
  const _ArcadeOverlay();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _ArcadePainter());
}

class _ArcadePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = GameColors.cosmicPink.withValues(alpha: .09)..strokeWidth = 2;
    for (var y = 22.0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 16), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoyalOverlay extends StatelessWidget {
  const _RoyalOverlay();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RoyalPainter());
}

class _RoyalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = GameColors.rewardGold.withValues(alpha: .12)..strokeWidth = 1.5;
    final center = Offset(size.width / 2, 0);
    for (var i = 1; i <= 7; i++) {
      canvas.drawLine(center, Offset(size.width * i / 8, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConfettiOverlay extends StatelessWidget {
  const _ConfettiOverlay();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _ConfettiPainter());
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12);
    const colors = [GameColors.accentBright, GameColors.cosmicPink, GameColors.rewardGold, GameColors.success];
    for (var i = 0; i < 34; i++) {
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: .7);
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawRect(Rect.fromCenter(center: p, width: 5, height: 10), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BurstOverlay extends StatelessWidget {
  const _BurstOverlay();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BurstPainter());
}

class _BurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = GameColors.rewardGold.withValues(alpha: .22)..strokeWidth = 2;
    for (var i = 0; i < 18; i++) {
      final angle = i * math.pi * 2 / 18;
      canvas.drawLine(center, center + Offset(math.cos(angle), math.sin(angle)) * math.min(size.width, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LightningOverlay extends StatelessWidget {
  const _LightningOverlay();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _LightningPainter());
}

class _LightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.accentBright.withValues(alpha: .45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    for (var i = 0; i < 5; i++) {
      final x = size.width * (.12 + i * .2);
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x - 16, size.height * .35)
        ..lineTo(x + 7, size.height * .34)
        ..lineTo(x - 8, size.height * .72)
        ..lineTo(x + 18, size.height);
      canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
