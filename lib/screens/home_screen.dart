import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/app_video.dart';
import '../core/media/art.dart';
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
import '../data/moments.dart';
import '../data/quotes.dart';
import '../data/seasons.dart';
import '../models/character.dart';
import '../models/moment.dart';
import '../models/season.dart';
import 'bestiary_screen.dart';
import 'cast_screen.dart';
import 'character_detail_screen.dart';
import 'credits_screen.dart';
import 'moments_screen.dart';
import 'quotes_screen.dart';
import 'season_detail_screen.dart';
import 'seasons_screen.dart';
import 'story_screen.dart';
import 'settings_sheet.dart';
import 'timeline_screen.dart';
import 'trailer_player_screen.dart';

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

                    // The series at a glance, and the four doors fans use most.
                    const SliverToBoxAdapter(child: _StatsRow()),
                    SliverToBoxAdapter(
                      child: _QuickAccess(
                        onTimeline: () => _open(const TimelineScreen(), '/timeline'),
                        onMonsters: () => _open(const BestiaryScreen(), '/bestiary'),
                        onCharacters: () => _open(const CastScreen(), '/cast'),
                        onEpisodes: () => _open(const SeasonsScreen(), '/seasons'),
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
                      title: 'Latest Twists',
                      trailing: _SeeAll(
                        onTap: () => _open(const MomentsScreen(), '/moments'),
                      ),
                    ).sliver,
                    SliverToBoxAdapter(
                      child: _TwistRow(
                        shield: ref.watch(settingsProvider).spoilerShield,
                        watched: watched,
                        onTap: () => _open(const MomentsScreen(), '/moments'),
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
  });

  final VoidCallback onOpen;
  final String playLabel;
  final VoidCallback onWatch;
  final VoidCallback onTrailer;

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
              // The finale edit, silent, like a streaming billboard.
              const ClipLoop(videoKey: 'hero_finale', placeholder: SizedBox.shrink()),
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

/// The series at a glance, like the back of a box set.
class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final stats = [
      ('${Seasons.all.length}', 'SEASONS'),
      ('${Seasons.totalEpisodes}', 'CHAPTERS'),
      ('${cast_data.Cast.all.length}', 'DOSSIERS'),
      ('${Moments.all.length}', 'MOMENTS'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: NeonCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            for (final (i, (n, label)) in stats.indexed) ...[
              if (i > 0) Container(width: 1, height: 34, color: world.accent.withValues(alpha: 0.2)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      n,
                      style: AppText.headline(world.ink, size: 24, weight: 700, letterSpacing: 0).copyWith(
                        shadows: [Shadow(color: world.accent.withValues(alpha: 0.6), blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(label, style: AppText.label(world.muted).copyWith(fontSize: 9.5)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Four round doors into the sections fans open most.
class _QuickAccess extends StatelessWidget {
  const _QuickAccess({
    required this.onTimeline,
    required this.onMonsters,
    required this.onCharacters,
    required this.onEpisodes,
  });

  final VoidCallback onTimeline;
  final VoidCallback onMonsters;
  final VoidCallback onCharacters;
  final VoidCallback onEpisodes;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final items = [
      (Icons.timeline, 'TIMELINE', onTimeline),
      (Icons.filter_vintage, 'MONSTERS', onMonsters),
      (Icons.badge_outlined, 'CHARACTERS', onCharacters),
      (Icons.live_tv, 'EPISODES', onEpisodes),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          for (final (icon, label, onTap) in items)
            Expanded(
              child: GestureDetector(
                key: ValueKey('quick-${label.toLowerCase()}'),
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: world.card,
                        border: Border.all(color: world.accent.withValues(alpha: 0.7), width: 1.4),
                        boxShadow: [BoxShadow(color: world.accent.withValues(alpha: 0.3), blurRadius: 14)],
                      ),
                      child: Icon(icon, color: world.accent, size: 25, shadows: [Shadow(color: world.accent, blurRadius: 8)]),
                    ),
                    const SizedBox(height: 7),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label, style: AppText.headline(world.ink, size: 11, weight: 500, letterSpacing: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The series' turns as glowing case cards; behind the spoiler shield the
/// ones you haven't reached stay classified.
class _TwistRow extends StatelessWidget {
  const _TwistRow({required this.shield, required this.watched, required this.onTap});

  final bool shield;
  final Set<String> watched;
  final VoidCallback onTap;

  static IconData _icon(MomentKind k) => switch (k) {
    MomentKind.twist => Icons.autorenew,
    MomentKind.reveal => Icons.visibility,
    MomentKind.irony => Icons.theater_comedy,
    MomentKind.sacrifice => Icons.favorite,
    MomentKind.betrayal => Icons.heart_broken,
  };

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final twists = [
      for (final m in Moments.all)
        if (m.kind == MomentKind.twist || m.kind == MomentKind.reveal) m,
    ];
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: twists.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final m = twists[i];
          final hidden = shield && Seasons.isAhead(m.season, m.episode, watched);
          final c = world.tint(m.kind.color);
          final titleStyle = AppText.headline(world.ink, size: 14.5, letterSpacing: 0.04);
          return SizedBox(
            width: 148,
            child: NeonCard(
              onTap: onTap,
              glow: m.kind.color,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    hidden ? Icons.lock : _icon(m.kind),
                    color: c,
                    size: 30,
                    shadows: [Shadow(color: c, blurRadius: 12)],
                  ),
                  const Spacer(),
                  Text(m.kind.label.toUpperCase(), style: AppText.label(c).copyWith(fontSize: 9.5)),
                  const SizedBox(height: 3),
                  if (hidden)
                    RedactedText(m.title, style: titleStyle, maxLines: 2)
                  else
                    Text(m.title.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(m.chapterLabel, style: AppText.dossier(world.muted, size: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
