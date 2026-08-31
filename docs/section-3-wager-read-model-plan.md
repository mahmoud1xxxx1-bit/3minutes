# Section 3 — Ranked wager read-model closure

Goal: expose server-stored Ranked wager values to Flutter without moving any settlement authority to the client.

- Add backward-compatible `wagerCoins` and `wagerPotCoins` fields to `MatchSession`, defaulting to zero for Quick/legacy matches.
- Parse those fields from Firestore in `FirestoreMatchBackend._sessionFromDoc`.
- Add focused parser/domain coverage.
- Do not compute settlement or mutate balances on the client.
