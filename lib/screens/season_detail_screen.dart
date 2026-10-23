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
import '../core/widgets/world_fx.dart';
import '../core/widgets/world_toggle.dart';
import '../data/moments.dart';
import '../data/seasons.dart';
import '../data/timeline.dart';
import '../models/moment.dart';
import '../models/season.dart';
import 'story_screen.dart';
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
                      widget.heroTag == null ? art : STHero(tag: widget.heroTag!, radius: 22, child: art),
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
                            NeonIgnite(
                              delay: const Duration(milliseconds: 300),
                              builder: (context, glow) => Text(
                                'SEASON ${numberWord(s.number)}',
                                style: AppText.neon(size: 34, color: world.tint(s.accent), glow: glow),
                              ),
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
                                color: world.tint(s.accent),
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
                      const SizedBox(width: 4),
                      // Watch the season as a story, from its title card.
                      FilledButton.icon(
                        key: const ValueKey('play-season'),
                        onPressed: () => RiftPageRoute.push(
                          context,
                          StoryScreen(season: s.number, onlySeason: true),
                          name: '/story',
                        ),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('PLAY'),
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
                              onPlay: () => RiftPageRoute.push(
                                context,
                                StoryScreen(season: s.number, episode: e.number, onlySeason: true),
                                name: '/story',
                              ),
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
  void _showExtras(BuildContext context, List<Moment> moments, List<TimelineEvent> beats) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChapterExtrasSheet(
        season: season,
        episode: episode,
        moments: moments,
        beats: beats,
      ),
    );
  }

  const _ChapterCard({
    required this.season,
    required this.episode,
    required this.watched,
    required this.focused,
    required this.onToggle,
    required this.onPlay,
  });

  final Season season;
  final Episode episode;
  final bool watched;
  final bool focused;
  final VoidCallback onToggle;

  /// Watch this chapter in Story mode.
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final accent = world.tint(season.accent);
    // Everything else the app knows about this chapter.
    final moments = Moments.all
        .where((m) => m.season == season.number && m.episode == episode.number)
        .toList();
    final beats = STTimeline.events
        .where((e) => e.season == season.number && e.episode == episode.number)
        .toList();
    return NeonCard(
      onTap: onPlay,
      // NeonCard tints its own glow; pass the raw colour.
      glow: focused ? AppColors.hawkinsGold : season.accent,
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
                if (moments.isNotEmpty || beats.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (moments.isNotEmpty)
                        _LinkChip(
                          icon: Icons.local_fire_department,
                          label: '${moments.length} ${moments.length == 1 ? 'moment' : 'moments'}',
                          color: accent,
                          onTap: () => _showExtras(context, moments, beats),
                        ),
                      if (beats.isNotEmpty)
                        _LinkChip(
                          icon: Icons.timeline,
                          label: '${beats.length} timeline ${beats.length == 1 ? 'beat' : 'beats'}',
                          color: accent,
                          onTap: () => _showExtras(context, moments, beats),
                        ),
                    ],
                  ),
                ],
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

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label.toUpperCase(), style: AppText.label(color).copyWith(fontSize: 10.5, letterSpacing: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}

/// What else happens in one chapter: its moments (setup only - reveals
/// stay on the Moments screen) and the timeline beats it reveals. Respects
/// the spoiler shield like everywhere else.
class _ChapterExtrasSheet extends ConsumerWidget {
  const _ChapterExtrasSheet({
    required this.season,
    required this.episode,
    required this.moments,
    required this.beats,
  });

  final Season season;
  final Episode episode;
  final List<Moment> moments;
  final List<TimelineEvent> beats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = WorldPalette.of(context);
    final shielded = ref.watch(settingsProvider).spoilerShield &&
        Seasons.isAhead(season.number, episode.number, ref.watch(watchProgressProvider));
    final height = MediaQuery.sizeOf(context).height * 0.7;

    Widget item({
      required String? photo,
      required Color accent,
      required String kicker,
      required String title,
      required String body,
    }) {
      final titleStyle = AppText.h2(world.ink).copyWith(fontSize: 16);
      final bodyStyle = AppText.body(world.ink.withValues(alpha: 0.72), size: 12.5);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: NeonCard(
          glow: accent,
          padding: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 88, height: 104, child: EventArt(photo: photo, accent: accent)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kicker, style: AppText.chapter(world.tint(accent), size: 10)),
                      const SizedBox(height: 4),
                      shielded
                          ? RedactedText(title, style: titleStyle, maxLines: 1)
                          : Text(title, style: titleStyle),
                      const SizedBox(height: 4),
                      shielded
                          ? RedactedText(body, style: bodyStyle, maxLines: 2)
                          : Text(body, style: bodyStyle, maxLines: 4, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height),
          child: NeonCard(
            glow: season.accent,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text(
                  'S${season.number} · ${episode.chapterLabel}',
                  style: AppText.chapter(world.tint(season.accent), size: 11),
                ),
                const SizedBox(height: 4),
                Text(episode.title, style: AppText.h1(world.ink).copyWith(fontSize: 22)),
                if (shielded) ...[
                  const SizedBox(height: 10),
                  ClassifiedBanner(unlock: 'S${season.number} · E${episode.number}'),
                ],
                const SizedBox(height: 14),
                for (final m in moments)
                  item(
                    photo: m.photo,
                    accent: m.accent,
                    kicker: m.kind.label.toUpperCase(),
                    title: m.title,
                    body: m.setup,
                  ),
                for (final e in beats)
                  item(
                    photo: e.photo,
                    accent: e.accent,
                    kicker: 'TIMELINE · ${e.year.toUpperCase()}',
                    title: e.title,
                    body: e.detail,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
