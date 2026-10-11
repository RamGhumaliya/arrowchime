# 10 — Design System: "Toybox 3D" (STRICT)

> **For Claude Code: this file is a hard contract, not inspiration.**
> The game must look like a senior human game-UI designer crafted it — chunky, tactile, modern 2.5D / soft-3D, with one consistent light source. It must **never** look like a generic AI-generated Flutter app. If a screen or widget is not specified here, **stop and ask** instead of improvising a look.

---

## 0. The quality bar

Think "premium mobile puzzle game UI": physical, toy-like objects you want to press. Study (don't copy) the craft level of games such as Monument Valley, Alto's Odyssey, Two Dots and the chunky button/panel language of top casual titles. Every element should feel like it is made of a real material — glazed ceramic, enamel, lacquered wood, brushed brass — lit by the same lamp.

**The 5-second test:** a stranger looking at any screenshot should think "this was designed by a studio", not "this is a template".

## 1. BANNED — the "AI-generated look" (automatic rejection)

If any of these appear in player-facing UI, the work is not done:

| # | Banned | Instead |
|---|---|---|
| B1 | Unstyled Material/Cupertino widgets visible to players: `ElevatedButton`, `FilledButton`, `Card`, `AppBar`, `FloatingActionButton`, `Switch`, `Slider`, `Checkbox`, `SnackBar`, `AlertDialog`, `BottomNavigationBar`, `NavigationBar`, `Chip`, `ListTile` look | Our own `TBButton`, `TBPanel`, `TBToggle`, `TBSlider`, `TBSheet`, `TBToast`, `TBTabBar` (§5). Material widgets are allowed only as invisible structure (e.g. `Material` for ink, `Scaffold` body) or in the debug Level Lab. |
| B2 | Purple/violet → pink/blue "AI gradient" backgrounds, rainbow mesh gradients, gradients with no light logic | Chapter-painted backgrounds + token gradients that follow the light rule (§2) |
| B3 | Glassmorphism / frosted blur cards everywhere, neon outer-glow on everything | Solid materials with bevels; glow only for magic FX (portal, flow ×5) |
| B4 | Emoji as UI icons (❤️ ⭐ 🔥 ✨), Material Icons / Cupertino icons in game UI | Custom 3D icon set (§6); emoji only inside the Daily share **text** |
| B5 | Roboto, Inter, SF default, Poppins, Montserrat | Fredoka (display) + Nunito (UI), bundled |
| B6 | Everything centred in one column with equal gaps; identical card grids; "hero + 3 feature cards" layouts | Layouts from §7 specs with clear hierarchy and asymmetry where specified |
| B7 | Zero-offset, large-blur "glow shadows"; more than the 3 elevation styles in §3 | Exactly the shadow recipes in §3 |
| B8 | Random corner radii | Only radii tokens `r12`, `r20`, `r32`, `pill` |
| B9 | Scattered sparkles/stars decoration, generic blobs, abstract wavy shapes | Decoration only from the chapter scene or defined FX |
| B10 | Gradient text, outlined "tech" text, all-caps paragraphs | Sticker-style numbers & titles (§4) |
| B11 | Generic copy: "Unlock your potential!", "Let's go!!!", stacked exclamation marks | Short, warm, specific microcopy (§9) |
| B12 | More than one primary (tangerine) button per screen | One primary CTA; others secondary/tertiary |
| B13 | Inconsistent light direction (a highlight bottom-right on one element, top-left on another) | Light always from **top-left, 35° elevation** |
| B14 | Flat 1-colour shapes for interactive objects | Every interactive object has face + bevel/lip + highlight + shadow |
| B15 | Placeholder art that looks final (AI images, stock illustrations) | Placeholders are visibly placeholders (§10) |
| B16 | A "dark mode" invented on the fly | Single designed theme per chapter. No system dark mode in MVP. |

## 2. Light & material rules (the core of the 3D look)

- **One key light** from the **top-left** at about 35°. Every highlight sits top/left; every shadow falls **down and slightly right**.
- **Three-tone shading** for every solid object: `face` (base colour), `bevel-light` (+18% lightness, top/left rim), `bevel-dark` / `lip` (−22% lightness, bottom/right rim) + one **specular** streak (white 55–70%, thin, top-left).
- **Ambient occlusion**: where an object sits on a surface, add a tight dark contact shadow (2–4 dp, 30% ink) in addition to the soft drop shadow.
- **Materials** (used consistently):
  | Material | Where | Recipe |
  |---|---|---|
  | Glazed ceramic | Buttons, pills | glossy specular, saturated face, 6 dp lip |
  | Enamel candy | Arrows (default skin) | tube shading (§8), strong specular |
  | Lacquered wood / cream paper | Panels, sheets, board tray | low gloss, subtle grain texture (2% opacity noise), rim light |
  | Brushed brass | Frames, star plaques, chapter-2 skin | linear metal gradient + fine specular |
  | Crystal / ice | Frozen mechanic, crystal skin | translucent face, internal facets, bright rim |

Implement these as reusable painters (`core/ui/painters/`) — never hand-tune shadows per widget.

## 3. Tokens

### 3.1 Colour — brand "Night Garden" palette
| Token | Hex | Role |
|---|---|---|
| `ink900` | #121A2B | Darkest backgrounds, text on light |
| `ink700` | #1E2A44 | Panels on dark, board tray rim |
| `ink500` | #3A4A6B | Secondary text |
| `cream100` | #FFF6E6 | Panel face |
| `cream300` | #F3DFC1 | Panel bevel-dark, dividers |
| `tangerine` | #FF8A1F | **Primary CTA only** |
| `tangerineLip` | #C85A08 | Primary button lip |
| `teal` | #19B3A3 | Secondary CTA, success, "free" route |
| `tealLip` | #0E7D72 | Teal lip |
| `berry` | #E5446D | Hearts, errors, blocked flash |
| `butter` | #FFD15C | Coins, stars, rewards |
| `butterLip` | #C9952A | Coin/star edges |
| `sky` | #6EC6FF | Info, frozen hints |
Rules: tangerine never used for anything except the one primary action. Text never pure black/white: use `ink900` / `cream100`. Contrast ≥ 4.5:1 for text.

Chapter palettes (backgrounds/arrows) live in `ChapterTheme` and are defined in `06_ART_DIRECTION.md`. UI chrome stays on the brand palette in every chapter.

### 3.2 Spacing — 4 dp base
`s4, s8, s12, s16, s24, s32, s48, s64`. Screen side margin `s16` (phones) / `s32` (tablets).

### 3.3 Radius
`r12` (small chips, icon wells), `r20` (buttons, pills), `r32` (panels, sheets), `pill` (999).

### 3.4 Elevation (the only 3 allowed)
| Token | Drop shadow | Contact shadow | Use |
|---|---|---|---|
| `e1` | (0, 3) blur 6, ink 18% | (0,1) blur 1, ink 25% | Pills, small chips |
| `e2` | (2, 8) blur 16, ink 22% | (0,2) blur 2, ink 30% | Buttons, cards |
| `e3` | (4, 18) blur 32, ink 28% | (0,3) blur 3, ink 30% | Sheets, dialogs, win plaque |
(Shadow x-offset follows the top-left light → shadows lean right.)

### 3.5 Motion
| Token | Duration | Curve | Use |
|---|---|---|---|
| `mTap` | 90 ms | easeOut | Press down |
| `mRelease` | 160 ms | `Curves.easeOutBack` (overshoot 1.4) | Release / pop |
| `mEnter` | 240 ms | easeOutCubic | Sheets, panels slide in |
| `mCelebrate` | 360–600 ms | spring (stiffness 380, damping 22) | Stars, plaques, chests |
Stagger lists by 40 ms. Nothing linear except progress fills. Reduce Motion → fades of 160 ms only.

### 3.6 Derived tokens added in Phase 3
The spec fixes the palette (§3.1) but not the wood/brass of the materials in §2 or the size of the smaller components, so Phase 3 added them to `lib/app/theme/tokens.dart` (no new hues, nothing literal in components):

| Token group | Contents |
|---|---|
| `TBMaterials` | `woodFace/woodLip/woodHighlight` = `tangerineLip` toned into `ink700`/`ink900` and `cream100`; `brassFace/brassLight/brassDark` from `butterLip`/`butter`; `crystalFace` = `sky` |
| `TBBevel` | inner highlight 1.5 dp @ 45%, specular 3 dp @ 70%, panel bevel 4 dp, rim light 2 dp, grain 2%, ceramic top +8% lightness, disabled desaturation 80%, inner-shadow offset 3 / blur 4, brass rim 3 dp, wood rim 6 dp |
| `TBSizes` (additions) | pill 40, pill icon overlap 30%, "+" mini button 34, badge 22, toggle 64x36 (knob 30), slider groove 14 / knob 32, progress 20, flow meter 28, star 52, ribbon 56 (fold 14), tab 56, toast 48, chapter card 280x340 (frame 14), focus ring 3, chapter tilt 4 deg |
| `TBMotion` (additions) | `sheetCurve` (ease-out-back, overshoot 0.8), `starStagger` 180 ms, `toast` 2 s, `shimmer` 1.6 s |

### 3.7 Responsive rules (Phase 3)
- **Breakpoint:** shortest side >= 600 dp is a tablet (`TBLayout.isTablet`). Side margin 16 dp on phones, 32 dp on tablets (`TBLayout.screenMargin`).
- **Wide screens centre, they do not stretch:** content is capped at 720 dp (`TBCentered`, `TBSizes.contentMaxWidth`); bottom sheets at 560 dp (`TBSizes.sheetMaxWidth`). Chapter cards keep their size.
- **Text scale (docs/09 §7, tested at 1.0 / 1.3 / 1.5 / 2.0):** components with fixed heights grow by exactly the extra line height of the scaled text (`TBLayout.extraLine`), so nominal sizes are unchanged at 1x (buttons 64/52/44, ribbon 56, pill 40, tab bar). Button labels, pill values and ribbon/tab titles ellipsise or scale down instead of overflowing; the star row scales down in narrow boxes.
- **Tap targets** stay >= 44 dp at every scale (sliders and toggles included).
- **Pages scroll as a whole** (no fixed headers that a large text scale could squeeze out).
- `test/core/ui/responsive_test.dart` renders all 8 gallery pages at 320x568, 375x667, 430x932, 768x1024 and 1280x800 at 1.0 / 1.3 / 1.5 text scale (120 combinations) and fails on any overflow.

### 3.8 Press physics (measured by tests)
A pressed ceramic control reacts to the **raw pointer-down** (Flutter's `onTapDown` is delayed ~100 ms and would feel mushy): face down 4 dp, lip 6 -> 2 dp, shadow `e2` -> `e1`, selection haptic, `mTap` (90 ms easeOut). Release uses `mRelease` (160 ms, overshoot 1.4: the face pops up a hair above rest). Reduce Motion: 160 ms, no overshoot. `test/core/ui/painters_icons_test.dart` rasterises the painter and checks the lip rows (6 / 2) and face offset (0 / 4) in pixels.

## 4. Typography

| Style | Font | Size / weight | Treatment |
|---|---|---|---|
| `display` | Fredoka | 44 / 700 | **Sticker style**: 3 dp `ink900` stroke + 4 dp downward hard shadow (`ink900` 35%) |
| `title` | Fredoka | 28 / 700 | Sticker style, 2 dp stroke |
| `counter` | Fredoka | 22 / 700 | Tabular figures, 2 dp stroke, cream fill on dark pills |
| `button` | Fredoka | 20 / 600 | 1.5 dp darker-lip-colour stroke, letter-spacing +0.2 |
| `body` | Nunito | 16 / 600 | Plain, `ink900` on cream |
| `caption` | Nunito | 13 / 700 | Plain, `ink500` |
Implement once as `TBText` variants. Never use `Text` with ad-hoc styles in player UI.

## 5. Component library (build these BEFORE any screen)

All components live in `lib/core/ui/components/`, are custom-painted, and ship with golden tests for every state (idle, pressed, disabled, focus) at 1× and 3×.

| Component | Spec |
|---|---|
| `TBButton.primary/secondary/tertiary` | Height 64 (primary) / 52 / 44. Ceramic: face gradient (+8% top → face), 6 dp lip in lip colour, 1.5 dp top-left inner highlight (white 45%), specular streak, `e2`. **Pressed:** face moves down 4 dp, lip shrinks to 2 dp, shadow tightens to `e1`, haptic selection — in `mTap`; release with `mRelease`. Disabled: desaturate 80%, no lip. Optional left icon (3D icon, 32 dp). |
| `TBIconButton` | 56 dp round ceramic button for Undo/Hint/Grid/Fit, with badge slot (count / coin price) as a small butter pill top-right. |
| `TBPill` | Resource counter (hearts, coins): `ink700` recessed pill (inner shadow), 3D icon overlapping the left edge by 30%, `counter` text, optional "+" mini teal button on the right. |
| `TBPanel` | Cream lacquered-paper surface, `r32`, rim light top, 4 dp `cream300` bottom bevel, 2% grain, `e2`. Variants: `raised`, `recessed` (inner shadow — used for board tray and lists). |
| `TBRibbon` | Title banner: tangerine or teal fabric ribbon with folded ends, `title` sticker text. Used on Win, Fail, chapter headers. |
| `TBSheet` | Bottom sheet = big `TBPanel` with a `TBRibbon` header overlapping the top edge; scrim `ink900` 55%; enters with `mEnter` + slight overshoot. |
| `TBToggle` | Physical rocker switch: recessed track, ceramic knob with specular; on = teal track. |
| `TBSlider` | Recessed groove, ceramic knob, filled part teal; tick haptic every 10%. |
| `TBTabBar` | Wooden shelf with 3D tab plaques; selected tab raised + tangerine underline glow. |
| `TBStarRow` | 3 brass-rimmed stars; empty = recessed socket; fill animates with stamp + dust puff. |
| `TBProgressBar` | Recessed tube, butter liquid fill with moving highlight band. |
| `TBToast` | Small floating plaque from top, auto-hide 2 s. |
| `TBChapterCard` | Diorama window: chapter scene thumbnail inside a thick wooden frame, restoration % on a brass plaque, slight perspective tilt (rotateX 4°) that relaxes to 0 when focused. |
| `TBFlowMeter` | Segmented glass tube along the top of the board; segments light up with chapter colour; ×N badge pops. |
| `TBTray` | The board tray of §8 as a widget: chapter felt colour, fabric noise, inner shadow, 6 dp wooden rim. Used by the game screen (Phase 4). |
| `TBText` | The six text styles; sticker treatment (stroke + hard shadow) implemented once. |
| `TBIcon` | 25 placeholder 3D icons painted in code (3-tone + specular), names = `assets/ASSET_MANIFEST.md`. Replaced by the artist's WebP set. |
| `TBBadge` | Butter count/price pill (part of `TBIconButton`). |

Every component reads tokens only — no literal colours, sizes or durations inside component code.

## 6. Icons

- **Custom 3D icon set** (25 icons, list in `assets/ASSET_MANIFEST.md`; Phase 4 added `back`): rendered by a human 3D artist (Blender / Spline / Cinema4D) in one consistent style: soft clay-ceramic material, top-left key light, slight 3/4 angle, transparent background, delivered as 256 px WebP @1x/2x/3x.
- Until then, Claude Code draws **simple placeholder icons** with `CustomPainter` using the 3-tone rule (face + bevel + highlight) so the layout is right — clearly marked placeholder in the Design Gallery.
- No Material/Cupertino icons, no emoji, no icon fonts in player UI.

## 7. Screen layout specs (portrait phone, 390×844 reference)

```
HOME
┌───────────────────────────────────────┐
│ [♥ pill 5/5]  [coin pill 1,240 +]  [⚙]│  top row, s16 margin, pills e1
│                                       │
│    (chapter diorama fills screen,     │  full-bleed animated scene,
│     parallax 3–5 layers, ambient FX)  │  restoration visible
│                                       │
│  ┌ Daily Knot plaque ┐   streak flame │  left-aligned plaque (TBPanel small)
│  └───────────────────┘   3D icon + n  │  right: streak counter
│                                       │
│        ╔══════════════════════╗       │
│        ║   PLAY  · Level 37   ║       │  TBButton.primary, 64 dp, width 72%
│        ╚══════════════════════╝       │
│  [Shop]   [Collection]   [Quests]     │  3 TBIconButtons on a wooden shelf
└───────────────────────────────────────┘

LEVEL
┌───────────────────────────────────────┐
│ [‹]  Level 37 ribbon   [♥♥♥]  [coins] │  ribbon centre, small
│ ═══ Flow meter (glass tube) ═══════   │
│ ┌───────────────────────────────────┐ │
│ │  board tray (TBPanel.recessed,    │ │  board centred, max area
│ │  chapter-tinted felt surface)     │ │
│ └───────────────────────────────────┘ │
│   (Undo)   (Hint 2)   (Grid)   (Fit)  │  TBIconButtons on a bottom shelf,
└───────────────────────────────────────┘  left-handed mode mirrors order

WIN SHEET            FAIL SHEET
  ribbon "Level 37"    ribbon "Out of hearts" (berry)
  brass plaque with    board thumbnail desaturated
  TBStarRow            [Retry]  primary
  coin + XP rows       [+1 ♥ ▶ ad] secondary  [+1 ♥ 100c] tertiary
  [Next] primary       no ad shown before Retry
  [Replay] tertiary
```
Tablet landscape: board left 70%, HUD shelf as a vertical wooden panel on the right.

**LEVEL: states added in Phase 4 (not in the original spec, awaiting approval).**
```
LOADING / LOAD ERROR (chapter scene behind, centred, same Level backdrop)
┌───────────────────────────────────────┐
│                                       │
│          "Setting up the board…"      │  TBText.title, cream, ink stroke
│   (error: "This level could not be    │  error variant adds one primary
│    opened."  [ Back ]  TBButton.primary)│  TBButton "Back" → previous screen / Home
│                                       │
└───────────────────────────────────────┘

LEVEL, tablet landscape (≥600 dp shortest side, width > height)
┌──────────────────────────────────┬──────────┐
│ [‹]      Level 37        ♥♥♥ coin │  wooden  │  top bar spans the board column
│ ═══ Flow meter ══════════════════ │  shelf   │  (ribbon takes the free space)
│ ┌──────────────────────────────┐ │ (Undo)   │
│ │ board tray                   │ │ (Hint)   │  shelf = vertical wooden panel,
│ │                              │ │ (Grid)   │  centred in the right 30%
│ └──────────────────────────────┘ │ (Fit)    │
└──────────────────────────────────┴──────────┘
Left-handed reverses the order of the shelf buttons (left↔right on phones, top↔bottom on tablets).
Hearts = row of heart icons on a recessed capsule (broken heart = lost); coins = TBPill.
Shelf badges: Undo = free undos left, then its price; Hint = free hints left, then price (none while free).
```

Other screens (Shop, Collection, Daily, Settings, Achievements) follow the same kit: header `TBRibbon`, content in `TBPanel.recessed` lists, one primary CTA max. Before building any of them, Claude Code writes its ASCII layout into this section for approval.

### Phase 6 screen layouts (approved by the human, built in Phase 6)
Differences between these sketches and the built screens: the level strip wraps as many 44 dp pips per row as fit (7 on an iPhone SE) instead of exactly 10, so every pip is a 44 dp tap target; a missed Daily replay costs **100 coins** (`docs/08`), not 20; **Home**: the sketch's "♥ pill 5/5" has no meaning (hearts are per level, there is no global lives system), so Home shows the **player-level pill** there (tap = Achievements & Stats), a small **chapter plaque** under it opens the Chapter Map, and the music of the current chapter plays; the Quests sheet also shows the chest as the single primary button; recessed panels are cream wells, so their text is ink, not cream.
All screens: portrait 390×844 reference, `s16` side margin (tablet `s32`, content centred ≤ 720 dp), header `TBRibbon` + back `TBIconButton`, content in `TBPanel.recessed`, **at most one primary `TBButton` per screen**. Every string in ARB, every tap target ≥ 44 dp.

```
CHAPTER MAP  (from Home "Play" long-area or the chapter plaque)
┌───────────────────────────────────────┐
│ [‹]      Chapters ribbon      [coins] │
│                                       │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │  horizontal PageView of TBChapterCards
│  │ diorama │ │ diorama │ │ silhouette│ │  280×340, centre card focused (tilt 0),
│  │  frame  │ │  frame  │ │  + lock  │  │  neighbours tilted 4°; snap scrolling
│  │ 62%     │ │ 18%     │ │          │  │  brass plaque = restoration %
│  └─────────┘ └─────────┘ └─────────┘  │  locked = desaturated + lock icon
│   Misty Garden · ★ 112/180            │  name + stars of the focused chapter
│  ● ○ ○ ○ ○            (page dots)     │
│  ┌ level strip (TBPanel.recessed) ───┐ │  60 level pips in a wrapped grid, 10 per row:
│  │ ①②③④⑤⑥⑦⑧⑨⑩  stars under each    │ │  done = brass pip + stars, current = tangerine,
│  └───────────────────────────────────┘ │  locked = grey; every 10th = Knot pip (hex),
│        [ PLAY  Level 37 ]             │  60th = Boss pip. PLAY = the one primary CTA.
└───────────────────────────────────────┘

DAILY KNOT
┌───────────────────────────────────────┐
│ [‹]    Daily Knot #142 ribbon  [coins]│
│  ┌ today card (TBPanel) ─────────────┐│
│  │ mini board preview (felt tray)    ││  static preview of today's seeded board
│  │ 14×14 · 41 arrows    best: ♥♥♥ ⚡×4││  best result if already played
│  └───────────────────────────────────┘│
│        [ PLAY TODAY ]                 │  the one primary CTA (becomes "Share" when done:
│        or  [ Share result ] secondary │  then primary = Share)
│  ┌ calendar, last 30 days (recessed) ┐│  7-column grid of day pips: played = brass,
│  │ M T W T F S S                     ││  missed = grey (tap → "Replay for 20 coins"
│  │ ● ● ○ ● ● ● ●  …                  ││  TBSheet), today = tangerine ring
│  └───────────────────────────────────┘│
│  streak flame ×7  ·  freeze: 1 left   │  TBPill-style row, flame icon with tier glow
└───────────────────────────────────────┘
Share card (rendered off-screen to PNG + text via share_plus):
  a TBPanel card (360×450 logical, rendered at 3x): ribbon "Arrowchime Daily #142", ♥♥♡ row (hearts as icons),
  ⚡×4, time, the emoji mini-board (coloured squares) — text version:
  "Arrowchime Daily #142 ❤️❤️🖤 ⚡x4 ⏱1:52" + emoji grid (emoji only inside this share text, B4 exception).

QUESTS  (TBSheet from Home quests button)
┌───────────────────────────────────────┐
│        ┌ ribbon: Daily quests ┐       │
│  ┌ quest row ────────────────────────┐│  3 rows, each: icon, caption (≤ 6 words),
│  │ ▣ Clear 5 levels      [▓▓▓░░] 3/5 ││  TBProgressBar, coin reward badge;
│  └───────────────────────────────────┘│  completed row = "Claim" secondary TBButton
│  ┌ … Reach Flow ×3 ───────── [Claim] ┐│  claim plays coin burst; all 3 claimed → chest
│  ┌ … Free 100 arrows ───────  12/100 ┐│  row at the bottom: quest chest (open = primary)
│            [ Open chest ]             │
└───────────────────────────────────────┘

ACHIEVEMENTS & STATS
┌───────────────────────────────────────┐
│ [‹]   Achievements ribbon    [coins]  │
│  [ Achievements | Stats ]  TBTabBar   │  two wooden tabs
│  Achievements: 2-column grid of badge │  each = brass medallion + icon + title;
│  tiles (TBPanel), locked = silhouette │  progress bar for counters (e.g. 412/1000);
│  with progress; tap → small TBSheet   │  unlocked shows date
│  Stats: recessed list rows            │  rows: arrows freed, perfect clears, best Flow,
│   label ........................ value│  play time, levels cleared, longest streak
└───────────────────────────────────────┘

SETTINGS
┌───────────────────────────────────────┐
│ [‹]      Settings ribbon              │
│  ┌ Sound (TBPanel.recessed) ─────────┐│  Music  TBSlider + TBToggle
│  │ Music  ▬▬▬●▬▬▬        [on]        ││  Sound  TBSlider + TBToggle (notes + effects)
│  │ Sound  ▬▬▬▬▬●▬        [on]        ││  Haptics TBToggle
│  │ Haptics                [on]       ││
│  └───────────────────────────────────┘│
│  ┌ Play ─────────────────────────────┐│  Left-handed (mirrors the shelf), Relaxed mode
│  │ Left-handed layout     [off]      ││  (no hearts lost, max ★★), Reduce motion
│  │ Relaxed mode           [off]      ││  (follows the system, can force on),
│  │ Reduce motion          [system]   ││  Colour-blind palette: 3 chips (Off / Deutan-Protan /
│  │ Colour-blind palette  < Off >     ││  Tritan) as a TBTabBar-style segmented control
│  └───────────────────────────────────┘│
│  ┌ Account & info ──────────────────┐│  Language (system), Account (placeholder until
│  │ Language · Account · Privacy      ││  Phase 9), Privacy, Restore purchases (Phase 8),
│  │ Restore purchases · Credits       ││  Credits: rows open sub-sheets; no primary CTA here
│  └───────────────────────────────────┘│
└───────────────────────────────────────┘

ONBOARDING OVERLAY (Ch1 L1–10, on the Level screen)
┌───────────────────────────────────────┐
│ (normal Level screen)                 │
│        ┌ caption TBToast-style ─┐     │  caption ≤ 6 words, top of board, e.g.
│        │ Tap an arrow to free it│     │  "Tap an arrow to free it." (L1),
│        └────────────────────────┘     │  "Some arrows are blocked." (L2),
│            ☝ hand cursor              │  "Blocked taps cost a heart." (L3),
│   (taps/long-presses the target arrow)│  "Hold to peek the path." (L5), "Pinch to zoom." (L8)
└───────────────────────────────────────┘
Hand cursor = a 3D ceramic hand placeholder (code-painted), loops a tap or press gesture on a
solution arrow chosen from the level's `meta.solution`; hidden after the first correct tap.
```


### Phase 8 screen layouts (approved and implemented in Phase 8; deviation: Shop coin tiles show the price as a caption with a short "Buy" button so it fits iPhone SE)
Same kit and rules as the Phase 6 screens (`ScreenFrame`, `TBPanel.recessed` wells with ink text, at most one primary `TBButton` per screen, ≥ 44 dp targets, strings in ARB). Prices in the sketches are the defaults of `docs/08` §3 (the real price strings come from the store).

```
SHOP
┌───────────────────────────────────────┐
│ [‹]        Shop ribbon        [coins] │
│ ┌ Starter Bundle (only L15+, 48 h) ─┐ │  panel with a countdown ("1d 20h left"),
│ │ Remove Ads · 2,000 coins · Neon   │ │  contents as 3 small icon chips, and the
│ │ skin           [ $6.99 ] primary  │ │  ONE primary button of the screen; hidden
│ └───────────────────────────────────┘ │  when expired, bought, or Remove Ads owned
│ ┌ Remove Ads ───────────────────────┐ │  panel: icon + "No interstitials, ever."
│ │ + 500 coins        [ $3.99 ]      │ │  (secondary button); shows "Owned" tick when
│ └───────────────────────────────────┘ │  bought. Rewarded ads stay optional.
│ Coins (3 equal tiles in a row)        │  each tile: coin-stack icon, amount,
│ [1,000 $1.99] [5,500 $7.99] [15,000 …]│  secondary button with price; middle one has a
│                                       │  "Best value" brass tag
│ ┌ Chapter Art Pack ─ $2.99 ─────────┐ │  skin + trail + instrument preview chips
│ └───────────────────────────────────┘ │
│  Restore purchases   (tertiary)       │  bottom, centred
└───────────────────────────────────────┘
Buying shows the store sheet; success = a TBToast "Thank you!" + coins fly to the pill
(count-up), failure = TBToast "Purchase didn't go through.". No dark patterns: no fake
timers other than the real 48 h bundle window, no pre-ticked upsells.

COLLECTION  (Home shelf → Collection)
┌───────────────────────────────────────┐
│ [‹]     Collection ribbon     [coins] │
│ ┌ live preview (felt tray, 6×6 board)┐│  the REAL board renderer with the selected
│ │  arrows in the chosen skin/trail   ││  item applied; tap the preview to replay a
│ │  board theme as the tray colour    ││  short clear (arrows fly out + trail + note)
│ └────────────────────────────────────┘│
│ [Arrows|Trails|Boards|Instruments]    │  TBTabBar
│ ┌ grid of item tiles (2 per row) ────┐│  tile: swatch/preview, name, state:
│ │ Enamel Candy  ✓ equipped           ││  equipped tick / "Owned" / lock + how to get
│ │ Bamboo        Owned                ││  it ("Finish Misty Garden" or a coin price
│ │ Neon Tube     🔒 1,500 coins       ││  chip). Selecting a tile previews it.
│ └────────────────────────────────────┘│
│        [ Equip ]  /  [ Buy · 1,500 ]  │  the ONE primary: Equip (owned) or Buy
└───────────────────────────────────────┘                  (coins; disabled with a hint if short)
Items: Arrow skins (Enamel Candy default, Bamboo, Brass, Lantern Silk, Crystal, Galaxy,
Neon Tube, Paper-craft, Pixel), Trails (Sparkle, Petals, Snow, Ribbons), Board themes
(the 5 chapter trays + 2 extra), Instruments (Piano, Marimba, 8-bit, Choir). Chapter skins
are earned by restoring the chapter; Constellation items at 120 / 150 / 180 stars; the rest
cost coins (common 500, rare 1,500, epic 4,000) or come in bundles. Cosmetic only.
"Galaxy" may use a fragment shader (`glow.frag`) with a flat fallback when it is missing.

STARTER BUNDLE / PAYWALL SHEET  (TBSheet, opens once after level 15, never on a win/fail sheet)
  ribbon "Starter Bundle" · three chips (Remove Ads · 2,000 coins · Neon skin) · timer ·
  [ $6.99 ] primary · "Not now" tertiary. Shown at most once per day while the window is open.

ATT PRE-PROMPT  (iOS only, TBSheet after level 5, before the system dialog)
  ribbon "A quick note" · body ≤ 25 words explaining that allowing tracking keeps ads
  relevant and the game free · [ Continue ] primary (then the system ATT dialog) ·
  "Maybe later" tertiary (asks again after 7 days at most once).

WIN SHEET additions (docs/08: rewarded "double coins", max 5 per day)
  under the coin row: [ ×2 coins ▶ ] secondary teal button with a small ad badge; hidden when
  coins are 0, the daily cap is used, or no ad is loaded. Win sheet keeps ONE primary (Next).
FAIL SHEET: unchanged (+1 heart ad / coins already specified).
HINT with no coins: the "not enough coins" toast gets an action "Watch ad for a free hint".
MISSED DAILY replay sheet: adds a secondary "Unlock with an ad" next to the coin price.
```

## 8. Arrows & board (in-game 3D look)

**Arrow = glossy enamel tube**, drawn in 5 passes on a cached `Picture`:
1. **Shadow:** path offset (+0.06c, +0.10c), width 0.44c, ink 28%, blur 0.08c (pre-baked once per zoom bucket).
2. **Dark rim:** width 0.46c, colour −30% lightness.
3. **Body:** width 0.40c, base colour.
4. **Light band:** width 0.18c, colour +25% lightness, offset (−0.03c, −0.05c).
5. **Specular:** width 0.05c, white 70%, offset (−0.06c, −0.09c), drawn only on segments facing up/left (dash it off on down/right-facing segments).
Head: rounded triangle (corner radius 0.08c) with the same 5 passes; tail: rounded cap with a small darker "nock" ring (0.1c) — like a real arrow's back. (`c` = cell size.)

**Board tray:** recessed felt surface in the chapter's tray colour with subtle fabric noise, inner shadow along top/left edges, 6 dp wooden rim. Grid lines (when on) are stitched-looking dotted lines at 10% opacity.

**Mechanic objects** follow §2 materials: gate = lacquered wooden arch with brass key-hole badge; key arrow = brass key fob on the tail; frozen = crystal ice block with internal facets + white counter sticker; rotator = brass gear ring that turns; portal = ceramic ring with a swirling inner shader; chain = small brass links.

## 9. Microcopy
Warm, brief, never shouty. Max 6 words for captions. Examples: "Hold to peek the path." · "Nice flow!" · "So close — try again?" · "The garden is waking up." No "Awesome!!!", no "Level Failed".

## 10. Assets: human-made, not AI-made
- **Shipped art must be made or finished by humans**: chapter dioramas (illustrator or 3D artist), icon set (3D artist), logo (designer). AI image tools may be used only for internal mood boards — never shipped, never as final placeholders.
- Claude Code **must not** generate or download images to use as final art. It builds placeholders that are **obviously placeholders**: neutral grey gradient with a small "PLACEHOLDER · ch1/bg_mid" label in the debug build only, and in release builds a plain token-coloured gradient.
- If a Figma file exists and the Figma MCP is connected in Claude Code, implement screens from the Figma frames (match spacing/colours to tokens; flag any mismatch instead of guessing).

## 11. Design review gate (mandatory after every UI phase)

Claude Code must:
1. Add every new component/screen to the debug **Design Gallery** route (`/design-gallery`) with all states.
2. Produce screenshots via golden tests or `integration_test` on **two sizes**: iPhone SE (375×667) and iPhone 15 Pro Max (430×932), plus one Android tablet landscape for game screens. Save under `docs/screenshots/<phase>/`.
3. Self-review every screenshot against §1 (B1–B16) and §2–§8, and write a table in `docs/PROGRESS.md`: screen · issues found · fixed (Y/N).
4. **Stop and ask the human** to review the screenshots before starting the next phase.

### 11.1 Automated checks (Phase 3)
`test/core/ui/design_rules_test.dart` scans the sources for B1 (Material/Cupertino), B3 (blur/glass), B4 (Material icons, emoji), B5 (fonts), B7 (ad-hoc shadows), B8 (ad-hoc radii), B10, B16 and D2 (literal colours / durations / EdgeInsets in components and features). `components_golden_test.dart` holds 172 goldens (every state at 1x and 3x, D6); `design_gallery_screenshots_test.dart` writes the review screenshots to `docs/screenshots/phase3/`. Goldens compare with a 1% pixel tolerance (`test/flutter_test_config.dart`) because anti-aliasing differs between Windows, macOS and Linux.

## 12. Design checklist (copy into each UI PR)
- [ ] Only tokens used (no literal colours/sizes/durations)
- [ ] Light from top-left everywhere; shadows lean down-right
- [ ] Every tappable thing has face + lip/bevel + highlight + shadow and a pressed state
- [ ] One primary CTA per screen
- [ ] No banned item B1–B16
- [ ] Text uses `TBText` styles; sticker style on titles/counters
- [ ] Reduce Motion path checked
- [ ] Screenshots at 2 phone sizes reviewed
