# Season System Closeout

Status: IN PROGRESS — distributed rollover source/CI validated; Season Pass hardening and final APK acceptance remain.

This document is updated continuously with the current Season / Soft Reset / Prestige Stars hardening work. Exact season-boundary correctness and the distributed rollover architecture are now validated at source/CI level. Production deployment still requires Blaze, Cloud Tasks/IAM readiness, the tracked Firestore index, and final APK/device acceptance.

## Work in this batch

- Ranked matchmaking is explicitly bound to one active `seasonId`.
- Ranked queue candidates must belong to the same active season.
- Ranked match creation re-checks the season inside the match-claim transaction.
- Ranked rematches remain inside the original season and are rejected after that season stops accepting new Ranked matches.
- Ranked settlement uses the match-bound season rather than whichever season is active later.
- Existing settlement payloads are returned only after re-verifying that the caller is a match participant.
- Lifetime profile wins/losses are separated from season leaderboard wins/losses/ties.
- Seasonal ties are recorded explicitly and count toward season matches/history.
- Season History uses `seasonHistory/{uid}/seasons/{seasonId}` and is owner-readable/server-writable only.
- The Season screen has a player progress projection for current rank, Peak Rank, W/L/T, permanent Stars expected at close, and Soft Reset RP based on Peak Rank.
- Completed Season History is displayed only when authoritative live competition data is enabled; Spark does not invent values.

## Exact season-boundary policy

The previous release gate around a match still running at the exact season boundary is protected by a central server policy in `functions/src/season_boundary.ts`.

The policy is intentionally stricter than `now < endsAt`:

- New Ranked admission closes while enough time still remains for the 3-second countdown, the full 180-second match, and the final 15-second evidence transport allowance.
- Current guard: `3s + 180s + 15s = 198 seconds` before `endsAt`.
- Ranked queue match creation checks the guard both before queueing and again inside the transactional claim.
- The transition that starts the synchronized countdown checks the guard again, preventing players from creating a room early and waiting until the final seconds to start it.
- Ranked rematches use the same guard.
- Rollover does not freeze standings exactly at `endsAt`; it waits an additional five-minute settlement grace.
- At rollover acquisition the season is atomically changed to `active: false` and `rolloverState: processing` before standings are processed. Existing settlement code requires an active season, so transactions racing the lock cannot mutate frozen standings.
- The next season is activated only after every discovered rollover page has completed exactly once.

This guarantees that a legal Ranked match cannot be moved into the next season and that the final standings cannot be changed by a late settlement after rollover has acquired the lock.

## Distributed rollover architecture

The previous implementation loaded the complete leaderboard and iterated every player inside one scheduled Function. That design was correct at development scale but explicitly rejected for a one-million-player production target.

The source now uses a distributed page pipeline:

- `rolloverRankedSeason` is only the coordinator/lock owner.
- The coordinator runs every five minutes instead of hourly so post-season scheduling delay is bounded more tightly.
- It atomically freezes the ended season, initializes rollover counters, and enqueues page 0.
- `processSeasonRolloverPage` is a Firebase task-queue function in `me-central2`.
- Leaderboard traversal is server-index ordered by `rankPoints DESC`, `wins DESC`, `losses ASC`, then document ID ASC for a deterministic total order.
- Each task reads at most 200 leaderboard entries.
- Each page enqueues its deterministic next page after discovering its cursor, so rollover does not depend on one long invocation holding the whole leaderboard.
- Task IDs use `season_<seasonId>_page_<offset>` so enqueue retries cannot create an uncontrolled duplicate task tree.
- Cloud Tasks retry policy is bounded and backs off on transient failures.
- Queue dispatch is rate-limited to protect Firestore and Functions from an uncontrolled rollover spike.
- Within a page, player grants are processed with bounded concurrency rather than 200 unbounded simultaneous transactions.
- Per-player `seasonRolloverGrants` remain the exactly-once entitlement guard for Stars, reset RP, history and Legendary-season increments.
- Every page writes a separate completion marker in `seasonRolloverPages/{seasonId}/pages/{offset}` before contributing to `rolloverCompletedEntries`, so a retried page cannot double-increment progress.
- The last discovered page sets `rolloverExpectedEntries`.
- Finalization occurs only when `rolloverCompletedEntries >= rolloverExpectedEntries`.
- The final transaction closes the old season and activates the next season exactly once.
- An empty leaderboard is valid: page 0 records an expected count of zero and finalizes safely.

