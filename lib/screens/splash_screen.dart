import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sfx.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/particles.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_logo.dart';
import 'home_screen.dart';

/// Splash: the show's title sequence, rebuilt. Like the real opening it
/// starts in extreme close-up - fragments of glowing red letters drifting
/// across the frame - and slowly pulls back as the letters lock together
/// and the bars light, over the synth score, a red bloom and embers.
/// Tapping anywhere skips to the hub.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4400),
  );

  Timer? _navTimer;
  Timer? _scoreTimer;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _navTimer = Timer(const Duration(milliseconds: 5300), _goHome);
    // The theme comes in with the letters (a beat later, once saved
    // settings have loaded, so a muted score stays muted).
    _scoreTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted && ref.read(settingsProvider).music) Score.start();
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _scoreTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted || _left) return;
    _left = true;
    _navTimer?.cancel();
    // The score drifts out as the Gate opens onto Hawkins.
    Score.stop(fade: const Duration(milliseconds: 2600));
    Navigator.of(context).pushReplacement(
      RiftPageRoute<void>(page: const HomeScreen(), name: '/home'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upsideDown = ref.watch(worldModeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _goHome,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // World background.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.1),
                  radius: 1.1,
                  colors: upsideDown
                      ? const [
                          AppColors.udFogHi,
                          AppColors.udVoid,
                          Colors.black,
                        ]
                      : const [
                          Color(0xFF2A0709),
                          Color(0xFF0E0304),
                          Colors.black,
                        ],
                ),
              ),
            ),
            // Slow red bloom behind the title.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final bloom = Curves.easeInOut.transform(
                  (_controller.value * 1.6).clamp(0.0, 1.0),
                );
                return Center(
                  child: Container(
                    width: 300 + 260 * bloom,
                    height: 200 + 160 * bloom,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.stRed.withValues(alpha: 0.28 * bloom),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Embers in Hawkins; the world shell adds ash in the Upside Down.
            if (!upsideDown)
              const ParticleField(
                color: AppColors.stRedGlow,
                glowColor: AppColors.stRed,
                count: 30,
                baseRadius: 1.1,
                speed: 0.45,
                opacity: 0.8,
              ),
            const CrtOverlay(opacity: 0.14),
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final reduce = MediaQuery.disableAnimationsOf(context);
                  final converge = Curves.easeOutCubic.transform(
                    (t / 0.72).clamp(0.0, 1.0),
                  );
                  // Glow swells as letters lock, then holds steady.
                  final glow = 0.45 + 0.55 * Curves.easeIn.transform(converge);
                  final fade = Curves.easeIn.transform(
                    ((t - 0.7) / 0.25).clamp(0.0, 1.0),
                  );
                  // The camera pulls back from an extreme close-up of the
                  // letters, drifting as it goes - the real opening.
                  final pull = reduce
                      ? 1.0
                      : Curves.easeInOutCubic.transform(
                          (t / 0.8).clamp(0.0, 1.0),
                        );
                  final scale = 4.2 - 3.2 * pull;
                  final drift = Offset(80, 34) * (1 - pull);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Never wider than the screen: narrow phones and large
                      // accessibility text scale the logo down instead.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Transform.translate(
                            offset: drift,
                            child: Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: (0.35 + 0.65 * converge).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: STLogo(
                                  size: 46,
                                  spread: 0.5 * (1 - converge),
                                  glow: glow,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 44),
                      Opacity(
                        opacity: fade,
                        child: const ChristmasLights(bulbCount: 20),
                      ),
                      const SizedBox(height: 22),
                      Opacity(
                        opacity: fade,
                        child: Text(
                          'A HAWKINS FAN COMPANION',
                          style: AppText.label(
                            scheme.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: fade,
                        child: Text(
                          'tap to enter',
                          style: AppText.dossier(
                            scheme.onSurface.withValues(alpha: 0.45),
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
