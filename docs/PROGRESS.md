# PROGRESS — Arrowchime

## Current phase
**Phase 8 — Shop, cosmetics, ads & IAP: built and verified (1,333 tests green, analyzer clean), NOT committed; design gate: the human reviews `docs/screenshots/phase8/` (30 images).** Phase 7 is committed (`6d8e7cd`).

(Older entry:)
**Phase 7 — Mechanics content & Level Lab: built and verified, NOT committed.** Phase 6 is committed (`87f2120`); its design review is still open.

(Older entry:)
**Phase 6 — Meta & progression: built and verified, NOT committed; design gate: the human reviews `docs/screenshots/phase6/` (31 images).** Phases 0–5 are committed (`0d78c7b` is Phase 5).

(Older entry:)
**Phase 5 — Juice & Arrow Symphony audio: built and verified, NOT committed; it needs a human with ears (see "Phase 5 — for the human").** Phase 4 is committed (`f0aab23`); its design review is still open.

(Older entry:) **Phase 4 — Playable game screen: built and verified; NOT committed. Design review gate (docs/10 §11): the human reviews `docs/screenshots/phase4/` (20 images) and the questions in "Phase 4 — for the human" below before Phase 5.** Phases 0–3 are committed; Phase 4 is a working-tree change waiting for your review and your word to commit.

## Done
- Flutter pinned with FVM to **3.47.7 stable** (Dart 3.13.5) via `.fvmrc`; the machine's global Flutter is a 3.49 `main` build and is left untouched. Run commands as `fvm flutter ...`.
- Android + iOS only (no web/desktop folders).
- Android: namespace/applicationId `com.webazonic.arrowchime` (+ `.dev` suffix for dev), flavors `dev`/`prod`, display names "Arrowchime Dev"/"Arrowchime".
- iOS: build configs `Debug|Release|Profile-{dev,prod}`, schemes `dev`/`prod`, bundle ids `com.webazonic.arrowchime[.dev]`, iPhone portrait only, iPad all orientations. **Not built — needs a Mac.**
- Orientation policy at runtime: portrait on phones, all on tablets (shortest side >= 600).
- Entrypoints `lib/main_dev.dart`, `lib/main_prod.dart` -> `bootstrap.dart`. (`lib/main.dart` removed; always pass `-t`.)
- Packages added (docs/05 §1, no Firebase/ads/IAP): flame, flutter_riverpod, riverpod_annotation/generator, go_router, freezed(+annotation), json_serializable/annotation, hive_ce(+flutter), flutter_animate, share_plus, package_info_plus, url_launcher, in_app_review, connectivity_plus, intl, flutter_localizations, build_runner, flame_test, very_good_analysis (replaces flutter_lints).
- Folder structure from docs/05 §3 (empty dirs hold `.gitkeep`).
- `lib/app/theme/tokens.dart` (all docs/10 §3 tokens + light/size constants), `chapter_theme.dart` (5 chapters), `typography.dart` (6 styles; sticker painting stubbed for Phase 3).
- Fredoka + Nunito (OFL variable fonts) bundled in `assets/fonts/` with licences.
- go_router stub routes for every screen; `/design-gallery` and `/level-lab` only in debug.
- l10n via ARB (`lib/l10n/app_en.arb`, generated to `lib/l10n/gen`).
- `.github/workflows/ci.yml` per docs/05 §11.
- Verified: `flutter analyze` clean, `dart format` clean, 6 tests pass, dev APK runs on Android emulator (splash stub, Fredoka renders).

## Phase 1 — done (lib/core/level/, pure Dart)
- Models: `Cell`, `Direction`, `Arrow`/`ArrowKind`/`GateColor`, `Gate`, `Portal`, `Level`/`LevelMeta`/`LevelPack` (strict schema-v1 JSON parsing + `toJson`), `BoardLayout` (static topology, typed lists), `BoardState` (mutable runtime state + `key` for memoisation).
- `level_validator.dart`: game-rule validation (adjacency, overlaps, mask, head-back, rotator/switcher single cell, key colour, link pairs, gates, portals, self-crossing ray, portal cycles).
- `engine/`: `Rules` (freedom, ray tracing through portals with loop safety, removal side effects), `GameEngine` (tap, undo via snapshots, hearts, stars, relaxed mode, peek paths, reset), `GameEvent` sealed hierarchy, `UndoStack`.
- Mechanics: rotator, key/gate, frozen, linked pair, portal; switcher and splitter implemented behind `EngineOptions.enableSwitcher/enableSplitter` (off = behave as normal arrows).
- `prng.dart`: Mulberry32 + FNV-1a + `dailySeed`; golden sequences from an independent Python port.
- `solver/`: `GreedySolver` (waves, free counts for difficulty), `SearchSolver` (memoised DFS, 200k state limit, `trapRatio`), `HintService` (cached per state), `isMonotone`.
- `pack_loader.dart`: parse + validate packs/levels from JSON text.
- Models `Cell`, `Arrow`, `Gate`, `Portal`, `Level`, `LevelMeta`, `LevelPack` are **freezed** (generated `*.freezed.dart` are committed so `dart run tool/...` works without build_runner; CI regenerates anyway). Parsing/`toJson` stay hand-written for strict schema checks (`@Freezed(fromJson: false, toJson: false, makeCollectionsUnmodifiable: false)`). `BoardLayout`/`BoardState` (mutable, typed lists), events and `SolveResult` stay hand-written.
- Tests: 205 new tests under `test/core/level/` (table-driven parse/validate cases, a fixture per mechanic, every engine row G1–G12 and G16 of docs/09 §2, solver fixtures, sample levels solve + `meta.solution` replays to a win, pure-Dart guard that fails if `package:flutter`, `dart:ui` or `dart:math` is imported under `lib/core/level/`).
- Coverage (lcov): 100% of lines for `engine/*` and `solver/*` (also prng, validator, pack_loader, events). `models/level.dart` is 201/202 (the missed "line" is the closing `),` of a `throw const` that the test does exercise).
- `flutter analyze` clean, `dart format` clean, 217 tests pass with plain `fvm flutter test`.

