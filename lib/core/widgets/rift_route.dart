import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/world_palette.dart';

/// Where the last finger came down, in global coordinates. The app shell
/// records every pointer-down, so a pushed page can tear open from the card
/// that was tapped without every call site plumbing a Rect through.
class TapOrigin {
  TapOrigin._();

  static Offset? last;
}

/// The signature page transition: the incoming screen tears open through a
/// writhing, red-rimmed Gate that grows out of the tapped card, the way the
/// portal under Hawkins Lab splits the wall. Strands of goo stretch across
/// the edge and it throws off embers; in the Upside Down the rim crackles
/// with red lightning in cold haze and throws off ash instead. The page
/// behind dims and sinks as it's pulled under. Back closes the tear.
class RiftPageRoute<T> extends PageRouteBuilder<T> {
  RiftPageRoute({
    required this.page,
    String? name,
    Offset? origin,
  })  : origin = origin ?? TapOrigin.last,
        super(
          settings: RouteSettings(name: name),
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 480),
          pageBuilder: (context, animation, secondaryAnimation) => page,
        );

  final Widget page;

  /// Global point the Gate opens from; screen centre when unknown.
  final Offset? origin;

  // Each push gets its own tear shape.
  final double _seed = math.Random().nextDouble() * 100;

  /// Push helper used across the app.
  static Future<T?> push<T>(BuildContext context, Widget page, {String? name}) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      RiftPageRoute<T>(page: page, name: name),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _GateTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      origin: origin,
      seed: _seed,
      child: child,
    );
  }
}

