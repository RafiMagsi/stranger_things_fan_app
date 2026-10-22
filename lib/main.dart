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
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
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
      themeAnimationDuration: const Duration(milliseconds: 600),
      builder: (context, child) => _WorldStack(child: child!),
      home: const SplashScreen(),
    );
  }
}

/// Sits above every route: records where fingers land (so pages can tear
/// open from the tapped card), drifts ash through the air in the Upside
/// Down, and fires the lightning storm whenever the world flips.
class _WorldStack extends ConsumerStatefulWidget {
  const _WorldStack({required this.child});

  final Widget child;

  @override
  ConsumerState<_WorldStack> createState() => _WorldStackState();
}

class _WorldStackState extends ConsumerState<_WorldStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _storm = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  int _strikes = 0;

  @override
  void dispose() {
    _storm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upsideDown = ref.watch(worldModeProvider);

    // Strike whenever the world flips (not on first build).
    ref.listen(worldModeProvider, (previous, next) {
      if (previous != next && mounted) {
        setState(() => _strikes++);
        _storm.forward(from: 0);
      }
    });

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => TapOrigin.last = e.position,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (upsideDown)
            const IgnorePointer(
              child: ParticleField(
                color: AppColors.udSpore,
                glowColor: AppColors.udGlow,
                count: 46,
                baseRadius: 1.3,
                speed: 0.6,
                opacity: 0.75,
              ),
            ),
          IgnorePointer(child: RiftFlash(controller: _storm, seed: _strikes)),
        ],
      ),
    );
  }
}
