import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/moments.dart';
import '../models/moment.dart';

/// The twists, reveals, sacrifices and ironies of the series, in watch
/// order.
///
/// Every moment is split into a safe setup and a veiled reveal. The reveal
/// stays hidden behind a spoiler veil until the reader taps to uncover it -
/// it then tunes in like a VHS tape catching tracking - so the screen is
/// safe to hand to a first-time viewer.
class MomentsScreen extends StatefulWidget {
  const MomentsScreen({super.key});

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> {
  MomentKind? _filter;
  final Set<String> _revealed = {};

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
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
                    color: k.color,
                    selected: _filter == k,
                    onTap: () => setState(
                      () => _filter = _filter == k ? null : k,
                    ),
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
                ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 12)]
                : null,
          ),
          child: Text(
            label.toUpperCase(),
            style: AppText.label(selected ? color : color.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({
    required this.moment,
    required this.revealed,
    required this.onReveal,
  });

  final Moment moment;
  final bool revealed;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final k = moment.kind;

    return NeonCard(
      glow: moment.accent,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kind + chapter badge row.
          Row(
            children: [
              GlowBadge(text: k.label, color: k.color, icon: _kindIcon(k)),
              const Spacer(),
              GlowBadge(text: moment.chapterLabel, color: world.muted, icon: Icons.live_tv),
            ],
          ),
          const SizedBox(height: 12),
          Text(moment.title, style: AppText.h2(world.ink).copyWith(fontSize: 19)),
          const SizedBox(height: 8),
          Text(
            moment.setup,
            style: AppText.body(world.ink.withValues(alpha: 0.8), size: 13.5),
          ),
          const SizedBox(height: 14),
          // Reveal block, veiled until tapped.
          _SpoilerVeil(
            revealed: revealed,
            accent: moment.accent,
            onReveal: onReveal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('THE REVEAL', style: AppText.label(moment.accent)),
                const SizedBox(height: 6),
                Text(
                  moment.reveal,
                  style: AppText.dossier(world.ink.withValues(alpha: 0.9), size: 14),
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
                        color: k.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        moment.why,
                        style: AppText.body(world.ink.withValues(alpha: 0.62), size: 12.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

/// Blurs its [child] behind a tappable "spoiler" veil until revealed.
class _SpoilerVeil extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);

    return GestureDetector(
      onTap: revealed ? null : onReveal,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: revealed ? EdgeInsets.zero : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: revealed
              ? accent.withValues(alpha: 0.07)
              : world.ink.withValues(alpha: 0.05),
          border: Border.all(
            color: revealed
                ? accent.withValues(alpha: 0.4)
                : world.ink.withValues(alpha: 0.12),
          ),
        ),
        child: revealed
            ? _VhsTuneIn(child: child)
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
                          child: child,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility_off, size: 16, color: accent),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'SPOILER — TAP TO REVEAL',
                          style: AppText.label(accent).copyWith(fontSize: 11, letterSpacing: 1.1),
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
        if (_c.isCompleted) return child!;
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
                  colorFilter: const ColorFilter.mode(Color(0xFFFF2D3C), BlendMode.srcATop),
                  child: ExcludeSemantics(child: child),
                ),
              ),
            ),
            Opacity(
              opacity: (0.55 * (1 - t)).clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(amp - jitter, 0),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Color(0xFF29E6FF), BlendMode.srcATop),
                  child: ExcludeSemantics(child: child),
                ),
              ),
            ),
            Opacity(
              opacity: Curves.easeIn.transform(t.clamp(0.0, 1.0)),
              child: Transform.translate(offset: Offset(jitter * 0.3, 0), child: child),
            ),
          ],
        );
      },
    );
  }
}
