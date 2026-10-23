import 'package:flutter/material.dart';

import '../core/media/app_video.dart';
import '../core/media/art.dart';
import '../core/media/poster_image.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/characters.dart' as cast_data;
import 'bestiary_screen.dart';
import 'cast_screen.dart';
import 'gallery_screen.dart';
import 'gate_screen.dart';
import 'locations_screen.dart';
import 'moments_screen.dart';
import 'quiz_screen.dart';
import 'quotes_screen.dart';
import 'reel_screen.dart';
import 'seasons_screen.dart';
import 'soundboard_screen.dart';
import 'timeline_screen.dart';
import 'transmissions_screen.dart';

/// The shelves of the archive.
enum FileShelf {
  all('ALL'),
  watch('WATCH'),
  people('PEOPLE'),
  world('THE WORLD'),
  play('PLAY');

  const FileShelf(this.label);
  final String label;
}

typedef _File = ({
  String title,
  String subtitle,
  IconData icon,
  String route,
  FileShelf shelf,
  Widget Function() page,
  // What the tile shows: a credited photo (`events/...`), a fan still
  // (`fan/...`), a looping clip, or - with none - the cast mosaic.
  String? photo,
  String? still,
  String? clip,
});

final List<_File> _files = [
  (
    title: 'Seasons',
    subtitle: 'Watch guide · 42 chapters',
    icon: Icons.live_tv,
    route: '/seasons',
    shelf: FileShelf.watch,
    page: () => const SeasonsScreen(),
    photo: 'events/tv',
    still: null,
    clip: null,
  ),
  (
    title: 'The Reel',
    subtitle: 'Fan edits, turned the right way up',
    icon: Icons.movie,
    route: '/reel',
    shelf: FileShelf.watch,
    page: () => const ReelScreen(),
    photo: null,
    still: 'reel/aesthetic_3',
    clip: 'bikes_night',
  ),
  (
    title: 'Transmissions',
    subtitle: 'Official trailers & radio',
    icon: Icons.play_circle,
    route: '/transmissions',
    shelf: FileShelf.watch,
    page: () => const TransmissionsScreen(),
    photo: 'events/walkie',
    still: null,
    clip: null,
  ),
  (
    title: 'Moments',
    subtitle: 'Twists, reveals & ironies',
    icon: Icons.local_fire_department,
    route: '/moments',
    shelf: FileShelf.watch,
    page: () => const MomentsScreen(),
    photo: 'events/polaroid',
    still: null,
    clip: null,
  ),
  (
    title: 'The Cast',
    subtitle: 'Every dossier',
    icon: Icons.badge,
    route: '/cast',
    shelf: FileShelf.people,
    page: () => const CastScreen(),
    photo: null,
    still: null,
    clip: null,
  ),
  (
    title: 'Fan Art',
    subtitle: 'The gallery wall',
    icon: Icons.palette,
    route: '/gallery',
    shelf: FileShelf.people,
    page: () => const GalleryScreen(),
    photo: null,
    still: 'fan/eleven_011',
    clip: null,
  ),
  (
    title: 'Quotes',
    subtitle: 'Lines every fan knows',
    icon: Icons.format_quote,
    route: '/quotes',
    shelf: FileShelf.people,
    page: () => const QuotesScreen(),
    photo: 'events/typewriter',
    still: null,
    clip: null,
  ),
  (
    title: 'The Gate',
    subtitle: 'Tear it open · cross worlds',
    icon: Icons.blur_circular,
    route: '/gate',
    shelf: FileShelf.world,
    page: () => const GateScreen(),
    photo: null,
    still: 'gate_eleven',
    clip: 'gate_crossing',
  ),
  (
    title: 'Timeline',
    subtitle: '1959 to 1989, in order',
    icon: Icons.timeline,
    route: '/timeline',
    shelf: FileShelf.world,
    page: () => const TimelineScreen(),
    photo: 'events/lights',
    still: null,
    clip: null,
  ),
  (
    title: 'Hawkins Map',
    subtitle: 'Places & filming locations',
    icon: Icons.map,
    route: '/locations',
    shelf: FileShelf.world,
    page: () => const LocationsScreen(),
    photo: 'filming/downtown_hawkins',
    still: null,
    clip: null,
  ),
  (
    title: 'Bestiary',
    subtitle: 'Creatures of the Upside Down',
    icon: Icons.filter_vintage, // the Demogorgon's petal head
    route: '/bestiary',
    shelf: FileShelf.world,
    page: () => const BestiaryScreen(),
    photo: 'events/flytrap',
    still: null,
    clip: null,
  ),
  (
    title: 'Trivia',
    subtitle: 'Prove you\'re Hawkins-ready',
    icon: Icons.lightbulb,
    route: '/quiz',
    shelf: FileShelf.play,
    page: () => const QuizScreen(),
    photo: 'events/dice',
    still: null,
    clip: null,
  ),
  (
    title: 'Soundboard',
    subtitle: 'Synth cues, clocks & captures',
    icon: Icons.graphic_eq,
    route: '/soundboard',
    shelf: FileShelf.play,
    page: () => const SoundboardScreen(),
    photo: 'events/synth',
    still: null,
    clip: null,
  ),
];

