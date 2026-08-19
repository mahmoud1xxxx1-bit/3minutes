# Approved Avatar & Rank Artwork — 2026-08-19

Status: ART DIRECTION LOCKED BY OWNER

This document records the owner-approved visual sources for the 45 Avatars and 8 competitive rank emblems. It exists specifically to prevent autonomous redesigns during technical quality work.

## Non-negotiable art rule

No developer/AI may change an approved Avatar character, face, silhouette, outfit identity, palette, visual style, or approved rank-emblem design without explicit owner approval first.

Allowed without a new art-direction approval: exact cropping, transparent masking, resolution-preserving/upscale processing, lossless/high-quality compression, caching, precaching, decode-size optimization, and replacing a low-resolution runtime asset with the same approved design at higher technical quality.

A prior deterministic vector Avatar implementation was a technical workaround only and was NOT artistically approved. It must not be treated as final artwork.

## Owner-approved Avatar source boards

The approved source set is exactly 45 portraits:

- FREE — 5: Vanguard Captain, Arena Ace, Neon Hacker, Street Phantom, Star Warden.
- COINS — 20: Nebula Scout, Flux Racer, Iron Sentinel, Pulse Duelist, Ember Agent, Orbit Archer, Prism Monk, Quantum Driver, Rift Ranger, Ion Valkyrie, Cipher Fox, Storm Gladiator, Solar Nomad, Luna Tactician, Cosmo Ranger, Voltage Ronin, Mirror Siren, Jet Commander, Astro Rogue, Halo Engineer.
- PREMIUM — 10: Nebula Oracle, Crimson Reaper, Eclipse Huntress, Solar Sovereign, Infinite Monarch, Void Queen, Astral Ronin, Celestial Emperor, Chrono Warden, Nova Duchess.
- PRESTIGE STARS — 5: Stellar Veteran, Celestial Judge, Rift Archon, Eternal Paladin, Infinite Sage.
- EXCLUSIVE — 5: Zenith Paragon, Crowned Legend, Legacy Warden, Ranked Conqueror, Season Champion.

Current IDs remain unchanged and authoritative:

- `avatar_free_vanguard`, `avatar_free_arena`, `avatar_free_hacker`, `avatar_free_phantom`, `avatar_free_warden`.
- `avatar_coin_01` through `avatar_coin_20`.
- `avatar_premium_01` through `avatar_premium_10`.
- `avatar_star_01` through `avatar_star_05`.
- `avatar_exclusive_01` through `avatar_exclusive_05`.

Prices/unlock requirements are NOT read from text printed on concept boards. Current Economy Catalog remains the authority for acquisition rules and prices.

## Owner-approved rank family

Exactly eight approved emblems, in locked order:

1. Bronze
2. Silver
3. Gold
4. Platinum
5. Diamond
6. Master
7. Grand Master
8. Legendary

Artwork is the premium shield/wing Cosmic Flow family previously approved by the owner. Technical replacement must preserve that exact family and must not revert to simplistic SVG/painter placeholders.

## Production asset policy

For this remediation pass:

- Every approved Avatar receives an individual 1024×1024 local high-quality WebP master extracted from the approved board without redesign.
- Every approved rank receives an individual 1024×1024 local high-quality WebP master extracted from the approved board without redesign.
- List/card rendering decodes a resized cache version of the local master to keep memory and startup latency controlled.
- The shell precaches small display versions before normal browsing so Shop/Profile/Friends do not show per-item loading spinners.
- Large Preview/Purchase/Earned/Equipped surfaces use the same approved master. A cached low-resolution rendering may remain underneath for the few milliseconds required to decode a larger local frame, so there is never a blank/spinner state.
- Runtime uses `FilterQuality.high` and preserves aspect ratio/crop safety.
- There is no network dependency and no Firebase Storage dependency for Avatar or rank artwork.

## Acceptance surfaces

The same approved artwork must be used consistently in:

- Shop list/card;
- locked Preview;
- purchase confirmation / acquisition state;
- owned state;
- equipped state;
- Profile;
- Home identity;
- Friends/social identity;
- rooms/lobbies where identity is shown;
- rank grid;
- rank preview;
- profile rank badge;
- leaderboard/social rank surfaces;
- rank-up presentation.

## Regression rule

Automated tests must reject:

- missing mappings among the 45 approved Avatar IDs;
- missing mappings among the 8 rank tiers;
- use of the old 96px runtime Avatar atlases;
- return of the unapproved temporary vector Avatar painter;
- large Preview rendering that falls back to a loading spinner;
- future artwork replacement without updating this owner-approval record.
