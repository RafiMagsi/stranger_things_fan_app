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
    this.episode,
    this.photo,
  });

  final String year;
  final String title;
  final String detail;

  /// Season (and episode, when it's one scene) that reveals this beat.
  final int season;
  final int? episode;
  final Color accent;

  /// A real-world photo of the thing this beat is about (see
  /// `MediaCredits.photo`), e.g. `'events/lights'`.
  final String? photo;

  String get revealedIn =>
      episode == null ? 'Season $season' : 'S$season · E$episode';
}

/// The Stranger Things story in the order it happened, 1959 -> 1989.
/// Flashbacks sit where they belong in time; [TimelineEvent.revealedIn]
/// says where you watch them.
class STTimeline {
  STTimeline._();

  static const _past = Color(0xFF8E4585);
  static const _s1 = Color(0xFFE50914);
  static const _s2 = Color(0xFFFF6D00);
  static const _s3 = Color(0xFF00E5FF);
  static const _s4 = Color(0xFF9C27B0);
  static const _s5 = Color(0xFFC62828);

  /// The chapter of the story a beat belongs to (by when it happened).
  static String eraOf(TimelineEvent e) {
    if (e.accent == _s1) return 'Season 1 · 1983';
    if (e.accent == _s2) return 'Season 2 · 1984';
    if (e.accent == _s3) return 'Season 3 · 1985';
    if (e.accent == _s4) return 'Season 4 · 1986';
    if (e.accent == _s5) return 'Season 5 · 1987-1989';
    return 'Before the series';
  }

