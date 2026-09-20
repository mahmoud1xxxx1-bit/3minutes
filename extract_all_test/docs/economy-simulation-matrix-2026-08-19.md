# 3 Minutes — Player Economy & Million-Scale Simulation Matrix

Date: 2026-08-19
Purpose: complete the quantitative scenarios required by `final-system-audit-checklist.md`.

All player calculations below use the actual current Ranked policy:

- Win = 30 Coins / 120 XP / +30 RP.
- Loss = 10 Coins / 55 XP / -18 RP.
- Tie = 18 Coins / 80 XP / +8 RP.
- RP floor = 0.
- Match duration = exactly 3 minutes.
- XP required for next level = `100 + (level - 1) × 50`.

Unless stated otherwise, player tables are **direct Ranked match rewards only**. Recurring Missions, Season Pass and one-time Achievements are described separately because they should not be double-counted as if every scenario automatically completed all social objectives.

## 1. Expected reward per Ranked match by win rate

No-tie expectation:

| Win rate | Coins/match | XP/match | RP/match |
|---:|---:|---:|---:|
| 100% | 30 | 120 | +30.0 |
| 60% | 22 | 94 | +10.8 |
| 50% | 20 | 87.5 | +6.0 |
| 40% | 18 | 81 | +1.2 |
| 0% | 10 | 55 | -18.0 before floor |
| 100% ties | 18 | 80 | +8.0 |

### Competitive ladder finding

RP break-even win rate solves:

`30w - 18(1-w) = 0`

which gives **w = 37.5%**.

Therefore any no-tie player above 37.5% expected win rate gains RP in the long run. A 40% player still gains +1.2 RP/match. This is an engagement-friendly inflation system but weakens pure skill-ladder meaning because enough volume can compensate for a losing record.

This is a product balance risk, not a code defect. Do not silently change it without a deliberate ladder decision.

## 2. 20 Ranked matches/day

Minimum raw gameplay: **1 hour/day**.

| Scenario | Coins/day | Coins/30d | XP/day | XP/30d | RP/day | RP/30d* | Approx level after 30d |
|---|---:|---:|---:|---:|---:|---:|---:|
| 100% wins | 600 | 18,000 | 2,400 | 72,000 | +600 | +18,000 | L53 |
| 60% wins | 440 | 13,200 | 1,880 | 56,400 | +216 | +6,480 | L47 |
| 50% wins | 400 | 12,000 | 1,750 | 52,500 | +120 | +3,600 | L45 |
| 40% wins | 360 | 10,800 | 1,620 | 48,600 | +24 | +720 | L43 |
| 0% wins | 200 | 6,000 | 1,100 | 33,000 | -360 | floor-limited | L35 |
| all ties | 360 | 10,800 | 1,600 | 48,000 | +160 | +4,800 | L43 |

*Negative RP cannot go below zero.

Interpretation:

- 20/day is plausible for a highly engaged user.
- A 50% player reaches roughly 3,600 RP from zero over 30 days before variance, around Diamond threshold territory.
- 40% still reaches about +720 RP, confirming the low RP break-even issue.

## 3. 50 Ranked matches/day

Minimum raw gameplay: **2.5 hours/day**.

| Scenario | Coins/day | Coins/30d | XP/day | XP/30d | RP/day | RP/30d* | Approx level |
|---|---:|---:|---:|---:|---:|---:|---:|
| 100% wins | 1,500 | 45,000 | 6,000 | 180,000 | +1,500 | +45,000 | L84 |
| 60% wins | 1,100 | 33,000 | 4,700 | 141,000 | +540 | +16,200 | L74 |
| 50% wins | 1,000 | 30,000 | 4,375 | 131,250 | +300 | +9,000 | L71 |
| 40% wins | 900 | 27,000 | 4,050 | 121,500 | +60 | +1,800 | L69 |
| 0% wins | 500 | 15,000 | 2,750 | 82,500 | -900 | floor-limited | L56 |
| all ties | 900 | 27,000 | 4,000 | 120,000 | +400 | +12,000 | L68 |

Interpretation:

- 50/day is heavy but physically possible.
- At 50% wins, first-season expected RP is ~9,000, just below Legendary.
- At 60%, Legendary becomes expected well before season end.

## 4. 100 Ranked matches/day

Minimum raw gameplay: **5 hours/day** before queue/results/menu time.

| Scenario | Coins/day | Coins/30d | XP/day | XP/30d | RP/day | RP/30d* | Approx level |
|---|---:|---:|---:|---:|---:|---:|---:|
| 100% wins | 3,000 | 90,000 | 12,000 | 360,000 | +3,000 | +90,000 | L119 |
| 60% wins | 2,200 | 66,000 | 9,400 | 282,000 | +1,080 | +32,400 | L105 |
| 50% wins | 2,000 | 60,000 | 8,750 | 262,500 | +600 | +18,000 | L101 |
| 40% wins | 1,800 | 54,000 | 8,100 | 243,000 | +120 | +3,600 | L98 |
| 0% wins | 1,000 | 30,000 | 5,500 | 165,000 | -1,800 | floor-limited | L80 |
| all ties | 1,800 | 54,000 | 8,000 | 240,000 | +800 | +24,000 | L97 |

