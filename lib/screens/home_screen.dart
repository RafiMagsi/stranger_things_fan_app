import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/art.dart';
import '../core/media/poster_image.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_logo.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_toggle.dart';
import '../data/characters.dart' as cast_data;
import '../data/quotes.dart';
import '../data/seasons.dart';
import '../models/character.dart';
import '../models/season.dart';
import 'bestiary_screen.dart';
import 'cast_screen.dart';
import 'character_detail_screen.dart';
import 'credits_screen.dart';
import 'locations_screen.dart';
import 'moments_screen.dart';
import 'quiz_screen.dart';
import 'quotes_screen.dart';
import 'season_detail_screen.dart';
import 'seasons_screen.dart';
import 'soundboard_screen.dart';
import 'timeline_screen.dart';
import 'trailer_player_screen.dart';
import 'transmissions_screen.dart';

/// The hub: a feed of cards for exploring Hawkins. The finale up top, where
/// you are in the series, the Party, the seasons, Joyce's wall, every
/// section of the app, the town's grown-ups, and what crawled out of the
/// Upside Down.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _carouselController = PageController(viewportFraction: 0.7);
  int _carouselIndex = 0;

  static const _wallMessages = ['RIGHT HERE', 'RUN', 'FRIENDS DONT LIE'];
  int _wallMessage = 0;

  static const _residents = [
    cast_data.Cast.steve,
    cast_data.Cast.nancy,
    cast_data.Cast.jonathan,
    cast_data.Cast.robin,
    cast_data.Cast.hopper,
    cast_data.Cast.joyce,
  ];

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _open(Widget page, String name) =>
      RiftPageRoute.push(context, page, name: name);

  void _openCharacter(Character c, String heroTag) => _open(
        CharacterDetailScreen(character: c, heroTag: heroTag),
        '/character/${c.id}',
      );

  void _openSeason(Season s, {String? heroTag, int? focusEpisode}) => _open(
        SeasonDetailScreen(season: s, heroTag: heroTag, focusEpisode: focusEpisode),
        '/season/${s.number}',
      );

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final upsideDown = ref.watch(worldModeProvider);
    final watched = ref.watch(watchProgressProvider);
    final next = Seasons.nextUp(watched);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WorldAtmosphere(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(upsideDown: upsideDown)),

                // The finale, front and centre.
                SliverToBoxAdapter(
                  child: FlickerIn(
                    child: _FeaturedBanner(
                      onOpen: () => _openSeason(Seasons.s5),
                      onPlay: () => _open(
                        TrailerPlayerScreen(trailer: Seasons.s5.trailers.first),
                        '/trailer',
                      ),
                    ),
                  ),
                ),

                // Where you are in the series.
                SliverToBoxAdapter(
                  child: FlickerIn(
                    index: 1,
                    child: _NextUpCard(
                      next: next,
                      watched: watched.length,
                      onTap: next == null
                          ? () => _open(const MomentsScreen(), '/moments')
                          : () => _openSeason(next.$1, focusEpisode: next.$2.number),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SectionHeader(title: 'Meet the Party')),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 340,
                    child: PageView.builder(
                      controller: _carouselController,
                      itemCount: cast_data.Cast.party.length,
                      onPageChanged: (i) => setState(() => _carouselIndex = i),
                      itemBuilder: (context, i) {
                        final c = cast_data.Cast.party[i];
                        final tag = 'char-party-${c.id}';
                        return AnimatedPadding(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: _carouselIndex == i ? 0 : 18,
                          ),
                          child: _CharacterCard(
                            character: c,
                            heroTag: tag,
                            focused: _carouselIndex == i,
                            onTap: () => _openCharacter(c, tag),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SectionHeader(
                  title: 'The Seasons',
                  trailing: _SeeAll(onTap: () => _open(const SeasonsScreen(), '/seasons')),
                ).sliver,
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 236,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: Seasons.all.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final s = Seasons.all[i];
                        final tag = 'season-home-${s.number}';
                        final done = s.episodes.where((e) => watched.contains(s.keyFor(e))).length;
                        return _SeasonPoster(
                          season: s,
                          heroTag: tag,
                          watched: done,
                          onTap: () => _openSeason(s, heroTag: tag),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SectionHeader(title: 'Joyce\'s Wall')),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _WallCard(
                      message: _wallMessages[_wallMessage],
                      upsideDown: upsideDown,
                      onTap: () => setState(
                        () => _wallMessage = (_wallMessage + 1) % _wallMessages.length,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SectionHeader(title: 'Explore')),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.12,
                    children: [
                      for (final (i, tile) in _tiles.indexed)
                        _HubTile(
                          file: i + 1,
                          title: tile.title,
                          subtitle: tile.subtitle,
                          icon: tile.icon,
                          // The grid glows in Joyce's Christmas-bulb colours.
                          color: AppColors.bulbs[i % AppColors.bulbs.length],
                          onTap: () => _open(tile.page(), tile.route),
                        ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SectionHeader(title: 'Hawkins Residents')),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 214,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _residents.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final c = _residents[i];
                        final tag = 'char-resident-${c.id}';
                        return _MiniCharacterCard(
                          character: c,
                          heroTag: tag,
                          width: 140,
                          onTap: () => _openCharacter(c, tag),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SectionHeader(title: 'From the Upside Down')),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 214,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: cast_data.Cast.creatures.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final c = cast_data.Cast.creatures[i];
                        final tag = 'char-creature-${c.id}';
                        return _MiniCharacterCard(
                          character: c,
                          heroTag: tag,
                          width: 168,
                          creature: true,
                          onTap: () => _openCharacter(c, tag),
                        );
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: _QuoteOfTheDay(
                      onTap: () => _open(const QuotesScreen(), '/quotes'),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: _Footer(
                    accent: world.accent,
                    onCredits: () => _open(const CreditsScreen(), '/credits'),
                  ),
                ),
              ],
            ),
          ),
          const CrtOverlay(opacity: 0.06, animate: false),
        ],
      ),
    );
  }
}

