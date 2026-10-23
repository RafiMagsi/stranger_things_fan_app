import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../theme/world_palette.dart';
import 'st_effects.dart';

/// Grades its child into the active world's light: untouched in Hawkins; in
/// the Upside Down drained of colour, pushed cold and crushed dark - the
/// show's own Upside Down grade. Scales with [WorldPalette.depth], so art
/// cools gradually while the world flips rather than switching.
class WorldGrade extends StatelessWidget {
  const WorldGrade({super.key, required this.child, this.strength = 1});

  final Widget child;
  final double strength;

  static List<double> _matrix(double d) {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    const keep = 0.32; // share of the original saturation that survives
    const dim = 0.82;
    // Per channel: desaturate, then a cold balance (red down, blue up).
    const balance = [0.74, 0.9, 1.16];
    const lift = [0.0, 3.0, 10.0]; // shadows sit in blue, never pure black
    final ud = <double>[];
    for (var ch = 0; ch < 3; ch++) {
      final row = [
        (1 - keep) * lr + (ch == 0 ? keep : 0),
        (1 - keep) * lg + (ch == 1 ? keep : 0),
        (1 - keep) * lb + (ch == 2 ? keep : 0),
      ];
      ud.addAll([for (final v in row) v * balance[ch] * dim, 0, lift[ch]]);
    }
    ud.addAll([0, 0, 0, 1, 0]);
    const identity = [
      1.0, 0.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
    return [for (var i = 0; i < 20; i++) identity[i] + (ud[i] - identity[i]) * d];
  }

  @override
  Widget build(BuildContext context) {
    final d = (WorldPalette.of(context).depth * strength).clamp(0.0, 1.0);
    if (d <= 0.001) return child;
    return ColorFiltered(colorFilter: ColorFilter.matrix(_matrix(d)), child: child);
  }
}

/// Upside Down vines creeping onto a card from one corner. They grow with
/// [WorldPalette.depth] - flip the world and they visibly crawl across
/// every card - and are gone in Hawkins. Static per [seed], so each card
/// keeps its own growth.
class CardVines extends StatelessWidget {
  const CardVines({super.key, required this.seed, this.overArt = false});

  final int seed;

  /// Drawn over full-bleed art: keep to the top corners and a shorter
  /// reach, so faces and the title block at the bottom stay clear.
  final bool overArt;

