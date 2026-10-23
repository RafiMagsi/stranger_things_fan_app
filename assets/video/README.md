# Clips & drop-in trailers

## Bundled fan captures (from docs/videos)

Compressed for the app (portrait, h264, ~800KB-5MB each):

    gate_finale.mp4    home banner + the Gate tile (silent loop)
    hawkins_world.mp4  what the Gate shows when you're in the Upside Down
    upside_down.mp4    what the Gate shows when you're in Hawkins
    char_eleven.mp4    char_max / char_steve / char_vecna / char_will
    monster_mind_flayer.mp4   bestiary card loop
    clock.mp4  adventure.mp4  kate_bush.mp4   Screening Room (The Reel)
    s5_teaser.mp4      plays in Transmissions for the S5 trailer

Stills extracted from the same footage live in assets/images
(char_*, monster_*, season_5, featured, bg_*, st_*), and audio captures
in assets/audio/captures (soundboard).

## Drop-in trailers

Put your OWN licensed or captured trailer clips here. The app probes for
these keys:

    s1_teaser.mp4  s2_teaser.mp4  s3_teaser.mp4  s4_teaser.mp4  s5_teaser.mp4
    featured.mp4

Supported: .mp4 .mov .m4v .webm

If present, the Transmissions screen can play them; if absent, it uses the
built-in original synth cues. Run `flutter pub get` and rebuild after adding.