Interpretation:

- This is an extreme legitimate-engagement boundary and should also be an anti-abuse telemetry signal.
- A 40% player can grind +3,600 RP in a season despite losing most decisive matches. This is the strongest evidence that current RP favors participation volume.

## 5. 200 Ranked matches/day

Minimum raw gameplay: **10 hours/day** before overhead.

| Scenario | Coins/day | Coins/30d | XP/day | XP/30d | RP/day | RP/30d* | Approx level |
|---|---:|---:|---:|---:|---:|---:|---:|
| 100% wins | 6,000 | 180,000 | 24,000 | 720,000 | +6,000 | +180,000 | L169 |
| 60% wins | 4,400 | 132,000 | 18,800 | 564,000 | +2,160 | +64,800 | L149 |
| 50% wins | 4,000 | 120,000 | 17,500 | 525,000 | +1,200 | +36,000 | L144 |
| 40% wins | 3,600 | 108,000 | 16,200 | 486,000 | +240 | +7,200 | L138 |
| 0% wins | 2,000 | 60,000 | 11,000 | 330,000 | -3,600 | floor-limited | L114 |
| all ties | 3,600 | 108,000 | 16,000 | 480,000 | +1,600 | +48,000 | L138 |

Interpretation: 200/day is not a healthy normal-player target. It should be treated as extreme engagement / automation-risk telemetry.

## 6. 500 Ranked matches/day

Minimum raw gameplay: **25 hours/day**. This is physically impossible for a single human because the gameplay time alone exceeds one day.

| Scenario | Coins/day | Coins/30d | XP/day | XP/30d | RP/day | RP/30d* | Approx level |
|---|---:|---:|---:|---:|---:|---:|---:|
| 100% wins | 15,000 | 450,000 | 60,000 | 1,800,000 | +15,000 | +450,000 | L267 |
| 60% wins | 11,000 | 330,000 | 47,000 | 1,410,000 | +5,400 | +162,000 | L236 |
| 50% wins | 10,000 | 300,000 | 43,750 | 1,312,500 | +3,000 | +90,000 | L228 |
| 40% wins | 9,000 | 270,000 | 40,500 | 1,215,000 | +600 | +18,000 | L219 |
| 0% wins | 5,000 | 150,000 | 27,500 | 825,000 | -9,000 | floor-limited | L181 |
| all ties | 9,000 | 270,000 | 40,000 | 1,200,000 | +4,000 | +120,000 | L218 |

Conclusion: 500/day is exclusively a bot/farm/capacity test. A production account reaching this settlement volume should be treated as impossible-human evidence unless duplicate/retry accounting explains it.

## 7. Recurring mission/pass additions

If all Daily and Weekly missions are legitimately completed:

- Daily recurring mission Coins: 185/day.
- Weekly: 1,400/week.
- Daily Season XP: 250/day.
- Weekly Season XP: 2,150/week.

Over a 30-day planning month this is approximately:

- 11,550 recurring mission Coins;
- 16,714 Season XP;
- enough to reach Level 30 of the current Season Pass.

Full Free Pass adds 5,850 Coins.

Thus a user who completes every mission adds approximately **17,400 Coins/month** above direct match Coins, excluding achievements.

Premium additionally adds 12,300 Coins if every premium level is claimed, plus up to five gameplay-earned Prestige Stars at levels 6/12/18/24/30.

Example 50% win player with every recurring mission:

| Matches/day | Direct Ranked Coins | + Missions + Free Pass | + Premium track |
|---:|---:|---:|---:|
| 20 | 12,000 | ~29,400 | ~41,700 |
| 50 | 30,000 | ~47,400 | ~59,700 |
| 100 | 60,000 | ~77,400 | ~89,700 |

Current total Coin shop sink = 234,150 Coins. Therefore even a 20/day highly engaged completionist does not trivialize the entire current catalog in one season.

## 8. One-million-registered-user activity models

Registered accounts do not equal DAU. Model:

- Low DAU: 5% = 50,000 active/day.
- Normal/growth: 20% = 200,000 active/day.
- High: 50% = 500,000 active/day.
- Full stress: 100% = 1,000,000 active/day.

Infrastructure baseline from code audit:

- ~60 Firestore reads + ~60 writes per completed Ranked match before listener overhead.
- ~22 backend invocations/match.
- Firestore operation planning cost: ~$0.000072/match at currently listed rates.
- Functions compute proxy below assumes 200 ms average single-request-equivalent billable time, 1 vCPU + 256 MiB using published request-based resource rates. It is not a guaranteed Dammam invoice; concurrency and Tier-2 pricing change real values.

