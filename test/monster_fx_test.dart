import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stranger_things_fan_app/core/media/asset_media.dart';

import 'package:stranger_things_fan_app/core/theme/app_theme.dart';
import 'package:stranger_things_fan_app/core/widgets/monster_fx.dart';
import 'package:stranger_things_fan_app/data/bestiary.dart';
import 'package:stranger_things_fan_app/data/characters.dart' as cast_data;
import 'package:stranger_things_fan_app/screens/bestiary_screen.dart';
import 'package:stranger_things_fan_app/screens/cast_screen.dart';
import 'package:stranger_things_fan_app/screens/character_detail_screen.dart';
import 'package:stranger_things_fan_app/screens/home_screen.dart';

Widget _wrap({required Widget child}) => ProviderScope(
  child: MaterialApp(theme: AppTheme.hawkins, home: child),
);

/// Phone-shaped surface (the cards are taller than the 800x600 default).
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls the first scrollable on screen until [finder] is built/visible.
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
    // Each case resolves media in its own zone.
    AssetMedia.debugReset();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Every creature id renders its signature effect', (tester) async {
    usePhoneSize(tester);
    // One frame per creature: the painter must not throw for any id.
    for (final m in Bestiary.all) {
      await tester.pumpWidget(
        _wrap(
          child: Scaffold(
            body: MonsterFx(monsterId: m.id, accent: m.accent),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 120));
      expect(
        find.byType(CustomPaint),
        findsWidgets,
        reason: '${m.id} should paint its effect',
      );
      expect(tester.takeException(), isNull, reason: '${m.id} must not throw');
    }
  });

  testWidgets('Unknown creature ids fall back to drifting spores', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(
        child: const Scaffold(
          body: MonsterFx(monsterId: 'unknown_thing', accent: Colors.purple),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MonsterFx never steals taps from the card it decorates', (
    tester,
  ) async {
    usePhoneSize(tester);
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: MonsterFx(monsterId: 'demogorgon', accent: Colors.red),
              ),
              Center(
                child: GestureDetector(
                  key: const ValueKey('under-fx'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => tapped = true,
                  child: const SizedBox(width: 80, height: 80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.byKey(const ValueKey('under-fx')));
    expect(tapped, isTrue);
  });

  testWidgets('Bestiary cards are alive and flinch when poked', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const BestiaryScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    // The visible creature carries its effect.
    expect(find.byType(MonsterFx), findsWidgets);

    // Poking the card plays its scare lunge without breaking the screen.
    await tester.tap(find.text('DEMOGORGON'));
    await tester.pump(); // scare starts
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('DEMOGORGON'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 400)); // settle
    expect(find.byType(MonsterFx), findsWidgets);
  });

  testWidgets('The home "From the Upside Down" row animates its creatures', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    await _scrollTo(tester, find.text('FROM THE UPSIDE DOWN'));
    expect(find.byType(MonsterFx), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A creature dossier animates its subject in the header', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      _wrap(child: CharacterDetailScreen(character: cast_data.Cast.demogorgon)),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('DEMOGORGON'), findsOneWidget);
    expect(find.byType(MonsterFx), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('The cast file animates creature dossiers', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(_wrap(child: const CastScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    await _scrollTo(tester, find.text('FROM THE UPSIDE DOWN'));
    expect(find.byType(MonsterFx), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
