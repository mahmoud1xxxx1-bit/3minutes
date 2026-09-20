import 'package:flutter/material.dart';

import '../domain/rank_tier.dart';
import 'rank_art/rank_atlas_data.dart';

/// Renders the approved premium rank artwork from a single transparent atlas.
///
/// Atlas order is intentionally identical to [RankTier.values]:
/// Bronze, Silver, Gold, Platinum, Diamond, Master, Grand Master, Legendary.
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
    final index = tier.index;
    final column = index % RankAtlasData.columns;
    final row = index ~/ RankAtlasData.columns;
    final atlasWidth = size * RankAtlasData.columns;
    final atlasHeight = size * RankAtlasData.rows;

    return Semantics(
      image: true,
      label: tier.label,
      child: SizedBox.square(
        dimension: size,
        child: ClipRect(
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
        ),
      ),
    );
  }
}
