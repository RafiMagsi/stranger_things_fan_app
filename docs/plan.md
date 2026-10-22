# 🛸 Stranger Things — Super Fan App

An unofficial, fan-made Stranger Things companion built with Flutter: a
card-based way to explore Hawkins and follow the whole series in watch order.
This document reflects the **shipped** architecture (it started as a plan and
is kept in step with the code). Everything here is implemented and covered by
tests.

---

## 1. Design language — CINEMATIC DARK, NEON RED

The single most important decision: **anyone glancing at a screen should know
it's Stranger Things.** So every screen is built from the show's own signals:

- **The logotype** — `STLogo` rebuilds it from type: hollow neon Benguiat
  (Grenze), oversized S and R, the bar over STRANGER and the rule THINGS hangs
  from. It converges letter-by-letter on the splash, like the title sequence.
- **Neon tubes** — every card (`NeonCard`) is a near-black panel lit by a
  neon tube along its top edge, echoing the logo's bars. Titles use
  `AppText.neon` (stroke + glow in a single `Text`).
- **Joyce's alphabet wall** — a live card on Home that spells RIGHT HERE /
  RUN / FRIENDS DONT LIE one bulb at a time.
- **Chapter title cards** — episodes are "CHAPTER ONE", "CHAPTER TWO"…
- **Hawkins Lab dossiers** — character pages are stamped CLASSIFIED; the hub
  tiles are filed as FILE 01…10, glowing in Christmas-bulb colours.
- **Tube-TV texture** — faint CRT scanlines over every screen.

Both worlds are near-black; the toggle swaps the light:

| World | Base | Accent | Atmosphere |
| --- | --- | --- | --- |
| **Hawkins** (Right Side Up) | warm void `#070405` | logo red `#E50914` + amber | red title-sequence bloom, embers |
| **Upside Down** | storm void `#03060C` | storm blue `#5AAEFF` + red lightning | ash spores, vines in the corners, cold haze |

