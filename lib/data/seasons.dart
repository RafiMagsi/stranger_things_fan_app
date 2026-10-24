import 'package:flutter/material.dart';

import '../models/season.dart';
import '../models/trailer.dart';

/// All five seasons in watch order: real chapter titles, a spoiler-light
/// synopsis for every chapter, and the official trailers for each season.
class Seasons {
  Seasons._();

  static const List<Season> all = [s1, s2, s3, s4, s5];

  /// Every episode of the series, in the order you watch it.
  static List<(Season, Episode)> get watchOrder => [
    for (final s in all)
      for (final e in s.episodes) (s, e),
  ];

  /// The first chapter, in watch order, that isn't in [watched]; null once
  /// the whole series is done.
  static (Season, Episode)? nextUp(Set<String> watched) {
    for (final (s, e) in watchOrder) {
      if (!watched.contains(s.keyFor(e))) return (s, e);
    }
    return null;
  }

  static int get totalEpisodes => watchOrder.length;

  /// Spoiler shield: is something revealed in [season] / [episode] still
  /// ahead of you? Season-level reveals count from the season's first
  /// chapter.
  static bool isAhead(int season, int? episode, Set<String> watched) =>
      !watched.contains('S${season}E${episode ?? 1}');

  static const Season s1 = Season(
    number: 1,
    year: '2016',
    setting: 'November 1983',
    tagline:
        'A boy vanishes. A girl appears. A town finds out what is underneath.',
    threat: 'The Demogorgon',
    accent: Color(0xFFE50914),
    trailers: [
      Trailer(
        youtubeId: 'b9EkMc79ZSU',
        title: 'Official Final Trailer',
        season: 1,
      ),
    ],
    episodes: [
      Episode(
        number: 1,
        title: 'The Vanishing of Will Byers',
        photo: 'events/bike',
        synopsis:
            'After a ten-hour Dungeons & Dragons campaign, Will Byers cycles home '
            'through Mirkwood and vanishes from his own shed. Across town, a girl '
            'with a shaved head escapes Hawkins Lab.',
      ),
      Episode(
        number: 2,
        title: 'The Weirdo on Maple Street',
        photo: 'events/pool',
        synopsis:
            'Searching for Will in the rain, the boys find the girl - "Eleven" - '
            'and hide her in Mike\'s basement. Nancy drags Barb to a party at '
            'Steve\'s, and Barb is left alone by the pool.',
      ),
      Episode(
        number: 3,
        title: 'Holly, Jolly',
        photo: 'events/lights',
        synopsis:
            'Joyce strings Christmas lights through the house and Will answers '
            'through them, one bulb at a time - so she paints the alphabet on '
            'the wall. Barb wakes somewhere cold and wrong.',
      ),
      Episode(
        number: 4,
        title: 'The Body',
        photo: 'events/quarry',
        synopsis:
            'A body is pulled from the quarry and Hawkins mourns Will. Joyce '
            'refuses to believe it, Hopper breaks into the morgue, and Eleven '
            'finds Will\'s voice on Mike\'s walkie-talkie.',
      ),
      Episode(
        number: 5,
        title: 'The Flea and the Acrobat',
        photo: 'events/walkie',
        synopsis:
            'Mr. Clarke explains other dimensions with a flea on a tightrope. '
            'Hopper breaks into Hawkins Lab, and the boys follow their compasses '
            'toward the gate.',
      ),
      Episode(
        number: 6,
        title: 'The Monster',
        photo: 'events/fog',
        synopsis:
            'Nancy and Jonathan go hunting for the monster themselves. The Party '
            'splinters, and Eleven saves Mike at the quarry.',
      ),
      Episode(
        number: 7,
        title: 'The Bathtub',
        photo: 'events/tank',
        synopsis:
            'The lab closes in. With a kiddie pool and a lot of salt in the '
            'school gym, Eleven goes into the void to find Will.',
      ),
      Episode(
        number: 8,
        title: 'The Upside Down',
        photo: 'events/hazmat',
        synopsis:
            'Joyce and Hopper suit up and cross over. Nancy and Jonathan set a '
            'trap, and the Party makes its last stand at Hawkins Middle.',
      ),
    ],
  );

