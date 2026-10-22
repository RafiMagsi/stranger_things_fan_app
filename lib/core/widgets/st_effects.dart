import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A faint CRT scanline + VHS-noise overlay. Drop it over a header or the
/// whole scaffold for that 1983 tube-TV texture. Cheap: one repainting
/// CustomPainter, gated so tests don't spin an endless ticker.
class CrtOverlay extends StatefulWidget {
  const CrtOverlay({
    super.key,
    this.opacity = 0.18,
    this.animate = true,
  });

  final double opacity;
  final bool animate;

  @override
  State<CrtOverlay> createState() => _CrtOverlayState();
}

class _CrtOverlayState extends State<CrtOverlay>
    with SingleTickerProviderStateMixin {
  // Tests pump with a fake clock and never settle an infinite animation, so
  // we only spin the ticker when actually running on a device.
  static const bool _kTest = bool.fromEnvironment('FLUTTER_TEST');

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
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
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return CustomPaint(
              painter: _CrtPainter(
                opacity: widget.opacity,
                // Flicker the noise a little each frame.
                seed: (_c.value * 1000).round(),
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
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scan = Paint()..color = Colors.black.withValues(alpha: opacity);

    // Horizontal scanlines every 3px.
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.2), scan);
    }

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
  static const bool _kTest = bool.fromEnvironment('FLUTTER_TEST');

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  // The wire sags between pegs, like real strung lights.
  late final List<double> _sag = List.generate(
    widget.bulbCount,
    (i) => math.sin(i * 0.9) * 3,
  );

  static const List<Color> _palette = [
    Color(0xFFFF3B30), // red
    Color(0xFFFFCC00), // yellow
    Color(0xFF34C759), // green
    Color(0xFF0A84FF), // blue
    Color(0xFFFF6482), // pink
    Color(0xFFBF5AF2), // purple
  ];

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
              palette: _palette,
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
    required this.palette,
  });

  final int bulbCount;
  final double bulbSize;
  final double spacing;
  final List<double> sag;
  final double t;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..color = const Color(0xFF1B3D1B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

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
    canvas.drawPath(path, wire);

    // Bulbs light in a travelling wave — a message being spelled.
    final head = (t * bulbCount * 2) % (bulbCount + 6);
    for (var i = 0; i < bulbCount; i++) {
      final x = i * spacing + spacing / 2;
      final y = 6 + sag[i];
      final color = palette[i % palette.length];
      final dist = (head - i).abs();
      final lit = (1 - (dist / 5)).clamp(0.0, 1.0);

      // Halo for lit bulbs.
      if (lit > 0.05) {
        final glow = Paint()
          ..color = color.withValues(alpha: 0.5 * lit)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(x, y), bulbSize, glow);
      }

      // The glass.
      final glass = Paint()
        ..color = Color.lerp(color.withValues(alpha: 0.25), color, lit)!;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: bulbSize * 1.2,
          height: bulbSize * 1.6,
        ),
        glass,
      );

      // Bright specular dot when lit.
      if (lit > 0.4) {
        final spark = Paint()..color = Colors.white.withValues(alpha: lit);
        canvas.drawCircle(Offset(x - 1, y - 2), 1.2, spark);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LightsPainter old) => old.t != t;
}