typedef _Tile = ({
  String title,
  String subtitle,
  IconData icon,
  String route,
  Widget Function() page,
});

final List<_Tile> _tiles = [
  (title: 'Seasons', subtitle: 'Watch guide · 42 chapters', icon: Icons.live_tv, route: '/seasons', page: () => const SeasonsScreen()),
  (title: 'The Cast', subtitle: 'Every dossier', icon: Icons.badge, route: '/cast', page: () => const CastScreen()),
  (title: 'Transmissions', subtitle: 'Official trailers & radio', icon: Icons.play_circle, route: '/transmissions', page: () => const TransmissionsScreen()),
  (title: 'Timeline', subtitle: '1959 to 1989, in order', icon: Icons.timeline, route: '/timeline', page: () => const TimelineScreen()),
  (title: 'Hawkins Map', subtitle: 'Places & filming locations', icon: Icons.map, route: '/locations', page: () => const LocationsScreen()),
  (title: 'Bestiary', subtitle: 'Creatures of the Upside Down', icon: Icons.pets, route: '/bestiary', page: () => const BestiaryScreen()),
  (title: 'Moments', subtitle: 'Twists, reveals & ironies', icon: Icons.local_fire_department, route: '/moments', page: () => const MomentsScreen()),
  (title: 'Quotes', subtitle: 'Lines every fan knows', icon: Icons.format_quote, route: '/quotes', page: () => const QuotesScreen()),
  (title: 'Trivia', subtitle: 'Prove you\'re Hawkins-ready', icon: Icons.lightbulb, route: '/quiz', page: () => const QuizScreen()),
  (title: 'Soundboard', subtitle: 'Synth cues & SFX', icon: Icons.graphic_eq, route: '/soundboard', page: () => const SoundboardScreen()),
];

extension on SectionHeader {
  Widget get sliver => SliverToBoxAdapter(child: this);
}

class _Header extends StatelessWidget {
  const _Header({required this.upsideDown});

