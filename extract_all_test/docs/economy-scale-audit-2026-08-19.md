# 3 Minutes — Economy, Scale, Cost and Abuse Audit

Date: 2026-08-19
Repository: `mahmoud1xxxx1-bit/3minutes`
Reference source state when audit started: `3c0bea6221da940123df279ff83b045f4b628252`

This document is a planning/audit reference. It separates verified source facts from modeled infrastructure estimates. Cloud prices change; production invoices must be checked against the live Google Cloud billing account and Cloud Monitoring metrics.

## 1. Ranked economy — verified source contract

Ranked rewards are server-authoritative:

- Win: +30 RP, +120 XP, +30 Coins.
- Loss: -18 RP, +55 XP, +10 Coins.
- Tie: +8 RP, +80 XP, +18 Coins.
- RP never falls below zero.
- Rank thresholds: 0 / 500 / 1200 / 2200 / 3500 / 5000 / 7000 / 10000.

For a no-tie player at 50% win rate, mathematical average per match is:

- +6 RP.
- 87.5 XP.
- 20 Coins.

This means Ranked RP is intentionally inflationary rather than zero-sum. A decisive two-player match creates +12 net RP across the two accounts. Seasonal reset is therefore required to control long-term ladder inflation.

### Approximate first-season Legendary workload

Ignoring ties and variance:

| Win rate | Expected RP/match | Matches to 10,000 RP | Average matches/day over 30 days |
|---|---:|---:|---:|
| 50% | 6.0 | 1,667 | 55.6 |
| 55% | 8.4 | 1,190 | 39.7 |
| 60% | 10.8 | 926 | 30.9 |
| 70% | 15.6 | 641 | 21.4 |

Conclusion: first-season Legendary is difficult for average players and becomes realistic mainly for high-skill/high-engagement players. That is appropriate for the top rank.

Legendary resets to 5,000 RP after a Legendary-peak season, so repeat Legendary seasons are intentionally easier than the first climb.

## 2. Quick economy — verified source contract

Quick rewards:

- Win: 70 XP / 18 Coins.
- Tie: 50 XP / 12 Coins.
- Loss: 30 XP / 6 Coins.
- RP delta is always zero.

Same-pair anti-farming:

- pair matches 1–10/day: 100% reward;
- 11–20/day: 25% reward;
- after 20/day: 0% farmable reward for that exact pair.

The transaction increments pair usage and rewards atomically, so concurrent settlements cannot trivially bypass the same-pair counter.

### Remaining Quick abuse risk

The limiter is keyed to the exact player pair, not the account's total Quick volume. A bot farm can rotate multiple accounts/opponents to avoid the same-pair limit. Before production scale, consider a second server-side per-account daily reward budget/diminishing curve in addition to the pair limiter. This is a product/economy decision and is not silently changed by this audit.

## 3. Social / Private / Party reward economy

Social settlement verifies deterministic evidence and uses a same-group daily multiplier:

- first 5 matches with the exact participant group: 100%;
- next 5: 35%;
- after 10: 0%;
- base placement Coins: 20 / 14 / 11 / 8 depending on placement.

Social play advances friend-match mission/achievement progress.

### Remaining Social abuse risk

The limiter is keyed to the exact group. Rotating one participant changes the key and can restore the full multiplier. At production scale a per-player social-reward budget should be considered so coordinated alt-account rotation cannot generate unlimited social Coins.

## 4. Missions — verified reward catalog

Daily:

- Play 3: 60 Coins / 80 Season XP.
- Win 1: 75 Coins / 100 Season XP.
- Friend match 1: 50 Coins / 70 Season XP.
- Maximum daily mission total: 185 Coins / 250 Season XP.

Weekly:

- Play 30: 450 Coins / 700 Season XP.
- Win 15: 600 Coins / 900 Season XP.
- Friend matches 5: 350 Coins / 550 Season XP.
- Maximum weekly mission total: 1,400 Coins / 2,150 Season XP.

Mission claims are server-authoritative and ledgered. The Season Pass is progressed by Season XP from claimed mission rewards, not ordinary match XP. This is a useful anti-grind property: playing hundreds of extra matches does not directly accelerate the pass after mission objectives are exhausted.

