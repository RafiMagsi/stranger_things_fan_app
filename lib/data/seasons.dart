import 'package:flutter/material.dart';

import '../models/season.dart';

/// All five seasons with their real chapter titles.
class Seasons {
  Seasons._();

  static const List<Season> all = [s1, s2, s3, s4, s5];

  static const Season s1 = Season(
    number: 1,
    year: '2016',
    tagline: 'The vanishing of Will Byers opens a door that should stay shut.',
    threat: 'The Demogorgon',
    accent: Color(0xFFE50914),
    episodes: [
      Episode(number: 1, title: 'The Vanishing of Will Byers'),
      Episode(number: 2, title: 'The Weirdo on Maple Street'),
      Episode(number: 3, title: 'Holly, Jolly'),
      Episode(number: 4, title: 'The Body'),
      Episode(number: 5, title: 'The Flea and the Acrobat'),
      Episode(number: 6, title: 'The Monster'),
      Episode(number: 7, title: 'The Bathtub'),
      Episode(number: 8, title: 'The Upside Down'),
    ],
  );

  static const Season s2 = Season(
    number: 2,
    year: '2017',
    tagline: 'Hawkins prepares for Halloween - and a shadow learns Will\'s name.',
    threat: 'The Mind Flayer',
    accent: Color(0xFFFF6D00),
    episodes: [
      Episode(number: 1, title: 'MADMAX'),
      Episode(number: 2, title: 'Trick or Treat, Freak'),
      Episode(number: 3, title: 'The Pollywog'),
      Episode(number: 4, title: 'Will the Wise'),
      Episode(number: 5, title: 'Dig Dug'),
      Episode(number: 6, title: 'The Spy'),
      Episode(number: 7, title: 'The Lost Sister'),
      Episode(number: 8, title: 'The Mind Flayer'),
      Episode(number: 9, title: 'The Gate'),
    ],
  );

  static const Season s3 = Season(
    number: 3,
    year: '2019',
    tagline: 'A summer of mall rats, Russian tunnels, and something under Starcourt.',
    threat: 'The Flayed',
    accent: Color(0xFF00E5FF),
    episodes: [
      Episode(number: 1, title: 'Suzie, Do You Copy?'),
      Episode(number: 2, title: 'The Mall Rats'),
      Episode(number: 3, title: 'The Case of the Missing Lifeguard'),
      Episode(number: 4, title: 'The Sauna Test'),
      Episode(number: 5, title: 'The Flayed'),
      Episode(number: 6, title: 'E Pluribus Unum'),
      Episode(number: 7, title: 'The Bite'),
      Episode(number: 8, title: 'The Battle of Starcourt'),
    ],
  );

  static const Season s4 = Season(
    number: 4,
    year: '2022',
    tagline: 'Vecna counts down, Hawkins splits apart, and Max runs for a song.',
    threat: 'Vecna',
    accent: Color(0xFF9C27B0),
    episodes: [
      Episode(number: 1, title: 'The Hellfire Club'),
      Episode(number: 2, title: 'Vecna\'s Curse'),
      Episode(number: 3, title: 'The Monster and the Superhero'),
      Episode(number: 4, title: 'Dear Billy'),
      Episode(number: 5, title: 'The Nina Project'),
      Episode(number: 6, title: 'The Dive'),
      Episode(number: 7, title: 'The Massacre at Hawkins Lab'),
      Episode(number: 8, title: 'Papa'),
      Episode(number: 9, title: 'The Piggyback'),
    ],
  );

  static const Season s5 = Season(
    number: 5,
    year: '2025',
    tagline: 'The final chapter. The crawl begins. The rightside up.',
    threat: 'The Upside Down',
    accent: Color(0xFFC62828),
    episodes: [
      Episode(number: 1, title: 'The Crawl'),
      Episode(number: 2, title: 'The Vanishing of Holly Wheeler'),
      Episode(number: 3, title: 'The Turnbow Trap'),
      Episode(number: 4, title: 'Sorcerer'),
      Episode(number: 5, title: 'Shock Jock'),
      Episode(number: 6, title: 'Escape from Camazotz'),
      Episode(number: 7, title: 'The Bridge'),
      Episode(number: 8, title: 'The Rightside Up'),
    ],
  );
}