  @override
  Widget build(BuildContext context) {
    final depth = WorldPalette.of(context).depth;
    if (depth <= 0.01) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _CardVinePainter(
          seed: seed,
          grow: Curves.easeOut.transform(depth),
          overArt: overArt,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _CardVinePainter extends CustomPainter {
  const _CardVinePainter({
    required this.seed,
    required this.grow,
    required this.overArt,
  });

  final int seed;
  final double grow;
  final bool overArt;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(seed);
    // 0/1 = bottom corners, 2/3 = top corners.
    final corner = overArt ? 2 + seed % 2 : seed % 4;
    final origin = Offset(
      corner.isEven ? -2 : size.width + 2,
      corner < 2 ? size.height + 2 : -2,
    );
    // Aim diagonally into the card from the chosen corner.
    final inward = math.atan2(
      (corner < 2 ? -1 : 1) * size.height,
      (corner.isEven ? 1 : -1) * size.width,
    );
    final reach = size.shortestSide * (overArt ? 0.42 : 0.75);

    final vines = <(Path, double)>[];
    for (var v = 0; v < 2; v++) {
      final path = Path()..moveTo(origin.dx, origin.dy);
      var p = origin;
      var a = inward + (rng.nextDouble() - 0.5) * 0.9;
      const segments = 7;
      for (var i = 0; i < segments; i++) {
        a += (rng.nextDouble() - 0.5) * 0.8;
        final next = p + Offset(math.cos(a), math.sin(a)) * (reach / segments);
        final bend = Offset(math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)) *
            ((rng.nextDouble() - 0.5) * reach / segments);
        final c = Offset.lerp(p, next, 0.5)! + bend;
        path.quadraticBezierTo(c.dx, c.dy, next.dx, next.dy);
        if (i == 3) {
          // One side shoot.
          final s = Path()..moveTo(next.dx, next.dy);
          final sa = a + (rng.nextBool() ? 0.9 : -0.9);
          final end = next + Offset(math.cos(sa), math.sin(sa)) * reach * 0.25;
          s.quadraticBezierTo(next.dx + (end.dx - next.dx) * 0.4, end.dy, end.dx, end.dy);
          vines.add((s, 1.6));
        }
        p = next;
      }
      vines.add((path, 3.2 - v * 0.8));
    }

    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF120A1E).withValues(alpha: 0.9);
    final sheen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.udVine.withValues(alpha: 0.45);
    final spore = Paint()..color = AppColors.udSpore.withValues(alpha: 0.55);

    for (final (path, width) in vines) {
      for (final PathMetric m in path.computeMetrics()) {
        final grown = m.extractPath(0, m.length * grow);
        canvas.drawPath(grown, dark..strokeWidth = width);
        canvas.drawPath(grown, sheen..strokeWidth = width * 0.35);
        // A spore glints at the growing tip.
        final tip = m.getTangentForOffset(m.length * grow)?.position;
        if (tip != null) canvas.drawCircle(tip, 1.4, spore);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CardVinePainter old) =>
      old.grow != grow || old.seed != seed || old.overArt != overArt;
}

/// Neon-sign ignition: when a screen arrives its neon titles stutter on -
/// a dull tube, a buzz of light, dark, a catch, then steady - instead of
/// simply appearing. Gives [builder] a glow from 0 (unlit) to 1.
class NeonIgnite extends StatefulWidget {
  const NeonIgnite({super.key, required this.builder, this.delay = Duration.zero});

  final Widget Function(BuildContext context, double glow) builder;
  final Duration delay;

  @override
  State<NeonIgnite> createState() => _NeonIgniteState();
}

class _NeonIgniteState extends State<NeonIgnite>
    with SingleTickerProviderStateMixin {
  static const _run = Duration(milliseconds: 1100);
  AnimationController? _c;
  double _start = 0;
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    // Like FlickerIn: only while the screen is arriving.
    final route = ModalRoute.of(context)?.animation;
    if (route == null || route.status == AnimationStatus.completed) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    final total = widget.delay + _run;
    _start = widget.delay.inMicroseconds / total.inMicroseconds;
    _c = AnimationController(vsync: this, duration: total)..forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  static double _ignite(double t) {
    if (t <= 0) return 0.05;
    if (t < 0.08) return 0.8;
    if (t < 0.16) return 0.05;
    if (t < 0.22) return 0.55;
    if (t < 0.3) return 0.1;
    if (t < 0.5) return 0.1 + 0.9 * ((t - 0.3) / 0.2);
    if (t < 0.56) return 0.55;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return widget.builder(context, 1);
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final t = ((c.value - _start) / (1 - _start)).clamp(0.0, 1.0);
        return widget.builder(context, c.isCompleted ? 1 : _ignite(t));
      },
    );
  }
}

/// Text that types itself out like a Hawkins Lab report on a teletype. The
/// untyped remainder is laid out but invisible, so nothing reflows while it
/// types, and the caret is the background of the next character rather
/// than an extra glyph - the string on screen is always the full text.
class TypewriterText extends StatefulWidget {
  const TypewriterText(
    this.text, {
    super.key,
    required this.style,
    this.charMs = 24,
    this.delay = const Duration(milliseconds: 250),
  });

  final String text;
  final TextStyle style;
  final int charMs;
  final Duration delay;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late final Duration _typing = Duration(milliseconds: widget.text.length * widget.charMs);
  // Created eagerly: build may never touch it (reduced effects), and a lazy
  // controller first created in dispose() would look up a dead context.
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.delay + _typing)..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(widget.text, style: widget.style);
    }
    final caret = widget.style.color ?? Colors.white;
    final start = widget.delay.inMicroseconds / (widget.delay + _typing).inMicroseconds;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = ((_c.value - start) / (1 - start)).clamp(0.0, 1.0);
        final n = (widget.text.length * t).floor();
        if (n >= widget.text.length) return Text(widget.text, style: widget.style);
        final hidden = widget.style.copyWith(color: Colors.transparent);
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: widget.text.substring(0, n), style: widget.style),
              TextSpan(
                text: widget.text[n],
                style: hidden.copyWith(
                  background: Paint()..color = caret.withValues(alpha: 0.75),
                ),
              ),
              TextSpan(text: widget.text.substring(n + 1), style: hidden),
            ],
          ),
        );
      },
    );
  }
}

