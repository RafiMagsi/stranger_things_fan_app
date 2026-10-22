import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Per-world color tokens delivered through `ThemeData.extensions`.
///
/// Both worlds are dark now, so `Brightness` alone can't distinguish them.
/// Components read this extension to get the right accent/glow/surface for
/// whichever world is active — no `isLight` branching sprinkled everywhere.
@immutable
class WorldPalette extends ThemeExtension<WorldPalette> {
  const WorldPalette({
    required this.upsideDown,
    required this.accent,
    required this.accentGlow,
    required this.secondary,
    required this.atmosphere,
    required this.bg,
    required this.card,
    required this.cardHi,
    required this.ink,
    required this.muted,
    required this.line,
  });

  final bool upsideDown;
  final Color accent; // primary neon accent (logo red / storm blue)
  final Color accentGlow; // neon halo color
  final Color secondary; // supporting accent (amber / red lightning)
  final Color atmosphere; // the light that leaks in at the top of a screen
  final Color bg;
  final Color card;
  final Color cardHi;
  final Color ink;
  final Color muted;
  final Color line;

  factory WorldPalette.hawkins() => const WorldPalette(
        upsideDown: false,
        accent: AppColors.stRed,
        accentGlow: AppColors.stRedGlow,
        secondary: AppColors.hawkinsGold,
        atmosphere: AppColors.stRed,
        bg: AppColors.hawkinsBg,
        card: AppColors.hawkinsCard,
        cardHi: AppColors.hawkinsCardHi,
        ink: AppColors.hawkinsInk,
        muted: AppColors.hawkinsMute,
        line: AppColors.hawkinsLine,
      );

  factory WorldPalette.upsideDown() => const WorldPalette(
        upsideDown: true,
        accent: AppColors.udGlow,
        accentGlow: AppColors.udSpore,
        secondary: AppColors.udLightning,
        atmosphere: AppColors.udLightning,
        bg: AppColors.udVoid,
        card: AppColors.udFog,
        cardHi: AppColors.udFogHi,
        ink: Colors.white,
        muted: AppColors.udMist,
        line: AppColors.udFogHi,
      );

  /// Convenience lookup with a safe fallback.
  static WorldPalette of(BuildContext context) {
    final ext = Theme.of(context).extension<WorldPalette>();
    return ext ?? WorldPalette.hawkins();
  }

  @override
  WorldPalette copyWith({
    bool? upsideDown,
    Color? accent,
    Color? accentGlow,
    Color? secondary,
    Color? atmosphere,
    Color? bg,
    Color? card,
    Color? cardHi,
    Color? ink,
    Color? muted,
    Color? line,
  }) {
    return WorldPalette(
      upsideDown: upsideDown ?? this.upsideDown,
      accent: accent ?? this.accent,
      accentGlow: accentGlow ?? this.accentGlow,
      secondary: secondary ?? this.secondary,
      atmosphere: atmosphere ?? this.atmosphere,
      bg: bg ?? this.bg,
      card: card ?? this.card,
      cardHi: cardHi ?? this.cardHi,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      line: line ?? this.line,
    );
  }

  @override
  WorldPalette lerp(WorldPalette? other, double t) {
    if (other == null) return this;
    return WorldPalette(
      upsideDown: t < 0.5 ? upsideDown : other.upsideDown,
      accent: Color.lerp(accent, other.accent, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      atmosphere: Color.lerp(atmosphere, other.atmosphere, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardHi: Color.lerp(cardHi, other.cardHi, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
    );
  }
}
