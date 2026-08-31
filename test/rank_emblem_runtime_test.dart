import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/art/approved_identity_art_manifest.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/competition/presentation/rank_emblem.dart';

void main() {
  testWidgets('all 8 competitive rank emblems render through safe runtime path',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (final tier in RankTier.values)
                RankEmblem(tier: tier, size: 72),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(RankEmblem), findsNWidgets(8));
    expect(tester.takeException(), isNull);
  });

  test('production rank masters remain gated until approved bytes exist', () {
    expect(ApprovedIdentityArtManifest.productionSourcesAvailable, isFalse);
    expect(ApprovedIdentityArtManifest.rankMasterPaths, hasLength(8));
    for (final tier in RankTier.values) {
      expect(
        ApprovedIdentityArtManifest.rankMasterPath(tier),
        endsWith('.webp'),
      );
    }
  });
}
