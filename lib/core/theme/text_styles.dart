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
  static const String condensed = 'Oswald';

  /// Condensed poster headline: screen titles, section labels, hero lines.
  /// Oswald is variable (wght 200-700), so the weight goes through
  /// `fontVariations` like the other faces.
  static TextStyle headline(
    Color c, {
    double size = 24,
    double weight = 600,
    double letterSpacing = 0.08,
  }) => TextStyle(
    fontFamily: condensed,
    fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
    fontVariations: [FontVariation('wght', weight)],
    fontSize: size,
    height: 1.05,
    letterSpacing: size * letterSpacing,
    color: c,
  );

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
  static TextStyle titleGlow({
    double size = 34,
    Color glow = AppColors.stRed,
  }) => TextStyle(
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

  /// The show's neon lettering: hollow Benguiat strokes with the tube's
  /// glow bleeding through. The stroke is the foreground paint, and the
  /// shadows (always painted as filled, blurred glyphs) give the inner and
  /// outer bloom — one Text widget, no stacking.
  static TextStyle neon({
    double size = 22,
    Color color = AppColors.stRed,
    double glow = 1.0,
    double letterSpacing = 0.06,
  }) => TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w900,
    fontVariations: const [FontVariation('wght', 900)],
    fontSize: size,
    height: 1.0,
    letterSpacing: size * letterSpacing,
    foreground: Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size * 0.045).clamp(1.0, 3.2)
      ..strokeJoin = StrokeJoin.round
      // An unlit tube is still there, just dull: lerp from dark glass to
      // the hot lit tube as the glow comes up.
      ..color = Color.lerp(
        Color.lerp(color, Colors.black, 0.55),
        Color.lerp(color, Colors.white, 0.18),
        glow.clamp(0.0, 1.0),
      )!,
    shadows: [
      Shadow(
        color: color.withValues(alpha: 0.55 * glow),
        blurRadius: size * 0.12,
      ),
      Shadow(
        color: color.withValues(alpha: 0.65 * glow),
        blurRadius: size * 0.45,
      ),
      Shadow(
        color: color.withValues(alpha: 0.35 * glow),
        blurRadius: size * 1.1,
      ),
    ],
  );

  /// "CHAPTER ONE" — the episode title card's small caps line.
  static TextStyle chapter(Color c, {double size = 12}) => TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w700,
    fontVariations: const [FontVariation('wght', 700)],
    fontSize: size,
    letterSpacing: size * 0.22,
    height: 1.1,
    color: c,
    shadows: [Shadow(color: c.withValues(alpha: 0.6), blurRadius: size * 0.8)],
  );

  static TextStyle h1(Color c, {bool heavy = false}) => TextStyle(
    fontFamily: display,
    fontWeight: heavy ? FontWeight.w900 : FontWeight.w700,
    fontVariations: [FontVariation('wght', heavy ? 900 : 700)],
    fontSize: 28,
    height: 1.08,
    letterSpacing: 0.2,
    color: c,
  );

  static TextStyle h2(Color c, {bool heavy = false}) => TextStyle(
    fontFamily: display,
    fontWeight: heavy ? FontWeight.w700 : FontWeight.w600,
    fontVariations: [FontVariation('wght', heavy ? 700 : 600)],
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

  static TextStyle dossier(Color c, {double size = 14}) =>
      TextStyle(fontFamily: typewriter, fontSize: size, height: 1.4, color: c);
}
