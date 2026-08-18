import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cosmetics only. Purchases activate after the secure server economy is enabled.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (final item in CosmeticCatalog.items) ...[
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(_iconFor(item.slot))),
                  title: Text(item.name),
                  subtitle: Text(_slotLabel(item.slot)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_outlined, size: 18),
                          const SizedBox(width: 4),
                          Text('${item.coinPrice}'),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'LOCKED',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
