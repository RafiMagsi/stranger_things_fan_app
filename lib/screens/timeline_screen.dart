import 'package:flutter/material.dart';

import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/timeline.dart';

/// The whole story in the order it happened, 1959 -> 1989, as a strand of
/// lit bulbs. Each era gets its own chapter break, and every beat says
/// which episode reveals it.
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = STTimeline.events;

    return STScaffold(
      title: 'TIMELINE',
      subtitle: '${events.length} beats · 1959 to 1989, in story order',
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 20, 40),
        itemCount: events.length,
        itemBuilder: (context, i) {
          final e = events[i];
          final era = STTimeline.eraOf(e);
          final newEra = i == 0 || STTimeline.eraOf(events[i - 1]) != era;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (newEra)
                SectionHeader(
                  title: era,
                  padding: const EdgeInsets.fromLTRB(4, 22, 0, 12),
                ),
              FlickerIn(
                index: i,
                child: _Beat(event: e, isLast: i == events.length - 1),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Beat extends StatelessWidget {
  const _Beat({required this.event, required this.isLast});

  final TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final e = event;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rail: a lit bulb on the wire.
          SizedBox(
            width: 30,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 12,
                  height: 16,
                  decoration: BoxDecoration(
                    color: e.accent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: e.accent.withValues(alpha: 0.9), blurRadius: 12, spreadRadius: 1),
                      BoxShadow(color: e.accent.withValues(alpha: 0.4), blurRadius: 26, spreadRadius: 4),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            e.accent.withValues(alpha: 0.6),
                            e.accent.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeonCard(
                glow: e.accent,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.year,
                            style: AppText.neon(size: 17, color: e.accent, glow: 0.8),
                          ),
                        ),
                        GlowBadge(text: e.revealedIn, color: world.muted, icon: Icons.live_tv),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(e.title, style: AppText.h2(world.ink).copyWith(fontSize: 17)),
                    const SizedBox(height: 6),
                    Text(
                      e.detail,
                      style: AppText.body(world.ink.withValues(alpha: 0.72), size: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
