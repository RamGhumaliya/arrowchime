# Arrowchime — Claude Code Starter Pack (Android + iOS)

Everything Claude Code needs to build a premium arrow-escape puzzle game in Flutter for **Android and iOS**. Web is deferred to a later version.

## The idea in one line
**Arrowchime: Arrow Escape Puzzle** — every freed arrow rings a musical chime, every cleared level restores part of a hand-made 3D diorama world, and the whole game has a tactile "Toybox 3D" look instead of the flat, template look of its competitors. Fair ads, real zoom, path preview and mechanics that make order matter.

## What's inside
```
arrowchime-pack/
├── README.md                      ← you are here
├── CLAUDE.md                      ← Claude Code reads this every session (design + engineering rules)
├── docs/
│   ├── 01_MARKET_RESEARCH.md      ← genre, competitors, complaints, gaps (with sources)
│   ├── 02_PRD.md                  ← product requirements, scope, USPs, metrics
│   ├── 03_GAME_DESIGN.md          ← rules, mechanics, chapters, juice, meta, screens (behaviour)
│   ├── 04_LEVEL_SYSTEM.md         ← level JSON, generator, solvers, difficulty, determinism
│   ├── 05_TECH_ARCHITECTURE.md    ← stack, folders, rendering, audio, save, CI (mobile)
│   ├── 06_ART_DIRECTION.md        ← NAME research, logo, chapter worlds, human-made art pipeline
│   ├── 07_AUDIO_DESIGN.md         ← Arrow Symphony system, SFX list, music, sourcing
│   ├── 08_ECONOMY_MONETIZATION.md ← coins, fair ads policy, IAP, liveops, UA
│   ├── 09_QA_ACCEPTANCE.md        ← acceptance tests, design QA (D1–D9), Definition of Done
│   ├── 10_DESIGN_SYSTEM.md        ← STRICT "Toybox 3D" UI system: banned AI-look list, tokens,
│   │                                 components, screen layouts, arrow look, design review gate
│   └── reference/generator_reference.py ← proven prototype of the level generator
├── prompts/BUILD_PROMPTS.md       ← Session Start, Design Guard, 11 phase prompts, fix/review prompts
└── assets/
    ├── ASSET_MANIFEST.md          ← every image/audio path the code will use
    ├── levels/level.schema.json   ← JSON Schema for levels
    ├── levels/sample_levels.json  ← 3 verified sample levels (incl. gate + key + frozen)
    └── branding/                  ← icon + logo direction sketches (SVG + PNG) for your designer
```

## How to use it with Claude Code
1. Create an empty Git repo for the game and copy **all** of this pack into it (`CLAUDE.md` at the root).
2. Open Claude Code there. Paste **Session Start**, then **Phase 0** from `prompts/BUILD_PROMPTS.md`.
3. Before any phase marked 🎨, paste the **Design Guard** prompt. Those phases end with screenshots in `docs/screenshots/` — **you review and approve them** before the next phase. This gate is what keeps the UI from drifting into a generic AI look.
4. Commit after each phase. Start every new session with **Session Start**.
5. If a screen ever looks generic, use the "Design looks generic" prompt at the bottom of `BUILD_PROMPTS.md`.

## What you still need to do (Claude Code can't)
- **Lock the name:** search "Arrowchime" in the Play Console and App Store Connect, check trademarks (class 9 & 41), register `arrowchime.com` and social handles.
- **Hire human art:** a UI designer (Figma, using `docs/10` tokens) and a 3D artist for the icon set and 5 chapter dioramas — brief them with `docs/06` + `docs/10`. Logo sketches in `assets/branding/` are directions, not final art.
- **Audio:** instrument note samples + 5 music loops (`docs/07 §5`).
- Accounts & keys: Firebase, AdMob, Play Console, Apple Developer, RevenueCat (if chosen).
- Real-device playtesting for difficulty and feel.

## Decisions to make before Phase 0
- **State management:** pack uses Riverpod. If you prefer GetX, change it in `CLAUDE.md` and `docs/05` first (game engine is pure Dart, so either works).
- **IAP provider:** RevenueCat vs `in_app_purchase` (asked in Phase 8).
