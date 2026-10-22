import 'package:flutter/material.dart';

import '../core/media/poster_image.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
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
          child: FlickerIn(index: i, child: _MonsterCard(m: Bestiary.all[i])),
        ),
      ),
    );
  }
}

class _MonsterCard extends StatelessWidget {
  const _MonsterCard({required this.m});

  final Monster m;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return NeonCard(
      glow: m.accent,
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
                PosterImage(
                  assetKey: 'monster_${m.id}',
                  fallback: KeyArt(
                    accent: m.accent,
                    icon: m.icon,
                    iconSize: 110,
                    iconAlignment: const Alignment(0.8, 0),
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
                    color: m.threat >= 5 ? AppColors.udLightning : AppColors.hawkinsGold,
                    icon: Icons.warning_amber,
                    onImage: true,
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 8,
                  child: Text(
                    m.name.toUpperCase(),
                    style: AppText.neon(size: 26, color: m.accent),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.alias, style: AppText.dossier(m.accent, size: 13.5)),
                const SizedBox(height: 10),
                Text(
                  m.detail,
                  style: AppText.body(world.ink.withValues(alpha: 0.75), size: 13),
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
                          color: t <= m.threat ? m.accent : world.ink.withValues(alpha: 0.12),
                          boxShadow: t <= m.threat
                              ? [BoxShadow(color: m.accent.withValues(alpha: 0.7), blurRadius: 8)]
                              : null,
                        ),
                      ),
                    const SizedBox(width: 10),
                    GlowBadge(text: 'First seen S${m.firstSeason}', color: world.muted),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: m.accent.withValues(alpha: 0.08),
                    border: Border.all(color: m.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.gpp_maybe, size: 15, color: m.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Weakness: ${m.weakness}',
                          style: AppText.dossier(world.ink.withValues(alpha: 0.85), size: 12.5),
                        ),
                      ),
                    ],
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
