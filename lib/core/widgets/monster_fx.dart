import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../platform/test_env.dart';

/// Signature life for each creature of the Upside Down: a procedural
/// animated overlay layered over key art so the monsters *move* — the
/// Demogorgon's maw breathing open, the Mind Flayer's shadow churning,
/// Vecna's levitating motes and clock ring, a Demodog pack skittering, the
/// demo-bat swarm flapping past, the Flayed melting from the ceiling.
///
/// Everything is drawn with cheap seeded paths inside one repeating
/// controller, wrapped in a [RepaintBoundary] so only the overlay's own
/// layer repaints. It never eats taps ([IgnorePointer]), freezes on a
/// deterministic frame inside `flutter test`, and stands still under
/// reduced-motion — same rules as the other effects in this app.
class MonsterFx extends StatefulWidget {
  const MonsterFx({
    super.key,
    required this.monsterId,
    required this.accent,
    this.intensity = 1,
    this.seed,
    this.animate = true,
  });

  /// Creature id — the shared vocabulary of `Character.id` and `Monster.id`
  /// (`demogorgon`, `mind_flayer`, `vecna`, `demodog`, `demo_bat`,
  /// `the_flayed`). Unknown ids fall back to drifting spores.
  final String monsterId;

  /// The creature's own colour.
  final Color accent;

  /// 0..1+ — scales the whole effect (smaller on list cards, larger on the
  /// detail header).
  final double intensity;

  /// Override the seed (defaults to a stable hash of [monsterId], so a
  /// given creature always moves the same way).
  final int? seed;

  /// Set false for a one-frame still (used by static art).
  final bool animate;

  /// The frame shown when animation is off — chosen to read as "mid-move".
  static const double stillFrame = 0.35;

  /// Stable per-id seed (String.hashCode isn't stable across runs).
  static int seedFor(String id) =>
      id.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7fffffff);

  @override
  State<MonsterFx> createState() => _MonsterFxState();
}

class _MonsterFxState extends State<MonsterFx>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    // One ticker for the whole overlay; dormant in tests and when static.
    if (widget.animate && !isFlutterTest) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 5200),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final c = still ? null : _c;

    Widget frame(double t) => IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _DispatchPainter(
            widget.monsterId,
            t: t,
            seed: widget.seed ?? MonsterFx.seedFor(widget.monsterId),
            accent: widget.accent,
            intensity: widget.intensity,
          ),
          size: Size.infinite,
        ),
      ),
    );

    // Reduced motion (or static mode): one still frame, no ticker,
    // never repaints.
    if (c == null) return frame(MonsterFx.stillFrame);
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) => frame(c.value),
    );
  }
}

