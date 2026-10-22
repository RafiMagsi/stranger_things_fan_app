import 'package:flutter/foundation.dart';

/// An official trailer, hosted on Netflix's own YouTube channels.
///
/// The app never bundles or re-hosts footage: it embeds the official upload
/// through YouTube's player, which is how Netflix publishes these for fans
/// to watch and share. Every id here was checked against YouTube's oEmbed
/// endpoint to confirm the uploader is an official Netflix channel.
@immutable
class Trailer {
  const Trailer({
    required this.youtubeId,
    required this.title,
    required this.season,
    this.channel = 'Netflix',
  });

  final String youtubeId;
  final String title;
  final int season;

  /// The official channel that published it.
  final String channel;

  String get thumbnailUrl => 'https://i.ytimg.com/vi/$youtubeId/hqdefault.jpg';
  String get watchUrl => 'https://www.youtube.com/watch?v=$youtubeId';
}
