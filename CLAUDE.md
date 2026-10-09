# CLAUDE.md — Arrowchime

You are building **Arrowchime** (store title: *Arrowchime: Arrow Escape Puzzle*), a premium arrow-escape puzzle game for **Android and iOS only** in Flutter + Flame. There is **no web target** in this version — do not add web code, web builds or web-specific packages. Read this file fully at the start of every session.

## Source of truth (read before coding a feature)
| Topic | File |
|---|---|
| What & why, scope, USPs | `docs/02_PRD.md` |
| Rules, mechanics, UX, juice, meta | `docs/03_GAME_DESIGN.md` ← **rules authority** |
| Level JSON, generator, solver, difficulty | `docs/04_LEVEL_SYSTEM.md` (+ `docs/reference/generator_reference.py`) |
| Stack, folders, runtime design | `docs/05_TECH_ARCHITECTURE.md` |
| Brand, name, world art, asset pipeline | `docs/06_ART_DIRECTION.md` |
| Audio "Arrow Symphony" | `docs/07_AUDIO_DESIGN.md` |
| Economy, ads, IAP, remote config | `docs/08_ECONOMY_MONETIZATION.md` |
| Tests & Definition of Done | `docs/09_QA_ACCEPTANCE.md` |
| **UI design system — STRICT** | `docs/10_DESIGN_SYSTEM.md` ← **visual authority** |
| Every asset path | `assets/ASSET_MANIFEST.md` |
| Build order | `prompts/BUILD_PROMPTS.md` |

If a request conflicts with these docs, ask before deviating. If the design changes, update the doc in the same change.

## 🎨 Design rules (non-negotiable)
The game must look **hand-crafted by a senior game-UI designer: modern, tactile, soft-3D ("Toybox 3D")** — never like a generic AI-generated Flutter app.
1. Read `docs/10_DESIGN_SYSTEM.md` before writing any widget. Everything in its §1 "BANNED" list (B1–B16) is an automatic fail: no unstyled Material widgets in player UI, no purple-pink AI gradients, no glassmorphism soup, no emoji/Material icons, no Roboto/Inter, no centred-column templates, no random shadows/radii.
2. Build the **component library first** (`lib/core/ui/components/`, `TB*` widgets) with golden tests, then compose screens only from those components.
3. Use **tokens only** (`lib/app/theme/tokens.dart`): colours, spacing, radii, the 3 elevations, motion durations/curves. A literal `Color(0x…)`, `EdgeInsets` number or `Duration` inside a feature widget is a bug.
4. **One light source, top-left.** Every interactive object has face + bevel/lip + highlight + shadow + a pressed state.
5. **Never improvise a screen.** If a screen/state isn't specified in `docs/10` §7, write its ASCII layout into that section and ask for approval first.
6. **Do not create or fetch images to use as art.** Shipped art is human-made (see `docs/06` §8). You build obvious placeholders at the manifest paths.
7. After every UI phase run the **Design review gate** (`docs/10` §11): Design Gallery, screenshots at iPhone SE + Pro Max (+ tablet for game screens), self-review table in `docs/PROGRESS.md`, then **stop for human review**.

## Engineering golden rules
1. **Work one phase at a time** (`prompts/BUILD_PROMPTS.md`). Finish its acceptance checklist before the next. Keep `docs/PROGRESS.md` updated (phase, done, next, known issues).
2. **`lib/core/level/` is pure Dart.** No `package:flutter` imports there — it is shared with the `tool/` CLI. The engine is synchronous, deterministic and fully unit-tested.
3. **Engine first, pixels second.** State changes happen in the engine; Flame components only animate emitted events.
4. **Determinism:** level generation uses our `Mulberry32` PRNG (32-bit masked math), never `dart:math` `Random`. Same seed ⇒ identical JSON on Android, iOS and the Dart VM.
5. **Every shipped level is solver-verified** (`dart run tool/level_check.dart assets/levels/`).
6. **Juice is a requirement**: the feedback table in GDD §4 (animation + sound + haptic per event), respecting Reduce Motion.
7. **No hard-coded strings or tunables.** Strings → ARB; economy/ads → Remote Config defaults in `core/remote_config/defaults.dart`.
8. **Fair ads policy is non-negotiable** (`docs/08` §2), enforced in `ad_policy.dart` with unit tests.
9. **Placeholders first** at the exact paths in `assets/ASSET_MANIFEST.md`, so final assets drop in with zero code changes.
10. **Add packages with `flutter pub add`** — never invent version numbers; justify each new dependency in `docs/PROGRESS.md`.
11. **Services behind interfaces** (ads, IAP, analytics, audio) injected via Riverpod so tests can fake them.
12. Ask before: changing the level JSON schema, adding a backend service or paid SDK, altering monetization rules, or adding a platform.

## Stack (Oct 2026)
Flutter 3.47.x stable (Dart 3.13) — Material & Cupertino are standalone packages from 3.47; follow the official migration guide when scaffolding. Platforms: **android, ios**. Flame 1.38.x (not 2.0-dev). flutter_soloud 5.1.x (run `dart run flutter_soloud:skills` once so its agent skill files are available). Riverpod 3 + riverpod_generator, go_router, freezed/json_serializable, hive_ce, Firebase (core/auth/firestore/remote_config/analytics/crashlytics/storage), google_mobile_ads + UMP, RevenueCat or in_app_purchase (decide in Phase 8), flutter_animate, share_plus.

## Commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed / riverpod / json
flutter analyze && dart format --set-exit-if-changed .
flutter test                                               # unit + widget + golden tests
flutter test --update-goldens test/core/ui                 # only when a design change is approved
dart run tool/level_gen.dart --chapter 1 --count 60 --seed 1001 --out assets/levels/ch1.json
dart run tool/level_check.dart assets/levels/
dart run tool/gen_placeholder_assets.dart
flutter run --flavor dev -t lib/main_dev.dart              # Android emulator / iOS simulator
flutter test integration_test --flavor dev                 # screenshots for the design gate
flutter build appbundle --flavor prod -t lib/main_prod.dart
flutter build ipa --flavor prod -t lib/main_prod.dart
```

## Code conventions
- Feature-first folders as in `docs/05` §3. One public widget/class per file; files `snake_case.dart`.
- Immutable models with `freezed`. Riverpod `@riverpod` codegen providers; no global singletons except the SoLoud engine wrapped in `AudioService`.
- Lints: `very_good_analysis` (or `flame_lint`); zero warnings.
- Tests mirror `lib/` under `test/`. Engine & generator: table-driven tests with fixtures from `assets/levels/sample_levels.json`. UI components: golden tests per state.
- Performance: no allocations in `render()`; reuse `Paint`/`Path`; cache static arrow `Picture`s; ≤ 120 live particles; 60 fps on a 2021 mid-range Android.
- Accessibility: semantics labels on every tappable widget; tap targets ≥ 44 logical px; colour never the only signal.
- Commit messages: `feat(game): …`, `fix(level): …`, `style(ui): …`, `test(engine): …`, `docs: …`.

## Definition of Done
`docs/09_QA_ACCEPTANCE.md` §1: analyzer clean, tests (incl. goldens) green, runs on Android + iOS, strings in ARB, Reduce Motion + colour-blind checked, design gate passed for UI work, `docs/PROGRESS.md` updated.
