import 'package:flutter/widgets.dart';

/// The long edge to decode a bundled image at when it fills [box]: the
/// smallest bucket that still covers it (cover-fit crops one axis, hence
/// the headroom), or null for full size. Buckets, not exact sizes, so a
/// hero flight re-decodes a couple of times rather than every frame.
int? decodeEdgeFor(Size box, double devicePixelRatio) {
  final need = box.longestSide * devicePixelRatio * 1.3;
  if (!need.isFinite) return null;
  for (final bucket in const [480, 960]) {
    if (need <= bucket) return bucket;
  }
  return null;
}

/// [asset] as an image provider sized for [box] (see [decodeEdgeFor]).
ImageProvider sizedAsset(String asset, Size box, double devicePixelRatio) {
  final edge = decodeEdgeFor(box, devicePixelRatio);
  final image = AssetImage(asset);
  return edge == null
      ? image
      : ResizeImage(
          image,
          width: edge,
          height: edge,
          policy: ResizeImagePolicy.fit,
        );
}
