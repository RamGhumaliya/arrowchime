# PROGRESS — Arrowchime

## Current phase
Phase 0 — Scaffold: implemented, awaiting review. Not committed.

## Done
- Flutter pinned with FVM to **3.47.7 stable** (Dart 3.13.5) via `.fvmrc`; the machine's global Flutter is a 3.49 `main` build and is left untouched. Run commands as `fvm flutter ...`.
- Android + iOS only (no web/desktop folders).
- Android: namespace/applicationId `com.webazonic.arrowchime` (+ `.dev` suffix for dev), flavors `dev`/`prod`, display names "Arrowchime Dev"/"Arrowchime".
- iOS: build configs `Debug|Release|Profile-{dev,prod}`, schemes `dev`/`prod`, bundle ids `com.webazonic.arrowchime[.dev]`, iPhone portrait only, iPad all orientations. **Not built — needs a Mac.**
- Orientation policy at runtime: portrait on phones, all on tablets (shortest side >= 600).
- Entrypoints `lib/main_dev.dart`, `lib/main_prod.dart` -> `bootstrap.dart`. (`lib/main.dart` removed; always pass `-t`.)
- Packages added (docs/05 §1, no Firebase/ads/IAP): flame, flutter_soloud, flutter_riverpod, riverpod_annotation/generator, go_router, freezed(+annotation), json_serializable/annotation, hive_ce(+flutter), flutter_animate, share_plus, package_info_plus, url_launcher, in_app_review, connectivity_plus, intl, flutter_localizations, build_runner, flame_test, very_good_analysis (replaces flutter_lints).
- Folder structure from docs/05 §3 (empty dirs hold `.gitkeep`).
- `lib/app/theme/tokens.dart` (all docs/10 §3 tokens + light/size constants), `chapter_theme.dart` (5 chapters), `typography.dart` (6 styles; sticker painting stubbed for Phase 3).
- Fredoka + Nunito (OFL variable fonts) bundled in `assets/fonts/` with licences.
- go_router stub routes for every screen; `/design-gallery` and `/level-lab` only in debug.
- l10n via ARB (`lib/l10n/app_en.arb`, generated to `lib/l10n/gen`).
- `.github/workflows/ci.yml` per docs/05 §11.
- Verified: `flutter analyze` clean, `dart format` clean, 6 tests pass, dev APK runs on Android emulator (splash stub, Fredoka renders).

## Next
- Human review of Phase 0, then Phase 1 (engine).

## Known issues
- **`flutter test` fails on this Windows machine**: flutter_soloud builds native code on the host and the Windows 10/11 SDK is missing from the Visual Studio install (`stddef.h` not found). Fix: add the "Windows 11 SDK" component in the VS Installer. Tests passed when flutter_soloud was temporarily removed. CI (Linux) is unaffected.
- Emulator `emulator-5554` has ~450 MB free: the 175 MB debug APK cannot install; verified with a release x64 build instead. Free emulator space for `flutter run`.
- `android/gradle.properties` sets `kotlin.incremental=false` (Kotlin cache failed because project (D:) and pub cache (C:) are on different drives). Slower builds.
- Material/Cupertino "standalone package" migration: not needed on 3.47.7 (SDK still ships `material.dart`); I could not read the online guide, so this is based on inspecting the SDK. App uses `WidgetsApp.router`, `uses-material-design: false`.
- iOS flavor setup is hand-edited in `project.pbxproj`; open once in Xcode to confirm.
- Chapter palette hex values are my interpretation of the colour names in docs/06 §4 (docs give names, not hex).
- Release build prints a harmless "Expected to find fonts for MaterialIcons/CupertinoIcons" warning.
- `dart run flutter_soloud:skills` not yet run.
- Lint `unnecessary_type_name_in_constructor` (very_good_analysis 11) was auto-fixed to the `const new(...)` constructor shorthand.

## New dependencies (justification)
See "Packages added" above; all from docs/05 §1. `very_good_analysis` for lints; `flame_test` for Flame tests; `intl` + `flutter_localizations` for ARB l10n.

## Design review gate
No UI phase completed; nothing awaiting review (stub screens only).

| Screen | Issues found | Fixed (Y/N) |
|---|---|---|