### Phase 1 design decisions (please confirm)
- (Resolved) Level models converted to freezed as requested by the human.
- Added `meta` package (for `@immutable` on `Cell`); pure Dart.
- **Flow streak is not in the engine** (it depends on wall-clock time, 1.5 s); it belongs in `GameSessionController`. Engine exposes the data it needs (events).
- Stars = 3 − hearts lost, clamped to 1–3 (equals GDD for 3 hearts); relaxed caps at 2.
- Peek (`exitPaths`) ignores obstacles and draws the whole route to the edge so it never reveals free/blocked.
- Linked pair: both arrows must be free ignoring each other; a frozen partner makes the tap a *blocked* tap (heart lost) with blocker type `frozenPartner`.
- A ray that cycles through portals forever is "blocked" (type `loop`); the validator rejects such levels.
- `SolveResult.depth` is greedy waves; `null` for the search solver (Phase 2 difficulty score must decide how to derive depth for rotator levels).
- Undo restores the board only (not hearts); the free-undo count / coin cost is economy, not engine. Undo is refused after win/loss.
- Daily pack JSON shape (`daily_{yyyy}.json`, keyed by date) is not specified in docs/04 beyond that; left for Phase 2.

## Phase 2 — done (generator, difficulty, tools, placeholders)
- `lib/core/level/generator/`: `GenParams`/`MechanicMix` (freezed), `LevelGenerator` (reverse construction, Mulberry32 only, portal-aware rays), `MechanicsPass` (gates+keys, linked, frozen, rotator generate-and-test; every step solver-verified), `Masks` (heart, ring, diamond, star, cross, circle), `ChapterPlan` (band table, sawtooth, Knot/Boss, mechanic budget, `paramsFor`), `PackBuilder` (bisects difficulty onto the target), `OnboardingLevels` (ch1 L1-10), `DailyKnot` (+ `DailyPack` model).
- `lib/core/level/difficulty.dart` (docs/04 §5 formula, `WaveStats`), `level_checker.dart`, `pack_loader.dart` (daily packs + one-level-per-line encoders).
- `lib/core/assets.dart`: `AssetCatalog` of all 305 manifest files + `AssetFormats` (png/wav placeholders, one place to switch to webp/ogg).
- Tools: `tool/level_gen.dart`, `tool/level_check.dart`, `tool/gen_placeholder_assets.dart` (+ `tool/placeholder/*`), `tool/print_golden_hashes.dart`.
- Shipped data: `assets/levels/ch1.json` … `ch5.json` (60 levels each, seed 1001), `daily_2026.json` (83 days from 2026-10-10) + `daily_2027.json` (283 days to 2027-10-10) = 366 days.
- 305 placeholder files (3.4 MB images, 3.6 MB audio): token-coloured gradients, flat 3-tone icon shapes lit top-left, "PLACEHOLDER" labels on branding/thumbs, synthesised WAV tones; asset directories registered in `pubspec.yaml`.
- Docs updated: `assets/ASSET_MANIFEST.md` (implementation note, fonts = variable TTFs, fragments rect format, level files), `docs/04` (daily format, §9 implementation notes).

### Phase 2 acceptance
| Criterion | Result |
|---|---|
| 1,000 random seeds per chapter → 100% solvable | pass: `generator_test.dart`, all 5 chapters, every mechanic incl. rotators/portals; each level also valid + `meta.solution` replays to a win with no heart lost |
| Same seed ⇒ identical JSON (golden fixtures) | pass on the Dart VM (9 hash fixtures) and **on the Android emulator** (`integration_test/determinism_test.dart`, 9/9). iOS not run (no Mac). `level_gen` run twice gives byte-identical packs (also a CI step) |
| `level_check` passes | pass: 8 files, 669 levels, 0.5 s; non-zero exit on failure |
| Placeholders at every manifest path | pass: 305/305 (`assets_test.dart` checks existence, PNG/WAV validity, pubspec registration, manifest coverage) |
| Analyzer / format / tests | clean / clean / 434 tests pass; 1,576 of 1,577 level+assets lines covered |

### Phase 2 design decisions (please confirm)
- **Daily range** (your choice): next 366 days from 2026-10-10, split into `daily_2026.json` + `daily_2027.json`. **All 5 chapters shipped now** (your choice) — the ch2–5 mechanics levels are generator-made and may be re-tuned in Phase 7.
- Placeholders use `.png` / `.wav` via `AssetFormats` (the manifest explicitly allows this); Rive files are **empty (0 byte) placeholders** and will not load until the real `.riv` exists; shaders are valid GLSL placeholders but are not listed under `flutter: shaders:` yet.
- `mechanics` in the difficulty score = each mechanic **type** present once (the doc was ambiguous); rotator `trapRatio` band default 0–0.5 (doc gives none); frozen counters `≤ min(position, 5)`.
- Waves for the score come from greedy whenever greedy can finish the level, so depth does not depend on the solver's path (fixed an early bug where rotator levels scored ≈ 100).
- The onboarding levels (L1–10) score ≈ 9–31, while L11–L15 target ≈ 14–25: the early curve is not monotone because onboarding levels are exempt from the band and floor out at ≈ 20–30 under this formula. Revisit if you want a smoother start.
- Daily Knot params by weekday (size 9–12, fill 0.70–0.84, mechanics ramp) are my design; not specified in the docs.
- `--delete-conflicting-outputs` no longer exists in build_runner (it only warns): CI no longer passes it; CLAUDE.md still lists it.
- Tool palette colours (`tool/placeholder/palette.dart`) mirror the theme tokens; a test fails if they drift.

## Phase 3 — Design system & component library (design gate: human review)
Built exactly per `docs/10`:
- `lib/core/ui/painters/`: `ceramic` (buttons), `paper` (panels/sheets, raised + recessed), `inset` (recessed wells), `wood` (shelf, tab bar, tray rim, felt), `brass`, `crystal`, `knob`, `enamel_tube` (the 5-pass arrow of §8: shadow, dark rim, body, light band, specular on up/left runs, rounded head, nock), `shade` (three-tone helper, deterministic grain).
- `lib/core/ui/components/`: `TBText` (sticker treatment once), `TBButton` primary/secondary/tertiary, `TBIconButton` (+ `TBBadge`), `TBPill`, `TBPanel` raised/recessed, `TBRibbon`, `TBSheet` (+ `showTBSheet`), `TBToggle`, `TBSlider`, `TBTabBar`, `TBStarRow`, `TBProgressBar`, `TBToast` (+ `showTBToast`), `TBChapterCard`, `TBFlowMeter`, `TBTray`.
- `lib/core/ui/icons/`: 25 code-painted 3-tone placeholder icons (24 + `back`, added in Phase 4) (`TBIcon`), names equal the asset manifest (a test checks it).
- `lib/features/design_gallery/` (debug route `/design-gallery`): 8 pages (Foundations, Buttons, Panels, HUD, Controls, Chapters, Icons, Materials); every component with all its states on cream, ink and one chapter background.
- Press physics: face down 4 dp, lip 6 -> 2 dp, shadow e2 -> e1, haptic, mTap/mRelease with overshoot; Reduce Motion = 160 ms fade, no overshoot. Verified from rasterised pixels.
- Tokens added (and documented in docs/10 §3.6 and §3.8): `TBMaterials`, `TBBevel`, component sizes, motion extras.

