import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:stranger_things_fan_app/core/audio/sfx.dart';
import 'package:stranger_things_fan_app/data/soundboard.dart';
import 'package:stranger_things_fan_app/core/media/asset_media.dart';
import 'package:stranger_things_fan_app/core/media/app_video.dart';
import 'package:stranger_things_fan_app/core/media/youtube_embed.dart';
import 'package:stranger_things_fan_app/core/state/app_state.dart';
import 'package:stranger_things_fan_app/core/theme/app_colors.dart';
import 'package:stranger_things_fan_app/core/theme/app_theme.dart';
import 'package:stranger_things_fan_app/core/theme/world_palette.dart';
import 'package:stranger_things_fan_app/core/widgets/neon_card.dart';
import 'package:stranger_things_fan_app/core/widgets/rift_route.dart';
import 'package:stranger_things_fan_app/core/widgets/st_effects.dart';
import 'package:stranger_things_fan_app/core/widgets/st_logo.dart';
import 'package:stranger_things_fan_app/core/widgets/world_fx.dart';
import 'package:stranger_things_fan_app/data/characters.dart' as cast_data;
import 'package:stranger_things_fan_app/data/credits.dart';
import 'package:stranger_things_fan_app/data/gateways.dart';
import 'package:stranger_things_fan_app/data/fan_media.dart';
import 'package:stranger_things_fan_app/data/moments.dart';
import 'package:stranger_things_fan_app/data/quiz.dart';
import 'package:stranger_things_fan_app/data/seasons.dart';
import 'package:stranger_things_fan_app/data/timeline.dart';
import 'package:stranger_things_fan_app/main.dart';
import 'package:stranger_things_fan_app/models/quiz_question.dart';
import 'package:stranger_things_fan_app/screens/bestiary_screen.dart';
import 'package:stranger_things_fan_app/screens/gallery_screen.dart';
import 'package:stranger_things_fan_app/screens/reel_screen.dart';
import 'package:stranger_things_fan_app/screens/more_screen.dart';
import 'package:stranger_things_fan_app/screens/watch_screen.dart';
import 'package:stranger_things_fan_app/screens/upside_down_screen.dart';
import 'package:stranger_things_fan_app/screens/main_shell.dart';
import 'package:stranger_things_fan_app/screens/explore_screen.dart';
import 'package:stranger_things_fan_app/screens/character_detail_screen.dart';
import 'package:stranger_things_fan_app/screens/home_screen.dart';
import 'package:stranger_things_fan_app/screens/locations_screen.dart';
import 'package:stranger_things_fan_app/screens/moments_screen.dart';
import 'package:stranger_things_fan_app/screens/quiz_screen.dart';
import 'package:stranger_things_fan_app/screens/quotes_screen.dart';
import 'package:stranger_things_fan_app/screens/season_detail_screen.dart';
import 'package:stranger_things_fan_app/screens/seasons_screen.dart';
import 'package:stranger_things_fan_app/screens/soundboard_screen.dart';
import 'package:stranger_things_fan_app/screens/story_screen.dart';
import 'package:stranger_things_fan_app/screens/timeline_screen.dart';
import 'package:stranger_things_fan_app/screens/trailer_player_screen.dart';

Widget _wrap({required Widget child}) => ProviderScope(
  child: MaterialApp(theme: AppTheme.hawkins, home: child),
);

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

