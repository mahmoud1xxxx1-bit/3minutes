import assert from 'node:assert/strict';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  serverTimestamp,
  setDoc,
  updateDoc,
} from 'firebase/firestore';

const projectId = 'demo-3minutes';
const testEnv = await initializeTestEnvironment({ projectId });

const emptyProgress = () => ({
  completedGames: 0,
  totalScore: 0,
  accuracyTotal: 0,
  mistakes: 0,
  elapsedMs: 0,
  completedAt: null,
});

try {
  const aliceDb = testEnv.authenticatedContext('alice').firestore();
  const bobDb = testEnv.authenticatedContext('bob').firestore();
  const charlieDb = testEnv.authenticatedContext('charlie').firestore();
  const anonymousDb = testEnv.unauthenticatedContext().firestore();

  const partyRef = doc(aliceDb, 'parties', 'party-smoke');
  await setDoc(partyRef, {
    leaderUid: 'alice',
    memberUids: ['alice'],
    pendingInviteUids: [],
    activeRoomId: null,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  const party = await getDoc(partyRef);
  assert.equal(party.exists(), true, 'Party creator must be able to create/read own party.');

  const ownInventory = await getDoc(doc(aliceDb, 'inventories', 'alice'));
  assert.equal(ownInventory.exists(), false, 'Missing own inventory should be readable as empty state.');
  await assertFails(getDoc(doc(bobDb, 'inventories', 'alice')));

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(doc(adminDb, 'users', 'alice'), {
      gameName: 'Alice',
      avatarId: 'avatar_free_vanguard',
      level: 1,
      xp: 0,
      rankPoints: 0,
      stars: 0,
      wins: 0,
      losses: 0,
      gamesPlayed: 0,
      cosmeticLoadout: {},
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
    await setDoc(doc(adminDb, 'seasonHistory', 'alice', 'seasons', 'season_1'), {
      seasonId: 'season_1',
      seasonNumber: 1,
      peakTier: 'gold',
      finalRankPoints: 1350,
      finalStanding: 18,
      wins: 4,
      losses: 3,
      ties: 1,
      matches: 8,
      starsAwarded: 4,
      closedAt: serverTimestamp(),
    });
    await setDoc(doc(adminDb, 'socialMatches', 'social-security'), {
      mode: 'privateRoom',
      hostUid: 'alice',
      maxPlayers: 2,
      seed: 12345,
      registryVersion: 3,
      gameCount: 8,
      roomCode: 'ABCDE',
      participantOrder: ['alice', 'bob'],
      participants: {
        alice: {
          displayName: 'Alice',
          avatarId: 'avatar_free_vanguard',
          isReady: true,
          connectionState: 'connected',
          progress: emptyProgress(),
          finishedAt: null,
          latestEmoteId: null,
          latestEmoteAt: null,
        },
        bob: {
          displayName: 'Bob',
          avatarId: 'avatar_free_arena',
          isReady: true,
          connectionState: 'connected',
          progress: emptyProgress(),
          finishedAt: null,
          latestEmoteId: null,
          latestEmoteAt: null,
        },
      },
      countdownStartedAt: serverTimestamp(),
      createdAt: serverTimestamp(),
    });
    await setDoc(doc(adminDb, 'quickMatchmaking', 'alice'), {
      uid: 'alice',
      status: 'waiting',
      matchId: null,
      authorityVersion: 1,
    });
    await setDoc(doc(adminDb, 'quickSettlements', 'quick-match-1'), {
      matchId: 'quick-match-1',
      mode: 'quick',
    });
    await setDoc(doc(adminDb, 'quickEvidence', 'quick-match-1', 'players', 'alice'), {
      uid: 'alice',
      evidence: [],
    });
    await setDoc(doc(adminDb, 'quickPairUsage', '2026-08-19_alice_bob'), {
      participantUids: ['alice', 'bob'],
      matches: 1,
    });

    await setDoc(doc(adminDb, 'competitiveWallets', 'alice'), {
      uid: 'alice',
      gold: 2500,
      heldGold: 500,
      updatedAt: serverTimestamp(),
    });
    await setDoc(doc(adminDb, 'competitiveWallets', 'alice', 'dailyGoldMail', '2026-08-28'), {
      dayKey: '2026-08-28',
      amount: 1000,
      claimed: false,
      createdAt: serverTimestamp(),
    });
    await setDoc(doc(adminDb, 'competitiveWallets', 'alice', 'goldTransactions', 'tx1'), {
      currency: 'gold',
      amount: 1000,
      kind: 'dailyGold',
      createdAt: serverTimestamp(),
    });
    await setDoc(doc(adminDb, 'competitiveQueue', 'alice'), {
      uid: 'alice',
      wager: 500,
      status: 'matched',
      matchId: 'competitive-1',
    });
    await setDoc(doc(adminDb, 'competitiveMatches', 'competitive-1'), {
      playerAId: 'alice',
      playerAName: 'Alice',
      playerBId: 'bob',
      playerBName: 'Bob',
      wager: 500,
      pot: 1000,
      status: 'waitingReady',
      readyA: false,
      readyB: false,
    });
    await setDoc(doc(adminDb, 'competitiveLeaderboards', 'gold', 'entries', 'alice'), {
      uid: 'alice',
      displayName: 'Alice',
      avatarId: 'avatar_free_vanguard',
      value: 2500,
      updatedAt: serverTimestamp(),
    });
    await setDoc(doc(adminDb, 'competitiveSettlements', 'competitive-1'), {
      matchId: 'competitive-1',
      payload: {},
    });
  });

  await assertSucceeds(getDoc(doc(aliceDb, 'seasonHistory', 'alice', 'seasons', 'season_1')));
  await assertFails(getDoc(doc(bobDb, 'seasonHistory', 'alice', 'seasons', 'season_1')));
  await assertFails(
    setDoc(doc(aliceDb, 'seasonHistory', 'alice', 'seasons', 'forged'), {
      seasonId: 'forged',
      seasonNumber: 999,
      peakTier: 'legend',
      starsAwarded: 999,
    }),
  );

  await assertFails(getDoc(doc(aliceDb, 'quickMatchmaking', 'alice')));
  await assertFails(getDoc(doc(aliceDb, 'quickSettlements', 'quick-match-1')));
  await assertFails(getDoc(doc(aliceDb, 'quickEvidence', 'quick-match-1', 'players', 'alice')));
  await assertFails(getDoc(doc(aliceDb, 'quickPairUsage', '2026-08-19_alice_bob')));
  await assertFails(
    setDoc(doc(aliceDb, 'quickMatchmaking', 'forged'), {
      uid: 'alice',
      status: 'matched',
      matchId: 'forged',
    }),
  );

  // Competitive GOLD privacy and server authority.
  await assertSucceeds(getDoc(doc(aliceDb, 'competitiveWallets', 'alice')));
  await assertFails(getDoc(doc(bobDb, 'competitiveWallets', 'alice')));
  await assertSucceeds(
    getDoc(doc(aliceDb, 'competitiveWallets', 'alice', 'dailyGoldMail', '2026-08-28')),
  );
  await assertSucceeds(
    getDoc(doc(aliceDb, 'competitiveWallets', 'alice', 'goldTransactions', 'tx1')),
  );
  await assertFails(updateDoc(doc(aliceDb, 'competitiveWallets', 'alice'), { gold: 999999 }));
  await assertFails(
    setDoc(doc(aliceDb, 'competitiveWallets', 'alice', 'dailyGoldMail', 'forged'), {
      amount: 999999,
      claimed: true,
    }),
  );

  // Queue state is private to its owner and cannot be forged by clients.
  await assertSucceeds(getDoc(doc(aliceDb, 'competitiveQueue', 'alice')));
  await assertFails(getDoc(doc(bobDb, 'competitiveQueue', 'alice')));
  await assertFails(updateDoc(doc(aliceDb, 'competitiveQueue', 'alice'), { wager: 1000 }));

  // Match documents are participant-readable but fully server-writable.
  await assertSucceeds(getDoc(doc(aliceDb, 'competitiveMatches', 'competitive-1')));
  await assertSucceeds(getDoc(doc(bobDb, 'competitiveMatches', 'competitive-1')));
  await assertFails(getDoc(doc(charlieDb, 'competitiveMatches', 'competitive-1')));
  await assertFails(updateDoc(doc(aliceDb, 'competitiveMatches', 'competitive-1'), { readyA: true }));

  // Ranking read models are available only to authenticated users.
  await assertSucceeds(
    getDoc(doc(aliceDb, 'competitiveLeaderboards', 'gold', 'entries', 'alice')),
  );
  await assertFails(
    getDoc(doc(anonymousDb, 'competitiveLeaderboards', 'gold', 'entries', 'alice')),
  );
  await assertFails(
    updateDoc(doc(aliceDb, 'competitiveLeaderboards', 'gold', 'entries', 'alice'), { value: 999999 }),
  );
  await assertFails(getDoc(doc(aliceDb, 'competitiveSettlements', 'competitive-1')));

  const socialRef = doc(aliceDb, 'socialMatches', 'social-security');
  await assertSucceeds(
    updateDoc(socialRef, {
      'participants.alice.connectionState': 'reconnecting',
    }),
  );
  await assertFails(
    updateDoc(socialRef, {
      'participants.alice.displayName': 'FORGED OWNER',
    }),
  );
  await assertFails(
    updateDoc(socialRef, {
      'participants.alice.latestEmoteId': 'emote_gg',
      'participants.alice.latestEmoteAt': serverTimestamp(),
    }),
  );

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await updateDoc(doc(adminDb, 'users', 'alice'), {
      'cosmeticLoadout.equippedEmoteId': 'emote_gg',
    });
  });

  await assertSucceeds(
    updateDoc(socialRef, {
      'participants.alice.latestEmoteId': 'emote_gg',
      'participants.alice.latestEmoteAt': serverTimestamp(),
    }),
  );
  await assertFails(
    updateDoc(socialRef, {
      'participants.alice.latestEmoteId': 'emote_gg',
      'participants.alice.latestEmoteAt': serverTimestamp(),
    }),
  );

  console.log('Firestore rules, competitive GOLD authority, matchmaking privacy, season history privacy, and cosmetic security tests passed.');
} finally {
  await testEnv.cleanup();
}
