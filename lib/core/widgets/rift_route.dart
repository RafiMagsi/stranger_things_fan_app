import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Custom page routes with a "rift" feel:
///  - forward: incoming screen rises through a red-teal rift with a slight
///    scale + fade; outgoing screen parallax-drifts and dims.
///  - reverse: mirrored, so back navigation feels physical.
class RiftPageRoute<T> extends PageRouteBuilder<T> {
  RiftPageRoute({
    required this.page,
    String? name,
  }) : super(
          settings: RouteSettings(name: name),
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 420),
          opaque: false,
          barrierDismissible: false,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            final coverCurve = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOutCubic,
            );

            // Entrance: rise + fade + settle.
            // Cover: when another route pushes on top, this page drifts
            // left and dims, like it's being pulled under the rift.
            return AnimatedBuilder(
              animation: Listenable.merge([curve, coverCurve]),
              builder: (context, _) {
                final cover = coverCurve.value;
                return Opacity(
                  opacity: (1 - cover * 0.45) * curve.value,
                  child: Transform.translate(
                    offset: Offset(
                      -cover * 64,
                      (1 - curve.value) * 28,
                    ),
                    child: Transform.scale(
                      scale: (0.965 + 0.035 * curve.value) * (1 - cover * 0.03),
                      child: child,
                    ),
                  ),
                );
              },
            );
          },
        );

  final Widget page;

  /// Push helper used across the app.
  static Future<T?> push<T>(BuildContext context, Widget page,
      {String? name}) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      RiftPageRoute<T>(
        page: page,
        name: name,
      ),
    );
  }
}

/// The signature transition: a full-screen rift that flashes across the
/// world when the Upside Down toggle fires. Drawn as a radial red-teal
/// wash that expands from the toggle's center.
class RiftFlash extends StatefulWidget {
  const RiftFlash({super.key, required this.controller});

  final Animation<double> controller;

  @override
  State<RiftFlash> createState() => _RiftFlashState();
}

class _RiftFlashState extends State<RiftFlash> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final v = widget.controller.value;
          if (v <= 0 || v >= 1) return const SizedBox.shrink();
          return CustomPaint(
            painter: _RiftPainter(v),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _RiftPainter extends CustomPainter {
  const _RiftPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.longestSide * 0.9;
    final r = maxR * Curves.easeOutExpo.transform(progress);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28 * (1 - progress) + 4;

    // Expanding red ring.
    paint.color = AppColors.stRed.withValues(alpha: (1 - progress) * 0.8);
    canvas.drawCircle(center, r, paint);

    // Inner teal ring, trailing.
    paint
      ..strokeWidth = 12 * (1 - progress) + 2
      ..color = AppColors.udSpore.withValues(alpha: (1 - progress) * 0.55);
    canvas.drawCircle(center, r * 0.82, paint);

    // Full-screen wash that fades in then out.
    final wash = Paint()
      ..color = AppColors.stRed.withValues(
        alpha: 0.35 * (progress < 0.4 ? progress / 0.4 : (1 - progress) / 0.6),
      );
    canvas.drawRect(Offset.zero & size, wash);
  }

  @override
  bool shouldRepaint(covariant _RiftPainter old) => old.progress != progress;
}
