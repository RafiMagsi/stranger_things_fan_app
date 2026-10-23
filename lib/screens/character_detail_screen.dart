import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sfx.dart';
import '../core/media/app_video.dart';
import '../core/media/art.dart';
import '../core/media/asset_media.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/monster_fx.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/particles.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/world_fx.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_toggle.dart';
import '../data/credits.dart';
import '../data/fan_media.dart';
import '../models/character.dart';

/// Full Hawkins Lab dossier for a character: the portrait flies in from
/// the card that opened it, stamped CLASSIFIED; then the file — profile,
/// animated stats radar, what they're known for, and a field-report quote.
class CharacterDetailScreen extends ConsumerStatefulWidget {
  const CharacterDetailScreen({
    super.key,
    required this.character,
    this.heroTag,
  });

  final Character character;

  /// Matches the card this dossier was opened from, so the art flies in.
  final String? heroTag;

  @override
  ConsumerState<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  // Some files announce themselves: Vecna's clock, a creature's cry.
  static const _openingCue = {
    'vecna': 'audio/clock.wav',
    'demogorgon': 'audio/screech.wav',
    'mind_flayer': 'audio/heartbeat.wav',
  };

  // The night each season's tape starts rolling.
  static final _tapeStart = {
    1: DateTime(1983, 11, 6, 21, 14),
    2: DateTime(1984, 10, 31, 19, 2),
    3: DateTime(1985, 7, 4, 20, 41),
    4: DateTime(1986, 3, 21, 22, 9),
    5: DateTime(1987, 11, 6, 23, 47),
  };

