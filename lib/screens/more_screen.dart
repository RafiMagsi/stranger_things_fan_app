import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_scaffold.dart';
import 'credits_screen.dart';
import 'gallery_screen.dart';
import 'quiz_screen.dart';
import 'quotes_screen.dart';
import 'reel_screen.dart';
import 'settings_sheet.dart';
import 'soundboard_screen.dart';
import 'story_screen.dart';

typedef _Row = ({
  String key,
  IconData icon,
  String title,
  String body,
  Color color,
});

/// Dive deeper: the extras, the settings, and where everything came from.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const List<_Row> _rows = [
    (
      key: 'story',
      icon: Icons.auto_stories,
      title: 'Story Mode',
      body: 'The whole series, chapter by chapter',
      color: AppColors.stRed,
    ),
    (
      key: 'reel',
      icon: Icons.movie,
      title: 'The Reel',
      body: 'Fan edits, the right way up',
      color: Color(0xFF4FC3F7),
    ),
    (
      key: 'gallery',
      icon: Icons.palette,
      title: 'Fan Art',
      body: 'The gallery wall',
      color: Color(0xFFB388FF),
    ),
    (
      key: 'sounds',
      icon: Icons.graphic_eq,
      title: 'Sounds & Music',
      body: 'The show\'s own sounds, from the clips',
      color: Color(0xFF66BB6A),
    ),
    (
      key: 'quotes',
      icon: Icons.format_quote,
      title: 'Quotes',
      body: 'Iconic lines from the series',
      color: AppColors.hawkinsGold,
    ),
    (
      key: 'trivia',
      icon: Icons.lightbulb,
      title: 'Trivia',
      body: 'Prove you\'re Hawkins-ready',
      color: Color(0xFFFF7043),
    ),
    (
      key: 'settings',
      icon: Icons.tune,
      title: 'Settings',
      body: 'Spoilers, sound, motion, progress',
      color: Color(0xFF90A4AE),
    ),
    (
      key: 'credits',
      icon: Icons.info_outline,
      title: 'Credits & Sources',
      body: 'Who made what, and the licences',
      color: Color(0xFF90A4AE),
    ),
    (
      key: 'about',
      icon: Icons.favorite_border,
      title: 'About',
      body: 'A fan companion, not an official app',
      color: AppColors.stRed,
    ),
  ];

  void _open(BuildContext context, String key) {
    void push(Widget page, String name) =>
        RiftPageRoute.push(context, page, name: name);
    switch (key) {
      case 'story':
        push(const StoryScreen(), '/story');
      case 'reel':
        push(const ReelScreen(), '/reel');
      case 'gallery':
        push(const GalleryScreen(), '/gallery');
      case 'sounds':
        push(const SoundboardScreen(), '/soundboard');
      case 'quotes':
        push(const QuotesScreen(), '/quotes');
      case 'trivia':
        push(const QuizScreen(), '/quiz');
      case 'settings':
        showSettingsSheet(context);
      case 'credits':
        push(const CreditsScreen(), '/credits');
      case 'about':
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => const _About(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return STScaffold(
      title: 'MORE',
      subtitle: 'Dive deeper',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          for (final (i, r) in _rows.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FlickerIn(
                index: i,
                child: NeonCard(
                  key: ValueKey('more-${r.key}'),
                  onTap: () => _open(context, r.key),
                  glow: r.color,
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: world.tint(r.color).withValues(alpha: 0.75),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: world.tint(r.color).withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          r.icon,
                          size: 20,
                          color: world.tint(r.color),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.title.toUpperCase(),
                              style: AppText.headline(
                                world.ink,
                                size: 15,
                                letterSpacing: 0.06,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.body,
                              style: AppText.dossier(world.muted, size: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: world.muted),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const ChristmasLights(bulbCount: 16, animate: false),
        ],
      ),
    );
  }
}

class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: NeonCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ABOUT THIS APP',
                style: AppText.headline(world.ink, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'An unofficial fan companion to Stranger Things, made for education and fun. '
                'Not affiliated with or endorsed by Netflix.\n\n'
                'Official trailers stream from Netflix\'s own YouTube channels. Photos are '
                'freely licensed and credited. The Reel, the fan-art wall and the captured '
                'sounds are a personal media pack of other fans\' work - see Credits.',
                style: AppText.body(
                  world.ink.withValues(alpha: 0.85),
                  size: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