## 5. Achievement Coin sources

One-time achievement rewards include:

- first win: 100;
- 10 wins: 250;
- 100 wins: 1,000;
- 500 wins: 3,000;
- 1,000 matches: 5,000;
- 10-win streak: 1,500;
- 50 friend matches: 750;
- 10 six-player wins: 1,200;
- 10 seasons: 4,000;
- 100 Prestige Stars: 3,000.

These are finite sources and therefore do not create unlimited long-run Coin inflation by themselves.

## 6. Season Pass economy

Season Pass level:

`level = min(30, 1 + floor(seasonXp / 500))`

Free level reward:

`40 + 10 × level` Coins.

Premium level reward:

`100 + 20 × level` Coins.

If all 30 levels are reached and claimed:

- Free track total: 5,850 Coins.
- Premium track additional total: 12,300 Coins.

Premium Season Pass contract:

- product: `premium_season_pass_30d`;
- prepaid Google Play base plan: `prepaid-30d`;
- reference price: USD 30 per 30-day season;
- entitlement is bound only to the active season;
- Google Play server verification and acknowledgement are required;
- no automatic carry to the next season.

### Premium Prestige Star clarification

The latest approved product policy explicitly allows up to five permanent Prestige Stars to be **earned through gameplay after purchasing Premium access**:

- Level 6: +1 Star.
- Level 12: +1.
- Level 18: +1.
- Level 24: +1.
- Level 30: +1.

Maximum: 5 Premium-pass Stars per season.

The correct rule going forward is therefore:

> Prestige Stars are permanent and non-consumable; they are not sold as a direct currency pack. Normal seasonal Stars are earned from Peak Rank, and a verified Premium Season Pass may additionally expose up to five gameplay-earned Star milestones during that season.

Payment alone does not grant all five Stars.

## 7. Normal seasonal Prestige Stars

Peak-rank rollover awards:

- Bronze: 1.
- Silver: 2.
- Gold: 4.
- Platinum: 7.
- Diamond: 11.
- Master: 16.
- Grand Master: 24.
- Legendary: 35.

Star-gated cosmetics are thresholds; Stars are not deducted when an item unlocks.

Because a Bronze player normally earns only 1 Star at rollover while Premium can add up to 5, Premium materially accelerates Star-threshold access for low-rank players. This is the intended current approved Premium policy, but should be watched in live telemetry to ensure prestige perception remains healthy.

## 8. Coin sinks — verified shop totals

Coin-priced avatar total: 112,200 Coins.

Other Coin cosmetic total: 121,950 Coins.

Total current Coin-catalog sink: **234,150 Coins**.

Individual Coin avatars: 1,600–11,000.

Other Coin cosmetics: 500–30,000.

The sink is large enough that ordinary users cannot instantly complete the catalog.

## 9. Example monthly Coin generation

Planning model assumptions:

- Ranked only for direct match Coins;
- no ties;
- 50% win rate => 20 Coins/match average;
- player completes all Daily + Weekly missions including friend missions;
- reaches Level 30 of the Season Pass;
- excludes one-time achievements.

| Ranked matches/day | Free-track monthly Coins | With Premium track |
|---:|---:|---:|
| 5 | ~20,400 | ~32,700 |
| 10 | ~23,400 | ~35,700 |
| 20 | ~29,400 | ~41,700 |
| 50 | ~47,400 | ~59,700 |
| 100 | ~77,400 | ~89,700 |

At 20 Ranked matches/day, completing every current Coin item would take roughly eight seasons/months if the player spent Coins only on the current catalog. At 50/day it is roughly five months. This is a healthy long-term collection horizon for the current catalog, assuming new cosmetics are added over time.

## 10. Human-time sanity / bot-risk thresholds

A match is exactly three minutes, excluding queue, countdown, results and navigation.

Raw minimum gameplay time:

- 20 matches/day: 1 hour.
- 50: 2.5 hours.
- 100: 5 hours.
- 200: 10 hours.
- 500: 25 hours and therefore physically impossible in one day.

Recommended anti-abuse telemetry, not yet a hard product rule:

