import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sfx.dart';
import '../core/media/art.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_logo.dart';
import '../core/widgets/world_fx.dart';
import '../data/seasons.dart';
import '../models/season.dart';

/// Story mode: watch the series. Full-screen and letterboxed like the show,
/// one chapter at a time. Each season opens on its logo; each chapter's
/// title card burns in over a slowly drifting still, a date caption types
/// itself out, the synopsis runs as a subtitle, and the synth score plays
/// underneath. Tap to skip ahead (left edge to go back), hold to pause,
/// swipe down to leave.
class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({
    super.key,
    this.season,
    this.episode,
    this.onlySeason = false,
  });

  /// Where to start; null = the very beginning.
  final int? season;

  /// Chapter to start on; null = the season's title card.
  final int? episode;

  /// Stop at the end of [season] instead of carrying on through the series.
  final bool onlySeason;

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

sealed class _Slide {
  const _Slide(this.season);
  final Season season;
}

class _SeasonIntro extends _Slide {
  const _SeasonIntro(super.season);
}

class _Chapter extends _Slide {
  const _Chapter(super.season, this.episode);
  final Episode episode;
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  late final List<_Slide> _slides = [
    for (final s
        in widget.onlySeason && widget.season != null
            ? [Seasons.all[widget.season! - 1]]
            : Seasons.all) ...[
      _SeasonIntro(s),
      for (final e in s.episodes) _Chapter(s, e),
    ],
  ];

  late int _index = _startIndex();
  bool _paused = false;
  bool _showHint = true;
  final _progress = ValueNotifier<double>(0);

