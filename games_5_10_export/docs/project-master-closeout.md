# 3 Minutes — Project Master Closeout

Status date: 2026-08-19

Repository: `mahmoud1xxxx1-bit/3minutes`

Current reference branch: `main`

This file is the master project reference for **3 Minutes / 3 دقائق**. It consolidates the product rules, architecture, multiplayer system, mini-game contracts, competition/rank system, seasons, progression, social features, shop/economy, cosmetics, visual identity, Firebase/security boundaries, validation state, deployment gates, and known deferred work.

This document is intentionally broader than the specialized closeout files. Specialized files remain authoritative for deep details of their subsystem, while this file explains how all systems fit together.

---

# 1. Product definition

3 Minutes is a fast competitive multiplayer game built around a strict shared match format:

- platform focus: Android first;
- framework: Flutter;
- backend: Firebase;
- state/backend boundaries structured for Spark now and Blaze authority later;
- authentication: Google Sign-In through Firebase Authentication;
- package name: `com.threeminutes.game`;
- Firebase project: `minutes-d7dfc`;
- primary Firestore region: `me-central2`;
- Cloud Functions runtime target: Node.js 22, region `me-central2`;
- supported languages: Arabic and English;
- match duration: exactly **180 seconds / 3 minutes**;
- normal match content: exactly **8 mini-games**;
- approved mini-game library: exactly **10 games** until a new game is explicitly proposed, visually explained, and approved before implementation.

The product principle is simple: players compete on the same deterministic content while cosmetics, prestige, identity, and collection systems provide long-term motivation without affecting competitive fairness.

---

# 2. Non-negotiable gameplay contract

A standard match must preserve all of the following:

1. Both players receive the same match seed.
2. Both players receive the same deterministic sequence of eight mini-games.
3. Both players receive equivalent per-game configuration and difficulty.
4. Progress is independent: one player completing a game does not advance the opponent.
5. The match has a shared three-minute deadline.
6. A player who finishes all eight games early waits for settlement rather than receiving an early final result while the opponent is still legally playing.
7. Result comparison remains deterministic.

Competitive comparison is based on the established match policy: completed progress first, followed by the approved score/accuracy/mistake/time comparison rules. Paid cosmetics never alter these rules.

The deterministic per-game seed formula is locked:

`gameSeed = matchSeed ^ ((gameIndex + 1) * 0x45d9f3b)`

Any change to this formula would be a protocol/content compatibility change and must not happen casually.

---

# 3. Project architecture

The project follows a layered Flutter architecture with explicit backend interfaces.

Key principle: **mini-games do not access Firebase directly**.

A mini-game receives deterministic configuration and a seed, performs local interaction, and returns a normalized result. Authentication, matchmaking, ranking, seasons, progression, inventory, purchases, social data, and Firestore writes are outside the mini-game implementation.

Major backend boundaries include:

- `MatchBackend` — matchmaking/match lifecycle boundary;
- `SocialMatchBackend` — private/party social match runtime;
- `CompetitionBackend` — season and leaderboard read models;
- ranked authority / settlement capability — server-authoritative ranked rewards;
- `EconomyBackend` — inventory, purchases and equipment;
- `ProgressionBackend` — progression/mission/achievement read state;
- `SocialBackend` — friends/recent-player social data;
- `RoomBackend` — room lifecycle and invitation state;
- `ProfileRepository` — player profile management.

The architectural goal is that switching from Spark-safe behavior to Blaze authority does not require rewriting the gameplay UI or mini-game engines.

---

# 4. Section 1 — Foundation

Section 1 is closed and represents the stable base of the application.

Implemented foundation:

- Flutter Android application;
- fixed package `com.threeminutes.game`;
- Firebase initialization;
- Google Sign-In via Firebase Auth;
- Cloud Firestore profile storage;
- first-run player profile setup;
- player name normalization and validation;
- duplicate-submit protection;
- retryable profile-loading failures;
- player name/avatar editing;
- protected competitive profile fields;
- initial Home shell;
- central 3-minute / 8-game match configuration;
- automated Flutter tests and CI foundation.

Security principle from the beginning: clients may edit public profile identity fields but must not directly control competitive values such as RP, stars, XP, level, wins/losses, or economy authority.

Historical Section 1 closeout is retained in `docs/section-1-closeout.md`.

---

# 5. Section 2 — Multiplayer core

Section 2 is code-complete. Physical two-client acceptance QA remains a release gate.

## 5.1 Matchmaking

