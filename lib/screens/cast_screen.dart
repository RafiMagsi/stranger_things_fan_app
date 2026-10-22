import 'package:flutter/material.dart';

import '../core/media/art.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/characters.dart' as cast_data;
import '../models/character.dart';
import 'character_detail_screen.dart';

/// Every dossier in one place, grouped the way Hawkins sees them: the
/// Party, the older kids, the adults, and the things from the other side.
class CastScreen extends StatelessWidget {
  const CastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<Character>>{};
    for (final c in cast_data.Cast.all) {
      final group = c.isCreature || c.role == 'Villain' ? 'From the Upside Down' : (c.role ?? 'Hawkins');
      groups.putIfAbsent(group, () => []).add(c);
    }

    var index = 0;
    return STScaffold(
      title: 'THE CAST',
      subtitle: '${cast_data.Cast.all.length} dossiers · Hawkins National Laboratory',
      body: CustomScrollView(
        slivers: [
          for (final entry in groups.entries) ...[
            SliverToBoxAdapter(child: SectionHeader(title: entry.key)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: [
                  for (final c in entry.value)
                    FlickerIn(
                      index: index++,
                      child: _DossierCard(
                        character: c,
                        heroTag: 'char-cast-${c.id}',
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _DossierCard extends StatelessWidget {
  const _DossierCard({required this.character, required this.heroTag});

  final Character character;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final c = character;
    return NeonCard(
      glow: c.isCreature ? AppColors.udLightning : c.accent,
      padding: EdgeInsets.zero,
      onTap: () => RiftPageRoute.push(
        context,
        CharacterDetailScreen(character: c, heroTag: heroTag),
        name: '/character/${c.id}',
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(tag: heroTag, child: CharacterArt(character: c, iconSize: 110)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xEB000000)],
                stops: [0.4, 1],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: AppText.h2(Colors.white).copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  c.actor ?? c.alias,
                  style: AppText.dossier(Colors.white.withValues(alpha: 0.7), size: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                GlowBadge(text: c.seasonLabel, color: c.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
