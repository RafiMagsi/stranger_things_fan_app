import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'world_fx.dart';

// Freezes the looping effects on a fixed frame. `flutter test` does not set
// this on its own (FLUTTER_TEST is an OS env var, not a compile-time define);
// pass `--dart-define=FLUTTER_TEST=true` for deterministic screenshots.
const bool _kTest = bool.fromEnvironment('FLUTTER_TEST');

/// A faint CRT scanline + VHS-noise overlay. Drop it over a header or the
/// whole scaffold for that 1983 tube-TV texture. Cheap: one repainting
/// CustomPainter, gated so tests don't spin an endless ticker. With
/// [animate] off it is a static scanline layer that never repaints.
class CrtOverlay extends StatefulWidget {
  const CrtOverlay({super.key, this.opacity = 0.18, this.animate = true});

  final double opacity;
  final bool animate;

  @override
  State<CrtOverlay> createState() => _CrtOverlayState();
}

class _CrtOverlayState extends State<CrtOverlay>
    with SingleTickerProviderStateMixin {
  // Only created when animating: a static overlay never needs a ticker.
  AnimationController? _c;

  @override
  void initState() {
    super.initState();
    if (widget.animate && !_kTest) {
      _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
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
    // Flickering static is off under reduced effects: show still scanlines.
    final c = MediaQuery.disableAnimationsOf(context) ? null : _c;
    if (c == null) {
      return IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _CrtPainter(opacity: widget.opacity, seed: -1),
            size: Size.infinite,
          ),
        ),
      );
    }
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: c,
          builder: (context, _) {
            return CustomPaint(
              painter: _CrtPainter(
                opacity: widget.opacity,
                // Flicker the noise a little each frame.
                seed: (c.value * 1000).round(),
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _CrtPainter extends CustomPainter {
  const _CrtPainter({required this.opacity, required this.seed});

  final double opacity;

  /// Negative seed = static scanlines only, no streaks.
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scan = Paint()..color = Colors.black.withValues(alpha: opacity);

    // Horizontal scanlines every 3px.
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.2), scan);
    }
    if (seed < 0) return;

    // Sparse horizontal "static" streaks that shift with the seed.
    final rng = math.Random(seed);
    final streak = Paint()..color = Colors.white.withValues(alpha: 0.04);
    for (var i = 0; i < 4; i++) {
      final y = rng.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), streak);
    }
  }

  @override
  bool shouldRepaint(covariant _CrtPainter old) =>
      old.seed != seed || old.opacity != opacity;
}

/// The show's most recognizable set dressing: the alphabet Christmas lights
/// Joyce strung across the wall. Each bulb glows in sequence, like a message
/// being spelled out. Purely decorative.
class ChristmasLights extends StatefulWidget {
  const ChristmasLights({
    super.key,
    this.bulbCount = 24,
    this.bulbSize = 7,
    this.spacing = 14,
    this.animate = true,
  });

  final int bulbCount;
  final double bulbSize;
  final double spacing;
  final bool animate;

  @override
  State<ChristmasLights> createState() => _ChristmasLightsState();
}

class _ChristmasLightsState extends State<ChristmasLights>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  // The wire sags between pegs, like real strung lights.
  late final List<double> _sag = List.generate(
    widget.bulbCount,
    (i) => math.sin(i * 0.9) * 3,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate && !_kTest) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.bulbCount * widget.spacing;
    return SizedBox(
      width: w,
      height: 22,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            painter: _LightsPainter(
              bulbCount: widget.bulbCount,
              bulbSize: widget.bulbSize,
              spacing: widget.spacing,
              sag: _sag,
              t: _kTest ? 0.15 : _c.value,
            ),
          );
        },
      ),
    );
  }
}

class _LightsPainter extends CustomPainter {
  const _LightsPainter({
    required this.bulbCount,
    required this.bulbSize,
    required this.spacing,
    required this.sag,
    required this.t,
  });

