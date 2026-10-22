import 'package:flutter/material.dart';

/// The Stranger Things palette — both worlds are CINEMATIC DARK.
///
/// The show lives at night: pure black frames, glowing red neon, cold spore
/// light in the Upside Down. There is no "light mode" — Hawkins is a warm
/// near-black with red-gold neon, and the Upside Down is a colder, decayed
/// near-black with bioluminescent teal and vine purple.
///
/// Contrast rule (senior-designer pass): every card gradient puts its DARK
/// end under text, light reads as a top-right source, and body text sits on
/// surfaces cleared to >= 4.5:1.
class AppColors {
  AppColors._();

  // ---- Brand ----
  static const Color stRed = Color(0xFFE50914); // Stranger Things brand red
  static const Color stRedGlow = Color(0xFFFF3B30); // neon tube core
  static const Color hawkinsGold = Color(0xFFF5C518); // retro Hawkins High

  // ---- Hawkins — the Right Side Up (warm near-black + red neon) ----
  static const Color hawkinsBg = Color(0xFF0A0507); // warm void
  static const Color hawkinsCard = Color(0xFF160B0F); // raised surface
  static const Color hawkinsCardHi = Color(0xFF24141A); // lit edge
  static const Color hawkinsInk = Color(0xFFF6ECE4); // warm white text
  static const Color hawkinsMute = Color(0xFFB78C7E); // muted warm text
  static const Color hawkinsLine = Color(0xFF3A2229); // hairline

  // ---- Upside Down — cold decayed void + spore light ----
  static const Color udVoid = Color(0xFF05070B); // base background
  static const Color udFog = Color(0xFF0D1119); // raised surface
  static const Color udFogHi = Color(0xFF182131); // spore fog blue
  static const Color udVine = Color(0xFF6D4BC3); // vine purple (glow)
  static const Color udMist = Color(0xFF93A6C2); // secondary text on dark
  static const Color udSpore = Color(0xFF5BFFDF); // bioluminescent spore

  // ---- Shared ----
  static const Color glassWhite = Color(0x14FFFFFF);
  static const Color dangerGlow = Color(0xFFFF1744);
  static const Color safeGreen = Color(0xFF69F0AE);
  static const Color archive = Color(0xFF8A7A55); // dossier/kraft brown

  /// Soft radial glow behind the title, tinted by world.
  static Color glowFor(bool upsideDown) =>
      upsideDown ? const Color(0x665BFFDF) : const Color(0x66E50914);
}
