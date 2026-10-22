import 'package:audioplayers/audioplayers.dart';

/// One-shot sound cues for the app's big moments (the world flip). Uses the
/// original synth WAVs in assets/audio. A garnish: any audio failure is
/// swallowed so it can never break the moment it decorates.
class Sfx {
  Sfx._();

  static AudioPlayer? _player;

  static Future<void> play(String asset, {double volume = 0.55}) async {
    try {
      final p = _player ??= AudioPlayer();
      await p.stop();
      await p.setVolume(volume);
      await p.play(AssetSource(asset));
    } catch (_) {
      // No audio on this device/platform - stay silent.
    }
  }
}
