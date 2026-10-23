import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/sfx.dart';
import '../core/media/art.dart';
import '../core/media/poster_image.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/monster_fx.dart';
import '../core/widgets/particles.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/bestiary.dart';

/// Field guide to the Upside Down's creatures, filed like the lab's own
/// threat assessments.
class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return STScaffold(
      title: 'BESTIARY',
      subtitle: 'Hawkins Lab threat assessment',
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: Bestiary.all.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: FlickerIn(
            index: i,
            child: _MonsterCard(m: Bestiary.all[i]),
          ),
        ),
      ),
    );
  }
}

class _MonsterCard extends ConsumerStatefulWidget {
  const _MonsterCard({required this.m});

  final Monster m;

  // What each thing sounds like when you get too close.
  static const _cries = {
    'demogorgon': 'audio/screech.wav',
    'demodog': 'audio/squelch.wav',
    'mind_flayer': 'audio/heartbeat.wav',
    'vecna': 'audio/clock.wav',
    'demo_bat': 'audio/screech.wav',
    'the_flayed': 'audio/vines.wav',
  };

  @override
  ConsumerState<_MonsterCard> createState() => _MonsterCardState();
}

class _MonsterCardState extends ConsumerState<_MonsterCard>
    with SingleTickerProviderStateMixin {
  // The card lunging when poked: a half-sine punch, 0 → 1 → 0.
  late final AnimationController _scare = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void dispose() {
    _scare.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    final world = WorldPalette.of(context);
    final accent = world.tint(m.accent);
    return NeonCard(
      glow: m.accent,
      onTap: () {
        final cry = _MonsterCard._cries[m.id];
        if (cry != null) Sfx.cue(ref, cry, volume: 0.6);
        if (!MediaQuery.disableAnimationsOf(context)) {
          _scare.forward(from: 0);
        }
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Upside Down ash drifting across the monster art.                  if (world.depth > 0.02)
                  IgnorePointer(
                    child: ParticleField(
                      color: world.tint(m.accent),
                      glowColor: world.accent,
                      count: 30,
                      baseRadius: 1.6,
                      speed: 0.8 + world.depth * 0.4,
                      opacity: 0.7,
                    ),
                  ),
                AnimatedBuilder(
                  animation: _scare,
                  // The art itself stays a static child; only the punch and
                  // the flash are rebuilt while the scare plays.
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(
                        assetKey: 'monster_${m.id}',
                        // A real-world look-alike when there is one (a Venus
                        // flytrap for the petal-faced Demogorgon), else key art.
                        fallback: m.photo == null
                            ? KeyArt(
                                accent: m.accent,
                                icon: m.icon,
                                iconSize: 110,
                                iconAlignment: const Alignment(0.8, 0),
                              )
                            : EventArt(
                                photo: m.photo,
                                accent: m.accent,
                                icon: m.icon,
                              ),
                      ),
                      // The creature, alive: its signature animation layered
                      // over the art (maw breathing, shadow churning, ...).
                      Positioned.fill(
                        child: MonsterFx(
                          monsterId: m.id,
                          accent: m.accent,
                          intensity: 0.9,
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, world.card],
                            stops: const [0.4, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: GlowBadge(
                          text: 'Threat ${m.threat}/5',
                          color: m.threat >= 5
                              ? AppColors.udLightning
                              : AppColors.hawkinsGold,
                          icon: Icons.warning_amber,
                          onImage: true,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 8,
                        child: Text(
                          m.name.toUpperCase(),
                          style: AppText.neon(size: 26, color: accent),
                        ),
                      ),
                    ],
                  ),
                  builder: (context, child) {
                    // A quick lunge toward the viewer, then settle — the card
                    // flinches like the thing inside it noticed you.
                    final punch = math.sin(
                      math.pi * Curves.easeOut.transform(_scare.value),
                    );
                    return Transform.scale(
                      scale: 1 + 0.06 * punch,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          child!,
                          if (punch > 0.02)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    m.accent.withValues(alpha: 0.45 * punch),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.alias, style: AppText.dossier(accent, size: 13.5)),
                const SizedBox(height: 10),
                Text(
                  m.detail,
                  style: AppText.body(
                    world.ink.withValues(alpha: 0.75),
                    size: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Threat meter: five segments, lit like a warning panel.
                    for (var t = 1; t <= 5; t++)
                      Container(
                        width: 18,
                        height: 7,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: t <= m.threat
                              ? accent
                              : world.ink.withValues(alpha: 0.12),
                          boxShadow: t <= m.threat
                              ? [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.7),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    const SizedBox(width: 10),
                    GlowBadge(
                      text: 'First seen S${m.firstSeason}',
                      color: world.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: accent.withValues(alpha: 0.08),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.gpp_maybe, size: 15, color: accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Weakness: ${m.weakness}',
                          style: AppText.dossier(
                            world.ink.withValues(alpha: 0.85),
                            size: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),                  ),
              ],
            ),
          ),
          // Spore/pollen burst the instant the card settles into place.
          IgnorePointer(
            child: ParticleBurst(
              controller: Tween<double>(begin: 0, end: 1)
                  .animate(CurvedAnimation(
                    parent: AlwaysStoppedAnimation(0.0 + (_scare.value / 1)),
                    curve: Curves.easeOut,
                  )),
              color: accent,
              count: 12,
            ),
          ),
        ],
      ),
    );
  }
}

