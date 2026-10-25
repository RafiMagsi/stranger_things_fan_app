import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sfx.dart';
import '../core/media/app_video.dart';
import '../core/media/poster_image.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
import '../core/widgets/world_toggle.dart';
import '../data/characters.dart' as cast_data;
import '../data/gateways.dart';
import '../data/seasons.dart';
import 'bestiary_screen.dart';
import 'character_detail_screen.dart';
import 'gate_screen.dart';
import 'locations_screen.dart';
import 'season_detail_screen.dart';

/// The other side, as a place to visit: a portal over live red lightning,
/// the creatures and places of the Upside Down, every gate the series ever
/// opened, and how to make it back.
class UpsideDownScreen extends ConsumerWidget {
  const UpsideDownScreen({super.key});

  /// Turns the whole app over, exactly like the world toggle.
  static void crossOver(BuildContext context, WidgetRef ref) {
    final shell = WorldFlipScope.maybeOf(context);
    if (shell != null) {
      shell.onFlip();
    } else {
      final intoUpsideDown = !ref.read(worldModeProvider);
      ref.read(worldModeProvider.notifier).toggle();
      Sfx.cue(ref, Sfx.crossing(intoUpsideDown: intoUpsideDown), volume: 1);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = WorldPalette.of(context);
    final inside = ref.watch(worldModeProvider);
    final shield = ref.watch(settingsProvider).spoilerShield;
    final watched = ref.watch(watchProgressProvider);
    void open(Widget page, String name) =>
        RiftPageRoute.push(context, page, name: name);

    return STScaffold(
      title: 'THE UPSIDE DOWN',
      subtitle: 'The other side · always watching',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: FlickerIn(
              child: _PortalHero(
                inside: inside,
                onEnter: () => open(const GateScreen(), '/gate'),
                onCross: () => crossOver(context, ref),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _HubButton(
                    icon: Icons.filter_vintage,
                    title: 'CREATURES',
                    body: 'Meet what hunts',
                    onTap: () => open(const BestiaryScreen(), '/bestiary'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HubButton(
                    icon: Icons.map,
                    title: 'LOCATIONS',
                    body: 'The town, inverted',
                    onTap: () => open(const LocationsScreen(), '/locations'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HubButton(
                    icon: Icons.hub,
                    title: 'HIVE MIND',
                    body: 'One will, many bodies',
                    onTap: () => open(
                      CharacterDetailScreen(
                        character: cast_data.Cast.mindFlayer,
                      ),
                      '/character/mind_flayer',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SectionHeader(title: 'A Mirror World'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _MirrorCard(),
          ),

          SectionHeader(
            title: 'Active Gateways',
            trailing: Text(
              '${Gateways.all.where((g) => g.status == GateStatus.open).length} OPEN',
              style: AppText.label(
                world.tint(AppColors.stRed),
              ).copyWith(fontSize: 11),
            ),
          ),
          for (final (i, g) in Gateways.all.indexed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: FlickerIn(
                index: i,
                child: _GatewayCard(
                  gate: g,
                  hidden:
                      shield && Seasons.isAhead(g.season, g.episode, watched),
                  onTap: () => open(
                    SeasonDetailScreen(
                      season: Seasons.all[g.season - 1],
                      focusEpisode: g.episode,
                    ),
                    '/season/${g.season}',
                  ),
                ),
              ),
            ),

          const SectionHeader(title: 'Survival Tips'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _SurvivalCard(),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: OutlinedButton.icon(
              key: const ValueKey('ud-cross'),
              onPressed: () => crossOver(context, ref),
              icon: Icon(
                inside ? Icons.wb_sunny_outlined : Icons.flip,
                size: 18,
              ),
              label: Text(inside ? 'RETURN TO HAWKINS' : 'CROSS OVER'),
              style: OutlinedButton.styleFrom(
                foregroundColor: world.ink,
                side: BorderSide(color: world.accent.withValues(alpha: 0.7)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "You are entering the Upside Down": the red sky over the mirror town,
/// a portal breathing in the corner, and the two ways through.
class _PortalHero extends StatelessWidget {
  const _PortalHero({
    required this.inside,
    required this.onEnter,
    required this.onCross,
  });

  final bool inside;
  final VoidCallback onEnter;
  final VoidCallback onCross;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final red = world.tint(AppColors.stRed);
    return NeonCard(
      onTap: onEnter,
      padding: EdgeInsets.zero,
      borderRadius: 22,
      glow: AppColors.stRed,
      child: SizedBox(
        height: 330,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipLoop(
              videoKey: 'ud_lightning',
              placeholder: PosterImage(
                assetKey: 'bg_upside',
                fallback: const ColoredBox(color: Color(0xFF12030A)),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x1A000000),
                    Color(0x59000000),
                    Color(0xF0000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            Positioned(
              top: 18,
              right: 16,
              width: 120,
              height: 120,
              child: PortalRing(color: red),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inside ? 'YOU ARE NOW IN' : 'YOU ARE ENTERING',
                    style: AppText.headline(
                      Colors.white,
                      size: 15,
                      weight: 500,
                      letterSpacing: 0.14,
                    ),
                  ),
                  Text(
                    'THE UPSIDE DOWN',
                    style:
                        AppText.headline(
                          Colors.white,
                          size: 34,
                          weight: 700,
                          letterSpacing: 0.04,
                        ).copyWith(
                          shadows: [
                            Shadow(
                              color: red.withValues(alpha: 0.8),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    inside
                        ? 'Reality flipped. The world here is alive - and it\'s watching.'
                        : 'A dimension colder. Darker. Alive.',
                    style: AppText.body(
                      Colors.white.withValues(alpha: 0.82),
                      size: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        key: const ValueKey('ud-enter-gate'),
                        onPressed: onEnter,
                        icon: const Icon(Icons.blur_circular, size: 18),
                        label: const Text('ENTER THE GATE'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.stRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: onCross,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: Text(inside ? 'GO HOME' : 'CROSS OVER'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A slowly breathing ring of the other side's light - the portal glyph.
class PortalRing extends StatefulWidget {
  const PortalRing({super.key, required this.color});

  final Color color;

  @override
  State<PortalRing> createState() => _PortalRingState();
}

class _PortalRingState extends State<PortalRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _RingPainter(t: _c.value, color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    // The dark eye in the middle.
    canvas.drawCircle(
      c,
      r * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black,
            color.withValues(alpha: 0.25),
            Colors.transparent,
          ],
          stops: const [0.3, 0.8, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.55)),
    );
    // Wobbling rings, each turning at its own pace.
    for (var i = 0; i < 4; i++) {
      final phase = t * math.pi * 2 * (i.isEven ? 1 : -1) + i;
      final path = Path();
      for (var k = 0; k <= 72; k++) {
        final a = k / 72 * math.pi * 2;
        final wobble =
            1 +
            0.06 * math.sin(a * 5 + phase) +
            0.03 * math.sin(a * 9 - phase * 2);
        final rr = r * (0.42 + i * 0.14) * wobble;
        final p = c + Offset(math.cos(a), math.sin(a)) * rr;
        k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      final alpha =
          (0.85 - i * 0.18) * (0.75 + 0.25 * math.sin(t * math.pi * 2 + i));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4 - i * 0.4
          ..color = color.withValues(alpha: alpha * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = Color.lerp(
            color,
            Colors.white,
            0.3,
          )!.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => o.t != t || o.color != color;
}

class _HubButton extends StatelessWidget {
  const _HubButton({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final red = world.tint(AppColors.stRed);
    return NeonCard(
      onTap: onTap,
      glow: AppColors.stRed,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: red.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(color: red.withValues(alpha: 0.35), blurRadius: 12),
              ],
            ),
            child: Icon(icon, color: red, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            style: AppText.headline(world.ink, size: 13, letterSpacing: 0.08),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppText.body(world.muted, size: 10.5).copyWith(height: 1.25),
          ),
        ],
      ),
    );
  }
}

/// The two Hawkinses, one above the other, and what's different down there.
class _MirrorCard extends StatelessWidget {
  const _MirrorCard();

  static const _facts = [
    (
      Icons.coronavirus_outlined,
      'INFECTED',
      'Vines on every wall, spores in the air, no light but lightning.',
    ),
    (
      Icons.hub_outlined,
      'HIVE MIND',
      'Every creature is wired to one will - the Mind Flayer\'s, and behind it, Vecna\'s.',
    ),
    (
      Icons.hourglass_empty,
      'FROZEN',
      'It\'s stuck on November 6, 1983: the night Will vanished.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final red = world.tint(AppColors.stRed);
    return NeonCard(
      padding: EdgeInsets.zero,
      glow: AppColors.stRed,
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PosterImage(
                  assetKey: 'bg_upside',
                  alignment: const Alignment(0, 0.1),
                  fallback: ColoredBox(color: world.card),
                ),
                // The seam between the worlds.
                Center(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: red,
                      boxShadow: [
                        BoxShadow(color: red, blurRadius: 14, spreadRadius: 1),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 12,
                  child: Text(
                    'IT IS ALWAYS WATCHING.',
                    style:
                        AppText.headline(
                          Colors.white,
                          size: 18,
                          letterSpacing: 0.1,
                        ).copyWith(
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 10),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, (icon, title, body)) in _facts.indexed) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      height: 88,
                      color: red.withValues(alpha: 0.25),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Icon(
                            icon,
                            color: red,
                            size: 24,
                            shadows: [Shadow(color: red, blurRadius: 10)],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: AppText.headline(
                              world.ink,
                              size: 12.5,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            textAlign: TextAlign.center,
                            style: AppText.body(
                              world.muted,
                              size: 10.5,
                            ).copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GatewayCard extends StatelessWidget {
  const _GatewayCard({
    required this.gate,
    required this.hidden,
    required this.onTap,
  });

  final Gateway gate;

  /// Spoiler shield: the chapter that shows it hasn't been watched.
  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final statusColor = switch (gate.status) {
      GateStatus.open => world.tint(AppColors.stRed),
      GateStatus.closed => world.muted,
      GateStatus.destroyed => world.tint(AppColors.hawkinsGold),
    };
    final body = AppText.body(world.ink.withValues(alpha: 0.8), size: 12.5);
    return NeonCard(
      onTap: onTap,
      glow: gate.status == GateStatus.open ? AppColors.stRed : null,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusLight(
            color: statusColor,
            live: gate.status == GateStatus.open,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gate.name.toUpperCase(),
                        style: AppText.headline(
                          world.ink,
                          size: 16,
                          letterSpacing: 0.06,
                        ),
                      ),
                    ),
                    Text(
                      gate.status.label,
                      style: AppText.label(statusColor).copyWith(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${gate.where} · ${gate.when} · S${gate.season} · E${gate.episode}',
                  style: AppText.dossier(world.muted, size: 11),
                ),
                const SizedBox(height: 6),
                if (hidden) ...[
                  RedactedText(gate.detail, style: body, maxLines: 2),
                  const SizedBox(height: 4),
                  Text(
                    'Classified · watch S${gate.season} · E${gate.episode} to unlock',
                    style: AppText.label(world.muted).copyWith(fontSize: 9.5),
                  ),
                ] else
                  Text(gate.detail, style: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A status lamp: steady when sealed, pulsing while the gate is open.
class _StatusLight extends StatefulWidget {
  const _StatusLight({required this.color, required this.live});

  final Color color;
  final bool live;

  @override
  State<_StatusLight> createState() => _StatusLightState();
}

class _StatusLightState extends State<_StatusLight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.live && !MediaQuery.disableAnimationsOf(context)) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final glow = widget.live ? 0.35 + 0.65 * _c.value : 0.0;
          return Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                if (widget.live)
                  BoxShadow(
                    color: widget.color.withValues(alpha: glow),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SurvivalCard extends StatelessWidget {
  const _SurvivalCard();

  static const _tips = [
    (
      Icons.flashlight_on,
      'When the lights flicker, it\'s close. Carry a flashlight.',
    ),
    (
      Icons.water_drop,
      'Don\'t bleed. The Demogorgon smells blood across worlds.',
    ),
    (
      Icons.local_fire_department,
      'Heat drives it out: fire burned the Mind Flayer out of Will.',
    ),
    (
      Icons.headphones,
      'If you hear the clock, put your song on. Music pulled Max back.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final amber = world.tint(AppColors.hawkinsGold);
    return NeonCard(
      glow: AppColors.hawkinsGold,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: amber, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'WARNING · REALITY BENDS',
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headline(amber, size: 14, letterSpacing: 0.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final (icon, tip) in _tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: world.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: AppText.body(
                        world.ink.withValues(alpha: 0.85),
                        size: 13,
                      ),
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
