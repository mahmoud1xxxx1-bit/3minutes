export const ALLOWED_GOLD_WAGERS = [100, 250, 500] as const;
export type GoldWager = (typeof ALLOWED_GOLD_WAGERS)[number];

export function parseGoldWager(value: unknown): GoldWager {
  if (typeof value !== 'number' || !Number.isInteger(value)) {
    throw new Error('wagerGold must be exactly 100, 250, or 500.');
  }
  if (!ALLOWED_GOLD_WAGERS.includes(value as GoldWager)) {
    throw new Error('wagerGold must be exactly 100, 250, or 500.');
  }
  return value as GoldWager;
}

export interface GoldEscrowSettlement {
  playerARefund: number;
  playerBRefund: number;
  playerAPayout: number;
  playerBPayout: number;
  burnedGold: number;
  reason:
    | 'playerA_win'
    | 'playerB_win'
    | 'double_fail'
    | 'draw_refund'
    | 'technical_refund';
}

export function settleGoldEscrow(options: {
  wagerGold: GoldWager;
  outcome: 'playerA' | 'playerB' | 'tie';
  technicalCancel?: boolean;
  tieIsFailure?: boolean;
}): GoldEscrowSettlement {
  const {
    wagerGold,
    outcome,
    technicalCancel = false,
    tieIsFailure = true,
  } = options;
  const pool = wagerGold * 2;

  if (technicalCancel) {
    return {
      playerARefund: wagerGold,
      playerBRefund: wagerGold,
      playerAPayout: 0,
      playerBPayout: 0,
      burnedGold: 0,
      reason: 'technical_refund',
    };
  }

  if (outcome === 'playerA') {
    return {
      playerARefund: 0,
      playerBRefund: 0,
      playerAPayout: pool,
      playerBPayout: 0,
      burnedGold: 0,
      reason: 'playerA_win',
    };
  }

  if (outcome === 'playerB') {
    return {
      playerARefund: 0,
      playerBRefund: 0,
      playerAPayout: 0,
      playerBPayout: pool,
      burnedGold: 0,
      reason: 'playerB_win',
    };
  }

  if (!tieIsFailure) {
    return {
      playerARefund: wagerGold,
      playerBRefund: wagerGold,
      playerAPayout: 0,
      playerBPayout: 0,
      burnedGold: 0,
      reason: 'draw_refund',
    };
  }

  const refund = Math.floor(wagerGold / 2);
  return {
    playerARefund: refund,
    playerBRefund: refund,
    playerAPayout: 0,
    playerBPayout: 0,
    burnedGold: pool - refund * 2,
    reason: 'double_fail',
  };
}
