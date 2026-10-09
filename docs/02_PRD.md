# 02 — Product Requirements Document (PRD)

| | |
|---|---|
| Product | **Arrowchime** (working title — see naming options in `06_ART_DIRECTION.md`) |
| Owner | Ram / Webazonic |
| Platforms | **Android & iOS** (phones + tablets), Flutter single codebase. Web is deferred (see §4.3). |
| Genre | Casual logic puzzle — arrow escape / tap-away |
| Version | PRD v1.0 — Oct 2026 |

---

## 1. Vision

A premium-feeling arrow-escape puzzle where **every freed arrow plays a musical note** and **every cleared level restores part of a living world**. Simple to learn in 5 seconds, beautiful enough to screenshot, fair enough that players never feel milked.

## 2. Goals & success metrics

| Goal | Metric | Target (soft launch) |
|---|---|---|
| Instant fun | Tutorial completion | ≥ 90% |
| Retention | D1 / D7 / D30 | ≥ 45% / 18% / 7% |
| Session depth | Levels per session | ≥ 6 |
| Habit | Daily Knot participation (of DAU) | ≥ 30% |
| Quality | Store rating | ≥ 4.6★ |
| Performance | Frame rate on a 2021 mid-range Android | 60 fps steady, < 1% jank frames |
| Monetization | ARPDAU (ads + IAP) | ≥ $0.06 (tune after soft launch) |
| Virality | Daily Knot share rate | ≥ 5% of completers |

## 3. Target players

1. **Casual brain-trainers (30–65)** — want calm, no timers, readable visuals, big tap targets. Large share of this genre.
2. **Commute snackers (18–35)** — 3–5 minute sessions, love juicy feedback, collect cosmetics.
3. **Puzzle enthusiasts** — want hard modes, mechanics where order matters, daily challenge leaderboards.

## 4. Scope

### 4.1 MVP (v1.0 launch) — MUST
- Core arrow-escape gameplay with snake-style arrows (see GDD).
- **Path preview ("Peek"):** press-and-hold an arrow to see its exit route as a glowing line to the edge. By default it does not say free/blocked — reading the board stays the player's job (remote-config flag `peek_shows_verdict` lets us A/B test a green/red verdict).
- **Pinch zoom + pan + double-tap to fit**; tap-target assist on dense boards.
- 3 hearts per level; hint, undo, and "route grid" toggle that stays on if the player wants.
- **Arrow Symphony** audio: each freed arrow plays the next note of the chapter melody.
- **World Restoration meta:** 5 chapters × 60 levels = **300 handcrafted-quality generated levels** at launch; each level clears a fragment of the chapter scene.
- New mechanics introduced across chapters: Rotator, Color Gate + Key, Frozen arrow, Linked pair, Portal (see GDD §5).
- **Daily Knot** — one seeded puzzle per day for everyone, Wordle-style shareable result card.
- Stars (3/2/1 by hearts left), XP + player level, coins, streak with streak-freeze.
- Cosmetics shop: arrow skins, trails, board themes, note instruments.
- Achievements (≈ 30).
- Settings: music/SFX/haptics volume, colour-blind palettes, left-handed layout, reduce motion, language.
- Offline play for all main levels.
- Local save + optional cloud save (Firebase anonymous auth → link Google / Apple).
- Ads (mobile): rewarded video + **fair** interstitial policy (see `08_ECONOMY_MONETIZATION.md`). IAP: Remove Ads, coin packs, starter bundle.
- Analytics, crash reporting, remote config.
- **Hand-crafted "Toybox 3D" UI** built from a custom component library (see `10_DESIGN_SYSTEM.md`) — no default Material look anywhere a player can see.
- Phones portrait; tablets portrait + landscape.

### 4.2 v1.1 — SHOULD
- Weekly Event ("Tangle Tower" — 10 escalating floors, leaderboard).
- Season pass ("Fletch Pass", 30 tiers, free + premium track).
- Game Center / Google Play Games achievements & leaderboards.
- 2 more chapters, Splitter + One-way Gate mechanics.
- Localization: Hindi, Spanish, Portuguese (BR), German, Japanese, Korean, French.

### 4.3 v2 — COULD
- **Level Editor + share codes**.
- **Web version** (instant-play + playable ad) — deferred; the architecture keeps services behind interfaces so a web target can be added later.
- Async **Duel**: two players get the same seed, compare hearts/time.
- Zen Mode: endless generated boards, no hearts.
- "Compose" mode: the player's clear order becomes a short melody they can save/share.

### 4.4 Out of scope
- Real-time multiplayer, chat, user-generated text, gambling mechanics, loot boxes with paid randomness.

## 5. Unique selling points (what makes it different)

