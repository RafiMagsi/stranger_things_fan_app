import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../theme/world_palette.dart';
import 'neon_card.dart';
import 'st_effects.dart';
import 'world_toggle.dart';

/// Shared chrome for every section screen: a neon title over a burning
/// tube, the world's atmosphere behind the content (the red title-sequence
/// glow in Hawkins; storm light and creeping vines in the Upside Down), and
/// a faint CRT texture on top — so each page reads as the show.
class STScaffold extends StatelessWidget {
  const STScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: subtitle == null ? 60 : 70,
        automaticallyImplyLeading: false,
        leadingWidth: canPop ? 60 : 0,
        leading: canPop ? const NeonBackButton() : null,
        titleSpacing: canPop ? 2 : 20,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.neon(size: 24, color: world.accent)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppText.dossier(world.muted, size: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        actions: [
          ...actions,
          const Padding(
            padding: EdgeInsets.only(left: 4, right: 14),
            child: Center(child: WorldToggle(compact: true)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: NeonTube(color: world.accent, intensity: 0.55, thickness: 1.2),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WorldAtmosphere(),
          body,
          const CrtOverlay(opacity: 0.07, animate: false),
        ],
      ),
    );
  }
}

/// The light that leaks into a screen: a red bloom from above in Hawkins;
/// in the Upside Down, cold storm haze, a distant red flash, and vines
/// reaching in from the corners.
class WorldAtmosphere extends StatelessWidget {
  const WorldAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1.25),
                radius: 1.25,
                colors: world.upsideDown
                    ? [AppColors.udFogHi.withValues(alpha: 0.9), world.bg.withValues(alpha: 0)]
                    : [AppColors.stRed.withValues(alpha: 0.16), world.bg.withValues(alpha: 0)],
              ),
            ),
          ),
          if (world.upsideDown) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.85, -0.9),
                  radius: 0.7,
                  colors: [
                    AppColors.udLightning.withValues(alpha: 0.12),
                    AppColors.udLightning.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            const VineOverlay(),
          ],
        ],
      ),
    );
  }
}

/// Back button in a neon ring.
class NeonBackButton extends StatelessWidget {
  const NeonBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return Center(
      child: Semantics(
        button: true,
        label: 'Back',
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
              border: Border.all(color: world.accent.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(color: world.accent.withValues(alpha: 0.3), blurRadius: 12),
              ],
            ),
            child: Icon(Icons.arrow_back_rounded, color: world.ink, size: 20),
          ),
        ),
      ),
    );
  }
}
