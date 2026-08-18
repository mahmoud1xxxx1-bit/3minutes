import 'package:flutter/material.dart';

class GameColors {
  const GameColors._();

  static const background = Color(0xFF101214);
  static const surface = Color(0xFF1A1D20);
  static const surfaceRaised = Color(0xFF23272B);
  static const accent = Color(0xFFF0C75E);
  static const success = Color(0xFF6BD89A);
  static const danger = Color(0xFFFF6B6B);
  static const muted = Color(0xFF9AA3AB);
}

class GameSpacing {
  const GameSpacing._();

  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class GameRadii {
  const GameRadii._();

  static const double button = 12;
  static const double card = 14;
  static const double panel = 18;
}

class GameDurations {
  const GameDurations._();

  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 220);
}
