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

## Milestone 2.3 — Recovery, rematch, and history

Implemented:

- Pre-start match cancellation with confirmation.
- Opponent-visible cancelled-room state.
- Cancellation is unavailable once the synchronized countdown starts.
- Reconnect/resume from the existing matchmaking ticket.
- Local runtime reconciliation against Firestore when the server has saved progress that the device did not acknowledge.
- Deterministic replay safety: after reconnect, the player resumes the next unsaved mini-game using the original match/game seed.
- Central settlement rule: a result becomes final only when both players finish or the shared 3-minute deadline expires.
- Early finishers wait for the opponent instead of receiving a premature result.
- Match status finalization after settlement.
- Same-opponent rematch requests.
- A new rematch document is created only after both players accept, with a fresh seed and reset progress.
- Players may retract a rematch request by returning home before the opponent accepts.
- Ticket repointing to the agreed rematch so reconnect continues to work.
- Match history read path from existing match documents without duplicating result storage.
- History UI showing settled/cancelled matches only.
- Additional automated tests for reconnect restoration and timeout settlement boundaries.

## Spark security boundary

This milestone is intentionally Spark-compatible. Firestore rules constrain queue, readiness, forward-only progress writes, cancellation, finalization, and rematch state changes, but client-side matchmaking cannot be fully authoritative against a hostile modified client. Queue claiming, initial seed creation, and normalized result values still originate on a client.

When Blaze is enabled, these operations must move behind Cloud Functions without changing the UI, mini-game contract, or `MatchBackend` callers:

- opponent claim / match creation;
- authoritative seed generation;
- start-time validation;
- result acceptance;
- rematch match creation;
- ranked scoring and anti-cheat.

## Remaining before Section 2 closes

- Validate the complete multiplayer path on two authenticated Android clients.
- Validate cancel-before-start on both devices.
- Validate disconnect/reopen/resume during a live match.
- Validate both rematch acceptance and rematch withdrawal.
- Validate match history after a completed and a cancelled match.
- Final `flutter analyze`, `flutter test`, Android APK build, and Firestore rules deploy.
- Physical two-client QA before marking Section 2 CLOSED.
