import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../theme/world_palette.dart';
import 'world_fx.dart';

/// The app's card: a near-black panel lit by a neon tube along its top
/// edge, echoing the bars that frame the show's logotype. The accent tints
/// the tube, border and halo; pressing sinks the card and flares the neon.
///
/// Every card follows the world: in the Upside Down its accent decays into
/// storm blue or lightning red, the tube dims like dying glass, cold fog
/// gathers on the panel, and vines creep across it - all scaled by
/// [WorldPalette.depth], so they grow in while the world flips.
class NeonCard extends StatefulWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.glow,
    this.onTap,
    this.onLongPress,
    this.tube = true,
    this.vineSeed,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glow;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Whether to draw the neon tube along the top edge.
  final bool tube;

  /// Shapes this card's Upside Down vines; defaults to one derived from the
  /// accent so a given card always grows the same way.
  final int? vineSeed;

  @override
  State<NeonCard> createState() => _NeonCardState();
}

class _NeonCardState extends State<NeonCard> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final accent = world.tint(widget.glow ?? world.accent);
    final radius = BorderRadius.circular(widget.borderRadius);
    final depth = world.depth;
    final fullBleed = widget.padding == EdgeInsets.zero;
    // Seed from the raw colour: the tinted one changes every frame while
    // the world flips, which would reshuffle the vines as they grow.
    final vineSeed = widget.vineSeed ?? (widget.glow?.toARGB32() ?? 0) ^ 0x5A17;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(world.card, accent, 0.08)!,
            world.card,
            Color.lerp(world.card, Colors.black, 0.4)!,
          ],
          stops: const [0, 0.45, 1],
        ),
        border: Border.all(
          color: accent.withValues(
            alpha: _pressed ? 0.65 : 0.26 - 0.06 * depth,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: _pressed ? 0.34 : 0.12),
            blurRadius: _pressed ? 30 : 22,
            spreadRadius: _pressed ? 1 : 0,
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius - 1),
        child: Stack(
          children: [
            // On text cards vines grow on the panel itself, beneath the
            // content, so they never cover words.
            if (!fullBleed) Positioned.fill(child: CardVines(seed: vineSeed)),
            Padding(padding: widget.padding, child: widget.child),
            // Cold fog pooling at the bottom of the panel.
            if (depth > 0.01)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.udFogHi.withValues(alpha: 0.35 * depth),
                          AppColors.udFogHi.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.55],
                      ),
                    ),
                  ),
                ),
              ),
            if (fullBleed)
              Positioned.fill(child: CardVines(seed: vineSeed, overArt: true)),
            if (widget.tube)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: NeonTube(
                  color: accent,
                  // Upside Down glass is dying.
                  intensity: _pressed ? 1.0 : 0.7 - 0.25 * depth,
                ),
              ),
          ],
        ),
      ),
    );

    if (!_interactive) return card;
    return Semantics(
      button: widget.onTap != null,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _setPressed(false);
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              },
        child: AnimatedScale(
          scale: _pressed ? 0.975 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: card,
        ),
      ),
    );
  }
}

/// A horizontal neon tube: hot core, colored glass, and a halo that fades
/// out toward both ends. Used on card tops, under app bars, in headers.
class NeonTube extends StatelessWidget {
  const NeonTube({
    super.key,
    required this.color,
    this.intensity = 1.0,
    this.thickness = 2,
  });

  final Color color;
  final double intensity;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: thickness + 10,
        child: CustomPaint(
          painter: _TubePainter(
            color: color,
            intensity: intensity,
            thickness: thickness,
          ),
        ),
      ),
    );
  }
}

class _TubePainter extends CustomPainter {
  const _TubePainter({
    required this.color,
    required this.intensity,
    required this.thickness,
  });

