import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale. Grenze stands in for ITC Benguiat (the show's title face);
/// Space Grotesk carries UI copy; Special Elite is the dossier typewriter.
///
/// Both bundled fonts are VARIABLE fonts (Grenze wght 100-900, Space Grotesk
/// wght 300-700). Declaring them at several `weight:` steps in pubspec does
/// NOT move the axis — Flutter renders the default instance. So we drive the
/// real weight through `fontVariations`, which is what makes the title read
/// as heavy Benguiat instead of a thin default.
class AppText {
  AppText._();

  static const String display = 'Grenze';
  static const String ui = 'SpaceGrotesk';
  static const String typewriter = 'SpecialElite';

  /// The Stranger Things title treatment: Grenze pushed to 900, tight,
  /// glowing brand red on black.
  /// Because TextStyle accepts only `color` or `gradient`, not both,
  /// we provide a gradient for the logotype and keep the glow as shadows.
  static TextStyle title({double size = 34, Color glow = AppColors.stRed}) =>
      TextStyle(
        fontFamily: display,
        fontWeight: FontWeight.w900,
        fontVariations: const [FontVariation('wght', 900)],
        fontSize: size,
        letterSpacing: size * 0.02,
        height: 1.02,
        color: Colors.white,
        shadows: [
          Shadow(color: glow.withValues(alpha: 0.9), blurRadius: size * 0.35),
          Shadow(color: glow.withValues(alpha: 0.5), blurRadius: size * 0.9),
        ],
      );

  /// Vertical gradient for the ST logotype: bright red top → deep oxblood bottom.
  static LinearGradient titleGradient() => const LinearGradient(
        colors: [Color(0xFFE50914), Color(0xFFA00312)],
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp,
      );

  /// Glow-only TextStyle (low-opacity white) used as a base under the gradient.
  static TextStyle titleGlow({double size = 34, Color glow = AppColors.stRed}) => TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w900,
    fontVariations: const [FontVariation('wght', 900)],
    fontSize: size,
    letterSpacing: size * 0.02,
    height: 1.02,
    color: Colors.white.withValues(alpha: 0.3),
    shadows: [
      Shadow(color: glow.withValues(alpha: 0.6), blurRadius: size * 0.45),
      ],
  );

  static TextStyle h1(Color c, {bool heavy = false}) => TextStyle(
    fontFamily: display,
    fontWeight: heavy ? FontWeight.w900 : FontWeight.w700,
    fontVariations: [
      FontVariation('wght', heavy ? 900 : 700),
    ],
    fontSize: 28,
    height: 1.08,
    letterSpacing: 0.2,
    color: c,
  );

  static TextStyle h2(Color c, {bool heavy = false}) => TextStyle(
    fontFamily: display,
    fontWeight: heavy ? FontWeight.w700 : FontWeight.w600,
    fontVariations: [
      FontVariation('wght', heavy ? 700 : 600),
    ],
    fontSize: 21,
    height: 1.14,
    color: c,
  );

  static TextStyle body(Color c, {double size = 15, bool bold = false}) =>
      TextStyle(
        fontFamily: ui,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        fontVariations: [FontVariation('wght', bold ? 700 : 400)],
        fontSize: size,
        height: 1.45,
        color: c,
      );

  static TextStyle label(Color c) => TextStyle(
    fontFamily: ui,
    fontWeight: FontWeight.w700,
    fontVariations: const [FontVariation('wght', 700)],
    fontSize: 12,
    letterSpacing: 1.6,
    color: c,
  );

  static TextStyle dossier(Color c, {double size = 14}) => TextStyle(
    fontFamily: typewriter,
    fontSize: size,
    height: 1.4,
    color: c,
  );
}
