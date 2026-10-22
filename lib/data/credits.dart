import '../models/media_credit.dart';

/// Every bundled photo and where it came from.
///
/// Cast portraits are the actors at public events, used to say "played by";
/// they are not stills from the show. Filming-location photos show the real
/// places that stood in for Hawkins. Event imagery shows the real-world
/// things each moment is built around - Joyce's Christmas lights, Hopper's
/// Blazer, Vecna's clock - never frames from the show. All are from Wikimedia Commons, resized
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

    // ---- Event imagery: the real objects and places behind each event ----
    MediaCredit(
      asset: 'assets/images/events/tv.jpg',
      subject: 'Vintage television sets',
      author: 'Klaus Nahr from Germany',
      license: 'CC BY-SA 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Museum_f%C3%BCr_Kommunikation_-_Depot_Heusenstamm_-_Technik_12_-_Flickr_-_KlausNahr.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/walkie.jpg',
      subject: 'Walkie-talkies',
      author: 'Wtshymanski',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Recreational_Walkie_Talkies.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:Recreational_Walkie_Talkies.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/lights.jpg',
      subject: 'A house in Christmas lights, Dublin, California',
      author: 'V Smoothe',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Christmas_in_Dublin,_CA.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/flytrap.jpg',
      subject: 'Venus flytrap',
      author: 'Noah Elhardt',
      license: 'CC BY-SA 2.5',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.5',
      source: 'https://commons.wikimedia.org/wiki/File:Venus_Flytrap_showing_trigger_hairs.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/polaroid.jpg',
      subject: 'Polaroid SX-70 camera',
      author: 'Thomas Backa from Turku, Finland',
      license: 'CC0',
      licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
      source: 'https://commons.wikimedia.org/wiki/File:Polaroid_SX-70_(4462345243).jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/typewriter.jpg',
      subject: 'Vintage typewriter',
      author: 'GodeNehler',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:MEK_II-371.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/dice.jpg',
      subject: 'Polyhedral role-playing dice',
      author: 'Sabbut (derivative work: SharkD)',
      license: 'CC BY-SA 3.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
      source: 'https://commons.wikimedia.org/wiki/File:Dados_4_a_20_caras_trans.png',
    ),
    MediaCredit(
      asset: 'assets/images/events/synth.jpg',
      subject: 'Minimoog synthesizer',
      author: 'Krash',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Minimoog.JPG',
      source: 'https://commons.wikimedia.org/wiki/File:Minimoog.JPG',
    ),
    MediaCredit(
      asset: 'assets/images/events/victorian.jpg',
      subject: 'Frank Wheeler Hotel, Freetown, Indiana',
      author: 'Quentin Melson',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:Frank_Wheeler_Hotel_in_Freetown,_Indiana.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/mkultra.jpg',
      subject: 'Declassified MKUltra document',
      author: 'Central Intelligence Agency',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:DeclassifiedMKULTRA.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:DeclassifiedMKULTRA.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/tank.jpg',
      subject: 'Flotation (isolation) tank',
      author: 'Floatguru',
      license: 'CC BY-SA 3.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
      source: 'https://commons.wikimedia.org/wiki/File:Flotation_Tank_Isolation_Tank.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/bike.jpg',
      subject: 'Bicycle rear light',
      author: 'Amin',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:Bicycle_lighting_red_back.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/slime.jpg',
      subject: 'Slime mould (Comatricha nigra)',
      author: 'Alexis Tinker-Tsavalas',
      license: 'CC BY 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:Comatricha_nigra_176600092.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/pool.jpg',
      subject: 'Backyard swimming pool',
      author: 'Vic Brincat from Keswick, Ontario, Canada',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Backyardpool.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/quarry.jpg',
      subject: 'Quarry',
      author: 'Wilson44691',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:PortlandQuarry.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:PortlandQuarry.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/hazmat.jpg',
      subject: 'Hazmat suits',
      author: 'U.S. Air Force',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:091108-F-8594F-797_(4100783730).jpg',
      source: 'https://commons.wikimedia.org/wiki/File:091108-F-8594F-797_(4100783730).jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/waffle.jpg',
      subject: 'Waffles',
      author: 'Parkerman & Christie from San Diego, USA',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Waffles_with_Strawberries.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/storm.jpg',
      subject: 'Supercell thunderstorm',
      author: 'Stefan Klein',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:Low_Precipitation_Supercell_Thunderstorm.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/pumpkin.jpg',
      subject: 'Jack-o\'-lantern',
      author: 'Man vyi',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Balle-%C3%A0-leunettes_10.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:Balle-%C3%A0-leunettes_10.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/chicago.jpg',
      subject: 'Chicago River',
      author: 'John Picken (derivative work: Georgfotoart)',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Chicago_River_ferry_b.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/trs80.jpg',
      subject: 'RadioShack TRS-80',
      author: 'Rama & Musée Bolo',
      license: 'CC BY-SA 2.0 fr',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.0/fr',
      source: 'https://commons.wikimedia.org/wiki/File:Radioshack_TRS80-IMG_7206.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/discoball.jpg',
      subject: 'Mirror ball',
      author: 'Catboy69',
      license: 'CC0',
      licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
      source: 'https://commons.wikimedia.org/wiki/File:Mirrored_Disco_Ball_with_Light_and_Motor.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/fireworks.jpg',
      subject: 'Fireworks',
      author: 'Rob Chandler',
      license: 'CC BY-SA 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:New_Year%27s_Eve_on_Sydney_Harbour.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/ltd.jpg',
      subject: '1977 Ford LTD',
      author: 'Greg Gjerdingen from Willmar, USA',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:77FordLTD_(cropped).jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/volcano.jpg',
      subject: 'Klyuchevskaya Sopka, Kamchatka',
      author: 'Tamten',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Klju%C4%8Devskaja_za_v%C3%BDchodu_slunce.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:Klju%C4%8Devskaja_za_v%C3%BDchodu_slunce.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/trailer.jpg',
      subject: 'Mobile home',
      author: 'Wikideas1',
      license: 'CC0',
      licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
      source: 'https://commons.wikimedia.org/wiki/File:Mobile_home_with_garage.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/cassette.jpg',
      subject: 'Compact cassette',
      author: 'Thegreenj',
      license: 'CC BY-SA 3.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
      source: 'https://commons.wikimedia.org/wiki/File:Compactcassette.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/desert.jpg',
      subject: 'Mesquite Flat Dunes, Death Valley',
      author: 'Daniel Mayer (mav)',
      license: 'CC BY-SA 3.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
      source: 'https://commons.wikimedia.org/wiki/File:Death_Valley_-_Mesquite_Flat_Dunes_-_dune_showing_stoss,_brink_and_slip_surfaces.JPG',
    ),
    MediaCredit(
      asset: 'assets/images/events/pennhurst.jpg',
      subject: 'Pennhurst State School and Hospital, Pennsylvania',
      author: 'Smccphotog',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Admin-current-pennhurst.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:Admin-current-pennhurst.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/humvee.jpg',
      subject: 'Humvee',
      author: 'U.S. Marine Corps, Lance Cpl. Olivia G. Ortiz',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:2015_MCAS_Beaufort_Air_Show_041215-M-CG676-161.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:2015_MCAS_Beaufort_Air_Show_041215-M-CG676-161.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/teddy.jpg',
      subject: 'Early-1900s teddy bear',
      author: 'Smithsonian Museum of Natural History',
      license: 'CC BY-SA 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Teddy_bear_early_1900s_-_Smithsonian_Museum_of_Natural_History.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/wormhole.jpg',
      subject: 'Einstein-Rosen bridge model',
      author: 'MikeRun',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:Einstein-rosen-bridge-model.png',
    ),
    MediaCredit(
      asset: 'assets/images/events/lightning.jpg',
      subject: 'Lightning storm',
      author: 'Maxime Raynal from France',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Port_and_lighthouse_overnight_storm_with_lightning_in_Port-la-Nouvelle.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/rainbow.jpg',
      subject: 'Double rainbow, Alaska',
      author: 'Eric Rolph',
      license: 'CC BY-SA 2.5',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.5',
      source: 'https://commons.wikimedia.org/wiki/File:Double-alaskan-rainbow.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/blazer.jpg',
      subject: '1979 Chevrolet K5 Blazer',
      author: '79k5driver',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:1979_Chevrolet_K5_Blazer_Cheyenne.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/camaro.jpg',
      subject: '1970 Chevrolet Camaro',
      author: 'Greg Gjerdingen from Willmar, USA',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:1970_Chevrolet_Camaro_(27755093943)_(cropped).jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/cinema.jpg',
      subject: 'City cinema, Ptuj',
      author: 'Ajznponar',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:Ptuj,_city_cinema.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/carnival.jpg',
      subject: 'Travelling carnival',
      author: 'Joshgod91',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0',
      source: 'https://commons.wikimedia.org/wiki/File:A_travelling_Carnival_in_Ararat_Victoria_Australia.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/sauna.jpg',
      subject: 'Sauna',
      author: 'Bleiglass',
      license: 'CC BY-SA 3.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
      source: 'https://commons.wikimedia.org/wiki/File:Sauna_2.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/rink.jpg',
      subject: 'Roller rink',
      author: 'Sector001',
      license: 'Public domain',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:LeosRollerRink.jpg',
      source: 'https://commons.wikimedia.org/wiki/File:LeosRollerRink.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/arcade.jpg',
      subject: 'Arcade cabinets',
      author: 'Andrevruas',
      license: 'CC BY-SA 3.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
      source: 'https://commons.wikimedia.org/wiki/File:Fliperama.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/fog.jpg',
      subject: 'Foggy street',
      author: 'Ian W. Fieggen',
      license: 'CC BY-SA 3.0',
      licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0',
      source: 'https://commons.wikimedia.org/wiki/File:20080313_Foggy_Street.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/clock.jpg',
      subject: 'Longcase (grandfather) clock',
      author: 'Unknown author',
      license: 'CC0',
      licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
      source: 'https://commons.wikimedia.org/wiki/File:Anonymous_Longcase_clock_01.jpg',
    ),
    MediaCredit(
      asset: 'assets/images/events/guitar.jpg',
      subject: 'Gibson Les Paul Custom',
      author: 'Fernando García (derivative work)',
      license: 'CC BY 2.0',
      licenseUrl: 'https://creativecommons.org/licenses/by/2.0',
      source: 'https://commons.wikimedia.org/wiki/File:Gibson_Les_Paul_54_Custom.jpg',
    ),
  ];

  /// Bundled portrait of the actor who plays [characterId], if any.
  static String? castPhoto(String characterId) =>
      _assetIfBundled('assets/images/cast/$characterId.jpg');

  /// Any bundled, credited photo by its path under `assets/images/`
  /// without the extension - e.g. `'events/lights'`, `'filming/starcourt'`.
  static String? photo(String? key) =>
      key == null ? null : _assetIfBundled('assets/images/$key.jpg');

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
