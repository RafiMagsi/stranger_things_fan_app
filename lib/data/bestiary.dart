import 'package:flutter/material.dart';

/// A creature / entity from the Upside Down.
@immutable
class Monster {
  const Monster({
    required this.id,
    required this.name,
    required this.alias,
    required this.detail,
    required this.weakness,
    required this.firstSeason,
    required this.icon,
    required this.accent,
    required this.threat,
  });

  final String id;
  final String name;
  final String alias;
  final String detail;

  /// What can put it down.
  final String weakness;
  final int firstSeason;
  final IconData icon;
  final Color accent;

  /// Threat rating 1..5.
  final int threat;
}

/// Field guide to the things that crawl out of the Upside Down.
class Bestiary {
  Bestiary._();

  static const List<Monster> all = [
    demogorgon,
    demodog,
    mindFlayer,
    vecna,
    demoBat,
    theFlyed,
  ];

  static const Monster demogorgon = Monster(
    id: 'demogorgon',
    name: 'Demogorgon',
    alias: 'The Petal-Faced',
    detail:
        'A humanoid predator with a flower-like head that unfurls into rows '
        'of teeth. It hunts by sound, bleeds acid, and can open its own '
        'gates between the Upside Down and Hawkins.',
    weakness: 'Fire, Eleven\'s power, heavy firepower',
    firstSeason: 1,
    icon: Icons.filter_vintage,
    accent: Color(0xFFE53935),
    threat: 4,
  );

  static const Monster demodog = Monster(
    id: 'demodog',
    name: 'Demodog',
    alias: 'Dart & the pack',
    detail:
        'Juvenile Demogorgons that move as a pack and grow from puppy-sized '
        'to wolf-sized in weeks. Dustin raised one and named it D\'Artagnan.',
    weakness: 'Fire - and they drop when the Gate is closed',
    firstSeason: 2,
    icon: Icons.pets,
    accent: Color(0xFFEF5350),
    threat: 3,
  );

  static const Monster mindFlayer = Monster(
    id: 'mind_flayer',
    name: 'Mind Flayer',
    alias: 'The Shadow',
    detail:
        'A vast smoky intelligence that spreads over the Upside Down like '
        'weather. It possesses Will, engineers the Flayed, and has played '
        'the long game since the gate first opened.',
    weakness: 'Heat drives it out of a host; closing the Gate cuts it off',
    firstSeason: 2,
    icon: Icons.thunderstorm,
    accent: Color(0xFF546E7A),
    threat: 5,
  );

  static const Monster vecna = Monster(
    id: 'vecna',
    name: 'Vecna',
    alias: 'Henry Creel · One',
    detail:
        'Henry Creel, the first test subject, remade in the Upside Down. He '
        'hunts the guilty through their minds - a clock chimes, the victim '
        'floats, and their bones break.',
    weakness: 'Music and happy memories break the curse; fire in his lair',
    firstSeason: 4,
    icon: Icons.hourglass_bottom,
    accent: Color(0xFF8E4585),
    threat: 5,
  );

  static const Monster demoBat = Monster(
    id: 'demo_bat',
    name: 'Demo-Bat',
    alias: 'The swarm',
    detail:
        'Winged predators that roost in the Upside Down sky. They swarm, '
        'bite and strangle - Steve barely survives them at Lover\'s Lake.',
    weakness: 'Fire, and a good distraction - like a guitar solo',
    firstSeason: 4,
    icon: Icons.wb_twilight,
    accent: Color(0xFF6D4BC3),
    threat: 3,
  );

  static const Monster theFlyed = Monster(
    id: 'the_flayed',
    name: 'The Flayed',
    alias: 'Hawkins\' missing',
    detail:
        'People infected by the Mind Flayer\'s goo. They are drawn to it, '
        'melt into a slurry, and are consumed to build its physical body.',
    weakness: 'Heat and fire; they melt back into the Mind Flayer',
    firstSeason: 3,
    icon: Icons.waves,
    accent: Color(0xFF26C6DA),
    threat: 4,
  );
}
