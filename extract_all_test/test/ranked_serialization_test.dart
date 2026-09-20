import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/mini_game_evidence.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/domain/ranked_settlement.dart';
import 'package:game/features/competition/domain/ranked_settlement_request.dart';

void main() {
  test('ranked settlement request round-trips evidence', () {
    const request = RankedSettlementRequest(
      matchId: 'match-1',
      evidence: [
        MiniGameEvidence(
          gameId: 'quick_math',
          gameIndex: 0,
          gameSeed: 123,
          score: 100,
          accuracy: 0.9,
          mistakes: 1,
          durationMs: 5000,
        ),
      ],
    );

    final decoded = RankedSettlementRequest.fromMap(request.toMap());
    expect(decoded.matchId, 'match-1');
    expect(decoded.evidence.single.gameId, 'quick_math');
    expect(decoded.evidence.single.gameSeed, 123);
    expect(decoded.evidence.single.accuracy, 0.9);
  });

  test('authoritative settlement round-trips tiers and timestamp', () {
    final settlement = RankedMatchSettlement(
      matchId: 'match-2',
      seasonId: 'season-7',
      playerA: const RankedPlayerSettlement(
        uid: 'a',
        previousRp: 980,
        nextRp: 1005,
        rpDelta: 25,
        previousTier: RankTier.silver,
        nextTier: RankTier.gold,
        xpAwarded: 50,
        coinsAwarded: 20,
      ),
      playerB: const RankedPlayerSettlement(
        uid: 'b',
        previousRp: 1100,
        nextRp: 1085,
        rpDelta: -15,
        previousTier: RankTier.gold,
        nextTier: RankTier.gold,
        xpAwarded: 20,
        coinsAwarded: 8,
      ),
      settledAt: DateTime.utc(2026, 8, 18, 9),
    );

    final decoded = RankedMatchSettlement.fromMap(settlement.toMap());
    expect(decoded.matchId, settlement.matchId);
    expect(decoded.seasonId, settlement.seasonId);
    expect(decoded.playerA.previousTier, RankTier.silver);
    expect(decoded.playerA.nextTier, RankTier.gold);
    expect(decoded.playerB.rpDelta, -15);
    expect(decoded.settledAt, settlement.settledAt);
  });
}
