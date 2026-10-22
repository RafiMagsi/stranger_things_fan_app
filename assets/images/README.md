# Drop-in stills / posters

Put your OWN licensed or captured Stranger Things stills here and the app
automatically prefers them over the built-in procedural key art.

Naming (case-sensitive, keys map 1:1 to content ids):

    char_<id>.jpg        e.g. char_eleven.jpg, char_vecna.jpg
    season_<n>.jpg       e.g. season_4.jpg
    featured.jpg         the big home banner
    loc_<id>.jpg         e.g. loc_hawkins_lab.jpg
    monster_<id>.jpg     e.g. monster_demogorgon.jpg

Supported: .jpg .jpeg .png .webp

After adding files run `flutter pub get` and rebuild. If a file is missing,
the app silently falls back to procedural art — nothing breaks.
