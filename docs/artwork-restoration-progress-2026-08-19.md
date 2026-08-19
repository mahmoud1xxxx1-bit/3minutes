# Artwork Restoration Progress — 2026-08-19

Status: IN PROGRESS — SOURCE BUNDLE INCOMPLETE

This ledger records the active technical restoration of the owner-approved 45 Avatar portraits and 8 competitive rank emblems. It is subordinate to `approved-avatar-rank-artwork-2026-08-19.md` for art direction and exists to prevent an incomplete upload or technical workaround from being mistaken for final artwork.

## Verified repository baseline

- Authoritative repository: `mahmoud1xxxx1-bit/3minutes`.
- Restoration inspection started from `main` commit `15245bc7c6b1565f1cf5c6a9286063554ca08569`.
- Parent artwork-lock commit: `8e8977139e1a184988af60600bf45fc375558655`.
- The current runtime still uses the artistically rejected temporary vector Avatar implementation.
- The current rank runtime still uses the legacy 4×2 WebP atlas with 96px cells.

## Incomplete HD bundle evidence

`assets/avatars/approved_hd_00.b64` is the only committed `approved_hd_*` chunk on `main`.

It is **not a complete WebP asset**. Decoding its Base64 prefix exposes a valid WebP RIFF header whose declared complete file size is 261,550 bytes, while the committed text chunk is only 16,000 Base64 characters.

The same header reports a 1280×2816 image. Those dimensions align with a 5×11 grid of 256×256 cells, indicating that the interrupted upload was a Mega-Atlas/intermediate bundle rather than the final individual 1024×1024 production masters required by the artwork policy.

At 16,000 Base64 characters per chunk, the complete payload would require approximately 22 chunks. No `approved_hd_01` through the remaining expected chunks are committed. Both temporary art branches were checked and contain no commits ahead of `main`.

Therefore `approved_hd_00.b64` MUST NOT be treated as a valid production asset, decoded at runtime, or used as evidence that the 45+8 artwork set is complete.

## Source identity recovered from project history

The project handoff/history preserves the exact approved board filenames:

### Avatars

- Free: `أفاتارات_كونية_مجانية_تدفق_النجوم.png`
- Coins: `متجر_الكوينز_أبطال_المجرة.png`
- Premium: `واجهة_متجر_فاخرة_لشخصيات_كونية_مدفوعة.png`
- Prestige Stars: `لوحة_النجوم_الكونية_الأسطورية.png`
- Exclusive / Seasonal / Achievements: `أيقونات_النخبة_الذهبية_في_الفضاء.png`

### Ranks

- Approved eight-rank board: `أوسمة_الرتب_الأسطورية_في_الفضاء.png`
- Previously extracted rank files were recorded as `rank_bronze.png`, `rank_silver.png`, `rank_gold.png`, `rank_platinum.png`, `rank_diamond.png`, `rank_master.png`, `rank_grandmaster.png`, and `rank_legendary.png`.

These names identify the approved source artwork. They do not authorize recreation or visual substitution if the source bytes are unavailable.

## Current restoration boundary

Until the complete approved source images are available as actual file bytes, the following are prohibited:

- replacing the vector runtime with regenerated "similar" portraits;
- enlarging the old ~96px atlas cells and calling them HD masters;
- cropping avatar/rank art out of later marketing/report composites and treating that as the authoritative source;
- using SVG/Painter placeholders as the final rank artwork;
- building or labeling a new APK as the final artwork-remediated build.

## Planned implementation once the source files are available

1. Extract all 45 Avatar portraits from the five approved source boards with exact ordering and no redesign.
2. Extract all 8 rank emblems from the approved rank board in locked tier order.
3. Produce local high-quality individual WebP masters and map every existing Avatar ID / `RankTier` explicitly.
4. Replace `CustomPainter` Avatar runtime with local image rendering.
5. Replace the 96px rank atlas runtime with individual local rank images.
6. Implement small-display precache/decode sizing plus high-quality large preview from the same approved masters; no per-item spinner.
7. Rewrite regression tests so they reject vector Avatar fallback, 96px atlases, missing 45/8 mappings, and spinner-based large preview.
8. Validate Shop, locked preview, purchase/acquired/owned/equipped, Profile, Home, Friends/social, rooms/lobbies, rank grid/preview/profile/leaderboard/rank-up.
9. Run Functions tests, Firestore emulator security tests, Flutter Analyze, full Flutter Tests, then the APK validation workflow.
10. Only after all automated gates pass, produce the new APK for physical-device visual acceptance.

## Product systems explicitly out of scope

This restoration does not alter Economy Catalog pricing/acquisition rules, Ranked/Quick rewards, Premium Season Pass policy, Prestige Stars, matchmaking, match duration, mini-game registry/seed formula, social rules, or any other approved product/gameplay contract.
