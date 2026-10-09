# 08 — Economy, Monetization & LiveOps

Principle: **fair beats greedy.** The genre leader's #1 complaint is ads. We monetize slightly less per session but aim to keep players far longer and earn the better rating.

## 1. Currency

| Source (coins) | Amount |
|---|---|
| Level clear | 10 + 5 per star (Knot ×1.5, Boss ×3) |
| Flow ×5 reached in a level | +10 |
| Daily Knot | 50 (+25 per streak tier) |
| Daily quest | 30–80 each; quest chest 100 |
| Achievement | 50–500 |
| Player level-up | 100 |
| Rewarded ad "double coins" on win sheet | ×2 (max 5 per day) |

| Sink | Price |
|---|---|
| Hint | 50 |
| Undo (after 2 free) | 30 |
| +1 heart on fail | 100 |
| Streak freeze | 200 |
| Cosmetic (common / rare / epic) | 500 / 1,500 / 4,000 |
| Replay a missed Daily | 100 |

Target: an average player can afford ~1 hint per 4 levels from earnings alone; cosmetics are the long-term coin sink. All values live in Remote Config.

## 2. Ads policy (mobile)

| Rule | Value (RC key) |
|---|---|
| No interstitials before level | 12 (`interstitial_min_level`) |
| Show interstitial only **after a win**, on the win → next transition | always |
| Never on: retry, fail, first app open, Daily Knot, tutorial, within 90 s of the previous ad | hard rules |
| Frequency | every 3rd win (`interstitial_every_n_levels`), min 150 s apart, max 6/hour |
| Skip after a purchase of any kind | 24 h ad holiday |
| Rewarded | +1 heart (max 2/level), double coins, free hint, unlock a missed Daily |
| Banners | **None** (keeps the board clean) |
| Ad content | Max ad rating G, sensitive categories blocked |
| Consent | Google UMP before any ad request; iOS ATT prompt only after level 5 with a pre-prompt explaining why |

## 3. IAP catalogue (suggested — set local pricing tiers per store)

| Product | Type | Contents | Suggested USD |
|---|---|---|---|
| Remove Ads | Non-consumable | No interstitials forever (rewarded stay optional) + 500 coins | **$3.99** (vs $9.99–16.99 at the leader) |
| Starter Bundle | Non-consumable, shown after L15 for 48 h | Remove Ads + 2,000 coins + Neon skin | $6.99 |
| Coin Pouch | Consumable | 1,000 | $1.99 |
| Coin Chest | Consumable | 5,500 | $7.99 |
| Coin Vault | Consumable | 15,000 | $19.99 |
| Chapter Art Pack | Non-consumable | Skin + trail + instrument themed set | $2.99 |
| Fletch Pass (v1.1) | Season (30 days) | Premium track cosmetics + 2× quest coins | $4.99 |

India pricing: use Play/App Store regional tiers (e.g., Remove Ads ≈ ₹149–199) — check current store price templates.

## 4. LiveOps calendar (post-launch)
| Cadence | Content |
|---|---|
| Daily | Daily Knot, 3 quests |
| Weekly | Tangle Tower event (Fri–Mon), weekly leaderboard for Daily Knot (v1.1) |
| Monthly | New 30-level mini-chapter or seasonal skin (Diwali lights, Halloween, Winter, Holi colours, Lunar New Year) |
| Quarterly | New full chapter + mechanic |

All events toggled via Remote Config; event levels downloaded as packs from Firebase Storage.

## 5. KPIs dashboard
D1/D7/D30, levels per DAU, fail rate per level (flag levels with > 35% fail for re-tune), hint usage per level, ad impressions per DAU, rewarded opt-in rate, payer conversion, ARPDAU, Daily Knot participation & share rate, uninstall after ad (proxy: churn on session after interstitial).

## 6. User acquisition notes
- Short-form video: "Every arrow rings a chime" — record a Flow ×5 clear with the melody.
- **Playable ad** (HTML5, built separately by a playable-ad studio or tool, < 5 MB): first 3 levels with the chime melody — the genre leader's UA relies heavily on one long-running playable. Not built in Flutter for this version.
- ASO keywords: arrow puzzle, arrows escape, tap away, arrow out, logic puzzle, brain game, relaxing puzzle, no timer.