### Phase 3 acceptance
| Criterion | Result |
|---|---|
| Golden tests for every component state at 1x and 3x (D6) | 172 goldens in `test/core/ui/goldens/` (86 cases x 2), all icons included (24 at the time; `back` added in Phase 4) |
| Screenshots iPhone SE (375 wide) + Pro Max (430 wide) + Android tablet landscape (1280x800) in `docs/screenshots/phase3/` | 19 images: 8 pages x 2 phone sizes + 3 tablet pages (Buttons, HUD, Chapters), made by `design_gallery_screenshots_test.dart` at 2x |
| B1–B16, D2 | automated scan `design_rules_test.dart` (17 tests) passes; B6/B9/B11–B15 reviewed by eye below |
| D3 light direction / D4 pressed states | pixel tests: highlight top-left, shadow down-right, lip 6/2 dp; every pressable has a pressed golden |
| Accessibility (docs/09 §7) | iOS 44 dp tap-target and labelled-tap-target guidelines pass on the Buttons, HUD and Controls pages; semantics tests for every component; Reduce Motion paths tested |
| Runs on device | debug build launched straight into `/design-gallery` on the Android emulator (`--route=/design-gallery`): renders with Fredoka/Nunito, no exceptions |
| Responsive (docs/09 §7, docs/03 §9) | 120-combination sweep (8 pages x 5 viewports from 320x568 to 1280x800 x 3 text scales) + 20 targeted tests: no overflow, tablets centre content (720 dp) and cap sheets (560 dp), 32 dp tablet margin, text scale up to 2x |
| Analyzer / format / tests | clean / clean / 889 tests pass (455 UI tests) |

### Design review self-review (docs/10 §11 step 3)
| Screen (page) | Issues I found in my own screenshots | Fixed |
|---|---|---|
| All pages | The ink900 surface vanished against the ink900 page background | Y (page is ink700) |
| Buttons | Pressed state looked right; but Flutter's `onTapDown` is delayed ~100 ms, so a real press would feel mushy | Y (raw pointer events) |
| Panels (sheet) | 3 stars overflowed the SE-width sheet by 1 px | Y (star 52 dp) |
| HUD | ×N badge overflowed the flow-meter box; unlit segments nearly invisible | Y |
| Controls | Toggle/pressables exposed an unlabeled duplicate semantics node (caught by the labeled-tap-target guideline) | Y (`ExcludeSemantics`) |
| Icons | Coin's engraved ring was a fat disc | Y |
| Foundations | r12/r20/r32 samples all looked like pills (32 dp high) | Y (square samples) |
| Materials / Chapters | none blocking: enamel tube, tray, wood, brass, crystal, chapter diorama frames read as intended | n/a |
| Process | `dart fix` once inserted `material.dart`/`cupertino.dart` imports into painters (B1) | Y (removed; the scanner test now guards it) |

Still open, for the human to judge: **(a)** (done: `star_empty` is now ink500, more visible on dark); **(b)** the chapter card scenes and all icons are code placeholders and say so in debug; **(c)** B6/B9/B11–B13 rely on my eye, and **D9 (stranger test with 3 people) needs humans**; **(d)** component sizes the spec does not fix (pill 40, toggle 64x36, slider 14/32, star 52, ribbon 56, tab 56, card 280x340) are my choices, listed in docs/10 §3.6: please confirm or change.

### Responsiveness pass (polish requested after the first review)
Found by the new sweep and fixed: the star row overflowed narrow boxes (now scales down); the tab bar clipped labels at larger text scales (grows taller, labels scale down); the gallery header squeezed the content at 1.5x text on a 320 px phone (the whole page now scrolls); the ×N brass badge's specular line stuck out of the badge; the slider's tap area was 40 dp (now 44, caught by the a11y guideline test); my first text-scale fix wrongly inflated the 44 dp tertiary button (now components grow only by the *extra* the text scale adds, nominal sizes unchanged); the tablet screenshot test measured page height from a centred offset (dead space). Added: `TBLayout` (`isTablet`, `screenMargin`, `extraLine`), `TBCentered`, button/pill/ribbon/tab overflow handling, centred capped sheets, tablet margins. Polish: the "empty" star is ink500 (visible on dark surfaces), the broken heart already was. Rules are in docs/10 §3.7.

### Phase 3 notes
- Goldens use a 1% tolerance (`test/flutter_test_config.dart`) because they are authored on Windows and CI runs on Linux; fonts are loaded from `assets/fonts/` in tests.
- Gallery labels are developer text (debug-only, not in ARB).
- `TBHaptics` is a thin hook over `HapticFeedback`; the real `HapticsService` replaces it in Phase 5.
- After switching Dart SDKs, `flutter run` can fail with "Invalid kernel binary format version" from a stale build-hook cache: delete `.dart_tool/hooks_runner`.

## Phase 4 — Playable game screen (design gate: human review)
Route `/level/chXX/N` now opens the real game (`LevelRef.parse`; a malformed route still falls back to the stub).

