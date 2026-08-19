# 3 Minutes — Final closeout audit ledger

Date: 2026-08-19
Repository: `mahmoud1xxxx1-bit/3minutes`
Package: `com.threeminutes.game`
Firebase project: `minutes-d7dfc`
Primary region: `me-central2`

This is the permanent evidence ledger for the final closeout work. It records verified source state, user-facing options, server authority, security boundaries, automated validation, APK provenance, and deployment-only dependencies.

## 1. Core product contract

- Match duration: exactly 3 minutes.
- Competitive match game count: exactly 8.
- Approved mini-game library: exactly 10; no Game #11 exists.
- Deterministic game seed: `matchSeed ^ ((gameIndex + 1) * 0x45d9f3b)`.
- Ranked: 1v1 only.
- Private Room / Party: only 2, 4, or 6 players.
- Prestige Stars are permanent status thresholds and are never spent by Star unlocks.
- Paid cosmetics never grant competitive advantage.

## 2. Mini-games

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

The game registry deterministically selects the 8-game match sequence. Automated tests protect the approved library count and compatibility contract.

## 3. Ranked

- 1v1 only.
- Ranked is the only multiplayer mode that awards RP.
- Secure server-authority implementation exists for settlement.
- Rank ladder: Bronze, Silver, Gold, Platinum, Diamond, Master, Grand Master, Legendary.
- RP thresholds: 0 / 500 / 1200 / 2200 / 3500 / 5000 / 7000 / 10000.
- Peak Rank and historical showcase are server-controlled.
- Legendary prestige is repeatable once per distinct season and persists historically.
- `Legendary ×N` is represented in the profile/social rank presentation where supported.

## 4. Rank emblem preview

- All rank emblems, including locked ones, are tappable for preview.
- Preview shows large artwork, rank name, RP requirement, locked/earned state, and Legendary history where applicable.
- Earned historical emblems can be equipped only when trusted Ranked authority is enabled.
- Previewing a locked emblem never grants it.
- Equipping an older emblem never changes current competitive rank.

## 5. Quick Match

Quick is implemented as a separate server-authoritative 1v1 mode.

- Random 1v1 queue.
- Same 3-minute / 8-game deterministic match contract.
- XP + Coins rewards.
- No RP; settlement explicitly returns `rpDelta: 0`.
- No Ranked leaderboard or Peak Rank writes.
- Quick matches are excluded from Ranked history while legacy no-`mode` records remain compatible.
- Rematch produces a fresh Quick match.
- Ticket recovery uses an authenticated callable rather than exposing matchmaking data to clients.

Anti-farming:

- Same-pair usage counted server-side per UTC day.
- Matches 1–10: 100% reward.
- Matches 11–20: 25% reward.
- After 20: 0% farmable reward for that pair/day.
- Pair count and settlement are transactional so concurrent requests cannot bypass the policy.

Quick queue, evidence, settlement, and pair-usage collections are explicitly protected by Firestore security tests against normal client access/forgery.

## 6. Private Rooms / Party / invites

- Only 2, 4, or 6 players are accepted.
- Five-character room codes are validated.
- Host must be a participant.
- Duplicate participants are rejected.
- Readiness is restricted to current participants.
- Private / Party do not award Ranked RP.
- Invite URI contract: `threeminutes://join/CODE`.
- Android deep-link handling is present.
- Room sharing uses the direct invite service; the old clipboard-listener auto-share behavior was removed.

## 7. Friends / social

- Friend code/search/request/list/remove/block flows remain present.
- Recent players, room, and party flows remain separate from Ranked authority.
- Friend cards pass Legendary season count to the rank badge.
- Public cosmetic loadout is a server-written display mirror; normal clients cannot forge ownership/equipment through direct Firestore writes.

## 8. Season system

- Season policy remains about 30 days.
- Peak Rank is retained for season rewards.
- Prestige Stars persist as lifetime account history.
- Season history is owner-private under Firestore rules.
- Rollover records `finalStanding`, final RP/tier, Peak Rank, Stars, and Legendary-season history.
- Rank reset follows server policy rather than client-provided values.

## 9. Missions / progression

The Season screen includes a prominent Missions gateway rather than hiding tasks behind a subtle action.

Current mission catalog:

Daily:
- Play 3 matches.
- Win 1 match.
- Play 1 friend match.

Weekly:
- Play 30 matches.
- Win 15 matches.
- Play 5 friend matches.

Mission rewards use the established Coins + Season XP catalog. Quick settlement advances relevant play/win daily and weekly mission state when an active season exists.

The achievement catalog remains active for long-term progression, including first win, wins milestones, match volume, streak, friend play, six-player wins, seasons, and Prestige Stars.

## 10. Premium Season Pass

- Policy documented in `premium-season-pass-policy.md`.
- Premium Pass entitlement is season-bound.
- Google Play purchase must be server verified before durable entitlement grant.
- Restore flow exists in the client.
- Premium production use requires configured Play products and deployed trusted Functions.

## 11. Shop / universal preview

Every shop catalog item is tappable for preview, including locked items.

Preview supplies:

- Large/representative runtime rendering.
- Name and description.
- Acquisition method / price.
- Locked / Owned / Equipped state.
- Correct acquisition/equip action when server authority is available.

Supported cosmetic slots:

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

The UI explicitly informs the player that locked items can still be previewed.

## 12. Avatar library — exactly 45

Both Flutter and Cloud Functions catalogs are guarded by automated tests requiring exactly 45 avatar IDs with one acquisition path each.

Distribution:

- 5 Free.
- 20 Coins.
- 10 Premium / Google Play.
- 5 Prestige Star threshold unlocks.
- 5 Achievement / seasonal exclusives.

