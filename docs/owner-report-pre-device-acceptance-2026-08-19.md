# 3 Minutes — Comprehensive Owner Report

Date: 2026-08-19
Status: **SOURCE + CI CLOSED / DEVICE ACCEPTANCE OF REPLACEMENT APK STILL PENDING**
Repository: `mahmoud1xxxx1-bit/3minutes`
Package: `com.threeminutes.game`
Firebase project: `minutes-d7dfc`
Primary region: `me-central2`

This report is the owner-facing map of the entire current application. It intentionally distinguishes four different states:

- **Implemented** — source exists in current GitHub project.
- **CI verified** — automated Functions/Firestore/Flutter/build checks passed.
- **Device verification pending** — behavior/visual/audio must still be accepted by the owner on the latest replacement APK.
- **Blaze/Play deployment required** — trusted production backend or Google Play configuration is prepared in source but not production-live while backend phase remains Spark.

## 1. Application identity and first-run

### Google Sign-In

Purpose: authenticate the player with Firebase Authentication using Google.

Current state:

- Implemented.
- Firebase/Auth wiring validated by build configuration.
- APK workflow verifies generated Google OAuth resource.
- Production release still requires correct release signing/App Check/Play configuration.

### First player profile

Purpose: create the player's game identity and store protected profile state.

The player can control public identity fields such as game name/avatar selection only through allowed paths. Competitive values such as RP, Stars, wins/losses and economy authority are not intended to be directly client-editable.

## 2. Main navigation

Primary bottom navigation:

1. Home
2. Season
3. Friends
4. Shop
5. Profile

A dedicated Settings entry now exists from the main experience after the Field-QA remediation.

## 3. Home

The Home surface is the launch point for the game modes and player identity.

Current important behavior:

- shows actual approved player avatar rather than a generic identity icon;
- exposes primary match modes;
- Settings is reachable;
- sign-out requires explicit confirmation after the Field-QA fix;
- player-facing copy must not mention Spark, Blaze, Firebase plan names or internal deployment terminology.

**Latest replacement APK device verification required:** Home visual quality, Settings discoverability, sign-out confirmation and menu music.

## 4. Settings

Dedicated Settings screen now includes persistent audio controls.

### Music

- separate music volume;
- mute capability;
- persisted via SharedPreferences;
- controls menu ambience and match-focus music.

### Sound effects

- separate SFX volume;
- mute capability;
- persisted;
- preview/test sound available.

Audio failures are fail-soft: audio must never block match timing or competitive state.

**Device verification required:** subjective sound quality, comfortable volume curve, no unpleasant repetition, mute persistence after restart.

## 5. Audio system

Current generated/license-independent audio system contains:

- Cosmic menu ambience;
- restrained energetic match-focus loop;
- UI tap SFX;
- reward SFX;
- match-start SFX.

Mode coverage:

- Ranked: match audio wrapper.
- Quick: match audio wrapper.
- Private: social match audio wrapper.
- Party: social match audio wrapper.

The design goal is professional, energetic and memorable without becoming irritating over repeated play.

## 6. Core match contract

Every standard competitive match obeys:

- exactly 3 minutes / 180 seconds;
- exactly 8 mini-games;
- deterministic shared seed/content;
- players receive equivalent game order/difficulty;
- progress is independent;
- one player's completion does not advance the opponent;
- settlement waits for both completion or legal deadline;
- paid cosmetics never affect score, timing, target size, information or difficulty.

Locked game-seed formula:

`gameSeed = matchSeed ^ ((gameIndex + 1) * 0x45d9f3b)`

## 7. Approved mini-games

Current library is exactly ten games:

1. Tap Target
2. Quick Math
3. Color Match
4. Odd One Out
5. Memory Flash
6. Direction Swipe
7. Number Order
8. Shape Count
9. Reaction Stop
10. Symbol Pair

A normal match selects exactly eight according to the deterministic registry.

**No Game #11 may be added without an explicit concept/visual approval step.**

This is the correct point for the owner to return to new mini-game development once the replacement APK device acceptance is complete.

## 8. Ranked mode

### Purpose

Primary competitive random 1v1 mode.

### Rewards

