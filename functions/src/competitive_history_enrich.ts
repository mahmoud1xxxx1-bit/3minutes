import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

const REGION = "me-central2";

export const enrichCompetitiveMatchHistory = onDocumentCreated(
  { region: REGION, document: "competitiveMatchHistory/{uid}/matches/{matchId}" },
  async (event) => {
    const uid = event.params.uid;
    const matchId = event.params.matchId;
    const historySnap = event.data;
    if (!historySnap) return;

    const db = getFirestore();
    const matchSnap = await db.collection("competitiveMatches").doc(matchId).get();
    const match = matchSnap.data();
    if (!match) return;

    const playerAId = String(match.playerAId ?? "");
    const isPlayerA = uid === playerAId;
    const gameResults = Array.isArray(match.gameResults) ? match.gameResults : [];
    const userGames = gameResults.map((raw) => {
      const item = raw && typeof raw === "object" ? raw as Record<string, unknown> : {};
      const scoreA = Number(item.playerAScore ?? 0);
      const scoreB = Number(item.playerBScore ?? 0);
      return {
        gameId: typeof item.gameId === "string" ? item.gameId : "",
        gameIndex: Number(item.gameIndex ?? 0),
        myScore: isPlayerA ? scoreA : scoreB,
        opponentScore: isPlayerA ? scoreB : scoreA,
        result: scoreA === scoreB ? "tie" : (isPlayerA ? scoreA > scoreB : scoreB > scoreA) ? "win" : "loss",
      };
    });

    await historySnap.ref.set({
      myTotalScore: Number(isPlayerA ? match.totalScoreA ?? 0 : match.totalScoreB ?? 0),
      opponentTotalScore: Number(isPlayerA ? match.totalScoreB ?? 0 : match.totalScoreA ?? 0),
      gameResults: userGames,
      detailsUpdatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
  },
);