- >100 completed matches/day: high-engagement / risk flag.
- >200/day: extreme-risk flag requiring integrity review.
- ≥480/day is mathematically impossible even before queue/UI overhead and should be treated as automation/data-integrity evidence.

Do not hard-ban solely from one threshold without checking reconnect/retry/idempotency data; use server settlement IDs and evidence first.

## 11. Ranked backend operation model

A full two-player Ranked match has 16 mini-game evidence submissions: 8 per player.

Each evidence submission currently performs approximately:

- 2 document reads (match + player evidence);
- 2 document writes (evidence + match progress).

That alone is approximately 32 reads + 32 writes per full match.

Settlement then reads match, prior settlement, season, two evidence docs, two profiles, two inventories and two leaderboard entries, and writes profiles, inventories, leaderboard entries, Coin ledgers, match and settlement.

The Ranked-settlement progression trigger then performs additional profile/mission/achievement/idempotency reads and writes for both players.

For planning this audit uses a deliberately conservative rounded baseline of **60 document reads + 60 document writes per Ranked match** before UI realtime-listener overhead. The exact production number will vary with matchmaking retries, reconnects, listeners, empty queries and retries.

Callable/event count planning baseline: about **22 backend invocations per completed Ranked match** (queue/ready/results/settlement/progression), again excluding polling/reconnect extras.

## 12. Firestore Standard planning prices — me-central2

Official Google Cloud Firestore pricing currently lists for the selected location group:

- document reads: $0.03 / 100,000;
- writes: $0.09 / 100,000;
- deletes: $0.01 / 100,000;
- free daily quota: 50k reads, 20k writes, 20k deletes;
- free stored data: 1 GiB;
- free outbound transfer: 10 GiB/month.

Using the 60-read / 60-write planning baseline, Firestore operation cost is approximately:

`60×0.03/100000 + 60×0.09/100000 = $0.000072 per Ranked match`

This excludes listener amplification, index-entry reads, storage and network.

## 13. Monthly Firestore operation scenarios

Important: `matches/day/player` counts both players, so total unique matches = DAU × matches/player/day ÷ 2.

| DAU | Matches/player/day | Unique matches/month | Approx Firestore read/write cost/month |
|---:|---:|---:|---:|
| 1,000 | 5 | 75,000 | ~$5.40 |
| 10,000 | 5 | 750,000 | ~$54 |
| 100,000 | 5 | 7.5M | ~$540 |
| 1,000,000 | 3 | 45M | ~$3,240 |
| 1,000,000 | 5 | 75M | ~$5,400 |
| 1,000,000 | 10 | 150M | ~$10,800 |

At scale, Firestore operations are meaningful but still predictable. Realtime listeners must be measured because every delivered document update is a billable read.

## 14. Cloud Run / Functions planning

`me-central2` (Dammam) is listed as a Tier-2 Cloud Run region.

Cloud Run request-based billing has:

- 2M requests/month free;
- then $0.40 per million requests at the published default request rate;
- CPU and memory are additionally billed during billable instance time;
- free CPU/RAM tiers apply monthly.

At the planning baseline of 22 backend invocations per match, request-count fee alone is approximately:

| DAU | Matches/player/day | Invocations/month | Request-count fee after 2M free |
|---:|---:|---:|---:|
| 10,000 | 5 | 16.5M | ~$5.80 |
| 100,000 | 5 | 165M | ~$65.20 |
| 1,000,000 | 3 | 990M | ~$395 |
| 1,000,000 | 5 | 1.65B | ~$659 |
| 1,000,000 | 10 | 3.30B | ~$1,319 |

The request fee is not the dominant Functions cost. CPU/RAM billed time can dominate.

### Compute planning proxy

Using the published request-based resource rates as a planning proxy (1 vCPU, 256 MiB) and assuming single-request equivalent billable durations:

For 1M DAU × 5 matches/player/day (1.65B backend invocations/month):

- 100 ms average billable compute: roughly $4.1k CPU/RAM before Dammam-specific variance/free tier.
- 200 ms: roughly $8.1k.
- 400 ms: roughly $16.3k.

This is intentionally a range, not a promised bill. Cloud Run concurrency can share an instance across multiple requests, cold starts and transaction latency can increase billed time, and Dammam is Tier 2. Production must record p50/p95 callable duration, instance concurrency and billable instance time before financial forecasts are trusted.

