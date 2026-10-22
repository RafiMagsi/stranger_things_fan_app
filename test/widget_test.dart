import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stranger_things_fan_app/core/state/app_state.dart';
import 'package:stranger_things_fan_app/core/theme/app_theme.dart';
import 'package:stranger_things_fan_app/data/characters.dart' as cast_data;
import 'package:stranger_things_fan_app/data/quiz.dart';
import 'package:stranger_things_fan_app/models/quiz_question.dart';
import 'package:stranger_things_fan_app/screens/bestiary_screen.dart';
import 'package:stranger_things_fan_app/screens/character_detail_screen.dart';
import 'package:stranger_things_fan_app/screens/home_screen.dart';
import 'package:stranger_things_fan_app/screens/locations_screen.dart';
import 'package:stranger_things_fan_app/screens/quiz_screen.dart';
import 'package:stranger_things_fan_app/screens/quotes_screen.dart';
import 'package:stranger_things_fan_app/screens/seasons_screen.dart';
import 'package:stranger_things_fan_app/screens/soundboard_screen.dart';
import 'package:stranger_things_fan_app/screens/timeline_screen.dart';

Widget _wrap({required Widget child}) =>
    ProviderScope(child: MaterialApp(home: child));

/// Wraps a widget in a MaterialApp that reacts to the world-mode provider,
/// mimicking the real app's theme wiring.
Widget _worldWrap({required Widget child}) => ProviderScope(
      child: Consumer(
        builder: (context, ref, _) {
          final upsideDown = ref.watch(worldModeProvider);
          return MaterialApp(
            theme: AppTheme.hawkins,
            darkTheme: AppTheme.upsideDown,
            themeMode: upsideDown ? ThemeMode.dark : ThemeMode.light,
            home: child,
          );
        },
      ),
    );

