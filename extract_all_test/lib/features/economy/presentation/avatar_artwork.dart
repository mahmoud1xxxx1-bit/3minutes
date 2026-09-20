import 'dart:math' as math;

import 'package:flutter/material.dart';

class AvatarArtwork extends StatelessWidget {
  const AvatarArtwork({
    super.key,
    required this.avatarId,
    this.size = 72,
    this.borderRadius = 22,
  });

  final String avatarId;
  final double size;
  final double borderRadius;

  static bool supports(String id) => _specFor(id) != null;

  /// Kept as a compatibility hook for the shell preload gate.
  /// Avatars are now deterministic vector art rendered locally, so there is
  /// no image decoding or network/disk wait before Shop/Profile can paint.
  static Future<void> preloadAll() async {}

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(avatarId);
    if (spec == null) {
      return SizedBox.square(
        dimension: size,
        child: const Icon(Icons.person_rounded),
      );
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _AvatarPortraitPainter(spec),
          ),
        ),
      ),
    );
  }

  static _AvatarSpec? _specFor(String id) {
    const freeIds = <String>[
      'avatar_free_vanguard',
      'avatar_free_arena',
      'avatar_free_hacker',
      'avatar_free_phantom',
      'avatar_free_warden',
    ];
    final free = freeIds.indexOf(id);
    if (free >= 0) {
      return _AvatarSpec(index: free, tier: _AvatarTier.free);
    }

    final coin = _numberedIndex(id, 'avatar_coin_', 20);
    if (coin != null) {
      return _AvatarSpec(index: 5 + coin, tier: _AvatarTier.coins);
    }

    final premium = _numberedIndex(id, 'avatar_premium_', 10);
    if (premium != null) {
      return _AvatarSpec(index: 25 + premium, tier: _AvatarTier.premium);
    }

    final stars = _numberedIndex(id, 'avatar_star_', 5);
    if (stars != null) {
      return _AvatarSpec(index: 35 + stars, tier: _AvatarTier.stars);
    }

    final exclusive = _numberedIndex(id, 'avatar_exclusive_', 5);
    if (exclusive != null) {
      return _AvatarSpec(index: 40 + exclusive, tier: _AvatarTier.exclusive);
    }
    return null;
  }

  static int? _numberedIndex(String id, String prefix, int count) {
    if (!id.startsWith(prefix)) return null;
    final value = int.tryParse(id.substring(prefix.length));
    if (value == null || value < 1 || value > count) return null;
    return value - 1;
  }
}

enum _AvatarTier { free, coins, premium, stars, exclusive }

class _AvatarSpec {
  const _AvatarSpec({required this.index, required this.tier});

  final int index;
  final _AvatarTier tier;
}

class _AvatarPortraitPainter extends CustomPainter {
  const _AvatarPortraitPainter(this.spec);

  final _AvatarSpec spec;

  static const _skinTones = <Color>[
    Color(0xFFF2C7A5),
    Color(0xFFD9A47F),
    Color(0xFFB97755),
    Color(0xFF8B543C),
    Color(0xFFF0B98F),
    Color(0xFFC98B69),
    Color(0xFF704434),
    Color(0xFFE5AD88),
  ];