| # | USP | Why it matters (from research) |
|---|---|---|
| 1 | **Arrow Symphony** — clearing a level plays a melody; fast correct streaks build harmony layers | No competitor uses sound as a core hook; makes every tap rewarding; great for short-form video |
| 2 | **World Restoration** — a living illustrated scene un-greys as you clear levels | Gives a reason to continue; competitors are abstract and identical |
| 3 | **Path Preview + real zoom** | Directly fixes top 2 UX complaints |
| 4 | **Order-matters mechanics** | Base genre has no real planning; this adds depth for enthusiasts |
| 5 | **Fair ads** — never on restart, never mid-level, capped per hour, cheap Remove Ads | Fixes the #1 complaint across the whole genre |
| 6 | **Daily Knot share card** | Free viral loop (emoji grid like Wordle) |
| 7 | **Hand-crafted Toybox 3D look** — tactile ceramic buttons, glossy enamel arrows, diorama worlds | The whole genre is flat and minimal; a premium look stands out in store screenshots and ads |

## 6. User stories (MVP)

- As a new player, I clear my first board within 10 seconds of opening the app, with no text wall.
- As a player, I can hold an arrow to see if it's free, so I don't lose hearts to visual confusion.
- As a player on a dense board, I can zoom and pan smoothly and the game helps me hit the arrow I meant.
- As a player, I hear a melody build as I clear, and a full musical flourish when the board empties.
- As a player, I see my world scene restore piece by piece, and I'm excited to unlock the next chapter.
- As a returning player, I see today's Daily Knot, my streak, and a reward waiting.
- As a player who fails, I can retry instantly — no ad before the retry.
- As a player, I can buy Remove Ads once at a fair price and never see forced ads again.
- As a player, every button and arrow feels like a real object I can press, and the game looks premium in every screen.
- As a colour-blind player, I can switch palettes so color-gate puzzles remain solvable.

## 7. Functional requirements (summary — details live in GDD/Tech docs)

| ID | Requirement |
|---|---|
| F-01 | Board renders arrows on an N×M grid (4×4 up to 24×24), arbitrary masks (non-rectangular shapes). |
| F-02 | Tap on a free arrow → arrow snakes out along its head direction; board updates; note plays. |
| F-03 | Tap on a blocked arrow → arrow bumps toward blocker and recoils; heart lost; blocker flashes. |
| F-04 | Level complete when no arrows remain → celebration, stars, rewards, world fragment restore. |
| F-05 | Level failed when hearts = 0 → offer: Retry (free), or +1 heart (rewarded ad / coins). |
| F-06 | Undo: reverts last removal (limited per level; cost coins after free uses). |
| F-07 | Hint: highlights one currently-free arrow that is part of a valid solution. |
| F-08 | Path preview on long-press; route grid toggle; zoom/pan/fit. |
| F-09 | All levels loaded from JSON packs; Daily Knot generated from date seed (deterministic, same for everyone). |
| F-10 | Every shipped level is verified solvable by the solver in CI. |
| F-11 | Progress, currency, cosmetics persisted locally; synced to cloud when signed in. |
| F-12 | Remote config controls ad frequency, prices, difficulty tuning, event toggles. |

## 8. Non-functional requirements

- 60 fps on mid-range Android (e.g., Snapdragon 6-series 2021), 120 fps capable on ProMotion devices.
- Cold start < 2.5 s; chapters 2–5 art loaded on demand.
- App download size < 80 MB (Android AAB); consider Play Asset Delivery / on-demand resources for later chapters.
- Accessibility: minimum tap target 44 pt (with assist), WCAG AA text contrast, colour-blind modes, reduce-motion, screen-reader labels on all UI (board is described as "N arrows remaining, X free").
- Privacy: no personal data required to play; ATT prompt on iOS only before personalized ads; GDPR/consent via Google UMP.
- Age rating target: Everyone / 4+ (ensure ad content filters set to G).

## 9. Release plan

| Milestone | Content |
|---|---|
| M0 Prototype | Core loop on 10 levels, placeholder art — test fun |
| M1 Vertical slice | Chapter 1 complete with final art, audio, meta |
| M2 Alpha | All 5 chapters, shop, daily, ads/IAP sandbox |
| M3 Soft launch | Android only in 2–3 test markets; tune economy via remote config |
| M4 Global launch | iOS + Android; ASO, playable ad live |

## 10. Risks

| Risk | Mitigation |
|---|---|
| Crowded clone market | Lead with sound + world + premium look + fairness; strong ASO; playable ad |
| Generated levels feel samey | Shape masks, mechanic mix, difficulty curve with "breather" levels, curated level packs reviewed in a debug viewer |
| UI ends up looking generic / AI-made | Strict design system (`10_DESIGN_SYSTEM.md`), component library + golden tests, mandatory design review gate with screenshots, human-made final art |
| Final art/audio not ready in time | Placeholders at exact manifest paths; art contracted in parallel from Phase 3 |
| Performance with many glowing arrows | Batch rendering, cached pictures, shader budget; perf test from week 1 |
