import 'package:flutter/material.dart';

import 'design_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final scheme = const ColorScheme.dark().copyWith(
      primary: GameColors.accent,
      onPrimary: GameColors.backgroundDeep,
      secondary: GameColors.violet,
      onSecondary: GameColors.textStrong,
      surface: GameColors.surface,
      onSurface: GameColors.textStrong,
      error: GameColors.danger,
      onError: GameColors.textStrong,
      outline: GameColors.surfaceStrong,
      outlineVariant: GameColors.surfaceRaised,
    );

    final baseTextTheme = ThemeData.dark().textTheme;
    final textTheme = baseTextTheme.copyWith(
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w900,
        letterSpacing: -.8,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w900,
        letterSpacing: -.5,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w900,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w900,
        letterSpacing: -.15,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w900,
        letterSpacing: .15,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: GameColors.textStrong,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: GameColors.textStrong,
        height: 1.35,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: GameColors.textSoft,
        height: 1.4,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: GameColors.muted,
        height: 1.35,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: .2,
      ),
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: GameColors.background,
      dividerColor: GameColors.surfaceStrong.withValues(alpha: .72),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      iconTheme: const IconThemeData(
        color: GameColors.textSoft,
        size: 22,
        opticalSize: 22,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: GameColors.textStrong,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: GameColors.textStrong,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: .35,
        ),
        iconTheme: IconThemeData(
          color: GameColors.textSoft,
          size: 22,
        ),
        actionsIconTheme: IconThemeData(
          color: GameColors.textSoft,
          size: 22,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
          foregroundColor: const WidgetStatePropertyAll(GameColors.backgroundDeep),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: .25),
          ),
          shape: WidgetStatePropertyAll(buttonShape),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? Colors.white.withValues(alpha: .12)
                : null,
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return GameColors.surfaceRaised;
            return GameColors.accentBright;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
          foregroundColor: const WidgetStatePropertyAll(GameColors.textStrong),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w900, letterSpacing: .2),
          ),
          shape: WidgetStatePropertyAll(buttonShape),
          elevation: const WidgetStatePropertyAll(0),
          side: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.disabled)
                ? GameColors.surfaceRaised
                : GameColors.surfaceStrong;
            return BorderSide(color: color, width: 1);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed)
                  ? GameColors.surfaceRaised.withValues(alpha: .9)
                  : GameColors.surfaceGlass.withValues(alpha: .55)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GameColors.accentBright,
          textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.square(42)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.pressed)
                  ? GameColors.accentSoft
                  : GameColors.surfaceGlass.withValues(alpha: .48)),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled)
                  ? GameColors.muted
                  : GameColors.textSoft),
        ),
      ),
      cardTheme: CardThemeData(
        color: GameColors.surfaceGlass,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: GameColors.surfaceStrong.withValues(alpha: .82), width: .8),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GameColors.surfaceGlass.withValues(alpha: .76),
        labelStyle: const TextStyle(color: GameColors.textSoft, fontWeight: FontWeight.w700),
        helperStyle: const TextStyle(color: GameColors.muted),
        hintStyle: const TextStyle(color: GameColors.muted),
        prefixIconColor: GameColors.accentBright,
        suffixIconColor: GameColors.textSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: GameColors.surfaceStrong.withValues(alpha: .84)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GameColors.accentBright, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: GameColors.danger),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GameColors.accentBright,
        linearTrackColor: GameColors.surfaceRaised,
        circularTrackColor: GameColors.surfaceRaised,
        linearMinHeight: 7,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: GameColors.surfaceRaised.withValues(alpha: .75),
        selectedColor: GameColors.accentSoft,
        side: BorderSide(color: GameColors.surfaceStrong.withValues(alpha: .8)),
        labelStyle: const TextStyle(
          color: GameColors.textSoft,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameRadii.pill),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: GameColors.accentBright,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: GameColors.textStrong,
        unselectedLabelColor: GameColors.muted,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .15),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        overlayColor: WidgetStatePropertyAll(GameColors.accentSoft.withValues(alpha: .35)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? GameColors.backgroundDeep
                : GameColors.muted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? GameColors.accentBright
                : GameColors.surfaceRaised),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: GameColors.accentBright,
        inactiveTrackColor: GameColors.surfaceRaised,
        thumbColor: GameColors.textStrong,
        overlayColor: GameColors.accentSoft,
        trackHeight: 5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0B1730),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: GameColors.textStrong,
          fontWeight: FontWeight.w900,
          fontSize: 19,
        ),
        contentTextStyle: const TextStyle(
          color: GameColors.textSoft,
          height: 1.45,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: GameColors.accentBright.withValues(alpha: .18)),
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF0B1730),
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: const Color(0xFF0B1730),
        showDragHandle: true,
        dragHandleColor: GameColors.surfaceStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF101E3D),
        contentTextStyle: const TextStyle(color: GameColors.textStrong, fontWeight: FontWeight.w700),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: GameColors.surfaceStrong.withValues(alpha: .8)),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF101E3D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: GameColors.surfaceStrong),
        ),
        textStyle: const TextStyle(color: GameColors.textStrong, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
