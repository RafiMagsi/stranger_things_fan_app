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
- **A film, not a UI** — a shared film-grain and vignette layer sits over the
  whole app (`FilmGrain`, 24fps), so every screen reads as footage.

### Watching, not browsing
A catalogue of cards tells you *about* the show; the app should feel like
*watching* it. So the series itself is the main way in:

- **Story mode** (`StoryScreen`) — the whole series, chapter by chapter,
  full-screen and letterboxed. Each season opens on a bare title card (the
  logo converging, the season number catching like neon); each chapter's
  "CHAPTER THREE" card burns in over a slowly drifting still, the show's
  date caption types itself out, the synopsis runs as a subtitle, and the
  synth score plays underneath. Tap right for next, left edge for back,
  hold to pause, swipe down to leave; a progress segment per card; mark a
  chapter watched without leaving. The gesture hint shows once, then fades.
- **Entry points** — Home's hero button reads START WATCHING / RESUME S1 · E4
  / WATCH AGAIN from your progress; the Next-up card, a season's PLAY button
  and every chapter card open the story at that point.
- **Billboard** — the Home hero plays the official final-season trailer
  muted behind the title (fades in once playing, pauses off-screen, loops);
  off in tests, with reduce effects, or via the "Trailer previews" setting.
- **Observing** — character dossiers are a Hawkins Lab surveillance feed:
  REC light, running timecode from the season's date, camera and subject
  labels, viewfinder brackets, and tape tearing in the Upside Down.

Both worlds are near-black; the toggle swaps the light:

| World | Base | Accent | Atmosphere |
| --- | --- | --- | --- |
| **Hawkins** (Right Side Up) | warm void `#070405` | logo red `#E50914` + amber | red title-sequence bloom, embers |
| **Upside Down** | storm void `#03060C` | storm blue `#5AAEFF` + red lightning | ash spores, vines in the corners, cold haze |

