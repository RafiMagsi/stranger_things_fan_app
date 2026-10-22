import 'package:flutter_riverpod/flutter_riverpod.dart';

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