/// The archive: every section of the app, filed like Hawkins Lab cases and
/// sorted onto shelves.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  FileShelf _shelf = FileShelf.all;

  @override
  Widget build(BuildContext context) {
    final files = [
      for (final (i, f) in _files.indexed)
        if (_shelf == FileShelf.all || f.shelf == _shelf) (i, f),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return STScaffold(
      title: 'EXPLORE',
      subtitle: 'The Hawkins Lab archive · ${_files.length} files',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ShelfTabs<FileShelf>(
              values: FileShelf.values,
              selected: _shelf,
              label: (s) => s.label,
              onSelect: (s) => setState(() => _shelf = s),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverGrid.count(
              crossAxisCount: wide ? 3 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.96,
              children: [
                for (final (k, (i, f)) in files.indexed)
                  FlickerIn(
                    key: ValueKey(f.route),
                    index: k,
                    child: FileTile(
                      file: i + 1,
                      title: f.title,
                      subtitle: f.subtitle,
                      icon: f.icon,
                      photo: f.photo,
                      still: f.still,
                      clip: f.clip,
                      // The grid glows in Joyce's Christmas-bulb colours.
                      color: AppColors.bulbs[i % AppColors.bulbs.length],
                      onTap: () =>
                          RiftPageRoute.push(context, f.page(), name: f.route),
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

/// A row of filter tabs with the world's neon under the chosen one.
class ShelfTabs<T> extends StatelessWidget {
  const ShelfTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelect,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    // A handful of tabs: one row, built whole, scrolling only if it must.
    return SizedBox(
      height: 46,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            for (final v in values)
              GestureDetector(
                key: ValueKey('shelf-${label(v)}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(v),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label(v),
                        style: AppText.headline(
                          v == selected ? world.ink : world.muted,
                          size: 13,
                          weight: v == selected ? 600 : 500,
                          letterSpacing: 0.12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 2,
                        width: v == selected ? 28 : 0,
                        decoration: BoxDecoration(
                          color: world.accent,
                          boxShadow: [
                            BoxShadow(color: world.accent, blurRadius: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grid tile into a section, filed like a lab case: a real photo, fan still
/// or looping clip of what the section is about, graded into the world,
/// under a scrim that keeps the words legible.
class FileTile extends StatelessWidget {
  const FileTile({
    super.key,
    required this.file,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.photo,
    this.still,
    this.clip,
  });

  final int file;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? photo;
  final String? still;
  final String? clip;

  static const _castCover = [
    cast_data.Cast.eleven,
    cast_data.Cast.mike,
    cast_data.Cast.dustin,
    cast_data.Cast.lucas,
  ];

  Widget _art() {
    final mosaic = CastMosaic(characters: _castCover, accent: color);
    if (still != null) return PosterImage(assetKey: still!, fallback: mosaic);
    if (photo != null) {
      // A lighter grade than the event cards: tiles keep more of each
      // photo's own colour, so night shots stay readable.
      return EventArt(photo: photo, accent: color, icon: icon, grade: 0.42);
    }
    return mosaic;
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    // In the Upside Down the Christmas bulbs go cold.
    final color = world.tint(this.color);
    return NeonCard(
      onTap: onTap,
      glow: this.color,
      vineSeed: file * 31,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (clip == null)
            _art()
          else
            ClipLoop(videoKey: clip!, placeholder: _art()),
          // Dark end under the text; a little colour left at the top.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.45),
                  world.card.withValues(alpha: 0.97),
                ],
                stops: const [0, 0.45, 0.82],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      // Opaque centre: a translucent fill would let the halo
                      // bleed through and read as a solid disc.
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(world.card, color, 0.14),
                        border: Border.all(
                          color: color.withValues(alpha: 0.75),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                        shadows: [Shadow(color: color, blurRadius: 8)],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Text(
                        'FILE ${file.toString().padLeft(2, '0')}',
                        style: AppText.dossier(
                          Colors.white.withValues(alpha: 0.85),
                          size: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title.toUpperCase(),
                  style: AppText.headline(
                    world.ink,
                    size: 17,
                    letterSpacing: 0.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppText.body(
                    world.ink.withValues(alpha: 0.72),
                    size: 11.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