The logo stays red in both worlds (it's red in the show). **Everything
else follows the world** - every card, background, photo and piece of art:

- `WorldPalette.depth` (0 = Hawkins, 1 = Upside Down) tweens with the theme,
  so effects *grow in* as you cross over instead of snapping.
- `WorldPalette.tint()` pulls any content colour into the world's light. The
  Upside Down only knows storm blue and lightning red: warm hues decay toward
  the lightning, cool ones toward the storm, greys to pale ash.
- `NeonCard` (every card): tinted glow, dying neon tube, cold fog on the
  panel, and vines that crawl across it (under the text on text cards; in
  the top corners on photo cards).
- `WorldGrade`: the show's Upside Down colour grade (drained, cold, crushed)
  on all procedural art, filming-location photos and trailer thumbnails;
  cast portraits re-grade live.
- `WorldAtmosphere` (every screen): Hawkins breathes a red title-sequence
  bloom; the Upside Down drifts storm fog, double-flickers distant red
  lightning every few seconds, and grows vines in from the corners.
- The shell keeps something in the air: embers in Hawkins, ash in the
  Upside Down.

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
│── main.dart                      # ProviderScope, dual theme, world shell (tap origin, grain, ash, storm)
├── core/
│   ├── theme/    app_colors · app_theme · text_styles · world_palette
│   ├── state/    app_state (worldMode, settings, watchProgress → shared_preferences)
│   ├── audio/    sfx (Sfx cues, looping Score with fades)
│   ├── platform/ test_env (isFlutterTest: no audio/webview under test)
│   ├── widgets/  neon_card (NeonCard, NeonTube, GlowBadge, SectionHeader, FlickerIn)
│   │             world_fx (WorldGrade, CardVines, NeonIgnite, TypewriterText, STHero,
│   │                       RedactedText, ClassifiedBanner, FilmGrain, SurveillanceOverlay)
│   │             st_logo · st_scaffold (STScaffold, WorldAtmosphere, NeonBackButton)
│   │             st_effects (CRT, ChristmasLights, KeyArt, DuotonePhoto, GateArt,
│   │                         VineOverlay, AlphabetWall)
│   │             rift_route (Gate transition, lightning storm) · world_toggle · particles
│   └── media/    asset_media · poster_image · billboard (muted trailer behind Home)
│                 youtube_embed (app identity for the player, failure messages)
│                 art (CharacterArt, SeasonArt, LocationArt, EventArt)
├── models/       character · season (+Episode) · trailer · moment · media_credit · quiz_question · sound_clip
├── data/         characters · seasons · timeline · moments · locations · bestiary
│                 quotes · quiz · soundboard · credits
└── screens/      splash · home · story · seasons · season_detail · trailer_player · cast ·
                  character_detail · timeline · locations · bestiary · moments ·
                  quotes · quiz · soundboard · transmissions · credits · settings_sheet
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
   - **Embedder identity** (`YoutubeEmbed`) — YouTube requires app WebViews
     to identify themselves: the player page's base URL / Referer is
     `https://<app id>` (iOS: lower-cased bundle id; Android: applicationId),
     per YouTube's Required Minimum Functionality. Without it YouTube
     answers *Error 153*. A test keeps the ids in step with the native
     projects.
   - **When YouTube won't play** — YouTube can still refuse an embed
     (error 150/152), most often when it wants the network to "confirm
     you're not a bot", which an anonymous embedded player can't do. The
     VCR then shows a dead channel (TRANSMISSION BLOCKED / TAPE MISSING /
     NO SIGNAL after 15s of silence) with **Watch on YouTube**, which opens
     the YouTube app; the Home billboard just stays hidden.
2. **Freely-licensed photos, bundled** — 13 cast portraits, 3 filming
   locations (Gwinnett Place Mall = Starcourt, Lukiškės Prison = the Kamchatka
   prison, Jackson GA = downtown Hawkins) from Wikimedia Commons under CC0 /
   CC BY / CC BY-SA, in `assets/images/cast/` and `assets/images/filming/`;
   plus **44 event images** in `assets/images/events/` - the real objects and
   places each event turns on: Joyce's Christmas lights, Hopper's '79 K5
   Blazer, Billy's Camaro, Jonathan's Ford LTD and Polaroid, Vecna's
   grandfather clock, the isolation tank, the quarry, Pennhurst, Kamchatka's
   volcano, Eddie's guitar, D&D dice... Every timeline beat, 33 of 34
   moments, four creatures and every Explore card carry one, graded into
   the show's look. Never frames from the show; all licence-checked
   (CC0 / CC BY / CC BY-SA / public domain only). Every chapter has one
   too (`Episode.photo`), behind its Story-mode title card; those stills
   are bundled at up to 1400px so they hold up full-screen, and
   `DuotonePhoto` decodes small tiles at 480/960px so lists stay light.
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
  **Next up**. Each chapter links to the moments and timeline beats that
  happen in it.
- **Spoiler shield** (Settings) — timeline beats and moments from chapters
  you haven't watched are redacted like a declassified lab file: blurred
  photo, blacked-out text, "Classified · watch S2 · E6 to unlock". Tap to
  declassify one.
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

- **Score** — the synth theme loops under the title sequence and Story mode,
  fading in and out (`Score.start` / `Score.stop`).
- **Cues in context** — crossing worlds (portal + chime), opening a villain's
  dossier (Vecna's clock, the Demogorgon's screech, the Mind Flayer's
  heartbeat), tapping a creature, rolling the dice to start Trivia, tuning
  into Transmissions. All gated by the Sound effects setting.

---

## 6. Animation & special effects (implemented)

- **The world flip** — the toggle turns the whole screen over on its
  horizontal axis: Hawkins rotates away, the world switches exactly when the
  screen is edge-on, two forked red lightning bolts strike with a double
  flash and a soft pressure wave, the frame shakes with the thunder, and the
  Upside Down turns in from the other side as vines grow across every card.

- **The Gate transition** (`RiftPageRoute`) — every card → screen push tears
  the new page open through a writhing, red-rimmed portal that grows from the
  exact point you tapped (`TapOrigin`), while the old page dims and sinks.
  Goo strands stretch across the edge and it throws off embers; in the
  Upside Down the rim crackles with red lightning in cold haze and throws
  off ash. Back closes the tear. `STHero` flies cast portraits and season
  art into the page header, keeping the card's rounded corners in flight
  with a burning neon edge.
- **The storm** (`RiftFlash`) — flipping worlds cracks two forked red
  lightning bolts across the screen in a double strike, rolls a red-blue
  shockwave, and the theme eases over 600ms.
- **Flicker-in** (`FlickerIn`) — cards stutter on like a Hawkins streetlight
  when something is near, staggered, only while a screen is arriving.
- **Neon ignition** (`NeonIgnite`) — screen titles and the logo power on
  like a neon sign: dull glass, a buzz, dark, a catch, then steady.
- **Lab teletype** (`TypewriterText`) — field reports, spoiler reveals and
  the quote of the day type themselves out, without reflowing the layout.
- **Parallax** — Party portraits drift slower than their cards as the
  carousel slides.
- **Wrong-answer jolt** — Trivia's answer board shakes like a slammed lab
  door; a right answer throws sparks.
- **VHS tune-in** — spoiler reveals split into red/cyan ghosts that jitter and
  snap together, like a tape finding its tracking.
- **Splash** — the title sequence: it opens in extreme close-up on the
  hollow red letters and slowly pulls back and drifts until the logo
  settles, the bars light and the score plays; then the Christmas lights
  and "tap to enter".
- **Film layer** — grain re-rolls 24 times a second under a soft vignette,
  across every screen; Story mode adds letterbox bars and a Ken Burns drift.
- **Surveillance feed** — dossiers record: blinking REC, live timecode,
  viewfinder brackets, tape tearing in the Upside Down.
- **Living art** — the Gate breathes, Christmas lights chase, ash drifts in
  the Upside Down, the stats radar draws on with a neon edge.

---

## 7. Settings, accessibility & platform polish

- **Settings** (the dial on Home): spoiler shield, score, sound effects,
  trailer previews, reduce effects, watch-progress reset. All persisted, as
  is the world you were in.
- **Reduce effects / photosensitivity** — the system's Reduce Motion or the
  in-app switch folds into `MediaQuery.disableAnimations` at the shell, and
  every effect honours it: no lightning, sky flashes, flicker, VHS glitch,
  typewriter, film grain, Ken Burns drift or billboard trailer; the Gate
  becomes a fade, the world flip a crossfade, and the splash skips the
  pull-back.
- **Story mode** hides the system bars (immersive) and restores them on exit.
- **Tablets** — content capped at a comfortable width (`kMaxContentWidth`),
  Explore goes three-across.
- **App identity** — an original neon "ST" icon (all platforms, Android
  adaptive), black launch screens (no white flash before the splash), and a
  real app name.

## 8. Important moments
All important, twisting and ironic moments of the series are in the
**Moments** screen (see §4), one card per moment, in watch order.

---

## 9. Verify

```bash
flutter analyze   # No issues found
flutter test      # 40/40 pass (widgets, world flip, shield, settings, story mode, trailers, data integrity)
flutter build web --release
flutter build ios --debug --no-codesign
```

Run it: `flutter run` on a device (trailers need a network connection).

> Unofficial fan work, not affiliated with or endorsed by Netflix. Built for
> personal/educational use.

## 10. Videos & Images
Now use the videos and images from the docs folder and use it anywhere fits, you can use character image from the videos and also audios, apply the vidoes and images accordingly and make the app wonderful, and rotate all the videos like "[4K] Stranger Things Finale Edit... Follow me @samedits.fx for more!.. [stranger things finale", to landscape because they are landscape videos so they can look proper, again take images from the videos and clips from the videos as required in the app

• TODOs
☐  Inspect docs videos/images: dimensions, orientation, durations
☐  Transcode chosen videos (compress, portrait-fit) + slice segments into assets/video
☐  Extract character/scene stills from videos into assets/images drop-in keys
☐  Add video_player dep + AppVideo widgets (loop bg, full player, test fallback)
☐  Wire videos/images into Home hero, Gate screen, Cast/Character, Bestiary, Moments
☐  Add Gate entry point on Home
☐  Extract audio clips from videos into soundboard
☐  Run flutter analyze + full test suite, verify

## 11. Improvements
Imorove the app, use more animations for visual effects same in the series, the doors to upside down, and other effects from the series do properly in this app, make it more good

## 12. Themes
Check theme folder in docs and try making the app better, if you find something better in these themes then apply on the app in wonderful way.