- Win: +30 RP / 120 XP / 30 Coins.
- Loss: -18 RP / 55 XP / 10 Coins.
- Tie: +8 RP / 80 XP / 18 Coins.

### Security

- deterministic evidence submitted per mini-game;
- trusted settlement validates evidence;
- settlement is idempotent by match ID;
- client cannot directly assign RP/Coins/XP;
- leaderboard/season writes are server authority.

### Balance finding

Current RP break-even win rate is 37.5%. A 40% win player gains +1.2 expected RP per match. Therefore Ranked currently behaves partly as an engagement ladder, not a strict zero-sum skill ladder.

This is the most important outstanding **product balance review**, not an implementation failure.

## 9. Rank ladder

Exactly eight ranks:

1. Bronze — 0 RP
2. Silver — 500
3. Gold — 1,200
4. Platinum — 2,200
5. Diamond — 3,500
6. Master — 5,000
7. Grand Master — 7,000
8. Legendary — 10,000

Approved premium emblem family is used.

### Rank preview

All rank emblems, including locked ranks, can be inspected before earning them.

Preview explains:

- emblem;
- name;
- required RP;
- earned/locked state;
- Legendary prestige information.

A preview never grants the rank.

## 10. Peak Rank and legacy showcase

`peakRankTier` preserves the lifetime highest legitimately earned rank.

Historical showcase is separate from current competitive rank, so a player can display history without falsely changing current rank.

Persistent server-authoritative showcase mutation requires Blaze-deployed trusted Functions.

## 11. Legendary repeat prestige

Legendary can be achieved in multiple distinct seasons.

History increments at most once per distinct season.

Presentation milestones:

- ×1 base;
- ×2 double halo;
- ×3 Crowned;
- ×5 stronger aura;
- ×10+ Legacy treatment.

Prestige affects identity/status only, never gameplay power.

## 12. Quick Match

### Purpose

Lower-stakes random 1v1 using the same 3-minute / 8-game deterministic contract.

### Rewards

- Win: 70 XP / 18 Coins.
- Tie: 50 XP / 12 Coins.
- Loss: 30 XP / 6 Coins.
- RP: always zero.

### Anti-farming

Against the exact same pair in one UTC day:

- matches 1–10: 100% reward;
- 11–20: 25%;
- after 20: 0%.

### Residual abuse risk

Rotating opponents can bypass a pair-only limiter. A future production hardening decision should consider per-account daily diminishing Quick rewards in addition to the pair limiter.

## 13. Private mode

Supported player counts only:

- 2
- 4
- 6

No 3 or 5 player mode.

Private games do not modify Ranked RP.

Uses room/invite flow and social match runtime.

## 14. Party mode

Supported sizes:

- 2
- 4
- 6

No Ranked RP.

Designed for persistent repeated group play/rematches.

## 15. Social match rewards

Social placement Coin bases:

- 1st: 20
- 2nd: 14
- 3rd: 11
- lower: 8

Exact-group anti-farm:

- first 5/day: 100%;
- next 5: 35%;
- after 10: 0%.

Residual risk: changing group membership produces a new group key. Consider a future per-player reward cap/diminishing system before large-scale launch.

## 16. Friends

Current social system includes:

- friend code;
- player search/summary;
- incoming/outgoing requests;
- accepted list;
- remove friend;
- block;
- recent players;
- social identity rendering.

Legendary season history is passed into friend rank presentation.

## 17. Invite links and rooms

Room invite format:

`threeminutes://join/CODE`

Android deep-link integration exists.

The previous clipboard listener auto-share workaround is no longer the intended design. Share is explicit through the invite service; copy remains separate/fallback behavior.

## 18. Season hub

Season is exactly 30 days.

The Season hub presents competition/progression information and now surfaces Missions and Premium Season Pass more directly after device feedback.

A previous indefinite loading problem was remediated by timeout/fail-soft behavior when no current season is returned.

**Device verification required:** Missions opens correctly and Premium entry is immediately discoverable in the replacement APK.

## 19. Missions

Daily:

- Play 3 matches — 60 Coins / 80 Season XP.
- Win 1 — 75 / 100.
- Friend match 1 — 50 / 70.