This removes the previous full-leaderboard memory requirement and the requirement to finish one million grants in one 540-second Function invocation.

## Firestore indexing for rollover

The repository tracks `firestore.indexes.json` and `firebase.json` references it alongside the rules file.

The required leaderboard index is tracked in source for:

- `rankPoints DESC`
- `wins DESC`
- `losses ASC`
- Firestore document-name ordering is the deterministic UID tie-break used by the query.

This index is a production deployment requirement before the distributed rollover worker runs against live Firestore.

## Locked economy/prestige policy

Prestige Stars remain permanent account history and are never spent. Season close awards and the next-season Soft Reset are both based on the highest tier reached during that season (Peak Rank), not the player's final-day tier.

Current reward and reset tables are unchanged in this hardening batch. Rebalancing requires an explicit product decision.

## Validation evidence

### Exact-boundary validation

GitHub Actions run `32220593908`, temporary PR #62, closed without merge:

- Cloud Functions TypeScript build ✅
- Cloud Functions policy/unit tests ✅
- Firestore emulator security tests ✅
- Flutter dependency resolution ✅
- `flutter analyze` ✅
- full `flutter test` ✅
- APK build: not run

### Distributed-rollover validation

GitHub Actions run `32221542284`, job `95972796567`, temporary PR #63, closed without merge:

- Cloud Functions dependencies ✅
- Cloud Functions TypeScript build and tests, including task-queue source ✅
- Firestore emulator rules/security tests ✅
- Flutter setup/dependencies ✅
- `flutter analyze` ✅
- full `flutter test` ✅
- APK build: not run

This proves source/CI compatibility of the distributed Cloud Tasks implementation. It does **not** prove production Cloud Tasks/IAM/index deployment because the project remains in the controlled Spark/pre-Blaze phase.

Additional policy coverage includes:

- owner-only Season History and denied client writes;
- ties contributing to season match count;
- Peak Rank, not current rank, controlling projected Stars and Soft Reset;
- server W/L/T accounting;
- server Stars/Soft Reset tables;
- exact final legal Ranked-admission millisecond;
- full five-minute settlement grace before rollover can acquire the season lock.

## Current open work discovered by the economy audit

The Season Pass implementation is currently being hardened. The previous state lived at `seasonPass/{uid}` without an explicit `seasonId`, so Season XP and claimed tier arrays could behave as lifetime state rather than one 30-day season. Claim receipt IDs were also not season-scoped. This is being treated as a real correctness defect, not deferred documentation.

The required invariant is that Season XP, pass tier progress and tier claims belong to one explicit season, while permanent account progression remains separate. Old-season completed mission rewards must not be able to inject Season XP into a new season.

## Remaining production-scale considerations for the final owner report

The distributed design removes the single-function memory/timeout bottleneck, but the final million-player report must still quantify:

- reads/writes per player rollover transaction;
- page-query reads;
- task count (`ceil(entries / 200)` at current page size);
- Cloud Tasks cost;
- Functions compute duration at configured queue limits;
- expected end-to-end rollover time at 100K / 1M players;
- whether player rollover transactions should be further reduced or denormalized;
- operational alarms for a season stuck in `processing`;
- deployment of the required Firestore composite index;
- Blaze/IAM requirements for Cloud Tasks enqueue/invoke permissions.

These points remain explicitly tracked for the final financial/capacity report rather than hidden behind a generic “scales automatically” claim.
