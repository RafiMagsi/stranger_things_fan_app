import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/text_styles.dart';
import '../core/widgets/glass_card.dart';
import '../data/quotes.dart';

/// A wall of the lines every fan knows by heart, in dossier typewriter.
class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QUOTES',
          style: AppText.h2(scheme.onSurface).copyWith(letterSpacing: 1.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: Quotes.all.length,
        itemBuilder: (context, i) {
          final q = Quotes.all[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _QuoteCard(q: q),
          );
        },
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.q});

  final Quote q;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      // Long-press copies the quote, like a fan sharing it.
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: '"${q.text}" — ${q.speaker}'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: ${q.speaker}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: GlassCard(
        glow: q.accent,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.format_quote, color: q.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.text,
                    style: AppText.dossier(
                      scheme.onSurface.withValues(alpha: 0.9),
                      size: 15.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 2,
                  decoration: BoxDecoration(
                    color: q.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  q.speaker.toUpperCase(),
                  style: AppText.label(q.accent),
                ),
                const Spacer(),
                GlowBadge(text: 'S${q.season}', color: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
