import 'package:flutter/material.dart';

import '../core/media/app_video.dart';
import '../core/media/decode_size.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
import '../data/fan_media.dart';
import 'explore_screen.dart' show ShelfTabs;

/// The screening room's full shelf: every fan edit in the media pack,
/// upright at last, filtered by what it's about. Tapping one plays from
/// there through the rest of the shelf.
class ReelScreen extends StatefulWidget {
  const ReelScreen({super.key, this.shelf});

  /// Open on one shelf; null shows everything.
  final ReelShelf? shelf;

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  late ReelShelf? _shelf = widget.shelf;

  @override
  Widget build(BuildContext context) {
    final clips = _shelf == null ? FanMedia.reel : FanMedia.onShelf(_shelf!);
    return STScaffold(
      title: 'THE REEL',
      subtitle: '${FanMedia.reel.length} fan edits · the right way up',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ShelfTabs<ReelShelf?>(
              values: [null, ...ReelShelf.values],
              selected: _shelf,
              label: (s) => s?.title.toUpperCase() ?? 'ALL',
              onSelect: (s) => setState(() => _shelf = s),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
              child: Row(
                children: [
                  FilledButton.icon(
                    key: const ValueKey('reel-play-all'),
                    onPressed: () => playReel(context, clips, 0),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('PLAY ALL'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.stRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${clips.length} clips · sound on',
                      style: AppText.dossier(
                        WorldPalette.of(context).muted,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 600 ? 3 : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: clips.length,
              itemBuilder: (context, i) => FlickerIn(
                index: i,
                child: ReelCard(
                  clip: clips[i],
                  onTap: () => playReel(context, clips, i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Plays [clips] fullscreen from [start], rolling through the rest.
Future<void> playReel(BuildContext context, List<FanClip> clips, int start) =>
    ClipPlayer.play(context, [
      for (final c in clips) ClipItem.fan(c),
    ], start: start);

/// A fan edit as a tape cover: its still, how it was shot, a play button,
/// and who cut it.
class ReelCard extends StatelessWidget {
  const ReelCard({
    super.key,
    required this.clip,
    required this.onTap,
    this.large = false,
  });

  final FanClip clip;
  final VoidCallback onTap;

  /// The featured variant: bigger type.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final accent = world.accent;
    return NeonCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          WorldGrade(
            strength: 0.75,
            child: LayoutBuilder(
              builder: (context, box) => Image(
                image: sizedAsset(clip.thumbnail, box.biggest, dpr),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(color: world.card),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x40000000),
                  Color(0x00000000),
                  Color(0xE6000000),
                ],
                stops: [0, 0.4, 1],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black.withValues(alpha: 0.55),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    clip.portrait
                        ? Icons.stay_current_portrait
                        : Icons.stay_current_landscape,
                    size: 11,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    clip.portrait ? 'PHONE' : 'WIDESCREEN',
                    style: AppText.label(
                      Colors.white70,
                    ).copyWith(fontSize: 8.5, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              width: large ? 58 : 44,
              height: large ? 58 : 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
                border: Border.all(color: accent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.7),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: large ? 34 : 26,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headline(
                    Colors.white,
                    size: large ? 22 : 14.5,
                    letterSpacing: 0.04,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  clip.note ?? clip.creator ?? 'Fan edit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.dossier(
                    Colors.white70,
                    size: large ? 12 : 10.5,
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
