import 'package:flutter/material.dart';

import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/glass_card.dart';
import '../data/seasons.dart';
import '../models/season.dart';

/// Timeline of all five seasons. Tapping a season expands its real chapter
/// list with a staggered reveal.
class SeasonsScreen extends StatefulWidget {
  const SeasonsScreen({super.key});

  @override
  State<SeasonsScreen> createState() => _SeasonsScreenState();
}

class _SeasonsScreenState extends State<SeasonsScreen> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SEASONS',
          style: AppText.h2(scheme.onSurface).copyWith(letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: Seasons.all.length,
        itemBuilder: (context, i) {
          final s = Seasons.all[i];
          final isExpanded = _expanded == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SeasonHeader(
                  season: s,
                  onTap: () => setState(
                    () => _expanded = isExpanded ? null : i,
                  ),
                ),
                // Episodes only exist in the tree when expanded, so they
                // don't leak into semantics or tests when collapsed.
                AnimatedSize(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: isExpanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _EpisodeList(season: s),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SeasonHeader extends StatelessWidget {
  const _SeasonHeader({
    required this.season,
    required this.onTap,
  });

  final Season season;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 156,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            // DARK end bottom-left anchors text.
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                season.accent,
                season.accent.withValues(alpha: 0.7),
                world.bg,
              ],
              stops: const [0, 0.55, 1],
            ),
            border: Border.all(
              color: world.accent.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SEASON ${season.number}',
                      style: AppText.label(Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      season.tagline,
                      style: AppText.body(Colors.white, size: 13.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GlowBadge(
                          text: '${season.year} · ${season.episodeLabel}',
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        GlowBadge(
                          text: season.threat,
                          color: Colors.amber,
                          icon: Icons.warning_amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Icon(Icons.expand_more, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodeList extends StatelessWidget {
  const _EpisodeList({required this.season});

  final Season season;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      glow: season.accent,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final e in season.episodes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chapter badge.
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: season.accent.withValues(alpha: 0.16),
                      border: Border.all(
                        color: season.accent.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '${e.number}',
                      style: AppText.label(season.accent).copyWith(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        e.title,
                        style: AppText.body(
                          scheme.onSurface.withValues(alpha: 0.85),
                          size: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
