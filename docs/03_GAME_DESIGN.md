# 03 — Game Design Document (GDD)

This document is the source of truth for **rules**. If code and this doc disagree, this doc wins (update it first if the design changes).

---

## 1. Core loop

```
Open app → Home (living scene + Play button)
   → Level (tap arrows out, melody builds)
      → Clear: stars + coins + XP + scene fragment restored → next level (1 tap)
      → Fail (0 hearts): Retry free / +1 heart (rewarded ad or coins)
   → Daily Knot, quests, shop, collection between levels
```

Session target: 3–6 minutes, 4–8 levels.

## 2. Board & arrow rules (pure base game)

### 2.1 Board
- Grid of `width × height` cells (4–24 each side).
- Optional **mask**: cells marked void are not part of the board (allows heart, star, diamond, letter shapes). Void cells are empty space — arrows fly over them.
- Coordinates: `(x, y)`, origin top-left, x → right, y → down.

### 2.2 Arrow
- An arrow is an ordered list of **adjacent** cells `body[0..n-1]`, from **tail** (`body[0]`) to **head** (`body[n-1]`). Length 1–40.
- `dir` ∈ {up, down, left, right} — the head's facing.
- Rule: if `n ≥ 2`, `dir` must not point back into `body[n-2]`.
- No two arrows share a cell. An arrow's body never overlaps itself.

### 2.3 Exit ray & freedom
- **Exit ray** = every cell from `head + dir` stepping in `dir` until leaving the board bounds.
- An arrow is **free** when no cell of its exit ray is occupied by another arrow, a closed gate, or any blocking object.
- A level must never contain an arrow whose exit ray crosses **its own body** (generator rule).

### 2.4 Tapping
| Situation | Result |
|---|---|
| Tap a free arrow | Arrow snakes out: the head travels along the ray, the body follows its own path cell-by-cell (like Snake), then off-screen. Arrow is removed from the logical board **immediately** on tap (animation is cosmetic). Note plays. |
| Tap a blocked arrow | Arrow lurches forward until it touches the first blocker, recoils back. The blocker flashes. **−1 heart.** Error sound + haptic. |
| Tap during another arrow's exit animation | Allowed (input is never locked); multiple arrows can be in flight. |
| Tap on empty cell | Nothing. |

### 2.5 Win / lose
- **Win:** zero arrows left.
- **Lose:** hearts reach 0. Start each level with **3 hearts** (remote-config).
- Stars: 3 hearts left = ★★★, 2 = ★★, 1 = ★.

### 2.6 Key property (important for engineers)
In the pure base game, removing an arrow can only free space, so **the base game can never become unsolvable**. Difficulty comes from visual reading. Mechanics in §5 break this property on purpose; any level containing them must be verified by the solver (`04_LEVEL_SYSTEM.md`).

## 3. Player tools

| Tool | Behaviour | Cost |
|---|---|---|
| **Peek** (long-press 250 ms on an arrow) | Draws the exit route as a dotted glowing line to the edge (through portals if any). Does **not** say free/blocked (remote-config flag `peek_shows_verdict`, default false). Release to hide. | Free, unlimited |
| **Route Grid** toggle | Shows faint grid lines + each arrow's ray as a thin line. Stays on until toggled off (persisted setting). | Free |
| **Hint** | Pulses one arrow that is free AND on a valid solution path. | L1–19: free. From L20: 1 free per level, then 50 coins or rewarded ad |
| **Undo** | Restores the last removed arrow (does not restore hearts). | 2 free per level, then 30 coins |
| **+1 Heart** | Shown on fail sheet. | Rewarded ad (max 2 per level) or 100 coins |
| **Zoom/Pan** | Pinch zoom 1×–4×, two-finger or one-finger drag pan when zoomed, double-tap = fit board. | Free |
| **Tap Assist** | If a tap lands on a cell boundary / within 30% of a cell edge, pick the arrow whose body cell centre is nearest; on dense boards (cell < 28 dp on screen) enlarge hit radius and prefer head cells. | Always on |

**Relaxed Mode** (settings): hearts are not lost. Stars are capped at ★★ in Relaxed mode. Daily Knot is always Classic.

## 4. Feedback & "juice" spec

Juice is a requirement, not polish. Every item below must exist in MVP.

