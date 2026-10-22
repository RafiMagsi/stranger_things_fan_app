import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../data/quotes.dart';

/// A wall of the lines every fan knows by heart, in dossier typewriter.
/// Long-press a card to copy the line.
class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return STScaffold(
      title: 'QUOTES',
      subtitle: 'Long-press any line to copy it',
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: Quotes.all.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FlickerIn(index: i, child: _QuoteCard(q: Quotes.all[i])),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.q});

  final Quote q;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return NeonCard(
      glow: q.accent,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      // Long-press copies the quote, like a fan sharing it.
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: '"${q.text}" — ${q.speaker}'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied: ${q.speaker}')),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text('“', style: AppText.neon(size: 44, color: q.accent, glow: 0.8).copyWith(height: 0.9)),
          ),
          Text(q.text, style: AppText.dossier(world.ink.withValues(alpha: 0.92), size: 17)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 22,
                height: 2,
                decoration: BoxDecoration(
                  color: q.accent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(color: q.accent, blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 8),
              Text(q.speaker.toUpperCase(), style: AppText.label(q.accent)),
              const Spacer(),
              GlowBadge(text: 'S${q.season}', color: world.muted),
            ],
          ),
        ],
      ),
    );
  }
}
