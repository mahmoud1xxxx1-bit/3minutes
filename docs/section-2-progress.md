# Section 2 — Multiplayer Core Progress

Status: IN PROGRESS

## Milestone 2.1 — Matchmaking foundation

Implemented:

- Blaze-ready `MatchBackend` abstraction.
- Spark implementation using Firestore.
- Authenticated matchmaking queue.
- Transactional two-player claim so two clients converge on one match document.
- Match session model with player snapshots, seed, registry version, readiness, and countdown timestamp.
- Home `PLAY` button connected to matchmaking.
- Waiting/cancel UI.
- Shared match room for both players.
- Per-player READY state.
- Server-timestamp-backed 3-2-1 countdown after both players are ready.
- Deterministic seed-based mini-game order.
- Mini-game SDK data contract (`MiniGameConfig`, `MiniGameResult`).
- `GameRegistry` v1 with 10 representative game IDs and deterministic selection of 8 per match.
- Automated tests proving the same seed produces the same eight-game order.

## Milestone 2.2 — Live match runtime

Implemented:

- Fixed 180-second local match runtime derived from the shared match start.
- Current mini-game index and deterministic per-game seed.
- Normalized result validation before a game may advance.
- Aggregate progress: completed games, score, accuracy, mistakes, and elapsed game time.
- Firestore progress synchronization only after each mini-game ends, not for every interaction.
- Separate progress fields for player A and player B with forward-only Firestore rule checks.
- Finish-time timestamp for players who complete all 8 games.
- Deterministic outcome resolver: completion first, then progress, accuracy, score, mistakes, and elapsed time.
- Resume ticket support so an interrupted player can re-enter the same match.
- Runtime restoration from the last synchronized completed-game index.
- Result screen and ticket cleanup before returning home.
- Reusable Flutter mini-game host with 10 representative registered games built on shared interaction engines.

The 10 representative IDs are:

1. `tap_target`
2. `quick_math`
3. `color_match`
4. `odd_one_out`
5. `memory_flash`
6. `direction_swipe`
7. `number_order`
8. `shape_count`
9. `reaction_stop`
10. `symbol_pair`

A match deterministically selects 8 from this registry. These are validation content for the SDK and architecture, not the final 100-game content library.

## Spark security boundary

This milestone is intentionally Spark-compatible. Firestore rules constrain queue, readiness, and forward-only progress writes, but client-side matchmaking cannot be fully authoritative against a hostile modified client. Queue claiming, initial seed creation, and result values still originate on a client.

When Blaze is enabled, these operations must move behind Cloud Functions without changing the UI, mini-game contract, or `MatchBackend` callers:

- opponent claim / match creation;
- authoritative seed generation;
- start-time validation;
- result acceptance;
- ranked scoring and anti-cheat.

## Remaining before Section 2 closes

- Validate Milestones 2.1 and 2.2 on two authenticated Android clients.
- Harden cancel/disconnect behavior so an abandoned room cannot strand the opponent.
- Add reconnect status messaging.
- Add rematch flow.
- Add match history storage/read path.
- Complete timeout/finalization edge-case tests.
- Final `flutter analyze`, `flutter test`, Android APK build, and physical two-client QA.
