import 'package:flutter/material.dart';

@immutable
class SoundClip {
  const SoundClip({
    required this.id,
    required this.label,
    required this.caption,
    required this.asset,
    required this.accent,
    required this.icon,
  });

  final String id;
  final String label;

  /// Flavor text under the label, in dossier voice.
  final String caption;
  final String asset;
  final Color accent;
  final IconData icon;
}
