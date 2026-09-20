export type CosmeticSlot =
  | "avatar"
  | "avatarFrame"
  | "badge"
  | "profileBackground"
  | "nameStyle"
  | "matchIntro"
  | "victoryEffect"
  | "rankAura"
  | "emote"
  | "roomTheme";

export type CosmeticPriceType =
  | "free"
  | "coins"
  | "prestigeStars"
  | "premium"
  | "earned";

export interface CosmeticDefinition {
  id: string;
  slot: CosmeticSlot;
  priceType: CosmeticPriceType;
  coinPrice: number;
  starPrice: number;
  premiumPriceCents: number;
  earnedRequirement?: string;
}

const base = (
  id: string,
  slot: CosmeticSlot,
  priceType: CosmeticPriceType,
): CosmeticDefinition => ({
  id,
  slot,
  priceType,
  coinPrice: 0,
  starPrice: 0,
  premiumPriceCents: 0,
});

const free = (id: string, slot: CosmeticSlot): CosmeticDefinition =>
  base(id, slot, "free");
const coin = (id: string, slot: CosmeticSlot, coinPrice: number): CosmeticDefinition => ({
  ...base(id, slot, "coins"),
  coinPrice,
});
const star = (id: string, slot: CosmeticSlot, starPrice: number): CosmeticDefinition => ({
  ...base(id, slot, "prestigeStars"),
  starPrice,
});
const premium = (
  id: string,
  slot: CosmeticSlot,
  premiumPriceCents: number,
): CosmeticDefinition => ({
  ...base(id, slot, "premium"),
  premiumPriceCents,
});
const earned = (
  id: string,
  slot: CosmeticSlot,
  earnedRequirement: string,
): CosmeticDefinition => ({
  ...base(id, slot, "earned"),
  earnedRequirement,
});

export const COSMETICS: ReadonlyArray<CosmeticDefinition> = [
  // Exactly 45 approved avatars.
  free("avatar_free_vanguard", "avatar"),
  free("avatar_free_arena", "avatar"),
  free("avatar_free_hacker", "avatar"),
  free("avatar_free_phantom", "avatar"),
  free("avatar_free_warden", "avatar"),
  coin("avatar_coin_01", "avatar", 1600),
  coin("avatar_coin_02", "avatar", 2000),
  coin("avatar_coin_03", "avatar", 2400),
  coin("avatar_coin_04", "avatar", 2800),
  coin("avatar_coin_05", "avatar", 3200),
  coin("avatar_coin_06", "avatar", 3600),
  coin("avatar_coin_07", "avatar", 4000),
  coin("avatar_coin_08", "avatar", 4400),
  coin("avatar_coin_09", "avatar", 4800),
  coin("avatar_coin_10", "avatar", 5200),
  coin("avatar_coin_11", "avatar", 5600),
  coin("avatar_coin_12", "avatar", 6000),
  coin("avatar_coin_13", "avatar", 6400),
  coin("avatar_coin_14", "avatar", 6800),
  coin("avatar_coin_15", "avatar", 7200),
  coin("avatar_coin_16", "avatar", 7600),
  coin("avatar_coin_17", "avatar", 8400),
  coin("avatar_coin_18", "avatar", 9200),
  coin("avatar_coin_19", "avatar", 10000),
  coin("avatar_coin_20", "avatar", 11000),
  premium("avatar_premium_01", "avatar", 998),
  premium("avatar_premium_02", "avatar", 998),
  premium("avatar_premium_03", "avatar", 1198),
  premium("avatar_premium_04", "avatar", 1198),
  premium("avatar_premium_05", "avatar", 1398),
  premium("avatar_premium_06", "avatar", 1398),
  premium("avatar_premium_07", "avatar", 1598),
  premium("avatar_premium_08", "avatar", 1598),
  premium("avatar_premium_09", "avatar", 1998),
  premium("avatar_premium_10", "avatar", 1998),
  star("avatar_star_01", "avatar", 3),
  star("avatar_star_02", "avatar", 5),
  star("avatar_star_03", "avatar", 10),
  star("avatar_star_04", "avatar", 20),
  star("avatar_star_05", "avatar", 35),
  earned("avatar_exclusive_01", "avatar", "legendary_once"),
  earned("avatar_exclusive_02", "avatar", "legendary_x3"),
  earned("avatar_exclusive_03", "avatar", "legendary_x5"),
  earned("avatar_exclusive_04", "avatar", "wins_100"),
  earned("avatar_exclusive_05", "avatar", "season_champion"),

  // Existing non-avatar coin cosmetics.
  coin("name_bold", "nameStyle", 500),
  coin("frame_classic", "avatarFrame", 750),
  coin("badge_timer", "badge", 1200),
  coin("background_grid", "profileBackground", 1600),
  coin("emote_gg", "emote", 2200),
  coin("frame_neon", "avatarFrame", 4200),
  coin("name_champion", "nameStyle", 5500),
  coin("frame_voltage", "avatarFrame", 7000),
  coin("background_arena", "profileBackground", 8500),
  coin("victory_confetti", "victoryEffect", 10000),
  coin("name_electric", "nameStyle", 12500),
  coin("room_arcade", "roomTheme", 16000),
  coin("intro_redline", "matchIntro", 22000),
  coin("aura_storm", "rankAura", 30000),

  star("badge_crown", "badge", 10),
  star("frame_prestige", "avatarFrame", 20),
  star("aura_rank_flare", "rankAura", 30),
  star("intro_champion", "matchIntro", 45),
  star("background_constellation", "profileBackground", 60),
  star("name_royal", "nameStyle", 80),
  star("victory_crown_burst", "victoryEffect", 120),
  star("frame_elite", "avatarFrame", 160),
  star("aura_mythic_legacy", "rankAura", 250),

  premium("frame_obsidian", "avatarFrame", 199),
  premium("background_void", "profileBackground", 299),
  premium("intro_portal", "matchIntro", 399),
  premium("victory_lightning", "victoryEffect", 399),
  premium("room_cyber_royal", "roomTheme", 499),
];

export function cosmeticById(id: string): CosmeticDefinition | null {
  return COSMETICS.find((item) => item.id === id) ?? null;
}

export function equippedField(slot: CosmeticSlot): string {
  switch (slot) {
    case "avatar":
      return "equippedAvatarId";
    case "avatarFrame":
      return "equippedAvatarFrameId";
    case "badge":
      return "equippedBadgeId";
    case "profileBackground":
      return "equippedProfileBackgroundId";
    case "nameStyle":
      return "equippedNameStyleId";
    case "matchIntro":
      return "equippedMatchIntroId";
    case "victoryEffect":
      return "equippedVictoryEffectId";
    case "rankAura":
      return "equippedRankAuraId";
    case "emote":
      return "equippedEmoteId";
    case "roomTheme":
      return "equippedRoomThemeId";
  }
}