## 15. Authentication cost boundary

The app uses Google Sign-In through Firebase Authentication.

Firebase pricing lists standard non-phone Authentication as available on both Spark/Blaze. If the project is upgraded/enabled for Google Cloud Identity Platform MAU billing, current Tier-1-provider pricing is:

- first 50k MAU: free;
- 50k–100k: $0.0055/MAU;
- 100k–1M: $0.0046/MAU.

That would make 1M MAU about **$4,415/month** for Identity Platform MAU billing.

Do not add this $4,415 automatically to forecasts unless the production project is actually using the Identity Platform billing model. Verify the project billing configuration during Blaze activation.

## 16. Firebase Storage and Realtime Database

Repository search found no current `FirebaseStorage` or `FirebaseDatabase` use.

Core avatar artwork and audio are local/generated in the client. Therefore this audit assigns **zero recurring Firebase Storage/RTDB cost to normal gameplay** at current source state.

Future remote downloadable art/audio would change this conclusion.

## 17. Firestore storage growth

Even without Firebase Storage, Firestore retains match/evidence/settlement/ledger documents.

A rough planning payload of 10–20 KiB retained per completed match would produce:

- 75M matches/month: roughly 0.7–1.4 TiB new raw logical data/month before index overhead;
- 150M matches/month: roughly 1.4–2.9 TiB/month.

This grows cumulatively if every evidence/queue document is retained forever.

Recommended lifecycle policy before very large scale:

- retain compact authoritative settlement/history long-term;
- retain anti-cheat evidence for a defined dispute/security window (for example 30–90 days);
- TTL/delete stale matchmaking tickets and ephemeral evidence after policy expiry;
- do not delete anything needed for pending settlement or abuse investigation.

TTL deletes are billable, but deleting ephemeral documents is typically much cheaper than indefinitely retaining and indexing them at massive scale.

## 18. Season rollover at 1M players

Rollover is paged at 200 leaderboard entries/task.

1M leaderboard entries implies about 5,000 rollover page tasks.

Per participating player rollover transaction reads roughly grant/user/board/history/achievements and writes roughly user/board/history/achievements/grant. Planning at 5 reads + 5 writes/player gives about:

- 5M reads;
- 5M writes;
- Firestore operation cost around **$6 per 1M-player season rollover** at current listed operation prices, excluding index/network/compute.

5,000 Cloud Tasks is far below Cloud Tasks' first-million monthly free operations. The five-minute Scheduler cadence is also operationally minor. The real rollover concern at 1M players is execution reliability and completion time, not raw Firestore operation price.

## 19. Google Play Premium economics

Reference Premium Season Pass price: $30.

Google Play currently states that subscriptions in remaining markets use a 15% service fee; fee rules vary by market/program and have a staged 2026–2027 rollout. For simple planning at 15%:

- Gross: $30.
- After 15% Play fee: about **$25.50** before taxes, refunds, chargebacks and currency effects.

This is not an accounting/tax net-income figure.

### Infrastructure break-even intuition

At 1M DAU × 5 matches/player/day:

- modeled Firestore read/write operations: ~$5.4k/month;
- Functions request count: ~$0.66k/month;
- planning CPU/RAM range: roughly $4.1k–$16.3k/month before Tier-2 variance;
- Identity Platform may add up to ~$4.4k/month if that billing model is enabled;
- storage/network/logging add additional cost.

A broad infrastructure planning band is therefore roughly **$10k–$27k/month** for this heavy 1M-DAU scenario before optimization, not a guaranteed invoice.

At ~$25.50 contribution after a simple 15% Play-fee assumption, around **400–1,100 Premium Season Pass purchases/month** would cover that infrastructure band before tax/support/refunds. That is only ~0.04%–0.11% of 1M DAU. This suggests the $30 pass can economically support the backend if player willingness-to-pay is adequate.

## 20. Realtime listener risk

Firestore snapshot listeners charge reads when documents are delivered/updated. Match progress changes frequently because each mini-game completion updates the match document.

The current architecture is already much better than per-tap synchronization: it writes after mini-game completion instead of each interaction.

