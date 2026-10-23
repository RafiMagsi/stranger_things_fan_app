import 'package:flutter/foundation.dart';

/// Which shelf of the Reel a clip sits on.
enum ReelShelf {
  party('The Party'),
  vecna('Vecna\'s Curse'),
  upsideDown('The Upside Down'),
  teasers('Teasers & Countdowns');

  const ReelShelf(this.title);
  final String title;
}

/// One fan edit in the Reel: `assets/video/reel_<slug>.mp4` with its
/// thumbnail at `assets/images/reel/<slug>.jpg`.
@immutable
class FanClip {
  const FanClip({
    required this.slug,
    required this.title,
    required this.shelf,
    this.creator,
    this.note,
    this.portrait = false,
  });

  final String slug;
  final String title;
  final ReelShelf shelf;

  /// The editor's handle or watermark, when the clip carries one.
  final String? creator;

  /// What the clip is, when the title alone doesn't say.
  final String? note;

  /// Shot for phones (9:16); everything else is landscape footage that was
  /// recorded sideways and has been turned upright.
  final bool portrait;

  String get videoKey => 'reel_$slug';
  String get thumbnail => 'assets/images/reel/$slug.jpg';
  String get credit => creator == null ? 'Fan edit' : 'Fan edit by $creator';
}

/// One piece of fan art in the gallery: `assets/images/fan/<slug>.jpg`.
@immutable
class FanArt {
  const FanArt({required this.slug, required this.title, this.artist, this.aspect = 9 / 16});

  final String slug;
  final String title;

  /// Width over height, so the gallery can lay pieces out before they load.
  final double aspect;

  /// The artist's signature or handle, when the piece carries one.
  final String? artist;

  String get asset => 'assets/images/fan/$slug.jpg';
  String get credit => artist == null ? 'Fan art' : 'Fan art by $artist';
}

