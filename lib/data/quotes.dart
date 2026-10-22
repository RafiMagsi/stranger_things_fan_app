import 'package:flutter/material.dart';

/// One memorable line from the series.
@immutable
class Quote {
  const Quote({
    required this.text,
    required this.speaker,
    required this.season,
    required this.accent,
  });

  final String text;
  final String speaker;
  final int season;
  final Color accent;
}

/// A wall of the lines every fan knows by heart.
class Quotes {
  Quotes._();

  static const List<Quote> all = [
    Quote(
      text: 'Friends don\'t lie.',
      speaker: 'Eleven',
      season: 1,
      accent: Color(0xFFF09CB8),
    ),
    Quote(
      text: 'Mouth breather.',
      speaker: 'Eleven',
      season: 1,
      accent: Color(0xFFF09CB8),
    ),
    Quote(
      text: 'The demogorgon - it came from that place. The Upside Down.',
      speaker: 'Mike Wheeler',
      season: 1,
      accent: Color(0xFF63B3FF),
    ),
    Quote(
      text: 'He\'s alive. I know he is.',
      speaker: 'Joyce Byers',
      season: 1,
      accent: Color(0xFFB9F6CA),
    ),
    Quote(
      text: 'I\'m on a roll, baby.',
      speaker: 'Steve Harrington',
      season: 2,
      accent: Color(0xFFFFD54F),
    ),
    Quote(
      text: 'Something\'s coming. Something hungry for blood.',
      speaker: 'Will Byers',
      season: 1,
      accent: Color(0xFFB388FF),
    ),
    Quote(
      text: 'She\'s our friend and she\'s crazy.',
      speaker: 'Lucas Sinclair',
      season: 1,
      accent: Color(0xFF57D9A3),
    ),
    Quote(
      text: 'I\'m the new girl.',
      speaker: 'Max Mayfield',
      season: 2,
      accent: Color(0xFFFF6E40),
    ),
    Quote(
      text: 'Have you ever heard of The Clash?',
      speaker: 'Robin Buckley',
      season: 3,
      accent: Color(0xFF4DD0E1),
    ),
    Quote(
      text: 'Sorry, I\'m busy.',
      speaker: 'Nancy Wheeler',
      season: 2,
      accent: Color(0xFFFF5C8A),
    ),
    Quote(
      text: 'Cops... and doughnuts. That\'s the whole list.',
      speaker: 'Jim Hopper',
      season: 1,
      accent: Color(0xFF8D8D8D),
    ),
    Quote(
      text: 'You lose, loser!',
      speaker: 'Erica Sinclair',
      season: 3,
      accent: Color(0xFF26C6DA),
    ),
    Quote(
      text: 'Every day is the Fourth of July.',
      speaker: 'Jim Hopper',
      season: 3,
      accent: Color(0xFF8D8D8D),
    ),
    Quote(
      text: 'You should run. You should\'ve run.',
      speaker: 'Vecna',
      season: 4,
      accent: Color(0xFF8E4585),
    ),
    Quote(
      text: 'Music is the strongest magic there is.',
      speaker: 'Dustin Henderson',
      season: 4,
      accent: Color(0xFFF5C518),
    ),
    Quote(
      text: 'I\'m the police. I can do whatever I want.',
      speaker: 'Jim Hopper',
      season: 1,
      accent: Color(0xFF8D8D8D),
    ),
  ];
}
