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
export { purchaseCosmetic, equipCosmetic } from "./economy.js";
export { unlockPrestigeCosmetic } from "./prestige.js";
export { rolloverRankedSeason } from "./season.js";
