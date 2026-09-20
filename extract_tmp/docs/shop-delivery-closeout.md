# 3 Minutes — Shop & Cosmetic Delivery Closeout

Status date: 2026-08-19

This document is the repository-level closeout contract for the current Shop / Cosmetics implementation. It records what is already implemented and tested, and clearly separates it from production-only Blaze / Google Play activation work.

## 1. Current phase and safety boundary

- Current backend phase remains **Spark**.
- `AppConfig.economyPurchasesEnabled` remains false until `BackendPhase.blaze` is deliberately enabled after Cloud Functions deployment and security review.
- Shop browsing and full in-game previews are active now.
- Coin purchase, Prestige unlock, earned-item claim, equip writes, and Google Play premium entitlement writes remain intentionally locked in Spark.
- We do **not** bypass this boundary with direct client Firestore writes.
- Premium cosmetics are cosmetic only and do not grant competitive power.
- Prestige Stars remain permanent history thresholds and are never spent or sold.

## 2. Catalog contract

Catalog version: **v3**

Total catalog entries: **73**

- 45 Avatars
- 28 non-avatar cosmetics
- 10 equipment slots are supported end-to-end by the equipment policy:
  - Avatar
  - Avatar Frame
  - Badge
  - Profile Background
  - Name Style
  - Match Intro
  - Victory Effect
  - Rank Aura
  - Emote
  - Room Theme

The Flutter catalog and Cloud Functions entitlement catalog use matching IDs / slots / server prices. Tests lock this contract so a server/client mismatch cannot silently ship.

## 3. Avatar catalog — exactly 45

### Free avatars — 5

| ID | Name | Unlock |
|---|---|---|
| `avatar_free_vanguard` | Vanguard Captain | Free |
| `avatar_free_arena` | Arena Ace | Free |
| `avatar_free_hacker` | Neon Hacker | Free |
| `avatar_free_phantom` | Street Phantom | Free |
| `avatar_free_warden` | Star Warden | Free |

### Coin avatars — 20

| ID | Name | Coins |
|---|---|---:|
| `avatar_coin_01` | Nebula Scout | 1,600 |
| `avatar_coin_02` | Flux Racer | 2,000 |
| `avatar_coin_03` | Iron Sentinel | 2,400 |
| `avatar_coin_04` | Pulse Duelist | 2,800 |
| `avatar_coin_05` | Ember Agent | 3,200 |
| `avatar_coin_06` | Orbit Archer | 3,600 |
| `avatar_coin_07` | Prism Monk | 4,000 |
| `avatar_coin_08` | Quantum Driver | 4,400 |
| `avatar_coin_09` | Rift Ranger | 4,800 |
| `avatar_coin_10` | Ion Valkyrie | 5,200 |
| `avatar_coin_11` | Cipher Fox | 5,600 |
| `avatar_coin_12` | Storm Gladiator | 6,000 |
| `avatar_coin_13` | Solar Nomad | 6,400 |
| `avatar_coin_14` | Luna Tactician | 6,800 |
| `avatar_coin_15` | Cosmo Ranger | 7,200 |
| `avatar_coin_16` | Voltage Ronin | 7,600 |
| `avatar_coin_17` | Mirror Siren | 8,400 |
| `avatar_coin_18` | Jet Commander | 9,200 |
| `avatar_coin_19` | Astro Rogue | 10,000 |
| `avatar_coin_20` | Halo Engineer | 11,000 |

### Premium avatars — 10

`premiumPriceCents` values are entitlement-catalog values. The production UI must use Google Play localized product pricing when Blaze / Play billing is enabled.

| ID | Name | Catalog cents |
|---|---|---:|
| `avatar_premium_01` | Nebula Oracle | 998 |
| `avatar_premium_02` | Crimson Reaper | 998 |
| `avatar_premium_03` | Eclipse Huntress | 1,198 |
| `avatar_premium_04` | Solar Sovereign | 1,198 |
| `avatar_premium_05` | Infinite Monarch | 1,398 |
| `avatar_premium_06` | Void Queen | 1,398 |
| `avatar_premium_07` | Astral Ronin | 1,598 |
| `avatar_premium_08` | Celestial Emperor | 1,598 |
| `avatar_premium_09` | Chrono Warden | 1,998 |
| `avatar_premium_10` | Nova Duchess | 1,998 |

