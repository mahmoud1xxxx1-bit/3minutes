import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/rank_tier.dart';

class RankEmblem extends StatelessWidget {
  const RankEmblem({
    super.key,
    required this.tier,
    this.size = 44,
  });

  final RankTier tier;
  final double size;

  String get _assetPath => switch (tier) {
        RankTier.bronze => 'assets/ranks/bronze.svg',
        RankTier.silver => 'assets/ranks/silver.svg',
        RankTier.gold => 'assets/ranks/gold.svg',
        RankTier.platinum => 'assets/ranks/platinum.svg',
        RankTier.diamond => 'assets/ranks/diamond.svg',
        RankTier.master => 'assets/ranks/master.svg',
        RankTier.grandmaster => 'assets/ranks/grandmaster.svg',
        RankTier.legend => 'assets/ranks/legendary.svg',
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: SvgPicture.asset(
        _assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        semanticsLabel: tier.label,
      ),
    );
  }
}
