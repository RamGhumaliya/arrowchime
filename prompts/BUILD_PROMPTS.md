# Build Prompts for Claude Code — Arrowchime (Android + iOS)

Paste these **one at a time**, in order. Each phase ends with an acceptance checklist; don't move on until Claude Code shows it passing (test output, screenshots, short demo). Phases marked 🎨 end with the **design review gate** — you look at the screenshots and approve before continuing.

---

## Session Start (beginning of every session)
```
Read CLAUDE.md, docs/10_DESIGN_SYSTEM.md and docs/PROGRESS.md (create PROGRESS.md if
missing). Summarise in 5 lines: current phase, what's done, what's next, open issues,
and any design-gate items waiting for my review. Then wait for my instruction.
```

## 🎨 Design Guard (paste at the start of ANY UI work, or whenever the look drifts)
```
STRICT DESIGN MODE. Before writing any widget:
1. Re-read docs/10_DESIGN_SYSTEM.md fully. The BANNED list (B1–B16) is an automatic fail.
2. Use only TB* components from lib/core/ui/components and tokens from
   lib/app/theme/tokens.dart. No literal colours, paddings, radii, shadows or durations
   in feature code. No unstyled Material/Cupertino widgets, no Material icons, no emoji,
   no Roboto/Inter, no purple-pink gradients, no glassmorphism, no random glows.
3. Toybox 3D: one light source top-left; every interactive object = face + bevel/lip +
   highlight + shadow + pressed state.
4. If a screen/state is not specified in docs/10 §7, write its ASCII layout there and ask
   me to approve it before coding.
5. Do not generate, download or embed images as art. Use the obvious placeholders.
6. When done: add to the Design Gallery, capture screenshots (iPhone SE, iPhone Pro Max,
   Android tablet landscape for game screens) into docs/screenshots/<phase>/, self-review
   against docs/10 §1–§8 and docs/09 §8 (D1–D9), log the table in docs/PROGRESS.md, then
   STOP and ask me to review.
```

---

## Phase 0 — Scaffold
```
Read CLAUDE.md and every file in docs/. Then scaffold the project:

1. Create a Flutter app "arrowchime" (org: com.webazonic) for **android and ios only**
   (`--platforms=android,ios`) on the current stable Flutter (3.47.x). Follow the 3.47
   Material/Cupertino standalone-package setup from the official docs. Do not create web/
   or desktop folders.
2. Flavors dev/prod with entrypoints lib/main_dev.dart and lib/main_prod.dart
   (ids com.webazonic.arrowchime.dev / com.webazonic.arrowchime). Portrait on phones,
   all orientations on tablets.
3. Add packages with `flutter pub add` per docs/05 §1 (skip Firebase, ads and IAP for now).
   Add very_good_analysis (or flame_lint) and fix all lints.
4. Create the folder structure from docs/05 §3 (including lib/core/ui and
   features/design_gallery).
5. lib/app/theme/tokens.dart with EVERY token from docs/10 §3 (colours, spacing, radii,
   elevations e1–e3 as BoxShadow lists, motion durations/curves) and chapter_theme.dart
   with the 5 chapter palettes from docs/06 §4. Bundle Fredoka + Nunito; typography.dart
   with the styles in docs/10 §4 (sticker effect can be stubbed until Phase 3).
6. go_router with stub routes: splash, home, chapter map, level (/level/:chapter/:index),
   daily, shop, collection, achievements, settings, design_gallery + level_lab (debug only).
   Stub screens may be plain token-coloured backgrounds with a centred label.
7. Copy assets/levels/*.json and assets/branding/* from this pack into the project and
   register asset folders in pubspec.
8. Create docs/PROGRESS.md and a GitHub Actions workflow per docs/05 §11.

Acceptance: app runs on Android emulator and iOS simulator; `flutter analyze` clean;
no web/ folder; tokens file covers all of docs/10 §3.
```

## Phase 1 — Core level engine (pure Dart)
```
Implement lib/core/level/ exactly as docs/03 §2 & §5 and docs/04 §1–2, §4.
- Models: Cell, Direction, Arrow, Gate, Portal, Level, BoardState.
- Level/pack JSON parsing + validation per docs/04 §1.
- GameEngine: tap(arrowId) -> List<GameEvent>; hearts, stars, undo (snapshot stack),
  mechanics: rotator, key/gate, frozen, linked pair, portal (switcher/splitter rules
  behind a feature flag).
- prng.dart: Mulberry32 + FNV-1a (32-bit masked) with golden-sequence tests.
- GreedySolver, SearchSolver (memoised DFS, 200k state limit), Hint service.
- NO Flutter imports in lib/core/level/ — add a test that fails if one appears.
Tests: table-driven, using assets/levels/sample_levels.json plus hand-made fixtures for
every mechanic and every engine-level row of docs/09 §2.

Acceptance: 100% line coverage for engine/rules/solvers; all three sample levels solve and
their meta.solution replays to a win.
```

