# 09 — QA Plan & Definition of Done

## 1. Definition of Done (every feature / phase)
- [ ] Behaviour matches GDD; doc updated if the design changed.
- [ ] `flutter analyze` → 0 issues; `dart format` clean.
- [ ] Unit tests for all logic; widget tests for new screens; golden test for key widgets where stable.
- [ ] Works on Android emulator + a real Android phone, iOS simulator + a real iPhone.
- [ ] UI work: passed the design review gate (`10_DESIGN_SYSTEM.md` §11) with screenshots in `docs/screenshots/`.
- [ ] No hard-coded user-facing strings (ARB).
- [ ] Reduce Motion, colour-blind mode, and text scaling 1.3× checked.
- [ ] No frame > 16 ms in profile mode on the test board (Level Lab FPS overlay).
- [ ] Analytics events fire with correct params (debug view).

## 2. Core gameplay acceptance tests
| # | Given | When | Then |
|---|---|---|---|
| G1 | Arrow with clear ray | tap | removed from engine immediately; exit animation plays; note plays; remaining −1 |
| G2 | Arrow blocked by B | tap | bump toward B, B flashes, hearts −1, Flow reset |
| G3 | 1 heart left, blocked tap | tap | fail sheet; Retry restores full board & hearts with **no ad** |
| G4 | Last arrow freed | — | win sequence: cascade notes, confetti, stars = hearts left, coins added once (no double-award on fast taps) |
| G5 | Two arrows tapped within 100 ms | — | both animate simultaneously; state consistent |
| G6 | Undo after removal | tap Undo | arrow returns to exact cells/dir; hearts unchanged; rotators/frozen/gates restored |
| G7 | Rotator present | remove any arrow | every rotator turns 90° CW |
| G8 | Key arrow (amber) removed | — | all amber gates open; rays now pass |
| G9 | Frozen ❄2 | tap before 2 other removals | shake, **no** heart lost |
| G10 | Linked pair, one partner blocked | tap free partner | counts as blocked tap |
| G11 | Ray enters portal A | — | continues from portal B same direction; arrow animates through |
| G12 | Hint | tap | highlighted arrow is free and solution-consistent; after following hints only, level always completes |
| G13 | Long-press 250 ms | — | route line appears; release hides; no heart cost |
| G14 | Pinch / double-tap / wheel | — | zoom 1×–4×, clamped pan, double-tap fits |
| G15 | Tap near cell edge on dense board | — | intended arrow selected (assist) in ≥ 95% of scripted test taps |
| G16 | Relaxed mode | blocked tap | no heart lost; max ★★ |

## 3. Level pipeline tests
- `tool/level_check.dart` passes on all packs (solvable, schema-valid, difficulty band ±6).
- Same seed ⇒ identical level JSON (golden fixtures) on the Dart VM, Android and iOS.
- 1,000 random seeds per chapter params ⇒ 100% solvable.
- Daily Knot for a given date identical across Android and iOS.

## 4. Meta & economy tests
- Streak: play at 23:59 and 00:01 local → +1; skip a day with freeze → kept, freeze consumed; skip without → reset.
- Daily Knot uses UTC date; share card text matches result.
- Coins never negative; purchases idempotent; restore purchases works on fresh install.
- Save survives kill during write (atomic write); migration from schema v1 → v2 test.
- Cloud merge rules (05 §6) unit-tested with conflict fixtures.

## 5. Ads tests
- No interstitial before level 12, after fail/retry, during tutorial/daily.
- Frequency caps honoured across app restarts.
- Remove Ads purchase ⇒ no interstitials immediately, rewarded still available.
- Ad load failure ⇒ game continues; rewarded button shows "not available" gracefully.

## 6. Device matrix
Android: low (2–3 GB RAM, Android 10), mid (Snapdragon 6-series), high (latest Pixel / Samsung S), one Android tablet. iOS: iPhone SE 2/3, iPhone 13, latest Pro (120 Hz), one iPad.

## 7. Accessibility checklist
Screen reader labels on all buttons; board summary label; tap targets ≥ 44 pt; contrast AA; colour-blind palettes verified with simulator; captions never rely on colour alone; Reduce Motion disables shake/confetti/parallax.

## 8. Design QA (visual acceptance)
| # | Check | Pass when |
|---|---|---|
| D1 | Banned list | No item from `10_DESIGN_SYSTEM.md` §1 (B1–B16) on any player-facing screen |
| D2 | Tokens | Grep finds no literal `Color(0x`, raw `EdgeInsets` numbers or `Duration(` inside `lib/features/**` (except tests) |
| D3 | Light direction | Highlights top-left, shadows down-right on every component screenshot |
| D4 | Pressed states | Every button/icon button has a visible press-down with lip compression |
| D5 | Hierarchy | Exactly one primary (tangerine) CTA per screen |
| D6 | Goldens | Golden tests exist for every `TB*` component state and pass |
| D7 | Sizes | Screens correct on iPhone SE, iPhone Pro Max, Android tablet landscape (game screens) |
| D8 | Arrow look | Arrows show the 5-pass tube (rim, body, light band, specular, shadow) at zoom 1× and 4× |
| D9 | Stranger test | Show 3 screenshots to 3 people outside the project: none say it "looks AI-made" or "looks like a template" |

## 9. Pre-launch checklist
Privacy policy & terms URLs; data safety (Play) / privacy nutrition (App Store) forms; age rating questionnaires; ad content rating G; UMP consent tested in EEA; ATT pre-prompt; store screenshots/video; crash-free rate ≥ 99.5% in soft launch; all asset licences recorded.