  final Color color;
  final double intensity;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final tube = Rect.fromLTWH(0, 0, size.width, thickness);
    final shader = LinearGradient(
      colors: [
        color.withValues(alpha: 0),
        color.withValues(alpha: 0.9 * intensity),
        Color.lerp(color, Colors.white, 0.45)!.withValues(alpha: intensity),
        color.withValues(alpha: 0.9 * intensity),
        color.withValues(alpha: 0),
      ],
      stops: const [0, 0.18, 0.5, 0.82, 1],
    ).createShader(tube);

    // Halo first, then the glass on top.
    canvas.drawRect(
      tube.inflate(1.5),
      Paint()
        ..shader = shader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + 4 * intensity),
    );
    canvas.drawRect(tube, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _TubePainter old) =>
      old.color != color ||
      old.intensity != intensity ||
      old.thickness != thickness;
}

/// A small uppercase label chip with an optional icon — the app's "tag".
class GlowBadge extends StatelessWidget {
  const GlowBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.onImage = false,
  });

  final String text;
  final Color color;
  final IconData? icon;

  /// Sits over a photo or key art: add a dark backdrop so it stays legible.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final color = WorldPalette.of(context).tint(this.color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: onImage
            ? Color.alphaBlend(
                color.withValues(alpha: 0.16),
                const Color(0xB3000000),
              )
            : color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: AppText.label(
                color,
              ).copyWith(fontSize: 10.5, letterSpacing: 1.3),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header: a short neon tube, the title in red Benguiat caps, and a
/// rule that burns out to the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 28, 20, 12),
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: NeonTube(color: world.accent, thickness: 2.5),
          ),
          const SizedBox(width: 10),
          // The title takes what it needs; the rule only gets the rest.
          Flexible(
            flex: 6,
            child: Text(
              title.toUpperCase(),
              // A condensed poster label, lit by the world's neon.
              style: AppText.headline(world.ink, size: 15, letterSpacing: 0.16)
                  .copyWith(
                    shadows: [
                      Shadow(
                        color: world.accent.withValues(alpha: 0.55),
                        blurRadius: 10,
                      ),
                    ],
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    world.accent.withValues(alpha: 0.45),
                    world.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Card entrance: the panel stutters on like a Hawkins streetlight when
/// something is near, then settles as it drifts up into place. Staggered by
/// [index].
///
/// It only plays while the route is still arriving, so cards that scroll
/// into view later simply appear instead of re-flickering on every scroll.
class FlickerIn extends StatefulWidget {
  const FlickerIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  State<FlickerIn> createState() => _FlickerInState();
}

class _FlickerInState extends State<FlickerIn>
    with SingleTickerProviderStateMixin {
  static const _step = Duration(milliseconds: 60);
  static const _run = Duration(milliseconds: 620);

  AnimationController? _controller;
  double _start = 0;
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) return;
    _checked = true;
    final route = ModalRoute.of(context)?.animation;
    if (route == null || route.status == AnimationStatus.completed) return;
    // Flicker is exactly what reduced effects is for.
    if (MediaQuery.disableAnimationsOf(context)) return;

    final delay = _step * widget.index.clamp(0, 8);
    final total = delay + _run;
    _start = delay.inMicroseconds / total.inMicroseconds;
    _controller = AnimationController(vsync: this, duration: total)..forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// A failing-bulb curve: on, off, on, dip, then a steady warm-up.
  static double _flicker(double t) {
    if (t <= 0) return 0;
    if (t < 0.12) return 0.85 * t / 0.12;
    if (t < 0.2) return 0.1;
    if (t < 0.3) return 0.9;
    if (t < 0.36) return 0.3;
    return 0.3 + 0.7 * Curves.easeOut.transform((t - 0.36) / 0.64);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = ((controller.value - _start) / (1 - _start)).clamp(0.0, 1.0);
        return Opacity(
          opacity: _flicker(t),
          child: Transform.translate(
            offset: Offset(0, (1 - Curves.easeOutCubic.transform(t)) * 18),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
