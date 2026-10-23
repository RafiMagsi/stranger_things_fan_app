import 'package:flutter/material.dart';

import '../core/media/decode_size.dart';
import '../core/theme/text_styles.dart';
import '../core/theme/world_palette.dart';
import '../core/widgets/neon_card.dart';
import '../core/widgets/st_scaffold.dart';
import '../core/widgets/world_fx.dart';
import '../data/fan_media.dart';

/// The gallery wall: fan art from the media pack, hung two to a row with
/// the wide pieces spanning both, each credited to its artist. Tap one to
/// look closer - pinch to zoom, swipe between pieces, swipe down to leave.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  /// Portraits pair up; landscapes get a row of their own.
  static List<List<FanArt>> _rows(List<FanArt> art) {
    final rows = <List<FanArt>>[];
    FanArt? waiting;
    for (final a in art) {
      if (a.aspect > 1) {
        rows.add([a]);
      } else if (waiting == null) {
        waiting = a;
      } else {
        rows.add([waiting, a]);
        waiting = null;
      }
    }
    if (waiting != null) rows.add([waiting]);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows(FanMedia.art);
    return STScaffold(
      title: 'FAN ART',
      subtitle: '${FanMedia.art.length} pieces · the gallery wall',
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: rows.length,
        itemBuilder: (context, r) {
          final row = rows[r];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FlickerIn(
              index: r,
              child: Row(
                children: [
                  for (final (k, a) in row.indexed) ...[
                    if (k > 0) const SizedBox(width: 12),
                    Expanded(
                      child: AspectRatio(
                        // A pair shares the taller piece's shape.
                        aspectRatio: row.map((x) => x.aspect).reduce((p, q) => p < q ? p : q),
                        child: _ArtCard(
                          art: a,
                          onTap: () => _open(context, FanMedia.art.indexOf(a)),
                        ),
                      ),
                    ),
                  ],
                  // A portrait left on its own still hangs at half width.
                  if (row.length == 1 && row.first.aspect < 1) ...[
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _open(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, _, _) => _Viewer(start: index),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }
}

class _ArtCard extends StatelessWidget {
  const _ArtCard({required this.art, required this.onTap});

  final FanArt art;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return NeonCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'fan-${art.slug}',
            child: WorldGrade(
              strength: 0.7,
              child: LayoutBuilder(
                builder: (context, box) => Image(
                  image: sizedAsset(art.asset, box.biggest, dpr),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => ColoredBox(color: world.card),
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xD9000000)],
                stops: [0.6, 1],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  art.title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.headline(Colors.white, size: 13.5, letterSpacing: 0.05),
                ),
                Text(
                  art.artist ?? 'Fan art',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.dossier(Colors.white70, size: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen look at one piece: pinch to zoom, swipe sideways for the
/// next, swipe down (or the cross) to go back to the wall.
class _Viewer extends StatefulWidget {
  const _Viewer({required this.start});

  final int start;

  @override
  State<_Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<_Viewer> {
  late final _pages = PageController(initialPage: widget.start);
  late int _index = widget.start;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final art = FanMedia.art[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (d) {
          if ((d.primaryVelocity ?? 0) > 500) Navigator.of(context).maybePop();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pages,
              itemCount: FanMedia.art.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final a = FanMedia.art[i];
                return InteractiveViewer(
                  maxScale: 4,
                  child: Center(
                    child: Hero(
                      tag: 'fan-${a.slug}',
                      child: Image.asset(a.asset, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      key: const ValueKey('viewer-close'),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        '${_index + 1} / ${FanMedia.art.length}',
                        style: AppText.label(Colors.white70).copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC000000)],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(art.title.toUpperCase(), style: AppText.headline(Colors.white, size: 20)),
                        const SizedBox(height: 4),
                        Text(
                          '${art.credit} · personal fan-media pack',
                          style: AppText.dossier(Colors.white70, size: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
