import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Soft glows for the app's many small lights - bulbs, embers, spores,
/// fireflies - drawn from one pre-rendered sprite in a single batched
/// `drawAtlas` call. A blurred circle per light (MaskFilter) or a fresh
/// gradient per light every frame costs far more on a phone's GPU and CPU;
/// this costs about the same as drawing one picture.
class GlowBatch {
  final List<RSTransform> _transforms = [];
  final List<Color> _colors = [];

  static const double _sprite = 64;
  static ui.Image? _image;
  static final List<Rect> _rects = [];

  /// The sprite: white at the centre, fading to nothing at the edge.
  static ui.Image get _glow => _image ??= () {
    final recorder = ui.PictureRecorder();
    const c = Offset(_sprite / 2, _sprite / 2);
    Canvas(recorder).drawCircle(
      c,
      _sprite / 2,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          _sprite / 2,
          const [Color(0xFFFFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF)],
          const [0, 0.35, 1],
        ),
    );
    return recorder.endRecording().toImageSync(
      _sprite.toInt(),
      _sprite.toInt(),
    );
  }();

  /// Queues a glow of [radius] at [center], tinted [color] (its alpha is
  /// the glow's strength).
  void add(Offset center, double radius, Color color) {
    if (color.a <= 0.004 || radius <= 0) return;
    _transforms.add(
      RSTransform.fromComponents(
        rotation: 0,
        scale: radius / (_sprite / 2),
        anchorX: _sprite / 2,
        anchorY: _sprite / 2,
        translateX: center.dx,
        translateY: center.dy,
      ),
    );
    _colors.add(color);
  }

  /// Draws everything queued, in one call, and empties the batch.
  void paint(Canvas canvas) {
    if (_transforms.isEmpty) return;
    while (_rects.length < _transforms.length) {
      _rects.add(const Rect.fromLTWH(0, 0, _sprite, _sprite));
    }
    canvas.drawAtlas(
      _glow,
      _transforms,
      _rects.sublist(0, _transforms.length),
      _colors,
      BlendMode.modulate,
      null,
      Paint()..filterQuality = FilterQuality.low,
    );
    _transforms.clear();
    _colors.clear();
  }
}

/// Holds an animation's 0..1 value to [fps] steps over a loop of
/// [period]: painters whose `shouldRepaint` compares it then repaint at
/// that rate instead of every display frame.
double steppedValue(double value, Duration period, {int fps = 30}) {
  final steps = (period.inMilliseconds * fps / 1000).round();
  if (steps <= 0) return value;
  return (value * steps).floorToDouble() / steps;
}