  static const Season s2 = Season(
    number: 2,
    year: '2017',
    setting: 'October 1984',
    tagline:
        'Hawkins prepares for Halloween - and a shadow learns Will\'s name.',
    threat: 'The Mind Flayer',
    accent: Color(0xFFFF6D00),
    trailers: [
      Trailer(
        youtubeId: 'R1ZXOOLMJ8s',
        title: 'Official Final Trailer',
        season: 2,
      ),
    ],
    episodes: [
      Episode(
        number: 1,
        title: 'MADMAX',
        photo: 'events/arcade',
        synopsis:
            'A year later, Will still has "episodes" - flashes of the Upside '
            'Down. A new girl beats Dustin\'s Dig Dug score, and Hopper keeps a '
            'secret in a cabin in the woods.',
      ),
      Episode(
        number: 2,
        title: 'Trick or Treat, Freak',
        photo: 'events/pumpkin',
        synopsis:
            'Halloween. Will sees a shadow as big as the sky, Dustin finds '
            'something in his trash can, and Nancy\'s guilt about Barb spills '
            'over.',
      ),
      Episode(
        number: 3,
        title: 'The Pollywog',
        photo: 'events/waffle',
        synopsis:
            'Dustin raises his new pet, "Dart". Eleven, restless in the cabin, '
            'sneaks out - and Will tries to stand up to the Shadow Monster.',
      ),
      Episode(
        number: 4,
        title: 'Will the Wise',
        photo: 'events/storm',
        synopsis:
            'Something is living inside Will. Joyce realises his drawings fit '
            'together, and Eleven goes digging into who she really is.',
      ),
      Episode(
        number: 5,
        title: 'Dig Dug',
        photo: 'events/slime',
        synopsis:
            'Hopper is trapped in tunnels growing under Hawkins. Nancy and '
            'Jonathan take Barb\'s story to a conspiracy theorist, and Eleven '
            'goes looking for her mother.',
      ),
      Episode(
        number: 6,
        title: 'The Spy',
        photo: 'events/hazmat',
        synopsis:
            'The lab sends soldiers into the tunnels with Will as their guide. '
            'Steve and Dustin team up to find Dart.',
      ),
      Episode(
        number: 7,
        title: 'The Lost Sister',
        photo: 'events/chicago',
        synopsis:
            'Eleven travels to Chicago to find Kali - another child from the lab '
            '- and her gang of outcasts.',
      ),
      Episode(
        number: 8,
        title: 'The Mind Flayer',
        photo: 'events/trs80',
        synopsis:
            'Demodogs overrun the lab. Bob makes a run for it, and the group '
            'realises the Mind Flayer is using Will as a spy.',
      ),
      Episode(
        number: 9,
        title: 'The Gate',
        photo: 'events/discoball',
        synopsis:
            'Joyce fights to drive the Mind Flayer out of Will while Eleven and '
            'Hopper ride down to close the Gate. Then: the Snow Ball.',
      ),
    ],
  );