### Prestige avatars — 5

These are permanent lifetime thresholds. Unlocking never consumes Stars.

| ID | Name | Prestige Stars |
|---|---|---:|
| `avatar_star_01` | Stellar Veteran | 3 |
| `avatar_star_02` | Celestial Judge | 5 |
| `avatar_star_03` | Rift Archon | 10 |
| `avatar_star_04` | Eternal Paladin | 20 |
| `avatar_star_05` | Infinite Sage | 35 |

### Earned / seasonal avatars — 5

| ID | Name | Requirement |
|---|---|---|
| `avatar_exclusive_01` | Zenith Paragon | Reach Legendary once |
| `avatar_exclusive_02` | Crowned Legend | Legendary in 3 distinct seasons |
| `avatar_exclusive_03` | Legacy Warden | Legendary in 5 distinct seasons |
| `avatar_exclusive_04` | Ranked Conqueror | 100 Ranked wins |
| `avatar_exclusive_05` | Season Champion | Finish a season at standing #1 |

The server re-checks the authoritative achievement / season data before an earned avatar can be claimed.

## 4. Non-avatar cosmetics — 28

### Coins — 14

| ID | Slot | Coins | Runtime delivery |
|---|---|---:|---|
| `name_bold` | Name Style | 500 | Player identity text |
| `frame_classic` | Avatar Frame | 750 | Avatar identity |
| `badge_timer` | Badge | 1,200 | Player identity |
| `background_grid` | Profile Background | 1,600 | Profile |
| `emote_gg` | Emote | 2,200 | Social friend matches |
| `frame_neon` | Avatar Frame | 4,200 | Animated identity frame |
| `name_champion` | Name Style | 5,500 | Player identity text |
| `frame_voltage` | Avatar Frame | 7,000 | Animated identity frame |
| `background_arena` | Profile Background | 8,500 | Profile |
| `victory_confetti` | Victory Effect | 10,000 | Social + Ranked result victory |
| `name_electric` | Name Style | 12,500 | Animated identity text |
| `room_arcade` | Room Theme | 16,000 | Hosted private room |
| `intro_redline` | Match Intro | 22,000 | Social + Ranked pre-match |
| `aura_storm` | Rank Aura | 30,000 | Animated rank/identity presentation |

### Prestige Stars — 9

| ID | Slot | Stars | Runtime delivery |
|---|---|---:|---|
| `badge_crown` | Badge | 10 | Player identity |
| `frame_prestige` | Avatar Frame | 20 | Avatar identity |
| `aura_rank_flare` | Rank Aura | 30 | Animated rank/identity presentation |
| `intro_champion` | Match Intro | 45 | Animated Social + Ranked pre-match |
| `background_constellation` | Profile Background | 60 | Animated profile |
| `name_royal` | Name Style | 80 | Animated identity text |
| `victory_crown_burst` | Victory Effect | 120 | Animated Social + Ranked result victory |
| `frame_elite` | Avatar Frame | 160 | Animated identity frame |
| `aura_mythic_legacy` | Rank Aura | 250 | Animated high-prestige rank identity |

### Premium — 5

| ID | Slot | Catalog cents | Runtime delivery |
|---|---|---:|---|
| `frame_obsidian` | Avatar Frame | 199 | Avatar identity |
| `background_void` | Profile Background | 299 | Animated profile |
| `intro_portal` | Match Intro | 399 | Animated Social + Ranked pre-match |
| `victory_lightning` | Victory Effect | 399 | Animated Social + Ranked result victory |
| `room_cyber_royal` | Room Theme | 499 | Animated hosted private room |

## 5. Animated-item delivery

There are currently **17 catalog entries marked `isAnimated`**. They are not labels-only anymore. The central runtime now provides restrained Cosmic Flow motion for:

- Neon / Voltage / Elite animated avatar frames
- Electric / Royal animated name styles
- Constellation and Living Void profile backgrounds
- Storm / Rank Flare / Mythic Legacy rank auras
- Redline / Champion / Portal match intros
- Confetti / Crown Burst / Lightning victory effects
- Cyber Royal room theme

Animations are deliberately restrained rather than fast neon effects, preserving the Cosmic Flow visual identity.

