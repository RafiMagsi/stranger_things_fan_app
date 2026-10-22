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
    this.filmedAt,
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

  /// The real place that stood in for it on screen, when it's well known.
  final String? filmedAt;

  /// True for locations that exist in the Upside Down.
  final bool upsideDown;

  String get seasonLabel => seasons.map((s) => 'S$s').join(' ');
}

/// The map of Hawkins and the places the story keeps returning to.
class Locations {
  Locations._();

  static const List<STLocation> all = [
    downtownHawkins,
    hawkinsLab,
    byersHouse,
    wheelerHouse,
    hawkinsHigh,
    palaceArcade,
    hoppersCabin,
    starcourt,
    creelHouse,
    upsideDown,
    russianBase,
  ];

  static const STLocation downtownHawkins = STLocation(
    id: 'downtown_hawkins',
    name: 'Downtown Hawkins',
    note: 'Hawkins, Indiana · pop. small',
    detail:
        'Melvald\'s General Store where Joyce works, the police station where '
        'Hopper drinks his coffee, Bradley\'s Big Buy and the Hawkins Post: '
        'the ordinary town the whole story is trying to protect.',
    seasons: [1, 2, 3, 4, 5],
    icon: Icons.location_city,
    accent: Color(0xFFF5C518),
    filmedAt: 'Jackson, Georgia',
  );

  static const STLocation hawkinsLab = STLocation(
    id: 'hawkins_lab',
    name: 'Hawkins National Laboratory',
    note: 'Department of Energy cover',
    detail:
        'The black-site lab under Department of Energy letterhead. It ran '
        'the sensory-deprivation tank on children, punched a hole into '
        'another dimension, and buried its mistakes underneath.',
    seasons: [1, 2, 3, 4, 5],
    icon: Icons.science,
    accent: Color(0xFF90A4AE),
    filmedAt: 'Emory University\'s Briarcliff campus, Georgia',
  );

  static const STLocation byersHouse = STLocation(
    id: 'byers_house',
    name: 'The Byers House',
    note: 'At the end of Mirkwood',
    detail:
        'Where the phone rang from the other side, where Joyce wired '
        'Christmas lights to the alphabet on the wall, and where Will was '
        'taken from his own shed.',
    seasons: [1, 2, 3],
    icon: Icons.home,
    accent: Color(0xFFB9F6CA),
  );

  static const STLocation wheelerHouse = STLocation(
    id: 'wheeler_house',
    name: 'The Wheeler Basement',
    note: 'Party headquarters · Maple Street',
    detail:
        'The dungeon where the Party campaigns, argues, and plans. Every '
        'operation against the Upside Down starts - and the series ends - '
        'on this carpet.',
    seasons: [1, 2, 3, 4, 5],
    icon: Icons.casino,
    accent: Color(0xFF63B3FF),
  );

  static const STLocation hawkinsHigh = STLocation(
    id: 'hawkins_high',
    name: 'Hawkins High School',
    note: 'Home of the Tigers',
    detail:
        'Steve\'s reign as king, the Hellfire Club\'s lunch table, and the gym '
        'where the Tigers won the championship on the night Chrissy '
        'Cunningham died.',
    seasons: [1, 2, 4],
    icon: Icons.school,
    accent: Color(0xFFE53935),
  );

  static const STLocation palaceArcade = STLocation(
    id: 'palace_arcade',
    name: 'Palace Arcade',
    note: 'Dig Dug high-score territory',
    detail:
        'Where MADMAX outscored Dustin, and where Will slipped into his first '
        'episode of the Upside Down halfway through a game of Dragon\'s Lair.',
    seasons: [2],
    icon: Icons.sports_esports,
    accent: Color(0xFFD4E157),
  );

  static const STLocation hoppersCabin = STLocation(
    id: 'hoppers_cabin',
    name: 'Hopper\'s Cabin',
    note: 'Three rules, no visitors',
    detail:
        'Where Hopper hid Eleven for 353 days: Eggo towers, soap operas, '
        'a TV with bad reception, and a door that had to stay open three '
        'inches.',
    seasons: [2, 3],
    icon: Icons.cabin,
    accent: Color(0xFFFFB74D),
  );

  static const STLocation starcourt = STLocation(
    id: 'starcourt',
    name: 'Starcourt Mall',
    note: 'The summer of 1985',
    detail:
        'Hawkins\' neon cathedral. Scoops Ahoy, the food court, the movie '
        'theatre - and underneath it all, a Russian machine trying to break '
        'the Gate back open.',
    seasons: [3],
    icon: Icons.local_mall,
    accent: Color(0xFF00E5FF),
    filmedAt: 'Gwinnett Place Mall, Duluth, Georgia',
  );

  static const STLocation creelHouse = STLocation(
    id: 'creel_house',
    name: 'The Creel House',
    note: 'Where the curse began, 1959',
    detail:
        'The Victorian where the Creels lost everything. Vecna\'s curse roots '
        'back to its grandfather clock - and to the boy who grew up there.',
    seasons: [4, 5],
    icon: Icons.church,
    accent: Color(0xFF8E4585),
  );

  static const STLocation upsideDown = STLocation(
    id: 'upside_down',
    name: 'The Upside Down',
    note: 'A wormhole wearing Hawkins\' face',
    detail:
        'A decayed mirror of Hawkins frozen on the night of November 6, '
        '1983, webbed in vines and drifting with spores. The finale reveals '
        'what it really is: a bridge to somewhere else.',
    seasons: [1, 2, 3, 4, 5],
    icon: Icons.blur_on,
    accent: Color(0xFF5AAEFF),
    upsideDown: true,
  );

  static const STLocation russianBase = STLocation(
    id: 'russian_base',
    name: 'The Russian Base',
    note: 'Under Starcourt & Kamchatka',
    detail:
        'The Soviets tried to reverse-engineer the Gate. Under Starcourt they '
        'built a machine; in Kamchatka they kept a prison - and Hopper in it.',
    seasons: [3, 4],
    icon: Icons.foundation,
    accent: Color(0xFFEF5350),
    filmedAt: 'Lukiškės Prison, Vilnius, Lithuania',
  );
}
