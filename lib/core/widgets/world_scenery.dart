import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../theme/world_palette.dart';
import 'glow.dart';

/// Distant lightning in the Upside Down over one 0..1 cycle of the sky: a
/// strong double strike late in the cycle and a weaker one earlier.
double skyFlash(double t) {
  double spike(double at, double width) {
    final d = (t - at).abs();
    return d < width ? 1 - d / width : 0;
  }

  return math.max(
    math.max(spike(0.705, 0.012), spike(0.735, 0.008)),
    0.45 * spike(0.31, 0.01),
  );
}

/// The town behind every screen, in whichever world you're in.
///
/// Hawkins (depth 0): a night skyline along the foot of the screen - pines,
/// the water tower with HAWKINS on the tank and its red light blinking, a
/// house with its windows lit, telephone wires strung with Joyce's
/// Christmas bulbs - under stars and fireflies, with the Party riding past
/// on their bikes. Every so often the lights flicker. Something is near.
///
/// The Upside Down (depth 1): the same town, dead. Vines hang from the wires
/// and the tower, the bulbs are out, the windows are black, tendrils climb
/// out of the ground; storm clouds drift overhead, the Mind Flayer looms in
/// them and is lit red when the lightning strikes; spores and broken
/// debris float upward, demobats cross the sky - and the town itself hangs
/// upside down from the top of the screen like a reflection.
///
/// Everything is a function of [t] over a 0..1 loop, so the cycle is
/// seamless; [depth] crossfades the two worlds while they flip.
class WorldSceneryPainter extends CustomPainter {
  WorldSceneryPainter({
    required this.t,
    required this.depth,
    this.horizon = 0.3,
    this.moon = true,
  });

  final double t;
  final double depth;

  /// Whether Hawkins gets a moon (off where a banner already shows one).
  final bool moon;

  /// How much of the height the town takes: 0.3 behind a whole screen,
  /// more in a banner.
  final double horizon;

  static const _night = Color(0xFF07080E);
  static const _udNight = Color(0xFF03050B);

  // Geometry per size and horizon, kept for the few that are on screen.
  static final Map<(Size, double), _Town> _towns = {};

  // Every small light in one batched draw.
  static final _glows = GlowBatch();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final town = _towns[(size, horizon)] ??= () {
      if (_towns.length > 6) {
        for (final t in _towns.values) {
          t.dispose();
        }
        _towns.clear();
      }
      return _Town(size, horizon);
    }();
    final hk = (1 - depth).clamp(0.0, 1.0);
    final ud = depth.clamp(0.0, 1.0);
    final flash = skyFlash(t) * ud;

    if (hk > 0.01) _hawkinsSky(canvas, size, hk);
    if (ud > 0.01) _upsideDownSky(canvas, size, town, ud, flash);
    _glows.paint(canvas); // the moon's halo, behind the town

    // Everything that doesn't move - horizon, the hanging ghost town, the
    // silhouettes, poles, wires, the tank's name - recorded once per step
    // of the world's depth and replayed.
    final step = (depth * 16).round();
    canvas.drawPicture(
      town.still(step, (c) => _paintStill(c, size, town, step / 16)),
    );
    if (flash > 0.01) _stormLight(canvas, size, town, flash);