  static const _hairTones = <Color>[
    Color(0xFF16121F),
    Color(0xFF2A1932),
    Color(0xFF5A2934),
    Color(0xFF12344D),
    Color(0xFF613B1C),
    Color(0xFFD7C0A2),
    Color(0xFF70254E),
    Color(0xFF26304B),
    Color(0xFF8D5C2F),
    Color(0xFFE6E1DD),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 1024;
    canvas.save();
    canvas.scale(scale, scale);

    final i = spec.index;
    final accent = _accentFor(i, spec.tier);
    final accent2 = _accentFor(i + 11, spec.tier);
    final skin = _skinTones[(i * 3 + 1) % _skinTones.length];
    final hair = _hairTones[(i * 5 + 2) % _hairTones.length];
    final faceWidth = 236.0 + ((i % 5) - 2) * 8;
    final faceHeight = 302.0 + ((i % 4) - 1.5) * 8;
    final helmet = i % 4 == 0 ||
        (spec.tier == _AvatarTier.stars && i.isEven) ||
        (spec.tier == _AvatarTier.exclusive && i.isEven);
    final premiumAura = spec.tier == _AvatarTier.premium ||
        spec.tier == _AvatarTier.stars ||
        spec.tier == _AvatarTier.exclusive;

    _paintBackdrop(canvas, accent, accent2, premiumAura);
    _paintParticles(canvas, accent, accent2, i);
    _paintShoulders(canvas, accent, accent2, i);
    _paintNeck(canvas, skin);
    _paintFace(canvas, skin, faceWidth, faceHeight);
    if (helmet) {
      _paintHelmet(canvas, accent, accent2, i, faceWidth);
    } else {
      _paintHair(canvas, hair, accent, i, faceWidth);
    }
    _paintFeatures(canvas, accent, accent2, skin, i);
    _paintAccessories(canvas, accent, accent2, i);
    _paintChestEmblem(canvas, accent, accent2, i);
    if (spec.tier == _AvatarTier.exclusive && (i == 41 || i == 44)) {
      _paintCrown(canvas, accent, accent2);
    }

    canvas.restore();
  }

  Color _accentFor(int index, _AvatarTier tier) {
    final base = switch (tier) {
      _AvatarTier.free => 188.0,
      _AvatarTier.coins => 216.0,
      _AvatarTier.premium => 316.0,
      _AvatarTier.stars => 266.0,
      _AvatarTier.exclusive => 18.0,
    };
    final hue = (base + (index * 31)) % 360;
    final lightness = switch (tier) {
      _AvatarTier.free => .58,
      _AvatarTier.coins => .61,
      _AvatarTier.premium => .66,
      _AvatarTier.stars => .69,
      _AvatarTier.exclusive => .64,
    };
    return HSLColor.fromAHSL(1, hue, .88, lightness).toColor();
  }

