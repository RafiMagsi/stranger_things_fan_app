import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/art.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
import '../data/seasons.dart';
import '../models/season.dart';
import 'season_detail_screen.dart';

/// All five seasons as big key-art cards. Each one tears open into its
/// watch guide.
class SeasonsScreen extends ConsumerWidget {
  const SeasonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = ref.watch(watchProgressProvider);

    return STScaffold(
      title: 'SEASONS',
      subtitle: '5 seasons · 42 chapters · 1983-1989',
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: Seasons.all.length,
        itemBuilder: (context, i) {
          final s = Seasons.all[i];
          final tag = 'season-list-${s.number}';
          final done = s.episodes
              .where((e) => watched.contains(s.keyFor(e)))
              .length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: FlickerIn(
              index: i,
              child: _SeasonCard(
                season: s,
                heroTag: tag,
                watched: done,
                onTap: () => RiftPageRoute.push(
                  context,
                  SeasonDetailScreen(season: s, heroTag: tag),
                  name: '/season/${s.number}',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.season,
    required this.heroTag,
    required this.watched,
    required this.onTap,
  });

  final Season season;
  final String heroTag;
  final int watched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = season;
    final accent = WorldPalette.of(context).tint(s.accent);
    return NeonCard(
      onTap: onTap,
      glow: s.accent,
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: SizedBox(
        height: 196,
        child: Stack(
          fit: StackFit.expand,
          children: [
            STHero(
              tag: heroTag,
              radius: 22,
              child: SeasonArt(season: s),
            ),
            // Dark end on the left, under the text.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Color(0x11000000),
                    Color(0x99000000),
                    Color(0xF0000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 6,
              child: Text(
                '${s.number}',
                style: AppText.neon(size: 96, color: accent),
              ),
            ),
            Positioned(
              left: 18,
              right: 90,
              top: 18,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEASON ${s.number}',
                    style: AppText.chapter(accent, size: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.tagline,
                    style: AppText.h2(Colors.white).copyWith(fontSize: 17),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      GlowBadge(text: s.setting, color: Colors.white70),
                      GlowBadge(
                        text: s.threat,
                        color: AppColors.hawkinsGold,
                        icon: Icons.warning_amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: watched / s.episodes.length,
                            minHeight: 3,
                            color: accent,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$watched/${s.episodes.length}',
                        style: AppText.label(
                          Colors.white70,
                        ).copyWith(fontSize: 10.5),
                      ),
                    ],
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
