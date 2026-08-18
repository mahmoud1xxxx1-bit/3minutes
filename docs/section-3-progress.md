# Section 3 — Competition, Progression, Economy, and Launch

Status: IN PROGRESS

## Goal

Turn the validated multiplayer core into the competitive product layer without introducing pay-to-win or client-authoritative rank/economy writes.

## Milestone 3.1 — Domain and backend boundaries

Implemented:

- Central ranked tier model.
- Central rank-band policy, easy to tune before launch.
- Fixed 30-day season contract.
- Leaderboard entry model.
- `CompetitionBackend` abstraction for current season, leaderboard, and player competition state.
- XP/level progression model and centralized progression policy.
- Cosmetic-only economy models.
- Player inventory model with coins and equipped cosmetic slots.
- `EconomyBackend` abstraction for catalog, purchases, and equipment.
- Automated tests for rank tiers, 30-day seasons, and XP progression.

## Milestone 3.2 — Spark-safe competitive presentation

Implemented:

- Current rank tier shown on the home player card.
- Profile screen shows rank tier, RP, stars, wins/losses, and level.
- Profile screen shows XP progress toward the next level using the centralized progression policy.
- Leaderboard/season screen is connected from Home.
- Rank ladder and 30-day season rule are visible without inventing fake player standings.
- Cosmetic starter catalog with avatar frames, badges, profile backgrounds, and name styles.
- Shop screen is connected from Home and shows cosmetic prices.
- Shop purchasing remains visibly locked until secure server-side economy authority exists.

## Product rules locked

- Match length remains exactly 3 minutes.
- A normal match remains 8 mini-games.
- Ranked competition must never alter mini-game difficulty or give paid gameplay advantages.
- Paid or earned shop items are cosmetic only.
- Persistent seasonal stars remain part of the player identity above the avatar.
- Seasons last 30 days.
- Mini-games remain isolated from authentication, Firestore, ranking, seasons, and economy.

## Spark-safe work

The following may continue without Blaze:

- UI shells and view models for leaderboard, season, progression, inventory, and cosmetics.
- Rank/season/progression domain policies.
- Cosmetic catalog definitions bundled with the app.
- Additional mini-games and visual assets.
- Tests and release hardening.

## Blaze-required authority

The following must not be implemented as trusted client writes:

- accepting ranked match results;
- awarding or removing RP;
- updating wins/losses/games played from ranked matches;
- XP rewards;
- coin rewards and coin spending;
- season rollover and persistent seasonal star awards;
- authoritative leaderboard snapshots when anti-cheat is enabled;
- purchase validation and entitlement grants;
- anti-cheat and suspicious-result rejection.

These operations will sit behind Cloud Functions while Flutter continues using the competition/economy backend contracts.

## Next

1. Prepare Cloud Functions request/response contracts and Firestore data shapes for ranked settlement.
2. Define season rollover and persistent-star award rules behind server authority.
3. Define secure coin reward/spending transactions and inventory grants.
4. Continue expanding representative mini-games and visual identity.
5. Run final analyze/tests/build after this development block when device access is convenient.