**What exists** (`lib/features/game/`, plus `core/economy`, `core/ads`):
- `flame/`: `ArrowGame` (FlameGame + `CameraComponent`; replays engine events only, reads the engine for queries), `BoardComponent` (felt tray + wooden rim, wooden blocks for masked cells, stitched grid toggle, gates, portals with a swirl, brass chains between linked arrows, long-press path preview), `ArrowComponent` (5-pass enamel tube via `EnamelTube.paintPath`; rotator brass ring, key badge with colour-blind symbol, frozen crystal + counter; exit along an extended `PathMetric` path 250–450 ms ease-in, blocked lurch 0.35 cell + elastic recoil 220 ms, blocker red flash twice, frozen shake, hint glow, rotator turn), `ParticlePool` (fixed 120 slots, no allocation while playing), `BakedPicture` (see Performance).
- `input/`: `TapResolver` (tap assist: 30% edge zone, nearest centre within 0.8 cell, dense boards 1.0 and head preference) and `BoardGestures` (raw pointer events: instant tap, 250 ms peek, pinch, drag, wheel; a double tap on empty felt fits the board; no 300 ms tap delay).
- `model/`: `BoardGeometry`, `ViewTransform` (zoom 1×–4×, pan clamped to board + 20%), `FlowTracker` (3 taps within 1.5 s give ×2, +1 per 2 more up to ×5).
- `state/`: `GameSession` (Riverpod notifier per `LevelRef`: engine + Flow + hint cache, event stream for Flame, free/paid undo and hint, retry, +1 heart, pays the win reward once), `SessionState` (freezed), `GameSettings` (left-handed, relaxed, grid), `LevelRepository` (loads `assets/levels/ch{N}.json`).
- `hud/` + `dialogs/` + `game_screen.dart`: top bar (back, compact ribbon, hearts capsule, coins pill), `TBFlowMeter`, wooden shelf (Undo, Hint, Grid, Fit; mirrored for left-handed; vertical on tablet landscape), `WinSheet`, `FailSheet` (thumbnail of the board where it ended), toasts, chapter scene behind everything.
- `core/economy`: `Pricing` (docs/08 defaults), `Rewards` (10 + 5 per star, Knot ×1.5, Boss ×3, +10 at Flow ×5; XP), `Wallet` (in memory until Phase 6). `core/ads/rewarded_ads.dart`: interface + `StubRewardedAds` (grants at once) until the ad SDK in Phase 8.
- Engine: `GameEngine.addHeart()` for the fail sheet (a heart already lost still counts against the stars).
- Also: `TBIconId.back` (25th icon), tokens `TBGameMotion` / `TBGesture`, 33 new ARB strings, `ChapterScenePainter` made public, `EnamelTube.paintPath`.

### Phase 4 acceptance (docs/09 §2 G1–G16 and §3 D1–D8)
| Goal | How it is checked | Result |
|---|---|---|
| G1 free tap, G2 blocked tap, G4 win pays once, G5 two quick taps | engine tests + `game_session_test` + `game_goals_test` (through the real screen) | pass |
| G3 Retry is free and has no ad | `GameSession.retry` + widget test through the fail sheet | pass |
| G6 undo restores arrow, rotations, thaws and gates | engine tests + `arrow_game_test` | pass |
| G7–G11 rotator, key/gate, frozen, linked, portal | engine tests; each mechanic also animates in `arrow_game_test` and has a screenshot | pass |
| G12 hints always lead to a win | follows hints only on Ch1 L1–20 plus 5 levels of each other chapter: wins, no heart lost | pass |
| G13 long-press 250 ms peek, no heart cost | `game_goals_test` (hold on screen) | pass |
| G14 pinch / double tap / wheel, 1×–4×, clamped pan | `view_transform` tests + screen gesture test | pass |
| G15 tap assist ≥ 95% | scripted taps on every cell of the densest board (24×24, cells of 12 dp): **2436 / 2436 = 100%** (taps up to 0.4 cell off-centre) | pass |
| G16 relaxed mode: no heart lost, max ★★ | `game_goals_test` | pass |
| Ch1 L1–20 playable | `integration_test/play_chapter1_test.dart` taps every arrow on screen and presses "Next level" 19 times on the Android emulator (Pixel 5, Android 15) and, in Phase 6, on a real RMX2156 phone | **pass** |
| iOS | not possible here (no Mac) | **not verified** |
| 60 fps in profile mode on 14×14 | see Performance | **not proven on a real device** |
| D1 / D2 (B1–B16, tokens only) | `design_rules_test` scans `lib/features/game` | pass |
| D7 sizes | screenshots at iPhone SE, Pro Max, Android tablet landscape | done |
| D8 5-pass arrow at 1× and 4× | `dense_*` and `dense_4x_*` screenshots | by eye: OK |
| Analyzer / format / tests | clean / clean / 987 tests pass | |