Implemented:

- authenticated matchmaking queue;
- transactional two-player claim in the Spark-era implementation;
- shared match document;
- player snapshots;
- deterministic seed;
- registry version;
- readiness state;
- synchronized countdown timestamp;
- waiting/cancel flow;
- both players converge on the same match state.

## 5.2 Ready and countdown

Both players explicitly become READY.

When both are ready, the match enters synchronized countdown. The 3-2-1 countdown is gameplay-critical and is based on shared timing rather than decorative animation completion.

## 5.3 Live runtime

Implemented:

- 180-second runtime;
- current game index;
- deterministic mini-game sequence;
- deterministic per-game seed;
- normalized mini-game results;
- cumulative score, accuracy, mistakes, elapsed time and completed-game count;
- network synchronization after a mini-game completes rather than on every tap/swipe;
- finish timestamp when all eight games are completed;
- forward-only progress protections.

## 5.4 Reconnect/resume

Implemented:

- matchmaking ticket persists enough state to resume the existing match;
- local runtime reconciles against saved Firestore progress;
- the client resumes from the last synchronized completed-game index;
- deterministic content makes replay/resume safe because both clients can reconstruct the expected next game from the shared seed.

## 5.5 Cancellation

- pre-start cancellation is supported;
- cancellation requires confirmation;
- opponent can see the cancelled-room state;
- cancellation becomes unavailable once the synchronized countdown has started.

## 5.6 Settlement

Final result is not considered settled until either:

- both players finish all eight games, or
- the shared three-minute deadline has elapsed.

An early finisher waits rather than forcing a premature result.

## 5.7 Rematch

Implemented:

- same-opponent rematch request;
- both players must accept;
- either player may withdraw before mutual acceptance;
- a successful rematch creates a fresh match with reset progress and a fresh seed;
- ticket state can point players to the new rematch.

## 5.8 Match history

History is derived from existing match data rather than duplicating result storage. Settled and cancelled matches can be shown with bilingual result summaries.

Detailed Section 2 status remains in `docs/section-2-progress.md`.

---

# 6. Approved mini-game library

The game currently contains exactly ten approved game IDs:

1. `tap_target`
2. `quick_math`
3. `color_match`
4. `odd_one_out`
5. `memory_flash`
6. `direction_swipe`
7. `number_order`
8. `shape_count`
9. `reaction_stop`
10. `symbol_pair`

The registry deterministically chooses eight for a standard match.

The content safety layer requires every registered game to map to a playable engine/descriptor. Placeholder game IDs without a playable path are not allowed.

**Game #11 must not be added automatically.** A new concept must first be proposed with its mechanic and visual presentation and explicitly approved.

Arabic and English mini-game titles/instructions are first-class content and are covered by localization/content tests.

---

# 7. Game modes

The product-mode contract is:

## Ranked

- random 1v1 matchmaking;
- competitive RP changes;
- Coins/rewards through authoritative settlement;
- ranked integrity/anti-cheat requirements apply;
- public rank and leaderboard identity matter.

## Quick

- two players;
- no RP change;
- Coins/reward design may apply according to configured reward policy;
- intended as lower-stakes competitive play.

## Private

- supported room sizes: 2, 4 or 6;
- no RP;
- invitation/room-code driven;
- private social play.

## Party

- supported sizes: 2, 4 or 6;
- no RP;
- party persists across rematches/session flow;
- designed for repeated group play.

Sizes 3 and 5 are intentionally not part of the supported contract and tests/logic must not silently introduce them.

---

# 8. Social system

The social layer includes:

- friend codes;
- player search/summary;
- friend requests;
- accepted friend list;
- blocking;
- removing friends;
- recent players;
- private rooms;
- party rooms;
- 2/4/6 player capacity rules;
- room codes;
- invite links;
- Android deep-link handling.

Room link format:

`threeminutes://join/CODE`

Android invite MethodChannel:

`com.threeminutes.game/invites`

The previous clipboard-listener sharing hack is no longer part of the intended architecture. Room sharing is explicit: the share action invokes the Android share sheet; copying remains a separate/fallback action.

Social identity reads the player's public, server-written cosmetic loadout rather than creating a second mutable cosmetic ownership source.

Friends, search results, requests, recent players and room participants can therefore display the effective avatar/frame/name style/badge while actual ownership remains protected in the inventory authority.

---

# 9. Profile and player identity

The profile is more than name + avatar now. It is the public identity surface for:

- game name;
- avatar;
- equipped avatar frame;
- equipped badge;
- profile background;
- name style;
- current rank;
- RP;
- level and XP;
- wins/losses/matches;
- win rate and streak information where available;
- permanent Prestige Stars;
- Legendary seasonal prestige history;
- selected achievements;
- selected historical rank emblem (`Legacy Showcase`);
- equipped cosmetic collection.

The current rank and historical rank showcase are intentionally different concepts:

- `RankBadge` = current competitive rank;
- `peakRankTier` = lifetime highest rank ever earned;
- `showcaseRankTier` = an earned historical emblem selected for public legacy display.

A historical emblem is rendered separately so it never falsely represents the player's current rank.

---

# 10. Rank system

The final competitive ladder is exactly eight tiers:

1. Bronze — 0 RP
2. Silver — 500 RP
3. Gold — 1200 RP
4. Platinum — 2200 RP
5. Diamond — 3500 RP
6. Master — 5000 RP
7. Grand Master — 7000 RP
8. Legendary — 10000 RP

The internal stored ID of Legendary remains `legend` for compatibility. Player-facing English is **Legendary**, Arabic is **أسطوري**.

## 10.1 Rank art

The rejected simplistic painter emblems are not the active presentation.

`RankEmblem` now renders the approved premium transparent WebP rank atlas containing all eight ranks in a 4×2 arrangement. Contract tests protect cell count/order and asset format.

## 10.2 Lifetime peak

`peakRankTier` records the highest rank a player has genuinely earned and persists across seasonal reset.

## 10.3 Rank Showcase

Players can inspect all earned rank emblems.

On Spark, the gallery is viewable but changing the persistent public showcase remains locked because this must be a trusted server write. On Blaze, `selectRankShowcase` validates that the requested tier was actually earned before persisting it.

## 10.4 Rank-up reveal

Rank promotion UI does not locally guess a promotion.

When Blaze authority is active:

- `settleRankedMatch` returns the authoritative player settlement;
- Flutter parses previous RP, next RP, delta, previous tier, next tier, XP and Coins;
- only a real upward tier transition triggers the reveal;
- the reveal is deduplicated by `matchId`;
- an idempotent settlement retry therefore cannot repeatedly celebrate the same promotion;
- accessibility reduced-motion is respected.

Full rank details are in `docs/rank-system-closeout.md`.

---

# 11. Legendary seasonal prestige

Legendary has a permanent repeat-achievement identity.

A player receives one Legendary-season count at most once for each distinct completed season whose peak tier reached Legendary. Dropping and re-entering Legendary in the same season must not increase the count twice.

Visual milestones:

- ×1 — base Legendary prestige;
- ×2 — double halo;
- ×3 — Crowned;
- ×5 — stronger aura;
- ×10+ — Legacy ornament/aura.

This multiplier is status/history only. It does not modify RP, matchmaking, rewards, score, game difficulty, or any competitive property.

Public surfaces such as profile and leaderboard can show this history while leaderboard ordering remains based on the competitive ranking rules, not prestige count.

---

# 12. Seasons

The season contract is exactly **30 days**.

Season lifecycle policy includes:

- one active season;
- exact start/end timestamps;
- next season begins at the previous season's exact end boundary;
- season number increments once;
- season progress/time remaining presentation;
- per-player seasonal peak tier;
- season history;
- authoritative rollover;
- permanent Prestige Star awards;
- soft RP reset;
- idempotent rollover.

The soft reset policy is centralized so it can be tuned deliberately before launch; it must not be reimplemented independently in UI code.

Season rollover and permanent rewards are server-authoritative operations and are not production-live while the app remains on Spark.

---

# 13. Prestige Stars

Prestige Stars are **permanent history/status**, not consumable currency.

Rules:

- awarded through legitimate seasonal/progression authority;
- persist across seasons;
- cannot be bought;
- cannot be converted to Coins/money;
- do not affect competitive gameplay;
- Star-gated cosmetics use a lifetime threshold rather than spending Stars.

Example: a cosmetic requiring 20 Stars checks that the account has reached at least 20 Stars; unlocking it does not reduce the player from 20 to 0 or 15.

This distinction is fundamental to the prestige economy.

---

# 14. Missions and progression

Progression includes level/XP policies and mission/achievement presentation.

Season Missions were deliberately made more visible after review: they are not supposed to be hidden behind a small floating action. The Season screen includes a clear Missions entry/card with Daily/Weekly/reward-oriented presentation and a visible call to action.

