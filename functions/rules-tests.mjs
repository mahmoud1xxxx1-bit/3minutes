import assert from 'node:assert/strict';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc } from 'firebase/firestore';

const projectId = 'demo-3minutes';
const testEnv = await initializeTestEnvironment({ projectId });

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

  let blocked = false;
  try {
    await getDoc(doc(bobDb, 'inventories', 'alice'));
  } catch {
    blocked = true;
  }
  assert.equal(blocked, true, 'Another player must not read someone else inventory.');

  console.log('Firestore rules smoke tests passed.');
} finally {
  await testEnv.cleanup();
}
