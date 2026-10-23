import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// How the app identifies itself to YouTube's embedded player, and what to
/// tell the viewer when YouTube won't play.
///
/// YouTube requires every embed to say who is embedding it. An app WebView
/// that loads the player from local HTML does that through the page's base
/// URL (and so its Referer), which must be `https://<app id>`, lower-cased.
/// Without it YouTube answers "Error 153 - video player configuration
/// error"; the package default (posing as youtube-nocookie.com) is no
/// identity at all. See
/// https://developers.google.com/youtube/terms/required-minimum-functionality
abstract final class YoutubeEmbed {
  /// Must match `PRODUCT_BUNDLE_IDENTIFIER` in ios/Runner.xcodeproj and
  /// `applicationId` in android/app/build.gradle.kts (a test checks).
  static const iosAppId = 'com.hawkins.strangerThingsFanApp';
  static const androidAppId = 'com.hawkins.stranger_things_fan_app';

  /// This platform's embedder identity. Null on the web, where the player
  /// already uses the page's real origin.
  static String? get origin {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'https://$androidAppId',
      _ => 'https://${iosAppId.toLowerCase()}',
    };
  }

  /// [params] with the app's identity attached.
  static YoutubePlayerParams identify(YoutubePlayerParams params) =>
      params.copyWith(origin: origin);
}

/// Why a trailer isn't playing, in the viewer's terms.
enum TrailerFailure {
  /// The IFrame API never answered: offline, or YouTube is unreachable.
  unreachable(
    'NO SIGNAL',
    'Couldn\'t reach YouTube. Check your connection and try again.',
  ),

  /// Removed or made private.
  removed('TAPE MISSING', 'This trailer is no longer on YouTube.'),

  /// YouTube refused to play it here (errors 101/150/152/153). Either the
  /// owner switched embedding off, or YouTube wants this device or network
  /// to sign in first ("confirm you're not a bot") - which an embedded
  /// player can't do, but the YouTube app can.
  refused(
    'TRANSMISSION BLOCKED',
    'YouTube won\'t play this inside the app right now. It will play in the '
        'YouTube app.',
  );

  const TrailerFailure(this.title, this.message);

  final String title;
  final String message;

  /// The failure behind a player error, or null when there isn't one.
  static TrailerFailure? fromError(YoutubeError error) => switch (error) {
    YoutubeError.none => null,
    YoutubeError.videoNotFound || YoutubeError.cannotFindVideo => removed,
    _ => refused,
  };
}
