import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/poster_image.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../data/characters.dart' as cast_data;
import '../models/character.dart';
import 'bestiary_screen.dart';
import 'character_detail_screen.dart';
import 'locations_screen.dart';
import 'moments_screen.dart';
import 'quiz_screen.dart';
import 'quotes_screen.dart';
import 'seasons_screen.dart';
import 'soundboard_screen.dart';
import 'timeline_screen.dart';
import 'transmissions_screen.dart';

/// The hub. Featured banner + character carousel + quick tiles into every
/// section of the app.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _carouselController = PageController(viewportFraction: 0.78);
  int _carouselIndex = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final upsideDown = ref.watch(worldModeProvider);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
            // App bar with world toggle.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => const LinearGradient(
              colors: [Color(0xFFE50914), Color(0xFFA00312)],
              stops: [0.0, 1.0],
            ).createShader(rect),
            child: Text(
              'STRANGER THINGS',
              style: AppText.title(
                size: 22,
                glow: upsideDown
                    ? AppColors.udSpore
                    : AppColors.stRed,
              ),
            ),
          ),
                          const SizedBox(height: 2),
                          Text(
                            upsideDown ? 'You are in the Upside Down' : 'Hawkins, Indiana · 1985',
                            style: AppText.body(
                              scheme.onSurface.withValues(alpha: 0.55),
                              size: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const WorldToggle(),
                  ],
                ),
              ),
            ),

            // Featured banner.
            SliverToBoxAdapter(
              child: _FeaturedBanner(
                onTap: () => RiftPageRoute.push(
                  context,
                  const TransmissionsScreen(),
                  name: '/transmissions',
                ),
              ),
            ),

            // Character carousel section.
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Meet the Party'),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _carouselController,
                  itemCount: cast_data.Cast.party.length,
                  onPageChanged: (i) => setState(() => _carouselIndex = i),
                  itemBuilder: (context, i) {
                    final c = cast_data.Cast.party[i];
                    return AnimatedPadding(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: _carouselIndex == i ? 0 : 14,
                      ),
                      child: _CharacterCard(
                        character: c,
                        onTap: () => _openDetail(context, c),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Quick tiles.
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Explore'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _HubTile(
                    title: 'Seasons',
                    subtitle: '5 seasons · 42 chapters',
                    icon: Icons.live_tv,
                    color: AppColors.stRed,
                    onTap: () => RiftPageRoute.push(
                      context,
                      const SeasonsScreen(),
                      name: '/seasons',
                    ),
                  ),
                  _HubTile(
                    title: 'Transmissions',
                    subtitle: 'Trailers & teasers',
                    icon: Icons.play_circle,
                    color: AppColors.hawkinsGold,
                    onTap: () => RiftPageRoute.push(
                      context,
                      const TransmissionsScreen(),
                      name: '/transmissions',
                    ),
                  ),
                  _HubTile(
                    title: 'Timeline',
                    subtitle: '1959 to the rightside up',
                    icon: Icons.timeline,
                    color: const Color(0xFF8E4585),
                    onTap: () => RiftPageRoute.push(
                      context,
                      const TimelineScreen(),
                      name: '/timeline',
                    ),
                  ),
                  _HubTile(
                    title: 'Hawkins Map',
                    subtitle: 'Key locations',
                    icon: Icons.map,
                    color: const Color(0xFF4DD0E1),
                    onTap: () => RiftPageRoute.push(
                      context,
                      const LocationsScreen(),
                      name: '/locations',
                    ),
                  ),
                  _HubTile(
                    title: 'Bestiary',
                    subtitle: 'Creatures of the Upside Down',
                    icon: Icons.pets,
                    color: const Color(0xFFEF5350),
                    onTap: () => RiftPageRoute.push(
                      context,
                      const BestiaryScreen(),
                      name: '/bestiary',
                    ),
                  ),
                  _HubTile(
                    title: 'Moments',
                    subtitle: 'Twists, reveals & ironies',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFB388FF),
                    onTap: () => RiftPageRoute.push(
                      context,
                      const MomentsScreen(),
                      name: '/moments',
                    ),
                  ),
                  _HubTile(
                    title: 'Quotes',
                    subtitle: 'Lines every fan knows',
                    icon: Icons.format_quote,
                    color: const Color(0xFF57D9A3),
                    onTap: () => RiftPageRoute.push(
                      context,
                      const QuotesScreen(),
                      name: '/quotes',
                    ),
                  ),
                  _HubTile(
                    title: 'Trivia',
                    subtitle: 'Prove you\'re Hawkins-ready',
                    icon: Icons.lightbulb,
                    color: AppColors.udSpore,
                    onTap: () => RiftPageRoute.push(
                      context,
                      const QuizScreen(),
                      name: '/quiz',
                    ),
                  ),
                  _HubTile(
                    title: 'Soundboard',
                    subtitle: 'Synth cues & SFX',
                    icon: Icons.graphic_eq,
                    color: const Color(0xFFB388FF),
                    onTap: () => RiftPageRoute.push(
                      context,
                      const SoundboardScreen(),
                      name: '/soundboard',
                    ),
                  ),
                ],
              ),
            ),

            // Creatures row.
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'From the Upside Down'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList.list(
                children: [
                  for (final c in cast_data.Cast.creatures)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CreatureRowTile(
                        character: c,
                        onTap: () => _openDetail(context, c),
                      ),
                    ),
                ],
              ),
            ),
              ],
            ),
          ),

          // Faint CRT/VHS texture across the whole hub.
          const IgnorePointer(
            child: CrtOverlay(opacity: 0.08),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Character c) {
    RiftPageRoute.push(
      context,
      CharacterDetailScreen(character: c),
      name: '/character/${c.id}',
    );
  }
}