/// Hero for card art. In flight the art keeps its card's rounded corners
/// until it lands, and its edge burns with the world's neon at mid-flight -
/// like the portrait is being pulled through the Gate with the page.
class STHero extends StatelessWidget {
  const STHero({
    super.key,
    required this.tag,
    required this.child,
    this.radius = 20,
  });

  final Object tag;
  final Widget child;

  /// Corner radius of the card end of the flight.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (flightContext, animation, direction, fromContext, toContext) {
        final art = (toContext.widget as Hero).child;
        final glow = WorldPalette.of(flightContext).accent;
        return AnimatedBuilder(
          animation: animation,
          child: art,
          builder: (context, child) {
            final t = animation.value;
            final burn = math.sin(t * math.pi);
            final r = BorderRadius.circular(radius * (1 - t));
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: r,
                boxShadow: [
                  BoxShadow(color: glow.withValues(alpha: 0.65 * burn), blurRadius: 34 * burn),
                ],
              ),
              child: ClipRRect(
                borderRadius: r,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    child!,
                    Opacity(
                      opacity: burn,
                      child: const CrtOverlay(opacity: 0.22, animate: false),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: child,
    );
  }
}

/// Hawkins Lab redaction: the words are still laid out (so the card keeps
/// its shape) but blacked out like a declassified document.
class RedactedText extends StatelessWidget {
  const RedactedText(this.text, {super.key, required this.style, this.maxLines});

  final String text;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.clip,
        style: style.copyWith(
          color: Colors.transparent,
          background: Paint()..color = const Color(0xFF050505),
        ),
      ),
    );
  }
}

/// The banner on a shielded card: what it is and how to unlock it.
class ClassifiedBanner extends StatelessWidget {
  const ClassifiedBanner({super.key, required this.unlock});