Authoritative progression collections remain owner-readable/server-writable where applicable. Mission rewards that affect trusted progression/economy must not be granted by an untrusted client.

---

# 15. Leaderboard

The leaderboard uses server-populated competition read models when Blaze authority is active.

Player entries can include:

- rank points;
- wins/losses;
- peak tier;
- avatar/name identity;
- Legendary seasonal count.

RankBadge receives the Legendary count so repeat Legendary prestige is visible publicly without altering ordering.

Live leaderboard authority remains a Blaze activation concern; Spark UI must not fabricate standings.

---

# 16. Shop and economy overview

The current cosmetic catalog contract is **v3** with **73 total entries**:

- 45 Avatars;
- 28 other cosmetics;
- 10 supported equipment slots.

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

The Flutter catalog and server entitlement catalog are required to use matching IDs, slots and authoritative pricing metadata. Tests protect this contract.

Full item-by-item documentation is maintained in `docs/shop-delivery-closeout.md`.

---

# 17. The 45-avatar system

Exactly 45 avatars are part of the approved current catalog.

## Free — 5

- Vanguard Captain
- Arena Ace
- Neon Hacker
- Street Phantom
- Star Warden

These are legitimate quality starter characters, not deliberately unattractive placeholders.

## Coins — 20

Coin avatar prices were deliberately increased by 100% during the current design pass. Current price ladder runs from **1,600 Coins through 11,000 Coins** depending on avatar.

These characters create meaningful long-term Coin goals.

## Premium — 10

Premium avatars use Google Play product IDs and server-verified entitlements. Catalog cent values exist for the entitlement contract, while production UI must use Google Play localized prices.

## Prestige Stars — 5

Star thresholds:

- 3
- 5
- 10
- 20
- 35

Stars are not spent.

## Earned/Exclusive — 5

Requirements include:

- reach Legendary once;
- Legendary in 3 distinct seasons;
- Legendary in 5 distinct seasons;
- 100 Ranked wins;
- finish a season as #1 champion.

The server re-checks authoritative player/season state before granting these items.

---

# 18. Non-avatar shop cosmetics

The non-avatar catalog contains Coin, Prestige-Star and Premium cosmetics, including high-value items that must have meaningful runtime delivery.

Examples include:

- Bold Name;
- Classic Frame;
- 3 Minutes/timer-style badge;
- Grid Background;
- GG Emote;
- Neon Frame;
- Champion Name;
- Voltage Frame;
- Arena Background;
- Victory Confetti;
- Electric Name;
- Arcade Room;
- Redline Intro;
- Storm Aura;
- Crown Badge;
- Prestige/Elite Frames;
- Rank Flare / Mythic Legacy Aura;
- Champion Intro;
- Constellation Background;
- Royal Name;
- Crown Burst;
- Obsidian Frame;
- Living Void Background;
- Portal Entrance;
- Lightning Victory;
- Cyber Royal Room.

Every item must satisfy two promises:

1. **Preview promise:** the player can understand what they are trying to obtain before paying/earning it.
2. **Delivery promise:** the equipped result uses the actual runtime implementation rather than a misleading shop-only thumbnail.

---

# 19. Shop preview system

All cosmetics, including locked items, are intended to be previewable.

The preview is not a purchase action. Opening a preview must never deduct Coins, consume Stars, create an entitlement, or trigger Google Play payment.

Difficult-to-preview items use contextual runtime previews:

- Avatar → displayed as actual character identity;
- Frame → shown around an avatar;
- Badge → shown near identity;
- Profile Background → displayed on a profile-like panel;
- Name Style → rendered on sample/player-name text;
- Match Intro → mini pre-match scene;
- Victory Effect → mini result/victory scene;
- Rank Aura → rendered around a rank emblem;
- Emote → rendered as the actual emote presentation;
- Room Theme → miniature/actual room-surface treatment.

The design target is that preview and runtime share the same central cosmetic rendering components wherever practical. The player should not pay for an impressive preview and receive a weaker unrelated result.

---

# 20. Animated cosmetics

There are currently 17 catalog items marked animated.

They are not intended to be static icons with an `ANIMATED` label. Central runtime animation exists for the relevant frames, name styles, profile backgrounds, rank auras, intros, victory effects and room themes.

Motion follows the restrained Cosmic Flow rule: premium and noticeable, but not noisy enough to harm readability or competitive focus.

Widget smoke tests render every `isAnimated` item and advance animation frames to detect rendering/runtime exceptions.

