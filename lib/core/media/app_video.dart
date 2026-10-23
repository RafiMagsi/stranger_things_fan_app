import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../platform/test_env.dart';
import 'asset_media.dart';

/// A bundled clip (`assets/video/<key>.mp4`) rendered exactly where a still
/// would go: [placeholder] shows until the clip resolves and plays, and stays
/// forever if the file is absent or playback isn't available (tests, an
/// unreadable asset, a codec failure). Screens can therefore place a
/// `ClipLoop` unconditionally and simply fall back to their normal art.
///
/// The clip is muted and loops like a streaming billboard. Under reduced
/// motion it resolves to its first frame and holds still instead of playing.
class ClipLoop extends StatefulWidget {
  const ClipLoop({
    super.key,
    required this.videoKey,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.autoPlay = true,
    this.muted = true,
    this.alignment = Alignment.center,
  });

  /// Key inside assets/video (probed with .mp4/.mov/.m4v/.webm).
  final String videoKey;

  /// The art shown before the clip is ready - and instead of it, always,
  /// when no clip exists.
  final Widget placeholder;

  final BoxFit fit;
  final bool autoPlay;

  /// Muted loops never surprise; the fullscreen player unmutes on demand.
  final bool muted;
  final Alignment alignment;

  @override
  State<ClipLoop> createState() => _ClipLoopState();
}

class _ClipLoopState extends State<ClipLoop> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    if (isFlutterTest) return; // no platform views in `flutter test`
    final path = await AssetMedia.video(widget.videoKey);
    if (path == null || !mounted) return;
    try {
      final c = VideoPlayerController.asset(path);
      await c.setLooping(true);
      await c.setVolume(widget.muted ? 0 : 1);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      final reduce = MediaQuery.disableAnimationsOf(context);
      if (widget.autoPlay && !reduce) await c.play();
      setState(() {
        _controller = c;
        _ready = true;
      });
    } catch (_) {
      // Codec/asset trouble: the placeholder art simply stays.
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !_ready || _failed) return widget.placeholder;
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 450),
      child: ClipRect(
        child: FittedBox(
          fit: widget.fit,
          alignment: widget.alignment,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        ),
      ),
    );
  }
}

/// Fullscreen, sound-on playback for a bundled clip, with scrub + play/pause
/// + mute. This is where a fan chooses to watch, so nothing is silent here.
class ClipPlayer extends StatefulWidget {
  const ClipPlayer({
    super.key,
    required this.videoKey,
    required this.title,
    this.subtitle,
  });

  final String videoKey;
  final String title;
  final String? subtitle;

  /// Opens the fullscreen player for `assets/video/<videoKey>.*`.
  static Future<void> open(
    BuildContext context, {
    required String videoKey,
    required String title,
    String? subtitle,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ClipPlayer(
          videoKey: videoKey,
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }

  @override
  State<ClipPlayer> createState() => _ClipPlayerState();
}

class _ClipPlayerState extends State<ClipPlayer> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _missing = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final path = await AssetMedia.video(widget.videoKey);
    if (!mounted) return;
    if (path == null) {
      setState(() => _missing = true);
      return;
    }
    try {
      final c = VideoPlayerController.asset(path);
      await c.initialize();
      await c.setLooping(true);
      if (!mounted) {
        await c.dispose();
        return;
      }
      await c.play();
      setState(() {
        _controller = c;
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _missing = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(fontSize: 16, letterSpacing: 0.4)),
            if (widget.subtitle != null)
              Text(
                widget.subtitle!,
                style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.6)),
              ),
          ],
        ),
      ),
      body: c == null || !_ready
          ? Center(
              child: Text(
                _missing ? 'No clip bundled for this one yet.'
                         : 'Warming up the projector…',
                style: const TextStyle(color: Colors.white54),
              ),
            )
          : Center(
              child: AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(c),
                    _TapToToggle(controller: c),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        children: [
                          VideoProgressIndicator(
                            c,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Color(0xFFE50914),
                              bufferedColor: Color(0x66FFFFFF),
                              backgroundColor: Color(0x33FFFFFF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => setState(() {
                                  _muted = !_muted;
                                  c.setVolume(_muted ? 0 : 1);
                                }),
                                icon: Icon(
                                  _muted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() {
                                  c.value.isPlaying ? c.pause() : c.play();
                                }),
                                icon: Icon(
                                  c.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() {}),
                                icon: Icon(
                                  Icons.loop,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
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

class _TapToToggle extends StatelessWidget {
  const _TapToToggle({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.value.isPlaying
          ? controller.pause()
          : controller.play(),
    );
  }
}
