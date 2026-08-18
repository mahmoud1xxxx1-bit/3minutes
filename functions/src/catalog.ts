export type CosmeticSlot =
  | "avatarFrame"
  | "badge"
  | "profileBackground"
  | "nameStyle";

export interface CosmeticDefinition {
  id: string;
  slot: CosmeticSlot;
  coinPrice: number;
}

export const COSMETICS: ReadonlyArray<CosmeticDefinition> = [
  { id: "frame_classic", slot: "avatarFrame", coinPrice: 250 },
  { id: "frame_neon", slot: "avatarFrame", coinPrice: 600 },
  { id: "badge_timer", slot: "badge", coinPrice: 400 },
  { id: "badge_crown", slot: "badge", coinPrice: 900 },
  { id: "background_grid", slot: "profileBackground", coinPrice: 500 },
  { id: "background_arena", slot: "profileBackground", coinPrice: 800 },
  { id: "name_bold", slot: "nameStyle", coinPrice: 300 },
  { id: "name_champion", slot: "nameStyle", coinPrice: 750 },
];

export function cosmeticById(id: string): CosmeticDefinition | null {
  return COSMETICS.find((item) => item.id === id) ?? null;
}

export function equippedField(slot: CosmeticSlot): string {
  switch (slot) {
    case "avatarFrame":
      return "equippedAvatarFrameId";
    case "badge":
      return "equippedBadgeId";
    case "profileBackground":
      return "equippedProfileBackgroundId";
    case "nameStyle":
      return "equippedNameStyleId";
  }
}
