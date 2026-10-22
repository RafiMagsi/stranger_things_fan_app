import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/credits.dart';
import '../models/media_credit.dart';

/// Where every image, video and sound comes from. The Creative Commons
/// licences on the bundled photos require this attribution.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final cast = MediaCredits.all.where((c) => c.asset.contains('/cast/')).toList();
    final places = MediaCredits.all.where((c) => c.asset.contains('/filming/')).toList();

    return STScaffold(
      title: 'CREDITS',
      subtitle: 'Sources & licences',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          NeonCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ABOUT THIS APP', style: AppText.chapter(world.accent, size: 12)),
                const SizedBox(height: 10),
                Text(
                  'An unofficial, non-commercial fan companion made for education and '
                  'fun. Stranger Things and all related names are trademarks of '
                  'Netflix. This app is not affiliated with or endorsed by Netflix.',
                  style: AppText.body(world.ink.withValues(alpha: 0.85), size: 13.5),
                ),
                const SizedBox(height: 10),
                _Line(
                  icon: Icons.play_circle,
                  text: 'Trailers are Netflix\'s official uploads, streamed through '
                      'YouTube\'s embedded player. Nothing is downloaded or re-hosted.',
                ),
                _Line(
                  icon: Icons.graphic_eq,
                  text: 'Every sound is an original synth cue generated for this app '
                      '(tool/generate_audio.py). No recordings from the show.',
                ),
                _Line(
                  icon: Icons.brush,
                  text: 'Logos, gates, lightning, vines and the alphabet wall are drawn '
                      'in code. Fonts: Grenze, Space Grotesk and Special Elite '
                      '(open-licence Google Fonts).',
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Cast portraits', padding: EdgeInsets.fromLTRB(0, 28, 0, 6)),
          Text(
            'Photos of the actors at public events - not stills from the show.',
            style: AppText.dossier(world.muted, size: 12),
          ),
          const SizedBox(height: 12),
          for (final c in cast) _CreditTile(credit: c, onTap: () => _open(c.source)),
          const SectionHeader(title: 'Filming locations', padding: EdgeInsets.fromLTRB(0, 28, 0, 6)),
          Text(
            'The real places that stood in for Hawkins and beyond.',
            style: AppText.dossier(world.muted, size: 12),
          ),
          const SizedBox(height: 12),
          for (final c in places) _CreditTile(credit: c, onTap: () => _open(c.source)),
          const SizedBox(height: 12),
          Text(
            'All photos via Wikimedia Commons, resized for the app and colour-graded '
            'at display time. Adaptations of CC BY-SA works are offered under the '
            'same licence. Tap any entry to see the original file and licence.',
            style: AppText.body(world.muted, size: 12),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: world.secondary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppText.body(world.muted, size: 12.5))),
        ],
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  const _CreditTile({required this.credit, required this.onTap});

  final MediaCredit credit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeonCard(
        onTap: onTap,
        tube: false,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(credit.asset, width: 52, height: 52, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(credit.subject, style: AppText.body(world.ink, size: 14, bold: true)),
                  const SizedBox(height: 2),
                  Text(
                    '${credit.author} · ${credit.license}',
                    style: AppText.body(world.muted, size: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new, size: 16, color: world.muted),
          ],
        ),
      ),
    );
  }
}
