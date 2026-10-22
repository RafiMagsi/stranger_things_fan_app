import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';

/// Hawkins ⇄ Upside Down switch. In Hawkins the knob is a warm porch light;
/// flip it and the knob literally turns upside down into a cold spore.
class WorldToggle extends ConsumerWidget {
  const WorldToggle({super.key, this.compact = false});

  /// Smaller variant for section-screen app bars.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upsideDown = ref.watch(worldModeProvider);
    final primary = upsideDown ? AppColors.udGlow : AppColors.stRed;
    final width = compact ? 60.0 : 84.0;
    final height = compact ? 30.0 : 38.0;
    final knob = compact ? 22.0 : 28.0;
    final label = upsideDown ? 'Return to Hawkins' : 'Enter the Upside Down';

    return Semantics(
      button: true,
      toggled: upsideDown,
      label: label,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          key: const ValueKey('world-toggle'),
          onTap: () {
            HapticFeedback.heavyImpact();
            ref.read(worldModeProvider.notifier).toggle();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            width: width,
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: upsideDown
                    ? [AppColors.udFogHi, AppColors.udVoid]
                    : [AppColors.stRedDeep, AppColors.hawkinsBg],
              ),
              border: Border.all(color: primary.withValues(alpha: 0.7)),
              boxShadow: [
                BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 14),
              ],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 460),
              curve: Curves.easeOutBack,
              alignment: upsideDown ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 460),
                curve: Curves.easeOutBack,
                turns: upsideDown ? 0.5 : 0,
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: upsideDown
                          ? [AppColors.udSpore, AppColors.udGlow, const Color(0xFF13325A)]
                          : [const Color(0xFFFFE08A), AppColors.stRed, AppColors.stRedDeep],
                      stops: const [0, 0.55, 1],
                    ),
                    boxShadow: [
                      BoxShadow(color: primary.withValues(alpha: 0.9), blurRadius: 10),
                    ],
                  ),
                  child: Icon(
                    upsideDown ? Icons.blur_on : Icons.home_rounded,
                    size: knob * 0.6,
                    color: upsideDown ? AppColors.udVoid : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