  /// E.g. "S2 · E6".
  final String unlock;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Semantics(
      label: 'Spoiler hidden. Watch $unlock to unlock, or tap to reveal.',
      child: Row(
        children: [
          Icon(Icons.lock, size: 14, color: world.secondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'CLASSIFIED · WATCH $unlock TO UNLOCK · TAP TO DECLASSIFY',
              style: AppText.label(world.secondary).copyWith(fontSize: 10.5, letterSpacing: 1.1),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Film stock over the whole app: fine grain that shifts at 24 frames a
/// second, like the show's photography, and a soft lens vignette. One small
/// noise texture is made once and tiled at a new offset each frame, so it
/// costs almost nothing. Freezes under reduced effects.
class FilmGrain extends StatefulWidget {
  const FilmGrain({super.key, this.opacity = 0.055});

  final double opacity;

  @override
  State<FilmGrain> createState() => _FilmGrainState();
}

class _FilmGrainState extends State<FilmGrain> with SingleTickerProviderStateMixin {
  static ui.Image? _noise; // shared: one texture for the app's lifetime

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    if (_noise == null) {
      const n = 128;
      final rng = math.Random(1983);
      final px = Uint8List(n * n * 4);
      for (var i = 0; i < n * n; i++) {
        final v = rng.nextInt(256);
        px[i * 4] = v;
        px[i * 4 + 1] = v;
        px[i * 4 + 2] = v;
        px[i * 4 + 3] = 255;
      }
      ui.decodeImageFromPixels(px, n, n, ui.PixelFormat.rgba8888, (img) {
        _noise = img;
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
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
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _GrainPainter(
                  noise: _noise,
                  frame: (_c.value * 24).floor(),
                  opacity: widget.opacity,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // The lens: edges fall off into the dark.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.05,
                colors: [Color(0x00000000), Color(0x00000000), Color(0x73000000)],
                stops: [0, 0.62, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter({required this.noise, required this.frame, required this.opacity});

  final ui.Image? noise;
  final int frame;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final img = noise;
    if (img == null || size.isEmpty) return;
    final rng = math.Random(frame);
    final shift = Matrix4.translationValues(rng.nextDouble() * 128, rng.nextDouble() * 128, 0);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ImageShader(img, TileMode.repeated, TileMode.repeated, shift.storage)
        ..color = Colors.white.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) =>
      old.frame != frame || old.noise != noise || old.opacity != opacity;
}

/// Hawkins Lab is always watching. A CCTV feed laid over a subject's file:
/// viewfinder brackets, a blinking REC light, a timecode running from the
/// night they were first seen, and the camera's label. In the Upside Down
/// the feed tears every few seconds. Steady (no blink, no tear) under
/// reduced effects.
class SurveillanceOverlay extends StatefulWidget {
  const SurveillanceOverlay({
    super.key,
    required this.camera,
    required this.subject,
    required this.since,
    this.topInset = 88,
  });

  /// E.g. "CAM 03 · HAWKINS NATIONAL LABORATORY".
  final String camera;

  /// E.g. "SUBJECT 011".
  final String subject;

  /// When the tape starts.
  final DateTime since;
  final double topInset;

  @override
  State<SurveillanceOverlay> createState() => _SurveillanceOverlayState();
}

class _SurveillanceOverlayState extends State<SurveillanceOverlay>
    with SingleTickerProviderStateMixin {
  late final _ticker = createTicker(_onTick);
  Duration _elapsed = Duration.zero;

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  // Repaint only when something visible changes: twice a second.
  void _onTick(Duration elapsed) {
    if (elapsed.inMilliseconds ~/ 500 != _elapsed.inMilliseconds ~/ 500) {
      setState(() => _elapsed = elapsed);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final now = widget.since.add(_elapsed);
    final stamp = '${_months[now.month - 1]} ${_two(now.day)} ${now.year}  '
        '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';
    final rec = reduce || (_elapsed.inMilliseconds ~/ 500).isEven;
    // The Upside Down interferes with the signal.
    final tearing = !reduce && world.depth > 0.5 && _elapsed.inSeconds % 6 == 5 && _elapsed.inMilliseconds % 1000 < 500;
    final osd = AppText.label(Colors.white.withValues(alpha: 0.82)).copyWith(fontSize: 10.5, letterSpacing: 1.4);

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ViewfinderPainter(top: widget.topInset, tearing: tearing)),
          Positioned(
            top: widget.topInset + 10,
            left: 26,
            child: Row(
              children: [
                AnimatedOpacity(
                  opacity: rec ? 1 : 0.15,
                  duration: const Duration(milliseconds: 120),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(color: AppColors.stRedGlow, shape: BoxShape.circle),
                  ),
                ),
                const SizedBox(width: 6),
                Text('REC  $stamp', style: osd),
              ],
            ),
          ),
          Positioned(
            top: widget.topInset + 28,
            left: 26,
            child: Text('${widget.camera}\n${widget.subject} · OBSERVATION', style: osd.copyWith(fontSize: 9.5, color: Colors.white60)),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  const _ViewfinderPainter({required this.top, required this.tearing});

  final double top;
  final bool tearing;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.7);
    const arm = 22.0;
    final r = Rect.fromLTRB(14, top, size.width - 14, size.height - 14);
    for (final (c, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(c, c + Offset(arm * dx, 0), p);
      canvas.drawLine(c, c + Offset(0, arm * dy), p);
    }
    // Centre crosshair, faint.
    final mid = r.center;
    final faint = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawLine(mid - const Offset(10, 0), mid + const Offset(10, 0), faint);
    canvas.drawLine(mid - const Offset(0, 10), mid + const Offset(0, 10), faint);

    if (tearing) {
      final rng = math.Random(DateTime.now().millisecondsSinceEpoch ~/ 120);
      final tear = Paint()..color = Colors.white.withValues(alpha: 0.18);
      for (var i = 0; i < 5; i++) {
        final y = rng.nextDouble() * size.height;
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1 + rng.nextDouble() * 3), tear);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter old) => old.tearing != tearing || tearing || old.top != top;
}
