import assert from 'node:assert/strict';
import test from 'node:test';

import { parseGoldWager, settleGoldEscrow } from './wager.js';

test('only exact integer 100 250 and 500 gold wagers are accepted', () => {
  assert.equal(parseGoldWager(100), 100);
  assert.equal(parseGoldWager(250), 250);
  assert.equal(parseGoldWager(500), 500);
  assert.throws(() => parseGoldWager(50));
  assert.throws(() => parseGoldWager(1000));
  assert.throws(() => parseGoldWager(100.5));
  assert.throws(() => parseGoldWager('100'));
  assert.throws(() => parseGoldWager(Number.NaN));
});

test('winner receives the entire two-player wager pool', () => {
  assert.deepEqual(settleGoldEscrow({ wagerGold: 250, outcome: 'playerA' }), {
    playerARefund: 0,
    playerBRefund: 0,
    playerAPayout: 500,
    playerBPayout: 0,
    burnedGold: 0,
    reason: 'playerA_win',
  });
});

test('double fail refunds only half of each player wager', () => {
  assert.deepEqual(settleGoldEscrow({ wagerGold: 500, outcome: 'tie' }), {
    playerARefund: 250,
    playerBRefund: 250,
    playerAPayout: 0,
    playerBPayout: 0,
    burnedGold: 500,
    reason: 'double_fail',
  });
});

test('exact successful draw refunds both wagers without punishment', () => {
  assert.deepEqual(
    settleGoldEscrow({ wagerGold: 250, outcome: 'tie', tieIsFailure: false }),
    {
      playerARefund: 250,
      playerBRefund: 250,
      playerAPayout: 0,
      playerBPayout: 0,
      burnedGold: 0,
      reason: 'draw_refund',
    },
  );
});

test('technical cancellation refunds both wagers in full', () => {
  assert.deepEqual(
    settleGoldEscrow({ wagerGold: 100, outcome: 'tie', technicalCancel: true }),
    {
      playerARefund: 100,
      playerBRefund: 100,
      playerAPayout: 0,
      playerBPayout: 0,
      burnedGold: 0,
      reason: 'technical_refund',
    },
  );
});
