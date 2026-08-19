import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/economy/presentation/avatar_artwork.dart';

void main() {
  test('avatar preload compatibility hook completes without asset decoding', () async {
    await expectLater(AvatarArtwork.preloadAll(), completes);
  });

  testWidgets('representative avatar tiers render large without exceptions', (tester) async {
    const ids = <String>[
      'avatar_free_vanguard',
      'avatar_coin_01',
      'avatar_coin_20',
      'avatar_premium_01',
      'avatar_premium_10',
      'avatar_star_01',
      'avatar_star_05',
      'avatar_exclusive_01',
      'avatar_exclusive_05',
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final id in ids)
                  AvatarArtwork(
                    avatarId: id,
                    size: 220,
                    borderRadius: 110,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AvatarArtwork), findsNWidgets(ids.length));
    expect(tester.takeException(), isNull);
  });
}
