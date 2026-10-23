import 'package:flutter/material.dart';

import '../models/sound_clip.dart';

/// Original procedurally-synthesized cues (see tool/generate_audio.py),
/// plus a few captures cut from the fan clips bundled in docs/videos
/// (assets/audio/captures). The synth cues are all homage, none of the
/// real score; the captures are the fan edits' own sound.
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
    // Cut from the fan edits in the media pack (tool/build_fan_media.py).
    SoundClip(
      id: 'cap_chimes',
      label: 'The Four Chimes',
      caption: 'Four chimes. If you hear them, run.',
      asset: 'audio/captures/vecna_chimes.m4a',
      accent: Color(0xFFB71C1C),
      icon: Icons.notifications_active,
    ),
    SoundClip(
      id: 'cap_ticking',
      label: 'The Ticking',
      caption: 'Tock. Tock. Would you follow the sound?',
      asset: 'audio/captures/clock_ticking.m4a',
      accent: Color(0xFF8E4585),
      icon: Icons.timer,
    ),
    SoundClip(
      id: 'cap_almost',
      label: 'It\'s Almost Time',
      caption: 'The grandfather clock, winding down.',
      asset: 'audio/captures/almost_time.m4a',
      accent: Color(0xFF4FC3F7),
      icon: Icons.hourglass_bottom,
    ),
    SoundClip(
      id: 'cap_hill',
      label: 'Running Up That Hill',
      caption: 'The song that pulled Max out. Keep it on repeat.',
      asset: 'audio/captures/running_up_that_hill.m4a',
      accent: Color(0xFFF09CB8),
      icon: Icons.album,
    ),
    SoundClip(
      id: 'cap_1987',
      label: 'In the Fall of 1987',
      caption: 'One last adventure begins.',
      asset: 'audio/captures/fall_of_1987.m4a',
      accent: Color(0xFFF5C518),
      icon: Icons.campaign,
    ),
    SoundClip(
      id: 'cap_finale',
      label: 'Finale Stinger',
      caption: 'The finale edit, straight from the Reel.',
      asset: 'audio/captures/finale.m4a',
      accent: Color(0xFFE50914),
      icon: Icons.local_fire_department,
    ),
  ];
}
