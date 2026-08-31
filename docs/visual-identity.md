# 3 Minutes — Visual Identity

Status: ACTIVE DESIGN CONTRACT

The visual system must stay lightweight, readable, competitive, and fast on ordinary Android phones. Graphics should make the game feel like a real competitive product without turning each mini-game into a separate art style.

## Core visual direction

- Dark arena-like base.
- Flat/classic game UI rather than glossy casino UI.
- Strong contrast and large touch targets.
- Warm gold accent for the 3 Minutes identity.
- Success and danger colors are reserved for clear gameplay feedback.
- Minimal decorative animation; gameplay response must always be faster than decoration.
- No pay-to-win visual effect may hide, resize, or alter gameplay targets.

## Core palette

The Flutter source of truth is `core/theme/design_tokens.dart`.

- Background: `#101214`
- Surface: `#1A1D20`
- Raised surface: `#23272B`
- Primary accent: `#F0C75E`
- Success: `#6BD89A`
- Danger: `#FF6B6B`
- Muted text/details: `#9AA3AB`

Art assets should harmonize with these values instead of introducing unrelated neon palettes.

## Player identity hierarchy

The player identity area should read in this order:

1. Avatar.
2. Persistent seasonal stars.
3. Player name.
4. Rank tier / RP.
5. Equipped cosmetic frame/badge/background/name style.
6. Level and XP progress.

Season stars are permanent prestige identity and must remain visible without affecting gameplay.

## Avatar system

- The approved identity library contains exactly 45 avatar IDs.
- Circular or near-circular crop for compact screens.
- Consistent silhouette scale across every avatar.
- Transparent asset background where practical.
- Cosmetic avatar frames sit outside the avatar crop and must never cover the face/primary subject.
- Default avatars must remain visually valid even when no paid/earned frame is equipped.
- Final production masters use the canonical 1024x1024 local WebP paths declared by `ApprovedIdentityArtManifest`.
- Temporary generated/vector artwork is a runtime fallback only and must not be treated as the final approved source.

## Rank visual language

Ranks remain mechanically defined in `RankPolicy`. The visual contract covers all eight competitive tiers and follows the same order everywhere in the app and server authority.

- Bronze: simple entry shield with clear low-tier identity.
- Silver: cleaner, brighter metal treatment.
- Gold: warm premium treatment aligned with the main accent.
- Platinum: cool high-rank treatment with increased precision and depth.
- Diamond: sharp premium geometry and unmistakable elite silhouette.
- Master: strong prestige treatment while remaining readable at small sizes.
- Grandmaster: more commanding geometry and prestige than Master, without borrowing Legendary crown language.
- Legendary: highest competitive identity, unique silhouette and crown/elite language reserved for the top tier.

Final production rank masters use the canonical 1024x1024 local WebP paths declared by `ApprovedIdentityArtManifest`. The existing rank atlas is a compatibility fallback only until the full approved source bundle is restored.

Rank art is identity only. It must never change mini-game difficulty, timing, target visibility, or touch behavior.

## Persistent season stars

- Small prestige stars displayed near/above the avatar.
- Must remain readable from 0 to large totals.
- Large totals should compact into a number rather than rendering dozens of icons.
- Stars do not reset between seasons.

## Cosmetic slots

### Avatar frame
Decorates the avatar perimeter only.

### Badge
Small identity emblem near the name/profile area.

### Profile background
Decorates profile/home identity panels; never the active mini-game playfield.

### Name style
Typography treatment only. It must preserve readability and never alter player-name content.

## Mini-game presentation rules

Every mini-game shares a stable shell:

- Match timer remains in the same location.
- Current game number remains visible.
- Opponent progress uses a secondary area and never obstructs the game.
- Instructions are short and centered near the playable area.
- Correct/wrong feedback must be immediately distinguishable.
- Touch targets should remain large enough for phones.
- Mini-games should primarily use shapes, symbols, text, icons, and lightweight bundled assets.

The mini-game itself may vary visually, but navigation, timer, score/progress language, and interaction feedback stay consistent.

## Motion

- Fast feedback: approximately 120 ms.
- Normal UI transition: approximately 220 ms.
- Avoid long entrance animations before or between mini-games.
- The synchronized 3-2-1 countdown is gameplay-critical and must not depend on decorative animation completion.

## Graphics asset strategy

Priority order:

1. Reusable rank emblems.
2. Default avatar set.
3. Cosmetic avatar frames and badges.
4. Profile backgrounds.
5. Mini-game-specific lightweight icons/assets only when shapes/text are insufficient.
6. Store promotional art last.

Do not create hundreds of unique raster assets for gameplay that can be expressed with Flutter primitives. This keeps APK size, loading time, and content production manageable as the library grows.

## Asset naming

Production identity masters use IDs and paths from `ApprovedIdentityArtManifest`, for example:

- `avatar_free_vanguard.webp`
- `avatar_coin_01.webp`
- `rank_bronze.webp`
- `rank_grandmaster.webp`
- `rank_legendary.webp`

Cosmetic assets continue to use predictable lowercase IDs such as `frame_classic`, `badge_timer`, and `background_grid`.

Avoid filenames that encode temporary screen locations or arbitrary revision numbers.

## Accessibility/readability

- Never communicate correct/wrong only by color; combine color with shape/icon/text feedback.
- Avoid tiny labels during live gameplay.
- Keep primary instructions short.
- Preserve sufficient contrast against the dark background.
- Cosmetic name styles must fall back to a readable standard style if an effect becomes unclear.

## Non-negotiable rule

Cosmetics and visuals are allowed to change identity and presentation only. They must never modify hitboxes, game timing, visibility, scoring, difficulty, opponent information, or any other competitive property.
