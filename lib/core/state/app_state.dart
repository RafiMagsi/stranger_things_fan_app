import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether we're in the Right Side Up (Hawkins) or the Upside Down.
class WorldModeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = Hawkins, true = Upside Down

  void toggle() => state = !state;
  void set(bool upsideDown) => state = upsideDown;
}

final worldModeProvider =
    NotifierProvider<WorldModeNotifier, bool>(WorldModeNotifier.new);

/// Muted master volume for the soundboard/ambient audio.
class AudioEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final audioEnabledProvider =
    NotifierProvider<AudioEnabledNotifier, bool>(AudioEnabledNotifier.new);

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
}

final watchProgressProvider =
    NotifierProvider<WatchProgressNotifier, Set<String>>(
        WatchProgressNotifier.new);
