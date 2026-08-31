import 'package:flutter/material.dart';

import '../../../core/art/approved_identity_art_manifest.dart';
import '../domain/rank_tier.dart';
import 'rank_art/rank_atlas_data.dart';

/// Renders the competitive rank identity.
///
/// Production prefers the owner-approved 1024x1024 local WebP master declared
/// by [ApprovedIdentityArtManifest]. Until the complete approved source bundle
/// is restored, the existing transparent atlas remains an explicit fallback so
/// current releases never attempt to decode missing production assets.
class RankEmblem extends StatelessWidget {
  const RankEmblem({
    super.key,
    required this.tier,
    this.size = 44,
  });

  final RankTier tier;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: tier.label,
      child: SizedBox.square(
        dimension: size,
        child: ApprovedIdentityArtManifest.productionSourcesAvailable
            ? _approvedMaster()
            : _legacyAtlasFallback(),
      ),
    );
  }

  Widget _approvedMaster() {
    return Image.asset(
      ApprovedIdentityArtManifest.rankMasterPath(tier),
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }

  Widget _legacyAtlasFallback() {
    final index = tier.index;
    final column = index % RankAtlasData.columns;
    final row = index ~/ RankAtlasData.columns;
    final atlasWidth = size * RankAtlasData.columns;
    final atlasHeight = size * RankAtlasData.rows;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: atlasWidth,
        maxWidth: atlasWidth,
        minHeight: atlasHeight,
        maxHeight: atlasHeight,
        child: Transform.translate(
          offset: Offset(-column * size, -row * size),
          child: Image.memory(
            RankAtlasData.bytes,
            width: atlasWidth,
            height: atlasHeight,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