Reduced-motion/accessibility behavior must be respected where relevant.

---

# 21. Runtime delivery of cosmetics

Cosmetics are not considered delivered merely because their ID is present in inventory.

Runtime surfaces include:

- Avatar / Frame / Badge / Name Style / Background / Rank Aura → profile/player identity surfaces;
- identity cosmetics → Friends/search/requests/recent-player/room participant presentation where supported;
- Room Theme → hosted private room;
- Match Intro → Social and Ranked pre-match/countdown presentation;
- Victory Effect → Social and Ranked result presentation;
- GG Emote → social match interaction with cooldown and entitlement enforcement.

Public cosmetic state is derived from the trusted public `cosmeticLoadout` written after ownership validation. Ownership itself remains private/authoritative.

---

# 22. Coin purchases

Coin purchases must be server-authoritative.

`purchaseCosmetic` validates:

- authenticated player;
- known catalog item;
- correct price type;
- authoritative server price;
- sufficient Coins;
- item is not already owned.

The transaction atomically:

- deducts Coins;
- grants permanent entitlement;
- creates auditable transaction/receipt state.

The required invariant is:

**either deduction and ownership both succeed, or neither succeeds.**

Duplicate purchase must be rejected so the player cannot pay twice for the same permanent item.

---

# 23. Free, Prestige and Earned entitlement paths

## Free

A legitimate free item can be claimed/equipped without fake Coin price logic.

## Prestige

`unlockPrestigeCosmetic` checks the player's permanent Star total against the configured threshold, grants once, and records zero Stars spent.

## Earned

`claimEarnedCosmetic` re-validates the requirement server-side. A modified client claiming that it reached Legendary/100 wins/Season Champion is not sufficient.

---

# 24. Premium / Google Play entitlement path

Premium entitlement is not trusted simply because the client says payment succeeded.

Server verification checks:

- package `com.threeminutes.game`;
- Google Play purchase token;
- matching product/cosmetic ID;
- purchase state is purchased;
- verified line item contains the intended product;
- token is not reused for another user/cosmetic;
- permanent ownership is persisted transactionally;
- purchase acknowledgement is completed/retried.

The purchase token is used to create an idempotent receipt identity so retries do not duplicate ownership.

Actual production activation requires Blaze and correct Google Play Console product/service-account configuration.

---

# 25. Cosmetic security boundary

Firestore rules deny direct client writes to authoritative inventory/entitlement collections.

This prevents a modified APK from simply writing:

`ownedCosmeticIds += expensive_item`

or forging equipped ownership directly.

Trusted Cloud Functions/Admin authority owns sensitive economy writes.

The public `cosmeticLoadout` is presentation state derived after ownership checks. A client cannot safely turn that public projection into a new source of ownership.

Security tests also attempt hostile social/cosmetic mutations, including identity/emote forgery.

---

# 26. GG Emote security

The GG emote is a real match cosmetic, not just a shop card.

Behavior includes:

- equipped entitlement requirement;
- social-match display;
- cooldown;
- no score/time/gameplay effect;
- Firestore/Function security checks designed to prevent a modified client from broadcasting an unowned commercial emote.

---

# 27. Visual identity — Cosmic Flow

The current product direction is a professional dark competitive/cosmic identity rather than unrelated screen-by-screen styles.

Key direction:

- dark navy / indigo / deep-space foundation;
- cyan/violet accents;
- restrained premium glow;
- soft cards/panels;
- limited gradients;
- strong readability;
- no casino-like visual overload;
- responsive touch targets;
- animation secondary to interaction speed.

The earlier visual contract also emphasizes consistent contrast and the rule that cosmetics never obscure gameplay targets.

Competitive identity should feel premium but comfortable for repeated sessions.

---

# 28. Accessibility and fairness rules

Non-negotiable visual/gameplay accessibility rules:

- correct/wrong feedback must not depend on color alone;
- primary labels remain readable;
- active gameplay targets must not be covered by cosmetic effects;
- cosmetic animation must not alter hitboxes;
- cosmetics must not alter game timer, scoring, difficulty or opponent information;
- rank reveal and relevant effects should honor reduced-animation preference;
- Arabic RTL and English LTR must remain valid first-class layouts.

---

# 29. Localization

Flutter `gen_l10n` is the localization source.

Arabic and English are foundational languages.

The localization system includes:

