import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Drop-in media resolver.
///
/// The app ships with procedural key art (gradients + icons) so it looks
/// complete out of the box and stays offline + copyright-clean. But you can
/// drop your OWN licensed/captured stills and trailers into the asset
/// folders and the app will automatically prefer them:
///
///   assets/images/KEY.jpg   (or .png / .webp)  -> poster/still
///   assets/video/KEY.mp4                        -> trailer
///
/// Keys are stable ids, e.g.:
///   assets/images/char_eleven.jpg   assets/images/season_4.jpg
///   assets/images/featured.jpg      assets/video/s5_teaser.mp4
///
/// Drop the files in, then run `flutter pub get` (and rebuild). Nothing else
/// changes — every screen already asks this resolver first and falls back to
/// procedural art when the file is absent.
///
/// We probe the bundle's asset manifest - a list of names, so finding a
/// 5 MB clip never means loading it. Results are cached so we don't
/// re-probe every frame.
class AssetMedia {
  AssetMedia._();

  static Future<Set<String>>? _manifest;

  /// Every asset path in the bundle, read once.
  static Future<Set<String>> _assets() => _manifest ??= _readManifest();

  // async/await rather than then/catchError: once the bundle has cached the
  // manifest it hands back a SynchronousFuture, whose catchError returns a
  // future that never completes.
  static Future<Set<String>> _readManifest() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Forget everything resolved so far (tests start each case fresh).
  @visibleForTesting
  static void debugReset() {
    _manifest = null;
    _imageCache.clear();
    _videoCache.clear();
  }

  static const List<String> _exts = ['.jpg', '.jpeg', '.png', '.webp'];

  static final Map<String, String?> _imageCache = {};
  static final Map<String, String?> _videoCache = {};

  /// Resolve a poster/still for [key]. Returns the asset path if a bundled
  /// file exists, else null (caller draws procedural art).
  static Future<String?> image(String key) async {
    if (_imageCache.containsKey(key)) return _imageCache[key];
    for (final e in _exts) {
      final path = 'assets/images/$key$e';
      if (await _exists(path)) {
        return _imageCache[key] = path;
      }
    }
    return _imageCache[key] = null;
  }

  /// Resolve a trailer video for [key]. Returns the asset path if bundled,
  /// else null.
  static Future<String?> video(String key) async {
    if (_videoCache.containsKey(key)) return _videoCache[key];
    for (final e in ['.mp4', '.mov', '.m4v', '.webm']) {
      final path = 'assets/video/$key$e';
      if (await _exists(path)) {
        return _videoCache[key] = path;
      }
    }
    return _videoCache[key] = null;
  }

  /// Whether any image is bundled under [key]. Useful for a quick badge.
  static Future<bool> hasImage(String key) async => await image(key) != null;
  static Future<bool> hasVideo(String key) async => await video(key) != null;

  static Future<bool> _exists(String assetPath) async =>
      (await _assets()).contains(assetPath);
}
