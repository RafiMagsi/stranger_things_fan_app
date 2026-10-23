import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../platform/test_env.dart';

class UpsideDownGate extends StatefulWidget {
  final double openPercent;
  final double size;
  final Color color;
  final int seed;
  final VoidCallback? onOpen;
  const UpsideDownGate({
    super.key,
    required this.openPercent,
    this.size = 220,
    this.color = const Color(0xFFE50914),
    this.seed = 1983,
    this.onOpen,
  });
  @override
  State<UpsideDownGate> createState() => _UpsideDownGateState();
}

class _UpsideDownGateState extends State<UpsideDownGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  bool _wasOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The light behind the crack flickers like a struck match - steady
    // under reduced effects and frozen inside tests.
    final still = isFlutterTest || MediaQuery.disableAnimationsOf(context);
    if (still) {
      _c.stop();
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant UpsideDownGate o) {
    super.didUpdateWidget(o);
    if (o.openPercent > 0.5 && !_wasOpen) {
      o.onOpen?.call();
      _wasOpen = true;
    } else if (o.openPercent <= 0.5 && _wasOpen) {
      _wasOpen = false;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 2.2,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _GateWindP(
            p: _c.value,
            color: widget.color,
            seed: widget.seed,
            openPercent: widget.openPercent,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GateWindP extends CustomPainter {
  const _GateWindP({
    required this.p,
    required this.color,
    required this.seed,
    required this.openPercent,
  });

  final double p;
  final Color color;
  final int seed;
  final double openPercent;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(seed);
    final cx = size.width * 0.5;
    final cy = size.height * 0.55;
    final w = size.width * 0.9;
    final h = size.height * 1.7;

    final grad = RadialGradient(
      colors: [
        color.withValues(alpha: 0.55),
        color.withValues(alpha: 0.12),
        Colors.transparent,
      ],
      center: const Alignment(-0.2, -0.3),
      radius: 1.4,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.6,
      Paint()
        ..shader = grad.createShader(
          Rect.fromLTWH(cx - w * 0.6, cy - w * 0.6, w * 1.2, w * 1.2),
        ),
    );

    final path = Path();
    path.moveTo(cx - w * 0.1, 0);
    var drift = 0.0;
    for (var i = 0; i <= 40; i++) {
      final t = i / 40;
      final y = h * t;
      final fx = cx + (rng.nextDouble() - 0.5) * w * 0.5 + drift;
      drift *= -0.3;
      drift += (rng.nextDouble() - 0.5) * w * 0.08;
      path.lineTo(fx, y);
    }
    path.lineTo(cx + w * 0.1, h);

    final clip = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height * openPercent));
    // Only the opened part of the doorway lets the light through.
    final wind = Path.combine(PathOperation.intersect, path, clip);

    final alpha = 0.35 + 0.35 * math.sin(p * math.pi * 2);
    canvas.drawPath(
      wind,
      Paint()
        ..color = color.withValues(alpha: 0.55 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05),
    );
    canvas.drawPath(
      wind,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.01,
    );

    for (var i = 0; i < 22; i++) {
      final y = rng.nextDouble() * size.height * openPercent;
      final x = cx + (rng.nextDouble() - 0.5) * w * 0.9;
      final r = 1 + rng.nextDouble() * 3;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = color.withValues(alpha: (0.15 + rng.nextDouble() * 0.3) * alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GateWindP o) =>
      o.p != p || o.color != color || o.seed != seed || o.openPercent != openPercent;
}
