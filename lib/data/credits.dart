import '../models/media_credit.dart';

/// Every bundled photo and where it came from.
///
/// Cast portraits are the actors at public events, used to say "played by";
/// they are not stills from the show. Filming-location photos show the real
/// places that stood in for Hawkins. All are from Wikimedia Commons, resized
/// for the app and colour-graded at display time; adaptations of CC BY-SA
/// works are offered under the same licence.
class MediaCredits {
  MediaCredits._();

  static const _by2 = 'https://creativecommons.org/licenses/by/2.0';
  static const _by3 = 'https://creativecommons.org/licenses/by/3.0';
  static const _by4 = 'https://creativecommons.org/licenses/by/4.0';
  static const _bySa3 = 'https://creativecommons.org/licenses/by-sa/3.0';
  static const _bySa4 = 'https://creativecommons.org/licenses/by-sa/4.0';
  static const _cc0 = 'https://creativecommons.org/publicdomain/zero/1.0/';
  static const _commons = 'https://commons.wikimedia.org/wiki/File:';

  static const List<MediaCredit> all = [
    // ---- Cast ----
    MediaCredit(
      asset: 'assets/images/cast/eleven.jpg',
      subject: 'Millie Bobby Brown',
      author: 'TheWrap',
      license: 'CC BY 3.0',
      licenseUrl: _by3,
      source: '${_commons}Millie_Bobby_Brown_2025_(1).png',
    ),
    MediaCredit(
      asset: 'assets/images/cast/mike.jpg',
      subject: 'Finn Wolfhard',
      author: 'Grace Repasky',
      license: 'CC0',
      licenseUrl: _cc0,
      source: '${_commons}Finn_Wolfhard_2024.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/dustin.jpg',
      subject: 'Gaten Matarazzo',
      author: 'Philip Romano',
      license: 'CC BY-SA 4.0',
      licenseUrl: _bySa4,
      source: '${_commons}Gaten_Matarazzo.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/lucas.jpg',
      subject: 'Caleb McLaughlin',
      author: 'La Gazzetta dello Sport',
      license: 'CC BY 3.0',
      licenseUrl: _by3,
      source: '${_commons}Caleb_McLaughlin_2025_(1).png',
    ),
    MediaCredit(
      asset: 'assets/images/cast/will.jpg',
      subject: 'Noah Schnapp',
      author: 'Kevin Paul',
      license: 'CC BY 4.0',
      licenseUrl: _by4,
      source: '${_commons}Noah_Schnapp_-_NBFF_2025.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/max.jpg',
      subject: 'Sadie Sink',
      author: 'Super Festivals from Ft. Lauderdale, USA',
      license: 'CC BY 2.0',
      licenseUrl: _by2,
      source: '${_commons}Sadie_Sink_(43914734441).jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/steve.jpg',
      subject: 'Joe Keery',
      author: 'Philip Romano',
      license: 'CC BY-SA 4.0',
      licenseUrl: _bySa4,
      source: '${_commons}JoeKeery-byPhilipRomano.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/nancy.jpg',
      subject: 'Natalia Dyer',
      author: 'Beto Pasillas',
      license: 'CC BY 3.0',
      licenseUrl: _by3,
      source: '${_commons}Natalia_Dyer_2025_(3).png',
    ),
    MediaCredit(
      asset: 'assets/images/cast/jonathan.jpg',
      subject: 'Charlie Heaton',
      author: 'JoshPopov',
      license: 'CC BY-SA 4.0',
      licenseUrl: _bySa4,
      source: '${_commons}TIFF-2026-BELOW-CHARLIE-HEATON-03.png',
    ),
    MediaCredit(
      asset: 'assets/images/cast/robin.jpg',
      subject: 'Maya Hawke',
      author: 'Justin Higuchi',
      license: 'CC BY 4.0',
      licenseUrl: _by4,
      source: '${_commons}Maya_Hawke_@_Sid_The_Cat_Auditorium.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/hopper.jpg',
      subject: 'David Harbour',
      author: 'PelucheEn ElEstuche',
      license: 'CC BY 3.0',
      licenseUrl: _by3,
      source: '${_commons}David_Harbour_2025.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/joyce.jpg',
      subject: 'Winona Ryder',
      author: 'Harald Krichel',
      license: 'CC BY-SA 4.0',
      licenseUrl: _bySa4,
      source: '${_commons}Winona_Ryder-63849.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/cast/vecna.jpg',
      subject: 'Jamie Campbell Bower',
      author: 'Kevin Paul',
      license: 'CC BY 4.0',
      licenseUrl: _by4,
      source: '${_commons}Jamie_Campbell_Bower_at_San_Diego_Comic_Con_2026-1.jpg',
    ),

    // ---- Filming locations ----
    MediaCredit(
      asset: 'assets/images/filming/starcourt.jpg',
      subject: 'Gwinnett Place Mall, Duluth, Georgia',
      author: 'Thomson200',
      license: 'CC0',
      licenseUrl: _cc0,
      source: '${_commons}Gwinnett_Place_Mall_July_2016.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/filming/russian_base.jpg',
      subject: 'Lukiškės Prison, Vilnius, Lithuania',
      author: 'Juliux',
      license: 'CC BY-SA 3.0',
      licenseUrl: _bySa3,
      source: '${_commons}Luki%C5%A1k%C4%97s_Prison.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/filming/downtown_hawkins.jpg',
      subject: 'Butts County Courthouse, Jackson, Georgia',
      author: 'John Trainor',
      license: 'CC BY 2.0',
      licenseUrl: _by2,
      source: '${_commons}Butts_County_CH_GA.jpg',
    ),
  ];

  /// Bundled portrait of the actor who plays [characterId], if any.
  static String? castPhoto(String characterId) =>
      _assetIfBundled('assets/images/cast/$characterId.jpg');

  /// Bundled photo of the real place that stood in for [locationId], if any.
  static String? filmingPhoto(String locationId) =>
      _assetIfBundled('assets/images/filming/$locationId.jpg');

  static MediaCredit? forAsset(String asset) {
    for (final c in all) {
      if (c.asset == asset) return c;
    }
    return null;
  }

  static String? _assetIfBundled(String asset) =>
      forAsset(asset) == null ? null : asset;
}
