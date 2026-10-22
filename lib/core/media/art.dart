import 'package:flutter/material.dart';

import '../../data/credits.dart';
import '../../data/locations.dart';
import '../../models/character.dart';
import '../../models/season.dart';
import '../theme/world_palette.dart';
import '../widgets/st_effects.dart';
import 'poster_image.dart';

/// Card and header art for a character. Resolution order:
///  1. a fan's own drop-in still (`assets/images/char_<id>.jpg`),
///  2. the bundled, licensed cast portrait, graded into the world's light,
///  3. procedural key art.
class CharacterArt extends StatelessWidget {
  const CharacterArt({super.key, required this.character, this.iconSize = 150});

  final Character character;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final world = WorldPalette.of(context);
    final photo = MediaCredits.castPhoto(character.id);
    final fallback = photo != null
        ? DuotonePhoto(
            asset: photo,
            // Mostly the world's light, with a hint of the character's own.
            tint: Color.lerp(world.accent, character.accent, 0.35)!,
          )
        : KeyArt(
            accent: character.accent,
            deep: character.accentDeep,
            icon: character.icon,
            iconSize: iconSize,
          );
    return PosterImage(assetKey: 'char_${character.id}', fallback: fallback);
  }
}

/// Procedural season key art: the season's colour, a signature motif, and
/// the Gate itself for the first and last seasons.
class SeasonArt extends StatelessWidget {
  const SeasonArt({super.key, required this.season, this.animate = false});

  final Season season;

  /// Let the Gate breathe (hero headers only; lists stay static).
  final bool animate;

  static const _motifs = {
    1: Icons.directions_bike, // the Party's bikes
    2: Icons.thunderstorm, // the Shadow Monster
    3: Icons.celebration, // Fourth of July at Starcourt
    4: Icons.hourglass_bottom, // Vecna's clock
    5: Icons.public, // two worlds, one end
  };

  @override
  Widget build(BuildContext context) {
    final hasGate = season.number == 1 || season.number == 5;
    return PosterImage(
      assetKey: 'season_${season.number}',
      fallback: Stack(
        fit: StackFit.expand,
        children: [
          KeyArt(
            accent: season.accent,
            icon: _motifs[season.number],
            iconSize: 130,
            // With a Gate on the right, park the motif up and left, away
            // from both the tear and the title text below.
            iconAlignment: hasGate ? const Alignment(-0.7, -0.6) : const Alignment(0.8, -0.2),
          ),
          if (hasGate)
            Opacity(
              opacity: 0.9,
              child: GateArt(color: season.accent, seed: season.number * 11, animate: animate),
            ),
        ],
      ),
    );
  }
}

/// A location still: drop-in still, else the real filming location (lightly
/// graded so it sits in the show's palette), else procedural art.
class LocationArt extends StatelessWidget {
  const LocationArt({super.key, required this.location});

  final STLocation location;

  @override
  Widget build(BuildContext context) {
    final photo = MediaCredits.filmingPhoto(location.id);
    final fallback = photo != null
        ? DuotonePhoto(asset: photo, tint: location.accent, grade: 0.5, alignment: Alignment.center)
        : KeyArt(
            accent: location.accent,
            icon: location.icon,
            iconSize: 96,
            iconAlignment: const Alignment(0.85, 0.1),
          );
    return PosterImage(assetKey: 'loc_${location.id}', fallback: fallback);
  }
}
