# PROGRESS — Arrowchime

## Current phase
Phase 1 — Core level engine: implemented and re-verified, awaiting review. Phase 0 is committed (`8c98c0b`); Phase 1 is not committed yet.

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

## Re-verification of Phase 0 + 1 (2026-10-10)
| Check | Result |
|---|---|
| Flutter via FVM | 3.47.7 stable, Dart 3.13.5 |
| `flutter analyze` / `dart format --set-exit-if-changed .` | clean / clean |
| Tests (`fvm flutter test --coverage`) | 217 pass (engine, solvers, PRNG, validator, loader, pure-Dart guard, all 10 stub routes + level route) |
| Coverage | 100% lines in `engine/*`, `solver/*`, `prng`, `level_validator`, `pack_loader`; `models/level.dart` 193/194 (tool artefact: closing `),` of a `throw const`) |
| Platform folders | only `android/` and `ios/` |
| Android prod + dev release builds (x64) | both build; install side by side (`com.webazonic.arrowchime`, `.dev`); both launch with no crash, task label "Arrowchime" |
| iOS | not buildable here (no macOS). `project.pbxproj` braces balanced, configs `Debug/Release/Profile-{dev,prod}` present, schemes `dev` + `prod` present. **Needs one Xcode open on a Mac.** |
| CI workflow | `ci.yml` parses as YAML; not yet run on GitHub |
| `dart run flutter_soloud:skills` | done: 14 skill files in `.agents/skills/` |

## Next
- Material/Cupertino migration deferred (human decision) to a later phase, before the November stable deprecation.
- Human review of Phase 0 + Phase 1, then Phase 2 (generator, difficulty, tools).

## Known issues
- **flutter_soloud removed from pubspec until Phase 5 (audio)** (human decision): its native build fails on this Windows PC (Windows SDK missing from Visual Studio, `stddef.h`), which broke local `flutter test`. Re-add with `flutter pub add flutter_soloud` in Phase 5 (after installing the "Windows 11 SDK" component, or tests must be run on CI/Linux). The 14 agent skill files from `dart run flutter_soloud:skills` are kept in `.agents/skills/`.
- Emulator `emulator-5554` has ~450 MB free: the 175 MB debug APK cannot install; verified with a release x64 build instead. Free emulator space for `flutter run`.
- `android/gradle.properties` sets `kotlin.incremental=false` (Kotlin cache failed because project (D:) and pub cache (C:) are on different drives). Slower builds.
- **Material/Cupertino standalone packages (corrects an earlier note):** 3.47 publishes `material_ui` / `cupertino_ui` 1.x as an opt-in; the in-SDK `material.dart` still works and is formally deprecated in the November stable. Migration = `dart fix --apply --code=migrate_design_widgets`. Not applied yet: the app uses `WidgetsApp.router` + `GlobalMaterialLocalizations` only. Decision pending (see questions to the human).
- iOS flavor setup is hand-edited in `project.pbxproj`; open once in Xcode to confirm.
- Chapter palette hex values are my interpretation of the colour names in docs/06 §4 (docs give names, not hex).
- Release build prints a harmless "Expected to find fonts for MaterialIcons/CupertinoIcons" warning.
- Lint `unnecessary_type_name_in_constructor` (very_good_analysis 11) was auto-fixed to the `const new(...)` constructor shorthand.

## New dependencies (justification)
See "Packages added" above; all from docs/05 §1. `very_good_analysis` for lints; `flame_test` for Flame tests; `intl` + `flutter_localizations` for ARB l10n.

## Design review gate
No UI phase completed; nothing awaiting review (stub screens only).

| Screen | Issues found | Fixed (Y/N) |
|---|---|---|
