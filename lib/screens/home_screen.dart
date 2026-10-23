import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/app_video.dart';
import '../core/media/art.dart';
import '../core/media/asset_media.dart';
import '../core/media/billboard.dart';
import '../core/media/poster_image.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/monster_fx.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_logo.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
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
import 'gate_screen.dart';
import 'locations_screen.dart';
import 'moments_screen.dart';
import 'quiz_screen.dart';
import 'quotes_screen.dart';
import 'reel_screen.dart';
import 'season_detail_screen.dart';
import 'seasons_screen.dart';
import 'story_screen.dart';
import 'settings_sheet.dart';
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

  /// Story mode from [season]/[episode] (the very start when null).
  void _watch(Season? season, Episode? episode) => _open(
    StoryScreen(season: season?.number, episode: episode?.number),
    '/story',
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
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _Header(upsideDown: upsideDown)),

                    // The finale, front and centre.
                    SliverToBoxAdapter(
                      child: FlickerIn(
                        child: _FeaturedBanner(
                          onOpen: () => _openSeason(Seasons.s5),
                          // Watch the story from wherever you are.
                          playLabel: switch (next) {
                            null => 'WATCH AGAIN',
                            _ when watched.isEmpty => 'START WATCHING',
                            (final s, final e) =>
                              'RESUME S${s.number} · E${e.number}',
                          },
                          onWatch: () => _watch(next?.$1, next?.$2),
                          onTrailer: () => _open(
                            TrailerPlayerScreen(
                              trailer: Seasons.s5.trailers.first,
                            ),
                            '/trailer',
                          ),
                          previews: ref
                              .watch(settingsProvider)
                              .autoplayPreviews,
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
                              : () => _watch(next.$1, next.$2),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'Meet the Party'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 340,
                        child: PageView.builder(
                          controller: _carouselController,
                          itemCount: cast_data.Cast.party.length,
                          onPageChanged: (i) =>
                              setState(() => _carouselIndex = i),
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
                              child: AnimatedBuilder(
                                animation: _carouselController,
                                builder: (context, _) {
                                  final c0 = _carouselController;
                                  final page =
                                      c0.hasClients &&
                                          c0.position.haveDimensions
                                      ? c0.page ?? i.toDouble()
                                      : _carouselIndex.toDouble();
                                  return _CharacterCard(
                                    character: c,
                                    heroTag: tag,
                                    focused: _carouselIndex == i,
                                    parallax: (page - i).clamp(-1.0, 1.0),
                                    onTap: () => _openCharacter(c, tag),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    SectionHeader(
                      title: 'The Seasons',
                      trailing: _SeeAll(
                        onTap: () => _open(const SeasonsScreen(), '/seasons'),
                      ),
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
                            final done = s.episodes
                                .where((e) => watched.contains(s.keyFor(e)))
                                .length;
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

                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'Joyce\'s Wall'),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _WallCard(
                          message: _wallMessages[_wallMessage],
                          upsideDown: upsideDown,
                          onTap: () => setState(
                            () => _wallMessage =
                                (_wallMessage + 1) % _wallMessages.length,
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'Explore'),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid.count(
                        // Three across when a tablet gives us the room.
                        crossAxisCount: MediaQuery.sizeOf(context).width >= 600
                            ? 3
                            : 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.96,
                        children: [
                          // The door itself, looping live on the tile.
                          _HubTile(
                            file: 1,
                            title: 'The Gate',
                            subtitle: 'Press the door · cross worlds',
                            icon: Icons.door_sliding,
                            color: AppColors.stRed,
                            photo: null,
                            videoKey: 'gate_finale',
                            onTap: () => _open(const GateScreen(), '/gate'),
                          ),
                          // The screening room, also alive on its tile.
                          _HubTile(
                            file: 2,
                            title: 'The Reel',
                            subtitle: 'Screening room · captured clips',
                            icon: Icons.movie,
                            color: AppColors.udSpore,
                            photo: null,
                            videoKey: 'adventure',
                            onTap: () => _open(const ReelScreen(), '/reel'),
                          ),
                          for (final (i, tile) in _tiles.indexed)
                            _HubTile(
                              file: i + 2,
                              title: tile.title,
                              subtitle: tile.subtitle,
                              icon: tile.icon,
                              photo: tile.photo,
                              // The grid glows in Joyce's Christmas-bulb colours.
                              color:
                                  AppColors.bulbs[i % AppColors.bulbs.length],
                              onTap: () => _open(tile.page(), tile.route),
                            ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'Hawkins Residents'),
                    ),
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

                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'From the Upside Down'),
                    ),
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
                        onCredits: () =>
                            _open(const CreditsScreen(), '/credits'),
                      ),
                    ),
                  ],
                ),
              ),
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
  // The real-world thing the section is about; null = the cast mosaic.
  String? photo,
});

