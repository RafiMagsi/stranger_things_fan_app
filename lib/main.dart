import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/state/app_state.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/particles.dart';
import 'core/widgets/rift_route.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const ProviderScope(child: StrangerThingsApp()));
}

class StrangerThingsApp extends ConsumerWidget {
  const StrangerThingsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upsideDown = ref.watch(worldModeProvider);

    return MaterialApp(
      title: 'Stranger Things — Fan App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.hawkins,
      darkTheme: AppTheme.upsideDown,
      themeMode: upsideDown ? ThemeMode.dark : ThemeMode.light,
      home: _WorldStack(child: const SplashScreen()),
    );
  }
}

/// Wraps the app so the spore particle field and the rift flash sit above
/// content but below dialogs. Particles render only in the Upside Down.
class _WorldStack extends ConsumerStatefulWidget {
  const _WorldStack({required this.child});

  final Widget child;

  @override
  ConsumerState<_WorldStack> createState() => _WorldStackState();
}

class _WorldStackState extends ConsumerState<_WorldStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _rift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upsideDown = ref.watch(worldModeProvider);

    // Fire the rift sweep whenever the world flips (not on first build).
    ref.listen(worldModeProvider, (previous, next) {
      if (previous != next && mounted) {
        _rift.forward(from: 0);
      }
    });

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (upsideDown)
          const IgnorePointer(
            child: ParticleField(
              color: AppColors.udSpore,
              glowColor: AppColors.udSpore,
              count: 40,
              baseRadius: 1.4,
              speed: 0.7,
              opacity: 0.7,
            ),
          ),
        // Signature transition: a red-teal rift sweeping across the screen
        // each time Hawkins <-> the Upside Down is toggled.
        IgnorePointer(child: RiftFlash(controller: _rift)),
      ],
    );
  }
}
