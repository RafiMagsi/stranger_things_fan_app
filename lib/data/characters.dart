import 'package:flutter/material.dart';

import '../models/character.dart';

/// The Party, their friends, the adults who believe them, and the things
/// that crawled out of the Upside Down.
///
/// Named `Cast` (not `Characters`) to avoid the name clash with the
/// `characters` package that Flutter's material.dart re-exports.
class Cast {
  Cast._();

  static const List<Character> all = [
    eleven,
    mike,
    dustin,
    lucas,
    will,
    max,
    steve,
    nancy,
    jonathan,
    robin,
    hopper,
    joyce,
    vecna,
    demogorgon,
    mindFlayer,
  ];

  static const List<Character> party = [eleven, mike, dustin, lucas, will, max];
  static const List<Character> creatures = [vecna, demogorgon, mindFlayer];

  static const Character eleven = Character(
    id: 'eleven',
    name: 'Eleven',
    alias: 'Jane Hopper · Subject 011',
    tagline: 'The girl who closed the gate',
    bio:
        'Escaped from Hawkins Lab with a shaved head and a stolen Eggo box. '
        'Eleven bends physics with her nosebleed-inducing focus, and traded '
        'her rage for a family she chose - the Party.',
    line: 'Friends don\'t lie.',
    accent: Color(0xFFF09CB8),
    accentDeep: Color(0xFF6E2547),
    icon: Icons.psychology_alt,
    stats: CharacterStats(
      power: 10,
      courage: 9,
      intellect: 6,
      heart: 8,
      luck: 5,
      stealth: 3,
    ),
    skills: ['Telekinesis', 'Void tracking', 'Portal closing'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Millie Bobby Brown',
    role: 'The Party',
  );

  static const Character mike = Character(
    id: 'mike',
    name: 'Mike Wheeler',
    alias: ' Dungeon Master',
    tagline: 'Leader of the Party',
    bio:
        'Keeper of the campaign and the first to find Eleven in the woods. '
        'Mike runs the Party the way he runs a Hellfire session: everyone '
        'gets a seat, and nobody gets left behind.',
    line: 'She\'s our friend and she\'s crazy.',
    accent: Color(0xFF63B3FF),
    accentDeep: Color(0xFF123A66),
    icon: Icons.casino,
    stats: CharacterStats(
      power: 2,
      courage: 8,
      intellect: 7,
      heart: 9,
      luck: 6,
      stealth: 5,
    ),
    skills: ['Leadership', 'Campaign writing', 'Lockpicking'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Finn Wolfhard',
    role: 'The Party',
  );

  static const Character dustin = Character(
    id: 'dustin',
    name: 'Dustin Henderson',
    alias: ' D',
    tagline: 'The heart of the Party',
    bio:
        'Gap-toothed conspiracy theorist with a ham radio and a scientist\'s '
        'mind. Named a demodog D\'Artagnan, tried to raise it, and learned '
        'the hard way that some strays bite.',
    line: 'Mouth breather.',
    accent: Color(0xFFF5C518),
    accentDeep: Color(0xFF6B4E07),
    icon: Icons.radio,
    stats: CharacterStats(
      power: 2,
      courage: 7,
      intellect: 9,
      heart: 8,
      luck: 5,
      stealth: 4,
    ),
    skills: ['Radio ops', 'Science fair builds', 'Code-breaking'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Gaten Matarazzo',
    role: 'The Party',
  );

  static const Character lucas = Character(
    id: 'lucas',
    name: 'Lucas Sinclair',
    alias: ' Sling King',
    tagline: 'The protector',
    bio:
        'The Party\'s realist and its sharpest shot. Lucas was the first to '
        'treat Eleven with suspicion and the first to swing a slingshot at '
        'a Demogorgon - and he does not miss.',
    line: 'She\'s our friend and she\'s crazy.',
    accent: Color(0xFF57D9A3),
    accentDeep: Color(0xFF0E5B41),
    icon: Icons.track_changes,
    stats: CharacterStats(
      power: 5,
      courage: 9,
      intellect: 7,
      heart: 7,
      luck: 5,
      stealth: 8,
    ),
    skills: ['Slingshot', 'Night ops', 'Soldier-level focus'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Caleb McLaughlin',
    role: 'The Party',
  );

  static const Character will = Character(
    id: 'will',
    name: 'Will Byers',
    alias: ' Will the Wise',
    tagline: 'The boy who saw the Upside Down',
    bio:
        'Taken through the gate in 1983 and used as a spy for the Mind '
        'Flayer in 1985. Will draws what the Upside Down shows him - and '
        'his drawings keep saving Hawkins.',
    line: 'Something\'s coming. Something hungry for blood.',
    accent: Color(0xFFB388FF),
    accentDeep: Color(0xFF3F2A78),
    icon: Icons.auto_stories,
    stats: CharacterStats(
      power: 1,
      courage: 7,
      intellect: 7,
      heart: 8,
      luck: 2,
      stealth: 6,
    ),
    skills: ['Dungeon cartography', 'Upside Down sensing', 'Survival'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Noah Schnapp',
    role: 'The Party',
  );

  static const Character max = Character(
    id: 'max',
    name: 'Max Mayfield',
    alias: ' MADMAX',
    tagline: 'The girl who outran Vecna',
    bio:
        'Skateboarder, arcade record-holder, and the only one to walk away '
        'from Vecna\'s curse by remembering what she loved loud enough: '
        'a mixtape, a beach, and her friends.',
    line: 'I\'m the new girl.',
    accent: Color(0xFFFF6E40),
    accentDeep: Color(0xFF8A2703),
    icon: Icons.skateboarding,
    stats: CharacterStats(
      power: 1,
      courage: 10,
      intellect: 6,
      heart: 8,
      luck: 3,
      stealth: 7,
    ),
    skills: ['Skateboarding', 'Arcade high scores', 'Sneaking out'],
    seasons: [2, 3, 4, 5],
    actor: 'Sadie Sink',
    role: 'The Party',
  );

  static const Character steve = Character(
    id: 'steve',
    name: 'Steve Harrington',
    alias: 'King Steve',
    tagline: 'Babysitter to a town under siege',
    bio:
        'Hawkins\' golden boy grew into its most reliable protector. '
        'Scoops Ahoy flunky, babysitter to the Party, and a man whose hair '
        'has its own stunt coordinator.',
    line: 'I\'m on a roll, baby.',
    accent: Color(0xFFFFD54F),
    accentDeep: Color(0xFF7A5A00),
    icon: Icons.sports_baseball,
    stats: CharacterStats(
      power: 5,
      courage: 8,
      intellect: 5,
      heart: 9,
      luck: 4,
      stealth: 2,
    ),
    skills: ['Nail bat', 'Babysitting', 'Talking his way in'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Joe Keery',
    role: 'Hawkins High',
  );

  static const Character nancy = Character(
    id: 'nancy',
    name: 'Nancy Wheeler',
    alias: 'The reporter',
    tagline: 'Armed, accurate, unafraid',
    bio:
        'Started with a typewriter, graduated to a shotgun. Nancy chased '
        'the Hawkins story when the police wouldn\'t, and never stopped '
        'even when the story chased back.',
    line: 'Sorry, I\'m busy.',
    accent: Color(0xFFFF5C8A),
    accentDeep: Color(0xFF74113D),
    icon: Icons.newspaper,
    stats: CharacterStats(
      power: 5,
      courage: 9,
      intellect: 8,
      heart: 7,
      luck: 3,
      stealth: 4,
    ),
    skills: ['Investigation', 'Shotgun', 'Typewriter deadlines'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Natalia Dyer',
    role: 'Hawkins High',
  );

  static const Character jonathan = Character(
    id: 'jonathan',
    name: 'Jonathan Byers',
    alias: 'The photographer',
    tagline: 'Quiet eyes, loud courage',
    bio:
        'Will\'s older brother and Nancy\'s partner in both developing '
        'fluid and danger. Jonathan photographs what others miss - then '
        'walks straight into the dark to find his family.',
    line: 'I\'m not scared of you.',
    accent: Color(0xFF7EAAFF),
    accentDeep: Color(0xFF1D3372),
    icon: Icons.camera_alt,
    stats: CharacterStats(
      power: 3,
      courage: 8,
      intellect: 6,
      heart: 8,
      luck: 3,
      stealth: 9,
    ),
    skills: ['Photography', 'Stealth', 'Big-brother mode'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Charlie Heaton',
    role: 'Hawkins High',
  );

  static const Character robin = Character(
    id: 'robin',
    name: 'Robin Buckley',
    alias: 'Scoops Ahoy crew',
    tagline: 'Cracked the Russian code',
    bio:
        'Works the ice-cream counter, decodes Soviet transmissions in the '
        'back, and delivers translations under pressure with a joke and a '
        'panic attack. Hawkins owes her a medal.',
    line: 'Have you ever heard of The Clash?',
    accent: Color(0xFF4DD0E1),
    accentDeep: Color(0xFF0B4F5C),
    icon: Icons.icecream,
    stats: CharacterStats(
      power: 1,
      courage: 7,
      intellect: 10,
      heart: 8,
      luck: 4,
      stealth: 6,
    ),
    skills: ['Code-breaking', 'Languages', 'Deadpan survival'],
    seasons: [3, 4, 5],
    actor: 'Maya Hawke',
    role: 'Hawkins High',
  );

  static const Character hopper = Character(
    id: 'hopper',
    name: 'Jim Hopper',
    alias: 'Chief of Police',
    tagline: 'The cop who never stopped looking',
    bio:
        'Hawkins\' coffee-guzzling police chief took Eleven in as a '
        'daughter and fought the lab, the Russians, and his own grief. '
        'He walked out of a Russian prison still wearing the same hat.',
    line: 'Nothing\'s gonna change.',
    accent: Color(0xFF8D8D8D),
    accentDeep: Color(0xFF2C2C2C),
    icon: Icons.local_police,
    stats: CharacterStats(
      power: 6,
      courage: 9,
      intellect: 6,
      heart: 9,
      luck: 2,
      stealth: 3,
    ),
    skills: ['Interrogation', 'Truck ramming', 'Bad cooking'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'David Harbour',
    role: 'Hawkins Adult',
  );

  static const Character joyce = Character(
    id: 'joyce',
    name: 'Joyce Byers',
    alias: 'The mother who believed',
    tagline: 'Talked to her son through Christmas lights',
    bio:
        'When the town wrote Will off, Joyce wired the house with lights '
        'and spelled her fear in glowing letters. Every season since, '
        'Joyce runs toward the thing everyone else runs from.',
    line: 'He\'s alive. I know he is.',
    accent: Color(0xFFB9F6CA),
    accentDeep: Color(0xFF256B3F),
    icon: Icons.lightbulb,
    stats: CharacterStats(
      power: 3,
      courage: 10,
      intellect: 8,
      heart: 10,
      luck: 3,
      stealth: 2,
    ),
    skills: ['Christmas-light messages', 'Gut instinct', 'Screaming at monsters'],
    seasons: [1, 2, 3, 4, 5],
    actor: 'Winona Ryder',
    role: 'Hawkins Adult',
  );

  static const Character vecna = Character(
    id: 'vecna',
    name: 'Vecna',
    alias: 'Henry Creel · Subject 001',
    tagline: 'The mind behind the Mind Flayer',
    bio:
        'The first test subject escaped Hawkins Lab, remade himself as the '
        'Upside Down\'s priest, and hunts by turning guilt into clocks, '
        'countdowns, and floating bodies. Eleven put him here. He clawed '
        'his way back.',
    line: 'You have already lost.',
    accent: Color(0xFF8E4585),
    accentDeep: Color(0xFF2A0E2C),
    icon: Icons.hourglass_bottom,
    stats: CharacterStats(
      power: 10,
      courage: 2,
      intellect: 9,
      heart: 0,
      luck: 6,
      stealth: 5,
    ),
    skills: ['Mind control', 'Curse chains', 'Puppet bodies'],
    seasons: [4, 5],
    actor: 'Jamie Campbell Bower',
    role: 'Villain',
    isCreature: true,
  );

  static const Character demogorgon = Character(
    id: 'demogorgon',
    name: 'Demogorgon',
    alias: 'The Petal-Faced',
    tagline: 'It hunts by sound. It hungers for blood.',
    bio:
        'A flower-faced predator from the Upside Down that walked Hawkins '
        'in 1983. Superhuman strength, acid blood, and a mouth that opens '
        'like a nightmare bloom.',
    line: '... (petals open)',
    accent: Color(0xFFE53935),
    accentDeep: Color(0xFF4A0E0E),
    icon: Icons.filter_vintage,
    stats: CharacterStats(
      power: 9,
      courage: 8,
      intellect: 2,
      heart: 0,
      luck: 4,
      stealth: 7,
    ),
    skills: ['Tracking', 'Wall climbing', 'Gorgon shriek'],
    seasons: [1, 2, 4, 5],
    role: 'Creature',
    isCreature: true,
  );

  static const Character mindFlayer = Character(
    id: 'mind_flayer',
    name: 'Mind Flayer',
    alias: 'The Shadow',
    tagline: 'A storm with a plan',
    bio:
        'A vast smoky intelligence spread across the Upside Down like '
        'weather. It possessed Will, melted the Flayed into one body, and '
        'has been playing the long game since 1983.',
    line: 'It wants you. It wants everyone.',
    accent: Color(0xFF4A5568),
    accentDeep: Color(0xFF12161F),
    icon: Icons.thunderstorm,
    stats: CharacterStats(
      power: 10,
      courage: 3,
      intellect: 10,
      heart: 0,
      luck: 3,
      stealth: 8,
    ),
    skills: ['Possession', 'Storm form', 'Flayed hive-mind'],
    seasons: [2, 3, 4, 5],
    role: 'Villain',
    isCreature: true,
  );
}