final List<_Tile> _tiles = [
  (
    title: 'Seasons',
    subtitle: 'Watch guide · 42 chapters',
    icon: Icons.live_tv,
    route: '/seasons',
    page: () => const SeasonsScreen(),
    photo: 'events/tv',
  ),
  (
    title: 'The Cast',
    subtitle: 'Every dossier',
    icon: Icons.badge,
    route: '/cast',
    page: () => const CastScreen(),
    photo: null,
  ),
  (
    title: 'Transmissions',
    subtitle: 'Official trailers & radio',
    icon: Icons.play_circle,
    route: '/transmissions',
    page: () => const TransmissionsScreen(),
    photo: 'events/walkie',
  ),
  (
    title: 'Timeline',
    subtitle: '1959 to 1989, in order',
    icon: Icons.timeline,
    route: '/timeline',
    page: () => const TimelineScreen(),
    photo: 'events/lights',
  ),
  (
    title: 'Hawkins Map',
    subtitle: 'Places & filming locations',
    icon: Icons.map,
    route: '/locations',
    page: () => const LocationsScreen(),
    photo: 'filming/downtown_hawkins',
  ),
  (
    title: 'Bestiary',
    subtitle: 'Creatures of the Upside Down',
    icon: Icons.filter_vintage, // the Demogorgon's petal head
    route: '/bestiary',
    page: () => const BestiaryScreen(),
    photo: 'events/flytrap',
  ),
  (
    title: 'Moments',
    subtitle: 'Twists, reveals & ironies',
    icon: Icons.local_fire_department,
    route: '/moments',
    page: () => const MomentsScreen(),
    photo: 'events/polaroid',
  ),
  (
    title: 'Quotes',
    subtitle: 'Lines every fan knows',
    icon: Icons.format_quote,
    route: '/quotes',
    page: () => const QuotesScreen(),
    photo: 'events/typewriter',
  ),
  (
    title: 'Trivia',
    subtitle: 'Prove you\'re Hawkins-ready',
    icon: Icons.lightbulb,
    route: '/quiz',
    page: () => const QuizScreen(),
    photo: 'events/dice',
  ),
  (
    title: 'Soundboard',
    subtitle: 'Synth cues & SFX',
    icon: Icons.graphic_eq,
    route: '/soundboard',
    page: () => const SoundboardScreen(),
    photo: 'events/synth',
  ),
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
                NeonIgnite(
                  delay: const Duration(milliseconds: 350),
                  builder: (context, glow) => STLogo(size: 19, glow: glow),
                ),
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
          IconButton(
            key: const ValueKey('open-settings'),
            tooltip: 'Settings',
            onPressed: () => showSettingsSheet(context),
            icon: Icon(Icons.tune, color: world.muted),
          ),
          const SizedBox(width: 4),
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
      child: Text(
        'SEE ALL',
        style: AppText.label(world.muted).copyWith(fontSize: 11),
      ),
    );
  }
}

