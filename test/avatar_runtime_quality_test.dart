import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/art/approved_identity_art_manifest.dart';
import 'package:game/features/economy/presentation/avatar_artwork.dart';

void main() {
  test('avatar preload gate completes safely before approved bytes are enabled',
      () async {
    expect(ApprovedIdentityArtManifest.productionSourcesAvailable, isFalse);
    await expectLater(AvatarArtwork.preloadAll(), completes);
  });

  test('runtime support matches all 45 approved avatar identities exactly', () {
    expect(ApprovedIdentityArtManifest.avatarIds, hasLength(45));
    for (final id in ApprovedIdentityArtManifest.avatarIds) {
      expect(AvatarArtwork.supports(id), isTrue, reason: id);
    }
    expect(AvatarArtwork.supports('avatar_unknown'), isFalse);
  });

  testWidgets('representative avatar tiers render large without exceptions',
      (tester) async {
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
      MaterialApp(
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
