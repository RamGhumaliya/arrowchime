# 04 — Level System: Format, Generator, Solver, Difficulty

Levels are **generated offline by a Dart CLI tool, verified by a solver, curated in a debug viewer, and shipped as JSON packs**. The same generator runs on-device only as a fallback for the Daily Knot and Zen Mode.

---

## 1. Level JSON format (schema v1)

Full JSON Schema: `assets/levels/level.schema.json`. Sample: `assets/levels/sample_levels.json`.

```json
{
  "schema": 1,
  "id": "ch1_l007",
  "chapter": 1,
  "index": 7,
  "width": 8,
  "height": 8,
  "mask": null,
  "hearts": 3,
  "arrows": [
    { "id": 0, "body": [[0,2],[1,2],[2,2]], "dir": "R", "kind": "normal" },
    { "id": 1, "body": [[4,4]], "dir": "U", "kind": "rotator" },
    { "id": 2, "body": [[6,1],[6,2]], "dir": "D", "kind": "key", "color": "amber" },
    { "id": 3, "body": [[1,5],[2,5]], "dir": "R", "kind": "normal", "frozen": 3 },
    { "id": 4, "body": [[3,7]], "dir": "L", "kind": "normal", "link": "L1" },
    { "id": 5, "body": [[5,7]], "dir": "R", "kind": "normal", "link": "L1" }
  ],
  "gates":   [ { "cell": [4,1], "color": "amber" } ],
  "portals": [ { "id": "P1", "a": [1,1], "b": [6,6] } ],
  "meta": {
    "seed": 918273,
    "generatorVersion": "1.0.0",
    "difficulty": 37.4,
    "depth": 5,
    "solution": [2, 0, 3, 1, 4],
    "melody": "ch1_m02"
  }
}
```

Field rules:
- `body` is ordered **tail → head**. Consecutive cells are 4-adjacent. `dir` ∈ `U D L R`.
- `mask`: `null` = full rectangle, otherwise array of `height` strings of length `width`; `'1'` = cell, `'0'` = void.
- `kind` ∈ `normal | rotator | key | switcher | splitter`. `rotator`/`switcher` must have body length 1.
- `frozen`: optional int ≥ 1. `link`: optional group id (exactly 2 arrows per link id).
- `color` (for keys and gates) ∈ `amber | jade | rose | azure` (each has a symbol ● ▲ ■ ◆ for colour-blind mode).
- `meta.solution` = list of arrow ids in a valid removal order (for linked pairs, list the first id only).

Pack files: `assets/levels/ch{N}.json` → `{ "schema": 1, "chapter": N, "levels": [ ... ] }`. Daily: `assets/levels/daily_{yyyy}.json` → `{ "schema": 1, "year": 2027, "levels": { "2027-01-01": { level }, ... } }` (keyed by UTC `yyyy-mm-dd`; a file may cover part of a year; daily level ids are `daily_yyyymmdd`, `chapter` 0, `index` = day of the year). Files are written one level per line so diffs stay readable.

## 2. Engine semantics (pure Dart — must match GDD §2 & §5)

```
isFree(arrow, state):
  cells = rayCells(arrow.head, arrow.dir, state)      // follows portals
  for c in cells:
    if state.occupant(c) != null and occupant != arrow → false
    if state.closedGateAt(c) → false
  if arrow.frozenCounter > 0 → false (special: "frozen" tap, no heart loss)
  if arrow.link != null → also require isFree(partner) ignoring each other
  return true

rayCells(start, dir):
  p = start + dir
  visited portal set to avoid infinite loops
  while inBounds(p):            // void (masked) cells count as in-bounds empty space
    if portalAt(p) and not justTeleported: p = otherEnd(p) ; continue stepping from there in same dir
    yield p ; p += dir

remove(arrow):
  delete arrow (and its linked partner)
  for each other remaining arrow:
     if frozen > 0: frozen -= 1
     if kind == rotator: dir = rotateCW(dir)
  if arrow.kind == key: open all gates of arrow.color
  if arrow.kind == switcher: flip dir of 4-adjacent single-cell arrows
  push to undo stack (full snapshot — boards are small)
```

