import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/test_env.dart';
import '../state/app_state.dart';

/// One-shot sound cues for the app's moments: crossing worlds, a creature
/// answering, dice hitting the table. Uses the original synth WAVs in
/// assets/audio. A garnish: any audio failure is swallowed so it can never
/// break the moment it decorates.
class Sfx {
  Sfx._();

  static AudioPlayer? _player;

  /// Plays [asset] if the fan has sound effects on.
  static void cue(WidgetRef ref, String asset, {double volume = 0.55}) {
    if (ref.read(settingsProvider).soundEffects) play(asset, volume: volume);
  }

  static Future<void> play(String asset, {double volume = 0.55}) async {
    if (isFlutterTest) return;
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

/// The synth score: one looping player behind the title sequence and Story
/// mode, with gentle fades in and out so it never cuts like a jump scare.
class Score {
  Score._();

  static AudioPlayer? _player;
  static int _generation = 0;

  static Future<void> start({double volume = 0.42}) async {
    if (isFlutterTest) return;
    final gen = ++_generation;
    try {
      final p = _player ??= AudioPlayer();
      await p.setReleaseMode(ReleaseMode.loop);
      if (p.state != PlayerState.playing) {
        await p.setVolume(0);
        await p.play(AssetSource('audio/theme.wav'));
      }
      for (var i = 1; i <= 10 && gen == _generation; i++) {
        await p.setVolume(volume * i / 10);
        await Future<void>.delayed(const Duration(milliseconds: 60));
      }
    } catch (_) {
      // Silent where audio isn't available.
    }
  }

  static Future<void> stop({Duration fade = const Duration(milliseconds: 900)}) async {
    if (isFlutterTest) return;
    final gen = ++_generation;
    final p = _player;
    if (p == null) return;
    try {
      final from = p.volume;
      for (var i = 9; i >= 0 && gen == _generation; i--) {
        await p.setVolume(from * i / 10);
        await Future<void>.delayed(fade ~/ 10);
      }
      if (gen == _generation) await p.stop();
    } catch (_) {}
  }
}
