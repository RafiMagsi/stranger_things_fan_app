import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/particles.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import 'home_screen.dart';

/// Splash: the show's title sequence, rebuilt. Letters start wide apart and
/// glowing red, then converge into the logo as the camera "settles", with a
/// slow bloom behind them. Tapping anywhere skips to the hub.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _navTimer = Timer(const Duration(milliseconds: 4200), _goHome);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      RiftPageRoute<void>(page: const HomeScreen(), name: '/home'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final upsideDown = ref.watch(worldModeProvider);
    final scheme = Theme.of(context).colorScheme;
    final titleColor = upsideDown ? AppColors.udSpore : AppColors.stRed;

    return Scaffold(
      body: GestureDetector(
        onTap: _goHome,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // World background.
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 1.1,
                  colors: upsideDown
                      ? [AppColors.udFogHi, AppColors.udVoid, Colors.black]
                      : [const Color(0xFF3A1010), const Color(0xFF160606), Colors.black],
                ),
              ),
            ),
            // Slow bloom behind the title.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final bloom = Curves.easeInOut.transform(
                  (_controller.value * 2).clamp(0.0, 1.0),
                );
                return Center(
                  child: Container(
                    width: 420 + 160 * bloom,
                    height: 240 + 120 * bloom,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          titleColor.withValues(alpha: 0.22 * bloom),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Particles: spores in the Upside Down, embers in Hawkins.
            ParticleField(
              color: upsideDown ? AppColors.udSpore : AppColors.stRed,
              glowColor: titleColor,
              count: 34,
              baseRadius: 1.2,
              speed: 0.5,
              opacity: 0.85,
            ),
            // VHS / CRT texture over the whole frame.
            const Positioned.fill(
              child: CrtOverlay(opacity: 0.12),
            ),
            // Title + tagline.
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  final converge = Curves.easeOutExpo.transform(
                    (t / 0.72).clamp(0.0, 1.0),
                  );
                  final glowPulse = 0.6 + 0.4 * (1 - converge) + 0.15 * (t > 0.75 ? 1 : 0);
                  final fade = Curves.easeIn.transform(
                    ((t - 0.15) / 0.35).clamp(0.0, 1.0),
                  );

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "STRANGER" — letters converge inward with the authentic ST logotype.
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) => const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFA00312)],
                          stops: [0.0, 1.0],
                        ).createShader(rect),
                        child: _ConvergingTitle(
                          text: 'STRANGER',
                          converge: converge,
                          glow: glowPulse,
                          size: 56,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // "THINGS" — same treatment, slightly larger.
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (rect) => const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFA00312)],
                          stops: [0.0, 1.0],
                        ).createShader(rect),
                        child: _ConvergingTitle(
                          text: 'THINGS',
                          converge: converge,
                          glow: glowPulse,
                          size: 66,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // The alphabet lights, spelling themselves out.
                      Opacity(
                        opacity: fade,
                        child: const ChristmasLights(bulbCount: 22),
                      ),
                      const SizedBox(height: 18),
                      Opacity(
                        opacity: fade,
                        child: Text(
                          'A HAWKINS FAN PRODUCTION',
                          style: AppText.label(
                            scheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Opacity(
                        opacity: fade,
                        child: Text(
                          'tap to enter',
                          style: AppText.body(
                            scheme.onSurface.withValues(alpha: 0.4),
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

/// One line of the title, letters starting spread out and pulling together
/// like the show's intro. Each letter gets its own glow halo.
class _ConvergingTitle extends StatelessWidget {
  const _ConvergingTitle({
    required this.text,
    required this.converge,
    required this.glow,
    required this.size,
    required this.color,
  });

  final String text;
  final double converge;
  final double glow;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spread = (1 - converge) * size * 0.62;
    final letters = text.split('');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < letters.length; i++)
          Transform.translate(
            offset: Offset(
              (i - (letters.length - 1) / 2) * spread,
              0,
            ),
            child: Opacity(
              opacity: (0.35 + 0.65 * converge).clamp(0.0, 1.0),
              child: Text(
                letters[i],
                style: TextStyle(
                  fontFamily: AppText.display,
                  fontWeight: FontWeight.w900,
                  fontVariations: const [FontVariation('wght', 900)],
                  fontSize: size,
                  height: 1.0,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: 0.9 * glow),
                      blurRadius: size * 0.42 * glow,
                    ),
                    Shadow(
                      color: color.withValues(alpha: 0.45 * glow),
                      blurRadius: size * 0.95 * glow,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
