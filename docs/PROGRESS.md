# PROGRESS — Arrowchime

## Current phase
**Phase 3 — Design system & component library: built, polished for responsiveness, committed. Design review gate (docs/10 §11): the human reviews `docs/screenshots/phase3/` (their go-ahead for Phase 4).** Phases 0–3 are committed.

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
- `lib/core/ui/icons/`: 24 code-painted 3-tone placeholder icons (`TBIcon`), names equal the asset manifest (a test checks it).
- `lib/features/design_gallery/` (debug route `/design-gallery`): 8 pages (Foundations, Buttons, Panels, HUD, Controls, Chapters, Icons, Materials); every component with all its states on cream, ink and one chapter background.
- Press physics: face down 4 dp, lip 6 -> 2 dp, shadow e2 -> e1, haptic, mTap/mRelease with overshoot; Reduce Motion = 160 ms fade, no overshoot. Verified from rasterised pixels.
- Tokens added (and documented in docs/10 §3.6 and §3.8): `TBMaterials`, `TBBevel`, component sizes, motion extras.

### Phase 3 acceptance
| Criterion | Result |
|---|---|
| Golden tests for every component state at 1x and 3x (D6) | 172 goldens in `test/core/ui/goldens/` (86 cases x 2), all 24 icons included |
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
- **Human design review of Phase 3** (`docs/screenshots/phase3/`), then Phase 4 (Playable game screen, also a design-gate phase).
- Human review of Phase 2 is still open (nothing blocks Phase 3 work).
- Material/Cupertino migration deferred (human decision) to a later phase, before the November stable deprecation.
- Human review of Phase 0 + Phase 1, then Phase 2 (generator, difficulty, tools).

## Known issues
- **flutter_soloud removed from pubspec until Phase 5 (audio)** (human decision): its native build fails on this Windows PC (Windows SDK missing from Visual Studio, `stddef.h`), which broke local `flutter test`. Re-add with `flutter pub add flutter_soloud` in Phase 5 (after installing the "Windows 11 SDK" component, or tests must be run on CI/Linux). The 14 agent skill files from `dart run flutter_soloud:skills` are kept in `.agents/skills/`.
- `android/gradle.properties` sets `kotlin.incremental=false` (Kotlin cache failed because project (D:) and pub cache (C:) are on different drives). Slower builds.
- **Material/Cupertino standalone packages (corrects an earlier note):** 3.47 publishes `material_ui` / `cupertino_ui` 1.x as an opt-in; the in-SDK `material.dart` still works and is formally deprecated in the November stable. Migration = `dart fix --apply --code=migrate_design_widgets`. Not applied yet: the app uses `WidgetsApp.router` + `GlobalMaterialLocalizations` only. Decision pending (see questions to the human).
- iOS flavor setup is hand-edited in `project.pbxproj`; open once in Xcode to confirm.
- Chapter palette hex values are my interpretation of the colour names in docs/06 §4 (docs give names, not hex).
- Release build prints a harmless "Expected to find fonts for MaterialIcons/CupertinoIcons" warning.
- Lint `unnecessary_type_name_in_constructor` (very_good_analysis 11) was auto-fixed to the `const new(...)` constructor shorthand.

## New dependencies (justification)
Phase 2: `integration_test` (SDK, dev only): runs the golden determinism hashes on a real device (`flutter test integration_test --flavor dev`). No other new packages; `dart:io` is used only by `tool/` and tests.
See "Packages added" above; all from docs/05 §1. `very_good_analysis` for lints; `flame_test` for Flame tests; `intl` + `flutter_localizations` for ARB l10n.

## Design review gate
**Phase 3 is committed; the human reviews `docs/screenshots/phase3/` (19 images, incl. tablet) before Phase 4 starts.** Self-review and the responsiveness pass are in the Phase 3 section above.
