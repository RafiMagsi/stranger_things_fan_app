import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// The show's logotype, rebuilt from type: STRANGER over THINGS in hollow
/// neon Benguiat, the oversized S and R that cap the top word, the bar that
/// joins them, and the rule that THINGS hangs from.
///
/// [spread] pulls the letters apart (1 = scattered, 0 = settled) for the
/// title-sequence converge on the splash screen; the bars only light once
/// the letters have locked together.
class STLogo extends StatelessWidget {
  const STLogo({
    super.key,
    this.size = 40,
    this.glow = 1.0,
    this.spread = 0.0,
    this.color = AppColors.stRed,
  });

  /// Cap height of the small letters, in logical pixels.
  final double size;
  final double glow;
  final double spread;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final big = size * 1.34;
    final bars = (1 - spread * 2.2).clamp(0.0, 1.0);
    final barThickness = (size * 0.07).clamp(1.5, 5.0);

    Widget letter(String ch, double s, int i, int n) => Transform.translate(
          offset: Offset((i - (n - 1) / 2) * spread * s * 0.75, 0),
          child: Text(
            ch,
            style: AppText.neon(
              size: s,
              color: color,
              glow: glow,
              letterSpacing: 0.015,
            ),
          ),
        );

    const top = 'STRANGER';
    const bottom = 'THINGS';
    final bar = _Bar(color: color, opacity: bars * glow.clamp(0.0, 1.0), thickness: barThickness);

    return Semantics(
      label: 'Stranger Things',
      child: ExcludeSemantics(
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  letter(top[0], big, 0, top.length),
                  // The bar rides over the small letters, tying S to R.
                  IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        bar,
                        SizedBox(height: size * 0.12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 1; i < top.length - 1; i++)
                              letter(top[i], size, i, top.length),
                          ],
                        ),
                      ],
                    ),
                  ),
                  letter(top[top.length - 1], big, top.length - 1, top.length),
                ],
              ),
              SizedBox(height: size * 0.1),
              // THINGS hangs from a rule that runs out to both edges.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Padding(padding: EdgeInsets.only(right: size * 0.18), child: bar)),
                  for (var i = 0; i < bottom.length; i++)
                    letter(bottom[i], size, i, bottom.length),
                  Expanded(child: Padding(padding: EdgeInsets.only(left: size * 0.18), child: bar)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.color,
    required this.opacity,
    required this.thickness,
  });

  final Color color;
  final double opacity;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: thickness,
        decoration: BoxDecoration(
          color: Color.lerp(color, Colors.white, 0.15),
          borderRadius: BorderRadius.circular(thickness),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: thickness * 3),
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: thickness * 8),
          ],
        ),
      ),
    );
  }
}
