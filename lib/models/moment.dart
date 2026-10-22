import 'package:flutter/material.dart';

/// The flavour of a moment, used for the filter chips and the colour coding.
enum MomentKind {
  twist('Twist', Color(0xFFB388FF)),
  reveal('Reveal', Color(0xFF4DD0E1)),
  irony('Irony', Color(0xFFF5C518)),
  sacrifice('Sacrifice', Color(0xFFEF5350)),
  betrayal('Betrayal', Color(0xFFFF5C8A));

  const MomentKind(this.label, this.color);

  final String label;
  final Color color;
}

/// One of the series' big turning points.
///
/// Moments are structured as a two-beat reveal so the screen can hide the
/// payoff behind a spoiler veil:
///  - [setup]  -> the surface event, safe to show.
///  - [reveal] -> the twist / rug-pull / sting, veiled until tapped.
///  - [why]    -> the dossier note on why it lands (often the irony).
@immutable
class Moment {
  const Moment({
    required this.id,
    required this.kind,
    required this.title,
    required this.setup,
    required this.reveal,
    required this.why,
    required this.season,
    required this.episode,
    required this.accent,
    this.photo,
  });

  final String id;
  final MomentKind kind;
  final String title;

  /// Safe, un-spoiling summary.
  final String setup;

  /// The twist itself — hidden behind the veil until revealed.
  final String reveal;

  /// Why it lands: the irony or the emotional sting.
  final String why;

  final int season;
  final int episode;
  final Color accent;

  /// A real-world photo of what the moment turns on (see
  /// `MediaCredits.photo`), e.g. `'events/camaro'` for Billy.
  final String? photo;

  String get chapterLabel => 'S$season · E$episode';
}