  final int bulbCount;
  final double bulbSize;
  final double spacing;
  final List<double> sag;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var i = 0; i < bulbCount; i++) {
      final x = i * spacing + spacing / 2;
      final y = 4 + sag[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final px = (i - 1) * spacing + spacing / 2;
        final py = 4 + sag[i - 1];
        path.quadraticBezierTo((px + x) / 2, (py + y) / 2 + 4, x, y);
      }
    }
    canvas.drawPath(path, _wirePaint);

    // Bulbs light in a travelling wave — a message being spelled.
    final head = (t * bulbCount * 2) % (bulbCount + 6);
    for (var i = 0; i < bulbCount; i++) {
      final dist = (head - i).abs();
      _paintBulb(
        canvas,
        Offset(i * spacing + spacing / 2, 6 + sag[i]),
        AppColors.bulbs[i % AppColors.bulbs.length],
        (1 - (dist / 5)).clamp(0.0, 1.0),
        bulbSize,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LightsPainter old) => old.t != t;
}

final Paint _wirePaint = Paint()
  ..color = const Color(0xFF1B3D1B)
  ..strokeWidth = 1.5
  ..style = PaintingStyle.stroke;

/// One Christmas bulb: halo when lit, colored glass, a specular glint.
/// [dim] is how much colour an unlit bulb's glass still shows.
void _paintBulb(
  Canvas canvas,
  Offset c,
  Color color,
  double lit,
  double size, {
  double dim = 0.28,
}) {
  if (lit > 0.05) {
    canvas.drawCircle(
      c,
      size * (1.1 + lit),
      Paint()
        ..color = color.withValues(alpha: 0.55 * lit)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size),
    );
  }
  canvas.drawOval(
    Rect.fromCenter(center: c, width: size * 1.2, height: size * 1.6),
    Paint()..color = Color.lerp(color.withValues(alpha: dim), color, lit)!,
  );
  if (lit > 0.4) {
    canvas.drawCircle(
      c - Offset(size * 0.15, size * 0.3),
      size * 0.18,
      Paint()..color = Colors.white.withValues(alpha: lit),
    );
  }
}

/// Procedural key art for any card or header without a photo: an
/// accent-lit void, a big silhouette, the show's single hard key light from
/// the top right, and tube-TV scanlines. Graded into the Upside Down by
/// [WorldGrade] when the world flips.
class KeyArt extends StatelessWidget {
  const KeyArt({
    super.key,
    required this.accent,
    this.deep,
    this.icon,
    this.iconSize = 140,
    this.iconAlignment = const Alignment(0.8, -0.3),
  });

  final Color accent;
  final Color? deep;
  final IconData? icon;
  final double iconSize;
  final Alignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    return WorldGrade(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  accent.withValues(alpha: 0.9),
                  deep ?? Color.lerp(accent, Colors.black, 0.72)!,
                  Colors.black,
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
          // Hard key light, top right.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.9, -1),
                radius: 1.1,
                colors: [Color(0x30FFFFFF), Color(0x00FFFFFF)],
              ),
            ),
          ),
          if (icon != null)
            Align(
              alignment: iconAlignment,
              child: Icon(
                icon,
                size: iconSize,
                color: Colors.white.withValues(alpha: 0.17),
                shadows: [Shadow(color: accent, blurRadius: iconSize * 0.25)],
              ),
            ),
          const CrtOverlay(opacity: 0.16, animate: false),
        ],
      ),
    );
  }
}

/// A licensed photo graded into the show's look: crushed, desaturated, and
/// washed in [tint] so a red-carpet snap reads as one of the posters. One
/// colour matrix, no blend layers. [grade] mixes original (0) to full
/// duotone (1).
class DuotonePhoto extends StatelessWidget {
  const DuotonePhoto({
    super.key,
    required this.asset,
    required this.tint,
    this.grade = 0.7,
    this.alignment = const Alignment(0, -0.6),
  });