Weekly:

- Play 30 — 450 / 700.
- Win 15 — 600 / 900.
- Friend matches 5 — 350 / 550.

Rewards are claimed through server authority and ledgered to prevent duplicate claims.

Season XP is separate from normal player XP.

## 20. Achievements

Long-term achievements cover:

- first win;
- win counts;
- 1,000 matches;
- win streak;
- friend matches;
- six-player wins;
- season count;
- Prestige Stars.

Achievement Coin rewards are finite one-time rewards, not infinite farming sources.

## 21. Free Season Pass

Season Pass has 30 levels.

Level progression:

`1 + floor(Season XP / 500)`, capped at 30.

Free Coin reward by level:

`40 + 10 × level`.

Full Free track = 5,850 Coins.

## 22. Premium Season Pass

Approved policy:

- reference price: USD 30;
- 30-day season only;
- Google Play product: `premium_season_pass_30d`;
- prepaid base plan: `prepaid-30d`;
- purchase must be server verified;
- entitlement cannot be reused for another account/season;
- does not automatically carry into next season.

Premium Coin reward:

`100 + 20 × level`.

Full Premium track adds 12,300 Coins.

### Premium Prestige Stars

Latest approved policy permits five permanent Stars to be earned through Premium gameplay milestones:

- Levels 6 / 12 / 18 / 24 / 30.
- +1 each.
- maximum 5 per season.

Payment alone does not instantly grant five Stars.

## 23. Prestige Stars

Permanent account history/status and non-consumable.

Normal season rollover Peak-Rank awards:

- Bronze 1
- Silver 2
- Gold 4
- Platinum 7
- Diamond 11
- Master 16
- Grand Master 24
- Legendary 35

Star cosmetic requirements are thresholds; unlocking does not deduct Stars.

## 24. Soft reset

Current reset values by Peak Rank:

- Bronze → 0
- Silver → 250
- Gold → 500
- Platinum → 900
- Diamond → 1,400
- Master → 2,200
- Grand Master → 3,500
- Legendary → 5,000

This limits indefinite RP accumulation and makes repeat high-rank seasons easier than the first climb.

## 25. Leaderboard

Server-authoritative seasonal leaderboard tracks Rank Points and supporting record/identity information.

Leaderboard ordering remains competitive; Legendary repeat prestige is displayed but does not become a hidden ranking multiplier.

Production live authority requires Blaze deployment/live season data.

## 26. Profile

Profile identity can include:

- game name;
- avatar;
- avatar frame;
- badge;
- profile background;
- name style;
- current rank;
- RP;
- XP/level;
- wins/losses/matches;
- Prestige Stars;
- Legendary history;
- historical rank showcase;
- equipped cosmetics.

## 27. Shop overview

Catalog v3 contains 73 entries:

- 45 avatars;
- 28 other cosmetics;
- 10 cosmetic/equipment slots.

Slots:

1. Avatar
2. Avatar Frame
3. Badge
4. Profile Background
5. Name Style
6. Match Intro
7. Victory Effect
8. Rank Aura
9. Emote
10. Room Theme

## 28. Universal cosmetic preview

Every catalog item is intended to be tappable even while locked.

Preview states:

- Locked
- Available
- Owned
- Equipped

Preview shows acquisition method and contextual visual presentation.

Preview never charges or grants ownership.

## 29. 45 Avatars

Distribution:

- 5 Free
- 20 Coin
- 10 Premium
- 5 Prestige-Star threshold
- 5 earned/seasonal achievement

### Current artwork runtime

The previous low-resolution Base64/WebP atlas runtime was replaced after physical-device feedback.

Current runtime uses local deterministic vector-painted avatars:

- no Base64 decode;
- no asynchronous atlas wait;
- no avatar loading spinner;
- resolution-independent rendering;
- preserves all 45 IDs and acquisition contracts.

**Device verification required:** subjective visual quality of the new avatar family at large preview sizes.

### Technical cleanup

Some server fallback strings in legacy authority paths still reference `default_01` only as corrupted/missing-data fallback. They are not the approved player-facing avatar catalog. These should eventually be normalized to an approved starter ID to remove legacy technical debt.