  void _paintBackdrop(
    Canvas canvas,
    Color accent,
    Color accent2,
    bool premiumAura,
  ) {
    final haloRect = Rect.fromCircle(
      center: const Offset(512, 470),
      radius: premiumAura ? 355 : 310,
    );
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: premiumAura ? .62 : .42),
          accent2.withValues(alpha: .24),
          const Color(0x00101832),
        ],
        stops: const [0, .56, 1],
      ).createShader(haloRect);
    canvas.drawCircle(const Offset(512, 470), premiumAura ? 355 : 310, halo);

    if (!premiumAura) return;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = accent.withValues(alpha: .48);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(512, 470), width: 690, height: 520),
      ring,
    );
    ring
      ..strokeWidth = 4
      ..color = accent2.withValues(alpha: .34);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(512, 470), width: 560, height: 690),
      ring,
    );
  }

  void _paintParticles(Canvas canvas, Color accent, Color accent2, int seed) {
    for (var n = 0; n < 13; n++) {
      final angle = (seed * .73) + n * 2.399;
      final radius = 220 + ((seed * 31 + n * 67) % 245).toDouble();
      final center = Offset(
        512 + math.cos(angle) * radius,
        470 + math.sin(angle) * radius * .82,
      );
      final r = 3.0 + ((seed + n * 3) % 8);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = (n.isEven ? accent : accent2)
              .withValues(alpha: .18 + (n % 4) * .09),
      );
    }
  }

  void _paintShoulders(Canvas canvas, Color accent, Color accent2, int i) {
    final body = Path()
      ..moveTo(126, 1024)
      ..cubicTo(170, 832, 300, 742, 404, 704)
      ..cubicTo(452, 686, 478, 680, 512, 680)
      ..cubicTo(550, 680, 582, 690, 626, 706)
      ..cubicTo(734, 748, 856, 838, 900, 1024)
      ..close();
    final bodyBounds = body.getBounds();
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: .78),
            const Color(0xFF111932),
            const Color(0xFF070B1D),
            accent2.withValues(alpha: .55),
          ],
          stops: const [0, .28, .74, 1],
        ).createShader(bodyBounds),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = accent.withValues(alpha: .8),
    );

    final collar = Path()
      ..moveTo(338, 754)
      ..lineTo(434, 680)
      ..lineTo(512, 738)
      ..lineTo(590, 680)
      ..lineTo(688, 754)
      ..lineTo(620, 836)
      ..lineTo(512, 794)
      ..lineTo(404, 836)
      ..close();
    canvas.drawPath(collar, Paint()..color = const Color(0xEF090F25));
    canvas.drawPath(
      collar,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = (i.isEven ? accent : accent2),
    );

    for (var panel = 0; panel < 3; panel++) {
      final x = 240.0 + panel * 260;
      canvas.drawLine(
        Offset(x, 858),
        Offset(x + (panel == 1 ? 0 : panel == 0 ? -52 : 52), 1004),
        Paint()
          ..strokeWidth = 5
          ..color = accent2.withValues(alpha: .24),
      );
    }
  }

  void _paintNeck(Canvas canvas, Color skin) {
    final neck = Path()
      ..moveTo(442, 642)
      ..cubicTo(454, 610, 458, 582, 457, 548)
      ..lineTo(567, 548)
      ..cubicTo(565, 588, 571, 615, 584, 650)
      ..cubicTo(558, 680, 535, 696, 512, 699)
      ..cubicTo(485, 696, 462, 679, 442, 642)
      ..close();
    canvas.drawPath(
      neck,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [skin, Color.lerp(skin, const Color(0xFF5F2C37), .42)!],
        ).createShader(neck.getBounds()),
    );
  }

  void _paintFace(Canvas canvas, Color skin, double width, double height) {
    final rect = Rect.fromCenter(
      center: const Offset(512, 432),
      width: width,
      height: height,
    );
    final facePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(skin, Colors.white, .16)!,
          skin,
          Color.lerp(skin, const Color(0xFF6A3242), .28)!,
        ],
        stops: const [0, .52, 1],
      ).createShader(rect);
    canvas.drawOval(rect, facePaint);

    final shadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 17
      ..color = const Color(0x553E1F39);
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(478, 488), width: 128, height: 190),
      .35,
      1.15,
      false,
      shadow,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(552, 486), width: 118, height: 184),
      1.66,
      1.05,
      false,
      shadow..color = const Color(0x3A14233B),
    );
  }

  void _paintHelmet(
    Canvas canvas,
    Color accent,
    Color accent2,
    int i,
    double faceWidth,
  ) {
    final left = 512 - faceWidth / 2;
    final right = 512 + faceWidth / 2;
    final shell = Path()
      ..moveTo(left - 40, 364)
      ..cubicTo(left - 6, 210, 408, 128, 512, 126)
      ..cubicTo(624, 128, right + 10, 220, right + 42, 368)
      ..lineTo(right + 5, 492)
      ..lineTo(right - 38, 344)
      ..quadraticBezierTo(512, 246, left + 38, 344)
      ..lineTo(left - 5, 492)
      ..close();
    canvas.drawPath(shell, Paint()..color = const Color(0xFF091027));
    canvas.drawPath(
      shell,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = accent,
    );

    final crest = Path()
      ..moveTo(404, 230)
      ..lineTo(456, 144)
      ..lineTo(512, 202)
      ..lineTo(572, 140)
      ..lineTo(624, 230);
    canvas.drawPath(
      crest,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeJoin = StrokeJoin.miter
        ..color = accent2,
    );

    if (i % 3 == 1) {
      final visor = Path()
        ..moveTo(398, 396)
        ..quadraticBezierTo(512, 342, 626, 396)
        ..lineTo(608, 458)
        ..quadraticBezierTo(512, 428, 416, 458)
        ..close();
      canvas.drawPath(visor, Paint()..color = accent.withValues(alpha: .33));
      canvas.drawPath(
        visor,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..color = accent2.withValues(alpha: .82),
      );
    }
  }

  void _paintHair(Canvas canvas, Color hair, Color accent, int i, double faceWidth) {
    final left = 512 - faceWidth / 2;
    final right = 512 + faceWidth / 2;
    final style = i % 5;
    final path = Path();
    switch (style) {
      case 0:
        path
          ..moveTo(left - 30, 375)
          ..cubicTo(left, 188, 416, 126, 520, 134)
          ..cubicTo(630, 144, right + 36, 254, right + 22, 382)
          ..cubicTo(616, 278, 522, 316, left + 10, 396)
          ..close();
      case 1:
        path
          ..moveTo(left - 28, 382)
          ..cubicTo(left + 4, 182, 460, 118, 566, 146)
          ..cubicTo(656, 170, right + 36, 276, right + 16, 515)
          ..cubicTo(628, 418, 590, 340, 548, 292)
          ..cubicTo(478, 346, 420, 410, left + 6, 510)
          ..close();
      case 2:
        path
          ..moveTo(left - 25, 380)
          ..quadraticBezierTo(382, 138, 522, 126)
          ..quadraticBezierTo(664, 152, right + 28, 382)
          ..quadraticBezierTo(584, 286, left + 4, 390)
          ..close();
      case 3:
        path
          ..moveTo(left - 24, 384)
          ..quadraticBezierTo(392, 120, 530, 128)
          ..quadraticBezierTo(670, 150, right + 30, 386)
          ..quadraticBezierTo(520, 270, left + 4, 390)
          ..close();
      case _:
        path
          ..moveTo(left - 28, 380)
          ..cubicTo(left + 8, 190, 448, 104, 588, 150)
          ..cubicTo(662, 176, right + 32, 272, right + 16, 384)
          ..quadraticBezierTo(520, 254, left + 8, 390)
          ..close();
    }

    final bounds = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [hair, Color.lerp(hair, accent, .36)!],
        ).createShader(bounds),
    );

    final strand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6
      ..color = Color.lerp(hair, Colors.white, .28)!.withValues(alpha: .42);
    for (var n = 0; n < 6; n++) {
      final sx = 414.0 + n * 38;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(sx, 286 + (n % 2) * 20), width: 96, height: 182),
        3.6,
        1.2,
        false,
        strand,
      );
    }

    if (style == 1) {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(650, 510), width: 120, height: 350),
        4.5,
        2.1,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 48
          ..color = hair,
      );
    }
  }

  void _paintFeatures(
    Canvas canvas,
    Color accent,
    Color accent2,
    Color skin,
    int i,
  ) {
    final brow = Paint()
      ..color = Color.lerp(const Color(0xFF241421), skin, .18)!
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(456, 397), width: 82, height: 34),
      3.5,
      2.2,
      false,
      brow,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(568, 397), width: 82, height: 34),
      3.5,
      2.2,
      false,
      brow,
    );

    _paintEye(canvas, const Offset(460, 438), accent, i.isEven);
    _paintEye(canvas, const Offset(564, 438), accent2, i.isOdd);

    final nose = Path()
      ..moveTo(512, 452)
      ..quadraticBezierTo(495, 514, 515, 536)
      ..quadraticBezierTo(533, 543, 544, 526);
    canvas.drawPath(
      nose,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8
        ..color = const Color(0x80733D48),
    );

    final mouth = Path()
      ..moveTo(458, 584)
      ..quadraticBezierTo(512, 604, 566, 584)
      ..quadraticBezierTo(512, 623, 458, 584)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xAA6B2B49));
    canvas.drawPath(
      Path()
        ..moveTo(474, 586)
        ..quadraticBezierTo(512, 596, 550, 586),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0x99FFD8DE),
    );

    if (i % 7 == 0) {
      canvas.drawLine(
        const Offset(398, 424),
        const Offset(446, 508),
        Paint()
          ..strokeWidth = 8
          ..color = accent2.withValues(alpha: .74),
      );
    } else if (i % 5 == 2) {
      final mark = Path()
        ..moveTo(620, 470)
        ..lineTo(650, 490)
        ..lineTo(620, 510)
        ..lineTo(648, 531);
      canvas.drawPath(
        mark,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..color = accent.withValues(alpha: .74),
      );
    }
  }

  void _paintEye(Canvas canvas, Offset center, Color glow, bool bright) {
    final eye = Path()
      ..moveTo(center.dx - 40, center.dy)
      ..quadraticBezierTo(center.dx, center.dy - 24, center.dx + 40, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + 22, center.dx - 40, center.dy)
      ..close();
    canvas.drawPath(eye, Paint()..color = const Color(0xFF07101F));
    canvas.drawPath(
      eye,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0x55FFFFFF),
    );
    canvas.drawCircle(
      center,
      bright ? 11 : 9,
      Paint()..color = glow.withValues(alpha: bright ? 1 : .86),
    );
    canvas.drawCircle(
      Offset(center.dx - 3, center.dy - 3),
      3,
      Paint()..color = Colors.white.withValues(alpha: .9),
    );
  }

  void _paintAccessories(Canvas canvas, Color accent, Color accent2, int i) {
    if (i.isOdd) {
      canvas.drawCircle(
        const Offset(664, 472),
        23,
        Paint()..color = const Color(0xFF091127),
      );
      canvas.drawCircle(
        const Offset(664, 472),
        23,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..color = accent,
      );
      canvas.drawLine(
        const Offset(684, 463),
        const Offset(734, 434),
        Paint()
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = accent2.withValues(alpha: .72),
      );
    }

    if (spec.tier == _AvatarTier.premium ||
        spec.tier == _AvatarTier.stars ||
        spec.tier == _AvatarTier.exclusive) {
      final cheek = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = accent.withValues(alpha: .42);
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(512, 468), width: 330, height: 300),
        .15,
        1.0,
        false,
        cheek,
      );
    }
  }

  void _paintChestEmblem(Canvas canvas, Color accent, Color accent2, int i) {
    final center = const Offset(512, 838);
    if (spec.tier == _AvatarTier.stars || spec.tier == _AvatarTier.exclusive) {
      final star = Path();
      for (var point = 0; point < 10; point++) {
        final angle = -math.pi / 2 + point * math.pi / 5;
        final radius = point.isEven ? 54.0 : 24.0;
        final offset = Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        );
        if (point == 0) {
          star.moveTo(offset.dx, offset.dy);
        } else {
          star.lineTo(offset.dx, offset.dy);
        }
      }
      star.close();
      canvas.drawPath(star, Paint()..color = i.isEven ? accent : accent2);
      canvas.drawPath(
        star,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = const Color(0xFFFFF0B8),
      );
      return;
    }

    canvas.drawCircle(center, 46, Paint()..color = const Color(0xFF081129));
    canvas.drawCircle(
      center,
      46,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = accent,
    );
    final gem = Path()
      ..moveTo(512, 808)
      ..lineTo(542, 838)
      ..lineTo(512, 868)
      ..lineTo(482, 838)
      ..close();
    canvas.drawPath(gem, Paint()..color = accent2);
  }

  void _paintCrown(Canvas canvas, Color accent, Color accent2) {
    final crown = Path()
      ..moveTo(386, 226)
      ..lineTo(430, 118)
      ..lineTo(500, 184)
      ..lineTo(560, 106)
      ..lineTo(632, 190)
      ..lineTo(680, 126)
      ..lineTo(654, 238)
      ..lineTo(392, 238)
      ..close();
    canvas.drawPath(
      crown,
      Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFFFE59A), accent, accent2],
        ).createShader(crown.getBounds()),
    );
    canvas.drawPath(
      crown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = const Color(0xFFFFF2BE),
    );
  }

  @override
  bool shouldRepaint(covariant _AvatarPortraitPainter oldDelegate) {
    return oldDelegate.spec.index != spec.index || oldDelegate.spec.tier != spec.tier;
  }
}