The logo stays red in both worlds (it's red in the show). Cast photos are
**re-graded live** into the active world's light when you flip.

- `WorldPalette` (`lib/core/theme/world_palette.dart`) is a `ThemeExtension`
  carrying accent / secondary / atmosphere / surface tokens per world, so
  widgets never branch on brightness.
- `STScaffold` gives every section screen the same chrome: neon title +
  subtitle, burning tube under the app bar, world atmosphere, CRT layer, and a
  compact world toggle.

### Typography
Both bundled display/UI fonts are **variable fonts**; real weight is driven
through `fontVariations` (see `lib/core/theme/text_styles.dart`).
- **Grenze** ≈ ITC Benguiat (the show's title face) — logo, neon titles,
  chapter labels.
- **Space Grotesk** — UI copy.
- **Special Elite** — dossier/typewriter flavour (reports, quotes, captions).

---

## 2. Structure

```text
lib/
│── main.dart                      # ProviderScope, dual theme, world shell (tap origin, ash, storm)
├── core/
│   ├── theme/   app_colors · app_theme · text_styles · world_palette
│   ├── state/   app_state (worldMode, audioEnabled, watchProgress → shared_preferences)
│   ├── widgets/ neon_card (NeonCard, NeonTube, GlowBadge, SectionHeader, FlickerIn)
│   │            st_logo · st_scaffold (STScaffold, WorldAtmosphere, NeonBackButton)
│   │            st_effects (CRT, ChristmasLights, KeyArt, DuotonePhoto, GateArt,
│   │                        VineOverlay, AlphabetWall)
│   │            rift_route (Gate transition, lightning storm) · world_toggle · particles
│   └── media/   asset_media · poster_image · art (CharacterArt, SeasonArt, LocationArt)
├── models/      character · season (+Episode) · trailer · moment · media_credit · quiz_question · sound_clip
├── data/        characters · seasons · timeline · moments · locations · bestiary
│                quotes · quiz · soundboard · credits
└── screens/     splash · home · seasons · season_detail · trailer_player · cast ·
                 character_detail · timeline · locations · bestiary · moments ·
                 quotes · quiz · soundboard · transmissions · credits
```

---

## 3. Images & video — real, and legally used

Netflix's stills and trailers are copyrighted; "educational" doesn't make it
OK to re-host them inside an app. So the app uses three legitimate sources:

1. **Official trailers, streamed** — 8 trailers (every season) embedded from
   Netflix's own YouTube channels via `youtube_player_iframe`, in a VCR-styled
   player with an "Open in YouTube" fallback. Nothing is downloaded or
   re-hosted. Every id was verified with YouTube's oEmbed endpoint to confirm
   the uploader is an official Netflix channel.
2. **Freely-licensed photos, bundled** — 13 cast portraits and 3 filming
   locations (Gwinnett Place Mall = Starcourt, Lukiškės Prison = the Kamchatka
   prison, Jackson GA = downtown Hawkins) from Wikimedia Commons under CC0 /
   CC BY / CC BY-SA, in `assets/images/cast/` and `assets/images/filming/`.
   Attribution lives in `lib/data/credits.dart`, on each dossier/location
   card, and on the **Credits** screen (required by the licences).
3. **Procedural key art** — Gate, lightning, vines, the alphabet wall and
   season/creature art are drawn in code, so the app is complete offline.

### Drop-in slots (your own licensed files)
The app still prefers any file you drop in, with the above as fallback:

```text
assets/images/char_<id>.jpg     e.g. char_eleven.jpg
assets/images/season_<n>.jpg    e.g. season_4.jpg
assets/images/featured.jpg      the big home banner
assets/images/loc_<id>.jpg      e.g. loc_hawkins_lab.jpg
assets/images/monster_<id>.jpg  e.g. monster_demogorgon.jpg
```

The generated "PLACEHOLDER — DROP YOUR OWN FILE HERE" slates now live in
`tool/placeholder_slates/` (not bundled) — while they sat in `assets/images/`
the app showed them on every card.

---

## 4. Fan content — the whole series, in watch order

- **Watch guide** — all 5 seasons, all 42 chapters, each with a spoiler-light
  synopsis, the in-story setting (Nov 1983 → Nov 1987), official trailers,
  and a "watched" mark. Progress persists on device; Home always shows
  **Next up**.
- **Timeline** — 34 beats in story order, 1959 → the spring-1989 epilogue,
  grouped by era; each says which episode reveals it.
- **Moments** — 34 twists, reveals, ironies, sacrifices and betrayals across
  all five seasons, spoiler-veiled until tapped.
- **The Cast** — 15 dossiers with actor credits, story role, stats radar,
  skills, and a field-report quote.
- **Hawkins Map** — 11 places, with where they were filmed.
- **Bestiary** — creatures with threat meters and weaknesses.
- **Quotes**, **Trivia** (20 questions, every season), **Soundboard**,
  **Transmissions** (trailers + synth radio signals).

Content was fact-checked against the show; Season 5 against Wikipedia's
episode summaries.

---

## 5. Audio — original, procedurally synthesized

No copyrighted recordings. `tool/generate_audio.py` synthesizes the WAV cues
(theme, screech, static, dice, squelch, portal, chime, coin, power, clock,
heartbeat, vines). Re-run it to regenerate or extend.

---

## 6. Animation & special effects (implemented)

- **The Gate transition** (`RiftPageRoute`) — every card → screen push tears
  the new page open through a writhing, red-rimmed portal that grows from the
  exact point you tapped (`TapOrigin`), while the old page dims and sinks.
  Back closes the tear. Hero animations fly cast portraits and season art
  from the card into the page header on top of it.
- **The storm** (`RiftFlash`) — flipping worlds cracks two forked red
  lightning bolts across the screen in a double strike, rolls a red-blue
  shockwave, and the theme eases over 600ms.
- **Flicker-in** (`FlickerIn`) — cards stutter on like a Hawkins streetlight
  when something is near, staggered, only while a screen is arriving.
- **VHS tune-in** — spoiler reveals split into red/cyan ghosts that jitter and
  snap together, like a tape finding its tracking.
- **Splash** — the title sequence: scattered hollow letters converge, the
  bars light, the camera pushes in over a red bloom with embers.
- **Living art** — the Gate breathes, Christmas lights chase, ash drifts in
  the Upside Down, the stats radar draws on with a neon edge.

---

## 7. Important moments
All important, twisting and ironic moments of the series are in the
**Moments** screen (see §4), one card per moment, in watch order.

---

## 8. Verify

```bash
flutter analyze   # No issues found
flutter test      # 20/20 pass (widgets + series-data integrity)
flutter build web --release
flutter build ios --debug --no-codesign
```

Run it: `flutter run` on a device (trailers need a network connection).

> Unofficial fan work, not affiliated with or endorsed by Netflix. Built for
> personal/educational use.
