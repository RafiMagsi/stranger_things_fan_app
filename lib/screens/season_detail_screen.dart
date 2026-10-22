import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/media/art.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../core/widgets/st_effects.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_toggle.dart';
import '../models/season.dart';
import 'trailer_player_screen.dart';

/// One season as a watch guide: the key art, its official trailers, and
/// every chapter in order with a spoiler-light synopsis and a "watched"
/// mark, so the app follows along as you watch the series.
class SeasonDetailScreen extends ConsumerStatefulWidget {
  const SeasonDetailScreen({
    super.key,
    required this.season,
    this.heroTag,
    this.focusEpisode,
  });

  final Season season;

  /// Matches the card this screen was opened from, so its art flies in.
  final String? heroTag;

  /// Chapter to scroll to and highlight (e.g. from "Next up").
  final int? focusEpisode;

  @override
  ConsumerState<SeasonDetailScreen> createState() => _SeasonDetailScreenState();
}

class _SeasonDetailScreenState extends ConsumerState<SeasonDetailScreen> {
  final _focusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.focusEpisode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _focusKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.25,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.season;
    final world = WorldPalette.of(context);
    final watched = ref.watch(watchProgressProvider);
    final keys = [for (final e in s.episodes) s.keyFor(e)];
    final done = keys.where(watched.contains).length;
    final art = SeasonArt(season: s, animate: true);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WorldAtmosphere(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: world.bg,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: const NeonBackButton(),
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Center(child: WorldToggle(compact: true)),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.heroTag == null ? art : Hero(tag: widget.heroTag!, child: art),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x55000000), Color(0x22000000), Color(0xF0000000)],
                            stops: [0, 0.4, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SEASON ${numberWord(s.number)}',
                              style: AppText.neon(size: 34, color: s.accent),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              s.tagline,
                              style: AppText.body(Colors.white.withValues(alpha: 0.9), size: 14),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                GlowBadge(text: s.setting, color: Colors.white70, icon: Icons.event, onImage: true),
                                GlowBadge(text: s.threat, color: AppColors.hawkinsGold, icon: Icons.warning_amber, onImage: true),
                                GlowBadge(text: '${s.year} · ${s.episodeLabel}', color: Colors.white70, onImage: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress through this season.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              done == keys.length ? 'SEASON COMPLETE' : 'WATCHED $done OF ${keys.length}',
                              style: AppText.label(world.muted).copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: done / keys.length,
                                minHeight: 4,
                                color: s.accent,
                                backgroundColor: world.ink.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => ref
                            .read(watchProgressProvider.notifier)
                            .setAll(keys, watched: done != keys.length),
                        child: Text(done == keys.length ? 'RESET' : 'MARK ALL'),
                      ),
                    ],
                  ),
                ),
              ),

              if (s.trailers.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SectionHeader(title: 'Official Trailers')),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: s.trailers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => SizedBox(
                        width: s.trailers.length == 1
                            ? MediaQuery.sizeOf(context).width - 40
                            : 230,
                        child: TrailerCard(
                          trailer: s.trailers[i],
                          onTap: () => RiftPageRoute.push(
                            context,
                            TrailerPlayerScreen(trailer: s.trailers[i]),
                            name: '/trailer',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SectionHeader(title: 'Chapters')),
              // A plain column, not a lazy list: a season is at most nine
              // chapters, and "Next up" needs every card laid out to scroll
              // to it.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    children: [
                      for (final (i, e) in s.episodes.indexed)
                        Padding(
                          key: e.number == widget.focusEpisode ? _focusKey : null,
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FlickerIn(
                            index: i,
                            child: _ChapterCard(
                              season: s,
                              episode: e,
                              watched: watched.contains(s.keyFor(e)),
                              focused: e.number == widget.focusEpisode,
                              onToggle: () {
                                HapticFeedback.lightImpact();
                                ref.read(watchProgressProvider.notifier).toggle(s.keyFor(e));
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const CrtOverlay(opacity: 0.06, animate: false),
        ],
      ),
    );
  }
}

/// One chapter, styled like the show's own title card.
class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    required this.season,
    required this.episode,
    required this.watched,
    required this.focused,
    required this.onToggle,
  });

  final Season season;
  final Episode episode;
  final bool watched;
  final bool focused;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final accent = season.accent;
    return NeonCard(
      glow: focused ? AppColors.hawkinsGold : accent,
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        episode.chapterLabel,
                        style: AppText.chapter(accent, size: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (focused) ...[
                      const SizedBox(width: 8),
                      const GlowBadge(text: 'Next up', color: AppColors.hawkinsGold),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  episode.title,
                  style: AppText.h2(world.ink).copyWith(fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  episode.synopsis,
                  style: AppText.body(world.ink.withValues(alpha: 0.72), size: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Semantics(
            button: true,
            toggled: watched,
            label: watched ? 'Mark as not watched' : 'Mark as watched',
            child: IconButton(
              key: ValueKey('watch-${season.keyFor(episode)}'),
              onPressed: onToggle,
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: watched ? accent : Colors.transparent,
                  border: Border.all(
                    color: watched ? accent : world.muted.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: watched
                      ? [BoxShadow(color: accent.withValues(alpha: 0.7), blurRadius: 12)]
                      : null,
                ),
                child: Icon(
                  Icons.check,
                  size: 18,
                  color: watched ? Colors.white : world.muted.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
