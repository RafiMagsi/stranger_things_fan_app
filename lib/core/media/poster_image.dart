import 'package:flutter/material.dart';

import 'asset_media.dart';

/// Renders a real bundled still for [assetKey] if one exists, otherwise the
/// caller's [fallback] procedural art. This is the seam that lets fans drop
/// licensed key art into assets/images/ without touching any screen code.
class PosterImage extends StatefulWidget {
  const PosterImage({
    super.key,
    required this.assetKey,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final String assetKey;
  final Widget fallback;
  final BoxFit fit;

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

  Future<void> _resolve() async {
    final p = await AssetMedia.image(widget.assetKey);
    if (!mounted) return;
    setState(() {
      _path = p;
      _resolved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) return widget.fallback;
    final path = _path;
    if (path == null) return widget.fallback;
    return Image.asset(
      path,
      fit: widget.fit,
      // If the file is declared but unreadable, fall back gracefully.
      errorBuilder: (_, _, _) => widget.fallback,
    );
  }
}

/// Whether a still is bundled for [assetKey]. Used to show a small "STILL"
/// badge so fans know their drop-in was picked up.
Future<bool> hasStill(String assetKey) => AssetMedia.hasImage(assetKey);
