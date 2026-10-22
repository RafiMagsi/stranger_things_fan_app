import 'package:flutter/material.dart';

/// A recurring Hawkins (or beyond) location.
@immutable
class STLocation {
  const STLocation({
    required this.id,
    required this.name,
    required this.note,
    required this.detail,
    required this.seasons,
    required this.icon,
    required this.accent,
    this.upsideDown = false,
  });

  final String id;
  final String name;

  /// One-line "dossier" note.
  final String note;
  final String detail;
  final List<int> seasons;
  final IconData icon;
  final Color accent;

  /// True for locations that exist in the Upside Down.
  final bool upsideDown;

  String get seasonLabel => seasons.map((s) => 'S$s').join(' ');
}

/// The map of Hawkins and the places the story keeps returning to.
class Locations {
  Locations._();

  static const List<STLocation> all = [
    hawkinsLab,
    byersHouse,
    wheelerHouse,
    palaceArcade,
    starcourt,
    creelHouse,
    upsideDown,
    russianBase,
  ];

  static const STLocation hawkinsLab = STLocation(
    id: 'hawkins_lab',
    name: 'Hawkins National Laboratory',
    note: 'Department of Energy cover',
    detail:
        'The black-site lab under Department of Energy letterhead. It ran '
        'the sensory-deprivation tank on children, punched a hole into '
        'another dimension, and buried its mistakes underneath.',
    seasons: [1, 2, 3, 4],
    icon: Icons.science,
    accent: Color(0xFF90A4AE),
  );

  static const STLocation byersHouse = STLocation(
    id: 'byers_house',
    name: 'The Byers House',
    note: '124 Maple Street',
    detail:
        'Where Will hung on the wall as a ghost in the Upside Down, where '
        'Joyce wired Christmas lights to the alphabet, and where the phone '
        'rang from the other side.',
    seasons: [1, 2, 3],
    icon: Icons.home,
    accent: Color(0xFFB9F6CA),
  );

  static const STLocation wheelerHouse = STLocation(
    id: 'wheeler_house',
    name: 'The Wheeler Basement',
    note: 'Party headquarters',
    detail:
        'The dungeon where the Party campaigns, argues, and plans. Every '
        'operation against the Upside Down starts on this shag carpet.',
    seasons: [1, 2, 3, 4, 5],
    icon: Icons.casino,
    accent: Color(0xFF63B3FF),
  );

  static const STLocation palaceArcade = STLocation(
    id: 'palace_arcade',
    name: 'Palace Arcade',
    note: 'Dig Dug high-score territory',
    detail:
        'Where MADMAX outscored Dustin, where the Demogorgon was glimpsed in '
        'the reflections, and where nerd pride turned into a first date.',
    seasons: [2],
    icon: Icons.sports_esports,
    accent: Color(0xFFD4E157),
  );

  static const STLocation starcourt = STLocation(
    id: 'starcourt',
    name: 'Starcourt Mall',
    note: 'The summer of 1985',
    detail:
        'Hawkins\' neon cathedral. Scoops Ahoy, the food court, the '
        'Hawkins Post - and underneath it all, a Russian gate punched into '
        'the earth.',
    seasons: [3],
    icon: Icons.local_mall,
    accent: Color(0xFF00E5FF),
  );

  static const STLocation creelHouse = STLocation(
    id: 'creel_house',
    name: 'The Creel House',
    note: 'Hexgate ground zero',
    detail:
        'The Victorian where the Creels lost everything. Vecna\'s curse '
        'roots back to its grandfather clock - and to Henry Creel himself.',
    seasons: [4],
    icon: Icons.church,
    accent: Color(0xFF8E4585),
  );

  static const STLocation upsideDown = STLocation(
    id: 'upside_down',
    name: 'The Upside Down',
    note: 'A parallel dimension',
    detail:
        'A decayed mirror of Hawkins, frozen at the moment of the blast, '
        'webbed in vines and lit by spores. The gate connects it to the '
        'lab - and to Vecna\'s mind.',
    seasons: [1, 2, 3, 4, 5],
    icon: Icons.blur_on,
    accent: Color(0xFF5BFFDF),
    upsideDown: true,
  );

  static const STLocation russianBase = STLocation(
    id: 'russian_base',
    name: 'The Russian Base',
    note: 'Under Starcourt & Kamchatka',
    detail:
        'The Soviets reverse-engineered the gate. Under Starcourt they kept '
        'a Demogorgon; in Kamchatka they kept a prison - and Hopper with it.',
    seasons: [3, 4],
    icon: Icons.foundation,
    accent: Color(0xFFEF5350),
  );
}
