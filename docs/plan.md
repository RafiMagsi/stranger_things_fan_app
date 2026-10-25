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
│   ├── audio/    sfx (Sfx cues; Soundtrack: title, Running Up That Hill, its
│   │             Upside Down twin, Story theme - claims, crossfades, lifecycle)
│   ├── platform/ test_env (isFlutterTest: no audio/webview under test)
│   ├── widgets/  neon_card (NeonCard, NeonTube, GlowBadge, SectionHeader, FlickerIn)
│   │             world_fx (WorldGrade, CardVines, NeonIgnite, TypewriterText, STHero,
│   │                       RedactedText, ClassifiedBanner, FilmGrain, SurveillanceOverlay)
│   │             st_logo · st_scaffold (STScaffold, WorldAtmosphere, NeonBackButton)
│   │             st_effects (CRT, ChristmasLights, KeyArt, DuotonePhoto, GateArt,
│   │                         VineOverlay, AlphabetWall)
│   │             rift_route (Gate transition, lightning storm) · world_toggle · particles
│   │             world_scenery (the Hawkins / Upside Down town behind every screen)
│   │             gate_wind · glow (GlowBatch, steppedValue)
│   └── media/    asset_media · poster_image · decode_size · app_video (ClipLoop, ClipPlayer)
│                 youtube_embed (app identity for the player, failure messages)
│                 art (CharacterArt, SeasonArt, LocationArt, EventArt)
├── models/       character · season (+Episode) · trailer · moment · media_credit · quiz_question · sound_clip
├── data/         characters · seasons · timeline · moments · locations · bestiary
│                 quotes · quiz · soundboard · credits · fan_media · gateways
└── screens/      splash · main_shell (5 tabs) · home · explore · watch · upside_down · more ·
                  story · seasons · season_detail · trailer_player · cast · character_detail ·
                  timeline · locations · bestiary · moments · quotes · quiz · soundboard ·
                  transmissions · reel · gallery · gate · credits · settings_sheet
tool/             build_fan_media.py (the fan-media pack from docs/ - images, video and all audio)
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
     VCR then plays that season's **fan cut** from the Reel inline, with
     sound, under a note that says why, with **Watch on YouTube** and
     **Try YouTube again** (`FanMedia.trailerCut`). Only a trailer without
     a fan cut shows the dead channel (TRANSMISSION BLOCKED / TAPE MISSING /
     NO SIGNAL after 15s of silence).
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
4. **The fan-media pack (personal build)** — the edits, fan art and sounds
   supplied in `docs/`, cut by `tool/build_fan_media.py` (see §10). Unlike
   the sources above this is other fans' work around Netflix's footage, so
   it's credited in-app and on the Credits screen, and stripped with
   `--clean` before any public release.

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

## 5. Audio — the show's own sounds only

Every sound in the app is cut from the fan edits (§10, assets/audio/captures):
the main title, Running Up That Hill (and its drowned Upside Down mix), the
Story theme, Vecna's voice, his clock's chimes and ticking, "It's almost
time", and the two world-switch hits. The synth effects (and
`tool/generate_audio.py`, which made them) are gone.

- **Soundtrack** — from the fan-media pack (§10): the main title on the
  landing page, Running Up That Hill under the app (slowed and drowned in
  the Upside Down), the theme in Story mode; silenced by anything with its
  own sound (`Soundtrack.claim` / `release`).
- **Cues in context** — crossing worlds (Vecna's clock striking on the way
  under, the main title's first synth hit on the way home - from the toggle,
  the Gate and the Upside Down tab), the same pair for a right or wrong
  Trivia answer, and Vecna's voice ("Max.") opening his dossier or Bestiary
  card. Creatures the footage has no clean cry for stay silent. All gated by
  the Sound effects setting.
