import 'package:flutter/foundation.dart';

/// Attribution for one bundled, freely-licensed photo.
///
/// Every image in `assets/images/cast` and `assets/images/filming` comes
/// from Wikimedia Commons under a Creative Commons licence; the licence
/// requires that the author, licence and source travel with the file.
@immutable
class MediaCredit {
  const MediaCredit({
    required this.asset,
    required this.subject,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.source,
  });

  final String asset;

  /// Who or what is pictured, e.g. "Millie Bobby Brown".
  final String subject;
  final String author;
  final String license;
  final String licenseUrl;

  /// The Wikimedia Commons file page.
  final String source;
}