  static const Season s3 = Season(
    number: 3,
    year: '2019',
    setting: 'Summer 1985',
    tagline:
        'A summer of mall rats, Russian tunnels, and something under Starcourt.',
    threat: 'The Flayed',
    accent: Color(0xFF00E5FF),
    trailers: [
      Trailer(
        youtubeId: 'V3L1qrisKFE',
        title: 'Summer in Hawkins',
        season: 3,
        channel: 'Stranger Things',
      ),
    ],
    episodes: [
      Episode(
        number: 1,
        title: 'Suzie, Do You Copy?',
        photo: 'events/walkie',
        synopsis:
            'Summer 1985. Starcourt Mall has opened, Mike and El can\'t stop '
            'kissing, and Dustin is back from camp with a giant radio. Beneath '
            'the town, someone is trying to open a door.',
      ),
      Episode(
        number: 2,
        title: 'The Mall Rats',
        photo: 'filming/starcourt',
        synopsis:
            'Nancy and Jonathan chase a story about sick rats. Dustin, Steve and '
            'Robin crack a Russian message, and Billy is not himself.',
      ),
      Episode(
        number: 3,
        title: 'The Case of the Missing Lifeguard',
        photo: 'events/pool',
        synopsis:
            'El and Max spy on Billy and stumble onto something terrible. Will '
            'feels the old chill on the back of his neck.',
      ),
      Episode(
        number: 4,
        title: 'The Sauna Test',
        photo: 'events/sauna',
        synopsis:
            'The Party traps Billy in the community-pool sauna to prove the Mind '
            'Flayer has him.',
      ),
      Episode(
        number: 5,
        title: 'The Flayed',
        photo: 'events/slime',
        synopsis:
            'The flayed are gathering. Joyce and Hopper capture a Russian '
            'scientist, and Nancy and Jonathan fight for their lives at the '
            'hospital.',
      ),
      Episode(
        number: 6,
        title: 'E Pluribus Unum',
        photo: 'events/storm',
        synopsis:
            'Dustin, Steve, Robin and Erica are caught beneath Starcourt, while '
            'the flayed melt together into something enormous.',
      ),
      Episode(
        number: 7,
        title: 'The Bite',
        photo: 'events/carnival',
        synopsis:
            'Everyone races toward Starcourt as the Mind Flayer hunts Eleven.',
      ),
      Episode(
        number: 8,
        title: 'The Battle of Starcourt',
        photo: 'events/fireworks',
        synopsis:
            'Fourth of July. The Party holds the mall against the Mind Flayer '
            'while Joyce and Hopper go deep beneath it to shut the machine down.',
      ),
    ],
  );

  static const Season s4 = Season(
    number: 4,
    year: '2022',
    setting: 'March 1986',
    tagline:
        'Vecna counts down, Hawkins splits apart, and Max runs for a song.',
    threat: 'Vecna',
    accent: Color(0xFF9C27B0),
    trailers: [
      Trailer(
        youtubeId: 'mVsJXiI60a0',
        title: 'Volume 1 Final Trailer',
        season: 4,
        channel: 'Stranger Things',
      ),
      Trailer(
        youtubeId: 'sBEvEcpnG7k',
        title: 'Volume 2 Trailer',
        season: 4,
        channel: 'Stranger Things',
      ),
    ],
    episodes: [
      Episode(
        number: 1,
        title: 'The Hellfire Club',
        photo: 'events/dice',
        synopsis:
            'Spring Break 1986. Eleven, powerless and bullied in California, '
            'waits for Mike. In Hawkins the Hellfire Club plays on, and Chrissy '
            'Cunningham goes to Eddie Munson\'s trailer.',
      ),
      Episode(
        number: 2,
        title: 'Vecna\'s Curse',
        photo: 'events/clock',
        synopsis:
            'Eddie is on the run and the town wants a culprit. The Party traces '
            'the killings to something that knows its victims\' secrets.',
      ),
      Episode(
        number: 3,
        title: 'The Monster and the Superhero',
        photo: 'events/rink',
        synopsis:
            'Max visits Billy\'s grave as the clock chimes for her. Eleven is '
            'arrested - and offered a way to get her powers back.',
      ),
      Episode(
        number: 4,
        title: 'Dear Billy',
        photo: 'events/cassette',
        synopsis:
            'Max is cursed. Her friends have only minutes to find the one song '
            'that can pull her back.',
      ),
      Episode(
        number: 5,
        title: 'The Nina Project',
        photo: 'events/desert',
        synopsis:
            'In a hidden facility, Eleven relives her past to reclaim her power. '
            'Joyce and Murray fly to Alaska, and Hopper plans an escape.',
      ),
      Episode(
        number: 6,
        title: 'The Dive',
        photo: 'events/fog',
        synopsis:
            'The Hawkins team dives into Lover\'s Lake and finds a gate into '
            'the Upside Down.',
      ),
      Episode(
        number: 7,
        title: 'The Massacre at Hawkins Lab',
        photo: 'events/rainbow',
        synopsis:
            'Eleven finally remembers what happened in 1979 - and who was '
            'really behind it.',
      ),
      Episode(
        number: 8,
        title: 'Papa',
        photo: 'events/volcano',
        synopsis:
            'Eleven confronts Brenner as the army closes in. Hopper faces a '
            'Demogorgon, and the Party plans to kill Vecna.',
      ),
      Episode(
        number: 9,
        title: 'The Piggyback',
        photo: 'events/guitar',
        synopsis:
            'Two worlds, four teams, one plan. Eleven rides piggyback into '
            'Max\'s mind to fight Vecna as the fourth chime sounds.',
      ),
    ],
  );

