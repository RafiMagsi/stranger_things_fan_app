import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/seasons.dart';
import '../models/trailer.dart';

/// Plays one official trailer in-app, framed like a tape in a VCR.
///
/// Video streams from Netflix's own YouTube upload through YouTube's
/// embedded player; nothing is downloaded or re-hosted by the app.
class TrailerPlayerScreen extends StatefulWidget {
  const TrailerPlayerScreen({super.key, required this.trailer});

  final Trailer trailer;

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late final YoutubePlayerController _controller =
      YoutubePlayerController.fromVideoId(
    videoId: widget.trailer.youtubeId,
    autoPlay: true,
    params: const YoutubePlayerParams(
      showFullscreenButton: true,
      strictRelatedVideos: true,
    ),
  );

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Future<void> _openInYouTube() async {
    final ok = await launchUrl(
      Uri.parse(widget.trailer.watchUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t open YouTube on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final t = widget.trailer;
    final season = Seasons.all[t.season - 1];
    final others = [
      for (final s in Seasons.all) ...s.trailers.where((o) => o.youtubeId != t.youtubeId),
    ];

    return STScaffold(
      title: 'TRANSMISSION',
      subtitle: 'Season ${t.season} · ${t.title}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _VcrFrame(
            accent: season.accent,
            child: YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          ),
          const SizedBox(height: 18),
          Text(
            'STRANGER THINGS ${t.season}',
            style: AppText.chapter(season.accent, size: 12),
          ),
          const SizedBox(height: 6),
          Text(t.title, style: AppText.h1(world.ink).copyWith(fontSize: 26)),
          const SizedBox(height: 10),
          Row(
            children: [
              GlowBadge(text: 'Official · ${t.channel}', color: AppColors.safeGreen, icon: Icons.verified),
              const SizedBox(width: 8),
              GlowBadge(text: season.setting, color: world.muted),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openInYouTube,
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('OPEN IN YOUTUBE'),
          ),
          const SizedBox(height: 14),
          Text(
            'Streamed from ${t.channel}\'s official YouTube channel. This fan app '
            'never downloads or re-hosts footage.',
            style: AppText.dossier(world.muted, size: 12),
          ),
          if (others.isNotEmpty) ...[
            const SectionHeader(
              title: 'More transmissions',
              padding: EdgeInsets.fromLTRB(0, 28, 0, 12),
            ),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: others.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => SizedBox(
                  width: 210,
                  child: TrailerCard(
                    trailer: others[i],
                    onTap: () => Navigator.of(context).pushReplacement(
                      RiftPageRoute<void>(page: TrailerPlayerScreen(trailer: others[i])),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The player sits in a VCR-style bezel: neon edge and an on-screen
/// display like a tape deck from 1985.
class _VcrFrame extends StatelessWidget {
  const _VcrFrame({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final osd = AppText.label(Colors.white.withValues(alpha: 0.8)).copyWith(fontSize: 10.5);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 24)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.stRed, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text('PLAY ▶', style: osd),
                const Spacer(),
                Text('SP  ·  CH 3', style: osd),
              ],
            ),
          ),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        ],
      ),
    );
  }
}

/// A trailer as a tape-cover card: the official thumbnail (loaded from
/// YouTube alongside the embed), scanlines, and a neon play button.
/// Falls back to procedural art when offline.
class TrailerCard extends StatelessWidget {
  const TrailerCard({super.key, required this.trailer, required this.onTap});

  final Trailer trailer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final season = Seasons.all[trailer.season - 1];
    return NeonCard(
      onTap: onTap,
      glow: season.accent,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            trailer.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => KeyArt(accent: season.accent, icon: Icons.videocam, iconSize: 70),
          ),
          const CrtOverlay(opacity: 0.18, animate: false),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0xE6000000)],
              ),
            ),
          ),
          Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.4),
                border: Border.all(color: season.accent, width: 2),
                boxShadow: [BoxShadow(color: season.accent.withValues(alpha: 0.7), blurRadius: 16)],
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SEASON ${trailer.season}', style: AppText.chapter(season.accent, size: 10)),
                const SizedBox(height: 2),
                Text(
                  trailer.title,
                  style: AppText.h2(Colors.white).copyWith(fontSize: 14.5),
                  maxLines: 1,
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
