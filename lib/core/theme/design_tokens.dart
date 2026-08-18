export 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

class GameColors {
  const GameColors._();

  // Core competitive palette. Dark navy-charcoal keeps the game calm while
  // cyan, gold, and rank colors carry the visual energy.
  static const background = Color(0xFF090E17);
  static const surface = Color(0xFF111927);
  static const surfaceRaised = Color(0xFF1A2535);
  static const surfaceStrong = Color(0xFF233147);
  static const accent = Color(0xFF44D7F3);
  static const accentSoft = Color(0xFF14394A);
  static const success = Color(0xFF50D890);
  static const danger = Color(0xFFFF6D78);
  static const warning = Color(0xFFFFB84D);
  static const rewardGold = Color(0xFFFFD166);
  static const muted = Color(0xFF91A0B4);
  static const textStrong = Color(0xFFF5F8FC);

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

  static const double button = 14;
  static const double card = 16;
  static const double panel = 22;
  static const double pill = 999;
}

class GameDurations {
  const GameDurations._();

  static const fast = Duration(milliseconds: 110);
  static const normal = Duration(milliseconds: 200);
  static const reveal = Duration(milliseconds: 700);
  static const rankUp = Duration(milliseconds: 1100);
}
