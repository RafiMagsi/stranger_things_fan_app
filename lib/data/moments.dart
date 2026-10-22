import 'package:flutter/material.dart';

import '../models/moment.dart';

/// The moments fans still argue about: the twists, the reveals, the gut
/// punches, and the running gags. Each is split into a safe [Moment.setup]
/// and a veiled [Moment.reveal] so nobody gets spoiled by accident.
class Moments {
  Moments._();

  static const List<Moment> all = [
    // ---------------- Season 1 ----------------
    Moment(
      id: 'barb',
      kind: MomentKind.irony,
      title: 'Justice for Barb',
      setup:
          'Nancy\'s friend Barb waits in the car while Nancy goes inside with '
          'Steve. A light flickers. Barb is gone.',
      reveal:
          'Barb is dead within hours — and by the next episode, almost no one '
          'is looking for her. The town holds a prayer vigil for Will and '
          'shrugs at Barb.',
      why:
          'The show weaponizes its own indifference: Barb\'s erasure becomes '
          'the season\'s quiet indictment of who a town decides is worth '
          'mourning. The internet noticed.',
      season: 1,
      episode: 2,
      accent: Color(0xFF4DD0E1),
    ),
    Moment(
      id: 'fake_body',
      kind: MomentKind.twist,
      title: 'The Body in the Quarry',
      setup:
          'A body is pulled from the quarry. The face is Will\'s. Joyce '
          'screams. Hopper holds her back.',
      reveal:
          'It isn\'t Will. It\'s a translucent mold the Upside Down grew '
          'around him — a lure. The real Will is still alive, on the other '
          'side, pounding on a wall no one can hear.',
      why:
          'A fake-out death inside a fake-out death. The audience grieves a '
          'boy who isn\'t dead, which is exactly the trick the Upside Down '
          'plays on the town.',
      season: 1,
      episode: 4,
      accent: Color(0xFFEF5350),
    ),
    Moment(
      id: 'gate_closed',
      kind: MomentKind.sacrifice,
      title: 'The Girl Who Closed the Gate',
      setup:
          'Eleven reaches the gate beneath the lab as the Demogorgon closes '
          'in on her friends. There is no other way.',
      reveal:
          'She pours everything into sealing it — and is pulled away, '
          'seemingly dead. The season ends with the Party at a table, an '
          'empty chair where she should be.',
      why:
          'The victory that costs the hero. Eleven wins by losing herself, '
          'and the empty chair is the price tag the show refuses to look '
          'away from.',
      season: 1,
      episode: 8,
      accent: Color(0xFFF09CB8),
    ),

    // ---------------- Season 2 ----------------
    Moment(
      id: 'will_spy',
      kind: MomentKind.twist,
      title: 'The Boy Who Came Back Wrong',
      setup:
          'Will is home, safe, drawing maps of the tunnels. He keeps seeing '
          'the shadow. He keeps being right.',
      reveal:
          'Will never really escaped. The Mind Flayer left a piece of itself '
          'in him — he is its camera, its microphone, its spy. Every drawing '
          'was intel the enemy was feeding him.',
      why:
          'The rescued child is the Trojan horse. The people who love him '
          'most are nursing the very thing that is hunting them.',
      season: 2,
      episode: 6,
      accent: Color(0xFFB388FF),
    ),
    Moment(
      id: 'bob',
      kind: MomentKind.sacrifice,
      title: 'Bob Newby, Superhero',
      setup:
          'Bob, Joyce\'s new boyfriend and the least likely man in Hawkins, '
          'leads the group out of the lab through the dark. He knows the '
          'code. He knows the way.',
      reveal:
          'He holds the door and dies on the floor of the lab, hands '
          'useless, while Joyce is dragged away screaming. He was so close '
          'to being a hero, and he was one — just not a survivor.',
      why:
          'The show kills its one truly good, truly normal adult. Bob is the '
          'guy who would have been a great dad, and the Upside Down does not '
          'care.',
      season: 2,
      episode: 8,
      accent: Color(0xFFB9F6CA),
    ),
    Moment(
      id: 'kali',
      kind: MomentKind.reveal,
      title: 'Subject 008',
      setup:
          'Eleven follows a vision to Chicago and finds a gang led by a woman '
          'who paints illusions and calls herself Kali.',
      reveal:
          'Kali is Eight — another of Brenner\'s children, with her own powers '
          'and her own vendetta. She tries to turn Eleven toward revenge. '
          'Eleven walks back to Hawkins instead.',
      why:
          'The polarizing detour that defines Eleven by what she refuses to '
          'become. The path not taken, taken for one episode so she can '
          'choose her family over her fury.',
      season: 2,
      episode: 7,
      accent: Color(0xFF8E4585),
    ),

    // ---------------- Season 3 ----------------
    Moment(
      id: 'robin_out',
      kind: MomentKind.reveal,
      title: 'The Bathroom Floor',
      setup:
          'Drunk and shaking off the Russian truth, Robin talks Steve '
          'through her teenage crush — a girl who played flute. Steve leans '
          'in. The moment is there.',
      reveal:
          '"She was a girl." Robin isn\'t talking about a boy. She comes out '
          'to Steve on a bathroom floor, and he fumbles, then chooses her. '
          'They end up siblings-in-arms, not a couple.',
      why:
          'The show refuses the expected romance and gives Robin something '
          'better: the first person in 1985 Hawkins who gets to be fully '
          'herself, and a friend who shows up anyway.',
      season: 3,
      episode: 7,
      accent: Color(0xFF4DD0E1),
    ),
    Moment(
      id: 'billy',
      kind: MomentKind.sacrifice,
      title: 'The Bully Dies a Hero',
      setup:
          'Billy, racist tormentor and the season\'s worst man, is infected '
          'and used as the Flayed\'s vessel. He walks toward Eleven with the '
          'monster behind his eyes.',
      reveal:
          'He fights it — for Max. He plants his feet, takes the Mind '
          'Flayer\'s skewer meant for Eleven, and dies in his sister\'s arms '
          'after an apology she waited her whole life to hear.',
      why:
          'The show\'s coldest irony: the character you are built to hate '
          'spends his last seconds redeeming himself, and the grief Max '
          'carries afterward is real because the anger was too.',
      season: 3,
      episode: 8,
      accent: Color(0xFFFF6E40),
    ),
    Moment(
      id: 'hopper_faked',
      kind: MomentKind.twist,
      title: 'The Post-Credits Reveal',
      setup:
          'Hopper is caught in the blast that closes the gate. A memorial '
          'follows. Joyce finds a letter he left her. He is gone.',
      reveal:
          'After the credits, a Soviet guard feeds a prisoner bread and '
          'calls him "the American." The prisoner looks up. It\'s Hopper — '
          'alive, in a Russian gulag.',
      why:
           'The season plays a genuine death, holds the grief for a full '
           'episode, then snaps it away in a post-credits stinger. Bold, '
           'manipulative, and it earned the roar.',
      season: 3,
      episode: 8,
      accent: Color(0xFF8D8D8D),
    ),

    // ---------------- Season 4 ----------------
    Moment(
      id: 'vecna_identity',
      kind: MomentKind.twist,
      title: 'The Monster Has a Name',
      setup:
          'Vecna hunts across Hawkins, killing with a grandfather clock and '
          'a voice full of judgment. No one knows what he is.',
      reveal:
          'He is Henry Creel — Subject One — the very first of Brenner\'s '
          'children, the boy who survived his own family and remade reality. '
          'The Mind Flayer is his idea of a god. He is Eleven\'s brother in '
          'all but blood.',
      why:
          'The franchise folds its own mythology inward: the ultimate evil '
          'is not an alien but a sibling. Everything traces back to one '
          'broken boy in one laboratory.',
      season: 4,
      episode: 7,
      accent: Color(0xFF8E4585),
    ),
    Moment(
      id: 'dear_billy',
      kind: MomentKind.sacrifice,
      title: 'Running Up That Hill',
      setup:
          'Max is Vecna\'s chosen victim. Her eyes go white, her body lifts, '
          'her friends can only watch. The clock has struck twelve.',
      reveal:
          'Lucas talks to her. The mixtape plays. Max clawed her way back to '
          'the one memory bright enough to beat the curse — a beach, her '
          'brother before the monster — and physically turns away from '
          'Vecna. She survives. Barely.',
      why:
          'A rescue built entirely from love and a Kate Bush song. Max lives, '
          'but the price is real: she is left blind and broken, so the win '
          'never costs nothing.',
      season: 4,
      episode: 4,
      accent: Color(0xFFFF5C8A),
    ),
    Moment(
      id: 'eddie',
      kind: MomentKind.sacrifice,
      title: 'The Freak Plays On',
      setup:
          'Eddie Munson, outcast and Hellfire\'s DM, runs from the swarm into '
          'the one place he swore never to go — the Upside Down. He is '
          'cornered, unarmed, and done running.',
      reveal:
          'He rips out a riff on his guitar to lure the demo-bats away from '
          'his friends, fights to the last, and dies on a hill the town will '
          'blame him for anyway. Dustin holds him at the end.',
      why:
          'The boy the town would have convicted is the one who bought his '
          'friends their escape with the only weapon he ever trusted. The '
          'song is the suicide note of a man who finally stopped hiding.',
      season: 4,
      episode: 9,
      accent: Color(0xFFEF5350),
    ),
    Moment(
      id: 'papa',
      kind: MomentKind.irony,
      title: 'Goodbye, Papa',
      setup:
          'Brenner — the man who tortured and "raised" Eleven — is broken and '
          'helpless, strapped to a chair in the desert as the military closes '
          'in.',
      reveal:
          'He saves Eleven one last time with a mask he can speak through, '
          'then dies in the dirt. Eleven, his greatest victim, is the only '
          'one who mourns him.',
      why:
           'The monster of Seasons 1 and 4 dies a hero, and the girl he made '
           'still calls him Papa. The show denies everyone a clean feeling.',
      season: 4,
      episode: 8,
      accent: Color(0xFF90A4AE),
    ),
    Moment(
      id: 'wills_birthday',
      kind: MomentKind.irony,
      title: 'The Boy Who Keeps Dying',
      setup:
          'It\'s Will\'s birthday. He is quiet. He paints a gift for Mike. '
          'Everyone remembers the day he vanished.',
      reveal:
          'Almost no one remembers the day he *didn\'t*. Will\'s sexuality, '
          'his grief, his unrequited love for Mike — all of it sits under a '
          'pizza party no one threw for him.',
      why:
          'The irony that never lets up: the boy the whole series is named '
          'for keeps being left in the background, still the kid who was '
          'left behind.',
      season: 4,
      episode: 1,
      accent: Color(0xFFB388FF),
    ),

    // ---------------- Season 5 ----------------
    Moment(
      id: 'holly',
      kind: MomentKind.twist,
      title: 'The Vanishing of Holly Wheeler',
      setup:
          'Holly, the youngest Wheeler, follows a sound into the dark like a '
          'child in 1983. Her mother turns around and she is simply gone.',
      reveal:
          'Taken into the Upside Down and remade — the same nightmare that '
          'started the whole series, now aimed at the last innocent left in '
          'it. The cycle the Party has fought since childhood comes for the '
          'next generation.',
      why:
          'History rhyming: the show opens with a child vanishing and returns '
          'to it in its final act, forcing the kids who survived to watch '
          'their own story repeat through a younger sister\'s eyes.',
      season: 5,
      episode: 2,
      accent: Color(0xFFC62828),
    ),
  ];
}
