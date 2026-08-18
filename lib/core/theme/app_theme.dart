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
      onPrimary: GameColors.background,
      secondary: GameColors.rewardGold,
      onSecondary: GameColors.background,
      surface: GameColors.surface,
      onSurface: GameColors.textStrong,
      error: GameColors.danger,
    );

    final baseTextTheme = ThemeData.dark().textTheme;
    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w900,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w900,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: GameColors.textStrong),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: GameColors.textStrong),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w900,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: GameColors.background,
      dividerColor: GameColors.surfaceStrong,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: GameColors.background,
        foregroundColor: GameColors.textStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: GameColors.accent,
          foregroundColor: GameColors.background,
          disabledBackgroundColor: GameColors.surfaceRaised,
          disabledForegroundColor: GameColors.muted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameRadii.button),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: GameColors.accent,
          side: const BorderSide(color: GameColors.surfaceStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GameRadii.button),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GameColors.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        color: GameColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: GameColors.surfaceStrong),
          borderRadius: BorderRadius.circular(GameRadii.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GameColors.surface,
        labelStyle: const TextStyle(color: GameColors.muted),
        helperStyle: const TextStyle(color: GameColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GameRadii.button),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GameRadii.button),
          borderSide: const BorderSide(color: GameColors.surfaceStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GameRadii.button),
          borderSide: const BorderSide(color: GameColors.accent, width: 1.6),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GameColors.accent,
        linearTrackColor: GameColors.surfaceRaised,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GameColors.surfaceRaised,
        selectedColor: GameColors.accentSoft,
        side: const BorderSide(color: GameColors.surfaceStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameRadii.pill),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: GameColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameRadii.panel),
        ),
      ),
    );
  }
}
