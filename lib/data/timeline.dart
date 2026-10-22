import 'package:flutter/material.dart';

/// One beat on the series timeline (in-story chronology, not air dates).
@immutable
class TimelineEvent {
  const TimelineEvent({
    required this.year,
    required this.title,
    required this.detail,
    required this.season,
    required this.accent,
  });

  final String year;
  final String title;
  final String detail;

  /// Season this beat is revealed in.
  final int season;
  final Color accent;
}

/// The Stranger Things in-story timeline, 1959 -> 1987.
class STTimeline {
  STTimeline._();

  static const List<TimelineEvent> events = [
    TimelineEvent(
      year: '1959',
      title: 'The Creel House opens',
      detail:
          'The Creel family moves in. Strange deaths follow, and Henry Creel - '
          'Subject One - is hidden away in Hawkins Lab.',
      season: 4,
      accent: Color(0xFF8E4585),
    ),
    TimelineEvent(
      year: '1979',
      title: 'The Hawkins Lab massacre',
      detail:
          'Subject One turns on the other children and is cast into the '
          'Upside Down, where he remakes himself as Vecna.',
      season: 4,
      accent: Color(0xFF8E4585),
    ),
    TimelineEvent(
      year: 'Nov 1983',
      title: 'Will vanishes',
      detail:
          'Will Byers is taken through the gate on the way home. Eleven '
          'escapes the lab the same night, and the Demogorgon walks Hawkins.',
      season: 1,
      accent: Color(0xFFE50914),
    ),
    TimelineEvent(
      year: 'Dec 1983',
      title: 'The gate is closed',
      detail:
          'Eleven finds Will in the Upside Down and closes the gate to the '
          'lab, seemingly ending the nightmare.',
      season: 1,
      accent: Color(0xFFE50914),
    ),
    TimelineEvent(
      year: 'Oct 1984',
      title: 'The shadow returns',
      detail:
          'Will starts drawing the Mind Flayer. The gate beneath the lab is '
          'reopened, and demodogs pour into Hawkins.',
      season: 2,
      accent: Color(0xFFFF6D00),
    ),
    TimelineEvent(
      year: 'Jul 1985',
      title: 'The Battle of Starcourt',
      detail:
          'The Flayed melt into the Mind Flayer\'s meat avatar. The Russians '
          'are run out of Starcourt, and Hopper is lost.',
      season: 3,
      accent: Color(0xFF00E5FF),
    ),
    TimelineEvent(
      year: '1986',
      title: 'Vecna\'s curse',
      detail:
          'Vecna claims victims across Hawkins High. Max survives a curse, '
          'and the truth of Henry Creel surfaces.',
      season: 4,
      accent: Color(0xFF9C27B0),
    ),
    TimelineEvent(
      year: '1987',
      title: 'The rightside up',
      detail:
          'Hawkins is split open. The Party rides into the Upside Down for '
          'one last crawl, and the gate closes for good.',
      season: 5,
      accent: Color(0xFFC62828),
    ),
  ];
}
