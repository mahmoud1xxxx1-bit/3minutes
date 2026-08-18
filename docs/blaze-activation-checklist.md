# Blaze Activation Checklist

Do not switch `AppConfig.backendPhase` from `spark` to `blaze` until every item below is complete.

## Ranked authority

- Deploy authenticated ranked settlement callable/function.
- Function loads the match server-side by `matchId`.
- Verify both participants and authenticated caller.
- Verify match registry version, match seed, game count, start/end timing, and final status.
- Validate compact `MiniGameEvidence` against the deterministic game sequence and per-game seeds.
- Reject impossible score/accuracy/mistake/duration values.
- Use `matchId` as the exactly-once settlement key.
- Commit RP, W/L, games played, XP, coins, season player state, leaderboard entry, settlement record, and coin ledger atomically or transactionally.
- Return `RankedMatchSettlement` using the documented serialized contract.

## Season authority

- Create exactly one active season.
- Enforce 30-day duration.
- Track each player's peak tier for the active season.
- Scheduled rollover awards permanent stars from peak tier.
- Apply centralized soft RP reset.
- Close previous season and create the next season with contiguous timestamps.
- Rollover must be idempotent.

## Economy authority

- Deploy authenticated purchase function.
- Read price from the server-approved/versioned catalog, never from client input.
- Reject duplicate ownership and insufficient balance.
- Write inventory grant and negative coin ledger transaction atomically.
- Return authoritative `PurchaseReceipt`.
- Deploy authenticated equip function.
- Reject unowned or unknown cosmetics.
- Update only the cosmetic's correct slot and return authoritative inventory.

## Firestore/security

- Keep client writes denied for seasons, leaderboards, inventories, ranked settlements, and coin transactions.
- Admin SDK/Cloud Functions owns authoritative writes.
- Verify App Check/rate-limiting strategy before public ranked launch.
- Create required Firestore indexes for live leaderboard queries.

## Flutter activation

Only after backend/security verification:

1. Change `AppConfig.backendPhase` to `BackendPhase.blaze`.
2. Provide callable implementations of `RankedAuthorityBackend` and `EconomyBackend` write operations.
3. Confirm live season + leaderboard read models are populated.
4. Confirm Shop inventory documents exist for users.
5. Run analyze/tests/build.
6. Run two-device ranked QA including duplicate settlement retry and reconnect.
7. Verify no paid cosmetic changes gameplay behavior.

Until this checklist passes, Spark mode must keep ranked authority, live leaderboard, and economy purchases disabled.