The engine is **pure, deterministic, synchronous** and has 100% unit-test coverage. Rendering only observes it.

## 3. Generator — reverse construction (guarantees solvability)

### 3.1 Core idea
Build the board in **reverse removal order**. Place arrow #1 on an empty board (anything is free), then arrow #2 so its exit ray avoids arrow #1's cells, and so on. Each new arrow's ray avoids every arrow already placed. Removing arrows in reverse placement order is therefore always valid → **every generated base board is solvable by construction**. Later-placed bodies naturally block earlier arrows' rays, which creates the puzzle.

### 3.2 Algorithm (base game)

```
generate(params, seed):
  rng = Mulberry32(seed)                        // own PRNG — see §6
  board = empty(params.width, params.height, params.mask)
  placed = []
  failures = 0
  while board.fillRatio < params.targetFill and failures < params.maxFailures:
     head = pickHeadCell(rng, board, params)    // empty cell, bias toward centre & existing arrows
     dir  = pickDir(rng, head, board)            // ray from head must be clear of all placed cells
     if dir == null: failures++ ; continue
     L    = sampleLength(rng, params.lenMin, params.lenMax, params.lenBias)
     body = growBodyBackward(rng, head, dir, L, board, params.windiness)
            // random walk from head into empty cells,
            // never into the new arrow's own ray cells,
            // never back into its own body,
            // first step must not be (head + dir)
            // turn probability = windiness (0..1)
     if body.length < params.lenMin: failures++ ; continue
     board.place(Arrow(body, dir)) ; placed.add(...)
  level = finalize(placed)                       // assign ids (shuffle so id order ≠ solution), solution = reverse(placed)
  return level
```

Parameters (`GenParams`): `width, height, mask, targetFill (0.55–0.92), lenMin, lenMax, lenBias, windiness, edgeBias, mechanicMix, maxFailures`.

### 3.3 Adding mechanics
| Mechanic | Generation approach |
|---|---|
| Shaped mask | Pass mask into generator; heads/bodies only on `'1'` cells; rays fly over `'0'` cells. |
| Color gate + key | After base board: choose an empty cell lying on ≥2 arrows' rays → gate. Pick an arrow that is removed **earlier** than all of those arrows in the solution order → make it the key. Re-verify with greedy solver. |
| Frozen | Choose arrows late in the solution order; set `frozen = k` where k ≤ (its position in solution order). Verify. |
| Linked pair | Pick two arrows adjacent in solution order and both free at that state; link them. Verify. |
| Portal | Place portal pair on empty cells, then regenerate rays during construction using portal-aware `rayCells`. |
| Rotator / Switcher (non-monotone) | Generate-and-test: convert 2–6 single-cell arrows, randomize initial directions, run **search solver**; keep if solvable and `trapRatio` in target band; else retry with new seed (max 200 tries). |

## 4. Solvers

### 4.1 Greedy solver (monotone mechanics: base, mask, gates, frozen, linked, portals)
Because freedom never decreases, repeatedly removing **any** free arrow solves the board if it is solvable.
```
waves = 0
while arrows remain:
   F = all free arrows
   if F empty → UNSOLVABLE
   remove all of F (simulate in sequence, re-checking each), waves++
return SOLVABLE, depth = waves
```

### 4.2 Search solver (non-monotone: rotator, switcher)
DFS with memoisation. State key = bitset of remaining arrow ids + 2-bit direction per rotator + gate bits. Move ordering: prefer arrows freed most recently. Limit 200k states; if exceeded mark "too complex" and reject the level. Outputs: `solvable`, one `solution`, `trapRatio` = fraction of legal first-k moves (sampled) that lead to unsolvable states.

