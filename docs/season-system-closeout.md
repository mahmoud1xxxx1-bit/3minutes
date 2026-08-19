# Season System Closeout

Status: IN PROGRESS — scale hardening and final APK validation pending.

This document is updated continuously with the current Season / Soft Reset / Prestige Stars hardening work. Exact season-boundary correctness is now validated; the remaining open item in this subsystem is production-scale rollover architecture plus the final whole-app APK validation later in the project.

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
- At rollover acquisition the season is atomically changed to `active: false` and `rolloverState: processing` before standings are read. Existing settlement code already requires an active season, so transactions that race with this lock retry against the closed state instead of mutating standings after the snapshot.
- If rollover execution fails after acquiring the lock, the scheduler can resume a season whose `rolloverState` is `processing`; per-player grants remain idempotent through `seasonRolloverGrants`.
- The next season is activated only in the final rollover transaction after the old season's player grants are processed.

This guarantees that a legal Ranked match cannot be moved into the next season and that the standings snapshot cannot be changed by a late settlement after rollover has acquired the lock.

## Locked economy/prestige policy

Prestige Stars remain permanent account history and are never spent. Season close awards and the next-season Soft Reset are both based on the highest tier reached during that season (Peak Rank), not the player's final-day tier.

Current reward and reset tables are unchanged in this hardening batch. Rebalancing requires an explicit product decision.

## Validation evidence

The exact boundary implementation passed the dedicated No-APK validation on GitHub Actions run `32220593908` via temporary PR #62. The PR was closed **without merge** after validation.

Validated successfully:

- Cloud Functions TypeScript build;
- Cloud Functions policy/unit tests, including exact boundary tests;
- Firestore emulator security tests;
- Flutter dependency resolution;
- `flutter analyze`;
- full `flutter test` suite.

A previous validation attempt correctly failed on a TypeScript snapshot typing error in `season.ts`; that error was fixed and the full validation was rerun from the beginning until green. No APK was built in this validation cycle.

Additional policy coverage includes:

- owner-only Season History and denied client writes;
- ties contributing to season match count;
- Peak Rank, not current rank, controlling projected Stars and Soft Reset;
- server W/L/T accounting;
- server Stars/Soft Reset tables;
- exact final legal Ranked-admission millisecond;
- full five-minute settlement grace before rollover can acquire the season lock.

## Scale gate still open

The current rollover implementation still loads the complete season leaderboard and processes player rollover grants sequentially. This is deterministic and idempotent for the current development/validation scale, but it is **not accepted as a one-million-player production architecture**.

Before final production readiness, season rollover must be redesigned or distributed so that:

- it never requires loading a million leaderboard entries into one function invocation;
- it never depends on one 540-second invocation finishing all player grants;
- retries preserve exact final standings and exactly-once Star/reset/history outcomes;
- next-season availability is not blocked for an unacceptable duration;
- Firestore reads/writes and Cloud Functions invocations are bounded and measurable.

This scalability item is explicitly tracked for the million-player cost/capacity audit and must be resolved before the project is declared fully production-ready.
