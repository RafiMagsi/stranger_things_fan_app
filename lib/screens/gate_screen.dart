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
import '../core/widgets/particles.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
import '../core/widgets/world_toggle.dart';

/// The Gate — the doorway between Hawkins and the other side.
///
/// Press the door and it swings inward on a hinge while light, wind and
/// spores of the other world spill through the widening crack. Past the
/// halfway mark the portal roars (sound + haptic + a flash of light), and
/// when it is fully open the whole app turns over into the world you were
/// aiming at, the way the flip works from the world toggle — then the door
/// shuts behind you, still sealed, on the other side.
class GateScreen extends ConsumerStatefulWidget {
  const GateScreen({super.key});

  @override
  ConsumerState<GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends ConsumerState<GateScreen>
    with SingleTickerProviderStateMixin {
  /// How far the door has been pushed open, 0..1.
  late final AnimationController _door = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  /// The burst of light when the doorway is first forced past halfway.
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  /// True from "fully open" until the door has finished shutting — the
  /// world flip is already underway, don't start a second one.
  bool _crossing = false;

  @override
  void initState() {
    super.initState();
    _door.addStatusListener((status) {
      if (!mounted) return;
      if (status == AnimationStatus.completed) {
        _crossOver();
      } else if (status == AnimationStatus.dismissed) {
        _crossing = false;
      }
    });
  }

  @override
  void dispose() {
    _door.dispose();
    _flash.dispose();
    super.dispose();
  }

  bool get _reduce => MediaQuery.disableAnimationsOf(context);

  void _toggleDoor() {
    if (_crossing) return;
    if (_door.status == AnimationStatus.forward) {
      _door.reverse();
      return;
    }
    HapticFeedback.selectionClick();
    _door.forward();
  }

  /// The doorway is more than half open: light spills, the world answers.
  void _onDoorCrack() {
    HapticFeedback.heavyImpact();
    Sfx.cue(ref, 'audio/portal.wav', volume: 0.75);
    if (!_reduce) _flash.forward(from: 0);
  }

  /// Fully open: turn the whole app over into the other world, then let
  /// the door swing shut behind you.
  void _crossOver() {
    if (_crossing || !mounted) return;
    _crossing = true;
    HapticFeedback.heavyImpact();
    final shell = WorldFlipScope.maybeOf(context);
    if (shell != null) {
      // In the app: the full screen-turns-over storm, like the world toggle.
      shell.onFlip();
    } else {
      // Standalone (tests, deep links): flip directly, still with sound.
      ref.read(worldModeProvider.notifier).toggle();
      Sfx.cue(ref, 'audio/portal.wav');
    }
    _door.reverse(from: 1);
  }

  /// Post-frame so the portal's onOpen (which arrives mid-rebuild) never
  /// kicks a controller while the tree is building.
  void _scheduleCrack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onDoorCrack();
    });
  }

  String _statusText(double open) {
    if (_crossing) return 'THE WORLD IS TURNING';
    if (open < 0.04) return 'SEALED';
    if (open < 0.5) return 'IT IS TEARING OPEN';
    return 'LIGHT IS SPILLING THROUGH';
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return STScaffold(
      title: 'THE GATE',
      subtitle: 'Hawkins Lab · sub-level · press the door',
      body: AnimatedBuilder(
        animation: _door,
        builder: (context, _) {
          final open = Curves.easeInOutCubic.transform(_door.value);
          final haze = Color.lerp(AppColors.stRed, AppColors.udGlow, world.depth)!;
          final statusColor = open > 0.5 ? haze : world.muted;
          return Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 360, child: _scene(open, world, haze)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            boxShadow: [
                              BoxShadow(color: statusColor.withValues(alpha: 0.7), blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_statusText(open), style: AppText.label(statusColor)),
                        const Spacer(),
                        Text(
                          world.depth > 0.5
                              ? 'LEADS TO: HAWKINS'
                              : 'LEADS TO: THE UPSIDE DOWN',
                          style: AppText.dossier(world.muted, size: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The wall under the lab never really healed. Push the door '
                      'and the light of the other side spills through the crack — '
                      'keep going and the world turns over.',
                      style: AppText.body(
                        world.ink.withValues(alpha: 0.75),
                        size: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      key: const ValueKey('gate-toggle'),
                      onPressed: _toggleDoor,
                      icon: Icon(
                        open > 0.5 ? Icons.vertical_align_center : Icons.open_in_full,
                        size: 18,
                      ),
                      label: Text(open > 0.5 ? 'LET IT SHUT' : 'PUSH THE DOOR'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.stRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // The flash of the other side when the crack first gives way.
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _flash,
                  builder: (context, _) {
                    final v = _flash.value;
                    if (v <= 0 || v >= 1) return const SizedBox.shrink();
                    final a = math.sin(v * math.pi);
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Color.lerp(Colors.white, AppColors.stRed, 0.35)!
                                .withValues(alpha: 0.5 * a),
                            AppColors.stRed.withValues(alpha: 0.18 * a),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The wall, the lit doorway behind it, and the door itself on its hinge.
  Widget _scene(double open, WorldPalette world, Color haze) {
    return Semantics(
      button: true,
      label: open > 0.5 ? 'Close the Gate' : 'Open the Gate',
      child: GestureDetector(
        key: const ValueKey('gate-door'),
        behavior: HitTestBehavior.opaque,
        onTap: _toggleDoor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final rect = Rect.fromLTWH(w * 0.2, h * 0.06, w * 0.6, h * 0.88);
            final spore = Color.lerp(AppColors.stRedGlow, AppColors.udSpore, world.depth)!;
            return Stack(
              children: [
                // The lab wall the doorway is cut into.
                Positioned.fill(
                  child: WorldGrade(
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF17131A), Color(0xFF0B0910), Colors.black],
                        ),
                      ),
                    ),
                  ),
                ),
                // The other side, seen through the opening: real footage
                // of the other world, fading in with the crack.
                Positioned.fromRect(
                  rect: rect,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0, -0.1),
                              radius: 1.3,
                              colors: [
                                haze.withValues(alpha: 0.85),
                                const Color(0xFF120A14),
                                Colors.black,
                              ],
                            ),
                          ),
                        ),
                        // In Hawkins the door shows the Upside Down; over
                        // there it shows Hawkins. The label says as much.
                        Positioned.fill(
                          child: Opacity(
                            opacity: open,
                            child: ClipLoop(
                              videoKey: world.depth > 0.5
                                  ? 'hawkins_world'
                                  : 'upside_down',
                              placeholder: const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        // Wind and light of the other world, gated by the crack.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: UpsideDownGate(
                              openPercent: open,
                              color: haze,
                              seed: 1983,
                              onOpen: _scheduleCrack,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ParticleField(
                              color: spore,
                              glowColor: haze,
                              count: 30,
                              baseRadius: 1.2,
                              speed: 0.9,
                              opacity: 0.25 + 0.75 * open,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Light from the doorway spilling onto the wall around it.
                if (open > 0.02)
                  Positioned.fromRect(
                    rect: rect.inflate(26),
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: [
                            BoxShadow(
                              color: haze.withValues(alpha: 0.55 * open),
                              blurRadius: 60,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // The door, hinged on its left edge, swinging inward.
                Positioned.fromRect(
                  rect: rect,
                  child: Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(open * 1.55),
                    child: _DoorPanel(width: rect.width, height: rect.height),
                  ),
                ),
                // The frame, drawn over the door's edges so it passes behind.
                Positioned.fromRect(
                  rect: rect.inflate(9),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: world.ink.withValues(alpha: 0.5),
                          width: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                // Vines of the other side creeping in as the light spills.
                Positioned.fill(child: VineOverlay(grow: open, seed: 9)),
                // Spores drifting out into the room once it's open.
                Positioned.fill(
                  child: IgnorePointer(
                    child: ParticleField(
                      color: spore,
                      glowColor: haze,
                      count: 26,
                      baseRadius: 1.1,
                      speed: 0.5,
                      opacity: 0.8 * open,
                    ),
                  ),
                ),
                if (open < 0.02)
                  Positioned(
                    bottom: 4,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Text(
                          'PRESS THE DOOR',
                          style: AppText.label(world.muted).copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The physical door: dark lab wood, two recessed panels, a brass plaque
/// and a knob. Pure decoration — everything interactive lives above it.
class _DoorPanel extends StatelessWidget {
  const _DoorPanel({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget panel(double h) => Container(
          width: width * 0.62,
          height: h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-0.4, -1),
              end: Alignment(0.4, 1),
              colors: [Color(0xFF241A12), Color(0xFF3A2A1C), Color(0xFF1C130D)],
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x88000000), blurRadius: 8, spreadRadius: 2),
            ],
          ),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.85, 1),
          colors: [Color(0xFF46331F), Color(0xFF2A1C12), Color(0xFF160E09)],
          stops: [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 26,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(0, -0.86),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2B2A28),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: AppColors.hawkinsGold.withValues(alpha: 0.5),
                ),
              ),
              child: const Text(
                'HAWKINS LAB · SUBLEVEL 3',
                style: TextStyle(
                  fontSize: 7,
                  letterSpacing: 1.2,
                  color: AppColors.hawkinsGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                panel(height * 0.24),
                const SizedBox(height: 8),
                panel(height * 0.3),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0.74, 0.06),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFE08A), Color(0xFFB8860B), Color(0xFF6B4A00)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.hawkinsGold.withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
