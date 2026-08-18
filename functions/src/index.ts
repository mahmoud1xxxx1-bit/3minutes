import { initializeApp } from "firebase-admin/app";

initializeApp();

export {
  joinRankedQueue,
  leaveRankedQueue,
  markRankedReady,
  cancelRankedMatch,
  submitRankedProgress,
} from "./match.js";

export { settleRankedMatch } from "./settlement.js";
export { settleSocialMatch } from "./social.js";
export { purchaseCosmetic, equipCosmetic } from "./economy.js";
export { unlockPrestigeCosmetic } from "./prestige.js";
export { verifyPremiumPurchase } from "./premium.js";
export {
  onRankedSettlementProgression,
  claimMissionReward,
  claimAchievementReward,
  claimSeasonPassReward,
} from "./progression.js";
export { rolloverRankedSeason } from "./season.js";
