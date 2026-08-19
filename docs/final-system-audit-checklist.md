# Final System Audit & Owner Report Checklist

Status: TRACKED — complete only after code closeout, final CI, and final APK acceptance.

This document locks the scope of the final owner-facing report so no requested analysis is forgotten while implementation continues.

## Evidence rule

The final report must distinguish clearly between:

- source implementation confirmed in GitHub;
- automated test/CI evidence;
- final APK/device acceptance evidence;
- live Firebase/Google Play deployment state;
- estimates or projections;
- current external Firebase pricing verified from official sources at report time.

No production-live claim may be inferred from source code or CI alone.

## Full product/system coverage required

The final report must cover, at minimum:

- exact 3-minute / 8-mini-game gameplay contract;
- all ten approved mini-games and deterministic fairness;
- Ranked, Quick, Private and Party modes;
- RP rules, rank ladder, Peak Rank and Legendary repeat prestige;
- XP, levels and progression curve;
- Coins earned/spent and economy sinks/sources;
- Prestige Stars and their permanent threshold behavior;
- 30-day Season lifecycle;
- season boundary, settlement grace, Season History and Soft Reset;
- Leaderboard ordering and season standings;
- Missions, Daily/Weekly progress, Achievements and Season Pass;
- Friends, requests, blocks, recent players and friend codes;
- Private rooms, Party rooms, room codes and invitation/deep-link flow;
- Profile and every public identity surface;
- all rank emblems/badges and their unlock/showcase behavior;
- Shop catalog, all 45 avatars, non-avatar cosmetics, prices/unlock paths and ownership persistence;
- Coin, Prestige, Earned and Google Play purchase security;
- all cosmetic previews and runtime delivery surfaces;
- Cosmic Flow visuals, Arabic/English and accessibility;
- anti-cheat/evidence/settlement authority;
- Firestore rules, App Check, Cloud Functions and deployment gates;
- known residual risks, abuse paths, scaling bottlenecks and recommended mitigations.

## Player earning simulation required

The final report must calculate the actual current policy results, not generic examples, for at least these daily Ranked volumes:

- 20 matches/day;
- 50 matches/day;
- 100 matches/day;
- 200 matches/day;
- 500 matches/day.

For each volume, provide separate realistic outcome models, including at least:

- 100% wins (upper-bound source generation);
- 60% wins / 40% losses;
- 50% wins / 50% losses;
- 40% wins / 60% losses;
- loss-heavy / abuse-oriented farming case where relevant;
- tie impact where it materially changes rewards.

For each scenario show:

- daily Coins;
- 30-day Coins;
- daily XP;
- 30-day XP;
- expected RP direction/change with RP floor behavior;
- approximate level progression from the actual XP curve;
- likely time commitment given the exact three-minute match cap;
- purchasing power against current Shop Coin prices;
- whether reward generation risks inflation or trivializes progression.

The report must explicitly call out impossible human-play scenarios and distinguish them from bot/farm/security load tests. For example, 500 full three-minute matches represents 25 gameplay hours before queue/menu overhead, so it is a useful abuse/capacity model but not a legitimate single-human daily behavior target.

## Million-player Firebase/cost study required

Use current official Firebase / Google Cloud pricing at final-report time and state region/currency assumptions.

Model at least:

- 1,000,000 registered players;
- multiple DAU ratios rather than assuming every registered player is daily active;
- low, normal, high and abuse traffic;
- 20/50/100/200/500 Ranked matches per active player where useful as stress bounds.

Break cost drivers apart rather than giving one unexplained total:

- Firestore document reads;
- Firestore document writes/deletes;
- index/aggregation impact where applicable;
- Cloud Functions invocations;
- function CPU/memory duration;
- network egress;
- Firebase Authentication relevant costs/limits;
- App Check implications;
- Storage/download traffic for cosmetic assets if Firebase-hosted;
- scheduled jobs / season rollover;
- Google Play verification-related backend calls where relevant;
- observability/logging risk at very high volume.

For each major game action, estimate the backend operation budget from the actual code path, then scale it to player volume. The final study must identify which actions dominate cost and which can be cached, aggregated, batched, made lazy, or removed.

## Required financial-risk conclusions

The owner report must answer plainly:

- What is the expected Firebase spend range under realistic DAU assumptions?
- What is the worst plausible spend if matchmaking or clients are abused?
- Which endpoints need quotas/rate limits/budgets before public launch?
- Which reads/writes are unnecessarily repeated?
- Does any player reward loop generate Coins/XP faster than intended?
- Can free farming undermine paid cosmetics?
- Is a million-player season rollover technically and financially safe?
- What changes must happen before Blaze activation?
- What budget alerts / hard operational safeguards should be configured?

## Final delivery format

The final owner-facing report must be highly structured and readable, using detailed tables where comparison matters. It should finish with a prioritized matrix:

`Area | Current status | Risk | Player impact | Financial impact | Required action | Priority`

This report is produced only after implementation closeout and the final APK acceptance cycle, so its conclusions reflect the product actually being shipped rather than an intermediate build.