  final String asset;
  final Color tint;
  final double grade;
  final Alignment alignment;

  static List<double> _matrix(Color tint, double grade) {
    final hi = Color.lerp(tint, Colors.white, 0.55)!;
    final lo = Color.lerp(tint, Colors.black, 0.94)!;
    const lr = 0.2126, lg = 0.7152, lb = 0.0722, contrast = 1.25;
    List<double> row(double h, double l, int channel) {
      final span = h - l;
      final duo = [
        span * contrast * lr,
        span * contrast * lg,
        span * contrast * lb,
        0.0,
        (span * (0.5 - 0.5 * contrast) + l) * 255,
      ];
      // Blend the duotone row with the identity row for this channel.
      final identity = List<double>.filled(5, 0)..[channel] = 1.0;
      return [
        for (var i = 0; i < 5; i++) duo[i] * grade + identity[i] * (1 - grade),
      ];
    }

    return [
      ...row(hi.r, lo.r, 0),
      ...row(hi.g, lo.g, 1),
      ...row(hi.b, lo.b, 2),
      0,
      0,
      0,
      1,
      0,
    ];
  }

  /// The long edge to decode at for a [box]: the smallest bucket that still
  /// covers it (cover-fit crops one axis, hence the headroom), or null for
  /// full size. Buckets, not exact sizes, so a hero flight re-decodes a
  /// couple of times rather than every frame.
  static int? _decodeEdge(Size box, double dpr) {
    final need = box.longestSide * dpr * 1.3;
    if (!need.isFinite) return null;
    for (final bucket in const [480, 960]) {
      if (need <= bucket) return bucket;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_matrix(tint, grade)),
      child: LayoutBuilder(
        builder: (context, box) {
          // Story mode wants the full 1400px still; a small tile doesn't
          // need to hold one in the image cache.
          final edge = _decodeEdge(box.biggest, dpr);
          final ImageProvider image = edge == null
              ? AssetImage(asset)
              : ResizeImage(
                  AssetImage(asset),
                  width: edge,
                  height: edge,
                  policy: ResizeImagePolicy.fit,
                );
          return Image(
            image: image,
            fit: BoxFit.cover,
            alignment: alignment,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => KeyArt(accent: tint),
          );
        },
      ),
    );
  }
}

/// The Gate: a breathing, fleshy red tear in the dark, like the one under
/// Hawkins Lab. Draws a seeded jagged crack with branching tendrils and a
/// layered glow; [animate] makes it pulse.
class GateArt extends StatefulWidget {
  const GateArt({
    super.key,
    this.color = AppColors.stRed,
    this.seed = 1983,
    this.animate = true,
  });

  final Color color;
  final int seed;
  final bool animate;

  @override
  State<GateArt> createState() => _GateArtState();
}