- ARB catalogs;
- native RTL/LTR support through Flutter localization delegates;
- parity tests preventing missing keys in one language;
- localized auth/profile/match/result/history/competition/shop flows;
- localized mini-game copy.

Internal registry/protocol values are presentation-neutral; they should not leak hard-coded English text into Arabic gameplay.

---

# 30. Firebase and App Check

Firebase is the project backend platform.

Important current configuration rules:

- project: `minutes-d7dfc`;
- Firestore Standard, region `me-central2`;
- Cloud Functions target region `me-central2`;
- Node.js 22;
- Android package `com.threeminutes.game`;
- App Check uses Play Integrity for release;
- debug builds use the Debug provider.

Authoritative server deployments remain a separate release action from source completeness.

---

# 31. Firestore security model

The Firestore rule philosophy is deny-by-default for trusted state.

Examples of server-only/server-written areas include:

- seasons authoritative writes;
- leaderboards authoritative writes;
- inventories and entitlement writes;
- ranked settlements;
- coin transaction ledger;
- Prestige Star transaction history;
- purchase receipts;
- ranked evidence.

Players can read the data required for their UI according to ownership/public rules, but they cannot directly edit competitive/economic truth.

Social match fallback rules constrain which participant fields a player may change and protect other participants/identity fields.

---

# 32. Ranked anti-cheat and evidence

Ranked uses compact per-mini-game evidence rather than uploading every touch event.

Evidence includes:

- game ID;
- game index;
- deterministic game seed;
- score;
- accuracy;
- mistakes;
- duration.

Server validation checks:

- match authority/registry version;
- game count;
- deterministic sequence;
- exact expected seed;
- impossible value bounds;
- match timing;
- participant membership;
- settlement status.

`matchId` is the stable exactly-once settlement key.

This provides an anti-cheat boundary without turning each three-minute match into a huge raw interaction upload.

---

# 33. Cloud Functions authority

Prepared/implemented source contracts include operations such as:

- ranked matchmaking authority operations;
- `settleRankedMatch`;
- ranked result submission/evidence;
- cosmetic purchase;
- cosmetic equipment;
- Prestige cosmetic unlock;
- earned cosmetic claim;
- premium Google Play entitlement verification;
- rank showcase selection;
- social emote authority where used;
- season rollover.

These operations are designed around authenticated callers, validation, idempotency and Admin SDK writes.

The source can be complete while still **not production-live** until Blaze deployment occurs.

---

# 34. Spark vs Blaze — critical distinction

Current product phase remains **Spark** unless explicitly changed during a controlled deployment.

Spark currently allows safe client-side/product development, previews, UI, local domain policies and constrained social/multiplayer behavior.

The following must not be faked with insecure Firestore writes just to make buttons appear active:

- Ranked RP settlement;
- trusted XP/reward grants;
- Coin rewards/spending;
- permanent purchase entitlements;
- Prestige/earned unlock authority;
- Google Play verification;
- public rank showcase mutation;
- season rollover;
- live authoritative leaderboard writes.

Blaze activation requires deployment/security verification first, then a deliberate `BackendPhase.blaze` release switch.

See `docs/blaze-activation-checklist.md`.

---

# 35. Season/Blaze activation gate

Before switching to Blaze, verify at minimum:

- ranked callables deployed;
- authenticated membership validation;
- deterministic evidence validation;
- idempotent settlement;
- atomic RP/W-L/XP/Coins/leaderboard updates;
- exactly one active 30-day season;
- idempotent rollover;
- permanent Prestige Star calculation;
- economy catalog server authority;
- purchase/equip validation;
- Firestore authoritative collections remain non-client-writable;
- App Check/security strategy;
- required indexes;
- live season/leaderboard data exists;
- Google Play products/service-account access configured;
- two-device ranked testing passes.

---

# 36. CI and validation policy

The repository has automated validation for Flutter, Functions and Firestore/security contracts.

During the current product-development phase, APK creation was deliberately separated from ordinary source validation.

Normal validation covers combinations of:

- Cloud Functions TypeScript build/tests;
- server cosmetic catalog tests;
- Firestore Emulator rules/security tests;
- Flutter dependency resolution;
- `flutter analyze`;
- full Flutter tests;
- rank asset contracts;
- Legendary visual milestone tests;
- settlement parsing;
- promotion overlay behavior;
- shop/animated cosmetic smoke tests;
- localization/content contracts.

APK build/verification/upload is guarded for explicit manual workflow use rather than every normal validation change.

Temporary validation PRs are marker-only and are closed without merge; product code remains on `main`.

