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
import '../data/seasons.dart';
import '../data/timeline.dart';

/// The whole story in the order it happened, 1959 -> 1989, as a strand of
/// lit bulbs. Each era gets its own chapter break, every beat carries a
/// photo of the thing it's about and says which episode reveals it. With
/// the spoiler shield on, beats you haven't reached yet are redacted.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = STTimeline.events;
    final shield = ref.watch(settingsProvider).spoilerShield;
    final watched = ref.watch(watchProgressProvider);

    return STScaffold(
      title: 'TIMELINE',
      subtitle: shield
          ? 'Spoiler shield on · ${events.length} beats'
          : '${events.length} beats · 1959 to 1989, in story order',
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
                child: _Beat(
                  event: e,
                  isLast: i == events.length - 1,
                  shielded:
                      shield && Seasons.isAhead(e.season, e.episode, watched),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Beat extends StatefulWidget {
  const _Beat({
    required this.event,
    required this.isLast,
    required this.shielded,
  });

  final TimelineEvent event;
  final bool isLast;

  /// Ahead of the viewer's progress, with the spoiler shield on.
  final bool shielded;

  @override
  State<_Beat> createState() => _BeatState();
}

class _BeatState extends State<_Beat> {
  bool _declassified = false;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final e = widget.event;
    final accent = world.tint(e.accent);
    final hidden = widget.shielded && !_declassified;
    final titleStyle = AppText.h2(world.ink).copyWith(fontSize: 17);
    final detailStyle = AppText.body(
      world.ink.withValues(alpha: 0.72),
      size: 13,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rail: a lit bulb on the wire (dark while classified).
          SizedBox(
            width: 30,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 12,
                  height: 16,
                  decoration: BoxDecoration(
                    color: hidden ? accent.withValues(alpha: 0.25) : accent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: hidden
                        ? null
                        : [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.9),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: accent.withValues(alpha: 0.4),
                              blurRadius: 26,
                              spreadRadius: 4,
                            ),
                          ],
                  ),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accent.withValues(alpha: 0.6),
                            accent.withValues(alpha: 0.08),
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
                padding: EdgeInsets.zero,
                onTap: hidden
                    ? () => setState(() => _declassified = true)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The photo strip, with the year burning over it.
                    SizedBox(
                      height: 112,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageFiltered(
                            enabled: hidden,
                            imageFilter: ImageFilter.blur(
                              sigmaX: 12,
                              sigmaY: 12,
                            ),
                            child: EventArt(photo: e.photo, accent: e.accent),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.1),
                                  world.card,
                                ],
                                stops: const [0.3, 1],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            bottom: 8,
                            child: Text(
                              e.year,
                              style: AppText.neon(
                                size: 19,
                                color: accent,
                                glow: 0.85,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GlowBadge(
                              text: e.revealedIn,
                              color: world.muted,
                              icon: Icons.live_tv,
                              onImage: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                      child: hidden
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RedactedText(
                                  e.title,
                                  style: titleStyle,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                RedactedText(
                                  e.detail,
                                  style: detailStyle,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 10),
                                ClassifiedBanner(unlock: e.revealedIn),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: titleStyle),
                                const SizedBox(height: 6),
                                Text(e.detail, style: detailStyle),
                              ],
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
  }
}
