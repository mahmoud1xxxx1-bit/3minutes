# 3 Minutes — Final closeout audit ledger

Date: 2026-08-19
Repository: `mahmoud1xxxx1-bit/3minutes`
Package: `com.threeminutes.game`
Firebase project: `minutes-d7dfc`
Primary region: `me-central2`

This is the permanent evidence ledger for the closeout work. It records the verified source state, user-facing features, server authority, security boundaries, automated validation, APK provenance, and deployment-only dependencies. It must be updated whenever the closeout state changes.

## 1. Product invariants

- Match duration: exactly 3 minutes.
- Mini-games per competitive match: exactly 8.
- Approved mini-game library: exactly 10 games; no Game #11 is present.
- Deterministic per-game seed remains `matchSeed ^ ((gameIndex + 1) * 0x45d9f3b)`.
- Ranked is 1v1 only.
- Private Room and Party support only 2, 4, or 6 players.
- Prestige Stars are permanent status thresholds; unlocking Star cosmetics does not spend Stars.
- Paid cosmetics never grant gameplay/ranking advantage.

## 2. Approved mini-game library

Registry version: 3.

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

The registry selects the requested 8-game sequence deterministically and covers the available gameplay categories. Automated registry/content policy tests protect the approved game count.

## 3. Ranked mode

- 1v1 only.
- Ranked is the only multiplayer mode that awards RP.
- Server-authority source exists for secure ranked settlement.
- Rank ladder contains exactly eight tiers: Bronze, Silver, Gold, Platinum, Diamond, Master, Grand Master, Legendary.
- RP thresholds: 0, 500, 1200, 2200, 3500, 5000, 7000, 10000.
- Peak rank and historical showcase are server-controlled fields.
- Legendary prestige is seasonal and repeatable once per distinct season; the historical count is permanent.
- `Legendary ×N` is surfaced in profile/social rank presentation where supported.

Deployment note: production ranked authority remains gated while `AppConfig.backendPhase == BackendPhase.spark`. Source validation is not the same as deployed Cloud Functions.

## 4. Quick Match

Quick Match has been completed as a separate 1v1 server-authoritative flow.

Verified behavior:

- Random 1v1 queue.
- Uses the same 3-minute / 8-game deterministic match contract.
- Awards XP and Coins.
- Awards **zero RP**; settlement payload explicitly records `rpDelta: 0`.
- Does not write Ranked leaderboard/peak-rank state.
- Quick matches are excluded from Ranked match history; legacy matches without a `mode` field remain compatible as Ranked history.
- Rematch flow creates a fresh Quick match.
- Queue ticket recovery is exposed through an authenticated callable rather than opening the matchmaking collection to clients.

Anti-farming policy:

- Pair usage is counted server-side per UTC day.
- First 10 same-pair matches: full Quick rewards.
- Matches 11–20: 25% reward multiplier.
- After 20: zero farmable Quick reward for that pair/day.
- Pair count and settlement happen transactionally to prevent concurrent bypass.

Quick authority collections are server-only: queue, evidence, settlements, and pair-usage data are explicitly covered by Firestore security tests so clients cannot directly read/write or forge them.

Deployment note: Quick UI/source exists but trusted production operation requires Blaze + deployed Functions; Spark keeps the secure authority path disabled rather than falling back to insecure client writes.

## 5. Private Rooms and Party

- Supported player counts are exactly 2, 4, and 6.
- No 3-player or 5-player room configuration is permitted by domain policy.
- Five-character room codes are validated.
- Host must be a participant.
- Duplicate participants are rejected.
- Readiness only applies to current room participants.
- Private/Party modes do not award Ranked RP.
- Invite links use `threeminutes://join/CODE`.
- Android deep-link handling and the direct room-invite service are present.
- The old clipboard-listener based invitation behavior was removed during cleanup; sharing is invoked intentionally from the room flow.

## 6. Friends and social presentation

