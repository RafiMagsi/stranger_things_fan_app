import 'package:flutter/material.dart';

import '../widgets/world_fx.dart';
import 'asset_media.dart';
import 'decode_size.dart';

/// Renders a real bundled still for [assetKey] if one exists, otherwise the
/// caller's [fallback] procedural art. This is the seam that lets fans drop
/// their own key art into assets/images/ without touching any screen code.
///
/// Stills follow the world like everything else (graded cold in the Upside
/// Down) and are decoded near the size they're drawn at.
class PosterImage extends StatefulWidget {
  const PosterImage({
    super.key,
    required this.assetKey,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String assetKey;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<PosterImage> createState() => _PosterImageState();
}

class _PosterImageState extends State<PosterImage> {
  String? _path;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant PosterImage old) {
    super.didUpdateWidget(old);
    if (old.assetKey != widget.assetKey) _resolve();
  }

  Future<void> _resolve() async {
    final key = widget.assetKey;
    final p = await AssetMedia.image(key);
    if (!mounted || key != widget.assetKey) return;
    setState(() {
      _path = p;
      _resolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final path = _path;
    if (!_resolved || path == null) return widget.fallback;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return WorldGrade(
      strength: 0.8,
      child: LayoutBuilder(
        builder: (context, box) => Image(
          image: sizedAsset(path, box.biggest, dpr),
          fit: widget.fit,
          alignment: widget.alignment,
          gaplessPlayback: true,
          // If the file is declared but unreadable, fall back gracefully.
          errorBuilder: (_, _, _) => widget.fallback,
        ),
      ),
    );
  }
}

/// Whether a still is bundled for [assetKey]. Used to show a small "STILL"
/// badge so fans know their drop-in was picked up.
Future<bool> hasStill(String assetKey) => AssetMedia.hasImage(assetKey);