class _GateArtState extends State<GateArt> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The Gate breathes, unless effects are reduced.
    final still =
        !widget.animate || _kTest || MediaQuery.disableAnimationsOf(context);
    if (still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _GatePainter(
            color: widget.color,
            seed: widget.seed,
            pulse: Curves.easeInOut.transform(_c.value),
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GatePainter extends CustomPainter {
  const _GatePainter({
    required this.color,
    required this.seed,
    required this.pulse,
  });

  final Color color;
  final int seed;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(seed);
    final w = size.width;
    final cx = w * 0.8;

    // Main crack: a thin vertical seam that wanders (a random walk pulled
    // back toward its centre line), widest in the middle like a wound.
    final left = <Offset>[];
    final right = <Offset>[];
    const steps = 34;
    var drift = 0.0;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final y = size.height * (-0.05 + 1.1 * t);
      final bulge = math.sin(t * math.pi);
      drift = drift * 0.7 + (rng.nextDouble() - 0.5) * w * 0.035;
      final half = w * (0.003 + 0.016 * bulge) * (0.9 + 0.2 * pulse);
      left.add(Offset(cx + drift - half, y));
      right.add(Offset(cx + drift + half, y));
    }
    final crack = Path()..addPolygon([...left, ...right.reversed], true);

    // Fleshy tendrils curling out from the seam.
    final tendrils = Path();
    for (var i = 0; i < 12; i++) {
      final from = (rng.nextBool() ? left : right)[3 + rng.nextInt(steps - 6)];
      final dir = from.dx < cx + drift ? -1.0 : 1.0;
      final len = w * (0.06 + rng.nextDouble() * 0.16);
      final end = from + Offset(dir * len, (rng.nextDouble() - 0.5) * len);
      final ctrl =
          Offset.lerp(from, end, 0.5)! +
          Offset(0, (rng.nextDouble() - 0.5) * len * 0.7);
      tendrils
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    }

    final glow = 0.75 + 0.25 * pulse;
    // Two blooms: a wide haze of red light, then a tight hot halo.
    canvas.drawPath(
      crack,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.12
        ..color = color.withValues(alpha: 0.28 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.12),
    );
    canvas.drawPath(
      crack,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025
        ..color = color.withValues(alpha: 0.75 * glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03),
    );
    canvas.drawPath(
      tendrils,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.6 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    // Hot flesh of the tear.
    canvas.drawPath(
      crack,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            Color.lerp(color, const Color(0xFFFFB199), 0.6 * glow)!,
            color,
          ],
        ).createShader(Offset.zero & size),
    );
    // White-hot core.
    canvas.drawPath(
      crack,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.5 * glow),
    );
  }

  @override
  bool shouldRepaint(covariant _GatePainter old) =>
      old.pulse != pulse || old.color != color || old.seed != seed;
}

/// Upside Down vines creeping in from the screen corners — seeded, and
/// cached by a RepaintBoundary. [grow] (0..1) is how far they've crawled;
/// branches only sprout once the vine has grown past them.
class VineOverlay extends StatelessWidget {
  const VineOverlay({
    super.key,
    this.color = AppColors.udVine,
    this.seed = 7,
    this.grow = 1,
  });

  final Color color;
  final int seed;
  final double grow;