Before launch at scale, instrument:

- reads/player/session;
- listener reconnect reads;
- leaderboard page reads;
- friends/recent-player reads;
- shop/profile reads;
- empty query frequency.

Listener amplification can move real bills above the transaction-only model in this document.

## 21. Abuse and economy findings

### Good controls already present

- Ranked evidence is deterministic and server validated.
- settlement IDs are idempotent.
- client cannot directly grant Coins/RP/Stars/ownership.
- Coin purchases are atomic deduct+grant.
- Prestige thresholds do not spend Stars.
- premium purchase verification is server-side.
- Quick has same-pair diminishing rewards.
- Social has same-group diminishing rewards.
- missions and Season Pass claims are ledgered/idempotent.

### Risks to address/monitor

1. Quick opponent rotation can bypass pair-only farming throttles.
2. Social participant rotation can bypass exact-group throttles.
3. Ranked has no economy hard cap by account/day; automation must be handled by evidence/velocity/risk systems rather than trusting volume.
4. Permanent evidence/ledger retention can create unnecessary long-term storage/index growth.
5. Realtime listener amplification is not represented by the 60/60 operation baseline.
6. Premium Star acceleration is strongest for low-rank players; watch prestige perception.
7. Logging at billion-invocation scale must be sampled/controlled to avoid a surprise Cloud Logging bill.

## 22. Economic verdict

### Coins

Current Coin economy is acceptable for launch testing. The 234,150-Coin current catalog sink is meaningfully larger than ordinary monthly generation. A 20-Ranked-matches/day highly engaged free player generates roughly 29.4k Coins/month when all recurring missions and the full Free Pass are completed. That does not trivialize the catalog.

### RP

RP is intentionally inflationary, but the 30-day season and soft reset are necessary and currently provide the control mechanism. First-time Legendary remains appropriately difficult at normal win rates.

### XP

XP is generous but level requirements increase linearly. It does not directly buy competitive power. Monitor high-level saturation after real telemetry.

### Prestige Stars

Permanent, threshold-based, non-consumable design is sound. Latest Premium policy intentionally allows up to five gameplay-earned Stars after a verified pass purchase; documentation must use this newer rule rather than the older absolute statement that money can never expose any Prestige-Star path.

### Premium

$30/30-day pricing is economically powerful enough to subsidize infrastructure at scale with a very small conversion rate, but perceived player value must come from cosmetics, Coins, track rewards and the five earned Star milestones without becoming pay-to-win.

### Infrastructure

The architecture can scale economically, but 1M DAU with several matches/day is not a tiny Firebase bill. The largest controllable levers are:

- reduce unnecessary function invocations;
- exploit safe Cloud Run concurrency;
- keep functions in-region with Firestore;
- control realtime listener reads;
- TTL ephemeral data;
- control logs;
- monitor actual p50/p95 compute duration before committing to large-scale forecasts.

## 23. Recommended pre-launch production gates

1. Upgrade/configure Blaze and deploy reviewed Functions/Rules.
2. Measure one real two-device Ranked match with Cloud Monitoring and Firestore usage metrics; compare actual reads/writes/invocations with the planning baseline.
3. Add billing budgets/alerts before launch.
4. Decide whether to add per-account Quick/Social daily reward diminishing limits in addition to pair/group limits.
5. Define evidence/match TTL retention policy.
6. Verify whether Identity Platform MAU billing is enabled.
7. Configure Play products and confirm localized Premium price/service-fee/tax behavior.
8. Run load testing against a non-production project before large acquisition campaigns.
9. Keep `me-central2` for latency/data locality unless a measured business reason justifies migration.
10. Re-run this audit with live p50/p95 usage after beta telemetry.

## 24. Official pricing references checked on 2026-08-19

- Firestore Standard pricing: https://cloud.google.com/firestore/pricing
- Cloud Run pricing: https://cloud.google.com/run/pricing
- Firebase pricing: https://firebase.google.com/pricing
- Identity Platform pricing: https://cloud.google.com/identity-platform/pricing
- Google Play service fees: https://support.google.com/googleplay/android-developer/answer/112622

Prices are external and time-sensitive; source code contracts in this document are repository-derived, while financial estimates are planning calculations.