### 5 matches/player/day — normal casual competitive use

| DAU | Unique matches/month | Firestore R/W | Backend invocations | Function request fee | 200ms compute proxy |
|---:|---:|---:|---:|---:|---:|
| 50k | 3.75M | ~$270 | 82.5M | ~$32 | ~$406 |
| 200k | 15M | ~$1,080 | 330M | ~$131 | ~$1,625 |
| 500k | 37.5M | ~$2,700 | 825M | ~$329 | ~$4,063 |
| 1M | 75M | ~$5,400 | 1.65B | ~$659 | ~$8,126 |

This excludes listeners, Auth conditional cost, storage, network, logging and Dammam Tier-2 variance.

### 20 matches/player/day — highly engaged population

| DAU | Unique matches/month | Firestore R/W | Backend invocations | Function request fee | 200ms compute proxy |
|---:|---:|---:|---:|---:|---:|
| 50k | 15M | ~$1,080 | 330M | ~$131 | ~$1,625 |
| 200k | 60M | ~$4,320 | 1.32B | ~$527 | ~$6,501 |
| 500k | 150M | ~$10,800 | 3.3B | ~$1,319 | ~$16,253 |
| 1M | 300M | ~$21,600 | 6.6B | ~$2,639 | ~$32,505 |

### Abuse / impossible-human bounds

For 200k DAU:

| Matches/player/day | Unique matches/month | Firestore R/W | Invocations | Request fee | 200ms compute proxy |
|---:|---:|---:|---:|---:|---:|
| 50 | 150M | ~$10,800 | 3.3B | ~$1,319 | ~$16,253 |
| 100 | 300M | ~$21,600 | 6.6B | ~$2,639 | ~$32,505 |
| 200 | 600M | ~$43,200 | 13.2B | ~$5,279 | ~$65,010 |
| 500 | 1.5B | ~$108,000 | 33B | ~$13,199 | ~$162,525 |

The 500/day row is not a user forecast. It demonstrates why public launch needs server rate controls, billing alerts and abuse detection: bot traffic can create real cloud spend even when rewards are server validated.

## 9. Cost-dominant actions

Most expensive high-frequency path:

1. 16 per-match mini-game result submissions.
2. Each submission transaction repeatedly reads/writes match and evidence.
3. Settlement and progression add further reads/writes.
4. Firestore realtime listeners can multiply delivered reads on every progress update.

Optimization candidates after correctness is locked:

- never synchronize per tap; current per-mini-game approach is correct and must remain;
- evaluate safe batching of evidence submissions only if reconnect/integrity semantics remain intact;
- measure whether evidence document must rewrite the entire growing array each mini-game;
- use Cloud Run concurrency effectively;
- remove redundant polling where realtime listener already provides state;
- paginate/cap leaderboard/friends/recent-player queries;
- TTL ephemeral queue/evidence after a defined security retention window;
- sample/suppress routine success logs at scale.

## 10. Required operational protections before public Blaze launch

- Google Cloud Billing budgets and multiple alert thresholds.
- Cloud Monitoring dashboard for callable count, p50/p95/p99 duration, error rate and concurrency.
- Firestore read/write dashboards.
- per-UID and per-device abuse telemetry.
- App Check enforced on trusted callables.
- Quick pair throttle plus consideration of per-account throttle.
- Social exact-group throttle plus consideration of per-account throttle.
- Ranked settlement velocity anomaly detection.
- impossible daily match count detection.
- stale ticket/evidence TTL policy.
- controlled log volume.
- load test in non-production project.

## 11. Final balance conclusions from simulations

### Coins — PASS with monitoring

The current shop sink is large relative to realistic free generation. The economy is not currently trivialized by a normal 20-match/day player.

### XP — PASS, fast progression

XP levels rise quickly for highly engaged users: roughly Level 45 in one month at 20/day and 50% wins from direct Ranked XP alone. Levels currently do not provide match power, so this is primarily a longevity/content issue rather than competitive unfairness. Long-term telemetry should determine whether level milestones need additional spacing.

### RP — BALANCE REVIEW REQUIRED

37.5% is the current long-run break-even win rate. A 40% player can climb with volume. This is the most important balance finding in the audit. If Rank is intended to represent skill more strictly, loss RP must eventually become more punitive and/or rank-dependent. If Rank is intended as a season engagement ladder, current inflation can be retained deliberately.

### Premium — ECONOMICALLY VIABLE, NOT PAY-TO-WIN

Premium provides Coins/cosmetic progression and five earned Star milestones, but no score/time/difficulty/RP advantage. At $30, a small paid conversion can cover modeled backend cost at very large scale, although taxes/refunds/marketing/support are outside this infrastructure model.

### 500-match case — BLOCK/INVESTIGATE

It is mathematically impossible for one human under the fixed three-minute contract. Production telemetry should never treat this as legitimate ordinary play.