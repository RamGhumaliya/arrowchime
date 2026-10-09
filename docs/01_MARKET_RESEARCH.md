# 01 — Market Research: Arrow "Tap-Away / Escape" Puzzles

_Research date: October 2026. Figures are third-party estimates; verify before using in a pitch._

## 1. What the genre is

A grid holds many arrows. Each arrow points in one direction. Tapping an arrow makes it slide (or snake) out of the board **only if the straight path from its head to the board edge is empty**. Goal: clear every arrow. Modern versions use long "snake" arrows whose bodies wind across the grid, so the board looks like a knot that you untangle one tap at a time.

The genre descends from car "Traffic Escape" / "Parking Jam" games. The breakout title stripped the 3D cars away and kept only abstract arrows.

## 2. The category leader — *Arrows – Puzzle Escape* (Lessmore / Miniclip)

| Signal | Data |
|---|---|
| Launch | July 2025 (Android), iOS shortly after |
| Scale | 100M+ Google Play installs; ~2.1M Play reviews; App Store 4.7★ from ~13K ratings |
| Early growth | ~20M downloads in its first 3 months; reported ~4M DAU and ~$250K/day ad revenue by Jan 2026 (Gamigion) |
| Chart peak | #4 in US App Store Puzzle |
| Revenue est. | $1M+/month (AppGoblin; mix estimates vary) |
| Recent trend | US downloads down ~35% period-over-period in 2026 — the clone wave is eroding it (AdMapix) |
| Core loop | Levels + a daily challenge. **No move limit.** 3 hearts — tapping a blocked arrow costs a heart; lose all 3 and you fail. A "grid" hint button overlays the arrow routes. |
| Monetization | Interstitial ads between levels; Remove Ads priced **$9.99–$16.99**, plus 1/3/6-month ad-free subscriptions; coin packs; hints |
| UA insight | One long-running **playable ad** carries most of their user acquisition |

**Why it won:** zero learning curve, very cheap to render (runs on any phone), each tap gives instant visual + audio payoff, and the abstract look appeals to all ages including older players.

## 3. The clone wave (2025–2026)

Dozens of titles copy the loop: *Arrow Out*, *Arrows Flow*, *Arrow Madness* (neon theme), *ArrowRush*, *Way Escape*, *Arrowscapes*, *Twisted Arrows*, *Arrow Cube Escape* (3D cube faces), *Arrow Escape – Flow Logic* (curved paths). Differentiators they have tried:

| Twist | Seen in |
|---|---|
| Curved/flowing paths instead of straight lines | Arrow Escape – Flow Logic |
| 3D cube you rotate, arrows on every face | Arrow Cube Escape |
| Splitter arrows, switcher arrows (flip neighbours), rotator tiles, one-way gates | Arrow – Escape (2026) |
| Neon art style | Arrow Madness |
| Daily challenge, streaks, monthly trophies | ArrowRush, Arrow – Escape |
| Difficulty tiers (Normal → Nightmare) | Arrow – Escape |

**Gap:** almost every clone is visually minimal and flat — many look template- or AI-made. Nobody owns "premium, tactile, world-building" presentation, and nobody has made sound a core feature.

## 4. What players complain about (review mining)

These are the openings for a better product:

1. **Ads after every level**, ads on restart, unskippable ads, ads killing background music. Strongest and most repeated complaint.
2. **Remove-ads price feels too high** ($10–17).
3. **Can't zoom / can't see the whole dense board**; requests for manual zoom and fully zooming out.
4. **Touch accuracy** — mis-taps on dense grids, wrong arrow selected, arrows that "look free but aren't".
5. **Grid overlay UX** — players want the route grid to stay on; gesture changes to toggle it caused backlash.
6. **No path preview** — players want to see where an arrow will go before committing (noted as a minus in the Arrow Cube Escape review).
7. **Difficulty swings** — some find levels too easy, others too hard; no player choice.
8. **Sameness** — boards all rectangles/squares; nothing to look forward to.

What players love: no timer, relaxing pace, "aha" moments, accessible to older players, satisfying board-clear feeling.

## 5. Important design insight (from analysing the mechanic)

In the **pure** version of the game, removing an arrow only ever frees space. So **no legal move can make the level unsolvable**. The only real challenge is _spotting which arrows are free_ — which is why the leader uses hearts to punish mis-taps.

That makes the base game shallow for skilled players. Real planning only appears when **order matters** — mechanics where a move changes the board for others (rotators, switches, gates, colour locks, portals). Our design (see `03_GAME_DESIGN.md`) introduces those gradually, and the level generator must use a solver to verify them.

## 6. Platform & tech landscape (Oct 2026)

| Item | Status |
|---|---|
| Flutter stable | **3.47.x** (Aug 2026, Dart 3.13). Material & Cupertino now ship as standalone packages. Next stable (3.50) targeted Nov 2026. |
| Flame engine | **1.38.x** stable (2.0 in pre-release — do not use yet). |
| Audio | **flutter_soloud 5.1.x** — low-latency game audio, mixing buses, scheduled playback. Ships agent skill files: `dart run flutter_soloud:skills`. |
| Ads | `google_mobile_ads` + Google UMP consent. |
| Platforms for v1 | **Android + iOS only.** Web deferred; playable ads can be built separately in HTML5. |

## 7. Positioning statement

> **Arrowchime** is the arrow-escape puzzle that _sounds like music and looks like a hand-made toy world_. Every arrow you free rings a chime; every level you clear restores a piece of a living diorama. Premium tactile 3D look, fair ads, real zoom, path preview, and new mechanics that make order matter.

## Sources
- Gamigion — Arrows Puzzle Escape scale (4M DAU, $250K/day ad revenue): https://www.gamigion.com/?p=28396
- AdMapix — Arrows ad strategy, 2026 download decline: https://www.admapix.com/blog/ad-intelligence/arrows-puzzle-escape-ad-strategy-2026
- App Store listing & IAP prices: https://apps.apple.com/us/app/-/id6748397500
- AppGoblin estimates: https://www.appgoblin.info/apps/com.ecffri.arrows
- Review analysis: https://marlvel.ai/apps/arrows-puzzle-escape/reviews , https://grand-screen.com/games/arrows-puzzle-escape/reviews/
- Shacknews — Arrow Cube Escape review: https://www.shacknews.com/article/149355/arrow-cube-escape-review-score
- Competitor listings: Arrow – Escape (https://apps.apple.com/mx/app/arrow-escape/id6778841222), Arrows Flow (https://mwm.ai/apps/arrows-flow-escape-puzzle/6761592557), Arrow Escape – Flow Logic (https://mwm.ai/de/apps/arrow-escape-flow-logic/6758941921)
- Flame: https://pub.dev/packages/flame · flutter_soloud: https://pub.dev/packages/flutter_soloud · Flutter versions: https://docs.shorebird.dev/getting-started/flutter-version.md