/// The fan-media pack: edits and art supplied by the app's owner (in
/// docs/), cut and graded by tool/build_fan_media.py. It's third-party fan
/// work around Netflix footage - fine for a personal build, to be stripped
/// (`python3 tool/build_fan_media.py --clean`) before any public release.
abstract final class FanMedia {
  static const List<FanClip> reel = [
    FanClip(slug: 'finale', title: 'Finale Edit', shelf: ReelShelf.upsideDown, creator: '@samedits.fx'),
    FanClip(slug: 'adventure', title: 'One Last Adventure in Hawkins', shelf: ReelShelf.party, creator: 'SVCEJ'),
    FanClip(slug: 'eleven', title: 'Eleven, in 4K', shelf: ReelShelf.party),
    FanClip(slug: 'undying_king', title: 'The Undying King', shelf: ReelShelf.vecna, creator: 'UMMI'),
    FanClip(slug: 'mind_flayer', title: 'The Mind Flayer', shelf: ReelShelf.upsideDown),
    FanClip(slug: 'stranger_things', title: 'Stranger Things', shelf: ReelShelf.party, creator: 'UMMI'),
    FanClip(slug: 'w_series', title: 'The Series', shelf: ReelShelf.party, creator: '@onexpiiece'),
    FanClip(slug: 'william', title: 'William in Season 5', shelf: ReelShelf.party, creator: 'GHXZ'),
    FanClip(slug: 'steve', title: 'Steve Harrington', shelf: ReelShelf.party, creator: 'GHXZ'),
    FanClip(slug: 'other_side', title: 'The Other Side', shelf: ReelShelf.upsideDown, creator: 'GHXZ'),
    FanClip(slug: 'one', title: 'Number One', shelf: ReelShelf.vecna, creator: 'GHXZ'),
    FanClip(slug: 'vecna_4k', title: 'Vecna, in 4K', shelf: ReelShelf.vecna, creator: 'MXTH'),
    FanClip(slug: 'creel_house', title: 'Inside the Creel House', shelf: ReelShelf.vecna),
    FanClip(slug: 'goodbye', title: 'I Don\'t Wanna Say Goodbye', shelf: ReelShelf.party, creator: 'CRIMZZ'),
    FanClip(slug: 'goosebumps', title: 'If You Can Hear Me', shelf: ReelShelf.vecna),
    FanClip(slug: 'volume_2', title: 'Volume 2', shelf: ReelShelf.teasers),
    FanClip(slug: 'beitman', title: 'Hawkins in Motion', shelf: ReelShelf.party, creator: '@beitman.ae'),
    FanClip(slug: 'aesthetic_1', title: 'Red Skies', shelf: ReelShelf.upsideDown),
    FanClip(slug: 'aesthetic_2', title: 'Lights in the Dark', shelf: ReelShelf.upsideDown),
    FanClip(slug: 'aesthetic_3', title: 'Night Ride', shelf: ReelShelf.upsideDown),
    FanClip(slug: 'aesthetic_4', title: 'The Creel House Crew', shelf: ReelShelf.party),
    FanClip(slug: 'cooked', title: 'Eleven vs. Vecna', shelf: ReelShelf.vecna),
    FanClip(
      slug: 'kate_bush',
      title: 'Running Up That Hill',
      shelf: ReelShelf.party,
      note: 'Max\'s escape from Vecna',
      portrait: true,
    ),
    FanClip(
      slug: 'fall_1987',
      title: 'In the Fall of 1987',
      shelf: ReelShelf.teasers,
      note: 'The Season 5 announcement teaser',
      portrait: true,
    ),
    FanClip(slug: 'will', title: 'Will Byers', shelf: ReelShelf.party, portrait: true),
    FanClip(
      slug: 'riding',
      title: 'Riding into the Unknown',
      shelf: ReelShelf.upsideDown,
      note: 'AI-generated fan art',
      portrait: true,
    ),
    FanClip(slug: 'wait_over', title: 'The Wait Is Over', shelf: ReelShelf.teasers, portrait: true),
    FanClip(slug: 'pumpkin', title: 'The Clock Is Ticking', shelf: ReelShelf.teasers, portrait: true),
    FanClip(slug: 'almost_time', title: 'It\'s Almost Time', shelf: ReelShelf.teasers, portrait: true),
    FanClip(slug: 'four_times', title: 'Four Chimes', shelf: ReelShelf.vecna, creator: 'guxly.fx', portrait: true),
    FanClip(slug: 'billy', title: 'Billy Hargrove', shelf: ReelShelf.party, portrait: true),
  ];

  static const List<FanArt> art = [
    FanArt(slug: 'eleven_011', title: 'Eleven · 011'),
    FanArt(slug: 'bikes_mirror', title: 'Right Side Up, Upside Down', artist: 'F.cwallpaperss'),
    FanArt(slug: 'vecna', title: 'Vecna', artist: '@Shellys_arts'),
    FanArt(slug: 'demogorgon', title: 'The Demogorgon', artist: '@Shellys_arts'),
    FanArt(slug: 'mind_flayer', title: 'The Shadow over Hawkins', artist: 'F.cwallpaperss'),
    FanArt(slug: 'max', title: 'Max', artist: 'BADVISH', aspect: 16 / 9),
    FanArt(slug: 'will', title: 'Will', artist: 'BADVISH', aspect: 16 / 9),
    FanArt(slug: 'eleven_reach', title: 'Eleven Reaches Out', artist: 'BADVISH', aspect: 16 / 9),
    FanArt(slug: 'steve_bat', title: 'Steve and the Bat', artist: 'BADVISH', aspect: 16 / 9),
    FanArt(slug: 'henry_creel', title: 'Henry Creel', artist: 'BADVISH', aspect: 16 / 9),
    FanArt(slug: 'eleven_011_pink', title: 'Eleven in Flames', artist: 'BADVISH'),
    FanArt(slug: 'logo_bikes', title: 'The Ride Out', artist: 'BADVISH', aspect: 16 / 9),
    FanArt(slug: 'eddie', title: 'Master of Puppets', artist: '@Shellys_arts', aspect: 0.767),
    FanArt(slug: 'steve_shades', title: 'King Steve', artist: '@Shellys_arts'),
    FanArt(slug: 'eleven_paint', title: 'Eleven in Colour'),
    FanArt(slug: 'vecna_clock', title: 'The Clock', artist: 'F.cwallpaperss'),
    FanArt(slug: 'red_storm', title: 'The Storm', artist: 'F.cwallpaperss'),
    FanArt(slug: 'red_forest', title: 'Mirkwood'),
    FanArt(slug: 'cast_poster', title: 'The Whole Party', aspect: 0.776),
    FanArt(slug: 'bedroom', title: 'Room with a View', artist: '@Shellys_arts'),
    FanArt(slug: 'shotgun', title: 'Locked and Loaded', artist: '@Shellys_arts'),
  ];

