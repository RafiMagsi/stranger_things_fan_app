import 'package:flutter/material.dart';

/// Six-axis fan-rating used by the detail-screen radar chart.
/// All values are 0..10.
@immutable
class CharacterStats {
  const CharacterStats({
    required this.power,
    required this.courage,
    required this.intellect,
    required this.heart,
    required this.luck,
    required this.stealth,
  });

  final double power;
  final double courage;
  final double intellect;
  final double heart;
  final double luck;
  final double stealth;

  List<double> get axes => [power, courage, intellect, heart, luck, stealth];
}

@immutable
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.alias,
    required this.tagline,
    required this.bio,
    required this.line,
    required this.accent,
    required this.accentDeep,
    required this.icon,
    required this.stats,
    required this.skills,
    required this.seasons,
    this.actor,
    this.role,
    this.isCreature = false,
  });

  final String id;
  final String name;
  final String alias;
  final String tagline;
  final String bio;

  /// The actor who plays them (omitted for creatures).
  final String? actor;

  /// Story role, e.g. "The Party", "Adult", "Villain".
  final String? role;

  /// A short fan-favorite line shown on the dossier card.
  final String line;

  /// Identity color for the poster/card gradient (dark end anchors text).
  final Color accent;
  final Color accentDeep;
  final IconData icon;
  final CharacterStats stats;
  final List<String> skills;

  /// Season numbers (1-based) this character appears in.
  final List<int> seasons;
  final bool isCreature;

  String get seasonLabel => seasons.map((s) => 'S$s').join(' · ');
}
