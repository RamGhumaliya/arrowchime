# 06 — Brand, Name, World Art & Asset Pipeline

UI components, tokens and the strict "no AI look" rules live in **`10_DESIGN_SYSTEM.md`**. This file covers the name, logo, chapter worlds and how final art gets made.

## 1. Name — **Arrowchime**

Store title: **`Arrowchime: Arrow Escape Puzzle`** · Package id: `com.webazonic.arrowchime`

| Criterion | Why Arrowchime passes |
|---|---|
| Unique | Web search (Oct 2026) found no app, game or brand named "Arrowchime" or "Arrow Chime" — only unrelated wind-chime products that happen to use the two words |
| Domain | `arrowchime.com` returned no record from the .com registry (appears unregistered) |
| SEO / ASO | Starts with **"Arrow"** — the #1 search term in this genre — so it matches "arrow puzzle", "arrows escape", "arrow game" searches; the subtitle adds "escape" + "puzzle" |
| Easy | Two everyday English words, 10 letters, one obvious spelling, easy to say in any accent |
| Meaningful | "Chime" = the satisfying musical sound each freed arrow makes → tells the unique hook (Arrow Symphony) and the calm mood |

**Before you commit (must do):** search the exact name in the App Store and Google Play consoles, check trademark databases (USPTO, EUIPO, India IP office — class 9 & 41), register the domain and social handles (@arrowchime). Search results change daily.

Backups checked at the same time: **Arrowtone** (unique, .com appears free; slight clash with archery "arrow tuning" apps), **Arrowmony** (unique, .com appears free; risk of being misspelled "arrow money"). Rejected: *Arrow Melody* (already a web game), *Arrowbloom* (.com registered 2025), *Arrowtune* (archery tuner products), *Arrowsong* (an existing archery VR game).

## 2. Logo & icon

Files: `assets/branding/app_icon.svg` (+ `app_icon_1024.png`) and `assets/branding/logo_concepts.svg` (+ `.png`). These are **direction sketches** for a human designer to finalise — not final production art.

- **Mark — "Chime Arrow":** a glossy enamel arrow that curls into a loop and passes through a little brass bell, on a deep night-teal ceramic tile lit from the top-left. Arrow + chime in one object.
- **Wordmark:** "Arrowchime" in a rounded heavy display face (Fredoka 700 as reference) with sticker treatment (ink stroke + hard drop), the "i" dot replaced by a tiny bell.
- Icon rules: readable at 48 px; no text on the icon; one light source top-left; strong silhouette; ≤ 3 hues (teal tile, tangerine arrow, butter/brass bell).
- Exports: iOS 1024 master; Android adaptive icon (foreground in 264 px safe zone of 432 px + separate background layer); Play Store 512; notification icon (single colour).

## 3. Visual pillars
1. **Toybox 3D** — every object looks physical: ceramic, enamel, lacquered wood, brass, crystal (recipes in `10` §2).
2. **A world worth restoring** — each chapter is a miniature diorama that wakes up as you play.
3. **Readability first** — arrows always pop against the tray; colour + symbol for every colour mechanic.
4. **Calm luxury** — warm light, rich but not neon colours, generous spacing.

## 4. Chapter worlds (backgrounds, tray, arrow sets)

| # | Chapter | Diorama | Sky / background | Tray felt | Arrow colour set (6) |
|---|---|---|---|---|---|
| 1 | Misty Garden | Zen garden, koi pond, stone bridge, cherry tree | Dawn peach → soft sage | #E9E2D0 | coral, sage, sky, butter, plum, teal |
| 2 | Clockwork Town | Brass rooftops, gears, clocktower | Teal dusk → cream | #E6D6BC | brass, teal, brick, cream, navy, mint |
| 3 | Lantern Bazaar | Night market, paper lanterns, rangoli, marigold garlands | Indigo → magenta glow | #2B2547 (dark tray, light arrows) | saffron, marigold, rose, turquoise, ivory, lime |
| 4 | Frost Peaks | Snowy peaks, aurora, cabin with warm window | Ice blue → violet aurora | #DCE7F2 | ice blue, berry, gold, pine, lilac, slate |
| 5 | Starlight Observatory | Domed observatory, brass telescope, nebula | Navy → deep teal nebula | #1C2440 (dark tray) | cyan, magenta, gold, white-pearl, coral, lime |

Each chapter diorama: 4–6 parallax layers (sky, far, mid, near, foreground, FX) at 2048×2732 portrait master plus a 2732×2048 landscape crop for tablets. Restoration = 60 fragments; each reveals the coloured, lit version of an area or switches on an animated element (lanterns light, waterfall flows, birds land). Grey state is produced in code (saturation 0.1, brightness −10%) so fragments align perfectly.

Ambient motion: drifting petals/snow/dust, slow cloud drift, gentle sway — paused under Reduce Motion.

## 5. Typography
Fredoka (display, 600/700) and Nunito (UI, 600/700), both OFL, bundled locally. Styles and sticker treatment in `10` §4.

## 6. Arrow skins (cosmetics)
Every skin follows the 5-pass tube structure in `10` §8 with different materials:
Enamel Candy (default) · Bamboo (lacquered wood grain, Ch1 reward) · Brass (Ch2) · Lantern Silk (fabric sheen, Ch3) · Crystal (glassy, Ch4) · Galaxy (shader, Ch5) · Neon Tube (shop) · Paper-craft (folded paper, shop) · Pixel (8-bit, shop).

## 7. Mascot (optional, v1.1)
"Pip" — a tiny brass bell with eyes that rings when you clear a board and peeks from the HUD for tutorials. Rive-animated. Must be designed by a human illustrator.

## 8. Asset pipeline — human-made
| Asset | Who makes it | Tool | Deliverable |
|---|---|---|---|
| Logo + icon | Brand/UI designer | Figma / Illustrator | SVG + PNG exports, icon layers |
| 24 UI icons (3D) | 3D artist | Blender / Spline / C4D | 256 px WebP @1x/2x/3x, consistent material & top-left light |
| 5 chapter dioramas | 3D artist (stylised low-poly/clay renders) **or** illustrator (painted 2.5D) | Blender + Photoshop / Procreate | Layered PSD → WebP layers per `ASSET_MANIFEST.md` |
| UI screens | UI designer | Figma (tokens matching `10` §3) | Frames for every screen in `10` §7 |
| Mechanic sprites | 3D artist / UI designer | Blender / Figma | SVG or WebP |
| Store screenshots & preview video | Designer + you | Figma, screen capture | 8 screenshots + 15–30 s video per platform |

Rules:
- AI image generators may be used **only for private mood boards** to brief artists. Nothing AI-generated ships.
- Claude Code builds clearly-marked placeholders only (`10` §10) and implements from the designer's Figma when available.
- Where to hire: Fiverr Pro / Upwork (search "mobile game UI", "stylised 3D game props"), ArtStation, Behance, or local Gujarat/Ahmedabad game-art studios. Brief them with this file + `10_DESIGN_SYSTEM.md` + reference boards.
- Keep `assets/ART_LICENSES.md`: file → creator → contract/licence (full commercial rights, work-for-hire).

## 9. Store assets
8 screenshots per platform: (1) "Every arrow rings a chime" with a dense glossy board mid-clear; (2) world restoration before/after; (3) Flow ×5 moment; (4) mechanics montage; (5) Daily Knot share card; (6) cosmetics shelf; (7) "No timers. No pressure."; (8) "Fair ads. Real zoom." Feature graphic (Play) 1024×500. App preview video 15–30 s with the melody audible — the same edit doubles as the short-form social video.
