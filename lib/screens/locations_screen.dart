import 'package:flutter/material.dart';

import '../core/media/art.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/credits.dart';
import '../data/locations.dart';

/// The map of Hawkins: the places the story keeps coming back to, and the
/// real towns and buildings that played them.
class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return STScaffold(
      title: 'HAWKINS MAP',
      subtitle: '${Locations.all.length} places · and where they were filmed',
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: Locations.all.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: FlickerIn(index: i, child: _LocationCard(loc: Locations.all[i])),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.loc});

  final STLocation loc;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final photo = MediaCredits.filmingPhoto(loc.id);
    final credit = photo == null ? null : MediaCredits.forAsset(photo);

    return NeonCard(
      glow: loc.accent,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LocationArt(location: loc),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, world.card],
                      stops: const [0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Wrap(
                    spacing: 6,
                    children: [
                      if (loc.upsideDown)
                        const GlowBadge(text: 'Upside Down', color: AppColors.udGlow, icon: Icons.blur_on, onImage: true),
                      if (photo != null)
                        const GlowBadge(text: 'Real location', color: Colors.white, icon: Icons.photo_camera, onImage: true),
                    ],
                  ),
                ),
                // Procedural art already shows the icon large.
                if (photo != null)
                  Positioned(
                    right: 14,
                    bottom: 10,
                    child: Icon(loc.icon, color: loc.accent, size: 26, shadows: [Shadow(color: loc.accent, blurRadius: 12)]),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.name, style: AppText.h2(world.ink).copyWith(fontSize: 19)),
                const SizedBox(height: 4),
                Text(loc.note, style: AppText.dossier(loc.accent, size: 13)),
                const SizedBox(height: 10),
                Text(
                  loc.detail,
                  style: AppText.body(world.ink.withValues(alpha: 0.75), size: 13),
                ),
                if (loc.filmedAt != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.videocam, size: 15, color: world.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filmed at ${loc.filmedAt}',
                          style: AppText.body(world.ink, size: 12.5, bold: true),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    GlowBadge(text: loc.seasonLabel, color: world.muted),
                    if (credit != null) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Photo: ${credit.author} · ${credit.license}',
                          style: AppText.body(world.muted.withValues(alpha: 0.8), size: 10.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
