import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../data/fan_media.dart';
import '../audio/sfx.dart';
import '../platform/test_env.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../widgets/world_fx.dart';
import 'asset_media.dart';

/// A bundled clip (`assets/video/<key>.mp4`) rendered exactly where a still
/// would go. [placeholder] shows until the first frame is ready, and stays
/// for good when there's no clip, no playback (tests), motion clips are
/// switched off, or effects are reduced - so a screen can place a
/// `ClipLoop` unconditionally and fall back to its normal art.
///
/// The clip is muted, loops like a streaming billboard, mixes with whatever
/// the phone is already playing, follows the world's colour grade, and
/// pauses while another page covers its own.
class ClipLoop extends ConsumerStatefulWidget {
  const ClipLoop({
    super.key,
    required this.videoKey,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  /// Key inside assets/video (probed with .mp4/.mov/.m4v/.webm).
  final String videoKey;

  /// The art shown before the clip is ready - and instead of it when the
  /// clip can't or shouldn't play.
  final Widget placeholder;

  final BoxFit fit;
  final Alignment alignment;

  @override
  ConsumerState<ClipLoop> createState() => _ClipLoopState();
}

class _ClipLoopState extends ConsumerState<ClipLoop> {
  VideoPlayerController? _controller;
  Timer? _idle;
  bool _loading = false;
  bool _firstFrame = false;

  bool get _wanted =>
      !isFlutterTest &&
      ref.read(settingsProvider).autoplayPreviews &&
      !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ClipLoop old) {
    super.didUpdateWidget(old);
    if (old.videoKey != widget.videoKey) {
      _release();
      _sync();
    }
  }

  /// Start, play, pause or drop the clip to match what the screen wants.
  /// Start, play, pause or drop the clip. Only clips you can see load;
  /// one hidden behind another tab or page pauses, and gives its decoder
  /// back if it stays hidden.
  void _sync() {
    if (!_wanted) {
      _release();
      return;
    }
    if (!TickerMode.valuesOf(context).enabled) {
      _controller?.pause();
      _idle ??= Timer(const Duration(seconds: 2), _release);
      return;
    }
    _idle?.cancel();
    _idle = null;
    final c = _controller;
    if (c == null) {
      _load();
    } else {
      c.play();
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    final key = widget.videoKey;
    final path = await AssetMedia.video(key);
    if (path == null || !mounted || key != widget.videoKey) {
      _loading = false;
      return;
    }
    final c = VideoPlayerController.asset(
      path,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
    } catch (_) {
      // Codec or asset trouble: the placeholder simply stays.
      await c.dispose();
      _loading = false;
      return;
    }
    _loading = false;
    if (!mounted || key != widget.videoKey || !_wanted) {
      await c.dispose();
      return;
    }
    c.addListener(_onTick);
    setState(() => _controller = c);
    _sync();
  }

  void _onTick() {
    final c = _controller;
    if (!_firstFrame &&
        c != null &&
        c.value.isPlaying &&
        c.value.position > Duration.zero) {
      setState(() => _firstFrame = true);
    }
  }

  void _release() {
    _idle?.cancel();
    _idle = null;
    final c = _controller;
    if (c == null) return;
    c.removeListener(_onTick);
    _controller = null;
    _firstFrame = false;
    c.dispose();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _idle?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-sync when the "motion clips" setting changes.
    ref.listen(
      settingsProvider.select((s) => s.autoplayPreviews),
      (_, _) => _sync(),
    );
    final c = _controller;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.placeholder,
        if (c != null)
          AnimatedOpacity(
            opacity: _firstFrame ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            child: WorldGrade(
              strength: 0.85,
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
            ),
          ),
      ],
    );
  }
}

/// A fan edit playing inline, with sound - where a YouTube trailer would
/// have been. Tap to pause; the corner button goes fullscreen.
class FanCutPlayer extends StatefulWidget {
  const FanCutPlayer({super.key, required this.clip});

  final FanClip clip;

  @override
  State<FanCutPlayer> createState() => _FanCutPlayerState();
}

