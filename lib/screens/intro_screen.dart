import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../core/audio/sfx.dart';
import '../core/media/asset_media.dart';
import '../core/platform/test_env.dart';
import '../core/state/app_state.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/rift_route.dart';
import 'main_shell.dart';
import 'splash_screen.dart';

/// The opening titles: the show's Season 1 credits, full screen, with the
/// theme - and SKIP INTRO in the corner, the way Netflix does it. When they
/// end (or you skip) the Gate opens onto Hawkins and the music carries on.
///
/// With Opening titles off, in tests, or if the clip can't play, the
/// rebuilt five-second title sequence ([SplashScreen]) runs instead.
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _c;
  Timer? _start;
  Timer? _skipTimer;
  SoundtrackClaim? _quiet;
  bool _skip = false;
  bool _left = false;

  /// Showing the rebuilt title sequence in place of the clip.
  bool _sequence = isFlutterTest;

  // Made up front: created lazily, a test's first touch would be in
  // dispose(), after the element has left the tree.
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (_sequence) return;
    // A beat for saved settings to load, so "off" stays off.
    _start = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      if (ref.read(settingsProvider).openingTitles) {
        _load();
      } else {
        _toTitleSequence();
      }
    });
  }

  Future<void> _load() async {
    final path = await AssetMedia.video('intro');
    if (path == null || !mounted) return _toTitleSequence();
    final c = VideoPlayerController.asset(path);
    try {
      await c.initialize().timeout(const Duration(seconds: 5));
    } catch (_) {
      await c.dispose();
      return _toTitleSequence();
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    // The clip carries the theme itself.
    _quiet = Soundtrack.claim(null);
    c.addListener(_onTick);
    setState(() => _c = c);
    _fade.forward();
    await c.play();
    _skipTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _skip = true);
    });
  }

  void _onTick() {
    final v = _c?.value;
    if (v == null || !v.isInitialized) return;
    if (v.duration > Duration.zero &&
        v.position >= v.duration - const Duration(milliseconds: 150)) {
      _enterHawkins();
    }
  }

  /// Titles over (or skipped): fade the theme and open the Gate.
  Future<void> _enterHawkins() async {
    if (_left || !mounted) return;
    _left = true;
    final c = _c;
    if (c != null && c.value.isPlaying) {
      for (var i = 9; i >= 0; i--) {
        await c.setVolume(i / 10);
        await Future<void>.delayed(const Duration(milliseconds: 45));
      }
      await c.pause();
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      RiftPageRoute<void>(page: const MainShell(), name: '/home'),
    );
  }

  /// The rebuilt sequence, right here; it opens the Gate itself.
  void _toTitleSequence() {
    if (_left || !mounted) return;
    setState(() => _sequence = true);
  }

  @override
  void dispose() {
    _start?.cancel();
    _skipTimer?.cancel();
    _fade.dispose();
    _c?.removeListener(_onTick);
    _c?.dispose();
    final q = _quiet;
    if (q != null) Soundtrack.release(q);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sequence) return const SplashScreen();
    final c = _c;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (c != null)
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: AspectRatio(
                  aspectRatio: c.value.aspectRatio,
                  child: VideoPlayer(c),
                ),
              ),
            ),
          // SKIP INTRO, bottom right, like the real thing.
          Positioned(
            right: 20,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: AnimatedOpacity(
                  opacity: _skip ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: IgnorePointer(
                    ignoring: !_skip,
                    child: OutlinedButton(
                      key: const ValueKey('skip-intro'),
                      onPressed: _enterHawkins,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black.withValues(alpha: 0.35),
                        side: const BorderSide(
                          color: Colors.white70,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'SKIP INTRO',
                        style: AppText.headline(
                          Colors.white,
                          size: 14,
                          letterSpacing: 0.12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