  /// Where each drop-in still and UI loop was cut from: an asset key to the
  /// reel slug or fan-art slug it came out of.
  static const Map<String, String> _clipSources = {
    'char_eleven': 'w_series',
    'char_will': 'william',
    'char_mike': 'vecna_4k',
    'char_steve': 'steve',
    'char_max': 'w_series',
    'char_hopper': 'beitman',
    'char_nancy': 'stranger_things',
    'char_vecna': 'volume_2',
    'char_demogorgon': 'william',
    'char_mind_flayer': 'finale',
    'monster_demogorgon': 'william',
    'monster_mind_flayer': 'mind_flayer',
    'monster_vecna': 'undying_king',
    'loc_creel_house': 'aesthetic_4',
    'loc_upside_down': 'aesthetic_1',
    'hero_finale': 'finale',
    'gate_crossing': 'undying_king',
    'gate_hawkins': 'riding',
    'ud_lightning': 'one',
    'ud_red': 'aesthetic_1',
    'bikes_night': 'aesthetic_3',
    'clock_loop': 'almost_time',
  };

  static const Map<String, String> _artSources = {
    'featured': 'cast_poster',
    'season_1': 'eleven_011_pink',
    'season_2': 'mind_flayer',
    'season_3': 'red_storm',
    'season_4': 'vecna_clock',
    'season_5': 'red_forest',
    'bg_upside': 'bikes_mirror',
    'gate_eleven': 'eleven_reach',
    'henry_creel': 'henry_creel',
  };

  /// The edit (with sound) a dossier's WATCH button plays.
  static const Map<String, String> characterReel = {
    'eleven': 'eleven',
    'will': 'will',
    'max': 'kate_bush',
    'steve': 'steve',
    'mike': 'vecna_4k',
    'hopper': 'beitman',
    'nancy': 'stranger_things',
    'vecna': 'undying_king',
    'demogorgon': 'william',
    'mind_flayer': 'mind_flayer',
  };

  static FanClip? clip(String slug) {
    for (final c in reel) {
      if (c.slug == slug) return c;
    }
    return null;
  }

  static FanArt? artwork(String slug) {
    for (final a in art) {
      if (a.slug == slug) return a;
    }
    return null;
  }

  /// "From 'William in Season 5', fan edit by GHXZ" - the credit line for
  /// the pack's still or loop under [assetKey], or null if it isn't one.
  static String? sourceLine(String assetKey) {
    final clipSlug = _clipSources[assetKey];
    if (clipSlug != null) {
      final c = clip(clipSlug)!;
      final by = c.creator == null ? 'a fan edit' : 'fan edit by ${c.creator}';
      return 'From "${c.title}", $by';
    }
    final artSlug = _artSources[assetKey];
    if (artSlug != null) {
      final a = artwork(artSlug)!;
      final by = a.artist == null ? 'fan art' : 'fan art by ${a.artist}';
      return '"${a.title}", $by';
    }
    return null;
  }

  /// Every asset key the pack accounts for (a test keeps this honest).
  static Iterable<String> get sourcedKeys => [..._clipSources.keys, ..._artSources.keys];

  /// The edits on [shelf], in reel order.
  static List<FanClip> onShelf(ReelShelf shelf) => [for (final c in reel) if (c.shelf == shelf) c];
}