    _lights(canvas, town, hk, ud);
    if (ud > 0.01) _vines(canvas, size, town, ud);
    if (hk > 0.01) _hawkinsLife(canvas, size, town, hk);
    if (ud > 0.01) _upsideDownLife(canvas, size, town, ud);
    _glows.paint(canvas);
  }

  // ---------------------------------------------------------------- skies

  void _hawkinsSky(Canvas canvas, Size size, double a) {
    if (moon) _moon(canvas, size, a);
    final star = Paint();
    for (final s in _stars) {
      final tw =
          0.35 +
          0.65 * (0.5 + 0.5 * math.sin((t * s.speed + s.phase) * math.pi * 2));
      star.color = Colors.white.withValues(alpha: s.bright * tw * a * 0.7);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height * 0.62),
        s.r,
        star,
      );
    }
  }

  /// A cold crescent with a halo of haze: high in the corner behind a
  /// screen, small and between the words in a banner.
  void _moon(Canvas canvas, Size size, double a) {
    final banner = horizon > 0.3;
    final moon = banner
        ? Offset(size.width * 0.62, size.height * 0.2)
        : Offset(size.width * 0.8, size.height * 0.12);
    final mr = size.width * (banner ? 0.032 : 0.07);
    _glows.add(
      moon,
      mr * 5,
      const Color(0xFFBFD3FF).withValues(alpha: 0.16 * a),
    );
    canvas.drawCircle(
      moon,
      mr,
      Paint()..color = const Color(0xFFE9EEF8).withValues(alpha: 0.85 * a),
    );
    canvas.drawCircle(
      moon + Offset(mr * 0.35, -mr * 0.1),
      mr * 0.92,
      Paint()..color = const Color(0xFF07080E).withValues(alpha: 0.86 * a),
    );
  }

  void _upsideDownSky(
    Canvas canvas,
    Size size,
    _Town town,
    double a,
    double flash,
  ) {
    final w = size.width;
    final h = size.height;
    // Storm banks drifting across the top of the world.
    for (final c in _clouds) {
      final x = ((c.x + t * c.drift) % 1.4 - 0.2) * w;
      final center = Offset(x, c.y * h);
      final r = c.r * w;
      _glows.add(
        center,
        r,
        Color.lerp(
          const Color(0xFF1A2333),
          AppColors.udLightning,
          0.35 * flash,
        )!.withValues(alpha: 0.55 * a),
      );
    }
    // The sky's glows go down now, behind everything else.
    _glows.paint(canvas);
    _mindFlayer(canvas, size, a, flash);
    if (flash > 0.05) _bolt(canvas, size, flash);
  }

  /// The shadow in the storm: a body and its long, reaching legs.
  void _mindFlayer(Canvas canvas, Size size, double a, double flash) {
    final w = size.width;
    final cx = w * 0.5;
    final cy = size.height * 0.13;
    final s = w * 0.68;
    final sway = math.sin(t * math.pi * 2) * 0.04;
    final body = Paint()
      ..color = const Color(0xFF020306).withValues(alpha: 0.62 * a);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.udLightning.withValues(alpha: 0.75 * flash)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final legs = <Path>[];
    for (var i = 0; i < 10; i++) {
      final side = i < 5 ? -1.0 : 1.0;
      final k = (i % 5) / 4; // 0 outer-high .. 1 inner-low
      final reach = s * (0.55 + 0.45 * (1 - k));
      final angle = (0.15 + 0.9 * k) * side + sway * side;
      final end = Offset(
        cx + math.sin(angle) * reach,
        cy + math.cos(angle) * reach * (0.9 + 0.5 * k),
      );
      final ctrl = Offset(
        cx + side * reach * (0.75 - 0.3 * k),
        cy - s * 0.12 + k * s * 0.2,
      );
      legs.add(
        Path()
          ..moveTo(cx, cy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy),
      );
    }
    final leg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = body.color;
    for (final (i, p) in legs.indexed) {
      leg.strokeWidth = s * (0.035 - 0.012 * (i % 5) / 4);
      canvas.drawPath(p, leg);
      if (flash > 0.02) {
        rim.strokeWidth = leg.strokeWidth * 0.6;
        canvas.drawPath(p, rim);
      }
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: s * 0.34,
        height: s * 0.22,
      ),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - s * 0.12),
        width: s * 0.2,
        height: s * 0.16,
      ),
      body,
    );
  }

  /// A forked red bolt for the strike that's flashing now.
  void _bolt(Canvas canvas, Size size, double flash) {
    final rnd = math.Random(t > 0.5 ? 1987 : 1983);
    final w = size.width;
    final h = size.height;
    var p = Offset(w * (0.7 + 0.2 * rnd.nextDouble()), 0);
    final path = Path()..moveTo(p.dx, p.dy);
    final branches = <Path>[];
    final steps = 9;
    for (var i = 0; i < steps; i++) {
      p = p + Offset((rnd.nextDouble() - 0.55) * w * 0.12, h * 0.45 / steps);
      path.lineTo(p.dx, p.dy);
      if (rnd.nextDouble() < 0.3) {
        var q = p;
        final b = Path()..moveTo(q.dx, q.dy);
        for (var j = 0; j < 3; j++) {
          q = q + Offset((rnd.nextDouble() - 0.5) * w * 0.1, h * 0.04);
          b.lineTo(q.dx, q.dy);
        }
        branches.add(b);
      }
    }
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = AppColors.udLightning.withValues(alpha: 0.45 * flash)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final core = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Color.lerp(
        AppColors.udLightning,
        Colors.white,
        0.6,
      )!.withValues(alpha: flash);
    for (final b in [path, ...branches]) {
      canvas.drawPath(b, glow);
      canvas.drawPath(b, core);
    }
  }

  // ----------------------------------------------------------------- town

  /// The parts of the town that never move, at one world depth.
  static void _paintStill(Canvas canvas, Size size, _Town town, double depth) {
    final hk = 1 - depth;
    final ud = depth;
    final base = size.height;
    final top = base - town.skyline * 2.2;
    canvas.drawRect(
      Rect.fromLTRB(0, top, size.width, base),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, base), [
          Colors.transparent,
          Color.lerp(
            AppColors.stRed.withValues(alpha: 0.34 * hk),
            AppColors.udLightning.withValues(alpha: 0.14 * ud),
            ud,
          )!,
        ]),
    );
    if (ud > 0.01) _ghostTown(canvas, size, town, ud);
    final far = Paint()
      ..color = Color.lerp(
        const Color(0xFF0C0F1A),
        const Color(0xFF070B14),
        ud,
      )!.withValues(alpha: 0.95);
    final near = Paint()..color = Color.lerp(_night, _udNight, ud)!;
    canvas.drawPath(town.farTrees, far);
    canvas.drawPath(town.tower, near);
    canvas.drawPath(town.house, near);
    canvas.drawPath(town.nearTrees, near);
    canvas.drawPath(town.ground, near);
    // Rim of the town glow along the tower.
    canvas.drawPath(
      town.tower,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Color.lerp(
          AppColors.stRed,
          AppColors.udLightning,
          ud,
        )!.withValues(alpha: 0.08),
    );
    final pole = Paint()
      ..strokeWidth = 2.2
      ..color = near.color;
    for (final p in town.poles) {
      canvas.drawLine(p, Offset(p.dx, size.height), pole);
      canvas.drawLine(
        p - Offset(town.skyline * 0.09, 0),
        p + Offset(town.skyline * 0.09, 0),
        pole,
      );
    }
    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = const Color(0xFF1A1C24);
    for (final wPath in town.wires) {
      canvas.drawPath(wPath, wire);
    }
    // HAWKINS on the tank, floodlit in town, swallowed in the dark below.
    if (hk > 0.01) {
      canvas.save();
      canvas.translate(town.tankLabel.dx, town.tankLabel.dy);
      town.label.paint(
        canvas,
        Offset(-town.label.width / 2, -town.label.height / 2),
      );
      canvas.restore();
      if (hk < 1) {
        canvas.drawRect(
          Rect.fromCenter(
            center: town.tankLabel,
            width: town.label.width + 4,
            height: town.label.height + 2,
          ),
          Paint()..color = near.color.withValues(alpha: 1 - hk),
        );
      }
    }
  }

  /// The storm lights the horizon and the tower's edge when it strikes.
  void _stormLight(Canvas canvas, Size size, _Town town, double flash) {
    final base = size.height;
    final top = base - town.skyline * 2.2;
    canvas.drawRect(
      Rect.fromLTRB(0, top, size.width, base),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, base), [
          Colors.transparent,
          AppColors.udLightning.withValues(alpha: 0.25 * flash),
        ]),
    );
    canvas.drawPath(
      town.tower,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.udLightning.withValues(alpha: 0.2 * flash),
    );
  }

  /// Windows, the tower's beacon and the bulbs: lit in Hawkins (and
  /// stuttering when something's near), dead in the Upside Down.
  void _lights(Canvas canvas, _Town town, double hk, double ud) {
    final flicker = _flicker;
    for (final (i, r) in town.windows.indexed) {
      final lit = hk * (i == 1 ? flicker : math.max(flicker, 0.4));
      if (lit > 0.01) {
        canvas.drawRect(
          r,
          Paint()
            ..color = const Color(0xFFFFC76B).withValues(alpha: 0.85 * lit),
        );
        _glows.add(
          r.center,
          r.width * 2.2,
          const Color(0xFFFFB347).withValues(alpha: 0.25 * lit),
        );
      }
      if (ud > 0.01 && i == 0) {
        final sick = ud * (0.35 + 0.25 * math.sin(t * math.pi * 2 * 5));
        canvas.drawRect(
          r,
          Paint()..color = AppColors.udLightning.withValues(alpha: 0.5 * sick),
        );
      }
    }
    final blink = (t * 8 % 1) < 0.45 ? 1.0 : 0.15;
    final light = AppColors.stRed.withValues(
      alpha: (0.25 + 0.75 * blink) * (0.3 + 0.7 * hk),
    );
    canvas.drawCircle(town.beacon, 2.4, Paint()..color = light);
    _glows.add(town.beacon, 10, light.withValues(alpha: light.a * 0.5));
    _bulbs(canvas, town, hk, ud, flicker);
  }

  /// 1 = lights on. Around t≈0.48 they stutter, the way they do when the
  /// Demogorgon is close.
  double get _flicker {
    if (t < 0.46 || t > 0.52) return 1;
    final k = ((t - 0.46) * 160).floor();
    return const [1.0, 0.1, 0.9, 0.0, 0.6, 0.05, 1.0, 0.2, 0.8, 1.0][k % 10];
  }

  void _bulbs(Canvas canvas, _Town town, double hk, double ud, double flicker) {
    final core = Paint();
    for (final (i, b) in town.bulbs.indexed) {
      final color = AppColors.bulbs[i % AppColors.bulbs.length];
      // A wave of twinkle runs along the wire.
      final tw = 0.6 + 0.4 * math.sin((t * 6 - i * 0.07) * math.pi * 2);
      final on = hk * tw * flicker;
      if (on > 0.02) _glows.add(b, 7, color.withValues(alpha: 0.55 * on));
      // Dead glass in the Upside Down, but a couple still sputter red.
      final sputter = (i % 11 == 3)
          ? ud * math.max(0, math.sin((t * 9 + i) * math.pi * 2))
          : 0.0;
      core.color = Color.lerp(
        Color.lerp(const Color(0xFF2A2C33), color, on.clamp(0.0, 1.0))!,
        AppColors.udLightning,
        sputter,
      )!.withValues(alpha: 0.9);
      canvas.drawCircle(b, 1.8, core);
    }
  }

  /// Vines hanging off the wires and the tower; tendrils out of the ground.
  void _vines(Canvas canvas, Size size, _Town town, double ud) {
    final vine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(
        _udNight,
        AppColors.udVine,
        0.55,
      )!.withValues(alpha: 0.95 * ud);
    for (final v in town.hangingVines) {
      final sway = math.sin((t * 2 + v.phase) * math.pi * 2) * v.len * 0.08;
      final len = v.len * ud;
      vine.strokeWidth = v.width;
      canvas.drawPath(
        Path()
          ..moveTo(v.root.dx, v.root.dy)
          ..quadraticBezierTo(
            v.root.dx + sway,
            v.root.dy + len * 0.6,
            v.root.dx + sway * 1.6,
            v.root.dy + len,
          ),
        vine,
      );
    }
    for (final v in town.tendrils) {
      final sway = math.sin((t * 3 + v.phase) * math.pi * 2) * v.len * 0.18;
      final len = v.len * ud;
      vine.strokeWidth = v.width;
      canvas.drawPath(
        Path()
          ..moveTo(v.root.dx, v.root.dy)
          ..cubicTo(
            v.root.dx - sway,
            v.root.dy - len * 0.35,
            v.root.dx + sway,
            v.root.dy - len * 0.7,
            v.root.dx + sway * 0.4,
            v.root.dy - len,
          ),
        vine,
      );
    }
  }

  /// The town again, hanging upside down from the top of the screen.
  static void _ghostTown(Canvas canvas, Size size, _Town town, double ud) {
    canvas.save();
    canvas.translate(0, size.height);
    canvas.scale(1, -1);
    final tint = Color.lerp(
      const Color(0xFF151B2C),
      AppColors.udLightning,
      0.15,
    )!;
    final ghost = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height),
        Offset(0, size.height - town.skyline * 1.1),
        [tint.withValues(alpha: 0.6 * ud), tint.withValues(alpha: 0)],
      );
    canvas.drawPath(town.farTrees, ghost);
    canvas.drawPath(town.tower, ghost);
    canvas.restore();
  }

  // ------------------------------------------------------------ the living

  void _hawkinsLife(Canvas canvas, Size size, _Town town, double hk) {
    final w = size.width;
    // Fireflies over the grass.
    for (final f in _fireflies) {
      final x =
          (f.x + 0.025 * math.sin((t * f.speed + f.phase) * math.pi * 2)) * w;
      final y = size.height - town.skyline * (0.2 + f.y);
      final blink = math
          .pow(math.max(0, math.sin((t * f.blink + f.phase) * math.pi * 2)), 3)
          .toDouble();
      if (blink < 0.02) continue;
      _glows.add(
        Offset(x, y),
        6,
        const Color(0xFFFFE08A).withValues(alpha: 0.7 * blink * hk),
      );
    }
    // The Party, riding through town with their headlamps on.
    final ride = (t - 0.05) / 0.5;
    if (ride > 0 && ride < 1) {
      final scale = town.skyline * 0.16;
      for (var k = 0; k < 4; k++) {
        final x = (-0.15 + 1.35 * ride) * w - k * scale * 2.6;
        final bob = math.sin((t * 40 + k) * math.pi * 2) * 0.6;
        _rider(
          canvas,
          Offset(x, size.height - town.skyline * 0.08 + bob),
          scale,
          hk,
        );
      }
    }
  }

  void _rider(Canvas canvas, Offset ground, double s, double a) {
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round
      ..color = _night.withValues(alpha: a);
    final back = ground + Offset(-s * 0.5, -s * 0.32);
    final front = ground + Offset(s * 0.55, -s * 0.32);
    canvas.drawCircle(back, s * 0.32, ink);
    canvas.drawCircle(front, s * 0.32, ink);
    final seat = back + Offset(s * 0.3, -s * 0.5);
    final bars = front + Offset(-s * 0.1, -s * 0.62);
    canvas.drawPath(
      Path()
        ..moveTo(back.dx, back.dy)
        ..lineTo(seat.dx, seat.dy)
        ..lineTo(bars.dx, bars.dy)
        ..lineTo(front.dx, front.dy)
        ..moveTo(seat.dx, seat.dy)
        ..lineTo(ground.dx, back.dy),
      ink,
    );
    final fill = Paint()..color = ink.color;
    final hip = seat + Offset(0, -s * 0.05);
    final shoulder = hip + Offset(s * 0.22, -s * 0.62);
    canvas.drawLine(hip, shoulder, ink..strokeWidth = s * 0.2);
    canvas.drawCircle(shoulder + Offset(s * 0.06, -s * 0.22), s * 0.16, fill);
    // The headlamp and its beam.
    final lamp = bars + Offset(s * 0.12, s * 0.05);
    canvas.drawPath(
      Path()
        ..moveTo(lamp.dx, lamp.dy)
        ..lineTo(lamp.dx + s * 3.2, lamp.dy - s * 0.5)
        ..lineTo(lamp.dx + s * 3.2, lamp.dy + s * 0.7)
        ..close(),
      Paint()
        ..shader = ui.Gradient.linear(lamp, lamp + Offset(s * 3.2, 0), [
          const Color(0xFFFFF1C1).withValues(alpha: 0.35 * a),
          Colors.transparent,
        ]),
    );
    canvas.drawCircle(
      lamp,
      s * 0.07,
      Paint()..color = const Color(0xFFFFF6D5).withValues(alpha: a),
    );
  }

  void _upsideDownLife(Canvas canvas, Size size, _Town town, double ud) {
    final w = size.width;
    final h = size.height;
    // Spores and ash, floating up.
    final spore = Paint();
    for (final p in _spores) {
      final y = ((p.y - t * p.rise) % 1.0) * h;
      final x =
          (p.x + 0.03 * math.sin((t * p.sway + p.phase) * math.pi * 2)) * w;
      final c = Offset(x, y);
      if (p.r > 2.2) {
        _glows.add(c, p.r * 3, AppColors.udSpore.withValues(alpha: 0.22 * ud));
      }
      spore.color = AppColors.udSpore.withValues(alpha: p.alpha * ud);
      canvas.drawCircle(c, p.r, spore);
    }
    // Broken pieces of the town, drifting upward and turning.
    final rock = Paint()
      ..color = const Color(0xFF0A0F1A).withValues(alpha: 0.9 * ud);
    final rockRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.udGlow.withValues(alpha: 0.25 * ud);
    for (final d in _debris) {
      final y = ((d.y - t * d.rise) % 1.0) * h;
      final c = Offset(d.x * w, y);
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(t * math.pi * 2 * d.spin);
      final path = Path()
        ..addPolygon([for (final v in d.shape) v * d.size], true);
      canvas.drawPath(path, rock);
      canvas.drawPath(path, rockRim);
      canvas.restore();
    }
    // A demobat flock crossing the sky.
    final cross = (t - 0.35) / 0.4;
    if (cross > 0 && cross < 1) {
      final bat = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF020306).withValues(alpha: 0.9 * ud);
      for (var k = 0; k < 7; k++) {
        final x = (1.15 - 1.4 * cross) * w + k * 18 + (k.isEven ? 0 : 9);
        final y =
            h * 0.24 +
            math.sin(k * 1.7) * 22 +
            math.sin((t * 6 + k) * math.pi * 2) * 6;
        final flap = math.sin((t * 90 + k) * math.pi * 2) * 5;
        canvas.drawPath(
          Path()
            ..moveTo(x - 8, y - flap)
            ..quadraticBezierTo(x - 3, y + 1, x, y)
            ..quadraticBezierTo(x + 3, y + 1, x + 8, y - flap),
          bat,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant WorldSceneryPainter old) =>
      old.horizon != horizon || old.t != t || old.depth != depth;

  // ------------------------------------------------------- seeded features

  static final List<
    ({double x, double y, double r, double bright, int speed, double phase})
  >
  _stars = () {
    final rnd = math.Random(83);
    return [
      for (var i = 0; i < 70; i++)
        (
          x: rnd.nextDouble(),
          y: math.pow(rnd.nextDouble(), 1.4).toDouble(),
          r: 0.5 + rnd.nextDouble() * 1.1,
          bright: 0.35 + rnd.nextDouble() * 0.65,
          speed: 1 + rnd.nextInt(4),
          phase: rnd.nextDouble(),
        ),
    ];
  }();

  static final List<({double x, double y, double r, int drift})> _clouds = () {
    final rnd = math.Random(84);
    return [
      for (var i = 0; i < 7; i++)
        (
          x: rnd.nextDouble() * 1.4,
          y: 0.04 + rnd.nextDouble() * 0.3,
          r: 0.25 + rnd.nextDouble() * 0.3,
          drift: 1,
        ),
    ];
  }();

  static final List<({double x, double y, int speed, int blink, double phase})>
  _fireflies = () {
    final rnd = math.Random(85);
    return [
      for (var i = 0; i < 16; i++)
        (
          x: rnd.nextDouble(),
          y: rnd.nextDouble() * 0.9,
          speed: 1 + rnd.nextInt(2),
          blink: 3 + rnd.nextInt(4),
          phase: rnd.nextDouble(),
        ),
    ];
  }();

  static final List<
    ({
      double x,
      double y,
      double r,
      double alpha,
      int rise,
      int sway,
      double phase,
    })
  >
  _spores = () {
    final rnd = math.Random(86);
    return [
      for (var i = 0; i < 64; i++)
        (
          x: rnd.nextDouble(),
          y: rnd.nextDouble(),
          r: 0.7 + math.pow(rnd.nextDouble(), 3) * 3.2,
          alpha: 0.25 + rnd.nextDouble() * 0.55,
          rise: 1 + rnd.nextInt(2),
          sway: 1 + rnd.nextInt(3),
          phase: rnd.nextDouble(),
        ),
    ];
  }();

  static final List<
    ({double x, double y, double size, int rise, int spin, List<Offset> shape})
  >
  _debris = () {
    final rnd = math.Random(87);
    return [
      for (var i = 0; i < 6; i++)
        (
          x: 0.05 + rnd.nextDouble() * 0.9,
          y: rnd.nextDouble(),
          size: 3.0 + rnd.nextDouble() * 7,
          rise: 1,
          spin: rnd.nextBool() ? 1 : -1,
          shape: [
            for (var k = 0; k < 6; k++)
              Offset.fromDirection(
                k / 6 * math.pi * 2,
                0.6 + rnd.nextDouble() * 0.6,
              ),
          ],
        ),
    ];
  }();
}

/// The town's fixed geometry for one screen size.
class _Town {
  _Town(this.size, double horizon) {
    final w = size.width;
    final h = size.height;
    skyline = horizon <= 0.3 ? math.min(h * horizon, 260.0) : h * horizon;
    final ground = h - skyline * 0.06;
    final rnd = math.Random(1983);

    Path pines(double minH, double maxH, double y, double spacing) {
      final p = Path();
      var x = -spacing;
      while (x < w + spacing) {
        final th = minH + rnd.nextDouble() * (maxH - minH);
        final tw = th * (0.32 + rnd.nextDouble() * 0.1);
        for (var tier = 0; tier < 3; tier++) {
          final tierTop = y - th + tier * th * 0.24;
          final tierW = tw * (0.55 + tier * 0.25);
          p.moveTo(x, tierTop);
          p.lineTo(x + tierW / 2, tierTop + th * 0.42);
          p.lineTo(x - tierW / 2, tierTop + th * 0.42);
          p.close();
        }
        p.addRect(
          Rect.fromLTWH(x - tw * 0.05, y - th * 0.3, tw * 0.1, th * 0.3),
        );
        x += spacing * (0.55 + rnd.nextDouble() * 0.7);
      }
      p.addRect(Rect.fromLTRB(-10, y - 2, w + 10, h));
      return p;
    }

    farTrees = pines(
      skyline * 0.35,
      skyline * 0.62,
      h - skyline * 0.12,
      skyline * 0.13,
    );
    nearTrees = Path();
    for (final x in [w * 0.04, w * 0.33, w * 0.95]) {
      final th = skyline * (0.55 + rnd.nextDouble() * 0.2);
      for (var tier = 0; tier < 4; tier++) {
        final top = ground - th + tier * th * 0.2;
        final tw = th * (0.22 + tier * 0.1);
        nearTrees.moveTo(x, top);
        nearTrees.lineTo(x + tw / 2, top + th * 0.32);
        nearTrees.lineTo(x - tw / 2, top + th * 0.32);
        nearTrees.close();
      }
    }
    this.ground = Path()..addRect(Rect.fromLTRB(-10, ground, w + 10, h + 10));

    // The water tower.
    final tx = w * 0.74;
    final legH = skyline * 0.5;
    final tankW = skyline * 0.36;
    final tankH = skyline * 0.24;
    final tankBottom = ground - legH;
    tower = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tx - tankW / 2, tankBottom - tankH, tankW, tankH),
          Radius.circular(tankW * 0.12),
        ),
      )
      ..moveTo(tx - tankW * 0.56, tankBottom - tankH)
      ..lineTo(tx, tankBottom - tankH - tankH * 0.45)
      ..lineTo(tx + tankW * 0.56, tankBottom - tankH)
      ..close()
      ..addRect(
        Rect.fromLTWH(tx - tankW * 0.6, tankBottom - 1.5, tankW * 1.2, 3),
      );
    for (final f in [-0.42, -0.14, 0.14, 0.42]) {
      final top = Offset(tx + tankW * f, tankBottom);
      final foot = Offset(tx + tankW * f * 1.45, ground);
      tower.addPolygon([
        top,
        top + const Offset(2.4, 0),
        foot + const Offset(2.4, 0),
        foot,
      ], true);
    }
    for (var k = 1; k <= 2; k++) {
      final y = tankBottom + legH * k / 3;
      final spread = 1 + 0.45 * k / 3;
      tower.addRect(
        Rect.fromLTWH(
          tx - tankW * 0.42 * spread,
          y,
          tankW * 0.84 * spread,
          1.6,
        ),
      );
    }
    beacon = Offset(tx, tankBottom - tankH - tankH * 0.45 - 3);
    tankLabel = Offset(tx, tankBottom - tankH * 0.5);
    label = TextPainter(
      text: TextSpan(
        text: 'HAWKINS',
        style: TextStyle(
          fontFamily: AppText.condensed,
          fontSize: tankH * 0.42,
          fontWeight: FontWeight.w600,
          letterSpacing: tankH * 0.04,
          color: const Color(0xFFE8D9B8).withValues(alpha: 0.42),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // The house, with its windows.
    final hx = w * 0.17;
    final hw = skyline * 0.5;
    final hh = skyline * 0.26;
    final hTop = ground - hh;
    house = Path()
      ..addRect(Rect.fromLTWH(hx - hw / 2, hTop, hw, hh))
      ..moveTo(hx - hw * 0.6, hTop)
      ..lineTo(hx, hTop - hh * 0.6)
      ..lineTo(hx + hw * 0.6, hTop)
      ..close()
      ..addRect(
        Rect.fromLTWH(hx + hw * 0.18, hTop - hh * 0.55, hw * 0.1, hh * 0.35),
      );
    windows = [
      Rect.fromLTWH(hx - hw * 0.34, hTop + hh * 0.3, hw * 0.16, hh * 0.28),
      Rect.fromLTWH(hx + hw * 0.16, hTop + hh * 0.3, hw * 0.16, hh * 0.28),
    ];

    // Telephone poles, wires and the bulbs strung on them.
    final poleTop = ground - skyline * 0.78;
    poles = [
      Offset(w * 0.06, poleTop),
      Offset(w * 0.47, poleTop + skyline * 0.06),
      Offset(w * 0.98, poleTop),
    ];
    for (var i = 0; i + 1 < poles.length; i++) {
      for (final lift in [0.0, skyline * 0.05]) {
        final a = poles[i] + Offset(0, lift);
        final b = poles[i + 1] + Offset(0, lift);
        final sag = skyline * (0.12 + lift / skyline);
        final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + sag * 2);
        wires.add(
          Path()
            ..moveTo(a.dx, a.dy)
            ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy),
        );
        if (lift == 0) {
          final n = ((b.dx - a.dx) / 15).floor();
          for (var k = 1; k < n; k++) {
            final u = k / n;
            final p = Offset(
              (1 - u) * (1 - u) * a.dx +
                  2 * (1 - u) * u * mid.dx +
                  u * u * b.dx,
              (1 - u) * (1 - u) * a.dy +
                  2 * (1 - u) * u * mid.dy +
                  u * u * b.dy,
            );
            bulbs.add(p + const Offset(0, 3));
            if (k % 3 == 0) {
              hangingVines.add((
                root: p,
                len: skyline * (0.08 + rnd.nextDouble() * 0.2),
                width: 1.2 + rnd.nextDouble(),
                phase: rnd.nextDouble(),
              ));
            }
          }
        }
      }
    }
    for (var k = 0; k < 6; k++) {
      hangingVines.add((
        root: Offset(tx - tankW / 2 + tankW * (k + 0.5) / 6, tankBottom),
        len: skyline * (0.1 + rnd.nextDouble() * 0.25),
        width: 1.4 + rnd.nextDouble() * 1.4,
        phase: rnd.nextDouble(),
      ));
    }
    for (var k = 0; k < 12; k++) {
      tendrils.add((
        root: Offset(w * (k + rnd.nextDouble()) / 12, ground + 2),
        len: skyline * (0.25 + rnd.nextDouble() * 0.5),
        width: 1.6 + rnd.nextDouble() * 2.2,
        phase: rnd.nextDouble(),
      ));
    }
  }

  final Size size;

  final Map<int, ui.Picture> _stills = {};

  /// The still town at depth step [step], recorded on first use.
  ui.Picture still(int step, void Function(Canvas) draw) =>
      _stills[step] ??= () {
        final recorder = ui.PictureRecorder();
        draw(Canvas(recorder));
        return recorder.endRecording();
      }();

  void dispose() {
    for (final p in _stills.values) {
      p.dispose();
    }
    _stills.clear();
  }

  late final double skyline;
  late final Path farTrees;
  late final Path nearTrees;
  late final Path ground;
  late final Path tower;
  late final Path house;
  late final List<Rect> windows;
  late final List<Offset> poles;
  final List<Path> wires = [];
  final List<Offset> bulbs = [];
  late final Offset beacon;
  late final Offset tankLabel;
  late final TextPainter label;
  final List<({Offset root, double len, double width, double phase})>
  hangingVines = [];
  final List<({Offset root, double len, double width, double phase})> tendrils =
      [];
}

/// The town as a banner: its own clock, the world's depth, the town filling
/// most of the height. Still under reduced effects.
class WorldSceneryBand extends StatefulWidget {
  const WorldSceneryBand({super.key, this.horizon = 0.6});

  final double horizon;

  @override
  State<WorldSceneryBand> createState() => _WorldSceneryBandState();
}

class _WorldSceneryBandState extends State<WorldSceneryBand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
      _c.value = 0.2;
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
    final depth = WorldPalette.of(context).depth;
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: WorldSceneryPainter(
              t: steppedValue(_c.value, _c.duration!),
              depth: depth,
              horizon: widget.horizon,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
