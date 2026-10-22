import 'package:flutter/material.dart';

import '../core/theme/text_styles.dart';
import '../core/widgets/glass_card.dart';
import '../data/timeline.dart';

/// The in-story timeline, 1959 -> 1987, as a glowing vertical rail.
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final events = STTimeline.events;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TIMELINE',
          style: AppText.h2(scheme.onSurface).copyWith(letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: events.length,
        itemBuilder: (context, i) {
          final e = events[i];
          final isLast = i == events.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rail: node dot + connecting line.
                SizedBox(
                  width: 34,
                  child: Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(top: 18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: e.accent,
                          boxShadow: [
                            BoxShadow(
                              color: e.accent.withValues(alpha: 0.6),
                              blurRadius: 12,
                            ),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GlassCard(
                      glow: e.accent,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GlowBadge(text: e.year, color: e.accent),
                              const SizedBox(width: 8),
                              GlowBadge(
                                text: 'Season ${e.season}',
                                color: Colors.white70,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            e.title,
                            style: AppText.h2(scheme.onSurface)
                                .copyWith(fontSize: 17),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.detail,
                            style: AppText.body(
                              scheme.onSurface.withValues(alpha: 0.72),
                              size: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
