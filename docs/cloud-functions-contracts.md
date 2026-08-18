# Blaze / Cloud Functions Authority Contracts

Status: PREPARED — not deployed on Spark

This document defines the server-authoritative operations that will replace trusted client writes when the Firebase project moves to Blaze.

## 1. settleRankedMatch(matchId)

Caller: authenticated participant only.

Server validations:

- caller belongs to the match;
- match exists and is settled (both completed or shared 3-minute deadline elapsed);
- match has not already been ranked-settled;
- registry version and game count are supported;
- progress moves are internally consistent;
- result is derived on the server from stored progress;
- current season is active;
- duplicate/replayed settlement is rejected idempotently;
- suspicious/impossible progress may be rejected or flagged.

Atomic writes:

- RP for both players;
- wins/losses/gamesPlayed;
- XP and resulting level;
- coin rewards;
- season peak tier / season statistics;
- leaderboard materialized values if used;
- immutable settlement record;
- auditable coin transaction records.

The response maps to `RankedMatchSettlement` in Flutter.

## 2. purchaseCosmetic(cosmeticId)

Caller: authenticated owner only.

Server validations:

- cosmetic exists in the authoritative catalog/version;
- item is cosmetic only;
- player does not already own the item;
- coin balance is sufficient;
- request has not already been processed.

Atomic writes:

- decrement coin balance;
- grant entitlement;
- immutable purchase/coin transaction record.

Coin balance must never become negative.

## 3. equipCosmetic(cosmeticId)

Caller: authenticated owner only.

Server validations:

- player owns the cosmetic;
- cosmetic type matches the requested equipment slot.

Write only the equipped cosmetic slot. Equipping never changes competitive values.

## 4. rolloverSeason()

Trigger: scheduled server job after the exact 30-day season boundary.

Server actions:

- close current season exactly once;
- calculate persistent star award from the player's highest tier for that season;
- add stars to persistent identity total;
- archive season leaderboard/statistics;
- create the next 30-day season;
- reset season-scoped rank state according to the launch reset policy.

Persistent stars never reset and never affect gameplay.

## Server-only collections / records

Recommended shapes when Blaze is enabled:

- `seasons/{seasonId}` — lifecycle and timing.
- `seasonPlayers/{seasonId}/players/{uid}` — season RP/peak tier/stats.
- `rankedSettlements/{matchId}` — immutable idempotency/result record.
- `inventories/{uid}` — coin balance and equipped cosmetics.
- `inventories/{uid}/items/{cosmeticId}` — owned entitlements.
- `coinTransactions/{transactionId}` — immutable auditable balance movements.

Clients may read only the data needed for UI. They must not directly write RP, XP, levels, wins, losses, coins, stars, season rewards, settlement records, or purchase entitlements.

## Spark phase rule

Until Blaze is enabled, these contracts remain inactive. The UI may display rank/progression/catalog data and domain policies may be tested locally, but trusted rewards, purchases, season rollover, and ranked leaderboard writes must not be simulated by insecure Firestore client writes.
