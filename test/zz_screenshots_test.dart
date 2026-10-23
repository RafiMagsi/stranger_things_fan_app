// TEMPORARY: renders screenshots for design review. Deleted after.
import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stranger_things_fan_app/core/media/asset_media.dart';

import 'package:stranger_things_fan_app/core/state/app_state.dart';
import 'package:stranger_things_fan_app/core/theme/app_theme.dart';
import 'package:stranger_things_fan_app/data/characters.dart' as cast_data;
import 'package:stranger_things_fan_app/screens/bestiary_screen.dart';
import 'package:stranger_things_fan_app/screens/cast_screen.dart';
import 'package:stranger_things_fan_app/screens/character_detail_screen.dart';
import 'package:stranger_things_fan_app/screens/gate_screen.dart';
import 'package:stranger_things_fan_app/screens/home_screen.dart';
import 'package:stranger_things_fan_app/screens/reel_screen.dart';
import 'package:stranger_things_fan_app/screens/timeline_screen.dart';
import 'package:stranger_things_fan_app/screens/explore_screen.dart';
import 'package:stranger_things_fan_app/screens/gallery_screen.dart';
import 'package:stranger_things_fan_app/screens/main_shell.dart';
import 'package:stranger_things_fan_app/screens/more_screen.dart';
import 'package:stranger_things_fan_app/screens/upside_down_screen.dart';
import 'package:stranger_things_fan_app/screens/watch_screen.dart';

const _out = String.fromEnvironment('SHOTS_DIR');
const _only = String.fromEnvironment('ONLY');

Future<void> _loadFonts() async {
  Future<void> load(String family, String file) async {
    final loader = FontLoader(family)
      ..addFont(
        Future.value(ByteData.sublistView(File(file).readAsBytesSync())),
      );
    await loader.load();
  }

  for (final f in Directory('assets/fonts').listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last.split('.').first;
    await load(name, f.path);
  }
  await load(
    'MaterialIcons',
    '/Users/rafi/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e, onError: (_, _) {});
    }
    await Future<void>.delayed(const Duration(milliseconds: 30));
  });
  await tester.pump(const Duration(milliseconds: 16));
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('shot')),
  );
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2));
  final bytes = await tester.runAsync(
    () => image!.toByteData(format: ImageByteFormat.png),
  );
  File('$_out/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

class _UD extends WorldModeNotifier {
  @override
  bool build() => true;
}

Widget _app(Widget home, {bool ud = false}) => ProviderScope(
  overrides: [if (ud) worldModeProvider.overrideWith(_UD.new)],
  child: RepaintBoundary(
    key: const ValueKey('shot'),
    child: Consumer(
      builder: (context, ref, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.hawkins,
        darkTheme: AppTheme.upsideDown,
        themeMode: ref.watch(worldModeProvider)
            ? ThemeMode.dark
            : ThemeMode.light,
        home: home,
      ),
    ),
  ),
);

void main() {
  setUpAll(_loadFonts);
  setUp(() {
    // Each case resolves media in its own zone.
    AssetMedia.debugReset();
    SharedPreferences.setMockInitialValues({
      'watched_episodes': ['S1E1', 'S1E2', 'S1E3'],
    });
  });

  void phone(WidgetTester t) {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  final screens = <String, (Widget, bool)>{
    'shell': (const MainShell(), false),
    'explore': (const ExploreScreen(), false),
    'watch': (const WatchScreen(), false),
    'ud': (const UpsideDownScreen(), false),
    'ud_in': (const UpsideDownScreen(), true),
    'more': (const MoreScreen(), false),
    'gallery': (const GalleryScreen(), false),
    'home': (const HomeScreen(), false),
    'gate': (const GateScreen(), false),
    'reel': (const ReelScreen(), false),
    'cast': (const CastScreen(), false),
    'will': (CharacterDetailScreen(character: cast_data.Cast.will), false),
    'bestiary': (const BestiaryScreen(), true),
    'timeline': (const TimelineScreen(), false),
  };
  for (final MapEntry(key: name, value: (screen, ud)) in screens.entries) {
    if (_only.isNotEmpty && !_only.split(',').contains(name)) continue;
    testWidgets(name, (t) async {
      phone(t);
      await t.pumpWidget(_app(screen, ud: ud));
      await t.pump();
      await t.pump(const Duration(milliseconds: 1500));
      await _shot(t, '${name}_1');
      final scroll = find.byType(Scrollable);
      if (scroll.evaluate().isNotEmpty) {
        await t.drag(scroll.first, const Offset(0, -700));
        await t.pump(const Duration(milliseconds: 900));
        await _shot(t, '${name}_2');
        await t.drag(scroll.first, const Offset(0, -700));
        await t.pump(const Duration(milliseconds: 900));
        await _shot(t, '${name}_3');
      }
    });
  }
}
