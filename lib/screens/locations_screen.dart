import 'package:flutter/material.dart';

import '../core/media/poster_image.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/glass_card.dart';
import '../data/locations.dart';

/// The map of Hawkins: recurring locations with drop-in stills.
class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HAWKINS MAP',
          style: AppText.h2(scheme.onSurface).copyWith(letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: Locations.all.length,
        itemBuilder: (context, i) {
          final loc = Locations.all[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _LocationCard(loc: loc),
          );
        },
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.loc});

  final STLocation loc;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GlassCard(
      glow: loc.accent,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Still strip (drop-in or procedural).
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(
                    assetKey: 'loc_${loc.id}',
                    fallback: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            loc.accent.withValues(alpha: 0.55),
                            scheme.surface,
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(loc.icon, size: 64, color: Colors.white24),
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
                  if (loc.upsideDown)
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: GlowBadge(
                        text: 'Upside Down',
                        color: Color(0xFF5BFFDF),
                        icon: Icons.blur_on,
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
                    loc.name,
                    style: AppText.h2(scheme.onSurface).copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.note,
                    style: AppText.label(loc.accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.detail,
                    style: AppText.body(
                      scheme.onSurface.withValues(alpha: 0.72),
                      size: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlowBadge(text: loc.seasonLabel, color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
