# Section 3 — Competition, Progression, Economy, and Launch

Status: IN PROGRESS — Spark-safe product layer and visual journey code complete; Blaze authority, deployment, and runtime QA remain.

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
- Leaderboard and dedicated Season screens are connected from Home.
- Rank ladder and 30-day season rule are visible without inventing fake player standings.
- Rank ladder shows persistent star rewards for each peak season tier.
- Cosmetic starter catalog with avatar frames, badges, profile backgrounds, and name styles.
- Shop screen is connected from Home and shows cosmetic prices and previews.
- Shop purchasing remains locked until secure server-side economy authority exists.

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
- Per-mini-game evidence validates game id, deterministic index/seed, score, accuracy, mistakes, and duration.
- Settlement idempotency uses `matchId` as the stable exactly-once reward key.
- Ranked request/response serialization contracts are prepared for callable Cloud Functions.
- Blaze/Cloud Functions contracts documented for ranked settlement, cosmetic purchase/equip, and 30-day season rollover.
- Automated tests cover reward policy, permanent season stars, seasonal soft reset, multi-level XP, safe coin balances, impossible ranked progress, evidence tampering, and duplicate-settlement prevention.

## Milestone 3.4 — Read model and security boundary

Implemented:

- Read-only `FirestoreCompetitionBackend` prepared for server-populated active season and leaderboard data.
- Read-only `FirestoreEconomyBackend` prepared for owner-only inventory reads.
- Economy writes intentionally fail on Spark until a server-authoritative Blaze implementation exists.
- Firestore rules allow authenticated season/leaderboard reads and owner-only inventory reads while denying all client writes to those authoritative collections.
- Ranked settlement and coin transaction collections remain completely client-inaccessible.
- Feature flags derive from one `BackendPhase.spark/blaze` source of truth.
- Ranked authority, purchases, and live leaderboard remain disabled in Spark phase.

## Milestone 3.5 — Secure cosmetic transaction contracts

Implemented:

- Versioned cosmetic catalog with validation for unique IDs, non-empty names, and non-negative prices.
- Four cosmetic rarity levels: Common, Rare, Epic, Legendary.
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
- Season clock exposes active/closed state, time remaining, and progress.
- Seasonal rollover calculates permanent stars and soft-reset RP from peak tier.
- Tests verify contiguous season boundaries and exact duration.

## Milestone 3.7 — Bilingual visual identity foundation

Implemented:

- Flutter `gen_l10n` enabled as the official localization source.
- Arabic and English ARB catalogs added as first-class game languages.
- App locale follows the device language automatically for Arabic/English.
- Material localization delegates provide native RTL for Arabic and LTR for English.
- Localization parity test prevents one language from silently missing message keys.
- Player-name validation exposes language-neutral validation issues so UI errors are localized.
- Competitive dark navy/cyan/gold visual palette established in shared design tokens.
- Shared theme upgraded for typography, buttons, cards, fields, dialogs, progress bars, and interaction states.
- Home redesigned with stronger player identity, visible prestige stars, localized rank identity, a large PLAY/RESUME surface, and a 2×2 navigation grid.
- Profile redesigned around player identity, localized stats, separate rank and XP progression, and localized editing errors.
- Leaderboard and Season presentation redesigned and localized while keeping live authority disabled on Spark.
- Shop redesigned and localized with localized cosmetic names and rarity presentation.

## Milestone 3.8 — Complete bilingual match journey

Implemented:

- Sign-in, auth loading/error states, and first-time profile setup redesigned and localized.
- Matchmaking redesigned with animated search identity, concise fairness explanation, retry, and cancel states.
- Match room redesigned with player/opponent panels, READY/WAITING identity, leave confirmation, reconnect state, old-registry cleanup, and synchronized 3-2-1 presentation.
- Match play shell redesigned with visible 8-game progress, 3-minute countdown, opponent progress, focused game surface, and end-of-match state.
- Result screen redesigned for Victory/Defeat/Tie with clear visual state, player/opponent score comparison, Rematch, and Home actions.
- Match history redesigned with visual win/loss/tie/cancel states and bilingual score summaries.
- All approved mini-game instructions, prompts, colors, and interaction copy are available in Arabic and English through `MiniGameCopy`.
- Registry display strings are presentation-neutral so internal deterministic metadata cannot leak English copy into Arabic gameplay.
- Test coverage locks the approved mini-game library to exactly 10 games until explicit approval for game 11.
- A bilingual mini-game-copy test verifies all 10 approved game IDs expose non-empty Arabic and English titles.

## Milestone 3.9 — Lightweight graphics and prestige identity

Implemented:

- Shared vector `RankEmblem` family for Bronze, Silver, Gold, Platinum, Diamond, and Master.
- Rank badges consume the vector emblems instead of generic Material rank icons.
- Persistent `SeasonStarBadge` visually upgrades at prestige thresholds while remaining cosmetic-only.
- Home and Profile consume the same season-star prestige identity.
- Shop includes lightweight Flutter-rendered previews for all eight starter cosmetics.
- Starter cosmetic previews include classic/neon avatar frames, timer/crown badges, grid/arena profile backgrounds, and two name styles.
- Visual assets are generated with Flutter vector/widgets instead of heavy binary artwork, preserving APK size and bilingual flexibility.
- No image asset contains baked-in language text.

## Product rules locked

- Match length remains exactly 3 minutes.
- A normal match remains 8 mini-games.
- The approved mini-game library remains exactly 10 games until a proposed new game is shown with an example and explicitly approved before implementation.
- Arabic and English are foundational game languages, not a post-launch translation pass.
- Ranked competition must never alter mini-game difficulty or give paid gameplay advantages.
- Paid or earned shop items are cosmetic only.
- Persistent seasonal stars remain part of the player identity.
- Seasons last exactly 30 days.
- Mini-games remain isolated from authentication, Firestore, ranking, seasons, and economy.

## Spark-safe work completed

- Bilingual app foundation and full player-visible journey.
- Competitive visual system and shared theme.
- Home/Profile/Leaderboard/Season/Shop presentation.
- Matchmaking/Room/Countdown/Play/Result/History presentation.
- Six rank emblems and persistent season-star prestige identity.
- Starter cosmetic previews and four rarity levels.
- Ranked/economy/season domain contracts and safe read models.
- Security flags keeping server-authoritative features off on Spark.
- Ten approved mini-games only; no unapproved game content added.

## Blaze-required authority remaining

The following must not become trusted client writes and require Cloud Functions/Admin SDK before activation:

- accepting ranked match results;
- awarding or removing RP;
- updating wins/losses/games played from ranked matches;
- XP rewards;
- coin rewards and coin spending;
- season rollover and persistent seasonal star awards;
- authoritative leaderboard materialization;
- purchase validation and entitlement grants;
- cosmetic equip writes;
- anti-cheat and suspicious-result rejection.

## Validation/deployment remaining

These are execution gates, not unfinished UI architecture:

1. Run Flutter dependency generation so `gen_l10n` emits the generated localization code.
2. Run `flutter analyze`, full `flutter test`, and Android debug build on the latest `main`.
3. Fix any compile/lint/test issue exposed by that run.
4. Deploy the latest Firestore rules because Section 3 added new competition/economy read boundaries after the earlier successful rules deployment.
5. Perform deferred two-device multiplayer QA when devices are available.
6. Enable Blaze only when ready to deploy the authoritative server package and then switch `BackendPhase` in a controlled release.

## Next engineering block

1. Prepare the Cloud Functions implementation package without activating it on Spark.
2. Add server-side ranked settlement, economy purchase/equip, season rollover, and leaderboard materialization behind the existing contracts.
3. Keep `BackendPhase.spark` until deployment, security verification, and Blaze billing readiness are confirmed.
4. Run automated Flutter validation and Firestore-rules compilation before any production release.