| Event | Visual | Audio | Haptic |
|---|---|---|---|
| Touch down on arrow | Arrow scales 1.06×, brightens 10% (60 ms) | — | selection click |
| Free arrow released | Head shoots along ray with ease-in (speed scales with length, 250–450 ms total), particle trail in arrow colour, cells it vacated briefly glow | Next melody note (see Audio doc) | light impact |
| Blocked tap | Lurch 0.35 cell toward blocker, elastic recoil 220 ms; blocker flashes red outline twice; heart icon cracks and drops | Soft dissonant "thunk" | medium impact ×2 |
| Flow streak (≥3 correct taps, each within 1.5 s of previous, no error) | Flow meter fills; ×2 → ×5 badge pops; board edge glows warmer | Harmony layer added per Flow tier | — |
| Last 3 arrows | Background music ducks 30%, subtle zoom-in 3% | Rising shimmer | — |
| Board clear | Remaining notes cascade into a 2-bar flourish; confetti burst in chapter palette; board folds into a glowing **fragment** that flies to the scene thumbnail | Flourish + chime | success notification |
| Star award | Stars stamp in one by one (180 ms apart) with bounce | Ascending ding per star | light ×n |
| Fail | Board desaturates, hearts shatter; fail sheet slides up | Low soft chord (never harsh) | heavy impact |
| Coin gain | Coins fly from source to counter, counter ticks up | Coin clinks (pitched up per coin) | — |

Rules: never block input for more than 300 ms except full-screen transitions; all animations respect "Reduce motion" (fade instead of fly, no shake/confetti).

## 5. Mechanics (introduced across chapters)

Each mechanic is introduced with a 1-screen interactive tutorial level (no text wall; a hand cursor + 6-word caption max).

| Mechanic | Rule | Chapter / level of intro | Breaks monotonicity? |
|---|---|---|---|
| **Snake arrows** | Long winding bodies (base rule) | Ch1 L1 | — |
| **Shaped boards** | Masks: heart, ring, star, letters | Ch1 L12 | No |
| **Rotator** ↻ | Single-cell arrow with ↻ badge. Each time **any other** arrow is removed, every rotator turns 90° clockwise (animated 150 ms). | Ch2 L1 | **Yes** |
| **Color Gate + Key** | A gate occupies a cell and blocks rays while closed. A **key arrow** of the same colour (has a key icon) opens all gates of that colour when it exits. Colours also carry a **symbol** (●▲■◆) for colour-blind play. | Ch3 L1 | No (still monotone) but forces order |
| **Frozen** ❄n | Arrow encased in ice with counter `n`. Counter decreases by 1 each time any other arrow is removed. Can't be tapped until counter hits 0 (tap = gentle shake, **no heart lost**). | Ch4 L1 | No |
| **Linked pair** 🔗 | Two arrows joined by a chain. Tapping either moves **both**; both must be free or it counts as a blocked tap. | Ch5 L1 | No |
| **Portal** ◎A/◎B | Paired portal cells. A ray entering one continues out of the other in the same direction. Arrows physically travel through. Portals never hold arrows. | Ch5 L20 | No |
| **Switcher** ⇄ (v1.1) | When removed, flips all orthogonally adjacent single-cell arrows 180°. | Ch6 | **Yes** |
| **One-way gate** (v1.1) | Cell that lets rays pass only in its marked direction. | Ch6 | No |
| **Splitter** (v1.1) | Y-headed arrow; free only if **both** perpendicular rays are clear; exits as two halves. | Ch7 | No |

Mechanic budget per level: at most 2 mechanic types in Ch2–4 levels, at most 3 in Ch5+. Bosses may use all unlocked mechanics.

## 6. Content structure — the 5 launch chapters

_Palette column = mood only. Exact colours, tray and arrow sets: `06_ART_DIRECTION.md` §4. Visual treatment: `10_DESIGN_SYSTEM.md`._

Each chapter = a **living scene** (illustrated, layered, parallax) that starts grey/misty. 60 levels per chapter; each clear restores one of 60 scene fragments (lanterns light, water flows, birds appear…). Level 60 = boss knot; on clear the whole scene animates fully and a short musical theme plays.

| # | Chapter | Scene | Palette | Instrument / scale | New mechanic |
|---|---|---|---|---|---|
| 1 | **Misty Garden** | Japanese-style zen garden: koi pond, bridge, cherry tree | Sage, blush pink, cream | Kalimba · C major pentatonic | Snake arrows, shaped boards |
| 2 | **Clockwork Town** | Brass rooftops, gears, a clocktower | Brass, teal, warm cream | Music box · G major | Rotator |
| 3 | **Lantern Bazaar** | Night market with lanterns, rangoli patterns, spice stalls | Saffron, magenta, indigo | Plucked strings (santoor-like) · D dorian | Color Gate + Key |
| 4 | **Frost Peaks** | Snowy mountains, aurora, cabin with warm window | Ice blue, violet, gold window light | Celesta / glass · A minor pentatonic | Frozen |
| 5 | **Starlight Observatory** | Domed observatory, nebula, orbiting planets | Deep navy, cyan, magenta stars | Harp + soft synth pad · E lydian | Linked pair, Portal |

### Difficulty curve inside a chapter
- Sawtooth: difficulty rises over 4 levels, 5th level is a **breather** (smaller, satisfying).
- Every 10th level: **Knot level** (bigger board, special shape, +50% coins).
- Level 60: **Boss Knot** (largest board of chapter, all mechanics so far).
- Board size grows roughly 6×6 (Ch1 L1–5) → 22×22 (Ch5 boss).
- Target difficulty score per level is defined in `04_LEVEL_SYSTEM.md`.

