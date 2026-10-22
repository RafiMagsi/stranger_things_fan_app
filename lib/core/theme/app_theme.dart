import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'text_styles.dart';
import 'world_palette.dart';

/// Two CINEMATIC-DARK worlds, one app. Both are near-black; only the neon
/// changes: Hawkins glows warm red-gold, the Upside Down glows spore-teal.
///
/// Each theme carries a [WorldPalette] extension so widgets can pull the
/// right accent/glow/surface without brightness-branching.
class AppTheme {
  AppTheme._();

  static ThemeData get hawkins => _build(WorldPalette.hawkins());
  static ThemeData get upsideDown => _build(WorldPalette.upsideDown());

  static ThemeData _build(WorldPalette world) {
    final scheme = ColorScheme(
      brightness: Brightness.dark, // both worlds are dark
      primary: world.accent,
      onPrimary: world.upsideDown ? AppColors.udVoid : Colors.white,
      secondary: world.upsideDown ? AppColors.udVine : AppColors.hawkinsGold,
      onSecondary: world.upsideDown ? Colors.white : AppColors.hawkinsBg,
      surface: world.card,
      onSurface: world.ink,
      error: AppColors.dangerGlow,
      onError: Colors.white,
      outline: world.line,
      surfaceContainerHighest: world.cardHi,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: world.bg,
      splashFactory: InkSparkle.splashFactory,
      extensions: [world],
      textTheme: TextTheme(
        displayLarge: AppText.title(size: 40),
        displayMedium: AppText.h1(world.ink),
        headlineMedium: AppText.h2(world.ink),
        bodyMedium: AppText.body(world.ink),
        bodySmall: AppText.body(world.muted, size: 13),
        labelLarge: AppText.label(world.muted),
      ),
      cardTheme: CardThemeData(
        color: world.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: world.line),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: world.ink,
        titleTextStyle: AppText.h2(world.ink),
        iconTheme: IconThemeData(color: world.ink),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: world.card,
        side: BorderSide(color: world.line),
        labelStyle: AppText.label(world.muted),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      dividerTheme: DividerThemeData(color: world.line, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: world.accent,
          foregroundColor: world.upsideDown ? AppColors.udVoid : Colors.white,
          textStyle: AppText.label(
            world.upsideDown ? AppColors.udVoid : Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: world.accent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: world.accent),
    );
  }
}
