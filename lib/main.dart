import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/sfx.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/particles.dart';
import 'core/widgets/rift_route.dart';
import 'core/widgets/world_fx.dart';
import 'core/widgets/world_toggle.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const ProviderScope(child: StrangerThingsApp()));
}

class StrangerThingsApp extends ConsumerWidget {
  const StrangerThingsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upsideDown = ref.watch(worldModeProvider);

    return MaterialApp(
      title: 'Stranger Things — Fan App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.hawkins,
      darkTheme: AppTheme.upsideDown,
      themeMode: upsideDown ? ThemeMode.dark : ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 600),
      builder: (context, child) => _WorldStack(child: child!),
      home: const SplashScreen(),
    );
  }
}

/// Sits above every route: records where fingers land (so pages can tear
/// open from the tapped card), keeps something drifting in the air (embers
/// in Hawkins, ash in the Upside Down), and owns the world flip.
///
/// The flip: the whole screen turns over on its horizontal axis - Hawkins
/// rotates away, the world switches exactly when the screen is edge-on,
/// lightning strikes, and the Upside Down turns in from the other side
/// while the frame shakes with the thunder.
class _WorldStack extends ConsumerStatefulWidget {
  const _WorldStack({required this.child});

  final Widget child;

  @override
  ConsumerState<_WorldStack> createState() => _WorldStackState();
}

class _WorldStackState extends ConsumerState<_WorldStack>
    with TickerProviderStateMixin {
  late final AnimationController _storm = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..addListener(_onFlipTick);
  bool _switched = false;
  int _strikes = 0;

  @override
  void dispose() {
    _flip.dispose();
    _storm.dispose();
    super.dispose();
  }

  // This context sits above the MediaQuery override built below, so check
  // the in-app setting directly as well as the system one.
  bool get _reduce =>
      MediaQuery.disableAnimationsOf(context) ||
      ref.read(settingsProvider).reduceEffects;

  void _startFlip() {
    if (_flip.isAnimating) return;
    // Reduced effects: no rotation, no strobe - the theme just crossfades.
    if (_reduce) {
      HapticFeedback.mediumImpact();
      _switchWorld(strike: false);
      return;
    }
    _switched = false;
    HapticFeedback.mediumImpact();
    _flip.forward(from: 0);
  }

  // Switch worlds at the edge-on midpoint, where neither side is visible.
  void _onFlipTick() {
    if (!_switched && _flip.value >= 0.5) {
      _switched = true;
      HapticFeedback.heavyImpact();
      _switchWorld(strike: true);
    }
  }

  void _switchWorld({required bool strike}) {
    final notifier = ref.read(worldModeProvider.notifier);
    final intoUpsideDown = !ref.read(worldModeProvider);
    notifier.toggle();
    if (ref.read(settingsProvider).soundEffects) {
      Sfx.play(intoUpsideDown ? 'audio/portal.wav' : 'audio/chime.wav');
    }
    if (strike) {
      setState(() => _strikes++);
      _storm.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final upsideDown = ref.watch(worldModeProvider);
    final settings = ref.watch(settingsProvider);
    final media = MediaQuery.of(context);
    final reduce = media.disableAnimations || settings.reduceEffects;

    // One switch for every effect in the app: the system's Reduce Motion or
    // the in-app "reduce effects" setting. Widgets read
    // MediaQuery.disableAnimationsOf and drop flashes, flicker and motion.
    return MediaQuery(
      data: media.copyWith(disableAnimations: reduce),
      child: WorldFlipScope(
        onFlip: _startFlip,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => TapOrigin.last = e.position,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The void behind the world while it turns over.
              const ColoredBox(color: Colors.black),
              AnimatedBuilder(
                animation: Listenable.merge([_flip, _storm]),
                child: widget.child,
                builder: (context, child) {
                  final v = _flip.value;
                  final turning = v > 0 && v < 1;
                  // 0 -> 90deg away, then -90deg -> 0 back in.
                  final angle = !turning
                      ? 0.0
                      : v < 0.5
                      ? Curves.easeInCubic.transform(v / 0.5) * math.pi / 2
                      : -(1 - Curves.easeOutCubic.transform((v - 0.5) / 0.5)) *
                            math.pi /
                            2;
                  final s = _storm.value;
                  final shake = s > 0 && s < 0.4
                      ? math.sin(s * 140) * 9 * (1 - s / 0.4)
                      : 0.0;
                  final dark = (angle.abs() / (math.pi / 2)).clamp(0.0, 1.0);

                  return Transform.translate(
                    offset: Offset(shake, shake * 0.4),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0011)
                        ..rotateX(angle),
                      child: AbsorbPointer(
                        absorbing: turning,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            child!,
                            // Light falls away as the world turns edge-on.
                            IgnorePointer(
                              child: Opacity(
                                opacity: dark * 0.75,
                                child: const ColoredBox(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 900),
                  child: reduce
                      ? const SizedBox.shrink()
                      : upsideDown
                      ? const ParticleField(
                          key: ValueKey('ash'),
                          color: AppColors.udSpore,
                          glowColor: AppColors.udGlow,
                          count: 46,
                          baseRadius: 1.3,
                          speed: 0.6,
                          opacity: 0.75,
                        )
                      : const ParticleField(
                          key: ValueKey('embers'),
                          color: AppColors.stRedGlow,
                          glowColor: AppColors.hawkinsGold,
                          count: 16,
                          baseRadius: 1.0,
                          speed: 0.35,
                          opacity: 0.4,
                        ),
                ),
              ),
              // Film stock over everything: grain and a lens vignette.
              const FilmGrain(),
              IgnorePointer(
                child: RiftFlash(controller: _storm, seed: _strikes),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
