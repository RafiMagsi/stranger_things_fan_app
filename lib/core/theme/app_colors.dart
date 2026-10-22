import 'package:flutter/material.dart';

/// The Stranger Things palette — both worlds are CINEMATIC DARK.
///
/// The show lives at night: pure black frames and the logo's red neon.
/// Hawkins is a warm near-black lit by that red and 80s amber; the Upside
/// Down is the show's cold storm-blue void, full of drifting ash and split
/// by red lightning.
///
/// Contrast rule (senior-designer pass): every card gradient puts its DARK
/// end under text, light reads as a top-right source, and body text sits on
/// surfaces cleared to >= 4.5:1.
class AppColors {
  AppColors._();

  // ---- Brand: the logotype's neon tube ----
  static const Color stRed = Color(0xFFE50914); // logo red
  static const Color stRedGlow = Color(0xFFFF2A2A); // neon tube core
  static const Color stRedDeep = Color(0xFF5E0509); // oxblood shadow
  static const Color hawkinsGold = Color(0xFFF5C518); // 80s amber

  // ---- Hawkins — the Right Side Up (warm near-black + red neon) ----
  static const Color hawkinsBg = Color(0xFF070405); // warm void
  static const Color hawkinsCard = Color(0xFF120A0C); // raised surface
  static const Color hawkinsCardHi = Color(0xFF21121A); // lit edge
  static const Color hawkinsInk = Color(0xFFF4ECE6); // warm white text
  static const Color hawkinsMute = Color(0xFFB8968C); // muted warm text
  static const Color hawkinsLine = Color(0xFF3A1D22); // hairline

  // ---- Upside Down — cold storm void, ash and red lightning ----
  static const Color udVoid = Color(0xFF03060C); // base background
  static const Color udFog = Color(0xFF0A1220); // raised surface
  static const Color udFogHi = Color(0xFF15233A); // storm-cloud blue
  static const Color udGlow = Color(0xFF5AAEFF); // cold neon accent
  static const Color udMist = Color(0xFF93A9C8); // secondary text on dark
  static const Color udSpore = Color(0xFFC4DAFF); // drifting ash / spores
  static const Color udLightning = Color(0xFFFF2D3C); // Mind Flayer storm
  static const Color udVine = Color(0xFF6D4BC3); // vine purple

  // ---- Shared ----
  static const Color dangerGlow = Color(0xFFFF1744);
  static const Color safeGreen = Color(0xFF69F0AE);
  static const Color archive = Color(0xFF8A7A55); // dossier/kraft brown

  /// Joyce's Christmas lights, in the order they hang on the wall.
  static const List<Color> bulbs = [
    Color(0xFFFF3B30), // red
    Color(0xFFFFCC00), // yellow
    Color(0xFF34C759), // green
    Color(0xFF0A84FF), // blue
    Color(0xFFFF6482), // pink
    Color(0xFFFF9F0A), // orange
  ];

  /// Soft radial glow behind titles, tinted by world.
  static Color glowFor(bool upsideDown) =>
      upsideDown ? const Color(0x665AAEFF) : const Color(0x66E50914);
}