- Friend code/search/request/list/remove/block flows remain part of the social system.
- Recent players and room/party flows remain separated from Ranked authority.
- Friend player cards now propagate Legendary season count into the rank badge so prestige history is not silently lost in that presentation.
- Social cosmetic loadout is display-only from the client perspective; server ownership verification controls public equipment mirrors.

## 7. Season system

- Season duration policy remains approximately 30 days.
- Peak Rank is retained for season reward calculation.
- Prestige Stars persist as lifetime account history.
- Season history is private to the owner under Firestore rules.
- Season rollover writes `finalStanding`, final RP/tier, peak tier, Stars, and Legendary-season history.
- Rank reset uses the established season policy instead of client-provided values.

### Season Missions UX

The Season page contains a prominent Missions gateway, not merely a hidden icon. It describes Daily/Weekly missions and rewards and links into progression.

Current mission catalog:

- Daily: play 3, win 1, play 1 friend match.
- Weekly: play 30, win 15, play 5 friend matches.
- Mission rewards include Coins and Season XP according to the existing catalog.

Quick settlement advances the relevant play/win daily and weekly mission state when an active season exists.

## 8. Premium Season Pass

- Premium Season Pass policy is documented separately in `docs/premium-season-pass-policy.md`.
- Pass entitlement is season-bound; an entitlement cannot silently grant multiple seasons.
- Google Play verification is performed by server-side premium authority before durable entitlement grant.
- Premium restore flow exists in the client.
- Production use requires configured Google Play products and deployed Functions.

## 9. Shop and universal preview

The shop has a central preview flow. All catalog items are tappable for preview, including locked items.

Preview exposes:

- Large cosmetic rendering / representative runtime presentation.
- Name and description.
- Acquisition method / price label.
- Locked, Owned, or Equipped state.
- Correct action path when authority is available.

The shop explicitly tells players that locked items can be previewed.

Supported cosmetic slots include:

- Avatar
- Avatar Frame
- Badge
- Profile Background
- Name Style
- Match Intro
- Victory Effect
- Rank Aura
- Emote
- Room Theme

Runtime components exist for profile/avatar/name/badge/aura/victory and the remaining cosmetic presentation slots used by the application.

## 10. Rank emblem preview

Rank emblem browsing was corrected during this closeout pass:

- Locked rank emblems are tappable for preview.
- Preview shows a large emblem, rank name, RP requirement, earned/locked state, and Legendary history where applicable.
- Earned emblems can be equipped from the preview when secure Ranked authority is enabled.
- Previewing an unearned emblem never grants/equips it.
- Historical emblem selection does not alter the player's current competitive rank.

## 11. Avatar catalog — exactly 45

Client and server catalogs are both guarded by automated tests that require exactly 45 avatar definitions with unique IDs and one acquisition path each.

Distribution:

- 5 Free.
- 20 Coins.
- 10 Premium / Google Play.
- 5 Prestige Star threshold unlocks.
- 5 Achievement / seasonal exclusives.

Artwork is not represented by names alone: the application ships avatar atlas artwork resources for Free, Coins, Premium, Stars, and Exclusive groups, and every approved avatar ID maps to artwork through `AvatarArtwork`.

Exclusive requirements:

- Reach Legendary once.
- Legendary ×3 seasons.
- Legendary ×5 seasons.
- 100 Ranked wins.
- Season Champion.

`Season Champion` is verified server-side by searching the player's season history for `finalStanding == 1`; it is not a cosmetic that the client can self-claim.

## 12. Ownership and purchase integrity

### Coins

Coin cosmetic purchase is a single Firestore transaction under server authority:

- Load balance and ownership.
- Reject already-owned item.
- Reject insufficient Coins.
- Deduct exact server-catalog price.
- Add ownership in the same transaction.
- Write a ledger transaction with resulting balance.

There is no valid success path where Coins are deducted without ownership being granted by that transaction.

