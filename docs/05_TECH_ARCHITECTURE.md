# 05 — Technical Architecture

## 1. Stack (verified Oct 2026)

| Area | Choice | Notes |
|---|---|---|
| SDK | **Flutter 3.47.x stable / Dart 3.13** | Material & Cupertino are now standalone packages in 3.47 — follow the official migration notes when creating the project. Do not use beta/master. |
| Game rendering | **Flame 1.38.x** (`flame`) | Stay on 1.x; 2.0 is pre-release. Use `flame_rive` / `flame_lottie` only if needed. |
| Audio | **flutter_soloud 5.1.x** | Low latency, mixing buses, scheduled playback. Run `dart run flutter_soloud:skills` to install its agent skill files for Claude Code. |
| State management | **Riverpod 3** (`flutter_riverpod` + `riverpod_generator`) | Game core is pure Dart, so swapping to GetX/Bloc later only touches the app layer. |
| Routing | `go_router` | Deep links from notifications (`/daily`, `/level/ch1/7`). |
| Models | `freezed` + `json_serializable` | Immutable models, generated JSON. |
| Local storage | `hive_ce` (+ `hive_ce_flutter`) | Fast local object storage on Android & iOS. |
| Backend | Firebase: Core, Auth (anonymous + Google + Apple), Firestore (cloud save, daily leaderboard v1.1), Remote Config, Analytics, Crashlytics, Storage (daily/event packs) | One Firebase project: `arrowchime-prod` (no flavors). |
| Ads | `google_mobile_ads` + Google UMP consent | Behind `AdsService`; a fake implementation is used in tests and dev. |
| IAP | RevenueCat (`purchases_flutter`) **or** `in_app_purchase` | RevenueCat recommended (receipt validation, entitlements, paywall analytics). Decide before Phase 8. |
| UI | Custom `TB*` component library (`lib/core/ui/`) per `10_DESIGN_SYSTEM.md`; `flutter_animate`; Rive for animated mascot/3D-feel buttons (optional) | No default Material look in player UI. |
| UI testing | Golden tests (`flutter test`) + `integration_test` screenshots (iPhone SE, Pro Max, tablet) | Required by the design review gate. |
| Share | `share_plus` + `RepaintBoundary` → PNG for Daily Knot card | |
| Haptics | Flutter `HapticFeedback` (built-in) | Silently no-op where unsupported. |
| i18n | `flutter_localizations` + gen-l10n (ARB files) | English at MVP; strings never hard-coded. |
| Misc | `package_info_plus`, `url_launcher`, `in_app_review`, `connectivity_plus` | |
| Lints | `very_good_analysis` or `flame_lint` | Zero warnings policy. |

> Rule for Claude Code: add packages with `flutter pub add <name>` so the newest compatible versions resolve; do not invent version numbers.

## 2. Layered architecture

```
┌──────────────────────────────────────────────────────────────┐
│ features/*  (Flutter widgets, screens, Riverpod controllers) │
│   game/  ── GameWidget(ArrowGame)  +  Flutter HUD overlay    │
├──────────────────────────────────────────────────────────────┤
│ core/services  audio · haptics · ads · iap · analytics ·     │
│                remote_config · persistence · cloud_sync      │
├──────────────────────────────────────────────────────────────┤
│ core/level  (PURE DART — no Flutter imports)                 │
│   models · engine · rules · generator · solver · prng ·      │
│   difficulty · pack_loader                                   │
└──────────────────────────────────────────────────────────────┘
```

- `core/level` must compile with plain `dart` (used by `tool/` CLI). Enforce with a test that imports it from a pure Dart test file and with a lint rule or CI grep for `package:flutter` inside `lib/core/level/`.
- Services are interfaces with real and fake implementations, injected with Riverpod providers so tests can override them.

## 3. Folder structure

