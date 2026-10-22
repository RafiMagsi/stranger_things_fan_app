# 🛸 Stranger Things — Super Fan App

An unofficial, fan-made Stranger Things companion built with Flutter. This
document reflects the **shipped** architecture (it started as a plan and was
rewritten once the app was real). Everything here is implemented and covered
by tests.

---

## 1. Design language — CINEMATIC DARK

The single most important decision: **both worlds are near-black**. The show
lives at night — pure black frames, glowing red neon, cold spore light in the
Upside Down. There is no "light mode."

| World | Base | Accent | Feel |
| --- | --- | --- | --- |
| **Hawkins** (Right Side Up) | warm void `#0A0507` | brand red `#E50914` + gold | red neon on black |
| **Upside Down** | cold void `#05070B` | spore teal `#5BFFDF` + vine purple | decayed, bioluminescent |

- `WorldPalette` is a `ThemeExtension` carrying per-world accent/glow/surface
  colors, so widgets pull the right tokens **without brightness-branching**
  (`ThemeExtension` in `lib/core/theme/world_palette.dart`).
- The Hawkins ⇄ Upside Down toggle fires a full-screen **rift sweep**
  (`RiftFlash`) and swaps the particle field from red embers to teal spores.

### Typography
Both bundled fonts are **variable fonts** (Grenze wght 100–900, Space Grotesk
wght 300–700). Declaring them at several `weight:` steps does NOT move the
axis — Flutter renders the default instance. So real weight is driven through
`fontVariations: [FontVariation('wght', N)]` (see `lib/core/theme/text_styles.dart`).
- **Grenze** ≈ ITC Benguiat (the show's title face) — title pushed to 900, tight,
  glowing red.
- **Space Grotesk** — UI copy.
- **Special Elite** — dossier/typewriter flavor (reports, quotes, weaknesses).

---

## 2. Structure

```text
lib/
│── main.dart                     # ProviderScope, dual theme, world stack, rift flash
├── core/
│   ├── theme/  app_colors · app_theme · text_styles · world_palette
│   ├── state/  app_state (Riverpod: worldMode, audioEnabled)
│   ├── widgets/ particles · rift_route · glass_card
│   └── media/  asset_media · poster_image      # DROP-IN stills/trailers
├── models/     character · season · quiz_question · sound_clip
├── data/       characters · seasons · quiz · soundboard
│               timeline · locations · bestiary · quotes
└── screens/    splash · home · character_detail · seasons ·
                timeline · locations · bestiary · quotes ·
                quiz · soundboard · transmissions
```

---

## 3. DROP-IN media (add your own posters & trailers)

The app ships with **procedural key art** (gradients + icons) so it looks
complete out of the box, offline, and copyright-clean. You can drop **your
own licensed/captured** stills and trailers into the asset folders and the app
**automatically prefers them**, with procedural art as the fallback — no code
changes needed.

```text
assets/images/char_<id>.jpg     e.g. char_eleven.jpg, char_vecna.jpg
assets/images/season_<n>.jpg    e.g. season_4.jpg
assets/images/featured.jpg      the big home banner
assets/images/loc_<id>.jpg      e.g. loc_hawkins_lab.jpg
assets/images/monster_<id>.jpg  e.g. monster_demogorgon.jpg
assets/video/s1_teaser.mp4 … s5_teaser.mp4, featured.mp4
```

Resolution is handled by `AssetMedia` (`lib/core/media/asset_media.dart`) and
surfaced through the `PosterImage` widget, which tries the bundled file then
falls back to the procedural art. Run `flutter pub get` + rebuild after adding.

**Where to get real assets legitimately:** Netflix's official press/media site
publishes key art and trailers for editorial/fan use. Do not scrape TikTok /
Instagram / YouTube — that violates those platforms' terms and rips copyrighted
material; this app is deliberately built so it never needs to.

---

## 4. Fan content (all shipped)

- **Roster** — 15 characters + creatures with **actor credits**, story role,
  six-axis stats radar, skills, and a field-report quote.
- **Seasons** — all 5 seasons, 42 real chapter titles, expandable.
- **Timeline** — in-story chronology 1959 → 1987 as a glowing rail.
- **Hawkins Map** — recurring locations with drop-in stills.
- **Bestiary** — creatures with threat meters + weaknesses.
- **Quotes** — the wall of lines fans know by heart (long-press to copy).
- **Trivia** — 15 questions, animated feedback, score + rank.
- **Soundboard** — 12 original synth cues with amplitude meters.
- **Transmissions** — playable teasers with waveform + progress.

---

## 5. Audio — original, procedurally synthesized

No copyrighted recordings. `tool/generate_audio.py` synthesizes 12 WAV cues
(theme, screech, static, dice, squelch, portal, chime, coin, power, clock,
heartbeat, vines). Re-run it to regenerate or extend.

---

## 6. Animation roadmap (implemented)

- **Splash** — the title sequence rebuilt: letters start spread out and
  glowing, then converge (easeOutExpo) over a red bloom with particles.
- **`RiftPageRoute`** — custom transitions: incoming rises/fades/scales in;
  the outgoing screen drifts left and dims as it's pulled under. Works for
  every push and reverses on back.
- **Particles** — `ParticleField` (spores/dust), `ParticleBurst` (tap),
  rift painter, waveform painters.
- **Radar chart** — animated hexagon draw-on for character stats.

---

## 7. **Important Moments**
* Add All Important, Twisting, Ironic moments in the App

## 8. Verify

```bash
flutter analyze   # No issues found
flutter test      # 11/11 pass
flutter build web --release
```

Run it: `flutter run -d chrome` (or `-d macos`). Tune the drift/rift/particles
in `rift_route.dart`, `main.dart`, and `particles.dart`.

> Unofficial fan work, not affiliated with or endorsed by Netflix. Built for
> personal/educational use.
