import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/poster_image.dart';
import '../core/state/app_state.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/particles.dart';
import '../models/character.dart';

/// Full dossier for a character: hero header, animated radar chart, skill
/// chips, and a typewriter-voiced "field report" quote.
class CharacterDetailScreen extends ConsumerStatefulWidget {
  const CharacterDetailScreen({super.key, required this.character});

  final Character character;

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final scheme = Theme.of(context).colorScheme;
    final upsideDown = ref.watch(worldModeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header.
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: const _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Drop-in still if bundled, else the procedural gradient.
                  PosterImage(
                    assetKey: 'char_${c.id}',
                    fallback: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            c.accent,
                            c.accentDeep,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                  // Scrim so the name stays legible over any still.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
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
                  // Big soft icon, upper right.
                  Positioned(
                    top: 30,
                    right: -10,
                    child: Opacity(
                      opacity: 0.18,
                      child: Icon(c.icon, size: 220, color: Colors.white),
                    ),
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
                          style: AppText.h1(Colors.white).copyWith(
                            fontSize: 36,
                            letterSpacing: 0.8,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            GlowBadge(
                              text: c.alias,
                              color: Colors.white70,
                              icon: c.isCreature ? Icons.warning : Icons.person,
                            ),
                            const SizedBox(width: 8),
                            GlowBadge(
                              text: c.seasonLabel,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        if (c.actor != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'played by ${c.actor}',
                            style: AppText.body(
                              Colors.white.withValues(alpha: 0.75),
                              size: 12.5,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tagline.
                  Text(
                    c.tagline,
                    style: AppText.h2(scheme.onSurface).copyWith(fontSize: 19),
                  ),
                  const SizedBox(height: 12),
                  // Bio.
                  Text(c.bio, style: AppText.body(scheme.onSurface, size: 14.5)),
                  const SizedBox(height: 24),

                  // Radar chart.
                  const SectionHeader(title: 'Field Stats'),
                  Center(
                    child: SizedBox(
                      height: 260,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => _StatsRadar(
                          stats: c.stats,
                          progress: Curves.easeOutCubic.transform(
                            _controller.value,
                          ),
                          color: c.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Skills.
                  const SectionHeader(title: 'Known For'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in c.skills)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: c.accent.withValues(alpha: 0.14),
                            border: Border.all(
                              color: c.accent.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Text(s, style: AppText.body(scheme.onSurface, size: 13)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Field report quote (typewriter).
                  GlassCard(
                    glow: c.accent,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FIELD REPORT',
                          style: AppText.label(
                            scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              height: 44,
                              decoration: BoxDecoration(
                                color: c.accent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '"${c.line}"',
                                style: AppText.dossier(
                                  scheme.onSurface.withValues(alpha: 0.85),
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.35),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
    return CustomPaint(
      painter: _RadarPainter(
        stats: stats,
        progress: progress,
        color: color,
        gridColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
        labelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
      canvas.drawCircle(
        p,
        4,
        Paint()..color = color,
      );

      // Label outside.
      final lp = center + Offset(math.cos(a), math.sin(a)) * (radius + 16);
      final tp = TextPainter(
        text: TextSpan(
          text: '${_labels[i]} ${values[i].toInt()}',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 10,
            fontWeight: FontWeight.w700,
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