### Onboarding (Ch1 L1–10)
| Level | Teaches | Board |
|---|---|---|
| 1 | Tap an arrow → it flies out | 3 straight arrows, all free, hand cursor |
| 2 | Some arrows are blocked | 4 arrows, 1 blocked |
| 3 | Hearts (caption: "Blocked taps cost a heart") | 6 arrows |
| 4 | Snake arrows (body follows head) | 5 arrows with bends |
| 5 | Peek (hand shows long-press) | 8 arrows |
| 6–7 | Practice | 10–12 arrows |
| 8 | Zoom & pan (board slightly larger than screen) | 14×14 |
| 9 | Practice | |
| 10 | First Knot level + first scene "wow" moment | heart shape |

Never more than one new idea per level. No text wall anywhere. All captions ≤ 6 words.

## 7. Gamification & meta systems

| System | Design |
|---|---|
| **Stars** | Per level (1–3). Chapter star totals unlock bonus "Constellation" cosmetics at 120 / 150 / 180 stars. |
| **XP & Player Level** | XP = 10 × stars + 5 per Flow tier reached. Level-up every ~8 levels early, slowing later; each level-up gives coins + a cosmetic every 5 levels. |
| **Coins** (soft currency) | Earned by clears, quests, daily, achievements. Spent on hints, undo, hearts, cosmetics. |
| **Gems** (premium, optional v1.1) | Only if season pass ships; MVP uses coins only. |
| **Streak** | Play ≥1 level per day. Streak flame grows (visual tiers at 3/7/30/100 days). 1 free **Streak Freeze** per week; more for coins. |
| **Daily Knot** | One seeded puzzle per UTC day, same for everyone. Result card: `Arrowchime Daily #142 ❤️❤️🖤 ⚡x4 ⏱1:52` + emoji mini-board. Calendar shows past 30 days (replay missed ones for coins). |
| **Daily Quests** | 3 per day from a pool: "Clear 5 levels", "Reach Flow ×3", "Free 100 arrows", "Get 3 perfect clears". Reward coins + quest chest. |
| **Achievements** | ~30: "First Note", "Untangler (1,000 arrows)", "Perfect Pitch (10 ★★★ in a row)", "Maestro (Flow ×5)", "Night Owl (Daily at 2am)", one per chapter completion… Synced to Game Center/Play Games in v1.1. |
| **Collection / Cosmetics** | Arrow skins (Neon, Bamboo, Brass, Crystal, Paper-craft, Candy, Galaxy), trails (sparkle, petals, snow, ribbons), board themes, **instruments** (swap the note voice: piano, marimba, 8-bit, choir). Only cosmetic — never gameplay power. |
| **Piggy Bank** (v1.1) | Accumulates coins from clears; break open with IAP. |
| **Lucky Wheel** | ❌ Not included — avoid gambling feel. |
| **Win streak bonus** | 3 consecutive first-try clears → next level starts with a "Golden Hint" (free hint). |

## 8. Screens

| Screen | Contents |
|---|---|
| Splash | 3D logo mark drops onto a ceramic plate with a chime; preload chapter 1 audio |
| **Home** | Full-bleed animated chapter scene; big **Play L{n}** button; Daily Knot card; streak flame; coins; quests; shop; collection; settings. Everything ≤ 2 taps from here. |
| Chapter Map | Horizontal scroll of chapters; each shows restoration %; locked chapters show silhouette |
| **Level** | Board centred; top bar: back, level #, hearts, coins; bottom bar: Undo, Hint, Grid toggle, Fit; Flow meter at top edge |
| Win | Stars, coins, XP bar, fragment animation, **Next** (primary), Replay (secondary) |
| Fail sheet | "Out of hearts" — Retry (primary, free), +1 heart (ad / coins) |
| Daily Knot | Today's puzzle, timer shown (optional to show), calendar, share button |
| Shop | Remove Ads, starter bundle, coin packs, cosmetics |
| Collection | Tabs: Arrows / Trails / Boards / Instruments; preview applies live |
| Achievements & Stats | Total arrows freed, perfect clears, best Flow, play time |
| Settings | Audio sliders, haptics, colour-blind palette, reduce motion, left-handed, Relaxed mode, language, account link, privacy, restore purchases, credits |

## 9. Layout & responsive rules
- Portrait on phones. Tablets: portrait and landscape (landscape: board left 70%, HUD shelf right).
- Board fit: board scaled so the larger dimension fills available area minus 16 dp margin; if resulting cell size < 24 dp, start at fit and let player zoom.
- Safe areas and notches respected; bottom shelf clears the home indicator.
- **Visual look of every screen and component is defined in `10_DESIGN_SYSTEM.md`** (layouts in §7). This GDD defines behaviour only.
