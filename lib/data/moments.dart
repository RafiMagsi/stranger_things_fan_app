import 'package:flutter/material.dart';

import '../models/moment.dart';

/// The moments fans still argue about: the twists, the reveals, the gut
/// punches, and the ironies — every season, in watch order. Each is split
/// into a safe [Moment.setup] and a veiled [Moment.reveal] so nobody gets
/// spoiled by accident.
class Moments {
  Moments._();

  static const List<Moment> all = [
    // ---------------- Season 1 · November 1983 ----------------
    Moment(
      id: 'barb',
      kind: MomentKind.irony,
      title: 'Justice for Barb',
      setup:
          'Nancy\'s best friend Barb waits alone by the pool while Nancy goes '
          'upstairs with Steve. A light flickers. Barb is gone.',
      reveal:
          'Barb is dead by the next episode - and while the whole town '
          'searches for Will, Barb is written off as a runaway. Only Nancy '
          'keeps looking.',
      why:
          'The show weaponises its own indifference: Barb\'s erasure becomes '
          'the season\'s quiet indictment of who a town decides is worth '
          'mourning. The internet noticed.',
      season: 1,
      episode: 2,
      accent: Color(0xFF4DD0E1),
    ),
    Moment(
      id: 'lights',
      kind: MomentKind.reveal,
      title: 'Right Here',
      setup:
          'Everyone thinks Joyce is falling apart. She is stringing Christmas '
          'lights through every room and talking to them.',
      reveal:
          'She paints the alphabet on the wall and asks Will where he is. The '
          'bulbs answer, one letter at a time: R-I-G-H-T H-E-R-E. Then she '
          'asks what she should do. R-U-N.',
      why:
          'The most iconic image of the series is a mother refusing to be '
          'told she is crazy - and being right.',
      season: 1,
      episode: 3,
      accent: Color(0xFFFFCC00),
    ),
    Moment(
      id: 'fake_body',
      kind: MomentKind.twist,
      title: 'The Body in the Quarry',
      setup:
          'A body is pulled from the quarry. The face is Will\'s. Joyce '
          'screams. Hopper holds her back.',
      reveal:
          'It isn\'t Will. It\'s a fake stuffed with cotton, planted by the '
          'lab to end the search. The real Will is alive on the other side, '
          'pounding on a wall no one can hear.',
      why:
          'A fake-out death inside a fake-out death. The audience grieves a '
          'boy who isn\'t dead, which is exactly the trick the lab is playing '
          'on the town.',
      season: 1,
      episode: 4,
      accent: Color(0xFFEF5350),
    ),
    Moment(
      id: 'hopper_deal',
      kind: MomentKind.betrayal,
      title: 'Hopper\'s Bargain',
      setup:
          'Hopper and Joyce are captured at Hawkins Lab. Minutes later, they '
          'are suited up and allowed to walk through the gate.',
      reveal:
          'The price of admission: Hopper told Brenner where to find the kids '
          '- and Eleven. The lab arrives at the school because the chief of '
          'police sent them.',
      why:
          'The town\'s protector trades the girl to save the boy. The guilt '
          'is why Hopper spends the next season hiding her from the world.',
      season: 1,
      episode: 8,
      accent: Color(0xFFFFB74D),
    ),
    Moment(
      id: 'el_vanishes',
      kind: MomentKind.sacrifice,
      title: 'The Girl Who Disappeared',
      setup:
          'The Demogorgon corners the Party in a classroom at Hawkins Middle. '
          'Eleven steps between it and her friends.',
      reveal:
          'She pins it to the chalkboard and screams until it - and she - '
          'disintegrate into ash. A month later, Hopper leaves a box of Eggos '
          'in the woods.',
      why:
          'The victory costs the hero, and the season\'s last clue is a '
          'frozen waffle - a promise that she is still out there.',
      season: 1,
      episode: 8,
      accent: Color(0xFFF09CB8),
    ),
    Moment(
      id: 'slug',
      kind: MomentKind.twist,
      title: 'Christmas Slug',
      setup:
          'Christmas. Will is home, the Party is together, and everyone is '
          'finally safe.',
      reveal:
          'Will excuses himself, coughs a slug into the sink, and flashes to '
          'the Upside Down. He is not safe at all.',
      why:
          'A happy ending with a parasite in it. The season closes the case '
          'and reopens it in the same breath.',
      season: 1,
      episode: 8,
      accent: Color(0xFF8BC34A),
    ),

    // ---------------- Season 2 · October 1984 ----------------
    Moment(
      id: 'dart',
      kind: MomentKind.irony,
      title: 'D\'Artagnan',
      setup:
          'Dustin finds a tiny slimy thing in his trash can, names it Dart, '
          'and hides it from the Party.',
      reveal:
          'Dart is a baby Demogorgon. It grows, eats Mews the cat, and joins '
          'the pack that overruns the lab - and later spares Dustin for a bar '
          'of nougat.',
      why:
          'The kid who loves science adopts the monster. The one act of '
          'kindness toward a creature in the series comes back to save him.',
      season: 2,
      episode: 6,
      accent: Color(0xFFF5C518),
    ),
    Moment(
      id: 'will_spy',
      kind: MomentKind.twist,
      title: 'The Boy Who Came Back Wrong',
      setup:
          'Will is home, safe, drawing maps of the tunnels. He keeps seeing '
          'the shadow. He keeps being right.',
      reveal:
          'Will never really escaped. The Mind Flayer is inside him - he is its '
          'eyes and ears. When he leads the soldiers into the tunnels, he is '
          'leading them into a trap.',
      why:
          'The rescued child is the Trojan horse. The people who love him '
          'most are nursing the very thing that is hunting them.',
      season: 2,
      episode: 6,
      accent: Color(0xFFB388FF),
    ),
    Moment(
      id: 'kali',
      kind: MomentKind.reveal,
      title: 'Subject 008',
      setup:
          'Eleven follows a vision to Chicago and finds a gang led by a woman '
          'who paints illusions and calls herself Kali.',
      reveal:
          'Kali is Eight - another of Brenner\'s children, with her own powers '
          'and her own vendetta. She tries to turn Eleven toward revenge. '
          'Eleven goes home instead.',
      why:
          'The polarising detour that defines Eleven by what she refuses to '
          'become - and it plants the sister the finale will need.',
      season: 2,
      episode: 7,
      accent: Color(0xFF8E4585),
    ),
    Moment(
      id: 'hopper_hid',
      kind: MomentKind.betrayal,
      title: '353 Days',
      setup:
          'Every night for almost a year, Mike radios Eleven. Every night, '
          'nobody answers.',
      reveal:
          'She was alive the whole time, hidden in Hopper\'s cabin and told '
          'never to make contact. When they finally reunite, Mike turns on '
          'Hopper: three hundred and fifty-three days.',
      why:
          'Hopper\'s rules kept Eleven alive and broke two kids\' hearts doing '
          'it - protection and control in the same gesture.',
      season: 2,
      episode: 8,
      accent: Color(0xFF63B3FF),
    ),
    Moment(
      id: 'bob',
      kind: MomentKind.sacrifice,
      title: 'Bob Newby, Superhero',
      setup:
          'Bob, Joyce\'s sweet, nerdy boyfriend, volunteers to reset the '
          'lab\'s breakers so everyone can get out. He knows BASIC. He knows '
          'the way.',
      reveal:
          'He gets the doors open, runs for the exit - and is pulled down by '
          'demodogs in front of Joyce, a few feet from safety.',
      why:
          'The show kills its one truly good, truly normal adult. Bob is the '
          'guy who would have been a great dad, and the Upside Down does not '
          'care.',
      season: 2,
      episode: 8,
      accent: Color(0xFFB9F6CA),
    ),

    // ---------------- Season 3 · Summer 1985 ----------------
    Moment(
      id: 'robin_out',
      kind: MomentKind.reveal,
      title: 'The Bathroom Floor',
      setup:
          'Drugged and hiding in a movie-theatre bathroom, Steve tells Robin '
          'he might be falling for her. Robin tells him about her crush.',
      reveal:
          'Her crush was Tammy Thompson. Robin comes out to Steve on the '
          'bathroom floor, and he takes a beat - then chooses her friendship, '
          'completely.',
      why:
          'The show refuses the expected romance and gives Robin something '
          'better: the first person in 1985 Hawkins who gets to know her, and '
          'a friend who shows up anyway.',
      season: 3,
      episode: 7,
      accent: Color(0xFF4DD0E1),
    ),
    Moment(
      id: 'alexei',
      kind: MomentKind.irony,
      title: 'Cherry Slurpee',
      setup:
          'Alexei, the captured Russian scientist, finally relaxes at the Fun '
          'Fair with Murray - winning a stuffed Woody Woodpecker, cherry '
          'Slurpee in hand.',
      reveal:
          'A Soviet assassin shoots him dead in the crowd, on the happiest day '
          'of his life in America.',
      why:
          'The enemy everyone feared turns out to be a sweet man who loved '
          'cartoons. Fans have not forgiven the show.',
      season: 3,
      episode: 7,
      accent: Color(0xFFE53935),
    ),
    Moment(
      id: 'billy',
      kind: MomentKind.sacrifice,
      title: 'The Bully Dies a Hero',
      setup:
          'Billy, flayed and the Mind Flayer\'s host, walks toward Eleven with '
          'the monster behind his eyes.',
      reveal:
          'She reminds him of a memory - his mother, a beach. He fights it, '
          'plants his feet, and takes the Mind Flayer\'s tendrils meant for '
          'Eleven. He dies telling Max he is sorry.',
      why:
          'The character you are built to hate spends his last seconds '
          'redeeming himself, and the grief Max carries afterward is real '
          'because the anger was too.',
      season: 3,
      episode: 8,
      accent: Color(0xFFFF6E40),
    ),
    Moment(
      id: 'hopper_faked',
      kind: MomentKind.twist,
      title: 'The American',
      setup:
          'Hopper is caught in the blast that shuts the machine down. Eleven '
          'reads the letter he wrote her. The Byers leave Hawkins.',
      reveal:
          'After the credits, Soviet guards in Kamchatka drag a prisoner past '
          'a cell - "not the American". Hopper is alive.',
      why:
          'The season plays a genuine death, holds the grief for a full '
          'episode, then snaps it away in a stinger. Bold, manipulative, and '
          'it earned the roar.',
      season: 3,
      episode: 8,
      accent: Color(0xFF8D8D8D),
    ),

    // ---------------- Season 4 · March 1986 ----------------
    Moment(
      id: 'chrissy',
      kind: MomentKind.irony,
      title: 'Chrissy at the Trailer',
      setup:
          'Cheerleader Chrissy Cunningham, haunted by visions, goes to Eddie '
          'Munson\'s trailer to buy something to make them stop.',
      reveal:
          'Vecna lifts her into the air and breaks her in front of him. Eddie '
          'runs - and Hawkins decides the Hellfire Club is a satanic cult.',
      why:
          'The town hunts the D&D kid while the real monster walks free. '
          'Every 80s moral panic, in one night.',
      season: 4,
      episode: 1,
      accent: Color(0xFFFF6482),
    ),
    Moment(
      id: 'victor',
      kind: MomentKind.reveal,
      title: 'The Man in Pennhurst',
      setup:
          'Nancy and Robin talk their way into an asylum to meet Victor Creel, '
          'the man convicted of murdering his family in 1959.',
      reveal:
          'Victor survived the same curse - because music pulled him out of '
          'it. The clue reaches Max\'s friends just in time.',
      why:
          'The answer to the season was locked in a madhouse with a man the '
          'whole town decided was a monster.',
      season: 4,
      episode: 4,
      accent: Color(0xFF90A4AE),
    ),
    Moment(
      id: 'dear_billy',
      kind: MomentKind.sacrifice,
      title: 'Running Up That Hill',
      setup:
          'Max is Vecna\'s chosen victim. Her eyes go white, her body lifts, '
          'and her friends can only watch.',
      reveal:
          'Lucas puts her Walkman on her. The song reaches her inside Vecna\'s '
          'mindscape, and she runs - out of his grip and back to her friends.',
      why:
          'A rescue built entirely from love and a Kate Bush song. It made '
          'a 1985 track a number-one hit again in 2022.',
      season: 4,
      episode: 4,
      accent: Color(0xFFFF5C8A),
    ),
    Moment(
      id: 'vecna_identity',
      kind: MomentKind.twist,
      title: 'The Monster Has a Name',
      setup:
          'Eleven relives 1979 in the Nina Project: the orderly who was kind '
          'to her, the Rainbow Room, the other children.',
      reveal:
          'The orderly is Henry Creel - Subject One. He killed his family, then '
          'the lab. Eleven sent him into the Upside Down, and he came back as '
          'Vecna.',
      why:
          'The ultimate evil is not an alien but the first of Brenner\'s '
          'children - and Eleven made him what he is.',
      season: 4,
      episode: 7,
      accent: Color(0xFF8E4585),
    ),
    Moment(
      id: 'van_speech',
      kind: MomentKind.irony,
      title: 'The Painting',
      setup:
          'In the back of a pizza van, Will tells Mike that Eleven '
          'commissioned the painting he made for her.',
      reveal:
          'Eleven never asked for it. Every word Will says about being '
          'different and afraid of losing Mike is about himself.',
      why:
          'A love confession disguised as a pep talk, delivered to the one '
          'person who can\'t hear it. Will turns to the window and cries.',
      season: 4,
      episode: 8,
      accent: Color(0xFFB388FF),
    ),
    Moment(
      id: 'papa',
      kind: MomentKind.irony,
      title: 'Goodbye, Papa',
      setup:
          'Brenner - the man who tortured and "raised" Eleven - is gunned down '
          'in the desert by the soldiers sent to kill her.',
      reveal:
          'Dying in the dirt, he looks to Eleven for forgiveness. She gives '
          'him a goodbye instead - "Goodbye, Papa" - and walks away.',
      why:
          'The villain of Season 1 dies asking for a love he never earned, '
          'and the girl he made finally chooses for herself.',
      season: 4,
      episode: 8,
      accent: Color(0xFF90A4AE),
    ),
    Moment(
      id: 'eddie',
      kind: MomentKind.sacrifice,
      title: 'The Freak Plays On',
      setup:
          'Eddie Munson, outcast and Hellfire\'s Dungeon Master, has to draw the '
          'demobats away from the Creel house in the Upside Down.',
      reveal:
          'He shreds "Master of Puppets" on the roof of his trailer, then stays '
          'to fight instead of running. He dies in Dustin\'s arms.',
      why:
          'The boy the town wanted to convict is the one who bought his '
          'friends their escape - and Hawkins will never know.',
      season: 4,
      episode: 9,
      accent: Color(0xFFEF5350),
    ),
    Moment(
      id: 'max_dies',
      kind: MomentKind.sacrifice,
      title: 'Vecna Wins',
      setup:
          'Max lets Vecna take her so Eleven can find him in her mind. The '
          'plan works - until it doesn\'t.',
      reveal:
          'Vecna breaks Max\'s bones and her heart stops. Eleven restarts it, '
          'but Max is left blind and in a coma - and the fourth chime splits '
          'Hawkins open.',
      why:
          'The first season to end in defeat: the heroes survive, the town '
          'does not, and the Upside Down is now leaking into the real world.',
      season: 4,
      episode: 9,
      accent: Color(0xFFFF5C8A),
    ),

    // ---------------- Season 5 · November 1987 ----------------
    Moment(
      id: 'will_1983',
      kind: MomentKind.reveal,
      title: 'What Happened to Will',
      setup:
          'November 1983, the night Will vanished. For the first time, we see '
          'where the Demogorgon took him.',
      reveal:
          'It carried him to Vecna, who left part of himself inside the boy. '
          'Will\'s "true sight", his visions, his chill - all of it was Vecna, '
          'from the very first episode.',
      why:
          'The final season rewrites the first one. The boy everyone rescued '
          'was marked before they ever found him.',
      season: 5,
      episode: 1,
      accent: Color(0xFFB388FF),
    ),
    Moment(
      id: 'holly',
      kind: MomentKind.twist,
      title: 'The Vanishing of Holly Wheeler',
      setup:
          'A Demogorgon smashes into the Wheeler house. Karen fights it with '
          'everything she has.',
      reveal:
          'It takes Holly anyway. And "Mr. Whatsit", the imaginary friend '
          'Holly talks about, is Henry Creel - he has been grooming her all '
          'along.',
      why:
          'The show opened with a child vanishing and returns to it for its '
          'final act - now aimed at the youngest Wheeler.',
      season: 5,
      episode: 2,
      accent: Color(0xFFC62828),
    ),
    Moment(
      id: 'sorcerer',
      kind: MomentKind.reveal,
      title: 'Will the Wise',
      setup:
          'Demogorgons corner Will\'s friends. Will has spent four years being '
          'the one who needs saving.',
      reveal:
          'He reaches into the hive mind Vecna planted in him and turns it '
          'back on the monsters. Will has powers, and he saves them all.',
      why:
          'The kid who played a wizard in the first scene of the series '
          'finally gets to cast the spell.',
      season: 5,
      episode: 4,
      accent: Color(0xFF63B3FF),
    ),
    Moment(
      id: 'kali_returns',
      kind: MomentKind.reveal,
      title: 'The Lost Sister Returns',
      setup:
          'Hopper and Eleven raid the military base to find who Dr. Kay is '
          'holding there.',
      reveal:
          'It\'s Kali. The military has been using her blood for its '
          'experiments. Eleven is no longer the only one left.',
      why:
          'The polarising Season 2 detour becomes a load-bearing piece of '
          'the finale.',
      season: 5,
      episode: 4,
      accent: Color(0xFF8E4585),
    ),
    Moment(
      id: 'karen',
      kind: MomentKind.irony,
      title: 'Karen Wheeler, Action Hero',
      setup:
          'Vecna sends demodogs after Max\'s comatose body at the hospital. '
          'The only adult in the room is Karen Wheeler.',
      reveal:
          'She blows them up with a laundry machine.',
      why:
          'The mom who spent four seasons in the background of her own '
          'house becomes the reason Max survives.',
      season: 5,
      episode: 6,
      accent: Color(0xFFFF9F0A),
    ),
    Moment(
      id: 'wormhole',
      kind: MomentKind.reveal,
      title: 'The Upside Down Is a Bridge',
      setup:
          'Nancy shoots a strange sphere in the Upside Down lab, and the '
          'building starts to melt around her and Jonathan.',
      reveal:
          'Dustin explains: the Upside Down isn\'t a world, it\'s a wormhole - '
          'held open by exotic matter in that sphere - leading somewhere else '
          'entirely. The Abyss.',
      why:
          'Five seasons in, the place everyone has been fighting in turns out '
          'to be a hallway.',
      season: 5,
      episode: 6,
      accent: Color(0xFF00E5FF),
    ),
    Moment(
      id: 'will_out',
      kind: MomentKind.reveal,
      title: 'Will Tells Them',
      setup:
          'It\'s the fourth anniversary of the night Will vanished. The Party '
          'gathers before the end.',
      reveal:
          'Will comes out to his friends. They stay exactly where they are: '
          'with him.',
      why:
          'After four seasons of subtext, the series gives its title '
          'character his own words - on the date that started everything.',
      season: 5,
      episode: 7,
      accent: Color(0xFFB388FF),
    ),
    Moment(
      id: 'kali_dies',
      kind: MomentKind.sacrifice,
      title: 'Eight',
      setup:
          'Kali and Max help Eleven into Henry\'s mind for the last fight while '
          'soldiers close in on the lab.',
      reveal:
          'Akers\' forces storm the lab and kill Kali. Eleven turns on them.',
      why:
          'The sister who wanted revenge dies helping Eleven save the world '
          'instead.',
      season: 5,
      episode: 8,
      accent: Color(0xFF8E4585),
    ),
    Moment(
      id: 'joyce_ends',
      kind: MomentKind.irony,
      title: 'Joyce Finishes It',
      setup:
          'In the Abyss, Will learns the truth: Henry let a fragment of the '
          'Mind Flayer into himself long ago. The Mind Flayer rises - and '
          'falls.',
      reveal:
          'Eleven and Will overpower the dying Henry Creel, and it is Joyce '
          'Byers who ends him.',
      why:
          'The mother everyone called crazy in 1983, stringing up Christmas '
          'lights, is the one who kills the monster.',
      season: 5,
      episode: 8,
      accent: Color(0xFFFFCC00),
    ),
    Moment(
      id: 'el_stays',
      kind: MomentKind.sacrifice,
      title: 'Eleven Stays Behind',
      setup:
          'The bomb is set. The Party climbs back to the right side up as the '
          'Upside Down starts to collapse.',
      reveal:
          'Eleven doesn\'t come with them. She stays as it falls apart, and '
          'the Upside Down is gone for good.',
      why:
          'The series began with a girl escaping a lab and ends with her '
          'choosing where to stand.',
      season: 5,
      episode: 8,
      accent: Color(0xFFF09CB8),
    ),
    Moment(
      id: 'last_campaign',
      kind: MomentKind.irony,
      title: 'The Last Campaign',
      setup:
          'Eighteen months later. Graduation. Hopper proposes to Joyce. The '
          'Party meets in the Wheeler basement one more time.',
      reveal:
          'They finish their Dungeons & Dragons campaign, and Mike offers a '
          'theory: Eleven might still be alive. They choose to believe him.',
      why:
          'The show ends where it started - kids at a table in a basement, '
          'rolling dice - only now they know the monsters were real.',
      season: 5,
      episode: 8,
      accent: Color(0xFFE50914),
    ),
  ];
}
