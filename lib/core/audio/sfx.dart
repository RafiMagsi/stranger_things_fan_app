import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/test_env.dart';
import '../state/app_state.dart';

/// `--dart-define=AUDIO_LOG=true` prints what the audio is doing.
const bool kAudioLog = bool.fromEnvironment('AUDIO_LOG');

void _log(String message) {
  if (kAudioLog) debugPrint('AUDIO $message');
}

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
      // play() swaps the source itself; a stop first would also switch
      // the audio session off between cues.
      final p = _player ??= AudioPlayer();
      await p.play(AssetSource(asset), volume: volume);
    } catch (e) {
      // No audio on this device/platform - stay silent.
      _log('sfx $asset failed: $e');
    }
  }
}

/// A screen's hold on the music: its own track, or silence.
class SoundtrackClaim {
  SoundtrackClaim._(this.asset, this.volume, this.loop);

  /// Null claims silence (the screen has sound of its own).
  final String? asset;
  final double volume;
  final bool loop;
}

/// The app's music, cut from the fan edits (tool/build_fan_media.py).
///
/// One looping player and a stack of who wants what:
///  - the shell sets the ambient track: Running Up That Hill in Hawkins,
///    and in the Upside Down the same song slowed and drowned, as if heard
///    from the other side;
///  - a screen can claim the floor with a track of its own (the title
///    sequence, Story mode's theme) or with silence (anything that makes
///    its own sound: the projector, a trailer, the soundboard);
///  - the newest claim wins, and releasing it falls back to the one below,
///    then to the ambient track.
///
/// Everything crossfades. It stays quiet when Music is off, while the app
/// is in the background, and in tests.
class Soundtrack {
  Soundtrack._();

  static const title = 'audio/captures/main_title.m4a';
  static const storyTheme = 'audio/captures/story_theme.m4a';
  static const hill = 'audio/captures/hill.m4a';
  static const hillUpsideDown = 'audio/captures/hill_upside_down.m4a';

  static const _ambientVolume = 0.32;

  static String? _ambient;
  static final List<SoundtrackClaim> _claims = [];
  static bool _enabled = true;
  static bool _foreground = true;

  /// Sets up the audio session once, at launch: the playback category (so
  /// sound plays with the ring/silent switch on, as video does) mixing with
  /// other audio - the app's own video players included, so the two never
  /// cut each other off on a real phone.
  static void configure() {
    if (isFlutterTest) return;
    AudioLogger.logLevel = kAudioLog ? AudioLogLevel.info : AudioLogLevel.error;
    if (kIsWeb) return;
    AudioPlayer.global
        .setAudioContext(
          AudioContextConfig(
            respectSilence: false,
            stayAwake: false,
            focus: AudioContextConfigFocus.mixWithOthers,
          ).build(),
        )
        .catchError((Object e) => _log('audio context failed: $e'));
  }

  /// Retries whatever should be playing (a browser releases audio on the
  /// first touch). Cheap when it's already playing.
  static void wake() {
    if (!kIsWeb || _woken) return;
    _woken = true;
    _apply();
  }

  static bool _woken = false;

  /// What should be audible right now: asset, volume, loop - or null.
  @visibleForTesting
  static ({String asset, double volume, bool loop})? get wanted {
    if (!_enabled || !_foreground) return null;
    if (_claims.isNotEmpty) {
      final top = _claims.last;
      final asset = top.asset;
      return asset == null
          ? null
          : (asset: asset, volume: top.volume, loop: top.loop);
    }
    final ambient = _ambient;
    return ambient == null
        ? null
        : (asset: ambient, volume: _ambientVolume, loop: true);
  }

  /// Music on or off (the setting).
  static void setEnabled(bool enabled) {
    if (_enabled == enabled) return;
    _enabled = enabled;
    _apply();
  }

  /// The app went to the background, or came back.
  static void setForeground(bool foreground) {
    if (_foreground == foreground) return;
    _foreground = foreground;
    _apply(fadeOut: const Duration(milliseconds: 250));
  }

