import 'package:flutter/material.dart';

import '../models/sound_clip.dart';

/// The show's own sounds, cut from the fan edits bundled in docs/videos
/// (tool/build_fan_media.py -> assets/audio/captures).
class Soundboard {
  Soundboard._();

  static const List<SoundClip> clips = [
    SoundClip(
      id: 'cap_title',
      label: 'Main Title',
      caption: 'The synth arpeggio that opens every chapter.',
      asset: 'audio/captures/main_title.m4a',
      accent: Color(0xFFE50914),
      icon: Icons.title,
    ),
    SoundClip(
      id: 'cap_hill',
      label: 'Running Up That Hill',
      caption: 'The song that pulled Max out. Keep it on repeat.',
      asset: 'audio/captures/hill.m4a',
      accent: Color(0xFFF09CB8),
      icon: Icons.album,
    ),
    SoundClip(
      id: 'cap_hill_ud',
      label: 'The Hill, from Below',
      caption: 'The same song, heard from the other side.',
      asset: 'audio/captures/hill_upside_down.m4a',
      accent: Color(0xFF5AAEFF),
      icon: Icons.flip,
    ),
    SoundClip(
      id: 'cap_vecna',
      label: 'Vecna: "Max."',
      caption: 'His voice, out of the dark. You know what comes next.',
      asset: 'audio/captures/vecna_voice.m4a',
      accent: Color(0xFFB71C1C),
      icon: Icons.record_voice_over,
    ),
    SoundClip(
      id: 'cap_chimes',
      label: 'The Four Chimes',
      caption: 'Vecna\'s clock. If you hear it, run.',
      asset: 'audio/captures/vecna_chimes.m4a',
      accent: Color(0xFFB71C1C),
      icon: Icons.notifications_active,
    ),
    SoundClip(
      id: 'cap_ticking',
      label: 'The Ticking',
      caption: 'Tick. Tock. Would you follow the sound?',
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
  ];
}
