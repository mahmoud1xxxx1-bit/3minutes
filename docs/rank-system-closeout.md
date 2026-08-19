# Rank System Closeout

Status: source-complete and No-APK validated on `main`.

## Final ladder

The competitive ladder is exactly eight tiers:

1. Bronze — 0 RP
2. Silver — 500 RP
3. Gold — 1200 RP
4. Platinum — 2200 RP
5. Diamond — 3500 RP
6. Master — 5000 RP
7. Grand Master — 7000 RP
8. Legendary — 10000 RP

The stored/server identifier for the top tier remains `legend` for compatibility. Player-facing English is `Legendary`; Arabic remains `أسطوري`.

## Approved rank art

- The rejected simple painter emblems are not the active rank presentation.
- `RankEmblem` renders the approved premium transparent WebP atlas.
- Atlas layout is 4 columns × 2 rows, matching `RankTier.values` exactly.
- Existing contract tests verify all eight cells and the WebP payload.

## Current rank truth vs historical display

- `RankBadge` always represents the player's current competitive tier when used on competitive surfaces.
- `peakRankTier` stores the lifetime highest earned rank.
- `showcaseRankTier` is an optional historical emblem selected only from tiers at or below the lifetime peak.
- `RankLegacyShowcase` renders the selected historical emblem separately from the current rank so the profile never pretends an old rank is current.
- On Spark, earned historical emblems are viewable but selecting/changing the public showcase is intentionally disabled. Server-authoritative selection activates with Blaze.

## Legendary seasonal prestige

Legendary prestige is permanent account history earned at most once per distinct completed season whose peak tier is Legendary.

Visual milestones:

- ×1 — Legendary base prestige
- ×2 — double halo
- ×3 — crowned
- ×5 — stronger aura
- ×10+ — Legacy gold ornament/aura

The multiplier is display/status only and never affects matchmaking, RP, scoring, rewards, or gameplay power.

## Server authority

The server settlement response is the source of truth for rank transitions. Flutter does not recalculate a promotion locally.

`RankedSettlementPlayer` validates the callable payload fields:

- previous RP
- next RP
- RP delta
- previous tier
- next tier
- XP awarded
- Coins awarded

`rankedSettlements` Firestore documents remain unreadable and unwritable by clients. Promotion UI therefore consumes the authenticated callable response rather than reading settlement records from Firestore.

## Rank-up reveal

When Blaze Ranked authority is active:

1. `settleRankedMatch` returns the authoritative player settlement.
2. `CloudFunctionsMatchBackend` parses the correct `playerA`/`playerB` entry by UID.
3. If `nextTier` is above `previousTier`, a promotion event is emitted with the match ID.
4. The app-level `RankPromotionOverlayHost` shows the premium `RankPromotionReveal` once for that match.
5. The reveal uses the approved rank emblem, shows the authoritative RP transition, respects reduced-motion accessibility, and can be dismissed with Continue.

Events are deduplicated by match ID so an idempotent settlement retry cannot repeatedly show the same promotion.

## Surfaces

- Current rank badge: profile, season/leaderboard and other competitive surfaces.
- Legendary ×N prestige: profile and leaderboard rank badge.
- Earned-emblem gallery: Rank Showcase screen.
- Selected historical emblem: profile Hero as `Legacy Showcase`.
- Promotion reveal: global overlay triggered only by authoritative Ranked settlement on Blaze.

## Validation evidence

No APK was built for this closeout.

Dedicated No-APK validation passed after the final profile integration:

- Cloud Functions build/tests: PASS
- Firestore rules/security tests: PASS
- Flutter analyze: PASS
- Full Flutter tests: PASS
- Approved rank atlas contract: PASS
- Legendary milestone widget contract: PASS
- Spark-safe Rank Showcase behavior: covered by source/config contract
- Ranked settlement parser tests: PASS
- Rank promotion reveal widget: PASS
- One-time promotion event/overlay behavior: PASS
- Historical `Legacy Showcase` widget: PASS

Temporary validation PRs were closed without merging.

## Deployment boundary

Current app phase remains Spark. The source for server-authoritative Ranked settlement, historical showcase selection, seasonal rollover, and rank promotion delivery is prepared, but those server actions are not production-live until the agreed Blaze deployment phase. This boundary must not be bypassed with insecure client writes.
