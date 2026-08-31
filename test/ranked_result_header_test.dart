import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/domain/cosmetic_loadout.dart';
import 'package:game/features/economy/presentation/cosmetic_runtime.dart';
import 'package:game/features/match/presentation/ranked_result_header.dart';

Widget _host(RankedResultHeader header) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: header),
      ),
    );

void main() {
  testWidgets('tie uses the neutral result header without loading a player',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      _host(
        RankedResultHeader(
          winnerUid: null,
          winnerName: null,
          winnerAvatarId: null,
          title: 'TIE',
          resultColor: Colors.amber,
          resultIcon: Icons.balance_rounded,
          loadoutLoader: (uid) async {
            calls++;
            return const CosmeticLoadout();
          },
        ),
      ),
    );

    expect(find.text('TIE'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('winner falls back to the match avatar immediately',
      (tester) async {
    final pending = Future<CosmeticLoadout>.delayed(
      const Duration(days: 1),
      () => const CosmeticLoadout(),
    );

    await tester.pumpWidget(
      _host(
        RankedResultHeader(
          winnerUid: 'winner-1',
          winnerName: 'Winner',
          winnerAvatarId: 'avatar_free_vanguard',
          title: 'VICTORY',
          resultColor: Colors.green,
          resultIcon: Icons.emoji_events_rounded,
          loadoutLoader: (_) => pending,
        ),
      ),
    );

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, 'avatar_free_vanguard');
    expect(find.byKey(const ValueKey('ranked-result-winner-winner-1')), findsOneWidget);
  });

  testWidgets('equipped loadout overrides winner presentation', (tester) async {
    await tester.pumpWidget(
      _host(
        RankedResultHeader(
          winnerUid: 'winner-2',
          winnerName: 'Champion',
          winnerAvatarId: 'avatar_free_vanguard',
          title: 'VICTORY',
          resultColor: Colors.green,
          resultIcon: Icons.emoji_events_rounded,
          loadoutLoader: (_) async => const CosmeticLoadout(
            avatarId: 'avatar_free_arc',
            avatarFrameId: 'frame_classic',
            badgeId: 'badge_crown',
            nameStyleId: 'name_bold',
            profileBackgroundId: 'background_grid',
          ),
        ),
      ),
    );
    await tester.pump();

    final avatar = tester.widget<CosmeticAvatarView>(
      find.byType(CosmeticAvatarView),
    );
    expect(avatar.avatarId, 'avatar_free_arc');
    expect(avatar.frameId, 'frame_classic');
    expect(find.byType(CosmeticBadgeView), findsOneWidget);
    expect(find.text('Champion'), findsOneWidget);
  });
}