void main() {
  testWidgets('Home renders the hub sections and the world toggle',
      (tester) async {
    await tester.pumpWidget(_wrap(child: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('STRANGER THINGS'), findsOneWidget);
    // SectionHeader uppercases its title.
    expect(find.text('MEET THE PARTY'), findsOneWidget);
    expect(find.byKey(const ValueKey('world-toggle')), findsOneWidget);

    // Reveal the Explore header + first rows of tiles.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -520));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('EXPLORE'), findsOneWidget);
    expect(find.text('Seasons'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);

    // Row 3: Bestiary + Quotes are adjacent; scroll to that row.
    await tester.scrollUntilVisible(
      find.text('Quotes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Bestiary'), findsOneWidget);
    expect(find.text('Quotes'), findsOneWidget);

    // Last row: Trivia + Soundboard.
    await tester.scrollUntilVisible(
      find.text('Soundboard'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Soundboard'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('FROM THE UPSIDE DOWN'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('FROM THE UPSIDE DOWN'), findsOneWidget);
  });

  testWidgets('World toggle flips MaterialApp to dark (Upside Down)',
      (tester) async {
    await tester.pumpWidget(_worldWrap(child: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // MaterialApp's AnimatedTheme eases between themes, so assert on the
    // deterministic themeMode wired up by the Consumer instead.
    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);

    await tester.tap(find.byKey(const ValueKey('world-toggle')));
    await tester.pump(const Duration(milliseconds: 700));

    expect(app().themeMode, ThemeMode.dark);

    final context = tester.element(find.byType(HomeScreen));
    expect(
      ProviderScope.containerOf(context, listen: false).read(worldModeProvider),
      isTrue,
    );
  });

  testWidgets('Character detail shows name, stats, skills', (tester) async {
    await tester.pumpWidget(
      _wrap(child: CharacterDetailScreen(character: cast_data.Cast.eleven)),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('ELEVEN'), findsOneWidget);
    // SectionHeader uppercases its title.
    expect(find.text('FIELD STATS'), findsOneWidget);
    expect(find.text('KNOWN FOR'), findsOneWidget);
    expect(find.text('Telekinesis'), findsOneWidget);
    expect(find.textContaining('Friends don'), findsOneWidget);
  });

  testWidgets('Seasons screen lists all five seasons and expands one',
      (tester) async {
    await tester.pumpWidget(_wrap(child: const SeasonsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // AnimatedCrossFade keeps both children mounted, so allow 2 matches.
    expect(find.text('SEASON 1'), findsWidgets);
    expect(find.text('The Vanishing of Will Byers'), findsNothing);

    // Scroll down to reveal Season 5.
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SEASON 5'), findsWidgets);

    // Scroll back up to expand Season 1.
    await tester.drag(find.byType(ListView), const Offset(0, 1600));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('SEASON 1').first);
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('The Vanishing of Will Byers'), findsOneWidget);
    expect(find.text('The Upside Down'), findsOneWidget);
  });

  testWidgets('Quiz shows a question, answers correctly, and reveals evidence',
      (tester) async {
    await tester.pumpWidget(_wrap(child: const QuizScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TRIVIA'), findsOneWidget);
    expect(find.textContaining('QUESTION 1 OF'), findsOneWidget);

    // Questions are shuffled, so find the correct answer by reading the
    // question text on screen and looking it up in the bank.
    final questionFinder = find.textContaining('QUESTION 1 OF');
    expect(questionFinder, findsOneWidget);

    // Find which bank question is on screen by matching an option label.
    QuizQuestion? current;
    for (final q in Quiz.bank) {
      if (tester.any(find.text(q.question))) {
        current = q;
        break;
      }
    }
    expect(current, isNotNull, reason: 'A known question should be visible');

    await tester.tap(find.byKey(ValueKey('quiz-option-${current!.options[current.correctIndex]}')));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('CORRECT'), findsOneWidget);
    expect(find.text(current.fact), findsOneWidget);
  });

  testWidgets('Soundboard renders its clips', (tester) async {
    await tester.pumpWidget(_wrap(child: const SoundboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SOUNDBOARD'), findsOneWidget);
    expect(find.text('Hawkins Theme'), findsOneWidget);
    expect(find.text('The D20'), findsOneWidget);
    expect(find.text('Eleven\'s Power'), findsOneWidget);
    expect(find.text('Vecna\'s Clock'), findsOneWidget);
  });

  testWidgets('Timeline renders the chronology beats', (tester) async {
    await tester.pumpWidget(_wrap(child: const TimelineScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TIMELINE'), findsOneWidget);
    expect(find.text('Will vanishes'), findsOneWidget);

    // The final beat is below the fold; scroll to reveal.
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('The rightside up'), findsOneWidget);
  });

  testWidgets('Locations renders the Hawkins map', (tester) async {
    await tester.pumpWidget(_wrap(child: const LocationsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HAWKINS MAP'), findsOneWidget);
    expect(find.text('Hawkins National Laboratory'), findsOneWidget);

    // Starcourt is further down the map; scroll to reveal.
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Starcourt Mall'), findsOneWidget);
  });

  testWidgets('Bestiary renders creatures with threat meters', (tester) async {
    await tester.pumpWidget(_wrap(child: const BestiaryScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('BESTIARY'), findsOneWidget);
    expect(find.text('Demogorgon'), findsOneWidget);
    expect(find.textContaining('Weakness:'), findsWidgets);

    // Vecna is further down the list; scroll to reveal.
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Vecna'), findsOneWidget);
  });

  testWidgets('Quotes renders the wall of lines', (tester) async {
    await tester.pumpWidget(_wrap(child: const QuotesScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('QUOTES'), findsOneWidget);
    expect(find.text('Friends don\'t lie.'), findsOneWidget);
    // Eleven has two lines on the wall.
    expect(find.text('ELEVEN'), findsWidgets);
  });

  testWidgets('World mode provider toggles on and off', (tester) async {
    await tester.pumpWidget(_wrap(child: const HomeScreen()));
    final context = tester.element(find.byType(HomeScreen));
    final container = ProviderScope.containerOf(context, listen: false);

    expect(container.read(worldModeProvider), isFalse);
    container.read(worldModeProvider.notifier).toggle();
    expect(container.read(worldModeProvider), isTrue);
    container.read(worldModeProvider.notifier).toggle();
    expect(container.read(worldModeProvider), isFalse);
  });
}