## Phase 2 — Generator, difficulty, tools
```
Port docs/reference/generator_reference.py to Dart in lib/core/level/generator/ and extend
it per docs/04 §3 (masks, gates+keys, frozen, linked, portals, rotator generate-and-test),
plus difficulty.dart per docs/04 §5.
Create:
- tool/level_gen.dart (flags from docs/04 §7; chapter band table + sawtooth; writes meta)
- tool/level_check.dart (schema + rules + solvable + band ±6; non-zero exit on failure)
- tool/gen_placeholder_assets.dart: every path in assets/ASSET_MANIFEST.md as an OBVIOUS
  placeholder (docs/10 §10): token-coloured gradients, simple 3-tone painted icon shapes,
  synthesized WAV tones for notes/SFX. Never fetch or generate realistic images.
Generate assets/levels/ch1.json (60 levels; L1–10 follow the onboarding table in docs/03 §6
— hand-author them if needed) and a daily pack for the next 366 days.

Acceptance: 1,000 random seeds per chapter → 100% solvable; same seed ⇒ identical JSON
(golden fixtures); level_check passes; placeholders exist at every manifest path.
```

## 🎨 Phase 3 — Design system & component library
```
[Paste the Design Guard first.]
Build lib/core/ui/ exactly per docs/10:
- painters/: ceramic (button), enamel tube (arrow preview), lacquered paper/wood (panel,
  shelf), brass (plaque, frame), crystal (ice) — each implementing the light & material
  rules in docs/10 §2 (face, bevel-light, bevel-dark/lip, specular, contact + drop shadow).
- components/: every TB* component in docs/10 §5 with all states (idle, pressed, disabled,
  selected) and the press physics (face moves down 4 dp, lip compresses, shadow tightens,
  haptic, mTap/mRelease).
- TBText with sticker treatment (stroke + hard drop) for display/title/counter/button.
- icons/: placeholder 3D icon painters for all 24 icons (3-tone + highlight), clearly
  marked placeholder in the gallery.
- features/design_gallery: one scrollable page per component group showing every state on
  the cream panel, dark ink background and one chapter background.
- Golden tests for every component state at 1× and 3×.

Acceptance: Design review gate (docs/10 §11) — screenshots at iPhone SE + Pro Max in
docs/screenshots/phase3/, self-review table in PROGRESS.md, zero B1–B16 violations,
D2/D3/D4/D6 pass. STOP for my review.
```

## 🎨 Phase 4 — Playable game screen
```
[Paste the Design Guard first.]
Build features/game per docs/05 §4, docs/03 §2–3, §9 and docs/10 §7–8:
- ArrowGame (FlameGame) with CameraComponent: pinch zoom 1×–4×, clamped pan, double-tap fit.
- BoardComponent: recessed felt tray with wooden rim, stitched grid lines (toggle), mask shapes.
- ArrowComponent: the 5-pass glossy enamel tube + rounded head + nock tail (docs/10 §8),
  cached Pictures per zoom bucket.
- TapResolver with tap assist; long-press Peek route line.
- Exit animation along the extended path (PathMetric); blocked bump/recoil; blocker flash.
- GameSessionController (Riverpod) bridging engine events -> Flame + HUD.
- HUD from TB components only: ribbon title, TBPill hearts/coins, TBFlowMeter, bottom wooden
  shelf with TBIconButtons (Undo, Hint, Grid, Fit), left-handed mirror; Win and Fail TBSheets
  exactly as the ASCII specs in docs/10 §7.
- Load levels from assets/levels/ch1.json; Next goes to the next level.

Acceptance: play Ch1 L1–20 on Android and iOS; G1–G16 (docs/09 §2) pass; 60 fps in profile
mode on a 14×14 board; design gate passed (D1–D8) with screenshots of a dense board at 1×
and 4× zoom, win sheet, fail sheet. STOP for my review.
```

## Phase 5 — Juice & Arrow Symphony audio
```
Implement docs/07 and the full feedback table in docs/03 §4:
- AudioService on flutter_soloud: music/notes/sfx buses, per-chapter preload, iOS audio
  session set to mix with other audio.
- MelodyPlayer + melodies.dart (≈12 ORIGINAL melodies per chapter as scale-degree data),
  Flow tiers adding harmony, clear cascade + flourish, music ducking.
- SFX for every id in docs/07 §2; HapticsService.
- Particles (pooled), confetti in chapter palette, star stamping on the brass plaque,
  coin fly-to-pill, heart crack, Flow meter fills — all using motion tokens.
- Reduce Motion honoured everywhere.

Acceptance: a clean clear sounds like a coherent melody; no glitches at 10 taps/s; Reduce
Motion removes shake/confetti/parallax; still 60 fps.
```