/// Animated Hawkins ⇄ Upside Down switch in the app bar.
class WorldToggle extends ConsumerWidget {
  const WorldToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upsideDown = ref.watch(worldModeProvider);
    final primary = upsideDown ? AppColors.udSpore : AppColors.stRed;

    return GestureDetector(
      key: const ValueKey('world-toggle'),
      onTap: () => ref.read(worldModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        width: 92,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: upsideDown
              ? AppColors.udFogHi.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.06),
          border: Border.all(color: primary.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: upsideDown
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: upsideDown
                      ? [AppColors.udSpore, const Color(0xFF2A5C58)]
                      : [Colors.amber, AppColors.stRed],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.8),
                    blurRadius: 8,
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

/// The big "featured" banner at the top of the hub.
class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A0E2C),
                  Color(0xFF5B1236),
                  Color(0xFFE50914),
                ],
                stops: [0, 0.55, 1],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Drop-in featured still if bundled, else the gradient art.
                PosterImage(
                  assetKey: 'featured',
                  fallback: const SizedBox.expand(),
                ),
                // Vignette + grain overlay.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, 0.4),
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 20,
                  right: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GlowBadge(
                        text: 'Now Streaming',
                        color: Colors.amber,
                        icon: Icons.play_arrow,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'THE FINAL CHAPTER',
                        style: AppText.h1(Colors.white).copyWith(
                          fontSize: 26,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Season 5 · 8 chapters · the gate closes for good.',
                        style: AppText.body(
                          Colors.white.withValues(alpha: 0.85),
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Play affordance.
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow,
                        color: AppColors.stRed, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Parallax character card in the carousel.
class _CharacterCard extends StatelessWidget {
  const _CharacterCard({required this.character, required this.onTap});

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // DARK end of the gradient anchors the text (bottom-left).
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                character.accent,
                character.accentDeep,
                world.bg,
              ],
              stops: const [0, 0.55, 1],
            ),
            border: Border.all(
              color: world.accent.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: character.accent.withValues(alpha: 0.25),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Drop-in still if bundled, else the icon art.
              PosterImage(
                assetKey: 'char_${character.id}',
                fallback: const SizedBox.expand(),
              ),
              // Legibility scrim over any still.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Icon "art" in the upper right, softly lit.
              Positioned(
                top: 18,
                right: 18,
                child: Opacity(
                  opacity: 0.22,
                  child: Icon(character.icon, size: 120, color: Colors.white),
                ),
              ),
              // Identity dot.
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: character.accent,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Text block anchored bottom-left on the dark end.
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      character.name.toUpperCase(),
                      style: AppText.h1(Colors.white).copyWith(
                        fontSize: 24,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.tagline,
                      style: AppText.body(
                        Colors.white.withValues(alpha: 0.82),
                        size: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    GlowBadge(text: character.seasonLabel, color: Colors.white70),
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

/// Wide tile for the creatures section.
class _CreatureRowTile extends StatelessWidget {
  const _CreatureRowTile({required this.character, required this.onTap});

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      glow: character.accent,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [character.accent, character.accentDeep],
              ),
              boxShadow: [
                BoxShadow(
                  color: character.accent.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(character.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(character.name, style: AppText.h2(Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(
                  character.tagline,
                  style: AppText.body(
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// Grid tile into a section.
class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [color.withValues(alpha: 0.28), world.card],
              stops: const [0, 0.7],
            ),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.h2(Theme.of(context).colorScheme.onSurface).copyWith(fontSize: 17)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppText.body(
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                      size: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
