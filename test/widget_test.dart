import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stranger_things_fan_app/core/state/app_state.dart';
import 'package:stranger_things_fan_app/core/theme/app_theme.dart';
import 'package:stranger_things_fan_app/core/widgets/rift_route.dart';
import 'package:stranger_things_fan_app/core/widgets/st_logo.dart';
import 'package:stranger_things_fan_app/data/characters.dart' as cast_data;
import 'package:stranger_things_fan_app/data/credits.dart';
import 'package:stranger_things_fan_app/data/moments.dart';
import 'package:stranger_things_fan_app/data/quiz.dart';
import 'package:stranger_things_fan_app/data/seasons.dart';
import 'package:stranger_things_fan_app/data/timeline.dart';
import 'package:stranger_things_fan_app/models/quiz_question.dart';
import 'package:stranger_things_fan_app/screens/bestiary_screen.dart';
import 'package:stranger_things_fan_app/screens/character_detail_screen.dart';
import 'package:stranger_things_fan_app/screens/home_screen.dart';
import 'package:stranger_things_fan_app/screens/locations_screen.dart';
import 'package:stranger_things_fan_app/screens/moments_screen.dart';
import 'package:stranger_things_fan_app/screens/quiz_screen.dart';
import 'package:stranger_things_fan_app/screens/quotes_screen.dart';
import 'package:stranger_things_fan_app/screens/season_detail_screen.dart';
import 'package:stranger_things_fan_app/screens/seasons_screen.dart';
import 'package:stranger_things_fan_app/screens/soundboard_screen.dart';
import 'package:stranger_things_fan_app/screens/timeline_screen.dart';

Widget _wrap({required Widget child}) =>
    ProviderScope(child: MaterialApp(theme: AppTheme.hawkins, home: child));

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

