import 'package:flutter/material.dart';

import 'trailer.dart';

@immutable
class Episode {
  const Episode({
    required this.number,
    required this.title,
    required this.synopsis,
    this.photo,
  });

  final int number;
  final String title;

  /// A short, spoiler-light "previously on" for the watch guide.
  final String synopsis;

  /// The still behind this chapter's title card in Story mode (see
  /// `MediaCredits.photo`), e.g. `'events/rink'` for Rink-O-Mania.
  final String? photo;

  /// "CHAPTER ONE" — how the show itself titles every episode.
  String get chapterLabel => 'CHAPTER ${numberWord(number)}';
}

@immutable
class Season {
  const Season({
    required this.number,
    required this.year,
    required this.setting,
    required this.tagline,
    required this.threat,
    required this.accent,
    required this.episodes,
    this.trailers = const [],
  });

  final int number;

  /// Release year on Netflix.
  final String year;

  /// When the season takes place in-story, e.g. "November 1983".
  final String setting;
  final String tagline;

  /// The season's antagonist force, e.g. "The Demogorgon".
  final String threat;
  final Color accent;
  final List<Episode> episodes;
  final List<Trailer> trailers;

  String get episodeLabel => '${episodes.length} chapters';

  /// Watch-progress key for one of this season's episodes.
  String keyFor(Episode e) => 'S${number}E${e.number}';
}

/// Spelled-out numbers for chapter and season title cards.
String numberWord(int n) {
  const words = [
    'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT',
    'NINE', 'TEN',
  ];
  return n >= 0 && n < words.length ? words[n] : '$n';
}
