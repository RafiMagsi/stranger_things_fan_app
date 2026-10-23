import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sfx.dart';
import '../core/media/app_video.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/gate_wind.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/particles.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_toggle.dart';

/// The Gate, behind the blast door on Hawkins Lab's lowest level.
///
/// Hold to force it, the way Eleven did: the steel halves grind apart, and
/// behind them a living red tear opens onto the other side - real footage
/// of the membrane, light flooding out, wind and spores pouring through,
/// vines crawling in over the door, the room shaking harder the longer you
/// hold. Let go and it heals shut. Hold all the way and you fall through:
/// the whole app turns over into the other world.
class GateScreen extends ConsumerStatefulWidget {
  const GateScreen({super.key});

  @override
  ConsumerState<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends ConsumerState<GateScreen>
    with TickerProviderStateMixin {
  /// How far it's been forced, 0..1. Holding drives it forward; letting go
  /// lets it heal back, a little faster.
  late final AnimationController _force = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
    reverseDuration: const Duration(milliseconds: 1600),
  );

  /// The tear's own life: its edge crawls, the light breathes.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );

  /// The white-out as you fall through.
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  bool _holding = false;
  bool _crossing = false;
  bool _cracked = false;

  @override
  void initState() {
    super.initState();
    _force.addListener(_onForce);
    _force.addStatusListener((s) {
      if (s == AnimationStatus.completed) _fallThrough();
      if (s == AnimationStatus.dismissed) {
        _crossing = false;
        _cracked = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _force.dispose();
    _pulse.dispose();
    _flash.dispose();
    super.dispose();
  }

  bool get _reduce => MediaQuery.disableAnimationsOf(context);

  void _onForce() {
    // Halfway: the membrane gives way.
    if (!_cracked && _force.value > 0.5) {
      _cracked = true;
      HapticFeedback.heavyImpact();
      Sfx.cue(ref, 'audio/power.wav', volume: 0.7);
    }
  }

  void _press() {
    if (_crossing || _holding) return;
    setState(() => _holding = true);
    HapticFeedback.mediumImpact();
    Sfx.cue(ref, 'audio/portal.wav', volume: 0.6);
    _force.forward();
  }

  void _release() {
    if (!_holding) return;
    setState(() => _holding = false);
    if (!_crossing) _force.reverse();
  }

  /// All the way open: white-out, and the world turns over.
  void _fallThrough() {
    if (_crossing || !mounted) return;
    _crossing = true;
    _holding = false;
    HapticFeedback.heavyImpact();
    if (!_reduce) _flash.forward(from: 0);
    final shell = WorldFlipScope.maybeOf(context);
    if (shell != null) {
      shell.onFlip();
    } else {
      ref.read(worldModeProvider.notifier).toggle();
      Sfx.cue(ref, 'audio/portal.wav');
    }
    // It heals behind you.
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _force.reverse();
    });
  }

  String _status(double v) {
    if (_crossing) return 'YOU\'RE THROUGH';
    if (v < 0.03) return 'SEALED';
    if (v < 0.45) return _holding ? 'THE DOOR IS GIVING' : 'IT\'S CLOSING';
    if (v < 0.9) return _holding ? 'IT\'S TEARING OPEN' : 'IT\'S HEALING';
    return 'HOLD ON';
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final toHawkins = world.depth > 0.5;
    return STScaffold(
      title: 'THE GATE',
      subtitle: 'Hawkins National Laboratory · Sublevel 3',
      body: AnimatedBuilder(
        animation: Listenable.merge([_force, _pulse, _flash]),
        builder: (context, _) {
          final v = _force.value;
          final light = toHawkins ? AppColors.hawkinsGold : AppColors.stRed;
          return Stack(
            fit: StackFit.expand,
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  _scene(v, world, light, toHawkins),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: v > 0.03 ? light : world.muted,
                          boxShadow: [
                            if (v > 0.03)
                              BoxShadow(color: light, blurRadius: 8),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _status(v),
                          key: const ValueKey('gate-status'),
                          style: AppText.headline(
                            v > 0.03 ? world.ink : world.muted,
                            size: 15,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ),
                      Text(
                        toHawkins
                            ? 'LEADS TO: HAWKINS'
                            : 'LEADS TO: THE UPSIDE DOWN',
                        style: AppText.dossier(world.muted, size: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: _HoldButton(
                      value: v,
                      holding: _holding,
                      color: light,
                      onPress: _press,
                      onRelease: _release,
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeonCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CASE FILE · THE GATE',
                          style: AppText.chapter(world.accent, size: 11),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'November 1983. Reaching for the creature in the void, Eleven tore '
                          'a hole in the wall under the lab. Joyce and Hopper walked through '
                          'it in hazmat suits to bring Will home. A year later Eleven came '
                          'back down here and closed it - and it wasn\'t the last.',
                          style: AppText.body(
                            world.ink.withValues(alpha: 0.82),
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // The white-out of the fall.
              if (_flash.isAnimating)
                IgnorePointer(
                  child: ColoredBox(
                    color: Color.lerp(Colors.white, light, 0.3)!.withValues(
                      alpha:
                          math.sin(_flash.value * math.pi).clamp(0.0, 1.0) *
                          0.9,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _scene(double v, WorldPalette world, Color light, bool toHawkins) {
    // The door gives first; the tear follows it open.
    final door = Curves.easeInOutCubic.transform((v / 0.5).clamp(0.0, 1.0));
    final tear = Curves.easeOutCubic.transform(
      ((v - 0.18) / 0.82).clamp(0.0, 1.0),
    );
    final t = _pulse.value;
    // The room shakes with the effort.
    final rnd = math.Random((t * 997).floor());
    final shake = _reduce || !_holding
        ? Offset.zero
        : Offset(rnd.nextDouble() - 0.5, rnd.nextDouble() - 0.5) * (2 + 7 * v);
    final spore = Color.lerp(
      AppColors.stRedGlow,
      AppColors.udSpore,
      world.depth,
    )!;

    return Semantics(
      button: true,
      label: 'Hold to open the Gate',
      child: GestureDetector(
        key: const ValueKey('gate-door'),
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => _press(),
        onLongPressEnd: (_) => _release(),
        onLongPressCancel: _release,
        child: Transform.translate(
          offset: shake,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 430,
              child: LayoutBuilder(
                builder: (context, box) {
                  final w = box.maxWidth;
                  final h = box.maxHeight;
                  final frame = Rect.fromLTWH(
                    w * 0.14,
                    h * 0.08,
                    w * 0.72,
                    h * 0.8,
                  );
                  return Stack(
                    children: [
                      // Poured concrete, the lab's lowest level.
                      const Positioned.fill(child: _LabWall()),
                      // Behind the door: the tear, and the other side through it.
                      Positioned.fromRect(
                        rect: frame,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const ColoredBox(color: Color(0xFF050305)),
                            ClipPath(
                              clipper: _TearClipper(open: tear, t: t),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          light,
                                          Color.lerp(light, Colors.black, 0.7)!,
                                        ],
                                      ),
                                    ),
                                  ),
                                  ClipLoop(
                                    videoKey: toHawkins
                                        ? 'gate_hawkins'
                                        : 'gate_crossing',
                                    placeholder: const SizedBox.shrink(),
                                  ),
                                  UpsideDownGate(
                                    openPercent: tear,
                                    color: light,
                                    seed: 1983,
                                  ),
                                ],
                              ),
                            ),
                            IgnorePointer(
                              child: CustomPaint(
                                painter: _TearRim(
                                  open: tear,
                                  t: t,
                                  color: light,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: ParticleField(
                                  color: spore,
                                  glowColor: light,
                                  count: 28,
                                  baseRadius: 1.2,
                                  speed: 0.6 + v,
                                  opacity: tear,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // The blast door, its halves sliding into the walls.
                      Positioned.fromRect(
                        rect: frame,
                        child: ClipRect(
                          child: Stack(
                            children: [
                              Positioned(
                                left: -frame.width / 2 * door,
                                top: 0,
                                bottom: 0,
                                width: frame.width / 2,
                                child: _DoorHalf(
                                  left: true,
                                  overgrown: world.depth,
                                ),
                              ),
                              Positioned(
                                right: -frame.width / 2 * door,
                                top: 0,
                                bottom: 0,
                                width: frame.width / 2,
                                child: _DoorHalf(
                                  left: false,
                                  overgrown: world.depth,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Light spilling out into the room.
                      if (tear > 0.01)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  radius: 0.9,
                                  colors: [
                                    light.withValues(
                                      alpha:
                                          0.35 *
                                          tear *
                                          (0.85 +
                                              0.15 * math.sin(t * math.pi * 2)),
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      // The door frame and its warning light.
                      Positioned.fromRect(
                        rect: frame.inflate(8),
                        child: _Frame(alarm: v > 0.03, t: t),
                      ),
                      // The other side gets in.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: VineOverlay(grow: tear, seed: 9),
                        ),
                      ),
                      if (v < 0.03)
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Text(
                              'PRESS AND HOLD',
                              textAlign: TextAlign.center,
                              style: AppText.headline(
                                Colors.white54,
                                size: 11,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The ring you hold - Eleven's hand, the effort filling up around it.
class _HoldButton extends StatelessWidget {
  const _HoldButton({
    required this.value,
    required this.holding,
    required this.color,
    required this.onPress,
    required this.onRelease,
  });

  final double value;
  final bool holding;
  final Color color;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Semantics(
      button: true,
      label: 'Hold to open the Gate',
      child: GestureDetector(
        key: const ValueKey('gate-hold'),
        onTapDown: (_) => onPress(),
        onTapUp: (_) => onRelease(),
        onTapCancel: onRelease,
        child: SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 4,
                  color: color,
                  backgroundColor: world.ink.withValues(alpha: 0.1),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: holding ? 70 : 76,
                height: holding ? 70 : 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: world.card,
                  border: Border.all(color: color.withValues(alpha: 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: holding ? 0.7 : 0.3),
                      blurRadius: holding ? 26 : 14,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.back_hand, color: color, size: 26),
                    Text(
                      'HOLD',
                      style: AppText.headline(
                        world.ink,
                        size: 10,
                        letterSpacing: 0.2,
                      ),
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

/// A living tear: a jagged slit whose edges crawl, pointed at both ends,
/// widening into an eye as it's forced.
class _TearClipper extends CustomClipper<Path> {
  const _TearClipper({required this.open, required this.t});

  final double open;
  final double t;

  @override
  Path getClip(Size size) => _tearPath(size, open, t);

  @override
  bool shouldReclip(covariant _TearClipper o) => o.open != open || o.t != t;
}

Path _tearPath(Size size, double open, double t) {
  final cx = size.width / 2;
  // It runs the height of the doorway before it widens.
  final reach = 0.46 * math.min(1.0, open * 2.2);
  final top = size.height * (0.5 - reach);
  final bottom = size.height * (0.5 + reach);
  final half = size.width * 0.5 * open;
  const steps = 28;
  final left = <Offset>[];
  final right = <Offset>[];
  for (var i = 0; i <= steps; i++) {
    final u = i / steps;
    final y = top + (bottom - top) * u;
    final env = math.pow(math.sin(math.pi * u), 0.8).toDouble();
    final jag =
        1 +
        0.18 * math.sin(u * 37 + t * math.pi * 2) +
        0.12 * math.sin(u * 91 - t * math.pi * 4);
    left.add(Offset(cx - half * env * jag, y));
    right.add(Offset(cx + half * env * (2 - jag), y));
  }
  final path = Path()..moveTo(left.first.dx, left.first.dy);
  for (final p in left.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  for (final p in right.reversed) {
    path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

/// The tear's wet, glowing rim and the strands still bridging it.
class _TearRim extends CustomPainter {
  const _TearRim({required this.open, required this.t, required this.color});

  final double open;
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (open <= 0.005) return;
    final path = _tearPath(size, open, t);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = color.withValues(alpha: 0.5 * open)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Color.lerp(color, Colors.white, 0.35)!.withValues(alpha: 0.9),
    );
    final rnd = math.Random(7);
    final strand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Color.lerp(
        color,
        Colors.black,
        0.35,
      )!.withValues(alpha: 0.75 * (1 - open * 0.6));
    final cx = size.width / 2;
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.25 + 0.5 * rnd.nextDouble());
      final span = size.width * 0.5 * open * (0.4 + 0.5 * rnd.nextDouble());
      final sag =
          10 + 14 * rnd.nextDouble() + 4 * math.sin(t * math.pi * 2 + i);
      canvas.drawPath(
        Path()
          ..moveTo(cx - span, y)
          ..quadraticBezierTo(cx, y + sag, cx + span, y + rnd.nextDouble() * 6),
        strand,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TearRim o) =>
      o.open != open || o.t != t || o.color != color;
}

/// Lab concrete: cold, stained, with the panel seams of the sublevel and
/// hazard chevrons along the floor.
class _LabWall extends StatelessWidget {
  const _LabWall();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1D20), Color(0xFF111214), Color(0xFF08090A)],
        ),
      ),
      child: CustomPaint(painter: _WallSeams(), size: Size.infinite),
    );
  }
}

class _WallSeams extends CustomPainter {
  const _WallSeams();

  @override
  void paint(Canvas canvas, Size size) {
    final seam = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), seam);
    }
    final band = Rect.fromLTWH(0, size.height - 18, size.width, 18);
    canvas.save();
    canvas.clipRect(band);
    final yellow = Paint()
      ..color = const Color(0xFFC9A227).withValues(alpha: 0.75);
    for (var x = -20.0; x < size.width + 20; x += 24) {
      canvas.drawPath(
        Path()
          ..moveTo(x, band.bottom)
          ..lineTo(x + 12, band.top)
          ..lineTo(x + 24, band.top)
          ..lineTo(x + 12, band.bottom)
          ..close(),
        yellow,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WallSeams o) => false;
}

/// One half of the blast door: brushed steel, rivets, stencilled warnings -
/// and in the Upside Down, cold rust and vines.
class _DoorHalf extends StatelessWidget {
  const _DoorHalf({required this.left, required this.overgrown});

  final bool left;
  final double overgrown;

  @override
  Widget build(BuildContext context) {
    final steel = Color.lerp(
      const Color(0xFF3A3F44),
      const Color(0xFF27303A),
      overgrown,
    )!;
    final stencil = TextStyle(
      fontFamily: AppText.condensed,
      fontSize: 9,
      letterSpacing: 1.6,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFC9A227).withValues(alpha: 0.85),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: left ? Alignment.centerLeft : Alignment.centerRight,
          end: left ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Color.lerp(steel, Colors.black, 0.45)!,
            steel,
            Color.lerp(steel, Colors.white, 0.08)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _Rivets(left: left)),
          ),
          Align(
            alignment: Alignment(left ? 0.4 : -0.4, -0.5),
            child: RotatedBox(
              quarterTurns: left ? 3 : 1,
              child: Text(
                left
                    ? 'AUTHORIZED PERSONNEL ONLY'
                    : 'HAWKINS NATIONAL LABORATORY',
                style: stencil,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.62),
            child: Text(
              left ? 'SUBLEVEL' : '3',
              style: stencil.copyWith(fontSize: left ? 11 : 22),
            ),
          ),
          if (overgrown > 0.01)
            Positioned.fill(
              child: Opacity(
                opacity: overgrown.clamp(0.0, 1.0),
                child: VineOverlay(seed: left ? 3 : 4),
              ),
            ),
        ],
      ),
    );
  }
}

class _Rivets extends CustomPainter {
  const _Rivets({required this.left});

  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final shine = Paint()..color = Colors.white.withValues(alpha: 0.18);
    for (final x in [size.width * 0.1, size.width * 0.9]) {
      for (var y = 14.0; y < size.height - 10; y += 26) {
        canvas.drawCircle(Offset(x, y), 2.4, dot);
        canvas.drawCircle(Offset(x - 0.7, y - 0.7), 1, shine);
      }
    }
    // The seal down the middle, where the halves meet.
    final edge = left ? size.width - 1.5 : 1.5;
    canvas.drawLine(
      Offset(edge, 0),
      Offset(edge, size.height),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.75)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _Rivets o) => o.left != left;
}

/// The door's frame, with the warning lamp over it that strobes once the
/// seal breaks.
class _Frame extends StatelessWidget {
  const _Frame({required this.alarm, required this.t});

  final bool alarm;
  final double t;

  @override
  Widget build(BuildContext context) {
    final strobe = alarm && (t * 6).floor().isEven;
    final lamp = alarm ? AppColors.stRed : const Color(0xFF3A1414);
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF55595E), width: 8),
                boxShadow: const [
                  BoxShadow(color: Colors.black87, blurRadius: 18),
                ],
              ),
            ),
          ),
          Positioned(
            top: -14,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 34,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: strobe ? lamp : Color.lerp(lamp, Colors.black, 0.5),
                  boxShadow: [
                    if (strobe)
                      BoxShadow(color: lamp, blurRadius: 18, spreadRadius: 2),
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
