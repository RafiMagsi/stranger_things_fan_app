import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Per-world color tokens delivered through `ThemeData.extensions`.
///
/// Both worlds are dark now, so `Brightness` alone can't distinguish them.
/// Components read this extension to get the right accent/glow/surface for
/// whichever world is active — no `isLight` branching sprinkled everywhere.
///
/// [depth] is how far into the Upside Down we are (0 = Hawkins, 1 = Upside
/// Down). Unlike [upsideDown] it tweens smoothly with the theme, so effects
/// that scale with it (vines, colour grading, fog) creep in as the world
/// flips instead of snapping.
@immutable
class WorldPalette extends ThemeExtension<WorldPalette> {
  const WorldPalette({
    required this.upsideDown,
    required this.depth,
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
  final double depth;
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
    depth: 0,
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
    depth: 1,
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

  /// Pulls any content colour (a character's, a season's, a creature's) into
  /// the active world's light. Hawkins leaves it alone. The Upside Down only
  /// knows two colours - storm blue and lightning red - so warm hues decay
  /// toward the lightning and everything else toward the storm, losing
  /// some brightness on the way like everything over there does.
  Color tint(Color c) {
    if (depth <= 0) return c;
    final hsl = HSLColor.fromColor(c);
    // Greys and whites have no real hue (white reads as hue 0, "red"): they
    // go to pale ash instead of lightning.
    final target = hsl.saturation < 0.15
        ? AppColors.udSpore
        : (hsl.hue < 45 || hsl.hue > 300)
        ? AppColors.udLightning
        : AppColors.udGlow;
    final decayed = Color.lerp(c, target, 0.68 * depth)!;
    return Color.lerp(
      decayed,
      Colors.black,
      0.12 * depth,
    )!.withValues(alpha: c.a);
  }

  /// Convenience lookup with a safe fallback.
  static WorldPalette of(BuildContext context) {
    final ext = Theme.of(context).extension<WorldPalette>();
    return ext ?? WorldPalette.hawkins();
  }

  @override
  WorldPalette copyWith({
    bool? upsideDown,
    double? depth,
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
      depth: depth ?? this.depth,
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
      depth: depth + (other.depth - depth) * t,
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
