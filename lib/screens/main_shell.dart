import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'more_screen.dart';
import 'upside_down_screen.dart';
import 'watch_screen.dart';

/// One tab of the app.
typedef _Tab = ({String label, IconData icon, IconData active, String key});

const List<_Tab> _tabs = [
  (label: 'HOME', icon: Icons.home_outlined, active: Icons.home, key: 'nav-home'),
  (label: 'EXPLORE', icon: Icons.explore_outlined, active: Icons.explore, key: 'nav-explore'),
  (label: 'WATCH', icon: Icons.play_circle_outline, active: Icons.play_circle, key: 'nav-watch'),
  (label: 'UPSIDE DOWN', icon: Icons.flip_outlined, active: Icons.flip, key: 'nav-upside-down'),
  (label: 'MORE', icon: Icons.menu, active: Icons.menu_open, key: 'nav-more'),
];

/// The app's frame: five tabs behind a neon bar at the bottom of the
/// screen. Tabs are built the first time they're visited and then kept, so
/// each keeps its scroll position; the ones you can't see stop animating.
/// Back on any other tab returns Home before it leaves the app.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _tab = widget.initialTab;
  late final Set<int> _visited = {_tab};

  Widget _page(int i) => switch (i) {
    0 => const HomeScreen(),
    1 => const ExploreScreen(),
    2 => const WatchScreen(),
    3 => const UpsideDownScreen(),
    _ => const MoreScreen(),
  };

  void _select(int i) {
    if (i == _tab) return;
    HapticFeedback.selectionClick();
    setState(() {
      _tab = i;
      _visited.add(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [
            for (var i = 0; i < _tabs.length; i++)
              TickerMode(
                enabled: i == _tab,
                child: _visited.contains(i) ? _page(i) : const SizedBox.shrink(),
              ),
          ],
        ),
        bottomNavigationBar: NeonNavBar(index: _tab, onSelect: _select),
      ),
    );
  }
}

/// The bottom bar: a dark strip under a thin burning tube; the current
/// tab lights up in the world's neon, the rest wait in the dark.
class NeonNavBar extends StatelessWidget {
  const NeonNavBar({super.key, required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.lerp(world.bg, Colors.black, 0.45),
        border: Border(top: BorderSide(color: world.accent.withValues(alpha: 0.35))),
        boxShadow: [
          BoxShadow(color: world.accent.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavItem(
                    tab: _tabs[i],
                    selected: i == index,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final color = selected ? world.accent : world.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      child: InkResponse(
        key: ValueKey(tab.key),
        onTap: onTap,
        radius: 36,
        highlightColor: Colors.transparent,
        splashColor: world.accent.withValues(alpha: 0.15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The tube over the lit tab.
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: selected ? 26 : 0,
              height: 2.5,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: world.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: world.accent, blurRadius: 8)],
              ),
            ),
            Icon(
              selected ? tab.active : tab.icon,
              size: 23,
              color: color,
              shadows: selected ? [Shadow(color: world.accent, blurRadius: 12)] : null,
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: AppText.headline(color, size: 9.5, weight: selected ? 600 : 500, letterSpacing: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}
