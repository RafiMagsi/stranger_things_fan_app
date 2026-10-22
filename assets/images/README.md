# Images

## Bundled (licensed)

    cast/<character_id>.jpg      actor portraits from Wikimedia Commons
    filming/<location_id>.jpg    real filming locations from Wikimedia Commons

Every file here is CC0 / CC BY / CC BY-SA. Its author, licence and source are
listed in `lib/data/credits.dart` and shown on the in-app Credits screen - keep
them in sync if you add or replace a file.

## Drop-in stills / posters

Put your OWN licensed or captured Stranger Things stills here and the app
automatically prefers them over the bundled photos and procedural key art.

Naming (case-sensitive, keys map 1:1 to content ids):

    char_<id>.jpg        e.g. char_eleven.jpg, char_vecna.jpg
    season_<n>.jpg       e.g. season_4.jpg
    featured.jpg         the big home banner
    loc_<id>.jpg         e.g. loc_hawkins_lab.jpg
    monster_<id>.jpg     e.g. monster_demogorgon.jpg

Supported: .jpg .jpeg .png .webp

After adding files run `flutter pub get` and rebuild. If a file is missing,
the app silently falls back - nothing breaks.

Placeholder slates (`tool/generate_placeholders.py`) are generated into
`tool/placeholder_slates/`, not here: anything in this folder wins over the
app's own art.
