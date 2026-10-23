import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/app_state.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/rift_route.dart';
import '../data/seasons.dart';
import 'credits_screen.dart';

/// The app's preferences, as a bottom sheet styled like a lab control
/// panel: spoiler shield, sound, reduced effects, and watch progress.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends ConsumerStatefulWidget {
  const _SettingsSheet();

  @override
  ConsumerState<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<_SettingsSheet> {
  // Reset is destructive: the first tap arms it, the second does it.
  bool _armed = false;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final watched = ref.watch(watchProgressProvider).length;
    // The device's own Reduce Motion, read from the platform: this sheet's
    // MediaQuery already folds in the in-app setting.
    final systemReduce = View.of(
      context,
    ).platformDispatcher.accessibilityFeatures.disableAnimations;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ConstrainedBox(
          // Small phones: the panel scrolls rather than overflowing.
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: NeonCard(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTROL PANEL',
                    style: AppText.neon(size: 22, color: world.accent),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hawkins National Laboratory · authorised personnel',
                    style: AppText.dossier(world.muted, size: 12),
                  ),
                  const SizedBox(height: 12),
                  _Toggle(
                    key: const ValueKey('setting-spoiler-shield'),
                    title: 'Spoiler shield',
                    body:
                        'Redact timeline beats and moments from chapters you '
                        'haven\'t marked as watched. Tap any card to peek.',
                    icon: Icons.lock,
                    value: settings.spoilerShield,
                    onChanged: notifier.setSpoilerShield,
                  ),
                  _Toggle(
                    key: const ValueKey('setting-music'),
                    title: 'Score',
                    body:
                        'The synth theme behind the title sequence and Story mode.',
                    icon: Icons.music_note,
                    value: settings.music,
                    onChanged: notifier.setMusic,
                  ),
                  _Toggle(
                    key: const ValueKey('setting-sound'),
                    title: 'Sound effects',
                    body:
                        'Crossing worlds, creatures answering, dice on the table.',
                    icon: Icons.graphic_eq,
                    value: settings.soundEffects,
                    onChanged: notifier.setSoundEffects,
                  ),
                  _Toggle(
                    key: const ValueKey('setting-previews'),
                    title: 'Motion clips',
                    body:
                        'Silent fan-edit loops behind banners, dossiers and the Gate.',
                    icon: Icons.slow_motion_video,
                    value: settings.autoplayPreviews,
                    onChanged: notifier.setAutoplayPreviews,
                  ),
                  _Toggle(
                    key: const ValueKey('setting-reduce'),
                    title: 'Reduce effects',
                    body: systemReduce
                        ? 'Your device already asks for reduced motion, so lightning, '
                              'flicker and big transitions are off.'
                        : 'Turn off lightning flashes, flicker and big transitions.',
                    icon: Icons.motion_photos_off,
                    value: settings.reduceEffects || systemReduce,
                    onChanged: systemReduce ? null : notifier.setReduceEffects,
                  ),
                  const Divider(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      children: [
                        Icon(Icons.live_tv, size: 20, color: world.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '$watched of ${Seasons.totalEpisodes} chapters watched',
                            style: AppText.body(
                              world.ink,
                              size: 14,
                              bold: true,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: watched == 0
                              ? null
                              : () {
                                  if (!_armed) {
                                    setState(() => _armed = true);
                                    return;
                                  }
                                  ref
                                      .read(watchProgressProvider.notifier)
                                      .clear();
                                  setState(() => _armed = false);
                                },
                          child: Text(_armed ? 'TAP AGAIN TO RESET' : 'RESET'),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        RiftPageRoute.push(
                          context,
                          const CreditsScreen(),
                          name: '/credits',
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('CREDITS & SOURCES'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                icon,
                size: 20,
                color: value ? world.accent : world.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body(world.ink, size: 15, bold: true),
                  ),
                  const SizedBox(height: 2),
                  Text(body, style: AppText.body(world.muted, size: 12.5)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: world.accent,
            ),
          ],
        ),
      ),
    );
  }
}