```
arrowchime/
├── CLAUDE.md
├── docs/                         # this pack
├── lib/
│   ├── main.dart
│   ├── bootstrap.dart            # init Firebase, Hive, audio, error handlers
│   ├── app/
│   │   ├── app.dart              # MaterialApp.router, theme, l10n
│   │   ├── router.dart
│   │   └── theme/                # tokens.dart (all design tokens), chapter_theme.dart, typography.dart
│   ├── core/
│   │   ├── ui/                   # design system: components/ (TB*), painters/ (ceramic, enamel, wood, brass, crystal), icons/ (placeholder 3D icon painters)
│   │   ├── level/                # PURE DART
│   │   │   ├── models/ (cell.dart, direction.dart, arrow.dart, level.dart, board_state.dart)
│   │   │   ├── engine/ (game_engine.dart, rules.dart, events.dart, undo.dart)
│   │   │   ├── generator/ (generator.dart, gen_params.dart, mechanics_pass.dart)
│   │   │   ├── solver/ (greedy_solver.dart, search_solver.dart, hint.dart)
│   │   │   ├── difficulty.dart
│   │   │   ├── prng.dart         # Mulberry32 + FNV-1a
│   │   │   └── pack_loader.dart
│   │   ├── audio/ (audio_service.dart, melody_player.dart, melodies.dart, sfx.dart)
│   │   ├── haptics/haptics_service.dart
│   │   ├── persistence/ (save_data.dart, save_repository.dart, migrations.dart)
│   │   ├── cloud/ (auth_service.dart, cloud_sync_service.dart)
│   │   ├── ads/ (ads_service.dart, ads_service_admob.dart, ads_service_fake.dart, ad_policy.dart)
│   │   ├── iap/ (iap_service.dart, products.dart)
│   │   ├── analytics/ (analytics_service.dart, events.dart)
│   │   ├── remote_config/remote_config_service.dart
│   │   └── economy/ (wallet.dart, rewards.dart, pricing.dart)
│   ├── features/
│   │   ├── splash/  home/  chapter_map/  daily/  shop/  collection/
│   │   ├── achievements/  quests/  profile/  settings/
│   │   ├── game/
│   │   │   ├── flame/ (arrow_game.dart, board_component.dart, arrow_component.dart,
│   │   │   │          arrow_painter.dart, gate_component.dart, portal_component.dart,
│   │   │   │          effects/ (exit_effect.dart, bump_effect.dart), particles/,
│   │   │   │          camera/ (zoom_pan_controller.dart), input/tap_resolver.dart)
│   │   │   ├── hud/ (top_bar.dart, bottom_bar.dart, flow_meter.dart, hearts.dart)
│   │   │   ├── dialogs/ (win_sheet.dart, fail_sheet.dart, pause_sheet.dart)
│   │   │   └── game_session_controller.dart
│   │   ├── design_gallery/       # debug-only: every TB component & screen state
│   │   └── level_lab/            # debug-only tools
│   └── l10n/ app_en.arb
├── tool/ (level_gen.dart, level_check.dart, gen_placeholder_assets.dart)
├── assets/ (images/, audio/, levels/, fonts/, rive/, shaders/)
├── test/   (mirrors lib/)
└── integration_test/
```

## 4. Game runtime design

### 4.1 Flow of a tap
```
pointer down (Flame TapCallbacks on ArrowGame)
  → TapResolver: screen → world → cell; nearest-arrow assist
  → GameSessionController.tap(arrowId)          (Riverpod Notifier)
      → engine.tap(arrowId) returns List<GameEvent>
         e.g. ArrowFreed(id, path), BlockedTap(id, blockerId, distance), HeartLost,
              RotatorsTurned(ids), GateOpened(color), FrozenTick(ids), LevelWon, LevelLost
  → controller updates immutable SessionState (hearts, flow, remaining, stars)
  → events stream → ArrowGame plays animations; AudioService plays notes; Haptics fire
```
The engine never waits for animations. Animations are fire-and-forget visual replays of events.

### 4.2 Rendering arrows (high quality, cheap)
- Each arrow = smooth path through cell centres with **rounded corners** (corner radius 0.45 cell), stroke width 0.42 cell, round caps, arrowhead triangle at head.
- Look: the 5-pass **glossy enamel tube** recipe in `10_DESIGN_SYSTEM.md` §8 (shadow, dark rim, body, light band, specular) + rounded head and nock tail. Shadow pre-baked once per zoom bucket. Keep `saveLayer` out of per-frame paths.
- Static arrows: cache as `Picture` (re-record only when skin/zoom bucket changes).
- Exit animation: animate a "progress" value; draw the body as the sub-path from `progress` to the end of the extended path (body + ray + off-screen margin) using `PathMetric.extractPath`.
- Optional **fragment shader** (`assets/shaders/glow.frag`) for skins like Neon/Galaxy; must have a non-shader fallback and be disabled under low-power or reduce-motion.
- Particles: pooled `ParticleSystemComponent`s; ≤ 120 live particles.

### 4.3 Camera
`CameraComponent` with `viewfinder.zoom` 1×–4× (fit = 1×). Pinch via `ScaleDetector`, pan clamped to board bounds + 20% margin, double-tap = animated fit.

