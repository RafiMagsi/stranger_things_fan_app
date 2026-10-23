import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../core/media/youtube_embed.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
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
  late YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _sub;
  Timer? _deadline;
  TrailerFailure? _failure;
  YoutubeError _error = YoutubeError.none;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailer.youtubeId,
      autoPlay: true,
      params: YoutubeEmbed.identify(
        const YoutubePlayerParams(
          showFullscreenButton: true,
          strictRelatedVideos: true,
        ),
      ),
    );
    _sub = _controller.stream.listen((v) {
      // Any state at all means the player loaded.
      if (v.playerState != PlayerState.unknown) _deadline?.cancel();
      final failure = TrailerFailure.fromError(v.error);
      if (failure != null && _failure == null && mounted) {
        setState(() {
          _failure = failure;
          _error = v.error;
        });
      }
    });
    // An IFrame API that never answers means YouTube is out of reach.
    _deadline = Timer(const Duration(seconds: 15), () {
      if (mounted && _failure == null) {
        setState(() => _failure = TrailerFailure.unreachable);
      }
    });
  }

  void _disconnect() {
    _deadline?.cancel();
    _sub?.cancel();
    _controller.close();
  }

  void _retry() {
    _disconnect();
    setState(() {
      _failure = null;
      _error = YoutubeError.none;
      _attempt++;
      _connect();
    });
  }

  @override
  void dispose() {
    _disconnect();
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
    final accent = world.tint(season.accent);
    final others = [
      for (final s in Seasons.all)
        ...s.trailers.where((o) => o.youtubeId != t.youtubeId),
    ];

    return STScaffold(
      title: 'TRANSMISSION',
      subtitle: 'Season ${t.season} · ${t.title}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _VcrFrame(
            accent: accent,
            child: switch (_failure) {
              null => YoutubePlayer(
                key: ValueKey(_attempt),
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
              final failure => TrailerUnavailable(
                failure: failure,
                errorCode: _error == YoutubeError.none ? null : _error.code,
                accent: accent,
                onWatchOnYouTube: _openInYouTube,
                onRetry: failure == TrailerFailure.unreachable ? _retry : null,
              ),
            },
          ),
          const SizedBox(height: 18),
          Text(
            'STRANGER THINGS ${t.season}',
            style: AppText.chapter(accent, size: 12),
          ),
          const SizedBox(height: 6),
          Text(t.title, style: AppText.h1(world.ink).copyWith(fontSize: 26)),
          const SizedBox(height: 10),
          Row(
            children: [
              GlowBadge(
                text: 'Official · ${t.channel}',
                color: AppColors.safeGreen,
                icon: Icons.verified,
              ),
              const SizedBox(width: 8),
              GlowBadge(text: season.setting, color: world.muted),
            ],
          ),
          // The dead-channel panel already offers YouTube when it's showing.
          if (_failure == null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openInYouTube,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('OPEN IN YOUTUBE'),
            ),
          ],
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
                      RiftPageRoute<void>(
                        page: TrailerPlayerScreen(trailer: others[i]),
                      ),
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

/// What sits in the VCR when YouTube won't play: a dead channel saying why,
/// and the way out. A refused embed still plays in the YouTube app, so that
/// is the first thing offered.
class TrailerUnavailable extends StatelessWidget {
  const TrailerUnavailable({
    super.key,
    required this.failure,
    required this.accent,
    required this.onWatchOnYouTube,
    this.errorCode,
    this.onRetry,
  });

  final TrailerFailure failure;
  final Color accent;
  final VoidCallback onWatchOnYouTube;

  /// YouTube's own error number, shown small for anyone reporting it.
  final int? errorCode;

  /// Offered only when trying again could help (offline).
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final code = errorCode;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          const CrtOverlay(opacity: 0.3),
          Padding(
            padding: const EdgeInsets.all(14),
            // Small phones: shrink the panel rather than overflow the frame.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tv_off, color: accent, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      failure.title,
                      textAlign: TextAlign.center,
                      style: AppText.neon(size: 20, color: accent),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      code == null
                          ? failure.message
                          : '${failure.message}  (error $code)',
                      textAlign: TextAlign.center,
                      style: AppText.body(Colors.white70, size: 12.5),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          key: const ValueKey('trailer-watch-on-youtube'),
                          onPressed: onWatchOnYouTube,
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('WATCH ON YOUTUBE'),
                        ),
                        if (onRetry != null)
                          OutlinedButton(
                            key: const ValueKey('trailer-retry'),
                            onPressed: onRetry,
                            child: const Text('TRY AGAIN'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
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
    final osd = AppText.label(
      Colors.white.withValues(alpha: 0.8),
    ).copyWith(fontSize: 10.5);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 24),
        ],
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
                  decoration: const BoxDecoration(
                    color: AppColors.stRed,
                    shape: BoxShape.circle,
                  ),
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
    final accent = WorldPalette.of(context).tint(season.accent);
    return NeonCard(
      onTap: onTap,
      glow: season.accent,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The official thumbnail, graded into the world's light.
          WorldGrade(
            child: Image.network(
              trailer.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => KeyArt(
                accent: season.accent,
                icon: Icons.videocam,
                iconSize: 70,
              ),
            ),
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
                border: Border.all(color: accent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.7),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEASON ${trailer.season}',
                  style: AppText.chapter(accent, size: 10),
                ),
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
