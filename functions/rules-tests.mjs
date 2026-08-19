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

  await assertFails(
    getDoc(doc(bobDb, 'inventories', 'alice')),
  );

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
  });

  await assertSucceeds(
    getDoc(doc(aliceDb, 'seasonHistory', 'alice', 'seasons', 'season_1')),
  );
  await assertFails(
    getDoc(doc(bobDb, 'seasonHistory', 'alice', 'seasons', 'season_1')),
  );
  await assertFails(
    setDoc(doc(aliceDb, 'seasonHistory', 'alice', 'seasons', 'forged'), {
      seasonId: 'forged',
      seasonNumber: 999,
      peakTier: 'legend',
      starsAwarded: 999,
    }),
  );

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

  console.log('Firestore rules, season history privacy, and cosmetic security tests passed.');
} finally {
  await testEnv.cleanup();
}