### 4.4 HUD
Flutter widgets in a `Stack` above `GameWidget`, reading `sessionProvider`. Keeps text crisp, accessible and localizable.

## 5. Audio architecture
- `AudioService` wraps `SoLoud.instance`. Three buses: **music**, **sfx**, **notes**; user sliders map to bus volumes.
- Notes: each instrument has pre-rendered samples for 2 octaves of its chapter scale (≈ 10–15 short OGG files). `MelodyPlayer` holds the current level's melody (list of scale degrees) and an index; each freed arrow plays `melody[i++ % len]`. Flow tiers add a harmony note (3rd/5th) on the notes bus at lower volume.
- Board clear: schedule the remaining melody notes 90 ms apart using scheduled playback, then the flourish.
- Music: one loop per chapter (OGG, gapless loop). Duck music −30% for last-3-arrows and during flourish.
- iOS: configure the audio session so game audio mixes politely with the player's music (ambient category) and respects the silent switch for music only — notes/SFX still follow the in-game volume settings.
- Preload all SFX + current chapter samples at chapter entry; dispose on exit.

## 6. Persistence & sync
- `SaveData` (freezed): schemaVersion, progress (stars per level id), currentLevel per chapter, wallet (coins), inventory (owned cosmetic ids), equipped, streak (count, lastPlayedDate, freezes), daily results map, achievements, quests, settings, stats, flags (adsRemoved), updatedAt.
- Stored in Hive box `save`, written debounced (500 ms) and on app pause.
- Cloud (signed in): Firestore `users/{uid}` doc. Merge on conflict: stars = max per level; inventory = union; achievements = union; coins & streak = from the doc with newer `updatedAt`; adsRemoved = OR. Never trust client for purchases — entitlements come from IAP provider.
- Migrations keyed by `schemaVersion` with unit tests.

## 7. Platform notes (Android & iOS only)

| Concern | Android | iOS |
|---|---|---|
| Ads | google_mobile_ads + UMP | google_mobile_ads + UMP + ATT pre-prompt |
| IAP | Play Billing via RevenueCat / in_app_purchase | StoreKit via RevenueCat / in_app_purchase |
| Haptics | `HapticFeedback` (check device support) | `HapticFeedback` (Taptic Engine) |
| High refresh | 90/120 Hz devices supported | ProMotion: set `CADisableMinimumFrameDurationOnPhone` = true |
| Build | AAB (`flutter build appbundle`) | IPA (`flutter build ipa`) |
| Min OS | Android 7.0 (API 24) or as required by dependencies | iOS 15 or as required by dependencies |

Web is **out of scope** for this version. Don't add web code paths; keep services behind interfaces so a web target can be added later.

## 8. Performance budget
- 60 fps with 300 arrows on 24×24 on a 2021 mid-range Android; frame build+raster < 12 ms.
- No allocations in `render()` hot paths (reuse `Paint`, `Path`).
- Memory < 250 MB on mobile.
- Track with DevTools; add a debug FPS overlay in Level Lab.

## 9. Analytics events (minimum)
`tutorial_step`, `level_start`, `level_win` (stars, hearts, duration, taps, blocked_taps, hints, undos, flow_max), `level_fail`, `hint_used`, `undo_used`, `peek_used`, `zoom_used`, `daily_start/win/share`, `ad_offer/ad_show/ad_reward`, `iap_view/iap_purchase`, `cosmetic_equip`, `chapter_complete`, `streak_update`.
Level ids and difficulty score attached to level events → lets you re-tune difficulty bands from data.

## 10. Remote Config keys
`hearts_per_level`, `interstitial_min_level`, `interstitial_min_seconds_between`, `interstitial_every_n_levels`, `max_interstitials_per_hour`, `rewarded_heart_cap`, `hint_price`, `undo_price`, `heart_price`, `peek_shows_verdict`, `daily_reward_coins`, `remove_ads_sku`, `starter_bundle_enabled`, `event_tangle_tower_enabled`.

## 11. CI / delivery
- GitHub Actions on every PR: `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test` (incl. golden tests), `dart run tool/level_check.dart assets/levels/`, `flutter build appbundle`; macOS runner for `flutter build ios --no-codesign` nightly.
- Release: Codemagic or Fastlane for Play Store and App Store (TestFlight + internal testing tracks).
- No flavors (V2): a single `prod` configuration, entrypoint `lib/main.dart`, bundle id `com.webazonic.arrowchime`, Firebase config via `flutterfire configure`.