## 🎨 Phase 6 — Meta & progression
```
[Paste the Design Guard first.]
Implement docs/03 §6–8:
- SaveData + SaveRepository on hive_ce with schemaVersion and migrations (docs/05 §6).
- Home exactly per docs/10 §7 (full-bleed diorama with parallax placeholder layers,
  restoration by fragments, pills, Daily plaque, streak, PLAY primary, shelf of 3 icon
  buttons); chapter map with TBChapterCards; stars/XP/coins; streak with freeze; Daily Knot
  (pre-baked pack + on-device fallback) with calendar and share card (RepaintBoundary ->
  PNG + emoji text via share_plus); daily quests; ~30 achievements; stats; settings (TBToggle,
  TBSlider; all options in docs/03 §8 incl. Relaxed mode, colour-blind palettes,
  left-handed layout).
- For every screen not yet in docs/10 §7: write its ASCII layout there and get my approval
  BEFORE coding it.
- Onboarding Ch1 L1–10 with hand cursor + ≤6-word captions (docs/10 §9 tone).

Acceptance: progress survives app kill; streak edge cases (docs/09 §4) pass; Daily Knot
identical on Android and iOS; design gate passed for every new screen. STOP for my review.
```

## Phase 7 — Mechanics content & Level Lab
```
- Render all mechanics per docs/10 §8 materials (wooden gate + brass keyhole, brass key fob,
  crystal ice with counter sticker, brass gear rotator, ceramic portal ring with swirl
  shader + fallback, brass chain links). Colour + symbol in colour-blind mode.
- One interactive tutorial level per mechanic (docs/03 §5).
- Generate ch2–ch5 packs with the band table; hand-tune boss levels.
- Level Lab (debug only; Material widgets allowed here): browse packs, play any level,
  overlay solution/difficulty/depth, regenerate one level, mark approved, export, FPS overlay.

Acceptance: all 300 levels pass level_check; each mechanic has tests + tutorial; mechanics
screenshots added to the Design Gallery.
```

## 🎨 Phase 8 — Shop, cosmetics, ads & IAP
```
[Paste the Design Guard first.]
- Cosmetics: arrow skins (docs/06 §6), trails, board themes, instruments; Collection screen
  with live preview on a mini board; optional glow.frag shader skin with fallback.
- Shop screen (ASCII layout approved first) — one primary CTA per view.
- Economy per docs/08 §1, all numbers from Remote Config defaults.
- Ask me: RevenueCat or in_app_purchase? Then implement the IAP catalogue (docs/08 §3),
  restore purchases, 24 h ad holiday after purchase.
- AdsService interface; AdMob implementation + UMP consent; fake for tests/dev.
  ad_policy.dart enforcing every rule in docs/08 §2 with time-mocked unit tests.
- iOS ATT pre-prompt (designed TBSheet) after level 5.

Acceptance: docs/09 §5 ad tests pass; sandbox purchases work on Android & iOS; design gate
passed for Shop, Collection, paywall sheets. STOP for my review.
```

## Phase 9 — Firebase, cloud save, analytics
```
- flutterfire configure for arrowchime-dev and arrowchime-prod (android + ios); init in
  bootstrap.dart.
- Auth: anonymous by default; link Google and Apple from Settings.
- Cloud save with the merge rules in docs/05 §6 (unit tests with conflict fixtures).
- Remote Config (docs/05 §10), Analytics events (docs/05 §9), Crashlytics, Storage download
  of new daily/event packs.

Acceptance: progress moves between an Android phone and an iPhone after sign-in; analytics
debug view shows level events with difficulty; a forced crash appears in Crashlytics.
```

## 🎨 Phase 10 — Polish, accessibility, performance, release
```
- Final art drop: replace placeholders with the human-made assets I provide (same paths);
  re-run all goldens and screenshot gates; report any visual mismatch.
- Accessibility checklist docs/09 §7; text scale 1.3×; screen-reader board summary.
- Performance pass on the device matrix (docs/09 §6); fix any frame > 16 ms.
- Localization scaffolding + Hindi as the first extra language.
- App icon/splash from assets/branding (final versions); store-screenshot helper route that
  stages beautiful boards; privacy policy/terms links; data-safety notes in docs/STORE.md.
- Release builds: AAB + IPA; fill docs/09 §9 checklist.

Acceptance: everything in docs/09 green incl. D9 stranger test; release candidates uploaded
to Play internal testing and TestFlight.
```

---

## Handy prompts

**Bug fix**
```
Bug: <what happened>, expected: <what should happen>, steps: <1,2,3>, device: <…>.
Write a failing test that reproduces it, fix it, run the full suite, update PROGRESS.md.
```

**Design looks generic / "AI-made"**
```
This screen looks generic: <screenshot / what's wrong>. Paste-in Design Guard applies.
List every violation of docs/10 §1–§8 you can find on it with file:line, propose the fix in
words, wait for my OK, then fix and re-run the design gate for this screen.
```

**Design change**
```
I want to change <rule/look>. Update docs/10 (or the relevant doc) first, show me the diff,
wait for my OK, then implement, update goldens, and re-run the design gate.
```

**Review**
```
Review all code changed in this phase against CLAUDE.md (design + engineering rules) and
docs/09 §1 and §8. List violations with file:line and fix them.
```