---

# 37. Most recent validation state covered by this master

The latest completed rank/profile No-APK validation before creation of this master passed:

- Cloud Functions build/tests: PASS;
- Firestore rules/security tests: PASS;
- Flutter Analyze: PASS;
- full Flutter Tests: PASS;
- Rank promotion behavior: PASS;
- Legacy Showcase rendering: PASS.

The shop closeout separately records successful validation for catalog/security/animated cosmetics.

This master document itself is documentation-only and does not claim a new runtime/device test.

---

# 38. Physical/device QA status

Physical two-client acceptance tests remain a release gate for the multiplayer experience.

Important device scenarios include:

- two-device matchmaking convergence;
- synchronized ready/countdown;
- full three-minute match;
- reconnect/resume;
- cancel-before-start;
- timeout settlement;
- rematch accept/withdraw;
- private/party invitation flow;
- Android deep link room joining;
- real Google Play purchase/restore/acknowledgement after Blaze/Play configuration;
- server-authoritative Ranked settlement on live infrastructure.

Do not confuse automated source validation with completion of these real-device network/payment acceptance scenarios.

---

# 39. Current documentation map

This master is the entry point. Deeper subsystem documents remain useful:

- `docs/architecture.md` — architecture fundamentals;
- `docs/section-1-closeout.md` — foundation closeout;
- `docs/section-2-progress.md` — multiplayer core;
- `docs/section-3-progress.md` — competition/economy/launch development history;
- `docs/section-3-runtime-readiness.md` — Spark-safe runtime boundary;
- `docs/visual-identity.md` — visual rules;
- `docs/cloud-functions-contracts.md` — authority contracts;
- `docs/blaze-activation-checklist.md` — production authority activation gate;
- `docs/shop-delivery-closeout.md` — all 73 shop items, prices, unlock paths and delivery rules;
- `docs/rank-system-closeout.md` — eight ranks, Legendary prestige, historical showcase and promotion delivery;
- `docs/rank-emblems-final-validation.md` — rank asset validation details.

When a specialized document contains a later, more specific technical closeout than an older section-progress file, the later specialized closeout is the current source of truth for that subsystem.

---

# 40. Locked product decisions

The following decisions must not be silently changed by future development:

- exactly 3 minutes per standard match;
- exactly 8 mini-games per standard match;
- current approved registry exactly 10 games;
- no Game #11 without explicit concept/visual approval;
- deterministic shared game sequence/seed contract;
- Arabic + English first-class;
- Ranked random 1v1;
- Private/Party sizes 2/4/6 only;
- no pay-to-win;
- cosmetics never change competitive behavior;
- eight rank tiers ending in Legendary;
- Legendary repeat prestige is distinct-season history;
- Prestige Stars are permanent and non-consumable;
- paid money buys cosmetics, never competitive history/power;
- 30-day season contract;
- lifetime peak rank remains permanent historical identity;
- authoritative economy/rank/season writes stay server-controlled;
- Google Play purchase success is not trusted without server verification;
- temporary CI PRs must never be merged into product history merely to trigger validation.

---

# 41. Current remaining engineering roadmap

The next major block after the rank/shop closeouts is the **Season + Soft Reset + Prestige Stars lifecycle audit and completion**.

That work should verify end-to-end:

- active season presentation;
- exact 30-day boundaries;
- seasonal peak tracking;
- permanent Star award;
- Legendary seasonal count;
- season history;
- soft RP reset;
- rollover idempotency;
- leaderboard archive/new-season behavior;
- mission visibility and season integration;
- profile presentation after rollover;
- Blaze deployment boundary.

After source completion, release work still includes controlled Blaze deployment, latest rules deployment, live Google Play configuration, physical two-device QA, and explicit APK/release builds.

---

# 42. Rule for future work and handoffs

Before making substantial changes, a future developer/AI should:

1. read this master document;
2. read the specialized closeout for the subsystem being changed;
3. inspect the current `main` code before editing;
4. distinguish **implemented in source** from **deployed/live**;
5. preserve the Spark/Blaze trust boundary;
6. run relevant automated validation after changes;
7. never invent a new game, rank, paid advantage, player-count mode, currency behavior, or season rule outside the locked product contract without explicit approval.

This file should be updated whenever a major subsystem is closed or a locked product decision changes, so the project can be resumed accurately from a new conversation or by a new developer without reconstructing history from chat logs.

---

# 43. 2026-08-19 Field QA remediation and validated replacement APK

