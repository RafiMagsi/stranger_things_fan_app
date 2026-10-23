import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../models/trailer.dart';
import '../platform/test_env.dart';
import 'youtube_embed.dart';

/// An official trailer playing silently behind the home banner - the
/// billboard of a streaming service. Fades in only once the video is really
/// playing, so offline it simply never appears and the key art stays.
/// Pauses while its screen is covered by another page, loops at the end,
/// and stays off in tests, under reduced effects, or when [enabled] is
/// false.
class TrailerBillboard extends StatefulWidget {
  const TrailerBillboard({
    super.key,
    required this.trailer,
    required this.enabled,
  });

  final Trailer trailer;
  final bool enabled;

  @override
  State<TrailerBillboard> createState() => _TrailerBillboardState();
}

class _TrailerBillboardState extends State<TrailerBillboard> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _sub;
  Timer? _deadline;
  bool _playing = false;

  // YouTube refused or never answered: the key art stays, and no hidden
  // player keeps asking.
  bool _failed = false;

  bool get _wanted =>
      !_failed &&
      widget.enabled &&
      !isFlutterTest &&
      !MediaQuery.disableAnimationsOf(context) &&
      // False while another route covers this one.
      TickerMode.valuesOf(context).enabled;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant TrailerBillboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final c = _controller;
    if (_wanted) {
      if (c == null) {
        _start();
      } else {
        c.playVideo();
      }
    } else if (c != null) {
      if (!widget.enabled) {
        _stop();
      } else {
        c.pauseVideo();
      }
    }
  }

  void _start() {
    final c = YoutubePlayerController.fromVideoId(
      videoId: widget.trailer.youtubeId,
      autoPlay: true,
      params: YoutubeEmbed.identify(
        const YoutubePlayerParams(
          mute: true,
          showControls: false,
          showFullscreenButton: false,
          enableCaption: false,
          showVideoAnnotations: false,
          strictRelatedVideos: true,
          playsInline: true,
          pointerEvents: PointerEvents.none,
        ),
      ),
    );
    // An IFrame API that never answers means YouTube is out of reach.
    _deadline = Timer(const Duration(seconds: 20), _fail);
    _sub = c.stream.listen((v) {
      if (v.playerState != PlayerState.unknown) _deadline?.cancel();
      if (v.error != YoutubeError.none) {
        // Not from inside the player's own event.
        scheduleMicrotask(_fail);
        return;
      }
      if (v.playerState == PlayerState.ended) {
        c.seekTo(seconds: 0, allowSeekAhead: true);
        c.playVideo();
      }
      final playing = v.playerState == PlayerState.playing;
      if (playing != _playing && mounted) setState(() => _playing = playing);
    });
    setState(() => _controller = c);
  }

  void _stop() {
    _deadline?.cancel();
    _sub?.cancel();
    _sub = null;
    _controller?.close();
    setState(() {
      _controller = null;
      _playing = false;
    });
  }

  void _fail() {
    if (!mounted || _failed) return;
    _failed = true;
    if (_controller != null) _stop();
  }

  @override
  void dispose() {
    _deadline?.cancel();
    _sub?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _playing ? 1 : 0,
        duration: const Duration(milliseconds: 1400),
        child: ClipRect(
          // Cover the banner like a background video: crop, don't letterbox.
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: 640,
              height: 360,
              child: YoutubePlayer(
                controller: c,
                aspectRatio: 16 / 9,
                enableFullScreenOnVerticalDrag: false,
                autoFullScreen: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
