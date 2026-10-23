import 'package:flutter/material.dart';

import '../core/media/app_video.dart';
import '../core/media/poster_image.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';

/// One clip in the reel: the assets/video key, how to label it, and the
/// still (extracted from the same footage) that keeps the grid cheap.
typedef _Clip = ({
  String key,
  String title,
  String credit,
  String still,
});

/// The screening room: every bundled clip, tapped through to the
/// fullscreen player. Cards show stills rather than looping video so a
/// whole wall of decoders never opens at once — the motion happens in
/// the player.
class ReelScreen extends StatelessWidget {
  const ReelScreen({super.key});

  static const List<_Clip> _reel = [
    (key: 'gate_finale', title: 'Finale Edit', credit: 'samedits.fx', still: 'featured'),
    (key: 's5_teaser', title: 'The Fall of 1987', credit: 'Season 5 teaser', still: 'season_5'),
    (key: 'hawkins_world', title: 'Hawkins', credit: 'aesthetic cut', still: 'bg_hawkins'),
    (key: 'upside_down', title: 'The Upside Down', credit: 'season 5 cuts', still: 'bg_upside'),
    (key: 'eleven', title: 'Eleven', credit: 'fan edit', still: 'char_eleven'),
    (key: 'max', title: 'Max', credit: 'Sadie Sink edit', still: 'char_max'),
    (key: 'steve', title: 'Steve Harrington', credit: 'fan edit', still: 'char_steve'),
    (key: 'vecna', title: 'Vecna', credit: 'The Undying King', still: 'char_vecna'),
    (key: 'will', title: 'Will Byers', credit: 'fan edit', still: 'char_will'),
    (key: 'mind_flayer', title: 'Mind Flayer', credit: 'fan edit', still: 'monster_mind_flayer'),
    (key: 'clock', title: 'The Clock Is Ticking', credit: 'countdown cut', still: 'st_clock'),
    (key: 'adventure', title: 'One Last Adventure', credit: '4K cut', still: 'st_adventure'),
    (key: 'kate_bush', title: 'Running Up That Hill', credit: 'Kate Bush anniversary', still: 'char_max'),
  ];

  @override
  Widget build(BuildContext context) {
    return STScaffold(
      title: 'THE REEL',
      subtitle: '${_reel.length} clips captured for this app',
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.86,
        ),
        itemCount: _reel.length,
        itemBuilder: (context, i) {
          final clip = _reel[i];
          return FlickerIn(
            index: i,
            child: _ClipCard(
              clip: clip,
              accent: AppColors.bulbs[i % AppColors.bulbs.length],
              onTap: () => ClipPlayer.open(
                context,
                videoKey: clip.key,
                title: clip.title,
                subtitle: clip.credit,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ClipCard extends StatelessWidget {
  const _ClipCard({
    required this.clip,
    required this.accent,
    required this.onTap,
  });

  final _Clip clip;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return NeonCard(
      onTap: onTap,
      glow: accent,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PosterImage(
            assetKey: clip.still,
            fallback: ColoredBox(color: world.card),
          ),
          // Dark end under the labels.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0x00000000), Color(0xE6000000)],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          // The play affordance, dead centre.
          const Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x8C000000),
              ),
              child: Padding(
                padding: EdgeInsets.all(11),
                child: Icon(Icons.play_arrow, size: 26, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clip.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.h2(world.ink).copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  clip.credit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.dossier(world.muted, size: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
