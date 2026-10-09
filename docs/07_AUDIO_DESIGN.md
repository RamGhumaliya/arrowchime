# 07 — Audio Design: "Arrow Symphony"

Sound is a **core feature**, not decoration. Goal: a player with eyes half-closed can feel the board clearing as music.

## 1. The Arrow Symphony system

1. Each level has a **melody**: a list of scale degrees (e.g. `[1,3,5,6,5,3,2,1, ...]`) in the chapter's scale, ≥ 16 notes, looping.
2. Each freed arrow plays the **next** note of the melody on the chapter instrument. Order of taps doesn't matter — the melody always sounds right, so every player "performs" the tune.
3. **Note length = arrow length:** arrows longer than 8 cells play the note with a longer sample variant (or let it ring with a fade) — long arrows feel weightier.
4. **Flow tiers** (consecutive correct taps within 1.5 s):
   - ×2: add a soft 5th above on the notes bus (−8 dB)
   - ×3: add a shaker/percussion tick layer to the music loop
   - ×4: add a 3rd (full triad)
   - ×5: sparkle sample on every note + brief music filter open
   A blocked tap resets Flow and plays the "thunk".
5. **Board clear:** remaining melody notes play as a fast cascade (90 ms apart), then a 2-bar flourish resolving to the tonic, then a chime.
6. **Boss clear:** full chapter theme sting (8–12 s).

Melodies live in `lib/core/audio/melodies.dart` as data (≈ 12 melodies per chapter, rotated by level index). Write them original — **do not use or imitate any existing copyrighted melodies**.

### Scales per chapter
| Chapter | Instrument | Scale (degrees available) | Tempo feel |
|---|---|---|---|
| Misty Garden | Kalimba | C major pentatonic, C4–C6 | Calm |
| Clockwork Town | Music box | G major, G4–G6 | Ticking, playful |
| Lantern Bazaar | Plucked strings (santoor-like) | D dorian, D4–D6 | Warm, festive |
| Frost Peaks | Celesta / glass | A minor pentatonic, A4–A6 | Airy |
| Starlight Obs. | Harp + synth pad | E lydian, E4–E6 | Wonder |

Pentatonic scales make random sequences sound pleasant; even non-pentatonic chapters should favour chord tones on strong beats.

### Sample strategy
Pre-render each note (2 octaves of the scale ≈ 10–15 files per instrument) at 44.1 kHz, mono, OGG Vorbis ~96 kbps, 0.6–1.5 s with natural decay, trimmed silence, normalized to −14 LUFS-ish peak −1 dBTP. Pitch-shifting a single sample is acceptable for placeholders only.

## 2. SFX list (MVP)

| ID | File | Description |
|---|---|---|
| `ui_tap` | `assets/audio/sfx/ui_tap.ogg` | Soft wooden click for buttons |
| `ui_back` | `ui_back.ogg` | Lower click |
| `arrow_touch` | `arrow_touch.ogg` | Very subtle tick on touch-down |
| `arrow_whoosh` | `arrow_whoosh.ogg` | Airy whoosh layered under each note (varies pitch ±5%) |
| `arrow_blocked` | `arrow_blocked.ogg` | Soft muffled thunk, not harsh |
| `heart_lost` | `heart_lost.ogg` | Glassy crack |
| `rotator_turn` | `rotator_turn.ogg` | Gear click |
| `gate_open` | `gate_open.ogg` | Wooden door swing + chime |
| `key_collect` | `key_collect.ogg` | Jingle |
| `ice_tick` | `ice_tick.ogg` | Ice crack (lighter each tick) |
| `ice_break` | `ice_break.ogg` | Ice shatter |
| `portal_pass` | `portal_pass.ogg` | Warp swirl |
| `flow_up` | `flow_up.ogg` | Rising arpeggio per tier |
| `board_clear` | `board_clear.ogg` | Chime after cascade |
| `star_1/2/3` | `star_1.ogg`… | Ascending pings |
| `coin` | `coin.ogg` | Coin clink (pitch up per coin in a burst) |
| `level_fail` | `level_fail.ogg` | Gentle descending chord |
| `fragment_restore` | `fragment_restore.ogg` | Magical shimmer |
| `chest_open` | `chest_open.ogg` | Wooden creak + sparkle |
| `daily_complete` | `daily_complete.ogg` | Short fanfare |
| `purchase` | `purchase.ogg` | Register-like sparkle |

## 3. Music
- One ambient loop per chapter (60–120 s, gapless OGG, −20 LUFS), sparse so notes sit on top. Same key as the chapter scale.
- Menu/home uses the current chapter loop at −4 dB.
- Ducking: −30% during last 3 arrows and the flourish; restore over 600 ms.

## 4. Mixing defaults
| Bus | Default |
|---|---|
| Music | 0.55 |
| Notes | 0.90 |
| SFX | 0.80 |
Settings expose Music, Sound (notes + SFX), Haptics.

## 5. Sourcing (check every licence)
- **CC0 SFX** for prototyping: Kenney.nl audio packs (CC0), Freesound filtered to CC0.
- **Instrument notes:** render from free/commercial-OK sample instruments (e.g., Spitfire LABS, Decent Samples — check each licence for game redistribution) in any DAW; or commission.
- **Music:** commission a composer or license royalty-free tracks with a game-use licence; AI music tools only if their terms grant commercial rights.
- Keep a `assets/audio/LICENSES.md` listing every file, source and licence.

## 6. Placeholder audio (so Phase 1–4 work without final assets)
`tool/gen_placeholder_assets.dart` synthesizes simple sine/triangle tones with an ADSR envelope into WAV files for every note and SFX id above. flutter_soloud can also generate waveforms at runtime — acceptable for placeholders.