  int _startIndex() {
    if (widget.season == null) return 0;
    final i = _slides.indexWhere(
      (sl) =>
          sl.season.number == widget.season &&
          (widget.episode == null
              ? sl is _SeasonIntro
              : sl is _Chapter && sl.episode.number == widget.episode),
    );
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(settingsProvider).music) Score.start();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Score.stop();
    _progress.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0) return;
    if (next >= _slides.length) {
      Navigator.of(context).maybePop();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _index = next;
      _showHint = false;
      _progress.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final reduce = MediaQuery.disableAnimationsOf(context);
    final size = MediaQuery.sizeOf(context);
    final bar = size.height * 0.085; // letterbox
    final seasonSlides = [
      for (var i = 0; i < _slides.length; i++)
        if (_slides[i].season.number == slide.season.number) i,
    ];
    final watched = ref.watch(watchProgressProvider);
    final chapter = slide is _Chapter ? slide : null;
    final chapterKey = switch (chapter) {
      final c? => c.season.keyFor(c.episode),
      null => null,
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => _go(d.globalPosition.dx < size.width * 0.28 ? -1 : 1),
        onLongPressStart: (_) => setState(() => _paused = true),
        onLongPressEnd: (_) => setState(() => _paused = false),
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 400) Navigator.of(context).maybePop();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: reduce ? 250 : 1000),
              child: _SlideView(
                key: ValueKey(_index),
                index: _index,
                slide: slide,
                paused: _paused,
                letterbox: bar,
                onTick: (i, v) {
                  if (i == _index) _progress.value = v;
                },
                onDone: (i) {
                  if (i == _index) _go(1);
                },
              ),
            ),

            // Letterbox: the show is widescreen.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: bar,
              child: const ColoredBox(color: Colors.black),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bar,
              child: const ColoredBox(color: Colors.black),
            ),

            // Progress through this season, one segment per card.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 6, 0),
                  child: Column(
                    children: [
                      ValueListenableBuilder<double>(
                        valueListenable: _progress,
                        builder: (context, p, _) => Row(
                          children: [
                            for (final i in seasonSlides)
                              Expanded(
                                child: Container(
                                  height: 2.5,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: i < _index
                                        ? 1
                                        : (i == _index ? p : 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            chapter == null
                                ? 'STRANGER THINGS ${slide.season.number}'
                                : 'S${slide.season.number} · E${chapter.episode.number}',
                            style: AppText.label(
                              Colors.white70,
                            ).copyWith(fontSize: 11),
                          ),
                          const Spacer(),
                          if (_paused)
                            Text(
                              'PAUSED',
                              style: AppText.label(
                                Colors.white70,
                              ).copyWith(fontSize: 11),
                            ),
                          IconButton(
                            key: const ValueKey('story-close'),
                            tooltip: 'Close',
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Mark this chapter watched without leaving the story.
            if (chapterKey != null)
              Positioned(
                right: 16,
                bottom: bar + 14,
                child: _WatchedButton(
                  watched: watched.contains(chapterKey),
                  onTap: () => ref
                      .read(watchProgressProvider.notifier)
                      .toggle(chapterKey),
                ),
              ),

            // How to drive it, once: gone a few seconds into the first card
            // so nothing sits on screen while you watch.
            if (_showHint)
              Positioned(
                left: 0,
                right: 0,
                bottom: bar * 0.35,
                child: ValueListenableBuilder<double>(
                  valueListenable: _progress,
                  builder: (context, p, child) => AnimatedOpacity(
                    opacity: p < 0.4 ? 1 : 0,
                    duration: const Duration(milliseconds: 900),
                    child: child,
                  ),
                  child: Text(
                    'TAP FOR NEXT  ·  HOLD TO PAUSE  ·  SWIPE DOWN TO CLOSE',
                    textAlign: TextAlign.center,
                    style: AppText.label(
                      Colors.white38,
                    ).copyWith(fontSize: 9.5, letterSpacing: 1.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WatchedButton extends StatelessWidget {
  const _WatchedButton({required this.watched, required this.onTap});

  final bool watched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: watched,
      label: watched ? 'Watched' : 'Mark as watched',
      child: GestureDetector(
        key: const ValueKey('story-watched'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: watched
                ? AppColors.stRed.withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.45),
            border: Border.all(
              color: watched ? AppColors.stRed : Colors.white38,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                watched ? Icons.check : Icons.add,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                watched ? 'WATCHED' : 'MARK WATCHED',
                style: AppText.label(Colors.white).copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One card of the story, on its own clock. It reports progress and
/// completion by index, so a card still fading out can't steer the story.
class _SlideView extends StatefulWidget {
  const _SlideView({
    super.key,
    required this.index,
    required this.slide,
    required this.paused,
    required this.letterbox,
    required this.onTick,
    required this.onDone,
  });

  final int index;
  final _Slide slide;
  final bool paused;
  final double letterbox;
  final void Function(int index, double progress) onTick;
  final void Function(int index) onDone;

  @override
  State<_SlideView> createState() => _SlideViewState();
}

class _SlideViewState extends State<_SlideView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(
          vsync: this,
          duration: widget.slide is _SeasonIntro
              ? const Duration(milliseconds: 6500)
              : const Duration(seconds: 11),
        )
        ..addListener(() => widget.onTick(widget.index, _c.value))
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onDone(widget.index);
        });

  @override
  void initState() {
    super.initState();
    if (!widget.paused) _c.forward();
  }

  @override
  void didUpdateWidget(covariant _SlideView old) {
    super.didUpdateWidget(old);
    if (widget.paused != old.paused) {
      widget.paused ? _c.stop() : _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final slide = widget.slide;
        return switch (slide) {
          _SeasonIntro() => _SeasonCard(
            season: slide.season,
            t: t,
            reduce: reduce,
            letterbox: widget.letterbox,
          ),
          _Chapter() => _ChapterCard(
            season: slide.season,
            episode: slide.episode,
            t: t,
            reduce: reduce,
            letterbox: widget.letterbox,
          ),
        };
      },
    );
  }
}

/// 0..1 progress of [t] through the window [a, b].
double _span(double t, double a, double b) =>
    ((t - a) / (b - a)).clamp(0.0, 1.0);

/// A neon tube catching: buzz, dark, catch, hold.
double _ignite(double u) {
  if (u <= 0) return 0.05;
  if (u < 0.15) return 0.85;
  if (u < 0.3) return 0.1;
  if (u < 0.45) return 0.6;
  if (u < 0.55) return 0.2;
  return 0.2 + 0.8 * ((u - 0.55) / 0.45).clamp(0.0, 1.0);
}

/// The slow camera drift behind every card.
class _KenBurns extends StatelessWidget {
  const _KenBurns({
    required this.t,
    required this.reduce,
    required this.drift,
    required this.child,
  });

  final double t;
  final bool reduce;
  final double drift; // -1..1: which way the camera slides
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final k = reduce ? 0.5 : t;
    return ClipRect(
      child: Transform.translate(
        offset: Offset(drift * (k - 0.5) * 40, 0),
        child: Transform.scale(scale: 1.18 - 0.12 * k, child: child),
      ),
    );
  }
}

class _Shade extends StatelessWidget {
  const _Shade();

  @override
  Widget build(BuildContext context) {
    // Light in the middle for the title, near-black under the subtitle so
    // it reads over a bright still (the Byers' Christmas lights).
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xB3000000),
            Color(0x59000000),
            Color(0x73000000),
            Color(0xD9000000),
            Color(0xF7000000),
          ],
          stops: [0, 0.3, 0.5, 0.7, 1],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.season,
    required this.episode,
    required this.t,
    required this.reduce,
    required this.letterbox,
  });

  final Season season;
  final Episode episode;
  final double t;
  final bool reduce;
  final double letterbox;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    // Chapter titles are red in the show, in both worlds.
    final red = world.tint(AppColors.stRed);
    final fadeIn = reduce ? 1.0 : _span(t, 0, 0.07);
    final chapterGlow = reduce ? 1.0 : _ignite(_span(t, 0.04, 0.16));
    final title = reduce
        ? 1.0
        : Curves.easeOutCubic.transform(_span(t, 0.1, 0.3));
    final titleGlow = reduce ? 1.0 : _ignite(_span(t, 0.12, 0.3));

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: fadeIn,
          child: _KenBurns(
            t: t,
            reduce: reduce,
            drift: episode.number.isEven ? 1 : -1,
            child: SeasonOrEventArt(season: season, photo: episode.photo),
          ),
        ),
        const _Shade(),
        Align(
          alignment: const Alignment(0, -0.18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  episode.chapterLabel,
                  style: AppText.neon(
                    size: 17,
                    color: red,
                    glow: chapterGlow,
                    letterSpacing: 0.24,
                  ),
                ),
                const SizedBox(height: 16),
                Opacity(
                  opacity: title,
                  child: Transform.scale(
                    scale: 1.12 - 0.12 * title,
                    child: Text(
                      episode.title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppText.neon(
                        size: 36,
                        color: red,
                        glow: titleGlow,
                        letterSpacing: 0.04,
                      ).copyWith(height: 1.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: letterbox + 64,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The show's location captions, typed in the corner.
              if (t > 0.3 || reduce)
                TypewriterText(
                  '${season.setting.toUpperCase()}  ·  STRANGER THINGS ${season.number}',
                  style: AppText.dossier(
                    Colors.white.withValues(alpha: 0.75),
                    size: 12.5,
                  ),
                ),
              const SizedBox(height: 12),
              AnimatedOpacity(
                opacity: t > 0.38 || reduce ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  episode.synopsis,
                  style: AppText.body(Colors.white, size: 15.5).copyWith(
                    height: 1.5,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.season,
    required this.t,
    required this.reduce,
    required this.letterbox,
  });

  final Season season;
  final double t;
  final bool reduce;
  final double letterbox;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final red = world.tint(AppColors.stRed);
    // The title sequence in miniature: letters drift together, the bars
    // light, then the season number catches like a neon sign.
    final converge = reduce
        ? 1.0
        : Curves.easeOutCubic.transform(_span(t, 0.02, 0.45));
    final numeral = reduce ? 1.0 : _ignite(_span(t, 0.42, 0.62));
    final words = reduce ? 1.0 : _span(t, 0.6, 0.75);

    return Stack(
      fit: StackFit.expand,
      children: [
        // A bare title card like the show's: the season's colour washed
        // into black, no motif competing with the logo.
        Opacity(
          opacity: reduce ? 1 : _span(t, 0, 0.1),
          child: _KenBurns(
            t: t,
            reduce: reduce,
            drift: 1,
            child: KeyArt(accent: season.accent),
          ),
        ),
        const ColoredBox(color: Color(0x99000000)),
        // The sign lights the dark around it.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.75,
              colors: [
                red.withValues(alpha: 0.2 * converge),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 1.6 - 0.6 * converge,
                child: Opacity(
                  opacity: (0.3 + 0.7 * converge).clamp(0.0, 1.0),
                  child: STLogo(
                    size: 30,
                    spread: 1 - converge,
                    glow: 0.4 + 0.6 * converge,
                    color: red,
                  ),
                ),
              ),
              if (season.number > 1) ...[
                const SizedBox(height: 6),
                Text(
                  '${season.number}',
                  style: AppText.neon(size: 92, color: red, glow: numeral),
                ),
              ],
              const SizedBox(height: 22),
              Opacity(
                opacity: words,
                child: Column(
                  children: [
                    Text(
                      season.setting.toUpperCase(),
                      style: AppText.chapter(Colors.white70, size: 13),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        season.tagline,
                        textAlign: TextAlign.center,
                        style: AppText.h2(Colors.white).copyWith(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
