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

export type CosmeticPriceType = "coins" | "prestigeStars" | "premium";

export interface CosmeticDefinition {
  id: string;
  slot: CosmeticSlot;
  priceType: CosmeticPriceType;
  coinPrice: number;
  starPrice: number;
  premiumPriceCents: number;
}

function coin(id: string, slot: CosmeticSlot, coinPrice: number): CosmeticDefinition {
  return { id, slot, priceType: "coins", coinPrice, starPrice: 0, premiumPriceCents: 0 };
}

function star(id: string, slot: CosmeticSlot, starPrice: number): CosmeticDefinition {
  return { id, slot, priceType: "prestigeStars", coinPrice: 0, starPrice, premiumPriceCents: 0 };
}

function premium(id: string, slot: CosmeticSlot, premiumPriceCents: number): CosmeticDefinition {
  return { id, slot, priceType: "premium", coinPrice: 0, starPrice: 0, premiumPriceCents };
}

export const COSMETICS: ReadonlyArray<CosmeticDefinition> = [
  coin("name_bold", "nameStyle", 500),
  coin("frame_classic", "avatarFrame", 750),
  coin("badge_timer", "badge", 1200),
  coin("background_grid", "profileBackground", 1600),
  coin("emote_gg", "emote", 2200),
  coin("avatar_comet", "avatar", 3000),
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
