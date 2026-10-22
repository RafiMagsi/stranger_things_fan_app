import '../models/quiz_question.dart';

/// Trivia drawn from all five seasons. Each answer ships with an "evidence"
/// blurb so a wrong tap still teaches the fan something.
class Quiz {
  Quiz._();

  static const List<QuizQuestion> bank = [
    // ---- Season 1 ----
    QuizQuestion(
      question: 'What monster attacks the Party in Mike\'s campaign in the very first scene?',
      options: ['The Mind Flayer', 'The Demogorgon', 'Vecna', 'The Thessalhydra'],
      correctIndex: 1,
      fact: 'Will rolls a seven and the Demogorgon gets him - so the boys name the real creature after it.',
    ),
    QuizQuestion(
      question: 'Where do the boys first find Eleven?',
      options: [
        'Hawkins National Lab',
        'Benny\'s Burgers',
        'In the woods, searching for Will',
        'The Byers\' shed',
      ],
      correctIndex: 2,
      fact: 'Mike, Lucas and Dustin find her soaked in the rain-dark woods while out looking for Will.',
    ),
    QuizQuestion(
      question: 'What does the alphabet wall spell when Joyce asks Will where he is?',
      options: ['HELP', 'RIGHT HERE', 'COME HOME', 'GO AWAY'],
      correctIndex: 1,
      fact: 'R-I-G-H-T H-E-R-E. Her next question gets a scarier answer: R-U-N.',
    ),
    QuizQuestion(
      question: 'Which song does Will sing to stay brave in the Upside Down?',
      options: [
        'Should I Stay or Should I Go',
        'Every Breath You Take',
        'Heroes',
        'Atmosphere',
      ],
      correctIndex: 0,
      fact: 'The Clash song Jonathan shared with him - with Eleven\'s help, the Party hears him singing it through the static.',
    ),
    QuizQuestion(
      question: 'Which food is Eleven\'s unofficial survival ration?',
      options: ['Eggo waffles', 'Pop-Tarts', 'Candy corn', 'Cheerios'],
      correctIndex: 0,
      fact: 'Eggos. She steals them from Bradley\'s Big Buy, and Hopper leaves them in the woods for her.',
    ),

    // ---- Season 2 ----
    QuizQuestion(
      question: 'What is the name of Dustin\'s pet from the Upside Down?',
      options: ['Dartagnan', 'Barb', 'Chester', 'Mews'],
      correctIndex: 0,
      fact: 'D\'Artagnan - "Dart" - after the Three Musketeers. Mews was the cat it ate.',
    ),
    QuizQuestion(
      question: 'What name is on the birth certificate Hopper gets for Eleven?',
      options: ['Jane Ives', 'Jane Hopper', 'Eleanor Hopper', 'El Byers'],
      correctIndex: 1,
      fact: 'Jane Hopper. "Jane" was the name her mother Terry Ives gave her.',
    ),
    QuizQuestion(
      question: 'Who closes the Gate at the end of Season 2?',
      options: ['Hopper', 'Eleven', 'Will', 'Mike'],
      correctIndex: 1,
      fact: 'Eleven seals it from the lab with Hopper beside her, while Joyce burns the Mind Flayer out of Will.',
    ),
    QuizQuestion(
      question: 'What is Hopper\'s job in Hawkins?',
      options: [
        'Diner owner',
        'Chief of police',
        'Lab security guard',
        'Truck driver',
      ],
      correctIndex: 1,
      fact: 'Chief of Police - badge, coffee, and a terrible personal life.',
    ),

    // ---- Season 3 ----
    QuizQuestion(
      question: 'What is Steve\'s summer job at Starcourt Mall?',
      options: [
        'Scoops Ahoy sailor',
        'RadioShack clerk',
        'Arcade attendant',
        'Food court cook',
      ],
      correctIndex: 0,
      fact: 'Scoops Ahoy - where Robin cracks the Russian code and the whole plot starts.',
    ),
    QuizQuestion(
      question: 'What does Dustin call the giant radio tower he builds at camp?',
      options: ['Cerebro', 'Suzie', 'Skynet', 'The Beacon'],
      correctIndex: 0,
      fact: 'Cerebro, after the X-Men machine. Suzie is the girlfriend on the other end.',
    ),
    QuizQuestion(
      question: 'Which song do Dustin and Suzie sing over the radio at the worst possible moment?',
      options: ['Take On Me', 'The NeverEnding Story', 'Africa', 'Ghostbusters'],
      correctIndex: 1,
      fact: 'The NeverEnding Story - while everyone waits for Suzie to recite Planck\'s constant.',
    ),
    QuizQuestion(
      question: 'What does the Party fight in the Starcourt finale?',
      options: [
        'The Demogorgon',
        'The Mind Flayer',
        'A demobat swarm',
        'Vecna himself',
      ],
      correctIndex: 1,
      fact: 'The Mind Flayer\'s flesh body - built from the flayed people of Hawkins.',
    ),

    // ---- Season 4 ----
    QuizQuestion(
      question: 'What song does Max listen to to escape Vecna\'s curse?',
      options: [
        'Should I Stay or Should I Go',
        'Every Breath You Take',
        'Running Up That Hill',
        'Heroes',
      ],
      correctIndex: 2,
      fact: 'Kate Bush\'s 1985 track - it became a number-one hit all over again in 2022.',
    ),
    QuizQuestion(
      question: 'Who runs the Hellfire Club at Hawkins High?',
      options: ['Mike Wheeler', 'Eddie Munson', 'Dustin Henderson', 'Lucas Sinclair'],
      correctIndex: 1,
      fact: 'Eddie Munson - Hellfire\'s Dungeon Master, in his third senior year.',
    ),
    QuizQuestion(
      question: 'What does Eddie play on his guitar to draw the demobats away?',
      options: [
        'Master of Puppets',
        'Eye of the Tiger',
        'Running Up That Hill',
        'Should I Stay or Should I Go',
      ],
      correctIndex: 0,
      fact: 'Metallica\'s "Master of Puppets", played on the roof of his trailer in the Upside Down.',
    ),
    QuizQuestion(
      question: 'Who was Vecna before he became Vecna?',
      options: ['Victor Creel', 'Martin Brenner', 'Henry Creel', 'Dr. Owens'],
      correctIndex: 2,
      fact: 'Henry Creel - Subject One, the first of Brenner\'s children.',
    ),

    // ---- Season 5 ----
    QuizQuestion(
      question: 'What does Holly Wheeler call her mysterious imaginary friend?',
      options: ['Mr. Whatsit', 'Mr. Clarke', 'Mr. Wizard', 'Mr. Bones'],
      correctIndex: 0,
      fact: 'Mr. Whatsit - who turns out to be Henry Creel.',
    ),
    QuizQuestion(
      question: 'What does Dustin work out the Upside Down really is?',
      options: [
        'A mirror world',
        'A wormhole to another dimension',
        'A shared dream',
        'A Soviet experiment',
      ],
      correctIndex: 1,
      fact: 'A wormhole held open by exotic matter - a bridge to the Abyss.',
    ),
    QuizQuestion(
      question: 'What is the final chapter of the series called?',
      options: ['The Crawl', 'The Bridge', 'The Rightside Up', 'The Turnbow Trap'],
      correctIndex: 2,
      fact: 'Chapter Eight: The Rightside Up - released New Year\'s Eve 2025.',
    ),
  ];
}