- **Soundboard / Transmissions** — the captures: Main Title, Running Up That
  Hill (and from below), Vecna's "Max.", the Four Chimes, the Ticking, It's
  Almost Time.

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
flutter test      # 54/54 pass (widgets, tabs, worlds, soundtrack, fan media on disk, story mode, data)
flutter build web --release
flutter build ios --debug --no-codesign
```

Run it: `flutter run` on a device (trailers need a network connection).

> Unofficial fan work, not affiliated with or endorsed by Netflix. Built for
> personal/educational use.

## 10. Videos & Images
Now use the videos and images from the docs folder and use it anywhere fits, you can use character image from the videos and also audios, apply the vidoes and images accordingly and make the app wonderful, and rotate all the videos like "[4K] Stranger Things Finale Edit... Follow me @samedits.fx for more!.. [stranger things finale", to landscape because they are landscape videos so they can look proper, again take images from the videos and clips from the videos as required in the app

• TODOs
☑  Inspect docs videos/images: dimensions, orientation, durations
☑  Transcode chosen videos (compress, rotate sideways ones upright) + slice segments into assets/video
☑  Extract character/scene stills from videos into assets/images drop-in keys
☑  Add video_player dep + AppVideo widgets (loop bg, full player, test fallback)
☑  Wire videos/images into Home hero, Gate screen, Cast/Character, Bestiary, Moments
☑  Add Gate entry point on Home
☑  Extract audio clips from videos into soundboard
☑  Run flutter analyze + full test suite, verify

**Done.** All of it is rebuilt by one script, `tool/build_fan_media.py`, from
the files in `docs/` (credits for every piece: `lib/data/fan_media.dart`).

- **Rotation** - 22 of the 42 edits are landscape footage recorded sideways
  in a 9:16 frame (the samedits.fx finale edit among them). Each was checked
  frame by frame and turned 90° the right way, so they play as widescreen.
- **The Reel** - 31 edits, upright, with sound, on four shelves (The Party,
  Vecna's Curse, The Upside Down, Teasers & Countdowns). The fullscreen
  player has a VCR display, play-all through a shelf, ±10 s, mute, and a
  *turn sideways* button that rotates the phone for widescreen edits.
- **Characters** - every one of the 17 dossiers has a still and a silent
  loop cut from the footage (crop centred on the face; group shots cropped
  around one person), plus a WATCH button that plays their edit with sound.
  Eddie Munson and Billy Hargrove were added as new dossiers.
- **Everywhere else** - the Home hero loops the finale edit; the Upside
  Down tab, the Gate, the Watch tab, Explore tiles and the Bestiary all run
  their own loops. Loops are muted, follow the world's colour grade, pause
  off-screen, and stay still under reduced effects or with Motion clips off.
- **Fan art** - the 21 screenshots are cropped to the art itself (app chrome
  removed), turned upright, and hung in a gallery with a pinch-zoom viewer;
  pieces also serve as season posters and backdrops.
- **Sound** - identified by analysis, not guesswork: the main title (Cmaj7
  arpeggio at ~84 BPM), Running Up That Hill (Ab-Bb-Cm at the record's own
  108 BPM; one clip turned out to be a sped-up copy and wasn't used), the
  pumpkin-clock edit's tick-tock and chimes. Unidentifiable songs were left
  out rather than mislabelled.
- **Soundtrack** - the main title plays on the landing page and runs out
  into Home; then Running Up That Hill plays under the whole app. Cross into
  the Upside Down and it crossfades to the same song slowed, muffled and
  echoing, as if heard from the other side. Story mode switches to the
  theme; the player, trailers, the soundboard and Transmissions silence it;
  it sleeps in the background; *Music* in Settings turns it off.
- **Verified on the iOS simulator** - all 58 videos and 19 sounds were
  played through the app's own players and every one advanced; the
  soundtrack was logged switching title -> Hill -> drowned Hill on a flip.
- **Size** - ~89 MB of assets (67 MB video). It's a personal build: strip
  the pack with `python3 tool/build_fan_media.py --clean` before publishing
  anything, since the edits are other fans' work around Netflix's footage.

## 11. Improvements
Imorove the app, use more animations for visual effects same in the series, the doors to upside down, and other effects from the series do properly in this app, make it more good

**Done.**
- **The Gate** - a blast door on Hawkins Lab's Sublevel 3. Hold to force it:
  the steel halves grind apart, the room shakes harder the longer you hold,
  the warning lamp strobes, and behind the door a living tear opens - its
  edge crawling, goo strands bridging it, light and spores pouring out,
  vines creeping in, the other world's footage inside it. Halfway, the
  membrane gives with a thud; all the way, a white-out and the whole app
  turns over into the other world. Let go and it heals shut.
- **The town behind every screen** - see Themes below.
- **Portal ring** on the Upside Down tab, pulsing gate lamps, and the
  existing world flip, Gate transition and lightning storm.

## 12. Themes
Check theme folder in docs and try making the app better, if you find something better in these themes then apply on the app in wonderful way.

**Done.** From the four concept boards:
- **Navigation** - a five-tab neon bar (Home, Explore, Watch, Upside Down,
  More), the lit tab glowing with a tube over it.
- **Home** - the series at a glance (seasons, chapters, dossiers, moments),
  four round quick doors (Timeline, Monsters, Characters, Episodes), and a
  *Latest Twists* row of glowing case cards (spoiler-shielded).
- **Explore** - the archive as Hawkins Lab files, filterable by shelf.
- **Upside Down tab** - "You are entering / now in the Upside Down" over
  live red lightning, Creatures / Locations / Hive Mind, *A Mirror World*,
  *Active Gateways* (every gate in the series, open/sealed/destroyed, each
  linking to its chapter), *Survival Tips*, and Cross over / Return home.
- **More** - Story mode, the Reel, fan art, sounds, quotes, trivia,
  settings, credits, about.
- **Type** - Oswald (condensed, OFL) for poster headlines and section
  titles, as the boards use.

**Hawkins and the Upside Down, made obvious** (`WorldSceneryPainter`):
- *Hawkins* - a night skyline along the foot of every screen (and right
  behind Home's logo): pines, the water tower with HAWKINS on the tank and a
  blinking red light, a house with its windows lit, telephone wires strung
  with Christmas bulbs, a moon, stars, fireflies, and the Party riding past
  on bikes with their headlamps on. Every so often the lights flicker.
- *The Upside Down* - the same town, dead: dark windows, dead bulbs with a
  couple sputtering red, vines hanging from the wires and the tower,
  tendrils climbing out of the ground; storm clouds, the Mind Flayer
  looming in them and lit red by each lightning strike; spores and broken
  debris floating upward, a demobat flock crossing the sky - and the town
  hanging upside down from the top of the screen.

## 13. Fixes - round 2 (Oct 24)

- **YouTube** - still refused on this network: YouTube answers every
  embedded player from it with "confirm you're not a bot", even Google's
  own sample video, so no app setting can get past it (on mobile data it
  plays). The trailer screen now plays the season's fan cut instead of
  stopping at a dead panel (see §3).
- **Vecna's dossier** - his video was hidden under the procedural "room"
  (clock, rain, gold light), which paints a near-opaque wall. The room is
  now the loop's placeholder: shown until the footage is up, never over it.
- **WATCH button** - sat 56 pt from the top of the header, inside the
  notch and toolbar on a real iPhone, under the world switch. It now sits in
  the badge row beside the name.
- **Audio on a real iPhone** - the audio session is set explicitly at
  launch (`Soundtrack.configure`): the playback category, so sound plays
  with the ring/silent switch on as video does, mixing with other audio so
  the app's video players and the music don't cut each other off. Cues no
  longer stop the shared player between sounds, which also switched the
  session off. On the web, music starts on the first tap (browsers block it
  before). `--dart-define=AUDIO_LOG=true` prints what the audio is doing.
- **Opening titles** - the app opens on the show's Season 1 opening credits
  (`assets/video/intro.mp4`, cropped to the 2:1 picture) with the theme and
  a Netflix-style SKIP INTRO; at the end the Gate opens onto Hawkins and
  Running Up That Hill takes over. Settings > Opening titles turns them off
  (then the rebuilt five-second sequence plays).
- **Lighter effects**
  - Every small light (bulbs, embers, spores, fireflies, the moon's halo,
    storm clouds) is drawn from one pre-rendered glow sprite in a single
    batched `drawAtlas` call (`GlowBatch`) - no blur filters, no per-light
    gradients each frame.
  - The town's static parts are recorded once per world-depth step and
    replayed; only what moves is drawn each frame.
  - Sky, scenery, particles and creature animations step at 30 fps.
  - Video loops load only while visible and give their decoder back two
    seconds after being hidden (another tab, a page on top).
  - Fewer shell particles in the Upside Down, where the town already has
    spores.
  - Tabs fade up into place when you switch.

## 14. Creatures - round 3 (Oct 24)

- **Demogorgon** - the synth "screech" that opened its dossier and Bestiary
  card didn't sound like the show, and no edit has a real Demogorgon roar
  (every shot is set to music; an OCR sweep of all 42 edits found sound
  captions only in #26, the chimes and ticking), so those two stay silent
  until there's a real one. The drawn "flower" animation over its footage
  is gone too.
- **Vecna** - the clock animation is gone from his dossier and his Bestiary
  card, and his file now opens on his own voice: "Max.", from #26, which
  carries the show's audio with subtitles burned in. The line was found by
  reading those subtitles off the frames (OCR) - it's too deep for speech
  recognition, which only found song lyrics in the other edits. The same
  subtitles mark the real [chimes] and [ticking continues], which replace
  the earlier guesses. His Bestiary still is a brighter frame (the Creel
  house), so the card no longer reads as an empty panel.
- **All creatures** - every procedural creature overlay (`MonsterFx`: the
  Demogorgon's maw, the Mind Flayer's storm, Vecna's motes and clock, the
  demodogs, demobats and the Flayed) and Vecna's drawn room are removed:
  the creatures with footage show the footage, the rest their art, and
  ~1,100 lines of per-frame drawing are gone.

## 15. Show sounds only, music fixed - round 4 (Oct 24)

- **Only the show's own sound** - the synth effects were deleted from
  assets/audio, so every cue now uses a capture or is gone: the world switch
  (Vecna's clock strike under, the main title's synth hit home) also marks
  Trivia answers; the dice, static, portal, power and creature cries are
  removed; the soundboard and Transmissions play the captures;
  `tool/generate_audio.py` is deleted. Only Vecna has a voice - none of the
  42 edits has a clean creature cry (an OCR sweep found sound captions only
  in #26).
- **World switch** - Vecna's clock (#26's first [chimes]) going under, the
  main title's first synth chord (#22) coming home, cut with a 20 ms attack
  so they land on the flip (`Sfx.crossing`).
- **Background music** - iOS reports "finished" at the end of every pass of
  a looping track; the soundtrack took that as the end and reloaded Running
  Up That Hill every 55 s. Loops are now left to loop, and changes are
  applied one at a time (a fast double flip could overlap two loads and
  leave the player silent). Checked on the simulator: the hill loops past
  60 s untouched, and three flips in 0.6 s settle on the right track.
  `--dart-define=AUDIO_LOG=true` also logs the music's position every 10 s.
- **Flip crash** - flipping back before the drifting ash/embers had faded
  out put two layers with one key in the switcher (a red-screen assert in
  debug); each crossing now gets its own key.
- **Test** - "every sound is bundled" scans lib/ for every audio path and
  checks it's a capture on disk, so a missing or synth file fails the tests.
