import assert from "node:assert/strict";
import { test } from "node:test";

import { COSMETICS, cosmeticById, equippedField } from "./catalog.js";

test("server catalog keeps exactly 45 approved avatars", () => {
  const avatars = COSMETICS.filter((item) => item.slot === "avatar");
  assert.equal(avatars.length, 45);
  assert.equal(avatars.filter((item) => item.priceType === "free").length, 5);
  assert.equal(avatars.filter((item) => item.priceType === "coins").length, 20);
  assert.equal(avatars.filter((item) => item.priceType === "premium").length, 10);
  assert.equal(avatars.filter((item) => item.priceType === "prestigeStars").length, 5);
  assert.equal(avatars.filter((item) => item.priceType === "earned").length, 5);
});

test("server cosmetic ids are unique and every slot maps to an equipped field", () => {
  const ids = COSMETICS.map((item) => item.id);
  assert.equal(new Set(ids).size, ids.length);

  const slots = new Set(COSMETICS.map((item) => item.slot));
  for (const slot of [
    "avatar",
    "avatarFrame",
    "badge",
    "profileBackground",
    "nameStyle",
    "matchIntro",
    "victoryEffect",
    "rankAura",
    "emote",
    "roomTheme",
  ] as const) {
    assert.equal(slots.has(slot), true, `${slot} has no server catalog delivery`);
    assert.equal(typeof equippedField(slot), "string");
  }
});

test("high value shop entitlements cannot silently change", () => {
  const expected = [
    ["name_bold", "nameStyle", "coins", 500, 0, 0],
    ["frame_classic", "avatarFrame", "coins", 750, 0, 0],
    ["badge_timer", "badge", "coins", 1200, 0, 0],
    ["background_grid", "profileBackground", "coins", 1600, 0, 0],
    ["emote_gg", "emote", "coins", 2200, 0, 0],
    ["frame_voltage", "avatarFrame", "coins", 7000, 0, 0],
    ["room_arcade", "roomTheme", "coins", 16000, 0, 0],
    ["aura_storm", "rankAura", "coins", 30000, 0, 0],
    ["intro_champion", "matchIntro", "prestigeStars", 0, 45, 0],
    ["victory_crown_burst", "victoryEffect", "prestigeStars", 0, 120, 0],
    ["aura_mythic_legacy", "rankAura", "prestigeStars", 0, 250, 0],
    ["intro_portal", "matchIntro", "premium", 0, 0, 399],
    ["victory_lightning", "victoryEffect", "premium", 0, 0, 399],
    ["room_cyber_royal", "roomTheme", "premium", 0, 0, 499],
  ] as const;

  for (const [id, slot, priceType, coinPrice, starPrice, premiumPriceCents] of expected) {
    const item = cosmeticById(id);
    assert.ok(item, `${id} missing from server catalog`);
    assert.equal(item.slot, slot, `${id} slot changed`);
    assert.equal(item.priceType, priceType, `${id} unlock path changed`);
    assert.equal(item.coinPrice, coinPrice, `${id} coin cost changed`);
    assert.equal(item.starPrice, starPrice, `${id} star threshold changed`);
    assert.equal(item.premiumPriceCents, premiumPriceCents, `${id} premium price changed`);
  }
});

test("prestige stars are thresholds, never mixed with premium price", () => {
  for (const item of COSMETICS.filter((value) => value.priceType === "prestigeStars")) {
    assert.ok(item.starPrice > 0, `${item.id} must have a star threshold`);
    assert.equal(item.coinPrice, 0, `${item.id} cannot also cost Coins`);
    assert.equal(item.premiumPriceCents, 0, `${item.id} cannot also be Premium`);
  }
});