  @override
  Widget build(BuildContext context) {
    if (grow <= 0.01) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _VinePainter(color: color, seed: seed, grow: grow),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _VinePainter extends CustomPainter {
  const _VinePainter({
    required this.color,
    required this.seed,
    required this.grow,
  });

  final Color color;
  final int seed;
  final double grow;

  void _vine(
    Canvas canvas,
    math.Random rng,
    Offset start,
    double angle,
    double length,
    double width,
    int depth, [
    double progress = 1,
  ]) {
    final path = Path()..moveTo(start.dx, start.dy);
    var p = start;
    var a = angle;
    const segments = 8;
    final seg = length / segments;
    final branches = <(Offset, double, double)>[];
    for (var i = 0; i < segments; i++) {
      a += (rng.nextDouble() - 0.5) * 0.7;
      final next = p + Offset(math.cos(a), math.sin(a)) * seg;
      final ctrl =
          Offset.lerp(p, next, 0.5)! +
          Offset(math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)) *
              (rng.nextDouble() - 0.5) *
              seg;
      path.quadraticBezierTo(ctrl.dx, ctrl.dy, next.dx, next.dy);
      if (depth > 0 && rng.nextDouble() < 0.35) {
        branches.add((next, a, (i + 1) / segments));
      }
      p = next;
    }
    // Draw only the part that has grown so far.
    if (progress <= 0) return;
    final grown = Path();
    for (final m in path.computeMetrics()) {
      grown.addPath(m.extractPath(0, m.length * progress), Offset.zero);
    }
    canvas.drawPath(
      grown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width
        ..color = Color.lerp(
          color,
          Colors.black,
          0.55,
        )!.withValues(alpha: 0.85),
    );
    canvas.drawPath(
      grown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 0.35
        ..color = color.withValues(alpha: 0.35),
    );
    for (final (o, ang, at) in branches) {
      _vine(
        canvas,
        rng,
        o,
        ang + (rng.nextBool() ? 0.8 : -0.8),
        length * 0.45,
        width * 0.6,
        depth - 1,
        // A branch starts growing once the vine has passed it.
        ((progress - at) / (1 - at)).clamp(0.0, 1.0),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(seed);
    final reach = size.shortestSide * 0.42;
    // Bottom-left corner, growing up and inward.
    for (var i = 0; i < 3; i++) {
      _vine(
        canvas,
        rng,
        Offset(-4, size.height - rng.nextDouble() * 60),
        -0.5 - rng.nextDouble() * 0.6,
        reach * (0.6 + rng.nextDouble() * 0.5),
        5,
        2,
        grow,
      );
    }
    // Top-right corner, hanging down.
    for (var i = 0; i < 2; i++) {
      _vine(
        canvas,
        rng,
        Offset(size.width + 4, rng.nextDouble() * 80),
        math.pi * 0.7 + rng.nextDouble() * 0.4,
        reach * (0.5 + rng.nextDouble() * 0.4),
        4,
        2,
        grow,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VinePainter old) =>
      old.color != color || old.seed != seed || old.grow != grow;
}

/// Joyce Byers' living-room wall: the alphabet painted under a strand of
/// Christmas lights in three rows (A–H, I–Q, R–Z). One bulb at a time
/// spells [message], then the whole strand flickers — exactly how Will
/// talked to his mother from the Upside Down.
class AlphabetWall extends StatefulWidget {
  const AlphabetWall({
    super.key,
    required this.message,
    this.upsideDown = false,
  });

  final String message;

  /// The Upside Down copy of the Byers house: cold, decayed wallpaper.
  final bool upsideDown;

  @override
  State<AlphabetWall> createState() => _AlphabetWallState();
}

class _AlphabetWallState extends State<AlphabetWall>
    with SingleTickerProviderStateMixin {
  static const _perLetter = 720; // ms each bulb stays lit
  static const _tail = 1800; // ms of strand flicker after the message

  late final AnimationController _c = AnimationController(vsync: this);

  String get _letters =>
      widget.message.toUpperCase().replaceAll(RegExp('[^A-Z ]'), '');

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(covariant AlphabetWall old) {
    super.didUpdateWidget(old);
    if (old.message != widget.message) _restart();
  }

  void _restart() {
    _c.duration = Duration(milliseconds: _letters.length * _perLetter + _tail);
    if (_kTest) {
      _c.value = 0.0;
    } else {
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
    return Semantics(
      label: 'Alphabet wall spelling ${widget.message}',
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 1.75,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final ms = _c.value * (_c.duration?.inMilliseconds ?? 1);
                return CustomPaint(
                  painter: _WallPainter(
                    letters: _letters,
                    ms: ms,
                    perLetter: _perLetter,
                    upsideDown: widget.upsideDown,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _WallPainter extends CustomPainter {
  _WallPainter({
    required this.letters,
    required this.ms,
    required this.perLetter,
    required this.upsideDown,
  });

  final String letters;
  final double ms;
  final int perLetter;
  final bool upsideDown;

  static const _rows = ['ABCDEFGH', 'IJKLMNOPQ', 'RSTUVWXYZ'];

  @override
  void paint(Canvas canvas, Size size) {
    // Wallpaper: faded floral in Hawkins, cold rot in the Upside Down.
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 1.2,
          colors: upsideDown
              ? const [Color(0xFF3A4656), Color(0xFF1A2230), Color(0xFF0A0F16)]
              : const [Color(0xFFCDB98F), Color(0xFF9C8660), Color(0xFF4A3A24)],
          stops: const [0, 0.6, 1],
        ).createShader(rect),
    );
    // Damask dots so it reads as patterned paper, not a flat panel.
    final dot = Paint()
      ..color = (upsideDown ? Colors.white : const Color(0xFF5A4325))
          .withValues(alpha: 0.08);
    for (double y = 8; y < size.height; y += 18) {
      for (double x = (y ~/ 18).isEven ? 8 : 17; x < size.width; x += 18) {
        canvas.drawCircle(Offset(x, y), 2.2, dot);
      }
    }

    // Which letter is lit right now (if any), and the closing flicker.
    final spelled = ms / perLetter;
    final idx = spelled.floor();
    final current = idx < letters.length ? letters[idx] : null;
    final inLetter = spelled - idx;
    final tail = idx >= letters.length;
    final flicker = tail && ((ms ~/ 110) % 3 != 0);

    final rowH = size.height / 3;
    final rng = math.Random(3);
    var bulbIndex = 0;
    for (var r = 0; r < _rows.length; r++) {
      final row = _rows[r];
      final spacing = size.width / (row.length + 0.6);
      final wireY = rowH * r + rowH * 0.22;
      final wire = Path();
      for (var i = 0; i < row.length; i++) {
        final x = spacing * (i + 0.8);
        final y = wireY + math.sin(i * 1.3 + r) * 2;
        if (i == 0) {
          wire.moveTo(x - spacing * 0.6, y - 2);
        }
        wire.quadraticBezierTo(x - spacing / 2, y + 5, x, y);
      }
      canvas.drawPath(wire, _wirePaint);

      for (var i = 0; i < row.length; i++) {
        final ch = row[i];
        final x = spacing * (i + 0.8);
        final y = wireY + math.sin(i * 1.3 + r) * 2;
        final color = AppColors.bulbs[bulbIndex++ % AppColors.bulbs.length];
        final isCurrent = ch == current && inLetter < 0.82;
        final lit = isCurrent ? 1.0 : (flicker ? 0.9 : 0.0);
        // On the wall you can always see the coloured glass, lit or not.
        _paintBulb(
          canvas,
          Offset(x, y + 6),
          color,
          lit,
          spacing * 0.22,
          dim: 0.6,
        );

        // Hand-painted letter under the bulb, slightly crooked.
        final tp = TextPainter(
          text: TextSpan(
            text: ch,
            style: TextStyle(
              fontFamily: AppText.display,
              fontWeight: FontWeight.w900,
              fontVariations: const [FontVariation('wght', 900)],
              fontSize: rowH * 0.42,
              color: upsideDown
                  ? const Color(0xFFB9C6D8).withValues(alpha: 0.75)
                  : const Color(0xFF15100B),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        canvas.save();
        canvas.translate(x, y + rowH * 0.5);
        canvas.rotate((rng.nextDouble() - 0.5) * 0.16);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }
    }

    // Vignette so the wall sits in a dark room.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _WallPainter old) =>
      old.ms != ms || old.letters != letters || old.upsideDown != upsideDown;
}

/// Vecna's room: a Victorian hallway lit by one strip of gold, a cracked
/// grandfather clock ticking loud enough to hear, rain on the window, and
/// the empty space where someone is waiting.
///
/// On Vecna's dossier header it sits behind the name; in [story] mode it
/// can take the whole card. The clock is the pulse of the scene: its hand
/// sweeps, the chimes rattle it, and a strike cracks through every so
/// often — the same rhythm as the show's Vecna kill time.
class VecnaScene extends StatefulWidget {
  const VecnaScene({
    super.key,
    required this.accent,
    this.loopSeconds = 14,
    this.story = false,
    this.animate = true,
  });

  /// The cold, bruised purple of Vecna's iconic red-gold light in context.
  final Color accent;

  /// One full loop of the clock + rain + mood — long so the ticks feel real.
  final double loopSeconds;

  /// Full-screen treatment with a darker room and the door frame visible.
  final bool story;

  /// False = a single settled frame (used under reduced motion).
  final bool animate;

  @override
  State<VecnaScene> createState() => _VecnaSceneState();
}

class _VecnaSceneState extends State<VecnaScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.loopSeconds * 1000).round()),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (widget.animate && !still && !_kTest) {
      if (!_c.isAnimating) _c.repeat();
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _kTest
        ? 0.6
        : (_c.isAnimating ? _c.value : 0.4);
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _VecnaRoomPainter(
            t: t,
            accent: widget.accent,
            loop: widget.loopSeconds,
            story: widget.story,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _VecnaRoomPainter extends CustomPainter {
  _VecnaRoomPainter({
    required this.t,
    required this.accent,
    required this.loop,
    required this.story,
  });

  final double t;
  final Color accent;
  final double loop;
  final bool story;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(7);
    final w = size.width;
    final h = size.height;

    // Room: dark wall with one gold strip from a window, plus rain.
    final wall = Paint()
      ..color = const Color(0xFF0A0A0E).withValues(alpha: 0.95);
    canvas.drawRect(Offset.zero & size, wall);

    // Window light, top-left, dusty.
    final window = Rect.fromLTWH(w * 0.06, h * 0.04, w * 0.32, h * 0.5);
    canvas.drawRect(
      window,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.5, -0.5),
          radius: 1.1,
          colors: [
            accent.withValues(alpha: 0.32),
            accent.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ).createShader(window),
    );

    // Rain streaks, random but seeded.
    final rain = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..strokeWidth = 1.2;
    for (var i = 0; i < 60; i++) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h;
      final len = 14 + rng.nextDouble() * 22;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 3, y + len),
        rain,
      );
    }

    // Clock: centered, big, behind the name in non-story mode.
    final cx = story ? w * 0.5 : w * 0.5;
    final cy = story ? h * 0.42 : h * 0.42;
    final clockR = story ? w * 0.16 : w * 0.13;

    // Frame shadow.
    canvas.drawCircle(
      Offset(cx, cy),
      clockR + 10,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Clock face — cracked, old, with a warm rim.
    final face = Paint()
      ..color = const Color(0xFF221C2A).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), clockR, face);

    final rim = Paint()
      ..color = accent.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(cx, cy), clockR, rim);

    final rim2 = Paint()
      ..color = accent.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(Offset(cx, cy), clockR - 2, rim2);

    // Cracks on the face.
    final crack = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final a0 = rng.nextDouble() * math.pi * 2;
      var a = a0;
      var px = cx + math.cos(a) * clockR * 0.2;
      var py = cy + math.sin(a) * clockR * 0.2;
      canvas.drawLine(Offset(cx, cy), Offset(px, py), crack);
      for (var j = 0; j < 3; j++) {
        a += (rng.nextDouble() - 0.5) * 0.8;
        px += math.cos(a) * clockR * 0.12;
        py += math.sin(a) * clockR * 0.12;
        canvas.drawLine(
          Offset(px - math.cos(a) * clockR * 0.04, py - math.sin(a) * clockR * 0.04),
          Offset(px, py),
          crack,
        );
      }
    }

    // Roman-ish hour ticks.
    for (var i = 0; i < 12; i++) {
      final a = i / 12 * math.pi * 2 - math.pi / 2;
      final inner = clockR * 0.78;
      final outer = clockR * (i % 3 == 0 ? 0.7 : 0.74);
      canvas.drawLine(
        Offset(cx + math.cos(a) * inner, cy + math.sin(a) * inner),
        Offset(cx + math.cos(a) * outer, cy + math.sin(a) * outer),
        Paint()
          ..color = accent.withValues(alpha: 0.6)
          ..strokeWidth = 2,
      );
    }

    // Clock hand sweeping around, one revolution per loop.
    final handAngle = t * math.pi * 2 - math.pi / 2;
    final handLen = clockR * 0.62;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + math.cos(handAngle) * handLen, cy + math.sin(handAngle) * handLen),
      Paint()
        ..color = accent.withValues(alpha: 0.9)
        ..strokeWidth = 3,
    );
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = accent);

    // A thin tail on the hand.
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx - math.cos(handAngle) * clockR * 0.12, cy - math.sin(handAngle) * clockR * 0.12),
      Paint()
        ..color = accent.withValues(alpha: 0.7)
        ..strokeWidth = 1.6,
    );

    // Chimes: clock rattle — only when a chime instant happens in the loop.
    final chimePhase = (t * 4) % 1.0; // four chimes per loop
    final chimeFlash = (1 - (chimePhase / 0.08).clamp(0.0, 1.0));
    if (chimeFlash > 0) {
      canvas.drawCircle(
        Offset(cx, cy),
        clockR * 1.2,
        Paint()
          ..color = accent.withValues(alpha: 0.25 * chimeFlash)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
    }

    // A big, soft gold glow behind the clock, breathing.
    final glowPulse = 0.6 + 0.4 * math.sin(t * math.pi * 2 * 0.4);
    canvas.drawCircle(
      Offset(cx, cy),
      clockR * 2.4 * glowPulse,
      Paint()
        ..color = accent.withValues(alpha: 0.08 * glowPulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );

    // Dust motes in the gold light.
    final mote = Paint()
      ..color = accent.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    final mote2 = Paint()
      ..color = accent.withValues(alpha: 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
    for (var i = 0; i < 10; i++) {
      final x0 = rng.nextDouble() * w;
      final y0 = rng.nextDouble() * h;
      final sp = 0.1 + rng.nextDouble() * 0.15;
      final y = ((y0 + t * sp) % 1.0) * h;
      final x = (x0 + math.sin((y / h + i) * 6) * 0.02 * w) % w;
      final a = math.sin((y / h) * math.pi) * 0.7;
      if (a <= 0.05) continue;
      final r = 1.2 + rng.nextDouble() * 1.4;
      canvas.drawCircle(Offset(x, y), r, mote);
      if (rng.nextDouble() > 0.7) {
        canvas.drawCircle(Offset(x, y), r * 0.4, mote2);
      }
    }

    // Door frame, right side, in story mode — someone standing there.
    if (story) {
      final doorX = w * 0.86;
      final doorW = w * 0.1;
      final doorH = h * 0.8;
      // Frame.
      canvas.drawRect(
        Rect.fromLTWH(doorX - 6, h * 0.05, doorW + 12, doorH),
        Paint()
          ..color = const Color(0xFF1A1620).withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      // Dark opening.
      canvas.drawRect(
        Rect.fromLTWH(doorX, h * 0.08, doorW, doorH * 0.9),
        Paint()
          ..color = const Color(0xFF050508)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // A single gold sliver through the door gap, flickering.
      final sliver = accent.withValues(alpha: 0.5 + 0.3 * math.sin(t * math.pi * 8));
      canvas.drawRect(
        Rect.fromLTWH(doorX + doorW * 0.3, h * 0.08, doorW * 0.08, doorH * 0.9),
        Paint()
          ..color = sliver
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // A shadow figure in the doorway, barely there.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(doorX + doorW * 0.18, h * 0.12, doorW * 0.64, doorH * 0.7),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      // Two eyes, faint gold.
      final eyeY = h * 0.2;
      canvas.drawCircle(
        Offset(doorX + doorW * 0.34, eyeY),
        2.4,
        Paint()..color = accent.withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        Offset(doorX + doorW * 0.5, eyeY),
        2.4,
        Paint()..color = accent.withValues(alpha: 0.9),
      );
    }

    // Vignette.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: 1.05,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _VecnaRoomPainter old) =>
      old.t != t || old.accent != accent || old.story != story;
}
