import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Particle engine: floating spores (Upside Down) or warm dust (Hawkins).
///
/// One painter serves both worlds — the caller tints and sizes it. Physics
/// are precomputed per particle so the animation loop does no allocation.
class ParticleField extends StatefulWidget {
  const ParticleField({
    super.key,
    required this.color,
    required this.glowColor,
    this.count = 46,
    this.baseRadius = 1.6,
    this.speed = 1.0,
    this.opacity = 1.0,
  });

  final Color color;
  final Color glowColor;
  final int count;
  final double baseRadius;
  final double speed;
  final double opacity;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 24))
        ..repeat();

  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(1983); // deterministic field, stable across builds
    _particles = List.generate(widget.count, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: widget.baseRadius * (0.5 + rng.nextDouble()),
        drift: 0.25 + rng.nextDouble() * 0.9,
        phase: rng.nextDouble() * math.pi * 2,
        sway: 0.4 + rng.nextDouble() * 1.4,
        pulse: 0.5 + rng.nextDouble() * 2.0,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                t: _controller.value * widget.speed,
                color: widget.color,
                glowColor: widget.glowColor,
                opacity: widget.opacity,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.drift,
    required this.phase,
    required this.sway,
    required this.pulse,
  });

  final double x;
  final double y;
  final double radius;
  final double drift;
  final double phase;
  final double sway;
  final double pulse;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.particles,
    required this.t,
    required this.color,
    required this.glowColor,
    required this.opacity,
  });

  final List<_Particle> particles;
  final double t;
  final Color color;
  final Color glowColor;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.16 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final dotPaint = Paint();

    for (final p in particles) {
      // Slow vertical drift (wraps), horizontal sway (sine).
      final dy = ((p.y - t * 0.045 * p.drift) % 1.0 + 1.0) % 1.0;
      final dx =
          (((p.x + math.sin(t * p.sway + p.phase) * 0.012) % 1.0) + 1.0) % 1.0;
      final center = Offset(dx * size.width, dy * size.height);

      final twinkle =
          0.55 + 0.45 * math.sin(t * p.pulse * 6.283 + p.phase * 3);
      final r = p.radius * (0.75 + 0.25 * twinkle);

      dotPaint.color = color.withValues(alpha: (0.25 + 0.5 * twinkle) * opacity);
      canvas.drawCircle(center, r * 3.2, glowPaint);
      canvas.drawCircle(center, r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.t != t || old.color != color || old.opacity != opacity;
}

/// One-shot radial burst used on taps (correct answer, card press, etc.).
class ParticleBurst extends StatelessWidget {
  const ParticleBurst({
    super.key,
    required this.controller,
    required this.color,
    this.count = 18,
  });

  final Animation<double> controller;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _BurstPainter(
              progress: controller.value,
              color: color,
              count: count,
            ),
          );
        },
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({
    required this.progress,
    required this.color,
    required this.count,
  });

  final double progress;
  final Color color;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1 || size.isEmpty) return;
    final center = size.center(Offset.zero);
    final paint = Paint();
    final maxR = size.shortestSide * 0.5;

    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 + progress * 0.6;
      final dist = maxR * Curves.easeOutCubic.transform(progress);
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * dist;
      paint.color = color.withValues(alpha: (1 - progress) * 0.9);
      canvas.drawCircle(pos, 3.2 * (1 - progress) + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) =>
      old.progress != progress || old.color != color;
}
