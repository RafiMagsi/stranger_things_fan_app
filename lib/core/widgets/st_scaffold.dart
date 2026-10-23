import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../theme/world_palette.dart';
import 'neon_card.dart';
import 'st_effects.dart';
import 'world_fx.dart';
import 'world_toggle.dart';

/// Widest the readable content gets on tablets and desktop.
const double kMaxContentWidth = 760;

/// Shared chrome for every section screen: a neon title over a burning
/// tube, the world's atmosphere behind the content (the red title-sequence
/// glow in Hawkins; storm light and creeping vines in the Upside Down), and
/// a faint CRT texture on top — so each page reads as the show.
class STScaffold extends StatelessWidget {
  const STScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: subtitle == null ? 60 : 70,
        automaticallyImplyLeading: false,
        leadingWidth: canPop ? 60 : 0,
        leading: canPop ? const NeonBackButton() : null,
        titleSpacing: canPop ? 2 : 20,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A condensed poster title whose neon halo powers on as the
            // page arrives.
            NeonIgnite(
              delay: const Duration(milliseconds: 250),
              builder: (context, glow) => Text(
                title,
                style: AppText.headline(world.ink, size: 24, letterSpacing: 0.1).copyWith(
                  shadows: [
                    Shadow(color: world.accent.withValues(alpha: 0.8 * glow), blurRadius: 8),
                    Shadow(color: world.accent.withValues(alpha: 0.5 * glow), blurRadius: 22),
                  ],
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppText.dossier(world.muted, size: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        actions: [
          ...actions,
          const Padding(
            padding: EdgeInsets.only(left: 4, right: 14),
            child: Center(child: WorldToggle(compact: true)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: NeonTube(color: world.accent, intensity: 0.55, thickness: 1.2),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WorldAtmosphere(),
          // Tablets: a comfortable reading width, centred; the sky stays
          // full-bleed behind it.
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: body,
            ),
          ),
          const CrtOverlay(opacity: 0.045, animate: false),
        ],
      ),
    );
  }
}

/// The light that leaks into a screen - a living sky behind every page.
///
/// Hawkins: the red title-sequence bloom from above, slowly breathing like
/// a neon sign. The Upside Down: cold storm haze, banks of fog drifting
/// across, distant red lightning that double-flickers through the clouds
/// every few seconds, and vines crawling in from the corners. The two skies
/// crossfade with [WorldPalette.depth], so the storm rolls in as you flip.
class WorldAtmosphere extends StatefulWidget {
  const WorldAtmosphere({super.key});

  @override
  State<WorldAtmosphere> createState() => _WorldAtmosphereState();
}

class _WorldAtmosphereState extends State<WorldAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Distant lightning flickers - off when effects are reduced.
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _SkyPainter(t: _c.value, depth: world.depth),
                size: Size.infinite,
              ),
            ),
          ),
          VineOverlay(grow: Curves.easeOut.transform(world.depth)),
        ],
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  const _SkyPainter({required this.t, required this.depth});

  final double t;
  final double depth;

  /// Distant lightning: a strong double flicker, and a weaker one earlier.
  double get _flash {
    double spike(double at, double width) {
      final d = (t - at).abs();
      return d < width ? 1 - d / width : 0;
    }

    return math.max(
      math.max(spike(0.705, 0.012), spike(0.735, 0.008)),
      0.45 * spike(0.31, 0.01),
    );
  }

  void _glow(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final wave = math.sin(t * math.pi * 2 * 3);

    // Hawkins: breathing red bloom from above, a faint warm floor.
    final hawkins = 1 - depth;
    if (hawkins > 0.01) {
      _glow(
        canvas,
        Offset(w / 2, -h * 0.12),
        h * 0.62,
        AppColors.stRed.withValues(alpha: (0.15 + 0.04 * wave) * hawkins),
      );
      _glow(
        canvas,
        Offset(w * 0.2, h * 1.05),
        h * 0.4,
        AppColors.hawkinsGold.withValues(alpha: 0.035 * hawkins),
      );
    }

    // Upside Down: storm haze, drifting fog, lightning in the clouds.
    if (depth > 0.01) {
      final a = t * math.pi * 2;
      _glow(
        canvas,
        Offset(w / 2, -h * 0.15),
        h * 0.7,
        AppColors.udFogHi.withValues(alpha: 0.9 * depth),
      );
      _glow(
        canvas,
        Offset(w * (0.25 + 0.2 * math.sin(a)), h * 0.32),
        w * 0.75,
        AppColors.udFogHi.withValues(alpha: 0.32 * depth),
      );
      _glow(
        canvas,
        Offset(w * (0.8 - 0.2 * math.cos(a)), h * 0.7),
        w * 0.85,
        AppColors.udFogHi.withValues(alpha: 0.26 * depth),
      );

      final flash = _flash * depth;
      _glow(
        canvas,
        Offset(w * 0.86, -h * 0.04),
        w * (0.6 + 0.35 * flash),
        AppColors.udLightning.withValues(alpha: 0.1 * depth + 0.4 * flash),
      );
      if (flash > 0) {
        canvas.drawRect(
          Offset.zero & size,
          Paint()
            ..color = AppColors.udLightning.withValues(alpha: 0.07 * flash),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter old) =>
      old.t != t || old.depth != depth;
}

/// Back button in a neon ring.
class NeonBackButton extends StatelessWidget {
  const NeonBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Center(
      child: Semantics(
        button: true,
        label: 'Back',
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(color: world.accent.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: world.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(Icons.arrow_back_rounded, color: world.ink, size: 20),
          ),
        ),
      ),
    );
  }
}