  @override
  void initState() {
    super.initState();
    final cue = _openingCue[widget.character.id];
    if (cue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Sfx.cue(ref, cue, volume: 0.6);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final world = WorldPalette.of(context);
    final upsideDown = ref.watch(worldModeProvider);
    final photo = MediaCredits.castPhoto(c.id);
    final credit = photo == null ? null : MediaCredits.forAsset(photo);
    // The portrait — or the captured footage of them, when a clip of this
    // character is bundled (it loops silently under the dossier chrome).
    final art = ClipLoop(
      videoKey: 'char_${c.id}',
      placeholder: CharacterArt(character: c, iconSize: 220),
    );
    // The character's colour, as it looks in the current world.
    final accent = world.tint(c.accent);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WorldAtmosphere(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                backgroundColor: world.bg,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: const NeonBackButton(),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Center(child: WorldToggle(compact: true)),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.heroTag == null
                          ? art
                          : STHero(
                              tag: widget.heroTag!,
                              radius: 24,
                              child: art,
                            ),
                      // Scrim so the name stays legible over any still.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x66000000),
                              Color(0x00000000),
                              Color(0xF2000000),
                            ],
                            stops: [0, 0.35, 1],
                          ),
                        ),
                      ),
                      // When an edit of them is bundled, offer it with sound.
                      if (FanMedia.clip(FanMedia.characterReel[c.id] ?? '')
                          case final reel?)
                        Positioned(
                          top: 56,
                          right: 14,
                          child: FutureBuilder<bool>(
                            future: AssetMedia.hasVideo(reel.videoKey),
                            builder: (context, snap) => snap.data != true
                                ? const SizedBox.shrink()
                                : _WatchChip(
                                    accent: accent,
                                    onTap: () => ClipPlayer.play(context, [
                                      ClipItem.fan(reel),
                                    ]),
                                  ),
                          ),
                        ),
                      // The dossier's subject, observed: creatures animate
                      // in both worlds (the file always shows it alive).
                      if (c.isCreature)
                        Positioned.fill(
                          child: MonsterFx(
                            monsterId: c.id,
                            accent: c.accent,
                            intensity: 1.1,
                          ),
                        ),
                      // Vecna gets the room: clock, rain, gold light, door.
                      if (c.id == 'vecna')
                        Positioned.fill(
                          child: VecnaScene(accent: c.accent, story: false),
                        ),
                      if (c.isCreature && upsideDown)
                        ParticleField(
                          color: c.accent,
                          glowColor: c.accent,
                          count: 26,
                          baseRadius: 1.1,
                          speed: 0.8,
                          opacity: 0.9,
                        ),
                      const CrtOverlay(opacity: 0.12, animate: false),
                      // Observed, not just read: the lab's camera on them.
                      SurveillanceOverlay(
                        // Stable per character (String.hashCode isn't).
                        camera:
                            'CAM ${(c.id.codeUnits.fold(0, (a, b) => a + b) % 8 + 1).toString().padLeft(2, '0')} · HAWKINS NATIONAL LABORATORY',
                        subject: c.isCreature
                            ? 'SPECIMEN'
                            : 'SUBJECT ${c.name.toUpperCase()}',
                        since:
                            _tapeStart[c.seasons.first] ??
                            DateTime(1983, 11, 6),
                        topInset: MediaQuery.paddingOf(context).top + 60,
                      ),
                      // Beside the name, clear of the face.
                      Positioned(
                        bottom: 126,
                        right: 16,
                        child: _ClassifiedStamp(creature: c.isCreature),
                      ),
                      // Name block, bottom left.
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name.toUpperCase(),
                              style: AppText.h1(Colors.white, heavy: true)
                                  .copyWith(
                                    fontSize: 40,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(color: accent, blurRadius: 22),
                                    ],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                GlowBadge(
                                  text: c.alias,
                                  color: Colors.white70,
                                  icon: c.isCreature
                                      ? Icons.warning
                                      : Icons.person,
                                ),
                                GlowBadge(text: c.seasonLabel, color: c.accent),
                              ],
                            ),
                            if (c.actor != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'played by ${c.actor}',
                                style: AppText.dossier(
                                  Colors.white.withValues(alpha: 0.8),
                                  size: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: FlickerIn(
                    child: NeonCard(
                      glow: c.accent,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.role == null
                                ? 'SUBJECT FILE'
                                : 'SUBJECT FILE · ${c.role!.toUpperCase()}',
                            style: AppText.chapter(accent, size: 11),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            c.tagline,
                            style: AppText.h2(world.ink).copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            c.bio,
                            style: AppText.body(
                              world.ink.withValues(alpha: 0.85),
                              size: 14.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Field Stats'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FlickerIn(
                    index: 1,
                    child: NeonCard(
                      glow: c.accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          height: 260,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) => _StatsRadar(
                              stats: c.stats,
                              progress: Curves.easeOutCubic.transform(
                                _controller.value,
                              ),
                              color: accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Known For'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in c.skills)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: accent.withValues(alpha: 0.12),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.18),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            s,
                            style: AppText.body(world.ink, size: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Field report quote (typewriter).
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: NeonCard(
                    glow: c.accent,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FIELD REPORT', style: AppText.label(world.muted)),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 44,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(color: accent, blurRadius: 8),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TypewriterText(
                                '"${c.line}"',
                                delay: const Duration(milliseconds: 700),
                                style: AppText.dossier(
                                  world.ink.withValues(alpha: 0.9),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
                  child: FutureBuilder<bool>(
                    // A fan still or loop of them outranks the portrait.
                    future: AssetMedia.hasImage('char_${c.id}'),
                    builder: (context, snap) {
                      final fan = snap.data == true
                          ? FanMedia.sourceLine('char_${c.id}')
                          : null;
                      final line = fan != null
                          ? 'Footage: $fan. Personal fan-media pack.'
                          : credit == null
                          ? null
                          : 'Portrait: ${credit.subject} by ${credit.author}, ${credit.license}, '
                                'via Wikimedia Commons. Colour-graded for the app.';
                      if (line == null) return const SizedBox.shrink();
                      return Text(
                        line,
                        style: AppText.body(
                          world.muted.withValues(alpha: 0.8),
                          size: 11,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The red rubber stamp on every Hawkins Lab file.
class _ClassifiedStamp extends StatelessWidget {
  const _ClassifiedStamp({required this.creature});

  final bool creature;

  @override
  Widget build(BuildContext context) {
    const red = AppColors.stRed;
    return Transform.rotate(
      angle: -0.2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: red.withValues(alpha: 0.85), width: 2.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          creature ? 'HOSTILE' : 'CLASSIFIED',
          style: AppText.dossier(
            red.withValues(alpha: 0.9),
            size: 15,
          ).copyWith(letterSpacing: 3, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Animated hexagonal radar chart.
class _StatsRadar extends StatelessWidget {
  const _StatsRadar({
    required this.stats,
    required this.progress,
    required this.color,
  });

  final CharacterStats stats;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return CustomPaint(
      painter: _RadarPainter(
        stats: stats,
        progress: progress,
        color: color,
        gridColor: world.ink.withValues(alpha: 0.15),
        labelColor: world.ink.withValues(alpha: 0.7),
      ),
      size: const Size(260, 260),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.stats,
    required this.progress,
    required this.color,
    required this.gridColor,
    required this.labelColor,
  });

  final CharacterStats stats;
  final double progress;
  final Color color;
  final Color gridColor;
  final Color labelColor;

  static const _labels = ['PWR', 'CRG', 'INT', 'HRT', 'LCK', 'STL'];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 26;
    const n = 6;

    // Grid hexagons at 4 levels.
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gridColor;

    for (var level = 1; level <= 4; level++) {
      final r = radius * level / 4;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final a = -math.pi / 2 + (i / n) * math.pi * 2;
        final p = center + Offset(math.cos(a), math.sin(a)) * r;
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Axis spokes.
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + (i / n) * math.pi * 2;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius;
      canvas.drawLine(center, p, gridPaint);
    }

    // Data hexagon, animated by progress.
    final values = stats.axes;
    final dataPath = Path();
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + (i / n) * math.pi * 2;
      final v = (values[i] / 10) * progress;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius * v;
      if (i == 0) {
        dataPath.moveTo(p.dx, p.dy);
      } else {
        dataPath.lineTo(p.dx, p.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: 0.28),
    );
    // Neon edge: glow, then the tube.
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color,
    );

    // Vertex dots + labels.
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + (i / n) * math.pi * 2;
      final v = (values[i] / 10) * progress;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius * v;
      canvas.drawCircle(p, 4, Paint()..color = color);

      // Label outside.
      final lp = center + Offset(math.cos(a), math.sin(a)) * (radius + 16);
      final tp = TextPainter(
        text: TextSpan(
          text: '${_labels[i]} ${values[i].toInt()}',
          style: TextStyle(
            fontFamily: AppText.ui,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            fontVariations: const [FontVariation('wght', 700)],
            color: labelColor,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, lp - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.progress != progress || old.color != color;
}

/// "WATCH" over the dossier header: the edit of this character, with sound.
class _WatchChip extends StatelessWidget {
  const _WatchChip({required this.accent, required this.onTap});

  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Watch footage',
      child: GestureDetector(
        key: const ValueKey('dossier-watch'),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 12),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_arrow, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                'WATCH',
                style: AppText.label(Colors.white).copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
