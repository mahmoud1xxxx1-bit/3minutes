import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/cosmetic_catalog.dart';
import '../data/economy_backend.dart';
import '../domain/cosmetic_item.dart';
import 'cosmetic_preview.dart';

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

  String _slotLabel(AppLocalizations l10n, CosmeticSlot slot) => switch (slot) {
        CosmeticSlot.avatarFrame => l10n.avatarFrame,
        CosmeticSlot.badge => l10n.badge,
        CosmeticSlot.profileBackground => l10n.profileBackground,
        CosmeticSlot.nameStyle => l10n.nameStyle,
      };

  String _itemName(AppLocalizations l10n, CosmeticItem item) => switch (item.id) {
        'frame_classic' => l10n.cosmeticFrameClassic,
        'frame_neon' => l10n.cosmeticFrameNeon,
        'badge_timer' => l10n.cosmeticBadgeTimer,
        'badge_crown' => l10n.cosmeticBadgeCrown,
        'background_grid' => l10n.cosmeticBackgroundGrid,
        'background_arena' => l10n.cosmeticBackgroundArena,
        'name_bold' => l10n.cosmeticNameBold,
        'name_champion' => l10n.cosmeticNameChampion,
        _ => item.name,
      };

  String _rarityLabel(AppLocalizations l10n, CosmeticRarity rarity) =>
      switch (rarity) {
        CosmeticRarity.common => l10n.common,
        CosmeticRarity.rare => l10n.rare,
        CosmeticRarity.epic => l10n.epic,
        CosmeticRarity.legendary => l10n.legendary,
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
      final l10n = AppLocalizations.of(context);
      setState(() {
        _message = l10n.purchaseSuccess(
          _itemName(l10n, item),
          receipt.remainingCoins,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = AppLocalizations.of(context).purchaseFailed);
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
      final l10n = AppLocalizations.of(context);
      setState(() => _message = l10n.equipSuccess(_itemName(l10n, item)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = AppLocalizations.of(context).equipFailed);
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final purchasesEnabled = AppConfig.economyPurchasesEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.shop,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: purchasesEnabled
            ? StreamBuilder<PlayerInventory?>(
                stream: widget.economyBackend.watchInventory(widget.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(GameSpacing.lg),
                        child: Text(l10n.couldNotLoadInventory),
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
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(GameSpacing.md),
      children: [
        Container(
          padding: const EdgeInsets.all(GameSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GameRadii.panel),
            gradient: const LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [GameColors.surfaceRaised, GameColors.surface],
            ),
            border: Border.all(color: GameColors.surfaceStrong),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: purchasesEnabled
                      ? GameColors.success.withValues(alpha: 0.12)
                      : GameColors.accentSoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  purchasesEnabled
                      ? Icons.verified_user_rounded
                      : Icons.lock_rounded,
                  color: purchasesEnabled
                      ? GameColors.success
                      : GameColors.accent,
                ),
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.secureCosmeticsShop,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: GameSpacing.xs),
                    Text(
                      purchasesEnabled
                          ? l10n.shopSecureDescription
                          : l10n.shopLockedDescription,
                      style: const TextStyle(color: GameColors.muted),
                    ),
                    if (inventory != null) ...[
                      const SizedBox(height: GameSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GameSpacing.sm,
                          vertical: GameSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: GameColors.rewardGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(GameRadii.pill),
                          border: Border.all(
                            color: GameColors.rewardGold.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on_rounded,
                              size: 18,
                              color: GameColors.rewardGold,
                            ),
                            const SizedBox(width: GameSpacing.xs),
                            Text(
                              '${inventory.coins} ${l10n.coins}',
                              style: const TextStyle(
                                color: GameColors.rewardGold,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: GameSpacing.sm),
          Container(
            padding: const EdgeInsets.all(GameSpacing.sm),
            decoration: BoxDecoration(
              color: GameColors.surface,
              borderRadius: BorderRadius.circular(GameRadii.button),
              border: Border.all(color: GameColors.surfaceStrong),
            ),
            child: Text(
              _message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.muted),
            ),
          ),
        ],
        const SizedBox(height: GameSpacing.lg),
        Text(
          l10n.catalog,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: GameSpacing.sm),
        for (final item in CosmeticCatalog.items) ...[
          _CosmeticCard(
            item: item,
            itemName: _itemName(l10n, item),
            slotLabel: _slotLabel(l10n, item.slot),
            rarityLabel: _rarityLabel(l10n, item.rarity),
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
    required this.itemName,
    required this.slotLabel,
    required this.rarityLabel,
    required this.purchasesEnabled,
    required this.owned,
    required this.equipped,
    required this.busy,
    required this.onPurchase,
    required this.onEquip,
  });

  final CosmeticItem item;
  final String itemName;
  final String slotLabel;
  final String rarityLabel;
  final bool purchasesEnabled;
  final bool owned;
  final bool equipped;
  final bool busy;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;

  Color get _rarityColor => switch (item.rarity) {
        CosmeticRarity.common => GameColors.rankSilver,
        CosmeticRarity.rare => GameColors.rankDiamond,
        CosmeticRarity.epic => GameColors.rankMaster,
        CosmeticRarity.legendary => GameColors.rewardGold,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rarityColor = _rarityColor;

    return Container(
      padding: const EdgeInsets.all(GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: rarityColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          CosmeticPreview(
            item: item,
            rarityColor: rarityColor,
            size: 58,
          ),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: GameSpacing.sm,
                  runSpacing: 3,
                  children: [
                    Text(
                      slotLabel,
                      style: const TextStyle(color: GameColors.muted),
                    ),
                    Text(
                      rarityLabel,
                      style: TextStyle(
                        color: rarityColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GameSpacing.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 17,
                      color: GameColors.rewardGold,
                    ),
                    const SizedBox(width: GameSpacing.xs),
                    Text(
                      '${item.coinPrice}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          if (!purchasesEnabled)
            _StatusPill(label: l10n.locked, color: GameColors.muted)
          else if (equipped)
            _StatusPill(label: l10n.equipped, color: GameColors.success)
          else
            OutlinedButton(
              onPressed: busy ? null : (owned ? onEquip : onPurchase),
              child: busy
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(owned ? l10n.equip : l10n.buy),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