/// The big banner at the top of the hub: the Gate breathing in the dark.
class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({
    required this.onOpen,
    required this.playLabel,
    required this.onWatch,
    required this.onTrailer,
    required this.previews,
  });

  final VoidCallback onOpen;
  final String playLabel;
  final VoidCallback onWatch;
  final VoidCallback onTrailer;

  /// Let the official trailer play silently behind the banner.
  final bool previews;

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
                    // The room decays with the world; the Gate is red in both.
                    const WorldGrade(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0xFF3A0508),
                              Color(0xFF12030A),
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
                    ),
                    const GateArt(color: AppColors.stRed, seed: 1987),
                  ],
                ),
              ),
              // The bundled finale edit, silent, like a streaming
              // billboard; the official YouTube trailer previews only
              // when no local clip is bundled.
              FutureBuilder<bool>(
                future: AssetMedia.hasVideo('gate_finale'),
                builder: (context, snap) {
                  if (snap.data == true) {
                    return Positioned.fill(
                      child: ClipLoop(
                        videoKey: 'gate_finale',
                        placeholder: const SizedBox.shrink(),
                      ),
                    );
                  }
                  if (!snap.hasData) return const SizedBox.shrink();
                  return TrailerBillboard(
                    trailer: Seasons.s5.trailers.last,
                    enabled: previews,
                  );
                },
              ),
              // Legibility: dark end under the text, bottom-left.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0x00000000),
                      Color(0x66000000),
                      Color(0xE6000000),
                    ],
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
                      style: AppText.body(
                        Colors.white.withValues(alpha: 0.85),
                        size: 12.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          key: const ValueKey('play-story'),
                          onPressed: onWatch,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: Text(playLabel),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.stRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: onTrailer,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: const Text('TRAILER'),
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
    final accent = world.tint(next?.$1.accent ?? AppColors.safeGreen);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: NeonCard(
        onTap: onTap,
        // NeonCard tints its own glow; pass the raw colour.
        glow: next?.$1.accent ?? AppColors.safeGreen,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 62,
                height: 62,
                child: next == null
                    ? const KeyArt(
                        accent: AppColors.safeGreen,
                        icon: Icons.emoji_events,
                        iconSize: 34,
                        iconAlignment: Alignment.center,
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          SeasonArt(season: next.$1),
                          Center(
                            child: Text(
                              '${next.$1.number}',
                              style: AppText.neon(
                                size: 30,
                                color: Colors.white,
                                glow: 0.8,
                              ),
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
                    next == null
                        ? 'Friends don\'t lie. You finished it.'
                        : next.$2.title,
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
                        style: AppText.label(
                          world.muted,
                        ).copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.play_circle_outline, color: accent, size: 30),
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
    this.parallax = 0,
  });

  final Character character;
  final String heroTag;
  final bool focused;
  final VoidCallback onTap;

  /// -1..1: how far this card is from the centre of the carousel.
  final double parallax;

  @override
  Widget build(BuildContext context) {
    final c = character;
    final accent = WorldPalette.of(context).tint(c.accent);
    return NeonCard(
      onTap: onTap,
      glow: c.accent,
      padding: EdgeInsets.zero,
      borderRadius: 24,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Parallax: the portrait drifts slower than its card as the
          // carousel slides, so each poster has depth.
          Transform.translate(
            offset: Offset(parallax * -46, 0),
            child: Transform.scale(
              scale: 1.18,
              child: STHero(
                tag: heroTag,
                radius: 24,
                child: CharacterArt(character: c),
              ),
            ),
          ),
          // Legibility scrim: the dark end sits under the text.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x14000000),
                  Color(0x33000000),
                  Color(0xF2000000),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: GlowBadge(
              text: c.role ?? 'Hawkins',
              color: Colors.white70,
              onImage: true,
            ),
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
                    shadows: [
                      Shadow(color: accent, blurRadius: focused ? 18 : 0),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.tagline,
                  style: AppText.body(
                    Colors.white.withValues(alpha: 0.85),
                    size: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (c.actor != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    c.actor!,
                    style: AppText.dossier(
                      Colors.white.withValues(alpha: 0.65),
                      size: 12,
                    ),
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
            STHero(
              tag: heroTag,
              radius: 18,
              child: CharacterArt(character: c, iconSize: 110),
            ),
            // The things from the other side move: each creature gets its
            // signature animation over the art.
            if (creature)
              Positioned.fill(
                child: MonsterFx(
                  monsterId: c.id,
                  accent: c.accent,
                  intensity: 0.8,
                ),
              ),
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
                child: GlowBadge(
                  text: 'Threat',
                  color: AppColors.udLightning,
                  icon: Icons.warning_amber,
                  onImage: true,
                ),
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
                    style: AppText.dossier(
                      Colors.white.withValues(alpha: 0.7),
                      size: 11,
                    ),
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
    final accent = WorldPalette.of(context).tint(s.accent);
    return SizedBox(
      width: 156,
      child: NeonCard(
        onTap: onTap,
        glow: s.accent,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            STHero(
              tag: heroTag,
              radius: 18,
              child: SeasonArt(season: s),
            ),
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
              child: Text(
                '${s.number}',
                style: AppText.neon(size: 54, color: accent),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEASON ${numberWord(s.number)}',
                    style: AppText.chapter(Colors.white, size: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.setting,
                    style: AppText.dossier(
                      Colors.white.withValues(alpha: 0.75),
                      size: 11.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: watched / s.episodes.length,
                      minHeight: 3,
                      color: accent,
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
                Icon(
                  Icons.lightbulb,
                  size: 16,
                  color: world.tint(AppColors.hawkinsGold),
                ),
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

/// Grid tile into a section, filed like a lab case: a real photo of the
/// thing the section is about, graded into the world, under a scrim that
/// keeps the words legible.
class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.file,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.photo,
    this.videoKey,
  });

  final int file;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  /// Null shows the cast mosaic.
  final String? photo;

  /// A bundled clip to loop behind the tile; falls back to [photo]/mosaic.
  final String? videoKey;

  /// The tile's still: the cast mosaic, or the graded event photo.
  Widget _art() => photo == null
      ? CastMosaic(characters: _castCover, accent: color)
      // A lighter grade than the event cards: tiles keep more of
      // each photo's own colour, so night shots stay readable.
      : EventArt(
          photo: photo,
          accent: color,
          icon: icon,
          grade: 0.42,
        );

  static const _castCover = [
    cast_data.Cast.eleven,
    cast_data.Cast.mike,
    cast_data.Cast.dustin,
    cast_data.Cast.lucas,
  ];

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
          videoKey == null
              ? _art()
              : ClipLoop(videoKey: videoKey!, placeholder: _art()),
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
                  title,
                  style: AppText.h2(world.ink).copyWith(fontSize: 17),
                ),
                const SizedBox(height: 2),
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

/// A line from the wall of quotes, changing daily.
class _QuoteOfTheDay extends StatelessWidget {
  const _QuoteOfTheDay({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final q = Quotes.all[DateTime.now().day % Quotes.all.length];
    final accent = world.tint(q.accent);
    return NeonCard(
      onTap: onTap,
      glow: q.accent,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OVERHEARD IN HAWKINS',
            style: AppText.chapter(accent, size: 11),
          ),
          const SizedBox(height: 10),
          TypewriterText(
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