## 30. Coin avatar pricing

Twenty Coin avatars range from 1,600 to 11,000 Coins.

Combined Coin avatar sink: 112,200.

## 31. Other Coin cosmetics

Other Coin cosmetics range from 500 to 30,000 Coins.

Combined non-avatar Coin sink: 121,950.

Total current Coin sink: **234,150 Coins**.

## 32. Coin purchase integrity

Server purchase transaction:

1. authenticate;
2. load authoritative catalog price;
3. reject duplicate ownership;
4. reject insufficient balance;
5. deduct exact Coins;
6. grant ownership in the same transaction;
7. write ledger/receipt state.

Invariant: deduction and ownership both succeed or neither succeeds.

## 33. Prestige cosmetic integrity

Server checks lifetime Star threshold.

Stars are not deducted.

Ownership is persisted once and receipt shows zero Stars spent.

## 34. Earned cosmetics

Server re-checks achievement/season requirement rather than trusting the client.

Examples:

- Legendary once;
- Legendary ×3 seasons;
- Legendary ×5;
- 100 Ranked wins;
- Season Champion (#1 historical final standing).

## 35. Premium cosmetics

Google Play purchase token must be verified server-side before permanent entitlement is stored.

Restore does not rely on local-only ownership.

Production activation requires Play Console products, Android Publisher access and deployed Blaze Functions.

## 36. Equipment integrity

A non-free item cannot be equipped unless authoritative ownership exists.

After validation, inventory equipped state and public cosmetic loadout are updated through trusted authority.

## 37. Animated cosmetics

Animated catalog items use runtime animation rather than only an `ANIMATED` label.

Coverage includes relevant frames, name styles, backgrounds, auras, intros, victory effects and room themes.

Motion must remain restrained and not obstruct gameplay.

## 38. Cosmetic runtime delivery

Examples:

- Avatar/frame/badge/name/background/aura → identity/profile/social surfaces.
- Room theme → hosted private room.
- Match intro → pre-match.
- Victory effect → result.
- GG emote → social match interaction.

Preview promise and runtime delivery promise should stay aligned.

## 39. Arabic and English

Both are first-class languages.

Localization uses Flutter generated localization catalogs with RTL/LTR support and parity/content tests.

No internal protocol strings should leak as player-facing copy.

## 40. Cosmic Flow identity

Visual direction:

- dark navy/indigo;
- cyan/violet accents;
- restrained glow;
- soft premium cards;
- limited gradients;
- high readability;
- no casino-like over-effects;
- cosmetics never obscure gameplay.

## 41. Accessibility

Key rules:

- correct/wrong feedback is not color-only;
- readable primary labels;
- no cosmetic gameplay obstruction;
- reduced-motion support where relevant;
- Arabic RTL and English LTR both valid.

## 42. Firestore and Functions security

Trusted state is deny-by-default for clients.

Protected server-written areas include:

- ranked settlement;
- inventory ownership;
- Coin transaction ledger;
- Prestige Star history;
- purchase receipts;
- season rollover/history;
- authoritative leaderboard;
- ranked evidence.

App Check is enforced on reviewed trusted callable paths.

## 43. Backend phase

Current source phase remains Spark until deliberate production activation.

Therefore the project can be **source complete and CI verified without being production-live** for:

- Ranked authority;
- Coin economy;
- trusted progression;
- Premium purchase verification;
- leaderboard authority;
- season rollover;
- persistent trusted showcase operations.

Do not publish pretending these server features are live until Blaze deployment is complete.

## 44. Latest CI / APK evidence

Latest replacement APK Validation run:

`32241945555`

Passed:

- Functions install/build/tests;
- Firestore rules/security;
- Flutter Analyze;
- Flutter Tests;
- Android debug APK build;
- Google OAuth resource verification;
- APK certificate verification;
- Artifact upload.

Artifact ID:

`9361323419`

The temporary APK PR was marker-only and closed without merge.

## 45. Current cost/scale conclusions

Detailed models are in:

- `economy-scale-audit-2026-08-19.md`
- `economy-simulation-matrix-2026-08-19.md`

Major conclusions:

- current Coin sink is healthy relative to realistic earning;
- Firestore cost is predictable but Functions compute can dominate at huge volume;
- realtime listener amplification must be measured;
- match/evidence retention needs TTL policy at scale;
- 1M-player season rollover is financially inexpensive in raw Firestore operations due to paging;
- 500 matches/day is impossible-human and is a useful bot/cost stress case;
- Quick/Social participant rotation are the clearest remaining farming risks;
- RP 37.5% break-even is the clearest remaining competitive balance question.

## 46. What is still external / not complete

The following must not be mislabeled COMPLETE:

1. Owner physical-device acceptance of the latest replacement APK.
2. Blaze upgrade/deployment of reviewed Functions and current Firestore Rules.
3. Live season/leaderboard production bootstrap.
4. Google Play product/base-plan configuration and real purchase/restore test.
5. Release Play Integrity/App Check production smoke test.
6. Real two-device Ranked/Quick/Private/Party acceptance on deployed backend.
7. Load/billing telemetry validation under real backend traffic.

## 47. Device acceptance checklist for the replacement APK

The owner should explicitly verify:

- Avatar visual quality is now acceptable.
- No avatar loading spinners/delay in Shop/Profile previews.
- Premium Season Pass is clearly visible from Season.
- Missions page opens immediately/fail-soft.
- Settings is easy to find.
- Music/SFX controls work and persist.
- Match music is comfortable and professional.
- Sign-out confirmation appears.
- No Spark/Blaze/Firebase-plan terms appear to the player.
- Rank preview quality remains acceptable.
- Locked cosmetics remain previewable.

Only after these are accepted should Field-QA be marked device COMPLETE.

## 48. Priority matrix

| Area | Current status | Risk | Player impact | Financial impact | Required action | Priority |
|---|---|---|---|---|---|---|
| Replacement APK | CI PASS | Device quality not yet accepted | High | Low | Owner test latest APK | P0 |
| Blaze backend | Source prepared, not live | Core trusted features unavailable in production | Critical | Critical | Upgrade/deploy/test | P0 before release |
| Google Play Premium | Source prepared | Purchase cannot be production-proven yet | High | High revenue | Configure products/API + real test | P0 before paid launch |
| RP balance | Works as coded | 37.5% break-even allows volume climbing | High competitive integrity | Medium | Deliberate balance decision | P1 |
| Quick farming | Pair throttle exists | Opponent rotation | Medium | Medium cloud/economy | Consider per-account throttle | P1 |
| Social farming | Group throttle exists | Participant rotation | Medium | Medium | Consider per-account throttle | P1 |
| Avatar runtime | Replaced, CI PASS | Subjective quality unknown until device test | High first impression | Medium retention | Device accept/reject | P0 |
| Audio | Implemented all modes | Subjective repetition/volume | Medium retention | Low | Device acceptance | P0 |
| Missions | Fail-soft remediation implemented | Navigation must be device-proven | High progression | Low | Device test | P0 |
| Premium visibility | Direct Season entry implemented | Must be device-proven | High monetization | High | Device test | P0 |
| Firestore retention | No final large-scale TTL policy | Long-term storage/index growth | Low immediate | Medium/High at scale | Define 30–90d evidence retention | P1 |
| Realtime reads | Architecture reasonable | Listener amplification unmeasured | Low | High at scale | Instrument beta | P1 |
| Identity Platform billing | Conditional | Possible MAU cost surprise | None | High at 1M MAU | Verify billing mode | P1 |
| Legacy `default_01` fallback | Technical debt only | Corrupt/legacy data could map to obsolete ID | Low | None | Normalize server fallbacks | P2 |
| New mini-games | Current 10 locked | None | Main next content phase | Content/revenue upside | Resume after device closeout | NEXT |

## 49. Owner conclusion

The application is **not waiting on another broad source rewrite**. The latest source passes the full automated validation and a replacement APK has been built. The remaining gate before returning full attention to new mini-games is primarily **physical acceptance of the replacement user experience**, followed later by the controlled Blaze/Google Play production activation work.

The two most important non-device decisions uncovered by the final audits are Ranked RP inflation/break-even and whether to add account-level Quick/Social farming throttles. Neither should be changed silently because both alter player progression policy.