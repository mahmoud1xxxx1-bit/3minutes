export 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

class GameColors {
  const GameColors._();

  // 3 Minutes Competitive Premium: dark arena surfaces, gold for stakes and
  // rewards, cyan/violet for navigation and secondary competitive energy.
  static const background = Color(0xFF050817);
  static const backgroundDeep = Color(0xFF01030C);
  static const surface = Color(0xFF0A1229);
  static const surfaceRaised = Color(0xFF101C3B);
  static const surfaceStrong = Color(0xFF20345A);
  static const surfaceGlass = Color(0xE60A132A);

  static const accent = Color(0xFF19DCE8);
  static const accentBright = Color(0xFF63F4F4);
  static const accentSoft = Color(0xFF123B52);
  static const violet = Color(0xFF7657F6);
  static const violetSoft = Color(0xFF2A1F5C);
  static const cosmicPink = Color(0xFFD454E8);

  static const success = Color(0xFF4DDA9A);
  static const danger = Color(0xFFFF5F75);
  static const warning = Color(0xFFFFB85A);
  static const rewardGold = Color(0xFFFFC83D);
  static const rewardGoldBright = Color(0xFFFFE28A);
  static const wagerGold = Color(0xFFFFB91C);
  static const coin = Color(0xFFFFD66B);
  static const rp = Color(0xFF73C8FF);
  static const muted = Color(0xFF8293B2);
  static const textStrong = Color(0xFFF8FAFF);
  static const textSoft = Color(0xFFC4CEE0);

  static const rankBronze = Color(0xFFC38354);
  static const rankSilver = Color(0xFFBCC8D6);
  static const rankGold = Color(0xFFFFCC5C);
  static const rankPlatinum = Color(0xFF61D5D0);
  static const rankDiamond = Color(0xFF6AA8FF);
  static const rankMaster = Color(0xFFC37BFF);
  static const rankGrandmaster = Color(0xFFFF667E);
  static const rankLegend = Color(0xFFFFD86B);

  static const rarityCommon = Color(0xFFB8C2D0);
  static const rarityRare = Color(0xFF5EA8FF);
  static const rarityEpic = Color(0xFFB46CFF);
  static const rarityLegendary = Color(0xFFFFC857);
  static const rarityMythic = Color(0xFFFF718F);

  static const cosmicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16D9E6), Color(0xFF6D5AF4), Color(0xFFC84FE0)],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE48A), Color(0xFFFFB51E), Color(0xFFB96700)],
  );

  static const arenaGradient = RadialGradient(
    center: Alignment(0, -.45),
    radius: 1.1,
    colors: [Color(0xFF18295C), Color(0xFF080E23), Color(0xFF01030C)],
  );

  static const cosmicBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1837), Color(0xFF050817), Color(0xFF01030C)],
  );
}

class GameSpacing {
  const GameSpacing._();
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 44;
}

class GameRadii {
  const GameRadii._();
  static const double button = 16;
  static const double card = 18;
  static const double panel = 24;
  static const double pill = 999;
}

class GameDurations {
  const GameDurations._();
  static const fast = Duration(milliseconds: 100);
  static const normal = Duration(milliseconds: 190);
  static const reveal = Duration(milliseconds: 650);
  static const rankUp = Duration(milliseconds: 1050);
}

class GameShadows {
  const GameShadows._();
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x2600CFE0), blurRadius: 18, offset: Offset(0, 7)),
  ];
  static const primaryGlow = <BoxShadow>[
    BoxShadow(color: Color(0x4D19DCE8), blurRadius: 22),
    BoxShadow(color: Color(0x267957F5), blurRadius: 34),
  ];
  static const goldGlow = <BoxShadow>[
    BoxShadow(color: Color(0x66FFB91C), blurRadius: 22),
    BoxShadow(color: Color(0x33FFE28A), blurRadius: 42),
  ];
}
