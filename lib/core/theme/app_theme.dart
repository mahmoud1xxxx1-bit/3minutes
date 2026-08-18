import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: GameColors.accent,
      brightness: Brightness.dark,
      surface: GameColors.surface,
    ).copyWith(
      primary: GameColors.accent,
      error: GameColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: GameColors.background,
      dividerColor: GameColors.surfaceRaised,
      appBarTheme: const AppBarTheme(
        backgroundColor: GameColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameRadii.button),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameRadii.button),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: GameColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GameColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GameRadii.button),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GameRadii.button),
          borderSide: const BorderSide(color: GameColors.surfaceRaised),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GameRadii.button),
          borderSide: const BorderSide(color: GameColors.accent, width: 1.5),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GameColors.accent,
        linearTrackColor: GameColors.surfaceRaised,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GameColors.surfaceRaised,
        selectedColor: GameColors.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameRadii.button),
        ),
      ),
    );
  }
}
