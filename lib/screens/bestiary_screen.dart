import 'package:flutter/material.dart';

import '../core/media/poster_image.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/glass_card.dart';
import '../data/bestiary.dart';

/// Field guide to the Upside Down's creatures, with threat meters.
class BestiaryScreen extends StatelessWidget {
  const BestiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BESTIARY',
          style: AppText.h2(scheme.onSurface).copyWith(letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: Bestiary.all.length,
        itemBuilder: (context, i) {
          final m = Bestiary.all[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MonsterCard(m: m),
          );
        },
      ),
    );
  }
}

class _MonsterCard extends StatelessWidget {
  const _MonsterCard({required this.m});

  final Monster m;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      glow: m.accent,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(
                    assetKey: 'monster_${m.id}',
                    fallback: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            m.accent.withValues(alpha: 0.6),
                            scheme.surface,
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(m.icon, size: 72, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            scheme.surface.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GlowBadge(
                      text: 'Threat ${m.threat}/5',
                      color: m.accent,
                      icon: Icons.warning_amber,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: AppText.h2(scheme.onSurface).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(m.alias, style: AppText.label(m.accent)),
                  const SizedBox(height: 8),
                  Text(
                    m.detail,
                    style: AppText.body(
                      scheme.onSurface.withValues(alpha: 0.72),
                      size: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Threat meter.
                      Row(
                        children: [
                          for (var t = 1; t <= 5; t++)
                            Container(
                              width: 14,
                              height: 6,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: t <= m.threat
                                    ? m.accent
                                    : scheme.onSurface.withValues(alpha: 0.15),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      GlowBadge(
                        text: 'First seen S${m.firstSeason}',
                        color: Colors.white70,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.gpp_maybe, size: 14, color: m.accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Weakness: ${m.weakness}',
                          style: AppText.dossier(
                            scheme.onSurface.withValues(alpha: 0.7),
                            size: 12.5,
                          ),
                        ),
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
