import 'package:flutter/material.dart';

import '../models/sound_clip.dart';

/// Original procedurally-synthesized cues (see tool/generate_audio.py).
/// No copyrighted recordings - all homage, none of the real score.
class Soundboard {
  Soundboard._();

  static const List<SoundClip> clips = [
    SoundClip(
      id: 'theme',
      label: 'Hawkins Theme',
      caption: 'The synth that put a small town on the map.',
      asset: 'audio/theme.wav',
      accent: Color(0xFFE50914),
      icon: Icons.graphic_eq,
    ),
    SoundClip(
      id: 'screech',
      label: 'Demogorgon Screech',
      caption: 'Petal-face says hello. Do not answer.',
      asset: 'audio/screech.wav',
      accent: Color(0xFFEF5350),
      icon: Icons.pets,
    ),
    SoundClip(
      id: 'static',
      label: 'Radio Static',
      caption: 'Between the bands, something listens back.',
      asset: 'audio/static.wav',
      accent: Color(0xFF78909C),
      icon: Icons.wifi_tethering,
    ),
    SoundClip(
      id: 'dice',
      label: 'The D20',
      caption: 'Natural 20, or the party dies trying.',
      asset: 'audio/dice.wav',
      accent: Color(0xFFF5C518),
      icon: Icons.casino,
    ),
    SoundClip(
      id: 'squelch',
      label: 'Walkie Squelch',
      caption: 'Party comms. Channel one, always.',
      asset: 'audio/squelch.wav',
      accent: Color(0xFF66BB6A),
      icon: Icons.radio,
    ),
    SoundClip(
      id: 'portal',
      label: 'Portal Rumble',
      caption: 'The gate breathing. It never sleeps.',
      asset: 'audio/portal.wav',
      accent: Color(0xFF7E57C2),
      icon: Icons.blur_on,
    ),
    SoundClip(
      id: 'chime',
      label: 'Lightbulb Chime',
      caption: 'A-O spells hope on a living room wall.',
      asset: 'audio/chime.wav',
      accent: Color(0xFFFFEE58),
      icon: Icons.lightbulb,
    ),
    SoundClip(
      id: 'coin',
      label: 'Arcade Coin',
      caption: 'Missed the high score? Insert coin, try again.',
      asset: 'audio/coin.wav',
      accent: Color(0xFF26C6DA),
      icon: Icons.sports_esports,
    ),
    SoundClip(
      id: 'power',
      label: 'Eleven\'s Power',
      caption: 'The hum before the nosebleed.',
      asset: 'audio/power.wav',
      accent: Color(0xFFF09CB8),
      icon: Icons.bolt,
    ),
    SoundClip(
      id: 'clock',
      label: 'Vecna\'s Clock',
      caption: 'The grandfather clock counts you down.',
      asset: 'audio/clock.wav',
      accent: Color(0xFF8E4585),
      icon: Icons.hourglass_bottom,
    ),
    SoundClip(
      id: 'heartbeat',
      label: 'Heartbeat',
      caption: 'Lub-dub. Someone is very close.',
      asset: 'audio/heartbeat.wav',
      accent: Color(0xFFEF5350),
      icon: Icons.favorite,
    ),
    SoundClip(
      id: 'vines',
      label: 'Vine Rustle',
      caption: 'The Upside Down, breathing.',
      asset: 'audio/vines.wav',
      accent: Color(0xFF6D4BC3),
      icon: Icons.grass,
    ),
  ];
}