/// Picks the painter for a creature id, one frame at a time (building the
/// painter is trivial; the work lives in the painters below).
class _DispatchPainter extends CustomPainter {
  _DispatchPainter(
    this.id, {
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final String id;
  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    switch (id) {
      case 'demogorgon':
        _PetalMawPainter(
          t: t,
          seed: seed,
          accent: accent,
          intensity: intensity,
        ).paint(canvas, size);
      case 'mind_flayer':
        _ShadowStormPainter(
          t: t,
          seed: seed,
          accent: accent,
          intensity: intensity,
        ).paint(canvas, size);
      case 'vecna':
        _VecnaPresencePainter(
          t: t,
          seed: seed,
          accent: accent,
          intensity: intensity,
        ).paint(canvas, size);
      case 'demodog':
        _SkitterPackPainter(
          t: t,
          seed: seed,
          accent: accent,
          intensity: intensity,
        ).paint(canvas, size);
      case 'demo_bat':
        _BatSwarmPainter(
          t: t,
          seed: seed,
          accent: accent,
          intensity: intensity,
        ).paint(canvas, size);
      case 'the_flayed':
        _FlayedMeltPainter(
          t: t,
          seed: seed,
          accent: accent,
          intensity: intensity,
        ).paint(canvas, size);
      default:
        _SporeDriftPainter(
          t: t,
          seed: seed,
          accent: accent,
          intensity: intensity,
        ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _DispatchPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Shared helpers.
// ---------------------------------------------------------------------------

double _fract(double x) => (x % 1 + 1) % 1;

/// The effect lives where the creature's icon sits in [KeyArt] — upper
/// right — so it never sits under the name at bottom-left.
Offset _focal(Size size) => Offset(size.width * 0.7, size.height * 0.34);

// ---------------------------------------------------------------------------
// Demogorgon — the petal-faced maw, breathing open and closed.
// ---------------------------------------------------------------------------

class _PetalMawPainter extends CustomPainter {
  _PetalMawPainter({
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final c = _focal(size);
    // One slow unfurl per loop: a flower-head opening, holding, snapping.
    final open =
        (0.35 +
                0.65 *
                    Curves.easeInOut.transform(
                      (math.sin(t * math.pi * 2) * 0.5 + 0.5),
                    ))
            .clamp(0.0, 1.0);
    final r = size.shortestSide * 0.19 * (0.55 + 0.45 * open) * intensity;

    const petals = 6;
    final jitter = [for (var i = 0; i < petals; i++) rng.nextDouble() * 0.5];
    final outline = Path();

    for (var i = 0; i < petals; i++) {
      final a = (i / petals) * math.pi * 2 + jitter[i] + t * 0.35;
      final dir = Offset(math.cos(a), math.sin(a));
      final side = Offset(-dir.dy, dir.dx);
      final len = r * (0.85 + 0.3 * jitter[i]);
      final tip = c + dir * len;
      final c1 = c + dir * len * 0.55 + side * len * 0.4;
      final c2 = c + dir * len * 0.55 - side * len * 0.4;
      final petal = Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(c1.dx, c1.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(c2.dx, c2.dy, c.dx, c.dy);
      outline.addPath(petal, Offset.zero);

      // Teeth: two inward ticks per petal edge.
      final tooth = Paint()
        ..color = Colors.white.withValues(
          alpha: (0.25 + 0.3 * open) * intensity,
        )
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round;
      final mid1 = Offset.lerp(c, c1, 0.85)! + dir * len * 0.1;
      final mid2 = Offset.lerp(c, c2, 0.85)! + dir * len * 0.1;
      canvas.drawLine(mid1, mid1 - side * len * 0.12, tooth);
      canvas.drawLine(mid2, mid2 + side * len * 0.12, tooth);
    }

    // Fleshy head, rim-lit.
    canvas.drawPath(
      outline,
      Paint()
        ..color = accent.withValues(alpha: (0.14 + 0.1 * open) * intensity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = accent.withValues(alpha: 0.75 * intensity),
    );
    // Halo so it glows like the poster art.
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = accent.withValues(alpha: 0.3 * open * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Hot throat: small when closed, burning when open.
    final throat = r * (0.12 + 0.2 * open);
    canvas.drawCircle(
      c,
      throat,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9 * open * intensity),
            accent.withValues(alpha: 0.6 * open * intensity),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: throat * 1.6)),
    );
  }

  @override
  bool shouldRepaint(covariant _PetalMawPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Mind Flayer — the Shadow: churning smoke with occasional lightning.
// ---------------------------------------------------------------------------

class _ShadowStormPainter extends CustomPainter {
  _ShadowStormPainter({
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final c = _focal(size);

    // Three smoke masses orbiting the focal point, breathing.
    for (var i = 0; i < 3; i++) {
      final phase = rng.nextDouble() * math.pi * 2;
      final speed = 0.5 + i * 0.23;
      final orbit = size.shortestSide * (0.1 + 0.06 * i);
      final p =
          c +
          Offset(
            math.cos(t * math.pi * 2 * speed + phase) * orbit,
            math.sin(t * math.pi * 2 * speed * 0.8 + phase) * orbit * 0.7,
          );
      final r = size.shortestSide * (0.16 + 0.05 * i) * intensity;
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xCC06070C).withValues(alpha: 0.75 * intensity),
              accent.withValues(alpha: 0.12 * intensity),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: p, radius: r)),
      );
    }

    // Two wisps curling underneath — dark strokes with soft edges.
    for (var i = 0; i < 2; i++) {
      final base =
          c + Offset(-size.width * 0.15 * i, size.height * 0.12 * (i + 1));
      final sway =
          math.sin(t * math.pi * 2 + i * 2.1) * size.shortestSide * 0.06;
      final path = Path()
        ..moveTo(base.dx - size.width * 0.2, base.dy)
        ..quadraticBezierTo(
          base.dx + sway,
          base.dy - size.height * 0.14,
          base.dx + size.width * 0.22,
          base.dy + sway * 0.5,
        );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0 + 4 * i
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF05060A).withValues(alpha: 0.4 * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Lightning: a forked strike that only exists for ~8% of each cycle.
    final flash = _fract(t * 3 + 0.4);
    if (flash < 0.09) {
      final a = (1 - flash / 0.09) * 0.85 * intensity;
      final strike = Path()..moveTo(c.dx + size.width * 0.06, -4);
      var x = c.dx + size.width * 0.06;
      for (var y = 0.0; y < c.dy; y += size.height * 0.09) {
        x += (rng.nextDouble() - 0.5) * size.width * 0.12;
        strike.lineTo(x, y);
      }
      strike.lineTo(c.dx, c.dy);
      canvas.drawPath(
        strike,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFB9C6FF).withValues(alpha: a * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawPath(
        strike,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShadowStormPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Vecna — levitating motes, a clock ring, a pulse that seeks you.
// ---------------------------------------------------------------------------

class _VecnaPresencePainter extends CustomPainter {
  _VecnaPresencePainter({
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final c = _focal(size);

    // Motes rising like the moment before a victim floats.
    final mote = Paint();
    for (var i = 0; i < 14; i++) {
      final x0 = rng.nextDouble();
      final y0 = rng.nextDouble();
      final speed = 0.08 + rng.nextDouble() * 0.08;
      final y = _fract(y0 - t * speed);
      final x = (x0 + math.sin((y + i) * 6.0) * 0.03) * size.width;
      final alpha = math.sin(y * math.pi) * 0.55 * intensity;
      if (alpha <= 0.02) continue;
      final r = 1 + rng.nextDouble() * 1.4;
      mote
        ..color = Color.lerp(
          Colors.white,
          accent,
          0.55,
        )!.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y * size.height), r * 2, mote);
      canvas.drawCircle(Offset(x, y * size.height), r, mote..maskFilter = null);
    }

    // The clock ring: twelve ticks, a hand sweeping one turn per loop.
    final ringR = size.shortestSide * 0.24 * intensity;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = accent.withValues(alpha: 0.5 * intensity);
    canvas.drawCircle(c, ringR, ring);
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * math.pi * 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        c + dir * ringR * 0.86,
        c + dir * ringR * (i % 3 == 0 ? 0.72 : 0.8),
        ring,
      );
    }
    final hand = t * math.pi * 2 - math.pi / 2;
    canvas.drawLine(
      c,
      c + Offset(math.cos(hand), math.sin(hand)) * ringR * 0.7,
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(
          accent,
          Colors.white,
          0.4,
        )!.withValues(alpha: 0.8 * intensity),
    );
    canvas.drawCircle(
      c,
      3,
      Paint()..color = accent.withValues(alpha: 0.9 * intensity),
    );

    // One expanding pulse — the curse reaching outward.
    final pulse = _fract(t * 0.75);
    final pr = ringR * (1 + pulse * 1.6);
    canvas.drawCircle(
      c,
      pr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = accent.withValues(alpha: (1 - pulse) * 0.3 * intensity),
    );
  }

  @override
  bool shouldRepaint(covariant _VecnaPresencePainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Demodog — a pack skittering across in bursts.
// ---------------------------------------------------------------------------

class _SkitterPackPainter extends CustomPainter {
  _SkitterPackPainter({
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  void _runner(Canvas canvas, Size size, math.Random rng, int lane) {
    final progress = _fract(t * (0.24 + lane * 0.06) + lane * 0.37);
    // Fade at the edges of the run so they phase in and out.
    final edge = (math.sin(progress * math.pi)).clamp(0.0, 1.0);
    if (edge < 0.05) return;

    final scale = (0.75 + rng.nextDouble() * 0.5) * intensity;
    final x = -size.width * 0.12 + progress * size.width * 1.24;
    final yBase = size.height * (0.5 + lane * 0.14);
    final jitterY = math.sin(progress * 34 + lane) * 2.5;
    final body = Offset(x, yBase + jitterY);
    final w = 20.0 * scale;
    final h = 7.5 * scale;
    final alpha = edge * 0.85;

    final bodyPaint = Paint()
      ..color = const Color(0xFF05060A).withValues(alpha: alpha);
    final legPaint = Paint()
      ..color = const Color(0xFF05060A).withValues(alpha: alpha * 0.9)
      ..strokeWidth = 1.4 * scale
      ..strokeCap = StrokeCap.round;

    // Skittering legs: four strokes swinging out of phase.
    for (var i = 0; i < 4; i++) {
      final swing =
          math.sin(t * math.pi * 40 + i * 1.7 + lane * 2.2) * 4 * scale;
      final at = body + Offset((i - 1.5) * w * 0.3, h * 0.2);
      canvas.drawLine(at, at + Offset(swing, h * 0.8), legPaint);
    }

    // Elongated body + snout.
    canvas.drawOval(
      Rect.fromCenter(center: body, width: w, height: h),
      bodyPaint,
    );
    final head = body + Offset(w * 0.55, -h * 0.15);
    canvas.drawCircle(head, h * 0.55, bodyPaint);

    // Eyes: lit coals with a small halo.
    final eye = Offset(head.dx + w * 0.12, head.dy - h * 0.12);
    canvas.drawCircle(
      eye,
      3.4 * scale,
      Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      eye,
      1.3 * scale,
      Paint()..color = Colors.white.withValues(alpha: 0.9 * alpha),
    );
    // A rim of the creature's colour along the back.
    canvas.drawLine(
      body - Offset(w * 0.4, h * 0.3),
      body + Offset(w * 0.35, h * 0.3),
      Paint()
        ..strokeWidth = 1.2
        ..color = accent.withValues(alpha: 0.5 * alpha),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(seed);
    for (var lane = 0; lane < 3; lane++) {
      _runner(canvas, size, rng, lane);
    }
  }

  @override
  bool shouldRepaint(covariant _SkitterPackPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Demo-Bats — silhouettes flapping across on sine paths.
// ---------------------------------------------------------------------------

class _BatSwarmPainter extends CustomPainter {
  _BatSwarmPainter({
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final body = Paint();
    for (var i = 0; i < 5; i++) {
      final speed = 0.14 + rng.nextDouble() * 0.1;
      final off = rng.nextDouble();
      final p = _fract(t * speed + off);
      final x = -size.width * 0.1 + p * size.width * 1.2;
      final yBase = size.height * (0.15 + rng.nextDouble() * 0.5);
      final y = yBase + math.sin(p * math.pi * 4 + i * 1.3) * size.height * 0.1;
      // Phase in/out at the edges of the flight.
      final edge = math.sin(p * math.pi).clamp(0.0, 1.0);
      if (edge < 0.06) continue;

      final scale = (0.7 + rng.nextDouble() * 0.6) * intensity;
      final flap = math.sin(t * math.pi * 2 * (3 + i * 0.6) + i);
      final alpha = edge * 0.8;
      body.color = const Color(0xFF05060A).withValues(alpha: alpha);

      final c = Offset(x, y);
      // Wings: quadratic arcs whose tips rise and fall with the flap.
      final wingLift = flap * 7 * scale;
      final span = 11 * scale;
      final wing = Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(
          c.dx - span * 0.5,
          c.dy - wingLift,
          c.dx - span,
          c.dy + wingLift * 0.4,
        )
        ..quadraticBezierTo(
          c.dx - span * 0.45,
          c.dy + 2 * scale,
          c.dx,
          c.dy + 2.5 * scale,
        )
        ..quadraticBezierTo(
          c.dx + span * 0.45,
          c.dy + 2 * scale,
          c.dx + span,
          c.dy + wingLift * 0.4,
        )
        ..quadraticBezierTo(c.dx + span * 0.5, c.dy - wingLift, c.dx, c.dy)
        ..close();
      canvas.drawPath(wing, body);
      // Body.
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(0, 1.5 * scale),
          width: 3 * scale,
          height: 5.5 * scale,
        ),
        body,
      );
      // A faint rim in the swarm's colour.
      canvas.drawPath(
        wing,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = accent.withValues(alpha: 0.35 * alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BatSwarmPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// The Flayed — infected goo melting down from the ceiling.
// ---------------------------------------------------------------------------

class _FlayedMeltPainter extends CustomPainter {
  _FlayedMeltPainter({
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final goo = Paint()
      ..color = accent.withValues(alpha: 0.35 * intensity)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final glow = Paint()
      ..color = accent.withValues(alpha: 0.22 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (var i = 0; i < 5; i++) {
      final x = size.width * (0.1 + 0.2 * i + rng.nextDouble() * 0.06);
      final speed = 0.3 + rng.nextDouble() * 0.2;
      final grow = _fract(t * speed + rng.nextDouble());
      // Stretch slowly, then let the droplet snap free at the end.
      final eased = Curves.easeInOut.transform(grow.clamp(0.0, 1.0));
      final len = size.height * (0.12 + 0.5 * eased);
      final width = (7 - 3 * eased) * intensity;

      goo.strokeWidth = width;
      glow.strokeWidth = width + 4;
      final path = Path()
        ..moveTo(x, -3)
        ..quadraticBezierTo(
          x + math.sin(i + t * 6) * 6,
          len * 0.6,
          x + math.sin(i * 2.0) * 4,
          len,
        );
      canvas.drawPath(path, glow);
      canvas.drawPath(path, goo);

      // The hanging bead at the tip.
      final tip = Offset(x + math.sin(i * 2.0) * 4, len);
      canvas.drawCircle(
        tip,
        width * 0.9,
        Paint()..color = accent.withValues(alpha: 0.5 * intensity),
      );

      // Detached droplet falling for the last stretch of the cycle.
      if (grow > 0.8) {
        final fall = (grow - 0.8) / 0.2;
        final dy = tip.dy + fall * fall * size.height * 0.4;
        final dr = width * 0.8 * (1 - fall * 0.4);
        canvas.drawCircle(
          Offset(tip.dx, dy),
          dr,
          Paint()
            ..color = accent.withValues(alpha: (0.55 - 0.4 * fall) * intensity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlayedMeltPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Fallback — drifting spores, for any unknown creature id.
// ---------------------------------------------------------------------------

class _SporeDriftPainter extends CustomPainter {
  _SporeDriftPainter({
    required this.t,
    required this.seed,
    required this.accent,
    required this.intensity,
  });

  final double t;
  final int seed;
  final Color accent;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    for (var i = 0; i < 12; i++) {
      final x0 = rng.nextDouble();
      final y0 = rng.nextDouble();
      final speed = 0.05 + rng.nextDouble() * 0.07;
      final y = _fract(y0 - t * speed);
      final x = (x0 + math.sin((y + i) * 4.4) * 0.025) * size.width;
      final alpha = math.sin(y * math.pi) * 0.5 * intensity;
      if (alpha <= 0.02) continue;
      final r = 1.2 + rng.nextDouble() * 1.6;
      final p = Paint()
        ..color = Color.lerp(
          Colors.white,
          accent,
          0.5,
        )!.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y * size.height), r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SporeDriftPainter old) => old.t != t;
}
