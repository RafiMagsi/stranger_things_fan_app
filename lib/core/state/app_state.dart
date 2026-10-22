import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads/writes a preference, shrugging off platforms without storage (e.g.
/// widget tests): settings then simply live in memory.
Future<T?> _pref<T>(Future<T?> Function(SharedPreferences p) f) async {
  try {
    return await f(await SharedPreferences.getInstance());
  } catch (_) {
    return null;
  }
}

/// Whether we're in the Right Side Up (Hawkins) or the Upside Down.
/// Remembered between launches - if you left Hawkins, you wake up on the
/// other side.
class WorldModeNotifier extends Notifier<bool> {
  static const _key = 'upside_down';

  @override
  bool build() {
    _pref((p) async => p.getBool(_key)).then((v) {
      if (v != null && v != state) state = v;
    });
    return false; // false = Hawkins, true = Upside Down
  }

  void toggle() => set(!state);

  void set(bool upsideDown) {
    state = upsideDown;
    _pref((p) => p.setBool(_key, upsideDown));
  }
}

final worldModeProvider =
    NotifierProvider<WorldModeNotifier, bool>(WorldModeNotifier.new);

/// App preferences, saved on device.
@immutable
class AppSettings {
  const AppSettings({
    this.spoilerShield = false,
    this.soundEffects = true,
    this.reduceEffects = false,
  });

  /// Hide timeline beats and moments from chapters you haven't watched.
  final bool spoilerShield;

  /// Sound cues on big moments (the world flip).
  final bool soundEffects;

  /// No flashes, flicker or big motion - on top of the system setting.
  final bool reduceEffects;

  AppSettings copyWith({bool? spoilerShield, bool? soundEffects, bool? reduceEffects}) =>
      AppSettings(
        spoilerShield: spoilerShield ?? this.spoilerShield,
        soundEffects: soundEffects ?? this.soundEffects,
        reduceEffects: reduceEffects ?? this.reduceEffects,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _shield = 'spoiler_shield';
  static const _sound = 'sound_effects';
  static const _reduce = 'reduce_effects';

  @override
  AppSettings build() {
    _pref((p) async => AppSettings(
          spoilerShield: p.getBool(_shield) ?? false,
          soundEffects: p.getBool(_sound) ?? true,
          reduceEffects: p.getBool(_reduce) ?? false,
        )).then((saved) {
      if (saved != null) state = saved;
    });
    return const AppSettings();
  }

  void setSpoilerShield(bool v) {
    state = state.copyWith(spoilerShield: v);
    _pref((p) => p.setBool(_shield, v));
  }

  void setSoundEffects(bool v) {
    state = state.copyWith(soundEffects: v);
    _pref((p) => p.setBool(_sound, v));
  }

  void setReduceEffects(bool v) {
    state = state.copyWith(reduceEffects: v);
    _pref((p) => p.setBool(_reduce, v));
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Which chapters the fan has watched, as "S1E1" keys. Saved on the device
/// so the app can follow you through the series in order and always know
/// what's next.
class WatchProgressNotifier extends Notifier<Set<String>> {
  static const _prefsKey = 'watched_episodes';

  @override
  Set<String> build() {
    _load();
    return const {};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey);
      if (saved != null) state = {...state, ...saved};
    } catch (_) {
      // No platform storage (e.g. widget tests): progress lives in memory.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, state.toList());
    } catch (_) {
      // Same as above - keep going in memory.
    }
  }

  void toggle(String key) {
    final next = {...state};
    if (!next.remove(key)) next.add(key);
    state = next;
    _save();
  }

  void setAll(Iterable<String> keys, {required bool watched}) {
    state = watched ? {...state, ...keys} : state.difference(keys.toSet());
    _save();
  }

  void clear() {
    state = const {};
    _save();
  }
}

final watchProgressProvider =
    NotifierProvider<WatchProgressNotifier, Set<String>>(
        WatchProgressNotifier.new);
