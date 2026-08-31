import 'package:flutter_test/flutter_test.dart';
import 'package:game/core/art/approved_identity_art_manifest.dart';
import 'package:game/features/competition/domain/rank_tier.dart';
import 'package:game/features/economy/data/cosmetic_catalog.dart';

void main() {
  test('approved avatar manifest contains exactly 45 unique identities', () {
    expect(ApprovedIdentityArtManifest.avatarIds, hasLength(45));
    expect(ApprovedIdentityArtManifest.avatarIds.toSet(), hasLength(45));
    expect(ApprovedIdentityArtManifest.avatarMasterPaths, hasLength(45));

    for (final id in ApprovedIdentityArtManifest.avatarIds) {
      expect(
        ApprovedIdentityArtManifest.avatarMasterPath(id),
        'assets/avatars/approved_1024/$id.webp',
      );
    }
  });

  test('approved avatar artwork stays exactly aligned with the economy catalog', () {
    final catalogIds = CosmeticCatalog.avatars.map((item) => item.id).toSet();
    final approvedIds = ApprovedIdentityArtManifest.avatarIds.toSet();

    expect(CosmeticCatalog.avatars, hasLength(45));
    expect(catalogIds, approvedIds);
  });

  test('approved rank manifest maps every one of the 8 competitive tiers', () {
    expect(RankTier.values, hasLength(8));
    expect(ApprovedIdentityArtManifest.rankMasterPaths, hasLength(8));
    expect(
      ApprovedIdentityArtManifest.rankMasterPaths.keys.toSet(),
      RankTier.values.toSet(),
    );
    expect(
      ApprovedIdentityArtManifest.rankMasterPaths.values.toSet(),
      hasLength(8),
    );
  });

  test('incomplete and legacy atlases can never be production masters', () {
    expect(ApprovedIdentityArtManifest.productionSourcesAvailable, isFalse);
    expect(
      ApprovedIdentityArtManifest.prohibitedProductionSources,
      contains('assets/avatars/approved_hd_00.b64'),
    );
    for (final path in ApprovedIdentityArtManifest.avatarMasterPaths.values) {
      expect(
        ApprovedIdentityArtManifest.prohibitedProductionSources.contains(path),
        isFalse,
      );
      expect(path, endsWith('.webp'));
    }
    for (final path in ApprovedIdentityArtManifest.rankMasterPaths.values) {
      expect(path, endsWith('.webp'));
    }
  });
}
