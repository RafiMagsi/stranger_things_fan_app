import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/text_styles.dart';
import '../core/widgets/glass_card.dart';
import '../data/moments.dart';
import '../models/moment.dart';

/// The twists, reveals, sacrifices and ironies of the series.
///
/// Every moment is split into a safe setup and a veiled reveal. The reveal
/// stays hidden behind a spoiler veil until the reader taps to uncover it,
/// so the screen is safe to hand to a first-time viewer.
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
    final scheme = Theme.of(context).colorScheme;
    final moments = _filter == null
        ? Moments.all
        : Moments.all.where((m) => m.kind == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MOMENTS',
          style: AppText.h2(scheme.onSurface).copyWith(letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          // Kind filter chips.
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'All',
                  color: scheme.onSurface,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: moments.length,
              itemBuilder: (context, i) {
                final m = moments[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MomentCard(
                    moment: m,
                    revealed: _revealed.contains(m.id),
                    onReveal: () => setState(() => _revealed.add(m.id)),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? color.withValues(alpha: 0.22) : Colors.transparent,
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12)]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: AppText.label(selected ? color : color.withValues(alpha: 0.7)),
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
    final scheme = Theme.of(context).colorScheme;
    final k = moment.kind;

    return GlassCard(
      glow: moment.accent,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kind + chapter badge row.
          Row(
            children: [
              GlowBadge(
                text: k.label,
                color: k.color,
                icon: _kindIcon(k),
              ),
              const Spacer(),
              GlowBadge(
                text: moment.chapterLabel,
                color: Colors.white70,
                icon: Icons.live_tv,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            moment.title,
            style: AppText.h2(scheme.onSurface).copyWith(fontSize: 19),
          ),
          const SizedBox(height: 8),
          Text(
            moment.setup,
            style: AppText.body(
              scheme.onSurface.withValues(alpha: 0.8),
              size: 13.5,
            ),
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
                Text(
                  'THE REVEAL',
                  style: AppText.label(moment.accent),
                ),
                const SizedBox(height: 6),
                Text(
                  moment.reveal,
                  style: AppText.dossier(
                    scheme.onSurface.withValues(alpha: 0.88),
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
                        color: k.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        moment.why,
                        style: AppText.body(
                          scheme.onSurface.withValues(alpha: 0.62),
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
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: revealed ? null : onReveal,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: revealed ? EdgeInsets.zero : const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: revealed
              ? accent.withValues(alpha: 0.07)
              : scheme.onSurface.withValues(alpha: 0.05),
          border: Border.all(
            color: revealed
                ? accent.withValues(alpha: 0.4)
                : scheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: revealed
            ? child
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
                  // Tappable overlay.
                  GestureDetector(
                    onTap: onReveal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.visibility_off,
                            size: 16, color: accent),
                        const SizedBox(width: 8),
                        Text(
                          'SPOILER — TAP TO REVEAL',
                          style: AppText.label(accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
