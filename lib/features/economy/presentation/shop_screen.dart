import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/cosmetic_catalog.dart';
import '../domain/cosmetic_item.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  IconData _iconFor(CosmeticSlot slot) => switch (slot) {
        CosmeticSlot.avatarFrame => Icons.crop_square_rounded,
        CosmeticSlot.badge => Icons.workspace_premium_outlined,
        CosmeticSlot.profileBackground => Icons.wallpaper_outlined,
        CosmeticSlot.nameStyle => Icons.text_fields,
      };

  String _slotLabel(CosmeticSlot slot) => switch (slot) {
        CosmeticSlot.avatarFrame => 'Avatar frame',
        CosmeticSlot.badge => 'Badge',
        CosmeticSlot.profileBackground => 'Profile background',
        CosmeticSlot.nameStyle => 'Name style',
      };

  @override
  Widget build(BuildContext context) {
    final purchasesEnabled = AppConfig.economyPurchasesEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GameSpacing.md),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(GameSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: GameColors.surfaceRaised,
                      child: Icon(
                        purchasesEnabled
                            ? Icons.verified_user_outlined
                            : Icons.lock_outline,
                      ),
                    ),
                    const SizedBox(width: GameSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure cosmetics shop',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: GameSpacing.xs),
                          Text(
                            purchasesEnabled
                                ? 'Cosmetic purchases are protected by the secure server economy.'
                                : 'Cosmetics only. Purchases activate after the secure server economy is enabled.',
                            style: const TextStyle(color: GameColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: GameSpacing.lg),
            Text(
              'Catalog',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: GameSpacing.sm),
            for (final item in CosmeticCatalog.items) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GameSpacing.md,
                    vertical: GameSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: GameColors.surfaceRaised,
                        child: Icon(_iconFor(item.slot)),
                      ),
                      const SizedBox(width: GameSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _slotLabel(item.slot),
                              style: const TextStyle(color: GameColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on_outlined, size: 18),
                              const SizedBox(width: GameSpacing.xs),
                              Text(
                                '${item.coinPrice}',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            purchasesEnabled ? 'AVAILABLE' : 'LOCKED',
                            style: TextStyle(
                              color: purchasesEnabled
                                  ? GameColors.success
                                  : GameColors.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GameSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