Avatar artwork is shipped in grouped atlas resources for Free, Coins, Premium, Stars, and Exclusive categories. Every approved avatar ID maps through `AvatarArtwork`; the catalog is not name-only metadata.

Exclusive unlock conditions:

- Reach Legendary once.
- Legendary ×3 seasons.
- Legendary ×5 seasons.
- 100 Ranked wins.
- Season Champion.

`Season Champion` is validated server-side by historical `finalStanding == 1` and cannot be self-awarded by the client.

## 13. Coins ownership integrity

Coin cosmetic purchase is one server transaction:

1. Load balance/ownership.
2. Reject duplicate ownership.
3. Reject insufficient balance.
4. Deduct exact server-catalog price.
5. Add ownership in the same transaction.
6. Write ledger record and resulting balance.

Therefore the approved transaction has no success state where Coins are deducted without ownership being granted.

## 14. Prestige Star ownership integrity

- Server reads lifetime Stars.
- Requires the catalog threshold.
- Stars are not deducted.
- Ownership becomes persistent.
- Receipt records `starsSpent: 0`.

## 15. Premium purchase integrity

- Client integrates Google Play billing and restore.
- Server premium authority verifies purchase before durable ownership.
- Restore relies on verified purchase history, not local-only state.
- Localized product availability/price ultimately comes from Google Play configuration.

## 16. Equipment integrity

- Server validates catalog item.
- Non-free item must be owned before equip.
- Free item may be granted on first equip.
- Inventory equipped field and public loadout mirror are written under server authority.
- Avatar equip updates the profile avatar mirror only after ownership validation.

## 17. Firestore / App Check security

Automated emulator validation covers, among other things:

- Own inventory read vs other-user denial.
- Season-history owner privacy.
- Rejection of forged season history.
- Social cosmetic/emote constraints.
- Quick authority collection privacy.

Reviewed trusted callable paths enforce App Check.

## 18. Android / authentication

- Firebase Auth + Google Sign-In are wired.
- Package remains `com.threeminutes.game`.
- Stable debug signing fingerprints are CI-enforced.
- Final APK workflow verifies generated Google OAuth resources.
- Final APK workflow verifies the embedded APK signing certificate after build.

## 19. CI evidence

No-APK validation run `32226618436`: PASS.

Final no-APK validation after Quick history/security corrections: run `32227173070`: PASS.

Verified there:

- Cloud Functions build/tests: PASS.
- Firestore rules/security tests: PASS.
- Flutter dependency resolution: PASS.
- `flutter analyze`: PASS.
- `flutter test`: PASS.

Temporary validation PRs were marker-only and closed without merge.

## 20. Dedicated APK workflow

The original `flutter-ci.yml` builds APK only for `workflow_dispatch`. Since the connected GitHub integration does not provide a workflow-dispatch mutation, `.github/workflows/apk-validation.yml` was added as a controlled build path.

It triggers only from the dedicated `.ci-apk-trigger` PR marker and runs:

- Functions build/tests.
- Firestore rules/security tests.
- Flutter Analyze.
- Flutter Tests.
- Android debug APK build.
- Google OAuth resource verification.
- APK certificate verification.
- Artifact upload.

Final APK Validation:

- Workflow run: `32227715972`.
- Job: `validate-apk`.
- Result: **SUCCESS**.
- Every required build/security/test/certificate/upload step passed.
- Temporary PR #71 was closed without merge.

## 21. Final artifact evidence

Full provenance is recorded separately in `final-apk-validation-2026-08-19.md`.

GitHub Artifact:

- ID: `9356279815`.
- Name: `3minutes-final-debug-apk`.
- ZIP size: `80,523,495` bytes.
- ZIP SHA-256: `5407a5714daa6205fe58a5200cf17f491b44b63e2e4c5b14632ddaa5ffbaa6ca`.
- Expiry: 2026-08-26.

Extracted APK:

- Original artifact filename: `app-debug.apk`.
- User delivery filename: `3minutes-final-2026-08-19-debug.apk`.
- Size: `158,825,508` bytes.
- APK SHA-256: `67361714d6d92bc93f4886ea6a546b5419c15322655ec6874d1235aa49871e02`.

CI enforced debug certificate fingerprints:

- SHA-1: `9D:0C:AE:8A:CE:E4:97:46:EE:C8:1F:16:E6:B1:F1:7A:33:65:B9:EA`.
- SHA-256: `4B:A2:BA:D2:AD:8F:B2:70:C0:F7:BA:B6:11:07:BA:6F:EE:33:2A:09:20:C9:50:39:CB:0E:83:BA:5D:FF:85:30`.

## 22. Deployment boundary — still external

`AppConfig.backendPhase` intentionally remains `spark`.

The repository therefore contains and validates trusted source for Ranked authority, Quick, economy purchase authority, premium verification, live leaderboard, and other server-only features, but they must not be described as production-live until external deployment is completed:

1. Upgrade Firebase to Blaze.
2. Deploy reviewed Firestore Rules + Cloud Functions to `minutes-d7dfc` / `me-central2`.
3. Configure/activate intended Google Play Billing products and regional prices.
4. Verify release Play Integrity / App Check configuration.
5. Switch reviewed backend phase only after deployment smoke testing.

**Source complete / CI verified is not the same as production backend deployed.**

## 23. Final closeout status

- Source/logic audit: **PASS**.
- Functions tests: **PASS**.
- Firestore security tests: **PASS**.
- Flutter Analyze: **PASS**.
- Flutter Tests: **PASS**.
- Android debug APK build: **PASS**.
- Google OAuth resource validation: **PASS**.
- APK certificate validation: **PASS**.
- Artifact upload/download/hash verification: **PASS**.
- Temporary final APK PR: **closed, not merged**.

Final validated debug APK closeout: **COMPLETE**.
