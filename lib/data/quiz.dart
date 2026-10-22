import '../models/quiz_question.dart';

/// Trivia drawn from all five seasons. Each answer ships with an "evidence"
/// blurb so a wrong tap still teaches the fan something.
class Quiz {
  Quiz._();

  static const List<QuizQuestion> bank = [
    QuizQuestion(
      question: 'What does Eleven use to open cans of food in Season 1?',
      options: ['A knife', 'Her mind', 'A rock', 'Hopper\'s badge'],
      correctIndex: 1,
      fact: 'Telekinesis is her party trick - and her only weapon until the gate.',
    ),
    QuizQuestion(
      question: 'What song does Max listen to to escape Vecna\'s curse?',
      options: [
        'Should I Stay or Should I Go',
        'Every Breath You Take',
        'Running Up That Hill',
        'Heroes',
      ],
      correctIndex: 2,
      fact: 'Kate Bush\'s 1985 track became the lifeline that pulled Max back.',
    ),
    QuizQuestion(
      question: 'What is the name of Dustin\'s pet demodog?',
      options: ['Dartagnan', 'Barb', 'Chester', 'Fig'],
      correctIndex: 0,
      fact: 'He named it D\'Artagnan after the Three Musketeers - then it grew teeth.',
    ),
    QuizQuestion(
      question: 'Where do the kids first find Eleven?',
      options: [
        'Hawkins National Lab',
        'The Byers\' house',
        'A costume shop on Main Street',
        'The woods behind Wheeler\'s',
      ],
      correctIndex: 3,
      fact: 'The woods - eating a stolen Eggo, shaved head, borrowed blanket.',
    ),
    QuizQuestion(
      question: 'What letters spell out Will\'s message through the Christmas lights?',
      options: ['HERE', 'RUN', 'OUT', 'LIE'],
      correctIndex: 2,
      fact: 'Out. The lights lit letter by letter across the wall of the Byers\' living room.',
    ),
    QuizQuestion(
      question: 'What is Steve\'s job at Starcourt Mall?',
      options: [
        'Scoops Ahoy sailor',
        'RadioShack clerk',
        'Arcade attendant',
        'Food court cook',
      ],
      correctIndex: 0,
      fact: 'Scoops Ahoy - where the Russian code-breaking plot actually starts.',
    ),
    QuizQuestion(
      question: 'What does Nancy find inside the wall of her house?',
      options: [
        'A demogorgon nest',
        'A rotting tendril',
        'Barb\'s necklace',
        'A hidden switch',
      ],
      correctIndex: 1,
      fact: 'The rotting tendril - proof the Upside Down had rooted into Hawkins itself.',
    ),
    QuizQuestion(
      question: 'Which season introduces a villain targeting Hawkins High students?',
      options: ['Season 2', 'Season 3', 'Season 4', 'Season 5'],
      correctIndex: 2,
      fact: 'Vecna\'s curse chain drives all of Season 4 - one victim, one clock, every week.',
    ),
    QuizQuestion(
      question: 'What is Hopper\'s job while searching for answers?',
      options: [
        'Diner owner',
        'Hawkins police chief',
        'Lab security guard',
        'Truck driver',
      ],
      correctIndex: 1,
      fact: 'Chief of Police - badge, coffee, and a terrible personal life.',
    ),
    QuizQuestion(
      question: 'What does Robin accidentally decode in the Russian storage room?',
      options: [
        'A distress signal',
        'A fast-food order',
        'A soldier\'s love letter',
        'A launch code',
      ],
      correctIndex: 2,
      fact: 'The Russians were sending a love letter - which cracked the whole cipher.',
    ),
    QuizQuestion(
      question: 'Who closes the gate to the Upside Down at the end of Season 2?',
      options: ['Hopper', 'Eleven', 'Will', 'Mike'],
      correctIndex: 1,
      fact: 'Eleven poured everything into sealing the gate beneath the lab.',
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
      fact: 'The Mind Flayer\'s meat-avatar - built from the Flayed of Hawkins.',
    ),
    QuizQuestion(
      question: 'What is the final chapter of Season 5 called?',
      options: ['The Crawl', 'The Bridge', 'The Rightside Up', 'The Turnbow Trap'],
      correctIndex: 2,
      fact: 'The Rightside Up - the series finale that closes the gate for good.',
    ),
    QuizQuestion(
      question: 'Which food item is Eleven\'s unofficial survival ration?',
      options: ['Eggo waffles', 'Pop-Tarts', 'Candy corn', 'Cheerios'],
      correctIndex: 0,
      fact: 'Eggos. Hopper stocked the freezer before he knew what "family" meant.',
    ),
    QuizQuestion(
      question: 'Who runs the Hellfire Club at Hawkins High?',
      options: ['Mike Wheeler', 'Eddie Munson', 'Dustin Henderson', 'Lucas Sinclair'],
      correctIndex: 1,
      fact: 'Eddie Munson - Hellfire\'s DM, and Season 4\'s most metal casualty.',
    ),
  ];
}