### 4.3 Hint
Hint = first arrow in a solution computed from the **current** state (greedy for monotone levels, search for others). Cache per state.

## 5. Difficulty score (0–100)

Computed by `tool/level_gen.dart` and stored in `meta.difficulty`.

```
depth        = greedy waves count
freeRatio    = mean over waves of |free| / |remaining|
minFree      = min |free| across waves
density      = occupied cells / board cells
avgLen       = mean body length
turns        = mean turns per arrow
deception    = share of blocked arrows whose ray has exactly 1 blocking cell
               located ≥ 4 cells away from the head  ("looks free, isn't")
mechanics    = Σ mechanic weights (rotator 6, switcher 6, gate 4, frozen 3, link 3, portal 5)
trapRatio    = from search solver (0 for monotone levels)

score = 4.0*depth + 30*(1 - freeRatio) + 8*(1/max(minFree,1)) + 10*density
      + 0.6*avgLen + 3*turns + 15*deception + mechanics + 25*trapRatio
score = clamp(score * 0.9, 0, 100)
```
Weights are a starting point — the debug Level Lab shows score next to playtest clear-rate so they can be re-tuned.

### Target bands
| Chapter | Board size | Fill | Score band (normal) | Knot (every 10th) | Boss (L60) |
|---|---|---|---|---|---|
| 1 Misty Garden | 6×6 → 12×12 | 0.55–0.75 | 10–35 | +8 | 45 |
| 2 Clockwork Town | 8×8 → 14×14 | 0.65–0.80 | 25–45 | +8 | 55 |
| 3 Lantern Bazaar | 10×10 → 16×16 | 0.70–0.85 | 30–55 | +8 | 65 |
| 4 Frost Peaks | 12×12 → 18×18 | 0.75–0.88 | 40–65 | +8 | 75 |
| 5 Starlight Obs. | 14×14 → 22×22 | 0.78–0.92 | 50–75 | +8 | 88 |

Sawtooth inside a chapter: for level index `i` (1–60): `target = bandMin + (bandMax-bandMin)*(i/60) + saw(i)` where `saw` adds +0, +3, +6, +9 then −8 on every 5th (breather).

## 6. Determinism (Daily Knot)
- **Never use `dart:math` `Random` for level generation** — its algorithm is not guaranteed to stay the same across Dart SDK versions, which would silently change every Daily Knot after an upgrade. Implement `Mulberry32` (32-bit ops, masked with `& 0xFFFFFFFF`) in `lib/core/level/prng.dart` and lock it with golden-output tests (fixed seeds → fixed number sequences and fixed level JSON).
- Daily seed = FNV-1a 32-bit hash of `"arrowchime-daily-v1-" + yyyy-MM-dd` (UTC).
- Primary source: pre-baked `daily_{yyyy}.json` shipped in app + refreshed from Firebase Storage. Fallback: on-device generation from seed (same code path as CLI).

## 7. Tooling

| Command | Purpose |
|---|---|
| `dart run tool/level_gen.dart --chapter 1 --count 60 --seed 1001 --out assets/levels/ch1.json` | Generate a chapter pack using the band table |
| `dart run tool/level_gen.dart --daily 2027 --out assets/levels/daily_2027.json` | Pre-bake dailies |
| `dart run tool/level_check.dart assets/levels/` | Validate every pack: schema, unique cells, adjacency, no self-crossing ray, solvable, difficulty within band ± 6. Exit non-zero on failure (used in CI). |
| Debug **Level Lab** screen (debug builds only) | Browse packs, play any level, see score/depth/solution overlay, regenerate a single level with a new seed, mark "approved", export pack |

## 8. Tests required
- Engine: freedom, blocked, removal side-effects for every mechanic, undo round-trip, portal loop safety.
- Generator: 1,000 random seeds per chapter params → 100% solvable; determinism (same seed → identical JSON) locked by golden fixtures, run on the Dart VM and in an Android + iOS integration test.
- Solver: hand-made unsolvable fixtures detected; rotator puzzles with known solutions.
- Pack check runs in CI on every PR.