/// Plays the title sequence through and lets the Gate open fully onto Home.
Future<void> _throughSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 5400));
  await tester.pump(); // the Gate's ticker starts on this frame
  await tester.pump(const Duration(milliseconds: 900));
}

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
  setUp(() {
    // Each case resolves media in its own zone, with a quiet soundtrack.
    AssetMedia.debugReset();
    Soundtrack.debugReset();
    SharedPreferences.setMockInitialValues({});
  });

  // Lots of the cards are taller than the default 800x600 test surface; use
  // a phone-shaped one so layouts behave like they do on a device.
  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('Home renders the logo, the feed and its new sections', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(STLogo), findsOneWidget);
    expect(find.bySemanticsLabel('Stranger Things'), findsOneWidget);
    expect(find.byKey(const ValueKey('world-toggle')), findsOneWidget);
    expect(find.text('THE FINAL\nCHAPTER'), findsOneWidget);
    // Fresh install: the very first chapter is next up.
    expect(find.text('NEXT UP · S1 CHAPTER ONE'), findsOneWidget);
    // The series at a glance.
    expect(find.text('CHAPTERS'), findsOneWidget);
    expect(find.text('${Seasons.totalEpisodes}'), findsOneWidget);
    for (final key in [
      'quick-timeline',
      'quick-monsters',
      'quick-characters',
      'quick-episodes',
    ]) {
      expect(find.byKey(ValueKey(key)), findsOneWidget, reason: key);
    }

    for (final title in [
      'MEET THE PARTY',
      'LATEST TWISTS',
      'THE SEASONS',
      'JOYCE\'S WALL',
      'HAWKINS RESIDENTS',
      'FROM THE UPSIDE DOWN',
    ]) {
      await _scrollTo(tester, find.text(title));
      expect(find.text(title), findsOneWidget, reason: title);
    }
  });

  testWidgets('Explore files every section and filters by shelf', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const ExploreScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    for (final title in [
      'SEASONS',
      'THE REEL',
      'TRANSMISSIONS',
      'MOMENTS',
      'THE CAST',
      'FAN ART',
      'QUOTES',
      'THE GATE',
      'TIMELINE',
      'HAWKINS MAP',
      'BESTIARY',
      'TRIVIA',
      'SOUNDBOARD',
    ]) {
      await _scrollTo(tester, find.text(title));
      expect(find.text(title), findsOneWidget, reason: title);
    }

    // The PLAY shelf holds only the games.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const ValueKey('shelf-PLAY')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('shelf-PLAY')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('TRIVIA'), findsOneWidget);
    expect(find.text('SOUNDBOARD'), findsOneWidget);
    expect(find.text('SEASONS'), findsNothing);
  });

  testWidgets('The bottom bar moves between the five tabs', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const MainShell()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(HomeScreen), findsOneWidget);

    for (final (key, screen) in [
      ('nav-explore', ExploreScreen),
      ('nav-watch', WatchScreen),
      ('nav-upside-down', UpsideDownScreen),
      ('nav-more', MoreScreen),
    ]) {
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(screen), findsOneWidget, reason: key);
    }
    // Tabs you've visited are kept, so they keep their place.
    expect(find.byType(ExploreScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets(
    'The Upside Down lists every gate and shields the unwatched ones',
    (tester) async {
      usePhoneSize(tester);
      SharedPreferences.setMockInitialValues({
        'spoiler_shield': true,
        'watched_episodes': ['S1E5', 'S1E8'],
      });
      await tester.pumpWidget(_wrap(child: const UpsideDownScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('THE UPSIDE DOWN'), findsWidgets);
      expect(find.byKey(const ValueKey('ud-enter-gate')), findsOneWidget);
      for (final g in Gateways.all) {
        await _scrollTo(tester, find.text(g.name.toUpperCase()));
        expect(find.text(g.name.toUpperCase()), findsOneWidget, reason: g.name);
        // Both Season 1 gates are watched; the rest stay classified.
        final unlock =
            'Classified · watch S${g.season} · E${g.episode} to unlock';
        final seen = g.season == 1;
        expect(
          find.text(unlock),
          seen ? findsNothing : findsOneWidget,
          reason: g.name,
        );
      }
    },
  );

  testWidgets('Watch opens the series, the Reel shelves and the trailers', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const WatchScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('START WATCHING'), findsOneWidget);
    expect(find.byKey(const ValueKey('watch-featured')), findsOneWidget);
    for (final shelf in ReelShelf.values) {
      await _scrollTo(tester, find.text(shelf.title.toUpperCase()));
      expect(
        find.text(shelf.title.toUpperCase()),
        findsOneWidget,
        reason: shelf.title,
      );
    }
    await _scrollTo(tester, find.text('OFFICIAL TRAILERS'));
    expect(find.text('OFFICIAL TRAILERS'), findsOneWidget);
  });

  testWidgets(
    'The Reel filters by shelf, and its player copes with a missing tape',
    (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_wrap(child: const ReelScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('FINALE EDIT'), findsOneWidget);

      await tester.tap(
        find.byKey(ValueKey('shelf-${ReelShelf.vecna.title.toUpperCase()}')),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('FINALE EDIT'), findsNothing);
      expect(find.text('THE UNDYING KING'), findsOneWidget);

      // No playback in tests: the deck says so instead of hanging.
      await tester.tap(find.byKey(const ValueKey('reel-play-all')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('NO TAPE IN THE DECK'), findsOneWidget);
      expect(find.byKey(const ValueKey('player-rotate')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('player-close')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ReelScreen), findsOneWidget);
    },
  );

  testWidgets('The gallery hangs every piece and opens the viewer', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const GalleryScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    final first = FanMedia.art.first;
    expect(find.text(first.title.toUpperCase()), findsOneWidget);
    await tester.tap(find.text(first.title.toUpperCase()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1 / ${FanMedia.art.length}'), findsOneWidget);
    expect(find.textContaining('personal fan-media pack'), findsOneWidget);
  });

  test('The fan-media pack matches the files on disk', () {
    bool exists(String path) => File(path).existsSync();
    for (final c in FanMedia.reel) {
      expect(exists('assets/video/${c.videoKey}.mp4'), isTrue, reason: c.slug);
      expect(exists(c.thumbnail), isTrue, reason: c.slug);
    }
    for (final a in FanMedia.art) {
      expect(exists(a.asset), isTrue, reason: a.slug);
    }
    // Every still or loop the pack accounts for is credited, and bundled.
    for (final key in FanMedia.sourcedKeys) {
      expect(FanMedia.sourceLine(key), isNotNull, reason: key);
      expect(
        exists('assets/images/$key.jpg') || exists('assets/video/$key.mp4'),
        isTrue,
        reason: key,
      );
    }
    for (final MapEntry(key: id, value: slug) in FanMedia.momentReel.entries) {
      expect(Moments.all.any((m) => m.id == id), isTrue, reason: id);
      expect(FanMedia.clip(slug), isNotNull, reason: slug);
    }
    for (final slug in FanMedia.characterReel.values) {
      expect(FanMedia.clip(slug), isNotNull, reason: slug);
    }
    for (final key in FanMedia.sourcedKeys) {
      for (final slug in FanMedia.clipSourcesOf(key)) {
        expect(FanMedia.clip(slug), isNotNull, reason: '$key <- $slug');
      }
    }
    // Every dossier has footage of its own.
    for (final c in cast_data.Cast.all) {
      expect(
        exists('assets/images/char_${c.id}.jpg'),
        isTrue,
        reason: 'still: ${c.id}',
      );
      expect(
        exists('assets/video/char_${c.id}.mp4'),
        isTrue,
        reason: 'loop: ${c.id}',
      );
    }
    expect(
      FanMedia.sourceLine('char_will'),
      'From "William in Season 5", fan edit by GHXZ',
    );
  });

  test('Media lookups resolve once the manifest is cached', () async {
    AssetMedia.debugReset();
    // Images load the manifest first; the bundle then answers synchronously,
    // which once left every lookup hanging.
    await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(
      await AssetMedia.image('char_eleven'),
      'assets/images/char_eleven.jpg',
    );
    expect(
      await AssetMedia.video('hero_finale'),
      'assets/video/hero_finale.mp4',
    );
    expect(await AssetMedia.image('no_such_still'), isNull);
  });

  test('The soundtrack stacks: claims win, releases fall back to the bed', () {
    Soundtrack.setAmbient(Soundtrack.hill);
    expect(Soundtrack.wanted?.asset, Soundtrack.hill);
    final story = Soundtrack.claim(Soundtrack.storyTheme);
    expect(Soundtrack.wanted?.asset, Soundtrack.storyTheme);
    // A trailer silences everything, then hands the theme back.
    final trailer = Soundtrack.claim(null);
    expect(Soundtrack.wanted, isNull);
    Soundtrack.release(trailer);
    expect(Soundtrack.wanted?.asset, Soundtrack.storyTheme);
    Soundtrack.release(story);
    expect(Soundtrack.wanted?.asset, Soundtrack.hill);
    // Crossing over swaps the bed for its drowned twin.
    Soundtrack.setAmbient(Soundtrack.hillUpsideDown);
    expect(Soundtrack.wanted?.asset, Soundtrack.hillUpsideDown);
    Soundtrack.setEnabled(false);
    expect(Soundtrack.wanted, isNull);
    Soundtrack.setEnabled(true);
    Soundtrack.setForeground(false);
    expect(Soundtrack.wanted, isNull);
  });

  test('Every sound the app plays is bundled', () {
    // Every 'audio/...' path written anywhere in lib/, so a cue can't go
    // quiet because its file went missing.
    final named = RegExp(r"'(audio/[^']+\.(?:wav|m4a))'");
    final assets = {
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File && f.path.endsWith('.dart'))
          for (final m in named.allMatches(f.readAsStringSync())) m.group(1)!,
    };
    expect(assets, contains(Sfx.intoUpsideDown));
    expect(assets, contains('audio/captures/vecna_voice.m4a'));
    // Only the show's own sound: everything is cut from the fan edits.
    for (final a in assets) {
      expect(a, startsWith('audio/captures/'), reason: a);
    }
    for (final a in [...assets, for (final c in Soundboard.clips) c.asset]) {
      expect(File('assets/$a').existsSync(), isTrue, reason: a);
    }
  });

  test('Every official trailer has a fan cut for when YouTube refuses', () {
    for (final s in Seasons.all) {
      for (final t in s.trailers) {
        final cut = FanMedia.clip(FanMedia.trailerCut[t.youtubeId] ?? '');
        expect(cut, isNotNull, reason: '${t.title} (S${t.season})');
        expect(
          File('assets/video/${cut!.videoKey}.mp4').existsSync(),
          isTrue,
          reason: cut.slug,
        );
      }
    }
    // And the opening titles are bundled for the landing page.
    expect(File('assets/video/intro.mp4').existsSync(), isTrue);
  });

  testWidgets(
    'Vecna\'s file has his footage and voice, and WATCH sits by his name',
    (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(
        _wrap(child: CharacterDetailScreen(character: cast_data.Cast.vecna)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      // Nothing drawn over the footage any more.
      expect(find.byType(ClipLoop), findsOneWidget);
      // WATCH is down with the name and badges, well clear of the toolbar
      // and the world switch.
      final watch = find.byKey(const ValueKey('dossier-watch'));
      expect(watch, findsOneWidget);
      expect(tester.getTopLeft(watch).dy, greaterThan(250));
      expect(
        tester.getCenter(watch).dy,
        closeTo(tester.getCenter(find.text('S4 · S5')).dy, 30),
      );
    },
  );

  test('Every gate points at a real chapter', () {
    for (final g in Gateways.all) {
      final season = Seasons.all[g.season - 1];
      expect(
        g.episode,
        inInclusiveRange(1, season.episodes.length),
        reason: g.name,
      );
    }
  });

  testWidgets('World toggle flips MaterialApp to dark (Upside Down)', (
    tester,
  ) async {
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
    // Her dossier runs on fan footage, and says whose.
    await _scrollTo(
      tester,
      find.textContaining(
        'Footage: From "The Series", fan edit by @onexpiiece',
      ),
    );
  });

  testWidgets('A dossier credits every edit its footage came from', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: CharacterDetailScreen(character: cast_data.Cast.dustin)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await _scrollTo(
      tester,
      find.text(
        'Footage: From "The Series", fan edit by @onexpiiece and '
        '"The Wait Is Over", a fan edit. Personal fan-media pack.',
      ),
    );
  });

  testWidgets('Seasons lists all five and tears open into a watch guide', (
    tester,
  ) async {
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

  testWidgets('The hero play button starts, resumes, or rewatches', (
    tester,
  ) async {
    usePhoneSize(tester);
    final everything = [for (final (s, e) in Seasons.watchOrder) s.keyFor(e)];
    for (final (watched, label) in [
      (<String>[], 'START WATCHING'),
      (['S1E1', 'S1E2', 'S1E3'], 'RESUME S1 · E4'),
      (everything, 'WATCH AGAIN'),
    ]) {
      SharedPreferences.setMockInitialValues({'watched_episodes': watched});
      await tester.pumpWidget(const SizedBox()); // a fresh ProviderScope
      await tester.pumpWidget(_wrap(child: const HomeScreen()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('Photos decode near the size they are drawn at', (tester) async {
    usePhoneSize(tester);
    Future<ImageProvider> providerAt(Size size) async {
      await tester.pumpWidget(
        Center(
          child: SizedBox.fromSize(
            size: size,
            child: const DuotonePhoto(
              asset: 'assets/images/events/rink.jpg',
              tint: AppColors.stRed,
            ),
          ),
        ),
      );
      return tester.widget<Image>(find.byType(Image)).image;
    }

    // A small tile holds a small decode, not the full still...
    final tile = await providerAt(const Size(110, 80));
    expect(tile, isA<ResizeImage>());
    expect((tile as ResizeImage).width, 480);
    // ...while a full-screen story card gets every pixel.
    expect(await providerAt(const Size(390, 700)), isA<AssetImage>());
  });

  test('The YouTube embed identifies itself with the real app ids', () {
    // YouTube rejects embeds without a valid app identity (error 153), so
    // these must track the native projects.
    final ios = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final android = File('android/app/build.gradle.kts').readAsStringSync();
    expect(
      ios,
      contains('PRODUCT_BUNDLE_IDENTIFIER = ${YoutubeEmbed.iosAppId};'),
    );
    expect(android, contains('applicationId = "${YoutubeEmbed.androidAppId}"'));

    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    for (final (platform, origin) in [
      (TargetPlatform.iOS, 'https://com.hawkins.strangerthingsfanapp'),
      (TargetPlatform.android, 'https://com.hawkins.stranger_things_fan_app'),
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      final params = YoutubeEmbed.identify(
        const YoutubePlayerParams(mute: true),
      );
      expect(params.origin, origin, reason: '$platform');
      expect(params.toMap()['widget_referrer'], origin, reason: '$platform');
      expect(
        params.mute,
        isTrue,
        reason: 'identify keeps the caller\'s params',
      );
    }
  });

  test('Player errors map to what the viewer is told', () {
    expect(TrailerFailure.fromError(YoutubeError.none), isNull);
    expect(
      TrailerFailure.fromError(YoutubeError.videoNotFound),
      TrailerFailure.removed,
    );
    for (final refused in [
      YoutubeError.notEmbeddable,
      YoutubeError.sameAsNotEmbeddable,
      YoutubeError.sameAsNotEmbeddable2,
      YoutubeError.unknown, // e.g. 153, which the package doesn't name
    ]) {
      expect(
        TrailerFailure.fromError(refused),
        TrailerFailure.refused,
        reason: '$refused',
      );
    }
  });

  testWidgets('A blocked trailer offers YouTube instead of a frozen frame', (
    tester,
  ) async {
    var opened = 0;
    var retried = 0;
    Future<void> show(TrailerFailure failure, {int? code}) => tester.pumpWidget(
      _wrap(
        child: Scaffold(
          body: TrailerUnavailable(
            failure: failure,
            errorCode: code,
            accent: AppColors.stRed,
            onWatchOnYouTube: () => opened++,
            onRetry: failure == TrailerFailure.unreachable
                ? () => retried++
                : null,
          ),
        ),
      ),
    );

    await show(TrailerFailure.refused, code: 150);
    expect(find.text('TRANSMISSION BLOCKED'), findsOneWidget);
    expect(find.textContaining('(error 150)'), findsOneWidget);
    expect(find.byKey(const ValueKey('trailer-retry')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('trailer-watch-on-youtube')));
    expect(opened, 1);

    await show(TrailerFailure.unreachable);
    expect(find.text('NO SIGNAL'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('trailer-retry')));
    expect(retried, 1);
  });

  testWidgets('Marking a chapter watched moves "next up" forward', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: const SeasonDetailScreen(season: Seasons.s1)),
    );
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

  testWidgets('The Gate transition leaves the whole new page tappable', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: const Scaffold(body: SizedBox.expand())),
    );
    final nav = tester.state<NavigatorState>(find.byType(Navigator));

    var tapped = false;
    nav.push(
      RiftPageRoute<void>(
        // Open from a corner so the tear has the farthest to travel.
        origin: const Offset(10, 10),
        page: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => tapped = true,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: ColoredBox(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
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

    final before = tester
        .widgetList(find.text('SPOILER — TAP TO REVEAL'))
        .length;
    await tester.tap(find.text('SPOILER — TAP TO REVEAL').first);
    await tester.pump(const Duration(milliseconds: 700));
    expect(
      tester.widgetList(find.text('SPOILER — TAP TO REVEAL')).length,
      before - 1,
    );
    expect(find.text('THE REVEAL'), findsWidgets);
  });

  testWidgets(
    'Quiz shows a question, answers correctly, and reveals evidence',
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

      await tester.tap(
        find.byKey(
          ValueKey('quiz-option-${current!.options[current.correctIndex]}'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('CORRECT'), findsOneWidget);
      expect(find.text(current.fact), findsOneWidget);
    },
  );

  testWidgets('Soundboard renders its clips', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const SoundboardScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SOUNDBOARD'), findsOneWidget);
    expect(find.text('Main Title'), findsOneWidget);
    expect(find.text('Running Up That Hill'), findsOneWidget);
    expect(find.text('The D20'), findsNothing);
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

  testWidgets('Locations renders the Hawkins map with filming locations', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const LocationsScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('HAWKINS MAP'), findsOneWidget);
    expect(find.text('Downtown Hawkins'), findsOneWidget);
    expect(find.text('Filmed at Jackson, Georgia'), findsOneWidget);

    await _scrollTo(tester, find.text('Starcourt Mall'));
    await _scrollTo(
      tester,
      find.text('Filmed at Gwinnett Place Mall, Duluth, Georgia'),
    );
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

  testWidgets(
    'In the app shell the world flips over and switches at the midpoint',
    (tester) async {
      usePhoneSize(tester);
      SharedPreferences.setMockInitialValues({'sound_effects': false});
      await tester.pumpWidget(const ProviderScope(child: StrangerThingsApp()));
      // The title sequence, then the Gate opens onto Home.
      await _throughSplash(tester);
      expect(find.byType(HomeScreen), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
        listen: false,
      );
      await tester.tap(find.byKey(const ValueKey('world-toggle')));
      await tester.pump(); // the flip's ticker starts on this frame
      await tester.pump(const Duration(milliseconds: 250));
      // Still Hawkins while the screen is turning away...
      expect(container.read(worldModeProvider), isFalse);
      await tester.pump(const Duration(milliseconds: 400));
      // ...the Upside Down once it has passed edge-on.
      expect(container.read(worldModeProvider), isTrue);
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('You are in the Upside Down'), findsOneWidget);
    },
  );

  testWidgets('Cards grow vines only in the Upside Down', (tester) async {
    Future<void> pumpIn(ThemeData theme) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 120,
                child: NeonCard(child: SizedBox.expand()),
              ),
            ),
          ),
        ),
      );
    }

    CustomPaint? vines() => tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(CardVines),
            matching: find.byType(CustomPaint),
          ),
        )
        .firstOrNull;

    await pumpIn(AppTheme.hawkins);
    expect(vines(), isNull);
    await pumpIn(AppTheme.upsideDown);
    // MaterialApp tweens between themes; let the vines grow in.
    await tester.pump(const Duration(milliseconds: 400));
    expect(vines(), isNotNull);
  });

  test(
    'World tint: Hawkins keeps colours, the Upside Down turns them red or blue',
    () {
      final hawkins = WorldPalette.hawkins();
      final ud = WorldPalette.upsideDown();
      const pink = Color(0xFFF09CB8); // Eleven
      const green = Color(0xFF34C759); // a Christmas bulb

      expect(hawkins.tint(pink), pink);
      double distance(Color a, Color b) =>
          (a.r - b.r).abs() + (a.g - b.g).abs() + (a.b - b.b).abs();
      // Warm hues decay toward the lightning, everything else toward the storm.
      expect(
        distance(ud.tint(pink), AppColors.udLightning),
        lessThan(distance(pink, AppColors.udLightning)),
      );
      expect(
        distance(ud.tint(green), AppColors.udGlow),
        lessThan(distance(green, AppColors.udGlow)),
      );
      // Halfway through the flip, halfway there.
      expect(hawkins.lerp(ud, 0.5).depth, closeTo(0.5, 1e-9));
    },
  );

  testWidgets('Typewriter text is always the full string on screen', (
    tester,
  ) async {
    const line = 'Friends don\'t lie.';
    await tester.pumpWidget(
      const MaterialApp(
        home: TypewriterText(line, style: TextStyle(fontSize: 14)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300)); // mid-typing
    expect(find.text(line), findsOneWidget);
    await tester.pump(const Duration(seconds: 1)); // done
    expect(find.text(line), findsOneWidget);
  });

  testWidgets('Reduced effects: the world switches at once, no lightning', (
    tester,
  ) async {
    usePhoneSize(tester);
    SharedPreferences.setMockInitialValues({
      'sound_effects': false,
      'reduce_effects': true,
    });
    await tester.pumpWidget(const ProviderScope(child: StrangerThingsApp()));
    await _throughSplash(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
      listen: false,
    );
    await tester.tap(find.byKey(const ValueKey('world-toggle')));
    await tester.pump();
    expect(container.read(worldModeProvider), isTrue);
    // No storm is drawn.
    expect(
      find.descendant(
        of: find.byType(RiftFlash),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('The world you left in is remembered', (tester) async {
    SharedPreferences.setMockInitialValues({'upside_down': true});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(worldModeProvider), isFalse); // until prefs load
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    expect(container.read(worldModeProvider), isTrue);
  });

  testWidgets('Spoiler shield redacts unwatched beats until declassified', (
    tester,
  ) async {
    usePhoneSize(tester);
    SharedPreferences.setMockInitialValues({'spoiler_shield': true});
    await tester.pumpWidget(_wrap(child: const TimelineScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // Nothing watched: the first beat (revealed in S4 · E7) is classified.
    expect(find.textContaining('CLASSIFIED'), findsWidgets);
    expect(find.byType(RedactedText), findsWidgets);
    final before = tester.widgetList(find.byType(RedactedText)).length;

    await tester.tap(find.textContaining('CLASSIFIED').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.widgetList(find.byType(RedactedText)).length, before - 2);
  });

  testWidgets('Spoiler shield lets watched chapters through', (tester) async {
    usePhoneSize(tester);
    SharedPreferences.setMockInitialValues({
      'spoiler_shield': true,
      'watched_episodes': ['S1E2'],
    });
    await tester.pumpWidget(_wrap(child: const MomentsScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    // Barb (S1 · E2) has been watched; the S1 · E3 moment has not.
    expect(find.text('Justice for Barb'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(RedactedText),
        matching: find.text('Justice for Barb'),
      ),
      findsNothing,
    );
    // Its title is still laid out (so the card keeps its shape) but redacted.
    expect(
      find.descendant(
        of: find.byType(RedactedText),
        matching: find.text('Right Here'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Settings sheet toggles the spoiler shield', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('open-settings')));
    await tester.pump(); // the sheet's entrance starts on this frame
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('CONTROL PANEL'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
      listen: false,
    );
    expect(container.read(settingsProvider).spoilerShield, isFalse);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('setting-spoiler-shield')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(container.read(settingsProvider).spoilerShield, isTrue);
  });

  testWidgets('Chapters link to their moments and timeline beats', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: const SeasonDetailScreen(season: Seasons.s1)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Chapter Two is where Barb is taken: one moment, one timeline beat.
    await _scrollTo(tester, find.text('1 MOMENT').first);
    await tester.tap(find.text('1 MOMENT').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Justice for Barb'), findsOneWidget);
    expect(find.text('Barb is taken'), findsOneWidget);
  });

  testWidgets('Story mode plays chapters, steps with taps, and marks watched', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: const StoryScreen(season: 1, episode: 1)),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('CHAPTER ONE'), findsOneWidget);
    expect(find.text('THE VANISHING OF WILL BYERS'), findsOneWidget);

    // Tap the right side: next chapter.
    await tester.tapAt(const Offset(300, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('THE WEIRDO ON MAPLE STREET'), findsOneWidget);

    // Tap the left edge: back again.
    await tester.tapAt(const Offset(30, 400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('THE VANISHING OF WILL BYERS'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(StoryScreen)),
      listen: false,
    );
    await tester.tap(find.byKey(const ValueKey('story-watched')));
    await tester.pump();
    expect(container.read(watchProgressProvider), contains('S1E1'));
  });

  testWidgets('A season opens on its title card, then runs into chapter one', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: const StoryScreen(season: 2, onlySeason: true)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(STLogo), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // The title card runs ~6.5s, then the first chapter begins by itself.
    await tester.pump(const Duration(milliseconds: 7000));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('MADMAX'), findsOneWidget);
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
      expect(
        Seasons.nextUp(all.difference({'S3E1'}))!.$2.title,
        'Suzie, Do You Copy?',
      );
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

    test('every event photo is bundled and credited', () {
      final keys = <String?>[
        for (final e in STTimeline.events) e.photo,
        for (final m in Moments.all) m.photo,
      ].whereType<String>();
      expect(keys, isNotEmpty);
      for (final k in keys) {
        expect(MediaCredits.photo(k), isNotNull, reason: k);
      }
      // Every timeline beat has one; most moments do.
      expect(STTimeline.events.every((e) => e.photo != null), isTrue);
    });

    test('every chapter has a credited Story-mode still', () {
      for (final (s, e) in Seasons.watchOrder) {
        expect(MediaCredits.photo(e.photo), isNotNull, reason: s.keyFor(e));
      }
    });

    test('every character has a real, trimmed alias', () {
      for (final c in cast_data.Cast.all) {
        expect(c.alias, c.alias.trim(), reason: c.id);
        expect(c.alias.length, greaterThanOrEqualTo(3), reason: c.id);
      }
    });

    test('timeline spans the whole story', () {
      expect(STTimeline.events.first.year, '1959');
      expect(STTimeline.events.last.year, 'Spring 1989');
      expect(STTimeline.events.length, greaterThanOrEqualTo(30));
    });

    test(
      'every credited photo is bundled and every cast photo has a character',
      () {
        for (final c in MediaCredits.all) {
          expect(File(c.asset).existsSync(), isTrue, reason: c.asset);
          expect(c.license, isNotEmpty);
          expect(c.source, startsWith('https://commons.wikimedia.org/'));
          // ...and is listed in one of the Credits screen's sections.
          expect(
            ['/cast/', '/filming/', '/events/'].any(c.asset.contains),
            isTrue,
            reason: '${c.asset} would be uncredited on screen',
          );
        }
        final ids = cast_data.Cast.all.map((c) => c.id).toSet();
        for (final c in MediaCredits.all.where(
          (c) => c.asset.contains('/cast/'),
        )) {
          final id = c.asset.split('/').last.replaceAll('.jpg', '');
          expect(ids, contains(id));
        }
      },
    );
  });
}
