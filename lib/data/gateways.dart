import 'package:flutter/foundation.dart';

/// Where a gate stands by the end of the season it belongs to.
enum GateStatus {
  open('OPEN'),
  closed('SEALED'),
  destroyed('DESTROYED');

  const GateStatus(this.label);
  final String label;
}

/// A door between Hawkins and the Upside Down.
@immutable
class Gateway {
  const Gateway({
    required this.name,
    required this.where,
    required this.when,
    required this.season,
    required this.episode,
    required this.status,
    required this.detail,
  });

  final String name;
  final String where;

  /// In-story date, e.g. "Nov 1983".
  final String when;
  final int season;

  /// The chapter that shows it.
  final int episode;
  final GateStatus status;
  final String detail;
}

/// Every gate the series opens, in story order. Kept in step with the
/// timeline and episode synopses.
abstract final class Gateways {
  static const List<Gateway> all = [
    Gateway(
      name: 'The Gate',
      where: 'Hawkins National Laboratory',
      when: 'Nov 1983',
      season: 1,
      episode: 8,
      status: GateStatus.closed,
      detail:
          'Eleven reaches the creature in the void and tears it open under the '
          'lab. Joyce and Hopper walk through it in hazmat suits to find Will. '
          'Eleven seals it a year later.',
    ),
    Gateway(
      name: 'The Tree',
      where: 'Mirkwood',
      when: 'Nov 1983',
      season: 1,
      episode: 5,
      status: GateStatus.closed,
      detail:
          'A wet slit in a tree trunk. Nancy follows the creature\'s trail '
          'inside, and Jonathan pulls her back out just before it closes.',
    ),
    Gateway(
      name: 'The Key',
      where: 'Under Starcourt Mall',
      when: 'Jul 1985',
      season: 3,
      episode: 8,
      status: GateStatus.destroyed,
      detail:
          'A Soviet machine forces a new gate open beneath the mall. Joyce '
          'turns the keys on the Fourth of July and blows the machine apart.',
    ),
    Gateway(
      name: 'The Watergate',
      where: 'Lover\'s Lake',
      when: 'Mar 1986',
      season: 4,
      episode: 6,
      status: GateStatus.open,
      detail:
          'Where Patrick died, the lake floor opens into the Upside Down. Steve '
          'is pulled through first; Dustin gives it its name.',
    ),
    Gateway(
      name: 'The Trailer',
      where: 'Eddie Munson\'s trailer',
      when: 'Mar 1986',
      season: 4,
      episode: 7,
      status: GateStatus.open,
      detail:
          'A gate in the ceiling, right where Chrissy died. Steve, Nancy, Robin '
          'and Eddie climb a mattress tower out of the Upside Down through it.',
    ),
    Gateway(
      name: 'The Four Gates',
      where: 'All over Hawkins',
      when: 'Mar 1986',
      season: 4,
      episode: 9,
      status: GateStatus.open,
      detail:
          'Vecna\'s four victims each left a gate behind. With the fourth chime '
          'for Max they join up and split the town open.',
    ),
    Gateway(
      name: 'The Crawl',
      where: 'Quarantined Hawkins',
      when: 'Nov 1987',
      season: 5,
      episode: 1,
      status: GateStatus.open,
      detail:
          'The rift never closed. With the army walling off the town, the Party '
          'sneaks through it on "crawls" to hunt Vecna in the dark.',
    ),
  ];
}
