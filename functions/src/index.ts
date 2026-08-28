import { initializeApp } from "firebase-admin/app";

initializeApp();

export {
  joinRankedQueue,
  leaveRankedQueue,
  markRankedReady,
  cancelRankedMatch,
  submitRankedProgress,
} from "./match.js";
export {
  submitRankedGameResult,
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
export {
  claimDailyGold,
  enterGoldWager,
  leaveGoldWager,
  selectCompetitiveGames,
  markCompetitiveReady,
} from "./competitive.js";
export { cancelCompetitiveMatch } from "./competitive_cancel.js";
export { recoverCompetitiveQueue } from "./competitive_recovery.js";
export { settleCompetitiveMatch } from "./competitive_settlement.js";

export { settleRankedMatch } from "./settlement.js";
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
