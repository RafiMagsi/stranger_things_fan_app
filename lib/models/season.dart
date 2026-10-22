import 'package:flutter/material.dart';

@immutable
class Episode {
  const Episode({required this.number, required this.title});

  final int number;
  final String title;
}

@immutable
class Season {
  const Season({
    required this.number,
    required this.year,
    required this.tagline,
    required this.threat,
    required this.accent,
    required this.episodes,
  });

  final int number;
  final String year;
  final String tagline;

  /// The season's antagonist force, e.g. "The Demogorgon".
  final String threat;
  final Color accent;
  final List<Episode> episodes;

  String get episodeLabel => '${episodes.length} episodes';
}