class _GateTransition extends StatelessWidget {
  const _GateTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.origin,
    required this.seed,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Offset? origin;
  final double seed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The tree shape below never changes between frames — only values do —
    // so the page's state survives the transition finishing.
    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      child: child,
      builder: (context, child) {
        final size = MediaQuery.sizeOf(context);
        final depth = WorldPalette.of(context).depth;
        // Reduced effects: no tear, no rim, no particles - just a fade. The
        // widget tree stays the same shape either way.
        final reduce = MediaQuery.disableAnimationsOf(context);
        final t = animation.value;
        final open = Curves.easeInOutCubic.transform(t);
        final cover = Curves.easeInOutCubic.transform(secondaryAnimation.value);
        final center = origin ?? size.center(Offset.zero);
        // Oversized so the edge's inward wobble (up to -14%) still clears
        // the farthest corner as the tear finishes opening.
        final maxR = _farthestCorner(center, size) * 1.25;
        final opening = t < 1 && !reduce;

        return Opacity(
          opacity: (1 - 0.55 * cover) * (reduce ? Curves.easeOut.transform(t) : 1),
          child: Transform.scale(
            scale: 1 - 0.05 * cover,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipPath(
                  clipBehavior: opening ? Clip.antiAlias : Clip.none,
                  clipper: _GateClipper(center, maxR * open, seed, t),
                  child: Transform.scale(
                    scale: opening ? 1.07 - 0.07 * open : 1,
                    child: child,
                  ),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    painter: _GateRimPainter(
                      center: center,
                      radius: maxR * open,
                      seed: seed,
                      t: opening ? t : 1,
                      depth: depth,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static double _farthestCorner(Offset c, Size s) => [
        c,
        Offset(s.width - c.dx, c.dy),
        Offset(c.dx, s.height - c.dy),
        Offset(s.width - c.dx, s.height - c.dy),
      ].map((o) => o.distance).reduce(math.max);
}

/// A ring whose radius writhes with layered sine noise — an organic tear,
/// not a geometric circle. The noise drifts with [t] so the edge squirms.
/// [crackle] adds per-frame jitter on top: electricity along the rim.
Path _gatePath(Offset center, double radius, double seed, double t,
    {double crackle = 0}) {
  const n = 128;
  final path = Path();
  final jitter = crackle > 0 ? math.Random((t * 90).floor() + seed.floor()) : null;
  for (var i = 0; i <= n; i++) {
    final a = i / n * math.pi * 2;
    final wobble = 1 +
        0.07 * math.sin(7 * a + seed + t * 3) +
        0.045 * math.sin(13 * a + seed * 2 - t * 5) +
        0.025 * math.sin(23 * a + seed * 3 + t * 8) +
        (jitter == null || i == n ? 0 : (jitter.nextDouble() - 0.5) * crackle);
    final p = center + Offset(math.cos(a), math.sin(a)) * radius * wobble;
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  return path..close();
}

class _GateClipper extends CustomClipper<Path> {
  const _GateClipper(this.center, this.radius, this.seed, this.t);

  final Offset center;
  final double radius;
  final double seed;
  final double t;

  // ClipPath also clips hit-testing, so once the Gate is fully open the clip
  // must be the whole page or taps in the far corners would be swallowed.
  @override
  Path getClip(Size size) => t >= 1
      ? (Path()..addRect(Offset.zero & size))
      : _gatePath(center, radius, seed, t);

  @override
  bool shouldReclip(covariant _GateClipper old) =>
      old.radius != radius || old.center != center || old.t != t;
}

class _GateRimPainter extends CustomPainter {
  const _GateRimPainter({
    required this.center,
    required this.radius,
    required this.seed,
    required this.t,
    required this.depth,
  });

  final Offset center;
  final double radius;
  final double seed;
  final double t;

  /// 0 = Hawkins (fleshy red tear, embers), 1 = Upside Down (lightning rim
  /// in cold haze, ash).
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    if (t >= 1 || radius <= 0) return;
    final fade = 1 - Curves.easeIn.transform(t);
    final rim = _gatePath(center, radius, seed, t);
    final haze = Color.lerp(AppColors.stRed, AppColors.udGlow, depth)!;
    final edge = Color.lerp(AppColors.stRedGlow, AppColors.udLightning, depth)!;
    final core = Color.lerp(const Color(0xFFFFD6C9), const Color(0xFFE8F1FF), depth)!;

    // Wide halo of the world's light.
    canvas.drawPath(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34 * fade + 6
        ..color = haze.withValues(alpha: 0.5 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Goo strands stretched across the edge, thinning as the tear widens.
    final rng = math.Random(seed.floor());
    final strands = Path();
    for (var i = 0; i < 9; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final inner = center + dir * radius * (0.82 + rng.nextDouble() * 0.08);
      final outer = center + dir * radius * (1.08 + rng.nextDouble() * 0.1);
      final sag = Offset(-dir.dy, dir.dx) * radius * 0.06 * (rng.nextDouble() - 0.5);
      final mid = Offset.lerp(inner, outer, 0.5)! + sag;
      strands
        ..moveTo(inner.dx, inner.dy)
        ..quadraticBezierTo(mid.dx, mid.dy, outer.dx, outer.dy);
    }
    canvas.drawPath(
      strands,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.4 * fade
        ..color = edge.withValues(alpha: 0.55 * fade * (1 - depth * 0.5)),
    );

    // The rim itself - in the Upside Down it crackles like lightning.
    final hot = depth > 0.01
        ? _gatePath(center, radius, seed, t, crackle: 0.035 * depth)
        : rim;
    canvas.drawPath(
      hot,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7 * fade + 1
        ..strokeJoin = StrokeJoin.round
        ..color = edge.withValues(alpha: 0.9 * fade),
    );
    canvas.drawPath(
      hot,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = core.withValues(alpha: fade),
    );

    // Embers (Hawkins) or ash (Upside Down) thrown off the edge.
    final speck = Color.lerp(const Color(0xFFFFB36B), AppColors.udSpore, depth)!;
    final burst = Paint();
    for (var i = 0; i < 48; i++) {
      final a = rng.nextDouble() * math.pi * 2;
      final speed = 0.5 + rng.nextDouble();
      final dist = radius * (0.97 + 0.05 * rng.nextDouble()) + 90 * speed * t;
      final p = center + Offset(math.cos(a), math.sin(a)) * dist;
      burst.color = speck.withValues(alpha: 0.85 * fade * (0.4 + 0.6 * rng.nextDouble()));
      canvas.drawCircle(p, (1 + 1.6 * rng.nextDouble()) * fade + 0.4, burst);
    }
  }

  @override
  bool shouldRepaint(covariant _GateRimPainter old) =>
      old.radius != radius || old.t != t || old.center != center || old.depth != depth;
}

/// The world-flip storm: fired each time Hawkins ⇄ the Upside Down is
/// toggled. Two forked red lightning bolts crack the screen in a double
/// strike (like the Mind Flayer's storm), a red-blue shock ring rolls out,
/// and the frame washes red.
class RiftFlash extends StatelessWidget {
  const RiftFlash({super.key, required this.controller, this.seed = 0});

  final Animation<double> controller;

  /// Changes each strike so the bolts never fork the same way twice.
  final int seed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final v = controller.value;
          if (v <= 0 || v >= 1) return const SizedBox.shrink();
          return CustomPaint(
            painter: _StormPainter(v, seed),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _StormPainter extends CustomPainter {
  const _StormPainter(this.progress, this.seed);

  final double progress;
  final int seed;

  /// Double strike: a hard flash, a beat of dark, a second flash, decay.
  double get _strike {
    final p = progress;
    if (p < 0.06) return p / 0.06;
    if (p < 0.14) return 1 - (p - 0.06) / 0.08 * 0.8;
    if (p < 0.2) return 0.2 + (p - 0.14) / 0.06 * 0.8;
    return math.max(0, 1 - (p - 0.2) / 0.5);
  }

  /// Real lightning runs mostly downhill: a trunk with small sideways kinks
  /// (a random walk that keeps pulling back toward its line), and a few
  /// short forks peeling off and tapering. Trunk and forks go into separate
  /// paths so the trunk can be drawn heavier.
  void _bolt(math.Random rng, Offset from, Offset to, Path trunk, Path forks,
      {bool canFork = true}) {
    const segments = 16;
    final span = to - from;
    final kinkScale = span.distance * 0.045;
    var drift = 0.0;
    trunk.moveTo(from.dx, from.dy);
    for (var i = 1; i <= segments; i++) {
      drift = drift * 0.6 + (rng.nextDouble() - 0.5) * kinkScale;
      final p = from + span * (i / segments) + Offset(drift, 0);
      trunk.lineTo(p.dx, p.dy);
      if (canFork && i > 2 && i < segments - 2 && rng.nextDouble() < 0.2) {
        final len = span.distance * (0.1 + rng.nextDouble() * 0.12);
        final side = rng.nextBool() ? 1.0 : -1.0;
        _bolt(rng, p, p + Offset(side * len * 0.75, len), forks, forks, canFork: false);
        trunk.moveTo(p.dx, p.dy);
      }
    }
  }

  void _drawBolt(Canvas canvas, Path path, double strike, double weight) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16 * weight
        ..color = AppColors.udLightning.withValues(alpha: 0.4 * strike)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * weight),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * weight
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.85 * strike),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * weight
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: strike),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strike = _strike;

    // Red wash over the whole frame.
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.udLightning.withValues(alpha: 0.26 * strike),
    );

    // Two bolts, one per half of the sky, only while the strike is bright.
    if (strike > 0.15) {
      final rng = math.Random(seed * 7919 + 17);
      for (var b = 0; b < 2; b++) {
        final x0 = size.width * (b * 0.5 + 0.1 + rng.nextDouble() * 0.3);
        final from = Offset(x0, -10);
        final to = Offset(
          x0 + (rng.nextDouble() - 0.5) * size.width * 0.3,
          size.height * (0.45 + rng.nextDouble() * 0.35),
        );
        final trunk = Path();
        final forks = Path();
        _bolt(rng, from, to, trunk, forks);
        _drawBolt(canvas, forks, strike * 0.8, 0.55);
        _drawBolt(canvas, trunk, strike, 1);
      }
    }

    // A soft pressure wave rolling out with the thunder: blurred, starting
    // wide, red with a cold blue echo - felt more than seen.
    final center = size.center(Offset.zero);
    final r = size.longestSide * (0.25 + 0.75 * Curves.easeOutCubic.transform(progress));
    final fade = 1 - progress;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40 * fade + 6
        ..color = AppColors.stRed.withValues(alpha: 0.35 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    canvas.drawCircle(
      center,
      r * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16 * fade + 3
        ..color = AppColors.udGlow.withValues(alpha: 0.25 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  @override
  bool shouldRepaint(covariant _StormPainter old) =>
      old.progress != progress || old.seed != seed;
}
