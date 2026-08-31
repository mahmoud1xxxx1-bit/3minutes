import { initializeApp } from "firebase-admin/app";

initializeApp();

export {
  joinRankedQueue,
  leaveRankedQueue,
  cancelRankedMatch,
} from "./match.js";
export {
  submitRankedGameSelection,
  markRankedReadyV2 as markRankedReady,
} from "./game_selection.js";
export { submitRankedGameResultV2 as submitRankedGameResult } from "./ranked_submission_v2.js";
export {
  requestRankedRematch,
  cancelRankedRematch,
  syncRankedTicket,
  clearRankedTicket,
} from "./ranked_client.js";
export {
  joinQuickQueue,
  leaveQuickQueue,
  clearQuickTicket,
  syncQuickTicket,
  markQuickReady,
  cancelQuickMatch,
  submitQuickGameResult,
  requestQuickRematch,
  cancelQuickRematch,
  settleQuickMatch,
} from "./quick.js";
export { getQuickTicket } from "./quick_ticket.js";

export { settleRankedMatchV2 as settleRankedMatch } from "./settlement_v2.js";
export { submitSocialGameResult, sendSocialEmote } from "./social_submit.js";
export { settleSocialMatch } from "./social.js";
export { purchaseCosmetic, equipCosmetic } from "./economy.js";
export {
  unlockPrestigeCosmetic,
  selectRankShowcase,
  claimEarnedCosmetic,
} from "./prestige.js";
export { verifyPremiumPurchase } from "./premium.js";
export {
  verifyPremiumSeasonPass,
  onPremiumSeasonPassReward,
} from "./season_pass_premium.js";
export {
  onRankedSettlementProgression,
  claimMissionReward,
  claimAchievementReward,
  claimSeasonPassReward,
} from "./progression.js";
export { rolloverRankedSeason, processSeasonRolloverPage } from "./season.js";