## 9. Implementation notes (Phase 2)

Decisions made while implementing §3–§7; they refine, not replace, the rules above.

- **Generator** (`lib/core/level/generator/`): `LevelGenerator.generate(GenParams, seed)`; every random choice comes from `Mulberry32`. Order: portals (so every ray is portal-aware) → reverse-construction base board → `MechanicsPass`: gates+keys → linked pairs → frozen → rotators. Each step is verified by a solver and skipped silently when it cannot be done validly, so output is always solvable. `meta.solution` is a greedy order for monotone levels and the search order for rotator levels. Mulberry32 means no `dart:math` in `lib/core/level/` (a test enforces it): length skew is an integer (`lenSkew`), masks use only `+ - *`.
- **Gates**: the gate sits on an empty cell that lies on ≥ 2 rays; the key is an ordinary arrow removed earlier than all of them. One colour per gate (max 4).
- **Linked**: two arrows adjacent in the solution and both free at that point; only the first id stays in `meta.solution`.
- **Frozen**: an arrow at tap position `p` gets a counter `1…min(p,5)`.
- **Rotators**: single-cell arrows (`singleCellShare` makes the generator emit some); generate-and-test up to 200 tries; accepted when the search solver solves it within the state budget and `trapRatio ∈ [trapMin, trapMax]` (default 0–0.5; the doc did not give the band).
- **Switcher / splitter** are not generated (v1.1); the engine supports them behind flags.
- **Difficulty** (`difficulty.dart`): formula exactly as §5. `mechanics` adds each mechanic **type** present once. `depth`/`freeRatio`/`minFree` come from the **greedy waves** whenever greedy can finish the level (always for monotone levels), so they do not depend on which solution a solver found; rotator levels greedy cannot finish fall back to replaying the found solution. `density` uses playable cells.
- **Chapter plan** (`chapter_plan.dart`): the §5 band table, sawtooth `+0 +3 +6 +9 −8`, Knot `+8`, Boss absolute. Board size follows the band linearly (Knot +1, breather −1, Boss max+2), masks on Knots and (ch1) from L12. Mechanic mixes follow the budget in GDD §5. `PackBuilder` bisects an easy↔hard axis (`adapt` ∈ [−3, 3]: fill, windiness, length, board size) over derived seeds until the score is within 2.5 of the target (accepts the closest of 80 attempts; the check allows ±6).
- **Onboarding** (ch1 L1–10, `onboarding.dart`): L1–L2 hand-authored, L3–L10 generated under tight constraints (arrow count, bends, depth) choosing the easiest of 30 candidates. They are exempt from the band check (`generatorVersion` `onboarding-1.0`), like `handmade`/`proto` levels.
- **Daily Knot** (`daily.dart`): seed `FNV-1a("arrowchime-daily-v1-yyyy-MM-dd")`; weekday drives size (9–12), fill (0.70–0.84) and mechanics (Mon plain … Sun gates+frozen+link). Not band-checked (not on the chapter curve), but validated and solver-verified.
- **`tool/level_check.dart`** checks: schema; rules (`validateLevel`); solvable (greedy / search ≤ 200k states); `meta.solution` replays to a win; stored `meta.difficulty` matches the recomputed one (±0.1); score within ±6 of the target for chapter levels (non-exempt); pack-level: unique ids, chapter/index consistency; daily packs: consecutive dates and ids. Exit code 1 on any failure.
- **Determinism**: `test/core/level/generator/golden_test.dart` locks 9 fixtures by FNV-1a hash of the canonical JSON (and `integration_test/determinism_test.dart` runs the same hashes on a device). A deliberate generator change must bump `LevelGenerator.version` and update the hashes (`dart run tool/print_golden_hashes.dart`).