  final bool upsideDown;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const STLogo(size: 19),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Row(
                    key: ValueKey(upsideDown),
                    children: [
                      Icon(
                        upsideDown ? Icons.blur_on : Icons.location_on,
                        size: 14,
                        color: world.secondary,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          upsideDown
                              ? 'You are in the Upside Down'
                              : 'Hawkins, Indiana · 1983-1989',
                          style: AppText.dossier(world.muted, size: 12.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const WorldToggle(),
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
    final world = WorldPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Text('SEE ALL', style: AppText.label(world.muted).copyWith(fontSize: 11)),
    );
  }
}

/// The big banner at the top of the hub: the Gate breathing in the dark.
class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.onOpen, required this.onPlay});

  final VoidCallback onOpen;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: NeonCard(
        onTap: onOpen,
        padding: EdgeInsets.zero,
        borderRadius: 22,
        glow: AppColors.stRed,
        child: SizedBox(
          height: 236,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PosterImage(
                assetKey: 'featured',
                fallback: Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF3A0508), Color(0xFF12030A), Colors.black],
                        ),
                      ),
                    ),
                    GateArt(color: AppColors.stRed, seed: 1987),
                  ],
                ),
              ),
              // Legibility: dark end under the text, bottom-left.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0x00000000), Color(0x66000000), Color(0xE6000000)],
                    stops: [0.2, 0.55, 1],
                  ),
                ),
              ),
              const CrtOverlay(opacity: 0.12, animate: false),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlowBadge(
                      text: 'All 5 seasons streaming',
                      color: AppColors.hawkinsGold,
                      icon: Icons.play_arrow,
                      onImage: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'THE FINAL\nCHAPTER',
                      style: AppText.neon(size: 30, color: AppColors.stRed),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Season 5 · Hawkins, November 1987 · 8 chapters',
                      style: AppText.body(Colors.white.withValues(alpha: 0.85), size: 12.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: onPlay,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('TRAILER'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.stRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: onOpen,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text('EPISODES'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Next up": the first chapter you haven't watched, and how far you are.
class _NextUpCard extends StatelessWidget {
  const _NextUpCard({
    required this.next,
    required this.watched,
    required this.onTap,
  });

  final (Season, Episode)? next;
  final int watched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final total = Seasons.totalEpisodes;
    final next = this.next;
    final accent = next?.$1.accent ?? AppColors.safeGreen;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: NeonCard(
        onTap: onTap,
        glow: accent,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 62,
                height: 62,
                child: next == null
                    ? const KeyArt(accent: AppColors.safeGreen, icon: Icons.emoji_events, iconSize: 34, iconAlignment: Alignment.center)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          SeasonArt(season: next.$1),
                          Center(
                            child: Text(
                              '${next.$1.number}',
                              style: AppText.neon(size: 30, color: Colors.white, glow: 0.8),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    next == null
                        ? 'SERIES COMPLETE'
                        : 'NEXT UP · S${next.$1.number} ${next.$2.chapterLabel}',
                    style: AppText.chapter(accent, size: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    next == null ? 'Friends don\'t lie. You finished it.' : next.$2.title,
                    style: AppText.h2(world.ink).copyWith(fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: watched / total,
                            minHeight: 4,
                            color: accent,
                            backgroundColor: world.ink.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$watched / $total',
                        style: AppText.label(world.muted).copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: world.muted),
          ],
        ),
      ),
    );
  }
}

/// Portrait card in the Party carousel. The art flies into the dossier
/// header (Hero) as the page tears open.
class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.heroTag,
    required this.focused,
    required this.onTap,
  });

  final Character character;
  final String heroTag;
  final bool focused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = character;
    return NeonCard(
      onTap: onTap,
      glow: c.accent,
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(tag: heroTag, child: CharacterArt(character: c)),
          // Legibility scrim: the dark end sits under the text.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x14000000), Color(0x33000000), Color(0xF2000000)],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: GlowBadge(text: c.role ?? 'Hawkins', color: Colors.white70, onImage: true),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  c.name.toUpperCase(),
                  style: AppText.h1(Colors.white, heavy: true).copyWith(
                    fontSize: 27,
                    letterSpacing: 1,
                    shadows: [Shadow(color: c.accent, blurRadius: focused ? 18 : 0)],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.tagline,
                  style: AppText.body(Colors.white.withValues(alpha: 0.85), size: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (c.actor != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    c.actor!,
                    style: AppText.dossier(Colors.white.withValues(alpha: 0.65), size: 12),
                  ),
                ],
                const SizedBox(height: 8),
                GlowBadge(text: c.seasonLabel, color: c.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Smaller character card for the horizontal rows.
class _MiniCharacterCard extends StatelessWidget {
  const _MiniCharacterCard({
    required this.character,
    required this.heroTag,
    required this.width,
    required this.onTap,
    this.creature = false,
  });

  final Character character;
  final String heroTag;
  final double width;
  final VoidCallback onTap;
  final bool creature;

  @override
  Widget build(BuildContext context) {
    final c = character;
    return SizedBox(
      width: width,
      child: NeonCard(
        onTap: onTap,
        glow: creature ? AppColors.udLightning : c.accent,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(tag: heroTag, child: CharacterArt(character: c, iconSize: 110)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xE6000000)],
                  stops: [0.35, 1],
                ),
              ),
            ),
            if (creature)
              const Positioned(
                top: 10,
                left: 10,
                child: GlowBadge(text: 'Threat', color: AppColors.udLightning, icon: Icons.warning_amber, onImage: true),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    style: AppText.h2(Colors.white).copyWith(fontSize: 17),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.actor ?? c.alias,
                    style: AppText.dossier(Colors.white.withValues(alpha: 0.7), size: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

/// A season as a poster: art, a big neon numeral, and your progress.
class _SeasonPoster extends StatelessWidget {
  const _SeasonPoster({
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
    return SizedBox(
      width: 156,
      child: NeonCard(
        onTap: onTap,
        glow: s.accent,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(tag: heroTag, child: SeasonArt(season: s)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xEB000000)],
                  stops: [0.3, 1],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 12,
              child: Text('${s.number}', style: AppText.neon(size: 54, color: s.accent)),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SEASON ${numberWord(s.number)}', style: AppText.chapter(Colors.white, size: 12)),
                  const SizedBox(height: 4),
                  Text(
                    s.setting,
                    style: AppText.dossier(Colors.white.withValues(alpha: 0.75), size: 11.5),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: watched / s.episodes.length,
                      minHeight: 3,
                      color: s.accent,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
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

/// Joyce's alphabet wall, as an interactive card.
class _WallCard extends StatelessWidget {
  const _WallCard({
    required this.message,
    required this.upsideDown,
    required this.onTap,
  });

  final String message;
  final bool upsideDown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return NeonCard(
      onTap: onTap,
      glow: AppColors.hawkinsGold,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          AlphabetWall(message: message, upsideDown: upsideDown),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, size: 16, color: AppColors.hawkinsGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    upsideDown
                        ? 'Someone on the other side is spelling...'
                        : 'Will is spelling a message. Tap for another.',
                    style: AppText.dossier(world.muted, size: 12.5),
                  ),
                ),
                Icon(Icons.refresh, size: 18, color: world.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid tile into a section, filed like a lab case.
class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.file,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final int file;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return NeonCard(
      onTap: onTap,
      glow: color,
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
                  border: Border.all(color: color.withValues(alpha: 0.75)),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12)],
                ),
                child: Icon(icon, color: color, size: 20, shadows: [Shadow(color: color, blurRadius: 8)]),
              ),
              const Spacer(),
              Text(
                'FILE ${file.toString().padLeft(2, '0')}',
                style: AppText.dossier(world.muted.withValues(alpha: 0.8), size: 10.5),
              ),
            ],
          ),
          const Spacer(),
          Text(title, style: AppText.h2(world.ink).copyWith(fontSize: 17)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppText.body(world.muted, size: 11.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A line from the wall of quotes, changing daily.
class _QuoteOfTheDay extends StatelessWidget {
  const _QuoteOfTheDay({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final q = Quotes.all[DateTime.now().day % Quotes.all.length];
    return NeonCard(
      onTap: onTap,
      glow: q.accent,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OVERHEARD IN HAWKINS', style: AppText.chapter(q.accent, size: 11)),
          const SizedBox(height: 10),
          Text(
            '"${q.text}"',
            style: AppText.dossier(world.ink, size: 17),
          ),
          const SizedBox(height: 10),
          Text(
            '- ${q.speaker}, Season ${q.season}',
            style: AppText.label(world.muted).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.accent, required this.onCredits});

  final Color accent;
  final VoidCallback onCredits;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 48),
      child: Column(
        children: [
          const ChristmasLights(bulbCount: 16, animate: false),
          const SizedBox(height: 16),
          Text(
            'An unofficial fan companion for education and fun.\n'
            'Not affiliated with or endorsed by Netflix.',
            textAlign: TextAlign.center,
            style: AppText.dossier(world.muted, size: 12),
          ),
          TextButton(
            onPressed: onCredits,
            child: Text('CREDITS & SOURCES', style: AppText.label(accent)),
          ),
        ],
      ),
    );
  }
}
