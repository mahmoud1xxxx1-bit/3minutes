# Season System Closeout

Status: IN PROGRESS — validation pending.

This document is updated continuously with the current Season / Soft Reset / Prestige Stars hardening work. Final validation evidence will be appended after the dedicated No-APK run.

## Work in this batch

- Ranked matchmaking is now explicitly bound to one active `seasonId`.
- Ranked queue candidates must belong to the same active season.
- Ranked match creation re-checks the season inside the match-claim transaction.
- Ranked rematches remain inside the original season and are rejected after that season closes.
- Ranked settlement uses the match-bound season rather than whichever season is active later.
- Existing settlement payloads are returned only after re-verifying that the caller is a match participant.
- Lifetime profile wins/losses are separated from season leaderboard wins/losses/ties.
- Seasonal ties are now recorded explicitly and count toward season matches/history.
- Season History uses `seasonHistory/{uid}/seasons/{seasonId}` and is owner-readable/server-writable only.
- The Season screen now has a player progress projection for current rank, Peak Rank, W/L/T, permanent Stars expected at close, and Soft Reset RP based on Peak Rank.
- Completed Season History is displayed only when authoritative live competition data is enabled; Spark does not invent values.

## Locked economy/prestige policy

Prestige Stars remain permanent account history and are never spent. Season close awards and the next-season Soft Reset are both based on the highest tier reached during that season (Peak Rank), not the player's final-day tier.

Current reward and reset tables are unchanged in this hardening batch. Rebalancing requires an explicit product decision.

## Production boundary still under review

The scheduled rollover is still a Blaze-only production concern. A match starting very near the nominal season boundary must never be credited to a different season. The new explicit `seasonId` binding prevents that corruption. Final production rollout must also define/validate the handling of an in-flight match if the scheduler attempts rollover before its settlement completes; this remains a release gate rather than being hidden by a client-side workaround.
