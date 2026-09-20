# Section 3 Runtime Readiness

Status: SPARK-SAFE CLIENT COMPLETE FOR CURRENT COMPETITION/ECONOMY SHELL

## Competition runtime

- `CompetitionBackend` is wired from `main` through `AuthGate` and `HomeScreen` into `LeaderboardScreen`.
- Spark keeps `liveLeaderboardEnabled == false`, so the screen does not perform live season/leaderboard reads.
- Blaze mode can expose the active season and leaderboard through the existing backend without changing navigation or presentation contracts.
- Active season presentation includes season number, local minute-by-minute countdown, and season progress.
- Leaderboard ordering has deterministic tie-breaking.

## Economy runtime

- `EconomyBackend` is wired from `main` through `AuthGate` and `HomeScreen` into `ShopScreen`.
- Spark keeps `economyPurchasesEnabled == false`, so the Shop performs no purchase/equip actions and does not depend on inventory documents.
- Blaze mode can expose owner inventory, coin balance, BUY and EQUIP actions through the same screen.
- Purchase actions expect an authoritative `PurchaseReceipt`.
- Equipment actions expect authoritative inventory state.

## Ranked integrity

- Ranked settlement requires a `RankedSettlementRequest` rather than only a match ID.
- The request carries compact per-mini-game evidence.
- Evidence contains game ID, index, deterministic game seed, score, accuracy, mistakes, and duration.
- Evidence validation checks the deterministic `GameRegistry` sequence and exact per-game seed formula.
- This remains compact: no tap/swipe event stream is uploaded.
- `matchId` remains the exactly-once settlement key.

## Mini-game content safety

- `GameRegistry` v2 produces deterministic eight-game matches with category coverage.
- `MiniGameEngineRegistry` maps every registered game to a playable engine family.
- `MiniGameContentPolicy` fails tests when a registry game has no engine or an engine has no descriptor.
- New game IDs must not be added until their playable host path exists.

## Deferred intentionally

- Cloud Functions deployment and authoritative writes require Blaze.
- Physical two-device multiplayer QA remains deferred by the user.
- Expansion beyond the first 10 playable mini-games will happen only through playable engine-backed content, not placeholder IDs.