class _FanCutPlayerState extends State<FanCutPlayer> {
  VideoPlayerController? _c;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (isFlutterTest) return;
    final path = await AssetMedia.video(widget.clip.videoKey);
    if (path == null || !mounted) return;
    final c = VideoPlayerController.asset(path);
    try {
      await c.initialize();
    } catch (_) {
      await c.dispose();
      return;
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    c.addListener(_tick);
    setState(() => _c = c);
    await c.play();
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c?.removeListener(_tick);
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final playing = c?.value.isPlaying ?? false;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        key: const ValueKey('fan-cut'),
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (c == null) return;
          playing ? c.pause() : c.play();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Until the clip's up: its own still.
            Image.asset(
              widget.clip.thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
            ),
            if (c != null)
              ColoredBox(
                color: Colors.black,
                child: FittedBox(
                  // Phone-shot edits sit in the middle; widescreen ones fill.
                  fit: widget.clip.portrait ? BoxFit.contain : BoxFit.cover,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),
              ),
            if (c != null && !playing)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 54,
                ),
              ),
            Positioned(
              left: 8,
              top: 6,
              child: Text(
                'FAN CUT · ${widget.clip.title.toUpperCase()}',
                style: AppText.label(
                  Colors.white.withValues(alpha: 0.85),
                ).copyWith(fontSize: 9.5),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 4,
              child: IconButton(
                key: const ValueKey('fan-cut-fullscreen'),
                tooltip: 'Full screen',
                onPressed: () {
                  c?.pause();
                  ClipPlayer.play(context, [ClipItem.fan(widget.clip)]);
                },
                icon: const Icon(Icons.fullscreen, color: Colors.white),
              ),
            ),
            if (c != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  c,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.stRed,
                    bufferedColor: Color(0x55FFFFFF),
                    backgroundColor: Color(0x33FFFFFF),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One thing the fullscreen player can play.
@immutable
class ClipItem {
  const ClipItem({
    required this.videoKey,
    required this.title,
    this.subtitle,
    this.landscape = true,
  });

  ClipItem.fan(FanClip clip)
    : videoKey = clip.videoKey,
      title = clip.title,
      subtitle = clip.note == null
          ? clip.credit
          : '${clip.note} · ${clip.credit}',
      landscape = !clip.portrait;

  final String videoKey;
  final String title;
  final String? subtitle;

  /// Landscape footage offers the turn-sideways button.
  final bool landscape;
}

/// The screening room's projector: fullscreen, sound on, with a VCR-style
/// on-screen display. Controls fade away while you watch and come back
/// with a tap; landscape edits can be turned sideways to fill the screen;
/// a playlist rolls straight into the next clip; swipe down to leave.
class ClipPlayer extends StatefulWidget {
  const ClipPlayer({super.key, required this.items, this.start = 0});

  final List<ClipItem> items;
  final int start;

  /// Plays a single bundled clip.
  static Future<void> open(
    BuildContext context, {
    required String videoKey,
    required String title,
    String? subtitle,
    bool landscape = true,
  }) => play(context, [
    ClipItem(
      videoKey: videoKey,
      title: title,
      subtitle: subtitle,
      landscape: landscape,
    ),
  ]);

  /// Plays [items] from [start], rolling on to the next when one ends.
  static Future<void> play(
    BuildContext context,
    List<ClipItem> items, {
    int start = 0,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => ClipPlayer(items: items, start: start),
        // The set warms up: a fade from black with a slight zoom.
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween(
              begin: 1.04,
              end: 1.0,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  State<ClipPlayer> createState() => _ClipPlayerState();
}

class _ClipPlayerState extends State<ClipPlayer> with SoundtrackClaimMixin {
  late int _index = widget.start;
  VideoPlayerController? _controller;
  bool _missing = false;
  bool _muted = false;
  bool _controls = true;
  bool _sideways = false;
  Timer? _hide;

  ClipItem get _item => widget.items[_index];
  bool get _hasNext => _index + 1 < widget.items.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final item = _item;
    final path = isFlutterTest ? null : await AssetMedia.video(item.videoKey);
    if (!mounted || item != _item) return;
    if (path == null) {
      setState(() => _missing = true);
      return;
    }
    final c = VideoPlayerController.asset(path);
    try {
      await c.initialize();
    } catch (_) {
      await c.dispose();
      if (mounted) setState(() => _missing = true);
      return;
    }
    if (!mounted || item != _item) {
      await c.dispose();
      return;
    }
    await c.setVolume(_muted ? 0 : 1);
    // A single clip loops; a playlist moves on.
    await c.setLooping(widget.items.length == 1);
    c.addListener(_onTick);
    setState(() {
      _controller = c;
      _missing = false;
    });
    await c.play();
    _scheduleHide();
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !mounted) return;
    final v = c.value;
    final ended =
        v.isInitialized &&
        !v.isPlaying &&
        v.duration > Duration.zero &&
        v.position >= v.duration;
    if (ended && _hasNext) {
      // Not from inside the controller's own notification.
      scheduleMicrotask(() {
        if (mounted && identical(_controller, c)) _go(1);
      });
      return;
    }
    setState(() {}); // progress + play state
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.items.length || !mounted) return;
    final old = _controller;
    old?.removeListener(_onTick);
    _controller = null;
    old?.dispose();
    setState(() {
      _index = next;
      _missing = false;
      _controls = true;
    });
    _load();
  }

  void _scheduleHide() {
    _hide?.cancel();
    _hide = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _controls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controls = !_controls);
    if (_controls) _scheduleHide();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null) return;
    c.value.isPlaying ? c.pause() : c.play();
    _scheduleHide();
  }

  void _seek(int seconds) {
    final c = _controller;
    if (c == null) return;
    final to = c.value.position + Duration(seconds: seconds);
    c.seekTo(to < Duration.zero ? Duration.zero : to);
    _scheduleHide();
  }

  Future<void> _turn() async {
    final sideways = !_sideways;
    setState(() => _sideways = sideways);
    if (isFlutterTest) return;
    await SystemChrome.setPreferredOrientations(
      sideways
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [DeviceOrientation.portraitUp],
    );
    await SystemChrome.setEnabledSystemUIMode(
      sideways ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
    _scheduleHide();
  }

  @override
  void dispose() {
    _hide?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    if (_sideways && !isFlutterTest) {
      SystemChrome.setPreferredOrientations(const []);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  static String _time(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final item = _item;
    final osd = AppText.label(
      Colors.white.withValues(alpha: 0.85),
    ).copyWith(fontSize: 11);
    final playing = c?.value.isPlaying ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 500) Navigator.of(context).maybePop();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: c == null
                  ? Text(
                      _missing ? 'NO TAPE IN THE DECK' : 'TRACKING…',
                      style: AppText.headline(
                        Colors.white38,
                        size: 18,
                        letterSpacing: 0.2,
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: c.value.aspectRatio,
                      child: VideoPlayer(c),
                    ),
            ),
            // On-screen display, like a 1985 VCR.
            AnimatedOpacity(
              opacity: _controls ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !_controls,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xCC000000),
                        Color(0x00000000),
                        Color(0x00000000),
                        Color(0xE6000000),
                      ],
                      stops: [0, 0.22, 0.7, 1],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                key: const ValueKey('player-close'),
                                tooltip: 'Close',
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.headline(
                                        Colors.white,
                                        size: 17,
                                        letterSpacing: 0.06,
                                      ),
                                    ),
                                    if (item.subtitle != null)
                                      Text(
                                        item.subtitle!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppText.dossier(
                                          Colors.white60,
                                          size: 11.5,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: playing
                                      ? AppColors.stRed
                                      : Colors.white38,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(playing ? 'PLAY ▶' : 'PAUSE ❚❚', style: osd),
                              const SizedBox(width: 10),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.items.length > 1)
                                IconButton(
                                  onPressed: _index > 0 ? () => _go(-1) : null,
                                  icon: const Icon(
                                    Icons.skip_previous,
                                    size: 30,
                                  ),
                                  color: Colors.white,
                                ),
                              IconButton(
                                onPressed: () => _seek(-10),
                                icon: const Icon(Icons.replay_10, size: 32),
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                key: const ValueKey('player-play'),
                                onPressed: _togglePlay,
                                icon: Icon(
                                  playing
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  size: 64,
                                ),
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () => _seek(10),
                                icon: const Icon(Icons.forward_10, size: 32),
                                color: Colors.white,
                              ),
                              if (widget.items.length > 1)
                                IconButton(
                                  onPressed: _hasNext ? () => _go(1) : null,
                                  icon: const Icon(Icons.skip_next, size: 30),
                                  color: Colors.white,
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (c != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: VideoProgressIndicator(
                                c,
                                allowScrubbing: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                colors: const VideoProgressColors(
                                  playedColor: AppColors.stRed,
                                  bufferedColor: Color(0x55FFFFFF),
                                  backgroundColor: Color(0x33FFFFFF),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              const SizedBox(width: 12),
                              Text(
                                c == null
                                    ? '0:00'
                                    : '${_time(c.value.position)} / ${_time(c.value.duration)}',
                                style: osd,
                              ),
                              const Spacer(),
                              if (_hasNext)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    'NEXT: ${widget.items[_index + 1].title.toUpperCase()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: osd.copyWith(
                                      color: Colors.white54,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              IconButton(
                                tooltip: _muted ? 'Sound on' : 'Mute',
                                onPressed: () {
                                  setState(() => _muted = !_muted);
                                  c?.setVolume(_muted ? 0 : 1);
                                  _scheduleHide();
                                },
                                icon: Icon(
                                  _muted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                ),
                              ),
                              if (item.landscape)
                                IconButton(
                                  key: const ValueKey('player-rotate'),
                                  tooltip: _sideways
                                      ? 'Back to portrait'
                                      : 'Turn sideways',
                                  onPressed: _turn,
                                  icon: Icon(
                                    _sideways
                                        ? Icons.stay_current_portrait
                                        : Icons.screen_rotation,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
