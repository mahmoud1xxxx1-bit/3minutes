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

## Spark security boundary

This milestone is intentionally Spark-compatible. Firestore rules constrain queue and match writes, but client-side matchmaking cannot be fully authoritative against a hostile modified client. In particular, queue claiming and initial seed creation are still client-originated.

When Blaze is enabled, these operations must move behind Cloud Functions without changing the UI, mini-game contract, or `MatchBackend` callers:

- opponent claim / match creation;
- authoritative seed generation;
- start-time validation;
- result acceptance;
- ranked scoring and anti-cheat.

## Next milestone

Milestone 2.2 will add the local match runtime:

- transition from countdown to active play;
- fixed 180-second match clock;
- current mini-game index and normalized per-game result tracking;
- progress comparison;
- finish / timeout rules;
- disconnect and resume groundwork.

Playable mini-game widgets follow on top of that runtime rather than embedding match logic inside individual games.