  /// The bed under everything; null for none.
  static void setAmbient(String? asset) {
    if (_ambient == asset) return;
    _ambient = asset;
    _apply();
  }

  /// Takes the floor with [asset] (null: silence) until [release]d. A
  /// track that doesn't [loop] releases itself when it ends.
  static SoundtrackClaim claim(
    String? asset, {
    double volume = 0.55,
    bool loop = true,
  }) {
    final c = SoundtrackClaim._(asset, volume, loop);
    _claims.add(c);
    _apply();
    return c;
  }

  static void release(
    SoundtrackClaim claim, {
    Duration fadeOut = const Duration(milliseconds: 700),
  }) {
    if (!_claims.remove(claim)) return;
    _apply(fadeOut: fadeOut);
  }

  /// Forget everything (tests).
  @visibleForTesting
  static void debugReset() {
    _ambient = null;
    _claims.clear();
    _enabled = true;
    _foreground = true;
  }

  // ---- The player side: crossfades between whatever [wanted] says. ----

  static AudioPlayer? _player;
  static StreamSubscription<void>? _done;
  static String? _loaded;
  static bool _audible = false;
  static int _generation = 0;

  static Future<void> _apply({
    Duration fadeOut = const Duration(milliseconds: 700),
  }) async {
    if (isFlutterTest) return;
    final gen = ++_generation;
    final want = wanted;
    _log('soundtrack -> ${want?.asset ?? 'silence'} (was ${_loaded ?? '-'})');
    try {
      final p = _player ??= AudioPlayer();
      _done ??= p.onPlayerComplete.listen((_) => _finished());
      if (want == null) {
        if (_audible) await _fade(p, p.volume, 0, fadeOut, gen);
        if (gen != _generation) return;
        _audible = false;
        await p.pause();
        return;
      }
      if (_loaded != want.asset) {
        if (_audible) await _fade(p, p.volume, 0, fadeOut, gen);
        if (gen != _generation) return;
        await p.stop();
        await p.setReleaseMode(want.loop ? ReleaseMode.loop : ReleaseMode.stop);
        await p.setVolume(0);
        await p.setSource(AssetSource(want.asset));
        if (gen != _generation) return;
        _loaded = want.asset;
      }
      await p.resume();
      _audible = true;
      await _fade(
        p,
        p.volume,
        want.volume,
        const Duration(milliseconds: 1400),
        gen,
      );
    } catch (e) {
      // Silent where audio isn't available.
      _log('soundtrack failed: $e');
    }
  }

  /// A one-shot track ended: its claim lets go.
  static void _finished() {
    final playing = _loaded;
    _loaded = null;
    _audible = false;
    final top = _claims.isEmpty ? null : _claims.last;
    if (top != null && !top.loop && top.asset == playing) _claims.removeLast();
    _apply();
  }

  static Future<void> _fade(
    AudioPlayer p,
    double from,
    double to,
    Duration d,
    int gen,
  ) async {
    const steps = 12;
    for (var i = 1; i <= steps && gen == _generation; i++) {
      await p.setVolume(from + (to - from) * i / steps);
      await Future<void>.delayed(d ~/ steps);
    }
  }
}

/// Holds the music silent (or on [asset]) for as long as the screen that
/// mixes it in is up.
mixin SoundtrackClaimMixin<T extends StatefulWidget> on State<T> {
  SoundtrackClaim? _soundtrackClaim;

  /// What this screen plays instead of the music; null for silence.
  String? get soundtrackAsset => null;
  double get soundtrackVolume => 0.55;

  @override
  void initState() {
    super.initState();
    _soundtrackClaim = Soundtrack.claim(
      soundtrackAsset,
      volume: soundtrackVolume,
    );
  }

  @override
  void dispose() {
    final c = _soundtrackClaim;
    if (c != null) Soundtrack.release(c);
    super.dispose();
  }
}
