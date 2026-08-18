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
- Rank ladder shows persistent star rewards for each peak season tier.
- Cosmetic starter catalog with avatar frames, badges, profile backgrounds, and name styles.
- Shop screen is connected from Home and shows cosmetic prices.
- Shop purchasing remains visibly locked until secure server-side economy authority exists.

## Milestone 3.3 — Ranked authority contracts

Implemented:

- Central `RankedRewardPolicy` for win/loss/tie RP, XP, and coin rewards.
- RP application clamps at zero so losing can never create negative rank points.
- Persistent season-star reward policy based on the player's peak seasonal tier.
- Stars accumulate permanently and never affect gameplay.
- Soft seasonal RP reset based on peak tier, centralized for launch tuning.
- XP application supports crossing multiple levels in one authoritative reward.
- Auditable `CoinTransaction` model with explicit transaction reasons.
- Coin balance policy rejects overspending and negative balances.
- `RankedMatchSettlement` response model for server-authoritative match settlement.
- Dedicated `RankedAuthorityBackend` boundary separated from read-only competition data.
- Match integrity policy for impossible progress/game-count/accuracy/time values.
- Settlement idempotency policy uses `matchId` as the stable exactly-once reward key.
- Blaze/Cloud Functions contracts documented for ranked settlement, cosmetic purchase/equip, and 30-day season rollover.
- Recommended immutable settlement and coin-ledger data shapes documented.
- Automated tests cover reward policy, permanent season stars, seasonal soft reset, multi-level XP, safe coin balances, impossible ranked progress, and duplicate-settlement prevention.

## Milestone 3.4 — Read model and visual foundation

Implemented:

- Read-only `FirestoreCompetitionBackend` prepared for server-populated active season and leaderboard data.
- Read-only `FirestoreEconomyBackend` prepared for owner-only inventory reads.
- Economy writes intentionally throw on Spark until a server-authoritative Blaze implementation exists.
- Firestore rules allow authenticated season/leaderboard reads and owner-only inventory reads while denying all client writes to those authoritative collections.
- Ranked settlement and coin transaction collections remain completely client-inaccessible.
- Shared game design tokens for background, surfaces, accent, success/danger, spacing, radii, and animation durations.
- App theme consumes shared design tokens instead of local hard-coded values.
- Mini-game SDK classifies games as reaction, logic, memory, or precision.
- All 10 approved game IDs remain unique and deterministic while exposing category metadata.
- Dedicated tests verify registry uniqueness/category coverage and deterministic seed behavior.

## Milestone 3.5 — Secure cosmetic transaction contracts

Implemented:

- Versioned cosmetic catalog with validation for unique IDs, non-empty names, and non-negative prices.
- Purchase receipt model returns transaction ID, exact price, remaining balance, and server purchase time.
- Economy backend purchase contract returns an authoritative receipt rather than `void`.
- Equipment contract returns authoritative inventory state after equip.
- Purchase policy rejects duplicate ownership, negative prices, and insufficient coin balances.
- Equipment policy rejects cosmetics the player does not own and changes only the correct cosmetic slot.
- Dedicated tests cover catalog validity, purchase balance calculation, duplicate purchase rejection, insufficient funds, and equipment ownership.

## Milestone 3.6 — Season lifecycle

Implemented:

- Season lifecycle policy guarantees exact 30-day seasons.
- The next season begins at the exact instant the previous season ends.
- Season numbering increments exactly once.
- Tests verify contiguous season boundaries and duration.

## Milestone 3.7 — Bilingual visual identity foundation

Implemented:

- Flutter `gen_l10n` enabled as the official localization source.
- Arabic and English ARB catalogs added as first-class game languages.
- App locale follows the device language automatically for Arabic/English.
- Material localization delegates provide native RTL for Arabic and LTR for English.
- Localization parity test prevents one language from silently missing message keys.
- Player-name validation exposes language-neutral validation issues so UI errors can be localized.
- Competitive dark navy/cyan/gold visual palette established in shared design tokens.
- Shared theme upgraded for typography, buttons, cards, fields, dialogs, progress bars, and interaction states.
- Home redesigned with a stronger player identity card, visible stars, localized rank badge, large competitive PLAY/RESUME surface, and a 2×2 navigation grid.
- Dedicated Season screen added instead of hiding season identity inside Leaderboard.
- Profile redesigned around player identity, localized stats, separate rank and XP progression, and localized editing errors.
- Leaderboard/Season presentation redesigned and localized while keeping live authority disabled on Spark.
- Shop redesigned and localized, including localized cosmetic names and four visual rarity levels: Common, Rare, Epic, Legendary.
- Cosmetic starter catalog now carries explicit rarity metadata while remaining cosmetic-only.
- Approved mini-game library is protected by a test that locks the current library to exactly 10 games until explicit approval for game 11.

## Product rules locked

- Match length remains exactly 3 minutes.
- A normal match remains 8 mini-games.
- The approved mini-game library remains exactly 10 games until a proposed new game is shown and explicitly approved before implementation.
- Arabic and English are foundational game languages, not a post-launch translation pass.
- Ranked competition must never alter mini-game difficulty or give paid gameplay advantages.
- Paid or earned shop items are cosmetic only.
- Persistent seasonal stars remain part of the player identity above the avatar.
- Seasons last 30 days.
- Mini-games remain isolated from authentication, Firestore, ranking, seasons, and economy.

## Spark-safe work

The following may continue without Blaze:

- Arabic/English localization of all remaining match/auth/history screens.
- Visual redesign of matchmaking, match room, countdown, gameplay shell, and result screen.
- Rank/season/progression domain policies.
- Cosmetic catalog definitions bundled with the app.
- Rank/star/avatar/cosmetic visual assets.
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

1. Localize and redesign matchmaking, match room, countdown, match play shell, results, history, sign-in, and profile setup.
2. Design the actual rank emblem and season-star asset family before integrating image assets.
3. Continue cosmetic presentation and preview components without activating purchases on Spark.
4. Prepare Cloud Functions implementation package when Blaze activation is chosen.
5. Run analyze/tests/build and compile Firestore rules after this development block.