  static const List<TimelineEvent> events = [
    // ---- Before the series ----
    TimelineEvent(
      year: '1959',
      title: 'The Creels come to Hawkins',
      photo: 'events/victorian',
      detail:
          'Victor and Virginia Creel move into a house on the edge of town with '
          'their children, Alice and Henry. Henry can already see into minds, '
          'and he hates what he finds there.',
      season: 4,
      episode: 7,
      accent: _past,
    ),
    TimelineEvent(
      year: '1959',
      title: 'The Creel murders',
      photo: 'events/clock',
      detail:
          'Virginia and Alice are found dead and Henry is left in a "coma". '
          'Victor is blamed and locked away in Pennhurst; Henry is quietly '
          'handed to Dr. Martin Brenner.',
      season: 4,
      episode: 7,
      accent: _past,
    ),
    TimelineEvent(
      year: '1970s',
      title: 'Brenner\'s children',
      photo: 'events/mkultra',
      detail:
          'Under the MKUltra programme, test subject Terry Ives gives birth to '
          'a daughter who is taken from her. The girl is raised in Hawkins Lab '
          'as number Eleven.',
      season: 1,
      accent: _past,
    ),
    TimelineEvent(
      year: 'Sep 1979',
      title: 'The Hawkins Lab massacre',
      photo: 'events/rainbow',
      detail:
          'Henry - Subject One - murders the other children and staff in the '
          'Rainbow Room. Eleven stops him and blasts him through a gate into '
          'the Upside Down, where he remakes himself as Vecna.',
      season: 4,
      episode: 7,
      accent: _past,
    ),
    TimelineEvent(
      year: '1983',
      title: 'The Gate opens',
      photo: 'events/tank',
      detail:
          'Sent into the void to spy, Eleven reaches out and touches a creature '
          'on the other side - and tears open the Gate beneath Hawkins Lab.',
      season: 1,
      accent: _past,
    ),

    // ---- Season 1 · November 1983 ----
    TimelineEvent(
      year: 'Nov 6, 1983',
      title: 'Will vanishes',
      photo: 'events/bike',
      detail:
          'Will Byers is taken on the way home from a D&D campaign. Eleven '
          'escapes the lab the same night, and a Demogorgon walks Hawkins.',
      season: 1,
      episode: 1,
      accent: _s1,
    ),
    TimelineEvent(
      year: 'Nov 1983',
      title: 'What really happened to Will',
      photo: 'events/slime',
      detail:
          'The Demogorgon carried Will to Vecna, who left part of himself '
          'inside the boy - the link that will haunt Will for four years.',
      season: 5,
      episode: 1,
      accent: _s1,
    ),
    TimelineEvent(
      year: 'Nov 1983',
      title: 'Barb is taken',
      photo: 'events/pool',
      detail:
          'Left alone by the pool at Steve Harrington\'s party, Barb Holland '
          'is dragged into the Upside Down.',
      season: 1,
      episode: 2,
      accent: _s1,
    ),
    TimelineEvent(
      year: 'Nov 1983',
      title: 'The alphabet wall',
      photo: 'events/lights',
      detail:
          'Joyce strings Christmas lights and paints the alphabet on her wall. '
          'Will spells his answers one bulb at a time: R-I-G-H-T H-E-R-E. R-U-N.',
      season: 1,
      episode: 3,
      accent: _s1,
    ),
    TimelineEvent(
      year: 'Nov 1983',
      title: 'The body in the quarry',
      photo: 'events/quarry',
      detail:
          'A body is pulled from the quarry and the town buries Will. It is a '
          'fake, and Hopper finds the proof.',
      season: 1,
      episode: 4,
      accent: _s1,
    ),
    TimelineEvent(
      year: 'Nov 1983',
      title: 'Into the Upside Down',
      photo: 'events/hazmat',
      detail:
          'Joyce and Hopper find Will barely alive in the Upside Down library, '
          'while Eleven destroys the Demogorgon at Hawkins Middle and vanishes.',
      season: 1,
      episode: 8,
      accent: _s1,
    ),
    TimelineEvent(
      year: 'Dec 1983',
      title: 'Christmas in Hawkins',
      photo: 'events/waffle',
      detail:
          'The Party is together again. Hopper leaves Eggos in a box in the '
          'woods, and Will coughs up a slug in the bathroom sink.',
      season: 1,
      episode: 8,
      accent: _s1,
    ),

    // ---- Season 2 · October 1984 ----
    TimelineEvent(
      year: 'Oct 1984',
      title: 'The shadow over Hawkins',
      photo: 'events/storm',
      detail:
          'Will\'s "episodes" show him a shadow as tall as the sky. Max and '
          'her stepbrother Billy arrive from California.',
      season: 2,
      episode: 2,
      accent: _s2,
    ),
    TimelineEvent(
      year: 'Oct 31, 1984',
      title: 'Will is possessed',
      photo: 'events/pumpkin',
      detail:
          'Will stands his ground against the Shadow Monster, and it pours '
          'into him. The Mind Flayer now sees through his eyes.',
      season: 2,
      episode: 3,
      accent: _s2,
    ),
    TimelineEvent(
      year: 'Nov 1984',
      title: 'Eleven\'s mother and sister',
      photo: 'events/chicago',
      detail:
          'Eleven finds her mother, Terry Ives, then travels to Chicago to find '
          'Kali - Eight - another of Brenner\'s children.',
      season: 2,
      episode: 7,
      accent: _s2,
    ),
    TimelineEvent(
      year: 'Nov 1984',
      title: 'Bob Newby, superhero',
      photo: 'events/trs80',
      detail:
          'Bob gets the lab\'s doors open for everyone else and is killed by '
          'demodogs yards from the exit.',
      season: 2,
      episode: 8,
      accent: _s2,
    ),
    TimelineEvent(
      year: 'Nov 1984',
      title: 'The Gate is closed again',
      photo: 'events/discoball',
      detail:
          'Joyce burns the Mind Flayer out of Will while Eleven, with Hopper '
          'beside her, seals the Gate. Hopper gives her a birth certificate: '
          'Jane Hopper.',
      season: 2,
      episode: 9,
      accent: _s2,
    ),

    // ---- Season 3 · Summer 1985 ----
    TimelineEvent(
      year: 'Jul 1985',
      title: 'Starcourt and the Russians',
      photo: 'filming/starcourt',
      detail:
          'A Soviet machine under the new Starcourt Mall is trying to reopen '
          'the Gate. The Mind Flayer takes Billy and starts building an army.',
      season: 3,
      episode: 2,
      accent: _s3,
    ),
    TimelineEvent(
      year: 'Jul 4, 1985',
      title: 'The Battle of Starcourt',
      photo: 'events/fireworks',
      detail:
          'Billy dies protecting Eleven, who loses her powers. Joyce turns the '
          'keys to shut the machine down, and Hopper is lost in the blast.',
      season: 3,
      episode: 8,
      accent: _s3,
    ),
    TimelineEvent(
      year: 'Fall 1985',
      title: 'The Byers leave Hawkins',
      photo: 'events/ltd',
      detail:
          'Joyce moves her family - and Eleven - to California. Eleven reads '
          'the letter Hopper wrote before he disappeared.',
      season: 3,
      episode: 8,
      accent: _s3,
    ),

    // ---- Season 4 · March 1986 ----
    TimelineEvent(
      year: 'Late 1985',
      title: '"The American"',
      photo: 'events/volcano',
      detail: 'Hopper is alive, a prisoner in a Soviet camp in Kamchatka.',
      season: 3,
      episode: 8,
      accent: _s4,
    ),
    TimelineEvent(
      year: 'Mar 1986',
      title: 'Vecna\'s first victim',
      photo: 'events/trailer',
      detail:
          'Cheerleader Chrissy Cunningham dies in Eddie Munson\'s trailer, and '
          'Hawkins decides the Hellfire Club is to blame.',
      season: 4,
      episode: 1,
      accent: _s4,
    ),
    TimelineEvent(
      year: 'Mar 1986',
      title: 'Running Up That Hill',
      photo: 'events/cassette',
      detail:
          'Cursed by Vecna, Max runs back to her friends on the strength of her '
          'favourite song.',
      season: 4,
      episode: 4,
      accent: _s4,
    ),
    TimelineEvent(
      year: 'Mar 1986',
      title: 'The Nina Project',
      photo: 'events/desert',
      detail:
          'To get her powers back, Eleven relives her memories in a hidden '
          'desert facility run by Brenner and Dr. Owens.',
      season: 4,
      episode: 5,
      accent: _s4,
    ),
    TimelineEvent(
      year: 'Mar 1986',
      title: 'One is Vecna',
      photo: 'events/clock',
      detail:
          'Eleven remembers 1979 and the truth: Henry Creel, Subject One and '
          'Vecna are the same person.',
      season: 4,
      episode: 7,
      accent: _s4,
    ),
    TimelineEvent(
      year: 'Mar 1986',
      title: 'Hopper breaks out',
      photo: 'filming/russian_base',
      detail:
          'Joyce and Murray reach Kamchatka, and Hopper fights his way free. '
          'In the desert, Brenner is gunned down - and Eleven leaves him with '
          'a goodbye.',
      season: 4,
      episode: 8,
      accent: _s4,
    ),
    TimelineEvent(
      year: 'Mar 1986',
      title: 'The Piggyback',
      photo: 'events/guitar',
      detail:
          'Eddie dies a hero, Max is left in a coma, and Vecna\'s fourth chime '
          'tears Hawkins open in four places.',
      season: 4,
      episode: 9,
      accent: _s4,
    ),

    // ---- Season 5 · November 1987 ----
    TimelineEvent(
      year: 'Nov 1987',
      title: 'Hawkins under quarantine',
      photo: 'events/humvee',
      detail:
          'The military seals the town, the rifts and Eleven. The Party runs '
          'secret "crawls" into the Upside Down to hunt Vecna.',
      season: 5,
      episode: 1,
      accent: _s5,
    ),
    TimelineEvent(
      year: 'Nov 1987',
      title: 'Holly Wheeler is taken',
      photo: 'events/teddy',
      detail:
          'A Demogorgon takes Holly from her bedroom. Her imaginary friend '
          '"Mr. Whatsit" is Henry Creel.',
      season: 5,
      episode: 2,
      accent: _s5,
    ),
    TimelineEvent(
      year: 'Nov 1987',
      title: 'The sorcerer and the lost sister',
      photo: 'events/fog',
      detail:
          'Will unlocks a power drawn from the hive mind and saves his friends. '
          'Hopper and Eleven find Kali held at the military base.',
      season: 5,
      episode: 4,
      accent: _s5,
    ),
    TimelineEvent(
      year: 'Nov 1987',
      title: 'The Upside Down is a bridge',
      photo: 'events/wormhole',
      detail:
          'Dustin works it out: the Upside Down is a wormhole, held open by '
          'exotic matter, leading to another world - the Abyss.',
      season: 5,
      episode: 6,
      accent: _s5,
    ),
    TimelineEvent(
      year: 'Nov 6, 1987',
      title: 'Will tells the truth',
      photo: 'events/walkie',
      detail:
          'Four years to the day after he vanished, Will comes out to his '
          'friends.',
      season: 5,
      episode: 7,
      accent: _s5,
    ),
    TimelineEvent(
      year: 'Nov 1987',
      title: 'The Rightside Up',
      photo: 'events/lightning',
      detail:
          'Kali dies, the Mind Flayer falls, and Joyce ends Henry Creel. The '
          'bomb destroys the Upside Down - and Eleven stays behind.',
      season: 5,
      episode: 8,
      accent: _s5,
    ),
    TimelineEvent(
      year: 'Spring 1989',
      title: 'Eighteen months later',
      photo: 'events/dice',
      detail:
          'Eighteen months later: graduation, Hopper proposes to Joyce, and the '
          'Party plays one last campaign in the Wheeler basement. Mike believes '
          'Eleven is still out there.',
      season: 5,
      episode: 8,
      accent: _s5,
    ),
  ];
}