### Prestige Stars

- Server reads lifetime Stars from the user profile.
- Requires the catalog threshold.
- Does **not** subtract Stars.
- Permanently adds ownership.
- Writes a receipt recording `starsSpent: 0`.

### Premium Google Play items

- Client billing starts purchase/restore.
- Server premium authority verifies purchase before durable grant.
- Premium ownership is restored from verified purchase history rather than relying only on local state.
- Real production product availability and localized price come from Google Play configuration.

### Equip

Server verifies catalog item and ownership before equipment.
Free items may be granted on first equip; non-free items cannot be equipped unless owned.
The server writes the inventory equipped field and the public display-only loadout mirror together.

## 13. Firestore security boundaries

Automated emulator rules validation covers core privacy/security behavior, including:

- Inventory owner readability and other-user denial.
- Season history owner-only access.
- Forged season history writes rejected.
- Cosmetic/security constraints in social matches.
- Quick authority collections inaccessible to normal clients.

Cloud Functions use App Check enforcement in the trusted callable paths reviewed during closeout.

## 14. Authentication / Android identity

- Google Sign-In is wired through Firebase Auth.
- Fixed Android application package remains `com.threeminutes.game`.
- CI verifies the expected stable debug signing fingerprints.
- APK validation also verifies generated Google OAuth resources and the APK certificate before artifact upload.

## 15. CI evidence before final APK run

No-APK validation run `32226618436`: PASS.

After the final history/security corrections, No-APK validation run `32227173070`: PASS.

Verified stages in the latter run:

- Install Cloud Functions dependencies: PASS.
- Build and test Cloud Functions: PASS.
- Firestore rules and cosmetic/Quick security tests: PASS.
- Flutter dependency resolution: PASS.
- `flutter analyze`: PASS.
- `flutter test`: PASS.

The temporary CI PRs were marker-only and closed without merge.

## 16. APK validation workflow

The existing `flutter-ci.yml` intentionally builds the APK only for `workflow_dispatch`. Because the connected GitHub tool does not expose a workflow-dispatch action, an explicit `.github/workflows/apk-validation.yml` workflow was added.

Safety properties of this workflow:

- It only runs on pull requests that contain the `.ci-apk-trigger` path.
- It repeats Functions tests, Firestore security validation, Flutter Analyze and Flutter Tests.
- It restores the known stable debug signing key.
- It builds `app-debug.apk`.
- It verifies generated Google OAuth resources.
- It verifies APK certificate SHA-1/SHA-256.
- It uploads the validated APK as the `3minutes-debug-apk` artifact.

Final APK Validation run currently tracked: `32227715972`.

At the time of this ledger update, Functions tests, Firestore rules/security, Flutter setup, signing-key restoration, dependency resolution, Analyze, and Flutter Tests have already passed; `Build Android debug APK` is running. The final artifact metadata, file SHA-256, and certificate result will be appended only after the workflow completes successfully.

## 17. Current deployment boundary

`AppConfig.backendPhase` remains `spark` intentionally.

Therefore the repository contains and validates trusted source for Ranked authority, Quick, economy purchasing, premium verification, live leaderboard, and related server-only flows, but those production paths are not to be represented as live until all of the following external steps are completed:

1. Upgrade the Firebase project to Blaze.
2. Deploy the reviewed Firestore Rules and Cloud Functions to `minutes-d7dfc` in `me-central2`.
3. Configure/activate the intended Google Play Billing products and price/region data.
4. Verify Play Integrity/App Check release configuration.
5. Switch the reviewed backend phase only after deployment and smoke validation.

This distinction is mandatory: **source complete / CI verified** does not mean **production backend deployed**.

## 18. Closeout status

Source/logic closeout: PASS based on the latest No-APK validation and manual source audit recorded above.

APK closeout: PENDING only until APK Validation run `32227715972` completes certificate verification and artifact upload. No older APK is to be labeled as the final build.
