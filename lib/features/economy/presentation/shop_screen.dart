import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/cosmetic_catalog.dart';
import '../data/economy_backend.dart';
import '../domain/cosmetic_item.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({
    super.key,
    required this.uid,
    required this.economyBackend,
  });

  final String uid;
  final EconomyBackend economyBackend;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String? _busyItemId;
  String? _message;

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

  bool _isEquipped(PlayerInventory inventory, CosmeticItem item) {
    return switch (item.slot) {
      CosmeticSlot.avatarFrame => inventory.equippedAvatarFrameId == item.id,
      CosmeticSlot.badge => inventory.equippedBadgeId == item.id,
      CosmeticSlot.profileBackground =>
        inventory.equippedProfileBackgroundId == item.id,
      CosmeticSlot.nameStyle => inventory.equippedNameStyleId == item.id,
    };
  }

  Future<void> _purchase(CosmeticItem item) async {
    if (_busyItemId != null || !AppConfig.economyPurchasesEnabled) return;
    setState(() {
      _busyItemId = item.id;
      _message = null;
    });
    try {
      final receipt = await widget.economyBackend.purchaseCosmetic(
        uid: widget.uid,
        cosmeticId: item.id,
      );
      if (!mounted) return;
      setState(() {
        _message =
            '${item.name} purchased • ${receipt.remainingCoins} coins remaining';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Purchase failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  Future<void> _equip(CosmeticItem item) async {
    if (_busyItemId != null || !AppConfig.economyPurchasesEnabled) return;
    setState(() {
      _busyItemId = item.id;
      _message = null;
    });
    try {
      await widget.economyBackend.equipCosmetic(
        uid: widget.uid,
        cosmeticId: item.id,
      );
      if (!mounted) return;
      setState(() => _message = '${item.name} equipped');
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Could not equip this cosmetic.');
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchasesEnabled = AppConfig.economyPurchasesEnabled;

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: SafeArea(
        child: purchasesEnabled
            ? StreamBuilder<PlayerInventory?>(
                stream: widget.economyBackend.watchInventory(widget.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(GameSpacing.lg),
                        child: Text('Could not load your inventory.'),
                      ),
                    );
                  }
                  final inventory = snapshot.data ??
                      const PlayerInventory(
                        coins: 0,
                        ownedCosmeticIds: <String>{},
                      );
                  return _buildContent(
                    context,
                    purchasesEnabled: true,
                    inventory: inventory,
                  );
                },
              )
            : _buildContent(
                context,
                purchasesEnabled: false,
                inventory: null,
              ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool purchasesEnabled,
    required PlayerInventory? inventory,
  }) {
    return ListView(
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
                      if (inventory != null) ...[
                        const SizedBox(height: GameSpacing.sm),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on_outlined, size: 18),
                            const SizedBox(width: GameSpacing.xs),
                            Text(
                              '${inventory.coins} coins',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: GameSpacing.sm),
          Text(
            _message!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameColors.muted),
          ),
        ],
        const SizedBox(height: GameSpacing.lg),
        Text(
          'Catalog',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: GameSpacing.sm),
        for (final item in CosmeticCatalog.items) ...[
          _CosmeticCard(
            item: item,
            slotLabel: _slotLabel(item.slot),
            icon: _iconFor(item.slot),
            purchasesEnabled: purchasesEnabled,
            owned: inventory?.ownedCosmeticIds.contains(item.id) ?? false,
            equipped: inventory == null ? false : _isEquipped(inventory, item),
            busy: _busyItemId == item.id,
            onPurchase: () => _purchase(item),
            onEquip: () => _equip(item),
          ),
          const SizedBox(height: GameSpacing.sm),
        ],
      ],
    );
  }
}

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({
    required this.item,
    required this.slotLabel,
    required this.icon,
    required this.purchasesEnabled,
    required this.owned,
    required this.equipped,
    required this.busy,
    required this.onPurchase,
    required this.onEquip,
  });

  final CosmeticItem item;
  final String slotLabel;
  final IconData icon;
  final bool purchasesEnabled;
  final bool owned;
  final bool equipped;
  final bool busy;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(GameSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: GameColors.surfaceRaised,
              child: Icon(icon),
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
                    slotLabel,
                    style: const TextStyle(color: GameColors.muted),
                  ),
                  const SizedBox(height: GameSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_outlined, size: 17),
                      const SizedBox(width: GameSpacing.xs),
                      Text('${item.coinPrice}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: GameSpacing.sm),
            if (!purchasesEnabled)
              const Text(
                'LOCKED',
                style: TextStyle(
                  color: GameColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              )
            else if (equipped)
              const Text(
                'EQUIPPED',
                style: TextStyle(
                  color: GameColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              OutlinedButton(
                onPressed: busy ? null : (owned ? onEquip : onPurchase),
                child: busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(owned ? 'EQUIP' : 'BUY'),
              ),
          ],
        ),
      ),
    );
  }
}