A physical Android test of the previous debug APK exposed a device-facing quality batch that automated source validation had not proven: low-resolution avatar presentation/loading behavior, weak Premium/Missions discoverability, missing Settings/audio controls, missing sign-out confirmation, and player-facing infrastructure terminology.

The current remediation batch addresses those findings in source while preserving the locked gameplay/economy contracts.

## 43.1 Avatar runtime replacement

The old avatar path used base64 WebP atlases whose Free atlas decoded to only 480×96 px, effectively about 96×96 px per portrait before enlargement. The runtime has been replaced with local deterministic vector portraits rendered through Flutter `CustomPainter`.

The replacement:

- preserves all 45 approved avatar IDs and ownership/equipment contracts;
- removes Base64 decoding and atlas image waits;
- removes the avatar `FutureBuilder` loading cycle;
- is resolution-independent at card/profile/preview sizes;
- keeps Free / Coins / Premium / Prestige Stars / Exclusive tier differentiation;
- retains `AvatarArtwork.preloadAll()` as a compatibility no-op.

`test/avatar_runtime_quality_test.dart` renders representative avatars from all five acquisition classes at a 220px preview size and rejects paint/widget exceptions.

## 43.2 Settings, navigation and copy

The remediation also includes:

- player Settings accessible from the main menu;
- persistent music volume, SFX volume and mute controls;
- sound-effect preview;
- explicit sign-out confirmation;
- direct Premium Season Pass gateway from Season;
- prominent Missions gateway;
- bounded season resolution so Missions can open a safe preview state instead of waiting forever;
- neutral unavailable-state language rather than internal infrastructure-plan terminology;
- a source regression test preventing Spark/Blaze/Firebase/Firestore/Cloud Functions terminology from appearing in player-facing presentation/localization files;
- removal of obsolete `default_01..04` avatar selection from the approved profile/economy flow.

## 43.3 Audio across all modes

`GameAudioController` now provides generated, license-independent:

- menu ambience;
- focused match music;
- UI tap SFX;
- reward SFX;
- match-start SFX.

Ranked and Quick use `AudioMatchPlayScreen`. Private/Party/Social use a public audio wrapper around the unchanged Social gameplay core. Entering gameplay plays the start cue and switches to match music; leaving restores menu ambience. Audio remains fail-soft and cannot affect timer, score, evidence, settlement or competitive state.

## 43.4 Validation evidence

An intermediate run `32241032040` failed only because the newly added avatar widget test used a Dart-unsupported `for` element inside a const widget tree. Commit `558b0bece2e8bf508499f5e2546174ede9df1918` corrected the test without changing product runtime.

The corrected PR validation then passed Functions, Firestore, Analyze and full Flutter Tests.

The replacement APK was produced by dedicated **APK Validation run `32241945555`** from runtime base commit **`558b0bece2e8bf508499f5e2546174ede9df1918`**. Every workflow stage passed:

- Cloud Functions build/tests;
- Firestore emulator/security regression;
- Flutter dependency resolution;
- stable debug signing fingerprint verification;
- Flutter Analyze;
- full Flutter Tests;
- Android debug APK build;
- Google OAuth resource verification;
- APK certificate verification;
- artifact upload.

Validated artifact:

- artifact name: `3minutes-final-debug-apk`;
- artifact ID: `9361323419`;
- ZIP size: `83,676,865` bytes;
- artifact digest: `sha256:8df996fd30db25a15389072eb64543380a663d2de48e135d85ef0e3513b296a2`;
- retention expiry: `2026-08-26T10:24:09Z`.

Extracted APK:

- size: `162,226,039` bytes;
- SHA-256: `d38479bb2174f2cde13d1f220746ea4fa29ca4df9f7cdbce6314ef9b5581a14a`.

Temporary validation PRs #73, #74, #75 and #76 were not merged. Failed/intermediate validation evidence is retained rather than rewritten as success.

## 43.5 Current acceptance boundary

For this Field-QA batch, source remediation and automated validation are complete. What remains is physical-device acceptance of the replacement APK, especially:

- avatar visual quality across tiers;
- absence of avatar loading delay/spinner while browsing;
- Premium and Missions discoverability;
- Settings persistence;
- sign-out confirmation;
- menu/match music and SFX behavior across Ranked, Quick, Private and Party;
- volume/mute behavior on Android.

This does **not** close the separate production-live gates for Blaze deployment, real Google Play purchase verification, or full two-device authoritative multiplayer acceptance.