  static const Season s5 = Season(
    number: 5,
    year: '2025',
    setting: 'November 1987',
    tagline: 'Hawkins under quarantine. One last crawl into the dark.',
    threat: 'Vecna & the Mind Flayer',
    accent: Color(0xFFC62828),
    trailers: [
      Trailer(youtubeId: 'PssKpzB0Ah0', title: 'Official Trailer', season: 5),
      Trailer(youtubeId: 'e0Eo0D038rQ', title: 'Volume 2 Trailer', season: 5),
      Trailer(youtubeId: 'AfQ13jsLDms', title: 'Finale Trailer', season: 5),
    ],
    episodes: [
      Episode(
        number: 1,
        title: 'The Crawl',
        photo: 'events/humvee',
        synopsis:
            'November 1987. The military has quarantined Hawkins and is hunting '
            'Eleven. The Party sneaks into the Upside Down on "crawls" to find '
            'Vecna - and a flashback shows what really happened to Will in 1983.',
      ),
      Episode(
        number: 2,
        title: 'The Vanishing of Holly Wheeler',
        photo: 'events/teddy',
        synopsis:
            'A Demogorgon breaks into the Wheeler house and takes Holly. Her '
            'imaginary friend, "Mr. Whatsit", turns out to have a real name.',
      ),
      Episode(
        number: 3,
        title: 'The Turnbow Trap',
        photo: 'events/fog',
        synopsis:
            'Will glimpses Vecna\'s next target, and the Party rigs a trap at the '
            'Turnbow house. Holly explores a strange house in the woods.',
      ),
      Episode(
        number: 4,
        title: 'Sorcerer',
        photo: 'events/dice',
        synopsis:
            'Hopper and Eleven raid the military base and find a familiar '
            'captive. Vecna\'s creatures snatch more children, and Will '
            'discovers a power of his own.',
      ),
      Episode(
        number: 5,
        title: 'Shock Jock',
        photo: 'events/walkie',
        synopsis:
            'The Party plans to reconnect Will to the hive mind with a dead '
            'Demogorgon and a lot of electricity. In Camazotz, the stolen '
            'children plan their escape.',
      ),
      Episode(
        number: 6,
        title: 'Escape from Camazotz',
        photo: 'events/wormhole',
        synopsis:
            'Dustin works out what the Upside Down really is. Max and Holly '
            'fight their way through Vecna\'s mind, and Karen Wheeler defends a '
            'hospital room.',
      ),
      Episode(
        number: 7,
        title: 'The Bridge',
        photo: 'events/lights',
        synopsis:
            'On the anniversary of Will\'s disappearance, the Party gathers for '
            'one final plan - and Will tells his friends who he is.',
      ),
      Episode(
        number: 8,
        title: 'The Rightside Up',
        photo: 'events/lightning',
        synopsis:
            'The last fight: Eleven, Max and Kali inside Henry\'s mind, the Party '
            'in the Abyss, and a bomb to end the Upside Down for good.',
      ),
    ],
  );
}