/// Scrolls the first scrollable on screen until [finder] is built and visible.
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Lots of the cards are taller than the default 800x600 test surface; use
  // a phone-shaped one so layouts behave like they do on a device.
  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('Home renders the logo, the feed and every section tile',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(STLogo), findsOneWidget);
    expect(find.bySemanticsLabel('Stranger Things'), findsOneWidget);
    expect(find.byKey(const ValueKey('world-toggle')), findsOneWidget);
    expect(find.text('THE FINAL\nCHAPTER'), findsOneWidget);
    // Fresh install: the very first chapter is next up.
    expect(find.text('NEXT UP · S1 CHAPTER ONE'), findsOneWidget);
    expect(find.text('MEET THE PARTY'), findsOneWidget);

    for (final title in [
      'EXPLORE',
      'Seasons',
      'The Cast',
      'Transmissions',
      'Timeline',
      'Hawkins Map',
      'Bestiary',
      'Moments',
      'Quotes',
      'Trivia',
      'Soundboard',
      'FROM THE UPSIDE DOWN',
    ]) {
      await _scrollTo(tester, find.text(title));
      expect(find.text(title), findsOneWidget, reason: title);
    }
  });

  testWidgets('World toggle flips MaterialApp to dark (Upside Down)',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_worldWrap(child: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // MaterialApp's AnimatedTheme eases between themes, so assert on the
    // deterministic themeMode wired up by the Consumer instead.
    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);
    expect(find.text('Hawkins, Indiana · 1983-1989'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('world-toggle')));
    await tester.pump(const Duration(milliseconds: 700));

    expect(app().themeMode, ThemeMode.dark);
    expect(find.text('You are in the Upside Down'), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    expect(
      ProviderScope.containerOf(context, listen: false).read(worldModeProvider),
      isTrue,
    );
  });

  testWidgets('Character detail shows name, stats, skills', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: CharacterDetailScreen(character: cast_data.Cast.eleven)),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('ELEVEN'), findsOneWidget);
    expect(find.text('played by Millie Bobby Brown'), findsOneWidget);
    expect(find.text('CLASSIFIED'), findsOneWidget);

    // SectionHeader uppercases its title.
    await _scrollTo(tester, find.text('FIELD STATS'));
    await _scrollTo(tester, find.text('Telekinesis'));
    expect(find.text('KNOWN FOR'), findsOneWidget);
    await _scrollTo(tester, find.textContaining('Friends don'));
    // The portrait is credited, as its licence requires.
    await _scrollTo(tester, find.textContaining('Portrait: Millie Bobby Brown'));
  });

  testWidgets('Seasons lists all five and tears open into a watch guide',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const SeasonsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SEASON 1'), findsWidgets);
    expect(find.text('The Vanishing of Will Byers'), findsNothing);

    // Scroll down to reveal Season 5.
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SEASON 5'), findsWidgets);

    // Scroll back up and open Season 1.
    await tester.drag(find.byType(ListView), const Offset(0, 1600));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('SEASON 1').first);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SeasonDetailScreen), findsOneWidget);
    expect(find.text('SEASON ONE'), findsOneWidget);
    expect(find.text('The Vanishing of Will Byers'), findsOneWidget);
    expect(find.text('The Upside Down'), findsOneWidget);
    expect(find.text('CHAPTER EIGHT'), findsOneWidget);
  });

  testWidgets('Marking a chapter watched moves "next up" forward',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const SeasonDetailScreen(season: Seasons.s1)));
    await tester.pump(const Duration(milliseconds: 300));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SeasonDetailScreen)),
      listen: false,
    );
    expect(find.text('WATCHED 0 OF 8'), findsOneWidget);

    await _scrollTo(tester, find.byKey(const ValueKey('watch-S1E1')));
    await tester.tap(find.byKey(const ValueKey('watch-S1E1')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(watchProgressProvider), contains('S1E1'));
    final next = Seasons.nextUp(container.read(watchProgressProvider))!;
    expect(next.$1.number, 1);
    expect(next.$2.title, 'The Weirdo on Maple Street');

    // Tapping again un-watches it.
    await tester.tap(find.byKey(const ValueKey('watch-S1E1')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(watchProgressProvider), isNot(contains('S1E1')));
  });

  testWidgets('The Gate transition leaves the whole new page tappable',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const Scaffold(body: SizedBox.expand())));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));

    var tapped = false;
    nav.push(RiftPageRoute<void>(
      // Open from a corner so the tear has the farthest to travel.
      origin: const Offset(10, 10),
      page: Scaffold(
        body: Align(
          alignment: Alignment.bottomRight,
          child: GestureDetector(
            onTap: () => tapped = true,
            child: const SizedBox(width: 40, height: 40, child: ColoredBox(color: Colors.red)),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 350)); // mid-tear
    await tester.pump(const Duration(milliseconds: 500)); // fully open

    // The far corner must not be clipped out of hit-testing.
    await tester.tap(find.byType(ColoredBox).last);
    expect(tapped, isTrue);
  });

  testWidgets('Moments veil spoilers until tapped', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const MomentsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MOMENTS'), findsOneWidget);
    expect(find.text('Justice for Barb'), findsOneWidget);
    expect(find.text('SPOILER — TAP TO REVEAL'), findsWidgets);

    final before = tester.widgetList(find.text('SPOILER — TAP TO REVEAL')).length;
    await tester.tap(find.text('SPOILER — TAP TO REVEAL').first);
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      tester.widgetList(find.text('SPOILER — TAP TO REVEAL')).length,
      before - 1,
    );
    expect(find.text('THE REVEAL'), findsWidgets);
  });

  testWidgets('Quiz shows a question, answers correctly, and reveals evidence',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const QuizScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TRIVIA'), findsOneWidget);
    expect(find.textContaining('QUESTION 1 OF'), findsOneWidget);

    // Questions are shuffled, so find which bank question is on screen.
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
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const SoundboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SOUNDBOARD'), findsOneWidget);
    expect(find.text('Hawkins Theme'), findsOneWidget);
    expect(find.text('The D20'), findsOneWidget);
    expect(find.text('Eleven\'s Power'), findsOneWidget);
    expect(find.text('Vecna\'s Clock'), findsOneWidget);
  });

  testWidgets('Timeline runs from 1959 to the epilogue', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const TimelineScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TIMELINE'), findsOneWidget);
    expect(find.text('The Creels come to Hawkins'), findsOneWidget);
    await _scrollTo(tester, find.text('Will vanishes'));
    await _scrollTo(tester, find.text('The Battle of Starcourt'));
    await _scrollTo(tester, find.text('Eighteen months later'));
  });

  testWidgets('Locations renders the Hawkins map with filming locations',
      (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const LocationsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HAWKINS MAP'), findsOneWidget);
    expect(find.text('Downtown Hawkins'), findsOneWidget);
    expect(find.text('Filmed at Jackson, Georgia'), findsOneWidget);

    await _scrollTo(tester, find.text('Starcourt Mall'));
    await _scrollTo(tester, find.text('Filmed at Gwinnett Place Mall, Duluth, Georgia'));
  });

  testWidgets('Bestiary renders creatures with threat meters', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const BestiaryScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('BESTIARY'), findsOneWidget);
    expect(find.text('DEMOGORGON'), findsOneWidget);
    expect(find.textContaining('Weakness:'), findsWidgets);

    await _scrollTo(tester, find.text('VECNA'));
  });

  testWidgets('Quotes renders the wall of lines', (tester) async {
    usePhoneSize(tester);
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

  group('Series data', () {
    test('every chapter of all five seasons is in the watch guide', () {
      expect(Seasons.all.map((s) => s.episodes.length), [8, 9, 8, 9, 8]);
      expect(Seasons.totalEpisodes, 42);
      for (final (s, e) in Seasons.watchOrder) {
        expect(e.synopsis, isNotEmpty, reason: s.keyFor(e));
      }
      expect(Seasons.s5.episodes.last.title, 'The Rightside Up');
    });

    test('next up walks the series in order and ends when it is done', () {
      expect(Seasons.nextUp({})!.$2.title, 'The Vanishing of Will Byers');
      final all = {for (final (s, e) in Seasons.watchOrder) s.keyFor(e)};
      expect(Seasons.nextUp(all.difference({'S3E1'}))!.$2.title, 'Suzie, Do You Copy?');
      expect(Seasons.nextUp(all), isNull);
    });

    test('every season has an official trailer with a valid YouTube id', () {
      for (final s in Seasons.all) {
        expect(s.trailers, isNotEmpty, reason: 'Season ${s.number}');
        for (final t in s.trailers) {
          expect(t.youtubeId, matches(RegExp(r'^[A-Za-z0-9_-]{11}$')));
          expect(t.season, s.number);
        }
      }
    });

    test('moments cover every season, in watch order, with unique ids', () {
      expect(Moments.all.map((m) => m.season).toSet(), {1, 2, 3, 4, 5});
      final order = [for (final m in Moments.all) m.season * 100 + m.episode];
      expect(order, [...order]..sort());
      expect(Moments.all.map((m) => m.id).toSet().length, Moments.all.length);
    });

    test('timeline spans the whole story', () {
      expect(STTimeline.events.first.year, '1959');
      expect(STTimeline.events.last.year, 'Spring 1989');
      expect(STTimeline.events.length, greaterThanOrEqualTo(30));
    });

    test('every credited photo is bundled and every cast photo has a character', () {
      for (final c in MediaCredits.all) {
        expect(File(c.asset).existsSync(), isTrue, reason: c.asset);
        expect(c.license, isNotEmpty);
        expect(c.source, startsWith('https://commons.wikimedia.org/'));
      }
      final ids = cast_data.Cast.all.map((c) => c.id).toSet();
      for (final c in MediaCredits.all.where((c) => c.asset.contains('/cast/'))) {
        final id = c.asset.split('/').last.replaceAll('.jpg', '');
        expect(ids, contains(id));
      }
    });
  });
}
