import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/art.dart';
import '../core/state/app_state.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
import '../data/moments.dart';
import '../data/seasons.dart';
import '../models/moment.dart';

/// The twists, reveals, sacrifices and ironies of the series, in watch
/// order.
///
/// Every moment is split into a safe setup and a veiled reveal. The reveal
/// stays hidden behind a spoiler veil until the reader taps to uncover it -
/// it then tunes in like a VHS tape catching tracking - so the screen is
/// safe to hand to a first-time viewer. With the spoiler shield on, moments
/// from chapters you haven't watched are redacted entirely - even the setup.
class MomentsScreen extends ConsumerStatefulWidget {
  const MomentsScreen({super.key});

  @override
  ConsumerState<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends ConsumerState<MomentsScreen> {
  MomentKind? _filter;
  final Set<String> _revealed = {};
  final Set<String> _declassified = {};

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final shield = ref.watch(settingsProvider).spoilerShield;
    final watched = ref.watch(watchProgressProvider);
    final moments = _filter == null
        ? Moments.all
        : Moments.all.where((m) => m.kind == _filter).toList();

    return STScaffold(
      title: 'MOMENTS',
      subtitle: '${Moments.all.length} turning points · spoilers veiled',
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Kind filter chips.
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'All',
                  color: world.ink,
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                for (final k in MomentKind.values)
                  _FilterChip(
                    label: k.label,
                    color: world.tint(k.color),
                    selected: _filter == k,
                    onTap: () =>
                        setState(() => _filter = _filter == k ? null : k),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              itemCount: moments.length,
              itemBuilder: (context, i) {
                final m = moments[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FlickerIn(
                    index: i,
                    child: _MomentCard(
                      moment: m,
                      revealed: _revealed.contains(m.id),
                      onReveal: () => setState(() => _revealed.add(m.id)),
                      shielded:
                          shield &&
                          !_declassified.contains(m.id) &&
                          Seasons.isAhead(m.season, m.episode, watched),
                      onDeclassify: () =>
                          setState(() => _declassified.add(m.id)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.35),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label.toUpperCase(),
            style: AppText.label(
              selected ? color : color.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _MomentCard extends StatefulWidget {
  const _MomentCard({
    required this.moment,
    required this.revealed,
    required this.onReveal,
    required this.shielded,
    required this.onDeclassify,
  });

  final Moment moment;
  final bool revealed;
  final VoidCallback onReveal;

  /// From a chapter the viewer hasn't watched, with the shield on.
  final bool shielded;
  final VoidCallback onDeclassify;

  @override
  State<_MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<_MomentCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final k = widget.moment.kind;
    final accent = world.tint(widget.moment.accent);
    final kindColor = world.tint(k.color);

    final titleStyle = AppText.h2(world.ink).copyWith(fontSize: 19);
    final setupStyle = AppText.body(
      world.ink.withValues(alpha: 0.8),
      size: 13.5,
    );
    final header = SizedBox(
      height: 132,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            enabled: widget.shielded,
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: EventArt(
              photo: widget.moment.photo,
              accent: widget.moment.accent,
              icon: _kindIcon(k),
            ),
          ),
          // A cold, misty wash over art in the Upside Down — like seeing
          // something through storm haze — oriented by the accent.
          if (world.depth > 0.2)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        world.tint(widget.moment.accent).withValues(alpha: 0.10 * world.depth),
                        Colors.transparent,
                      ],
                      stops: const [0, 1],
                    ),
                  ),
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.25), world.card],
                stops: const [0.35, 1],
              ),
            ),
          ),
          // Kind + chapter badge row.
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              children: [
                GlowBadge(
                  text: k.label,
                  color: kindColor,
                  icon: _kindIcon(k),
                  onImage: true,
                ),
                const Spacer(),
                GlowBadge(
                  text: widget.moment.chapterLabel,
                  color: world.muted,
                  icon: Icons.live_tv,
                  onImage: true,
                ),
              ],
            ),
          ),
          // A faint dust/ash swirl over the ticket art — tied to the kind
          // so each moment drifts differently — only in the Upside Down.
          if (world.depth > 0.05)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ArtDrift(
                    seed: widget.moment.id.hashCode,
                    tint: accent,
                    depth: world.depth,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.shielded) {
      return NeonCard(
        glow: widget.moment.accent,
        padding: EdgeInsets.zero,
        onTap: widget.onDeclassify,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RedactedText(widget.moment.title, style: titleStyle, maxLines: 1),
                  const SizedBox(height: 8),
                  RedactedText(widget.moment.setup, style: setupStyle, maxLines: 3),
                  const SizedBox(height: 12),
                  ClassifiedBanner(unlock: widget.moment.chapterLabel),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hovering = true),
        onTapUp: (_) => setState(() => _hovering = false),
        onTapCancel: () => setState(() => _hovering = false),
        onTap: widget.onReveal,
        child: AnimatedScale(
          scale: _hovering ? 1.012 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: NeonCard(
            glow: widget.moment.accent,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.moment.title, style: titleStyle),
                      const SizedBox(height: 8),
                      Text(widget.moment.setup, style: setupStyle),
                      const SizedBox(height: 14),
                      // Reveal block, veiled until tapped.
                      _SpoilerVeil(
                        revealed: widget.revealed,
                        accent: accent,
                        onReveal: widget.onReveal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('THE REVEAL', style: AppText.label(accent)),
                            const SizedBox(height: 6),
                            TypewriterText(
                              widget.moment.reveal,
                              charMs: 12,
                              delay: const Duration(milliseconds: 450),
                              style: AppText.dossier(
                                world.ink.withValues(alpha: 0.9),
                                size: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // The "why it lands" note.
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: kindColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    widget.moment.why,
                                    style: AppText.body(
                                      world.ink.withValues(alpha: 0.62),
                                      size: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _kindIcon(MomentKind k) {
    switch (k) {
      case MomentKind.twist:
        return Icons.shuffle;
      case MomentKind.reveal:
        return Icons.visibility;
      case MomentKind.irony:
        return Icons.theater_comedy;
      case MomentKind.sacrifice:
        return Icons.volunteer_activism;
      case MomentKind.betrayal:
        return Icons.back_hand;
    }
  }
}

/// Subtle drifting dusk/ash over a header image — Upside Down spores
/// or warm dust, depending on depth. Static per [seed], fades with [depth].
class _ArtDrift extends CustomPainter {
  const _ArtDrift({required this.seed, required this.tint, required this.depth});

  final int seed;
  final Color tint;
  final double depth;

  @override
  void paint(Canvas canvas, Size size) {
    if (depth <= 0.02 || size.isEmpty) return;
    final rng = math.Random(seed);
    final count = 14 + (seed % 8);
    final paint = Paint()
      ..color = tint.withValues(alpha: 0.05 * depth);
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 1.2 + rng.nextDouble() * 2.2;
      final dy = (rng.nextDouble() - 0.5) * size.height * 0.2;
      canvas.drawCircle(Offset(x, y + dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArtDrift old) =>
      old.depth != depth || old.seed != seed || old.tint != tint;
}

/// Blurs its [child] behind a tappable "spoiler" veil until revealed.
class _SpoilerVeil extends StatefulWidget {
  const _SpoilerVeil({
    required this.revealed,
    required this.accent,
    required this.onReveal,
    required this.child,
  });

  final bool revealed;
  final Color accent;
  final VoidCallback onReveal;
  final Widget child;

  @override
  State<_SpoilerVeil> createState() => _SpoilerVeilState();
}

class _SpoilerVeilState extends State<_SpoilerVeil> {
  double _twitch = 0;

  @override
  void initState() {
    super.initState();
    // Pretend the tape is struggling to stay tuned: a faint flicker while
    // hidden, settling as it's revealed.
    if (!widget.revealed) {
      Future<void>.delayed(const Duration(milliseconds: 40), () {
        if (mounted) setState(() => _twitch = 0.6);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);

    return GestureDetector(
      onTap: widget.revealed ? null : widget.onReveal,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.revealed
              ? widget.accent.withValues(alpha: 0.07)
              : world.ink.withValues(alpha: 0.05),
          border: Border.all(
            color: widget.revealed
                ? widget.accent.withValues(alpha: 0.4)
                : world.ink.withValues(alpha: 0.12),
          ),
        ),
        child: widget.revealed
            ? _VhsTuneIn(child: widget.child)
            : Stack(
                alignment: Alignment.center,
                children: [
                  // The real content, blurred out so it can't be read.
                  ExcludeSemantics(
                    child: Opacity(
                      opacity: 0.4,
                      child: ClipRect(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                  // A tap target, but wrapped so a tap also flickers the
                  // veil — like the signal is struggling.
                  IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _twitch,
                      duration: const Duration(milliseconds: 80),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility_off, size: 16, color: widget.accent),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'SPOILER — TAP TO REVEAL',
                          style: AppText.label(
                            widget.accent,
                          ).copyWith(fontSize: 11, letterSpacing: 1.1),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// A reveal that tunes in like a VHS tape finding its tracking: the text
/// splits into red and cyan ghosts that jitter sideways, then snap back
/// into one clean image.
class _VhsTuneIn extends StatefulWidget {
  const _VhsTuneIn({required this.child});

  final Widget child;

  @override
  State<_VhsTuneIn> createState() => _VhsTuneInState();
}

class _VhsTuneInState extends State<_VhsTuneIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  )..forward();

  // Keeps the clean copy's state (e.g. a typewriter mid-sentence) when the
  // ghosts are dropped and it moves out of the Stack.
  final _clean = GlobalKey();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        // Once tuned in, drop the ghosts so a revealed card costs no more
        // than a plain one. The content is stateless text, so swapping the
        // tree shape here loses nothing.
        if (_c.isCompleted || MediaQuery.disableAnimationsOf(context)) {
          return KeyedSubtree(key: _clean, child: child!);
        }
        final t = _c.value;
        final amp = (1 - Curves.easeOut.transform(t)) * 7;
        final jitter = math.sin(t * 70) * amp * 0.6;
        return Stack(
          children: [
            Opacity(
              opacity: (0.55 * (1 - t)).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(-amp + jitter, 0),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFFF2D3C),
                    BlendMode.srcATop,
                  ),
                  child: ExcludeSemantics(child: child),
                ),
              ),
            ),
            Opacity(
              opacity: (0.55 * (1 - t)).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(amp - jitter, 0),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF29E6FF),
                    BlendMode.srcATop,
                  ),
                  child: ExcludeSemantics(child: child),
                ),
              ),
            ),
            Opacity(
              opacity: Curves.easeIn.transform(t.clamp(0.0, 1.0)),
              child: Transform.translate(
                offset: Offset(jitter * 0.3, 0),
                child: KeyedSubtree(key: _clean, child: child!),
              ),
            ),
            // Tape hiss over the whole block while it tunes in — gone
            // once the signal is clean.
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _VhsScanline(t: t, intensity: (1 - t).clamp(0.0, 1.0)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VhsScanline extends CustomPainter {
  const _VhsScanline({required this.t, required this.intensity});

  final double t;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0 || size.isEmpty) return;
    final rng = math.Random((t * 1000).floor());
    final scan = Paint()
      ..color = Color.lerp(const Color(0xFFFF2D3C), const Color(0xFF29E6FF), 0.5)!
          .withValues(alpha: 0.25 * intensity);
    for (var i = 0; i < 3; i++) {
      final y = rng.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1.2 + rng.nextDouble() * 1.6),
        scan,
      );
    }
    // Horizontal speckle noise, like tape hiss rendered on screen.
    final noise = Paint()
      ..color = Colors.white.withValues(alpha: 0.18 * intensity);
    for (var i = 0; i < 6; i++) {
      final y = rng.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(0, y, rng.nextDouble() * size.width, 1),
        noise,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VhsScanline old) =>
      old.t != t || old.intensity != intensity;
}
