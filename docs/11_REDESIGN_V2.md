# 11 — Redesign V2 ("Clean Line") — direction chosen, pending mock-up approval

Why: first outside feedback was "boring", "3D arrows and boards look bad", "tasks/cells too small".
This doc replaces the Toybox-3D direction in `docs/06` / `docs/10` once approved. Nothing here is coded yet.

## 1. Research summary (what the market does)
| Finding | Source |
|---|---|
| Category leader *Arrows – Puzzle Escape* (Lessmore): 100M+ installs, ~4.7★, **flat minimalist look, no timers, thousands of handcrafted levels, hints**. | Play Store / App Store listings |
| Top complaints: **ads too frequent/hard to close**, "boring after 4000 levels" (no variety/reward feel), **accidental taps while panning the board**. | Store reviews |
| Challengers differentiate with modes: timed + daily leaderboard, colour arrows, 3D "tied" arrows, infinite procedural mode. | App Store listings |
| Hyper-casual retention: D1 ≈ 40 % is the viability bar, D7 ≈ 19 % good; meta layers (daily reward, streaks, achievements, events) drive return. Notifications that show *progress already made* motivate. | GameIntel / App Annie / nGrow case study |

Takeaways: (1) the winners are **flat, bold, readable** — not 3D; (2) our edge is **feel** (juice, sound) and **a retention layer that respects the player**; (3) fix their pain points: gentle ads, no accidental taps, variety.

## 2a. DIRECTION OF RECORD — "Clean Line" (supersedes §2 below)
Mock-ups: `docs/screenshots/v2_clean/` (play light/dark, win, home). Reference: Easybrain-style thin-line arrow puzzles (clean, calm, white board, shaped silhouettes).
- Thin-line arrows (≈ 0.16–0.2 cell), navy ink on white / near-white on charcoal; no card, bevel or 3D; **teal accent** (`#14B8A6`) for taps, hints, progress and primary buttons.
- **Shaped boards**: levels fill a silhouette; the finished picture is revealed on the win screen over a sunburst + confetti.
- Sparse HUD: back, level, arrows-left chip, hearts, difficulty tag, Hint / Zoom round buttons.
- Light / dark / auto themes. Early levels sparse and large; dense mazes later with pinch-zoom, auto-zoom-to-next-free-arrow and long-press magnifier.
- Schema: `docs/04` §1.1 (v2: no chapters, optional `picture`).

## 2. (Superseded) Visual direction — "Bright & Bouncy" (flat vector, no bevel/3D)
- **Arrows**: thick, flat, rounded strokes (≈ 0.55 cell), solid saturated colour + 1 px lighter inner stripe; round tail, big triangle head. No bevel, lip, glow or gradient on the body. Soft drop shadow only (one token).
- **Board**: no wooden tray. Clean rounded card on a full-bleed **animated gradient background** that shifts hue every 10 levels (colour world, not "chapters"). Faint animated dot grid under the arrows.
- **Bigger targets**: arrow ≥ 44 px stroke-to-stroke; board **auto-zooms to fit with min cell 36 px**; large boards pan with two fingers only (one-finger drag never taps) → fixes accidental taps. Max grid for phone: 9 × 12 visible; larger levels scroll.
- **Palette**: 8 vivid arrow colours on a deep navy / soft cream pair (light + dark theme). Typography stays Fredoka (display) + Nunito (body).
- **HUD**: level number, ♥ hearts, 💡 hint, ↶ undo as big flat pill buttons (flat fill + 2 px darker bottom edge; pressed = 2 px down). Same component names (`TB*`), re-skinned via tokens.

## 3. Juice & sound ("never boring")
| Event | Animation | Sound | Haptic |
|---|---|---|---|
| Tap free arrow | squash-stretch anticipation, flies out with motion trail + speed lines, board nudges | rising pentatonic note (chain climbs) | light |
| Chain of exits | **combo meter**: colour of background pulses, note pitch climbs per chain, "×5" pop | arpeggio sparkle | medium |
| Blocked arrow | wobble + red flash, heart cracks, camera shake 4 px | soft "bonk" | heavy |
| Last arrow | slow-mo 0.4 s, zoom-in, confetti cannon from both sides, stars stamp | fanfare chord | success |
| Level start | arrows pop in with stagger (spring) | tiny marimba run | — |
| Idle 5 s | one free arrow bounces ("tap me") | — | — |
| Coins/stars | fly to HUD with arc + ticking counter | coin ticks, pitched up | tick |
Reduce Motion keeps colour/sound, drops shake/zoom/slow-mo.

## 4. Structure — endless "Levels", no chapters
- Remove chapters/worlds. One linear track: **Level 1 → ∞**, procedurally generated + solver-verified in 25-level **packs** shipped locally (first 1,000 bundled, more generated deterministically from seed on device).
- Difficulty curve in 10-level waves: easy → easy → … → **Boss** level (bigger, 2× coins) every 10th, **Rest** level every 5th.
- Mechanics (rotators, gates, frozen, links, portals) are introduced progressively by level number, not chapter.
- Cosmetics: arrow skins/trails/boards unlock by **level milestones** (every 50 levels) + shop.

## 5. The differentiator — "Chime Companion" (kind notifications)
Local notifications first (no backend, `flutter_local_notifications`), opt-in after level 5 with a friendly pre-prompt, hard caps and quiet hours. Tone: **appreciation, never guilt**.
| Kind | Example | Rule |
|---|---|---|
| Appreciation | "You've cleared 120 arrows today — your best day yet. 🎶" (no emoji icons in-app; plain text) | after a session with a personal best |
| Progress nudge | "Level 87 is 3 arrows from a new star record." | 1 day idle |
| Streak guardian | "Your 6-day streak is safe until midnight — one quick puzzle?" | evening, only if streak ≥ 3 and not played today |
| Daily drop | "Today's Daily Chime is ready (4 min)." | at the player's usual play hour (learned locally) |
| Comeback | "No pressure — your arrows will be here. Free hint waiting." | 3 / 7 days idle, then stop for 30 days |
**Rules:** max 1/day, none 22:00–09:00 local, auto-stop after 3 ignored in a row, one-tap "fewer"/"off" in Settings, never during first session, copy from ARB (localised), tracked in analytics (opened/dismissed).
Extra "only-us" hooks: a **"Chime Diary"** screen — a calm timeline of your best moments (best chain, streak days, hardest level cleared) that the notifications link into; and a **"Gift a puzzle"** share link (a level seed) friends open directly.

## 6. Engineering scope
1. Tokens + painters: flat arrow painter, new board/background, animated gradient (tokens only).
2. Layout: min-cell zoom, two-finger pan, one-finger tap-only.
3. Juice pass per §3 (combo, slow-mo, confetti, idle hint, stagger).
4. Remove chapters: level index → single track, pack generation by level number, migrate saves (chapter+level → global level).
5. **Single flavor (prod only)**: delete `dev` flavor, `main_dev.dart`, `.dev` app id / schemes; update CI and CLAUDE.md commands.
6. Notifications service behind an interface + fake, scheduler with caps, Settings controls, tests.
7. Update docs 02, 03, 04, 06, 07, 10, PROGRESS; regenerate goldens/screenshots; **design gate → human review**.

## 7. Decisions needed
See the questions asked in chat (art style, save migration, notification scope).
