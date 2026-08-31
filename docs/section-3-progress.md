# Section 3 — Current Product / Visual / Ranked State

Status: CODE COMPLETE FOR CURRENT SECTION-3 SCOPE; exact approved identity artwork bytes and device-level runtime QA remain external gates.

## Current baseline

- Active mini-game registry: v7 with 13 active games.
- Ranked match length: exactly 3 minutes.
- Ranked match set: 8 mini-games.
- Arabic and English remain first-class languages.
- Ranked outcome, rewards, wagers, rematches, season state, economy, and cosmetic ownership are server-authoritative.
- Flutter, Cloud Functions, Firestore rules, Analyze, and Flutter tests pass on the current main baseline after PR #104.

## Competitive authority complete in repository

- Server-authoritative Ranked matchmaking and match evidence validation.
- Server-authoritative winner ordering aligned with Flutter.
- Registry v7 aligned across Flutter and Cloud Functions.
- Server-authoritative RP, XP, Coins, wins/losses, rank progression, and settlement receipts.
- Idempotent Ranked settlement.
- 30-day season lifecycle, rollover, peak tier, persistent season stars, and Legendary season count.
- Authoritative leaderboard read model.
- Server-side cosmetic purchase/equip and inventory authority.
- Ranked wagers use positive whole Coins selected by the player.
- Players only match opponents with the same wager.
- Both stakes are atomically held when the match is created.
- Pre-start cancellation refunds both stakes.
- Winner receives the full pot; tie returns each stake; loser receives no pot.
- Ranked rematch reserves the same wager again.
- Match reward Coins remain separate from wager payout.
- Ranked result UI shows the authoritative settlement receipt: RP, XP, match Coins, wager payout, and total Coins received.
- Ranked room and history read the server-stored wager/pot values from MatchSession.

## Player identity and visual journey complete in runtime

The public equipped identity is now consistent across the major player-facing surfaces:

- Home
- Profile
- Friends
- Party
- Private Room
- Ranked Match Room
- Matchmaking
- Leaderboard
- Match History
- Ranked Result
- Friend/Room Match Result

Supported public identity pieces include avatar, avatar frame, cosmetic badge, name style, rank aura/profile presentation where relevant, rank, persistent stars, and repeated Legendary prestige (×N).

## Legendary prestige contract

- Eight competitive ranks are active: Bronze, Silver, Gold, Platinum, Diamond, Master, Grandmaster, Legendary.
- Legendary prestige count is server-derived from completed seasons.
- Legendary badge displays ×N only for Legendary.
- Prestige visuals scale at repeated Legendary milestones while remaining cosmetic-only.

## Approved identity-art contract

The final production identity-art contract is locked in `ApprovedIdentityArtManifest`:

- 45 approved avatar IDs.
- 8 approved rank identities.
- Canonical final format: local 1024×1024 WebP masters.
- Canonical avatar root: `assets/avatars/approved_1024`.
- Canonical rank root: `assets/ranks/approved_1024`.
- Legacy atlases/Base64 payloads are explicitly prohibited from being treated as production masters.

Important: `ApprovedIdentityArtManifest.productionSourcesAvailable` is intentionally `false` because the exact owner-approved 45 avatar and 8 rank WebP source bytes are not present in GitHub. Runtime therefore keeps its safe temporary fallback and must not silently substitute newly drawn lookalikes as final artwork.

## What is no longer current

The earlier Spark-only/10-game/Blaze-future notes are obsolete. Cloud Functions authority, registry v7, 13 active games, Ranked wagers, server settlement, cosmetic authority, and the expanded visual identity journey are already implemented in the repository.

## Remaining external gates

1. Restore/provide the exact owner-approved 45 avatar source images and 8 approved rank source images.
2. Export/normalize those exact masters to the manifest destinations as 1024×1024 WebP.
3. Flip `productionSourcesAvailable` only after all 53 production files are present and validated.
4. Run visual QA across Home, Profile, Shop, Friends, Party, Rooms, Matchmaking, Leaderboard, History, and Results with the final artwork.
5. Perform deferred two-device multiplayer/runtime QA on physical devices.
6. Verify production Firebase/Cloud Functions deployment state before a store release; repository CI success alone is not proof of production deployment.
7. Android APK/signing/OAuth validation remains a separate `workflow_dispatch` release-validation path and should not replace the PR/main Analyze/Test gates.

## Section-3 closeout rule

From the repository/code perspective, Section 3 is complete for the implemented product and visual-runtime architecture. Full visual closeout is blocked only by the missing exact approved artwork bytes and final device/release QA. Do not regenerate or replace approved artwork merely to mark the section complete.
