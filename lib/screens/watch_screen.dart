import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/app_video.dart';
import '../core/media/art.dart';
import '../core/media/decode_size.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
import '../data/fan_media.dart';
import '../data/seasons.dart';
import 'gallery_screen.dart';
import 'reel_screen.dart';
import 'story_screen.dart';
import 'trailer_player_screen.dart';
import 'transmissions_screen.dart';

/// The screening room: the series itself in Story mode, the Reel of fan
/// edits shelf by shelf, the official trailers, and the gallery wall.
class WatchScreen extends ConsumerWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = ref.watch(watchProgressProvider);
    final next = Seasons.nextUp(watched);
    final featured = FanMedia.clip('finale')!;
    void open(Widget page, String name) =>
        RiftPageRoute.push(context, page, name: name);

    return STScaffold(
      title: 'WATCH',
      subtitle: 'The screening room · lights down',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // The series, from wherever you are.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: FlickerIn(
              child: _StorySoFar(
                watched: watched.length,
                label: switch (next) {
                  null => 'WATCH AGAIN',
                  _ when watched.isEmpty => 'START WATCHING',
                  (final s, final e) => 'RESUME S${s.number} · E${e.number}',
                },
                chapter: next == null
                    ? 'Every chapter watched'
                    : 'S${next.$1.number} · ${next.$2.chapterLabel}',
                title: next?.$2.title ?? 'Friends don\'t lie',
                seasonArt: next == null ? null : SeasonArt(season: next.$1),
                onPlay: () => open(
                  StoryScreen(
                    season: next?.$1.number,
                    episode: next?.$2.number,
                  ),
                  '/story',
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Featured Edit'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ReelCard(
                key: const ValueKey('watch-featured'),
                clip: featured,
                large: true,
                onTap: () => playReel(
                  context,
                  FanMedia.reel,
                  FanMedia.reel.indexOf(featured),
                ),
              ),
            ),
          ),

          for (final shelf in ReelShelf.values) ...[
            SectionHeader(
              title: shelf.title,
              trailing: _SeeAll(
                onTap: () => open(ReelScreen(shelf: shelf), '/reel'),
              ),
            ),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: FanMedia.onShelf(shelf).length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final clips = FanMedia.onShelf(shelf);
                  return SizedBox(
                    width: 156,
                    child: ReelCard(
                      clip: clips[i],
                      onTap: () => playReel(context, clips, i),
                    ),
                  );
                },
              ),
            ),
          ],

          SectionHeader(
            title: 'Official Trailers',
            trailing: _SeeAll(
              onTap: () => open(const TransmissionsScreen(), '/transmissions'),
            ),
          ),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: Seasons.all.fold<int>(
                0,
                (n, s) => n + s.trailers.length,
              ),
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final t = [
                  for (final s in Seasons.all.reversed) ...s.trailers,
                ][i];
                return SizedBox(
                  width: 220,
                  child: TrailerCard(
                    trailer: t,
                    onTap: () =>
                        open(TrailerPlayerScreen(trailer: t), '/trailer'),
                  ),
                );
              },
            ),
          ),

          SectionHeader(
            title: 'Fan Art',
            trailing: _SeeAll(
              onTap: () => open(const GalleryScreen(), '/gallery'),
            ),
          ),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: FanMedia.art.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final a = FanMedia.art[i];
                final dpr = MediaQuery.devicePixelRatioOf(context);
                return SizedBox(
                  width: a.aspect > 1 ? 300 : 108,
                  child: NeonCard(
                    onTap: () => open(const GalleryScreen(), '/gallery'),
                    padding: EdgeInsets.zero,
                    child: WorldGrade(
                      strength: 0.7,
                      child: LayoutBuilder(
                        builder: (context, box) => Image(
                          image: sizedAsset(a.asset, box.biggest, dpr),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
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

class _SeeAll extends StatelessWidget {
  const _SeeAll({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        'SEE ALL',
        style: AppText.label(
          WorldPalette.of(context).muted,
        ).copyWith(fontSize: 11),
      ),
    );
  }
}

/// Story mode's front door: the next chapter over a night ride through
/// Hawkins, with how far into the series you are.
class _StorySoFar extends StatelessWidget {
  const _StorySoFar({
    required this.watched,
    required this.label,
    required this.chapter,
    required this.title,
    required this.seasonArt,
    required this.onPlay,
  });

  final int watched;
  final String label;
  final String chapter;
  final String title;
  final Widget? seasonArt;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return NeonCard(
      onTap: onPlay,
      padding: EdgeInsets.zero,
      borderRadius: 22,
      glow: AppColors.stRed,
      child: SizedBox(
        height: 230,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipLoop(
              videoKey: 'bikes_night',
              placeholder: seasonArt ?? const SizedBox.shrink(),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x66000000),
                    Color(0xF2000000),
                  ],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE STORY SO FAR',
                    style: AppText.chapter(world.accent, size: 11),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chapter,
                    style: AppText.dossier(Colors.white70, size: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.headline(
                      Colors.white,
                      size: 26,
                      weight: 700,
                      letterSpacing: 0.04,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton.icon(
                        key: const ValueKey('watch-story'),
                        onPressed: onPlay,
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: Text(label),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.stRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: watched / Seasons.totalEpisodes,
                                minHeight: 3,
                                color: world.accent,
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$watched / ${Seasons.totalEpisodes} chapters',
                              style: AppText.label(
                                Colors.white70,
                              ).copyWith(fontSize: 10),
                            ),
                          ],
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
    );
  }
}