### Performance (emulator only, so indicative)
`integration_test/performance_test.dart` (run with `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/performance_test.dart --profile --flavor dev --dart-define=PERF_LEVEL=1/60`) prints frame times as `FRAMES …` lines; `baseline_test.dart` gives the emulator's floor. On this software-rendered emulator a trivial 40-circle animation costs **2.9 ms raster (p50)**.
- 14×14 board (Ch1 L60, 77 arrows): build p50 ≈ 2 ms, raster p50 ≈ 15–26 ms while pinching and tapping (46 ms before the work below). 24×24 board (Ch5 L60, 69 arrows): raster p50 ≈ 30 ms (69 ms before).
- What was done: static art is baked into images once per zoom bucket (`BakedPicture`: tray, grid, every arrow; vector fallback until baked, at most 8 bakes per frame, re-baking waits until a pinch ends); off-screen arrows are not drawn; arrows in flight use a hard shadow instead of a blurred one; particles are pooled.
- **Real device (RMX2156, Android 12, arm64, profile build, measured in Phase 6):** 14×14 board: build p50 ≈ 1–4 ms; raster p50 **12.5 ms while pinching**, **17.6 ms during a burst of taps** (arrows in flight); 24×24 board: pinching 15.3 ms, taps 20.7 ms. So pinch/zoom/idle stay inside 16.7 ms on a typical mid-range phone, but **a rapid tap burst runs at about 50–55 fps**, slightly short of the 60 fps goal. Next lever: one baked layer for all idle arrows and a cheaper flight (skip the head's blur). Command: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/performance_test.dart --profile --flavor dev -d <device>`.
- (Emulator reading from before:) **I cannot claim 60 fps from this.** The emulator rasterises in software, so it only shows relative improvement (about 2×). The first frame after opening a level takes 200–350 ms raster here (all images are baked at once). Someone has to run the command above on a real 2021 mid-range Android phone. If it misses 16.7 ms there, the next lever is one baked layer for all idle arrows.

### Design review self-review (docs/10 §11 step 3), Phase 4
| Screen | Issues I found in my own screenshots | Fixed |
|---|---|---|
| Board (all sizes) | The Flame canvas painted an opaque black rectangle over the chapter scene (Flame's default background) | Y (transparent) |
| Win sheet | "+48 coins / +50 XP" were an unreadable blob (ink text inside the ink sticker stroke) | Y (butter / sky fill) |
| Tablet landscape | The top bar floated in the middle of the board column | Y (ribbon takes the free space, counters on the right) |
| Dense board | Long chains drew long diagonal lines across the whole board | Y (sparser dots beyond 6 cells); still a visible detail, please judge |
| Win sheet | The "Nice flow!" toast sits on top of the ribbon while the sheet is up (scripted fast taps reach ×5) | open: cosmetic; toasts get their juice pass in Phase 5 |
| Dense board on iPhone SE | A 24×24 board has 12 dp cells at 1×; it is playable only through zoom and tap assist | by design (docs/03); please confirm the Ch5 sizes are what you want |
| Process | `dart fix` again moved a package into pubspec (`riverpod: any`) and added a `riverpod/src` import; both removed | Y |

### Phase 4 — for the human
1. **Review `docs/screenshots/phase4/`**: `board_*`, `dense_*` (1×), `dense_4x_*`, `win_*`, `fail_*` for iPhone SE, Pro Max and Android tablet landscape; `mechanic_*` (rotator, frozen, gate + key, linked, portal) on Pro Max.
2. **Approve the two states I added to docs/10 §7** (CLAUDE rule 5): the loading / load-error state of the Level screen, and the tablet-landscape layout (ASCII is in §7).
3. A real-device 60 fps check (see Performance) and an iOS build/run need you.
4. Decisions to confirm: hearts are shown as heart icons on a recessed capsule (the spec said "[♥♥♥]"), not a TBPill; the "+1 heart" ad button grants the heart at once (stub) until Phase 8; wallet and settings are in memory until Phase 6 (coins reset on restart); Next on level 60 goes to the Chapters stub; portal travel animates as "slide into portal A, fade, emerge from portal B" (simplified); no sound or haptics yet (Phase 5).

## Phase 5 — Juice & Arrow Symphony audio
**Built** (`lib/core/audio`, `lib/core/haptics`, `lib/features/game/feedback`):
- `AudioBackend` interface + `SoLoudBackend` (three buses music 0.55 / notes 0.90 / sfx 0.80, scheduled playback for delays, a low-pass biquad on the music bus, 64 voices so 10 taps a second do not drop sounds, music voice protected) and `AudioService` (preloads the chapter's notes + all effects, loops streamed chapter music, ducks −30% over 600 ms, applies the Music / Sound sliders, boss sting). If the engine cannot start, every call becomes a silent no-op, so audio can never break the game. `audio_session` sets iOS ambient + mix-with-others and Android game focus.
- `ChapterSound` (instrument + scale per chapter, equal to the asset catalog; a test checks the files exist), `melodies.dart` (**60 original 16-note melodies, 12 per chapter**, generated by `tool/gen_melodies.dart` from rules: statement, answer, the statement moved, a cadence on the tonic; chord tones on strong beats in the non-pentatonic scales), `MelodyPlayer` (next note per freed arrow; Flow harmony: fifth at ×2, third at ×4, sparkle at ×5; cascade of the remaining notes; flourish up to the next tonic; rewind on undo), `Sfx` (all 23 ids of docs/07 §2).
- `GameFeedback` maps every engine event to sound and haptics per docs/03 §4: touch-down click, note + whoosh (pitch ±5%) + light haptic per freed arrow, thunk + double medium haptic + glass crack on a blocked tap, ice tick / break, gear click, gate door + key jingle, portal warp, Flow-up arpeggio rising per tier, shaker tick at ×3, music bright for 1.5 s at ×5, last-three duck + shimmer + 3% zoom nudge, board clear (cascade 90 ms apart, 2-bar flourish, chime, success haptic, boss sting on level 60), stars dinging 180 ms apart, coin clinks pitched up, fail chord + heavy haptic, Retry restarts the tune.
- Visual juice added: touch-down press on an arrow (×1.06, 10% brighter, 60 ms), felt edge glows warmer with Flow, hearts crack (shake + pop) when one is lost, coin count-up on the win sheet, last-three zoom. Reduce Motion removes press / crack / zoom nudge / confetti (sound and haptics stay).
- `FeedbackBridge` routes the component library's press hook through haptics + the `ui_tap` click; back plays `ui_back`. `FeedbackSettings` holds Music / Sound / Haptics on-off and sliders (in memory until Phase 6).
- `tool/render_clear_preview.dart` renders what a level clear sounds like into `build/audio_preview/chN_l1.wav` (the real notes and timing on the placeholder tones), so it can be auditioned on a PC.

**Verified**: 1039 tests pass (new: melody data properties, melody player, audio service with a recording fake backend, every event → sound/haptic mapping, the full clear sequence, gestures → press + selection, leaving unloads, settings, haptics, juice widgets); analyzer and format clean. On the Android emulator: the real SoLoud engine starts, loads Ch1, takes 30 notes at 10 per second plus whooshes, ducks, brightens, plays the sting and shuts down without errors (`integration_test/audio_test.dart`); Ch1 L1–20 still plays through with sound; profile frame times did not get worse (taps raster p50 ≈ 9.5 ms on the emulator).

**Phase 5 acceptance (docs/prompts)**
| Item | Result |
|---|---|
| A clean clear sounds like a coherent melody | The notes are right by test (the melody in order, cascade, flourish home); **whether it sounds good needs a person**: listen to `build/audio_preview/ch*_l1.wav` and play a level |
| No glitches at 10 taps/s | engine runs the burst without errors on the emulator; **audible glitches can only be judged by ear on a device** |
| Reduce Motion removes shake / confetti / parallax | tested (parallax does not exist yet) |
| Still 60 fps | not proven on a real device (see Phase 4) |

### Phase 5 — for the human
1. **Listen.** The sample files in `assets/audio/` are still my placeholder sine/triangle tones, so the *timbre* is not final; check the melodies and rhythm (run `dart run tool/render_clear_preview.dart 3 7 14` for chapter 3, level 7, 14 arrows) and play a level with sound on.
2. Real instrument samples, music loops and SFX are human work (docs/07 §5); they drop in at the same paths (a `.ogg` swap is one constant in `lib/core/assets.dart`).
3. Decisions to confirm: the ×3 "shaker" layer is a quiet tick sample per note (no loop asset exists yet); long arrows (> 8 cells) play their note louder (one sample per note, no long variant yet); the coin **fly to the pill** and the board **folding into a fragment** are not built because Home and the scene thumbnails do not exist yet (Phase 6/7); the Music / Sound / Haptics switches work but have no screen until Settings (Phase 6).

## Phase 6 — Meta & progression (design gate: human review)
The layouts you approved (docs/10 §7) are built. The app now starts on the **Splash** (logo plate drops, chime, chapter audio loads) and opens **Home**.

**Built**
- **Save** (`lib/core/save`): `SaveData` (freezed + JSON: stars per level, current level per chapter, coins, XP, streak, Daily results, achievements, today's quests, settings, stats, flags, `schemaVersion`), `SaveMigrations` (v1 → v2), `SaveRepository` on `hive_ce` writing **two alternating slots with a write counter** (a kill in the middle of a write can only damage the slot being written; the previous good save is read), `SaveController` (Riverpod; writes 500 ms after the last change, and when the app goes to the background / is closed). Wallet, game settings, audio settings and Reduce Motion now live in the save and survive a restart.
- **Rules as pure functions** (`lib/core/meta`, 100% tested): `Progression` (a win: stars kept at their best, next level, stats, quests, achievements; first clear pays in full, a replay pays only the **extra stars** of a better result (no coin farming); chapters open in order, levels one by one; restoration per chapter; Daily Knot results and the 30-day calendar), `Streak` (local-date streak, weekly free freeze capped at 2, freeze consumption, edge cases of docs/09 §4), `PlayerLevel` (a level-up about every 8 levels early: 240 XP, +30 per step; 100 coins each), `Quests` (3 a day from a pool of 6, seeded by the date, never two of the same kind; claim once; chest), `Achievements` (30, coins 50–500), `DailyShare` (the exact share text), `MetaActions` (claim, chest, buy freeze for 200, pay 100 for a missed Daily).
- **Screens** (`lib/features`): Splash, **Home** (scene + 3-layer cloud parallax placeholder, player-level / coin / settings pills, chapter plaque, Daily plaque, streak flame that grows at 3/7/30/100 days, PLAY · Level n at 72% width, wooden shelf Shop / Collection / Quests), **Chapter Map** (pager of `TBChapterCard`s, 60 level pips with stars, locked chapters, one PLAY), **Daily Knot** (today's board preview, PLAY TODAY → Share once done, 30-day calendar, replay a missed day for 100 coins, streak and freezes, share card picture + text via `share_plus`), **Quests** sheet, **Achievements & Stats** (two tabs), **Settings** (Music / Sound / Haptics with sliders, Left-handed, Relaxed mode, Reduce motion system/on, colour-blind palette off / red-green / blue-yellow, account rows as "coming soon", credits), **Ch1 onboarding** (caption of at most 6 words + code-painted hand cursor looping tap / hold / pinch on the solution's first arrow, only on uncleared levels 1–10; gone after the first tap).
- The level screen records every win in the save (coins, XP, stars, stats, streak, quests, achievements) and the win sheet shows level-ups and unlocked achievements; Daily levels (`/daily/play/:date`, only today or the last 30 days) are recorded by UTC date. Colour-blind palettes (Okabe-Ito for red-green, another set for blue-yellow) recolour the arrows; gates and keys keep their symbols.

**Verified**: analyzer and format clean; the full suite passes (new: save, migrations, atomic-write recovery, Hive persistence across a reopen, controller debounce, streak edge cases, quests, achievements, progression, share text, and widget tests of every new screen driven by taps: Home, Quests sheet, Chapter Map, Daily incl. share / replay / freeze, Achievements & Stats, Settings, onboarding, a win saved to the save, a Daily win recorded).

**Acceptance (Phase 6 prompt)**
| Item | Result |
|---|---|
| Progress survives app kill | tested: save → new container loads it; Hive store reopened; a half-written slot falls back to the previous save |
| Streak edge cases (docs/09 §4) | tested: 23:59 → 00:01 = +1; skip with a freeze keeps and consumes it; skip without resets; two missed days need two freezes; weekly freeze; clock moved back |
| Daily Knot identical on Android and iOS | the level comes from the baked pack or the same generator (Phase 2 determinism hashes); the iOS side is **not run** (no Mac) |
| Design gate for every new screen | 31 screenshots in `docs/screenshots/phase6/` (iPhone SE, Pro Max, Android tablet landscape) |

### Design review self-review (docs/10 §11 step 3), Phase 6
| Screen | Issue found in my own screenshots | Fixed |
|---|---|---|
| Settings, Stats, Calendar | Cream text on the cream "recessed" wells was invisible (the recessed panel is a cream well, not a dark inset) | Y (ink text) |
| Chapter Map | Cards were wider than their pager pages and overlapped on a phone | Y (page width follows the card width) |
| Every screen | The Flutter DEBUG banner cut across the top-right corner | Y (off) |
| Home | The sketch's "♥ pill 5/5" does not exist in the game design (hearts are per level) | decided: player-level pill; **please confirm** |
| Home / Chapter Map | The scene is still the placeholder diorama (restoration shows only as colour), and the clouds are plain soft circles | known: art is human work (docs/06) |

### Phase 6 — for the human
1. **Review `docs/screenshots/phase6/`** (home, home_new, chapters, daily, daily_done, quests, achievements, stats, settings, onboarding at three sizes, plus the splash).
2. Confirm the decisions above: the player-level pill instead of the heart pill, no coin farming on replays, the quest pool and reward numbers, the player-level curve (240 XP + 30 per level), achievement coins, Streak Freeze price 200 and the free weekly freeze capped at 2.
3. Not built (waits for later phases): Shop and Collection (stubs), the account / privacy / restore rows (Phase 8–9), cloud sync (Phase 9), the "fragment flies to the scene" and coin fly-to-pill effects (need the real chapter scene art), Home music at −4 dB.

## Phase 7 — Mechanics content & Level Lab
**Built**
- **Tutorials, one per mechanic** (`MechanicTutorials`, `lib/core/level/generator/mechanic_tutorials.dart`): the level where each mechanic first appears is now a small board (7–8 cells, 6–12 arrows) with **only that mechanic**: rotator (Ch2 L1), gate + key (Ch3 L1), frozen (Ch4 L1), linked pair (Ch5 L1), portal (Ch5 L20). Before, Ch3 L1 had no gate at all, Ch4 L1 mixed ice and a rotator and Ch5 L20 mixed a link and a portal. Generated with a deterministic seed search, solver-verified, marked `tutorial-1.0` (exempt from the difficulty band like the onboarding levels). Packs ch2–ch5 were regenerated (`level_gen --seed 1001`); only those five levels changed.
- Each tutorial shows a caption of at most 6 words and the hand cursor on its first play ("Arrows turn after each tap.", "Free the key arrow first." (the hand points at the key), "Ice thaws as arrows leave.", "Chained arrows leave together.", "Portals carry arrows across."), only until the level is cleared.
- **Mechanic rendering** (docs/10 §8) was built in Phase 4 (brass gear ring, wooden gate with brass keyhole badge and colour symbol, brass key fob, crystal ice with counter sticker, ceramic portal ring with a code-drawn swirl, brass chain links); this phase adds a **Mechanics page to the Design Gallery** (5 boards on the real Flame renderer, each on cream / ink / chapter surfaces, plus both colour-blind palettes): `docs/screenshots/phase3/mechanics_*.png`.
- **Level Lab** (debug builds only; Material widgets allowed there, docs/10 B1 exception, so it is not scanned by the design-rules test): reachable from Settings → Developer. Browse a chapter's 60 levels (size, arrows, score vs target, mechanics, approved tick), view a level on the real board with the **solution order drawn on the arrow heads**, difficulty, depth, seed and generator version, **Play** it in the real game screen (through `levelOverridesProvider`; counts as a real play in the debug save), **Regenerate** it (next seed; plan-fixed levels regenerate to themselves), **Approve / Unapprove** (`meta.approved`), **Check** (the real `LevelChecker`), **Export pack** (pack JSON with the edits to the clipboard) and an **FPS overlay** switch.

**Acceptance (Phase 7 prompt)**
| Item | Result |
|---|---|
| All 300 levels pass `level_check` | `dart run tool/level_check.dart assets/levels/` → 8 files, 669 levels (300 chapter levels + 366 Daily + 3 samples), all passed |
| Each mechanic has tests + tutorial | `mechanic_tutorials_test` (single-mechanic, small, solvable, deterministic, shipped pack equals the generator output), engine tests per mechanic (Phase 1), widget tests for every tutorial hint, animation tests per mechanic (Phase 4) |
| Mechanics screenshots in the Design Gallery | yes (new Mechanics page) |
| Boss levels "hand-tuned" | **not done**: I cannot play-test; the 5 boss levels (L60) are generated and solver-verified like the rest. Use the Level Lab to look at them and regenerate or approve |

### Phase 7 — for the human
1. Open the Level Lab (Settings → Developer in a debug build) and look through the packs, especially the five tutorials and the boss levels (L60); **Approve** the ones you like. "Approved" is stored only in the exported JSON (copy it with Export pack and commit it).
2. The tutorials are generated, not hand-made; if one feels wrong, Regenerate and tell me.
3. Open points: ceramic portal "swirl shader + fallback": the swirl is code-drawn (animated arcs); a real fragment shader is art/engineering work for later.

## V2 "Clean Line" redesign (branch `redesign_game`) — in progress
Why: first outside feedback was "boring, 3D arrows and boards look bad, cells small, levels with few arrows". Direction and research: `docs/11_REDESIGN_V2.md`; mock-ups: `docs/screenshots/v2_clean/`.

Done so far (all tests green, analyzer clean):
- **Look**: flat tokens (white page, navy ink, teal accent), flat painters (button, card, slab, plaque, knob), thin-line arrows with a small head, no tray, faint dot grid, light/dark game board (follows system), flat icons, flat ribbons/progress, home with a drifting field of faint arrows.
- **Win screen**: full-screen teal sunburst + confetti + stars + the finished picture of the level (cells coloured by arrow, masked cells empty).
- **Juice**: arrows pop in at level start (staggered), idle "tap me" bounce after 6 s, accent press/hint highlight.
- **Endless track**: no chapter UI; level numbers are global; stages 1–5 are the shipped packs, 6+ are generated on the device from the same seeds (`PackBuilder`, 12 tries); sound palettes cycle every 60 levels.
- **Denser, shaped levels**: see `docs/04` §1.2. 21 silhouettes, boards 10–34 wide, minimum arrow counts, packs and Dailies regenerated (`generatorVersion 2.0.0`).
- **Chime Companion** (`lib/core/companion/`): pure planner (opt-in, 1/day, quiet hours, usual hour learned, stop after 3 ignored, comeback only at day 3 and 7), `flutter_local_notifications` behind `NotificationService`, pre-prompt after level 5, Settings (Normal/Fewer/Off), Chime Diary screen. Real-device delivery not yet verified.
- **Single configuration**: dev flavor removed (Android + iOS project, CI, docs); entrypoint `lib/main.dart`. iOS project edit is untested (no Mac).
- Dependencies: + `flutter_local_notifications`, `timezone`, `flutter_timezone`; − `connectivity_plus` (unused).

Still to do: sound pass (new exit/combo sounds), combo ripple + slow-mo last arrow, in-game zoom defaults for dense boards, Level picker, remove `ChapterTheme` scenes and the chapter art placeholders, real-device check, docs 02/03/06/07/10 rewrite to V2.

## Phase 8 — Shop, cosmetics, ads & IAP (design gate: human review)
Built:
- **Config**: `core/remote_config/{defaults,remote_config_service,app_config}.dart` (`LocalRemoteConfig` until Firebase in Phase 9); every economy/ad number reads `AppConfig`. `core/economy/pricing.dart` removed.
- **Ads** (`core/ads/`): `AdPolicy` (pure, unit-tested per docs/09 §5), `AdsService` + `FakeAdsService`, `AdMobAdsService` (google_mobile_ads + UMP, Google **test** unit IDs), `AdsController`, ATT `TrackingService`. Rules: no interstitial before level 12, only win→next, never retry/fail/first session/Daily/tutorial, 90 s hard gap, 150 s between interstitials, every 3rd win, <=6/h, 24 h holiday after a purchase, none after Remove Ads. Rewarded: +1 heart (<=2/level), x2 win coins (<=5/day), free hint when out of coins, unlock a missed Daily.
- **IAP** (`core/iap/`): `in_app_purchase` behind `IapService`; products remove_ads, starter_bundle, coins_pouch/chest/vault, art_pack; idempotent fulfilment (transaction ids + `product:<id>` markers); restore re-grants entitlements only (coin bonus once, consumables never); Starter Bundle 48 h window after level 15.
- **Cosmetics** (`core/cosmetics/`): 9 arrow skins, 5 trails, 5 boards, 5 instruments; prices common 500 / rare 1,500 / epic 4,000; chapter skins earned by restoring that chapter. Rendering: `ArrowSkin`, `glow.frag` (+ fallback), trail particle shapes, board themes, pitch-mapped instruments.
- **Screens**: Shop, Collection (4 tabs + live preview), Starter Bundle sheet, ATT pre-prompt; x2 coins on win sheet, "Ad not available" on fail sheet, hint/Daily ad sheets; Design Gallery Cosmetics page.

Acceptance vs docs/09 §5: ad-policy tests green (19); IAP fulfilment/restore/idempotency (28); cosmetics (12); screens/flows (`shop_ads_screens_test`). **Not verifiable here:** sandbox purchases on Android/iOS stores and any iOS build (no Mac, no store listing).

Decisions: `in_app_purchase` (not RevenueCat); no server-side receipt validation; Chapter Art Pack = paper skin + ribbons trail + marimba; hint-ad uses a sheet (not a toast action); Constellation board = stars within one chapter; instruments are pitch-shifted from the C-pentatonic samples; `glow.frag` is a placeholder shader.
Design self-review: found and fixed dark-on-cream coin amounts and truncated prices in the Shop coin tiles (now amount + caption price + short "Buy" button). Home behind the Starter sheet looks sparse only because it is the placeholder world art.
Known issues / before release: replace AdMob **test** app/unit IDs (AndroidManifest, Info.plist, `AdUnits`); real store products must be created with the ids above; iOS untested; Firebase wiring is Phase 9.
Docs-impact: docs/10 Phase 8 layouts approved and implemented.

## Re-verification of Phase 0 + 1 (2026-10-10)
| Check | Result |
|---|---|
| Flutter via FVM | 3.47.7 stable, Dart 3.13.5 |
| `flutter analyze` / `dart format --set-exit-if-changed .` | clean / clean |
| Tests (`fvm flutter test --coverage`) | 217 pass (engine, solvers, PRNG, validator, loader, pure-Dart guard, all 10 stub routes + level route) |
| Coverage | 100% lines in `engine/*`, `solver/*`, `prng`, `level_validator`, `pack_loader`; `models/level.dart` 193/194 (tool artefact: closing `),` of a `throw const`) |
| Platform folders | only `android/` and `ios/` |
| Android prod + dev release builds (x64) | both build; install side by side (`com.webazonic.arrowchime`, `.dev`); both launch with no crash, task label "Arrowchime" |
| Android debug on new emulator (Android 15, 4.7 GB free) | `fvm flutter run --flavor dev -t lib/main_dev.dart` installs and launches (DEBUG banner, splash stub with Fredoka), no FATAL in logcat |
| iOS | not buildable here (no macOS). `project.pbxproj` braces balanced, configs `Debug/Release/Profile-{dev,prod}` present, schemes `dev` + `prod` present. **Needs one Xcode open on a Mac.** |
| CI workflow | `ci.yml` parses as YAML; not yet run on GitHub |
| `dart run flutter_soloud:skills` | done: 14 skill files in `.agents/skills/` |

## Next
- **Phase 7 review** (Level Lab look-through, tutorials), then Phase 8 (Shop, cosmetics, ads, IAP; it asks you RevenueCat or in_app_purchase first).
- **Human review of Phase 6** (`docs/screenshots/phase6/`) and your word to commit it; then Phase 7 (mechanics content, all 300 levels checked, Level Lab).
- **Human listening test of Phase 5** (see "Phase 5 — for the human"), then Phase 6 (meta & progression: Save, Home, chapter map, Settings, Daily). The Phase 4 design review is still open.
- Human review of Phase 3 is still on record (screenshots in `docs/screenshots/phase3/`).
- Human review of Phase 2 is still open (nothing blocks Phase 3 work).
- Material/Cupertino migration deferred (human decision) to a later phase, before the November stable deprecation.
- Human review of Phase 0 + Phase 1, then Phase 2 (generator, difficulty, tools).

## Known issues
- **Phase 6:** Home, chapter scenes and the hand cursor are placeholders; Shop / Collection are stubs; account rows say "coming soon"; the first Daily of a day not in the baked pack is generated on the device (a few hundred ms); the iOS side of everything is unrun.
- **Phase 5:** nothing has been *listened* to by a human; the sound files are still placeholder sine tones; the coin fly-to-pill, the board-folds-into-a-fragment and parallax effects wait for Home / chapter scenes (Phase 6/7); Music, Sound and Haptics sliders exist as state but have no Settings screen yet (Phase 6).
- **Phase 4:** 60 fps is not proven on a real device (emulator only); iOS not built; wallet / settings are not persisted yet (Phase 6); the rewarded-ad button is a stub; no audio/haptics yet; the first frame of a level bakes all images (~0.2 s on the emulator).
- ~~flutter_soloud removed until Phase 5~~: **re-added in Phase 5.** The Windows 11 SDK is installed now, `flutter test` works with it, and the Android build and run work. The 14 agent skill files are in `.agents/skills/`.
- `android/gradle.properties` sets `kotlin.incremental=false` (Kotlin cache failed because project (D:) and pub cache (C:) are on different drives). Slower builds.
- **Material/Cupertino standalone packages (corrects an earlier note):** 3.47 publishes `material_ui` / `cupertino_ui` 1.x as an opt-in; the in-SDK `material.dart` still works and is formally deprecated in the November stable. Migration = `dart fix --apply --code=migrate_design_widgets`. Not applied yet: the app uses `WidgetsApp.router` + `GlobalMaterialLocalizations` only. Decision pending (see questions to the human).
- iOS flavor setup is hand-edited in `project.pbxproj`; open once in Xcode to confirm.
- Chapter palette hex values are my interpretation of the colour names in docs/06 §4 (docs give names, not hex).
- Release build prints a harmless "Expected to find fonts for MaterialIcons/CupertinoIcons" warning.
- Lint `unnecessary_type_name_in_constructor` (very_good_analysis 11) was auto-fixed to the `const new(...)` constructor shorthand.

## New dependencies (justification)
Phase 6: none new (`hive_ce` / `hive_ce_flutter` for the save, `share_plus` for the Daily share, both from docs/05 §1).
Phase 5: `flutter_soloud` (docs/05 §5, re-added), `audio_session` (iOS ambient + mix-with-others and Android game audio focus, which docs/05 §5 requires and SoLoud does not expose), `fake_async` (dev: drives the cascade / double-haptic timers in tests).
Phase 4: none. (`integration_test` was already there; `test_driver/integration_test.dart` is the standard 3-line driver for `flutter drive --profile`.)
Phase 2: `integration_test` (SDK, dev only): runs the golden determinism hashes on a real device (`flutter test integration_test --flavor dev`). No other new packages; `dart:io` is used only by `tool/` and tests.
See "Packages added" above; all from docs/05 §1. `very_good_analysis` for lints; `flame_test` for Flame tests; `intl` + `flutter_localizations` for ARB l10n.

- Phase 8: google_mobile_ads (AdMob + UMP consent), in_app_purchase (store purchases, decision: not RevenueCat), app_tracking_transparency (iOS ATT).

## Design review gate
**Phase 4 is built and tested but not committed; the human reviews `docs/screenshots/phase4/` (20 images, incl. tablet) before Phase 5 starts.** Self-review and the open questions are in the Phase 4 section above. Phase 3's gate material is in `docs/screenshots/phase3/`.
