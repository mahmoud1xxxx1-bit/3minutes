import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/competition/domain/leaderboard_entry.dart';
import 'package:game/features/competition/domain/leaderboard_policy.dart';

void main() {
  LeaderboardEntry entry({
    required String uid,
    required int rp,
    required int wins,
    required int losses,
  }) {
    return LeaderboardEntry(
      uid: uid,
      gameName: uid,
      avatarId: 'default_01',
      rankPoints: rp,
      stars: 0,
      wins: wins,
      losses: losses,
    );
  }

  test('leaderboard uses deterministic tie breakers', () {
    final items = [
      entry(uid: 'c', rp: 1000, wins: 10, losses: 3),
      entry(uid: 'a', rp: 1000, wins: 12, losses: 8),
      entry(uid: 'b', rp: 1000, wins: 12, losses: 2),
      entry(uid: 'z', rp: 1200, wins: 1, losses: 9),
    ];

    final sorted = LeaderboardPolicy.sorted(items);

    expect(sorted.map((item) => item.uid), ['z', 'b', 'a', 'c']);
  });
}