A widget smoke test renders every `isAnimated` catalog item through `CosmeticAppliedPreview`, advances multiple animation frames, and fails if Flutter reports a rendering/runtime exception.

## 6. Social/public delivery

The canonical public cosmetic state remains `users/{uid}.cosmeticLoadout`, written by trusted server authority after ownership verification.

Social summaries now derive identity from this canonical loadout rather than maintaining a second mutable social copy. Search results, incoming requests, accepted friends, and recent players render the effective equipped avatar / frame / name style / badge together with truthful current rank and Legendary ×N history where relevant.

Private rooms already render host room themes and participant equipped identity. Ranked rooms already render equipped avatar / frame / name / badge and match intro. Ranked result screens now render the winner's equipped Victory Effect without changing match settlement, RP, ranking, or rematch logic.

The GG emote is entitlement-gated. Firestore security tests explicitly verify that a participant cannot forge display identity or use the emote without the required equipped entitlement.

## 7. Purchase and ownership authority

### Coins

`purchaseCosmetic` is server-authoritative and transactional:

- validates authenticated UID
- validates catalog ID and coin price type
- rejects duplicate ownership
- checks coin balance
- deducts Coins atomically
- grants permanent ownership
- writes a coin ledger transaction

### Free cosmetics

`equipCosmetic` may claim a catalog `free` item on first equip. Non-free items cannot be equipped unless owned.

### Prestige Stars

`unlockPrestigeCosmetic`:

- reads permanent account Stars
- checks the configured threshold
- never subtracts Stars
- grants ownership once
- records a receipt with `starsSpent: 0`

### Earned cosmetics

`claimEarnedCosmetic` re-checks server-owned player / season history for:

- Legendary once
- Legendary ×3 distinct seasons
- Legendary ×5 distinct seasons
- 100 Ranked wins
- Season Champion

### Premium / Google Play

The premium pipeline is server-verified before entitlement is considered complete:

- fixed package: `com.threeminutes.game`
- server verifies Google Play purchase token
- product ID must match the cosmetic ID
- purchase state must be `PURCHASED`
- verified line item must contain that product
- purchase token is hashed into an idempotent receipt ID
- an existing token cannot be rebound to another user/cosmetic
- ownership is persisted transactionally
- Google Play acknowledgement is performed / retried
- client does not complete the Play purchase until server verification succeeds

Production activation still requires Blaze deployment plus the corresponding Google Play product configuration. This is intentionally deferred and must not be represented as live while the app remains in Spark phase.

## 8. Validation evidence

The current code path has passed dedicated **No APK Validation** after the latest animation fixes and animated-widget smoke coverage:

- Cloud Functions TypeScript build/tests: PASS
- server catalog contract tests: PASS
- Firestore Emulator rules/security tests: PASS
- Flutter Analyze: PASS
- Flutter full test suite: PASS
- animated cosmetic widget smoke test: PASS
- APK build: intentionally not run

Validation run: `32214788073`

Latest validated main commit at this closeout: `7cefac752f7bae54d7893c13c4c2e14cb071f5fb`

All temporary validation pull requests used during this work were closed without merge. No validation-marker PR remains open at closeout.

## 9. CI APK policy

Normal pushes and pull requests continue to run code validation, but Android APK build / OAuth-resource verification / APK certificate verification / artifact upload are now guarded by `github.event_name == 'workflow_dispatch'`.

This means an APK is not built automatically while visual/product work is still in progress. APK generation remains an explicit manual action for the later device-testing/release phase.

## 10. Remaining external activation work — intentionally deferred

The following is **not** a missing visual/store implementation bug and must remain deferred until the project moves to Blaze / release setup:

1. Deploy the production Cloud Functions in `me-central2`.
2. Configure/verify all Google Play premium product IDs and localized prices.
3. Give the runtime service account the required Android Publisher access for Play verification.
4. Enable `BackendPhase.blaze` only after production Functions and security review are confirmed live.
5. Run real-device Google Play purchase / restore / acknowledgement tests in the release-testing phase.
6. Build an APK only when explicitly requested for that phase.

Until then, the Shop correctly behaves as a **fully interactive preview/catalog experience with secure write actions intentionally locked**.
