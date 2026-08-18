import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/cosmetic_catalog.dart';
import '../data/economy_backend.dart';
import '../domain/cosmetic_item.dart';
import 'cosmetic_preview.dart';
import 'shop_copy.dart';

enum _ShopSection { featured, coins, prestige, premium, owned }

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
  _ShopSection _section = _ShopSection.featured;

  bool _isEquipped(PlayerInventory inventory, CosmeticItem item) {
    return switch (item.slot) {
      CosmeticSlot.avatar => inventory.equippedAvatarId == item.id,
      CosmeticSlot.avatarFrame => inventory.equippedAvatarFrameId == item.id,
      CosmeticSlot.badge => inventory.equippedBadgeId == item.id,
      CosmeticSlot.profileBackground =>
        inventory.equippedProfileBackgroundId == item.id,
      CosmeticSlot.nameStyle => inventory.equippedNameStyleId == item.id,
      CosmeticSlot.matchIntro => inventory.equippedMatchIntroId == item.id,
      CosmeticSlot.victoryEffect => inventory.equippedVictoryEffectId == item.id,
      CosmeticSlot.rankAura => inventory.equippedRankAuraId == item.id,
      CosmeticSlot.emote => inventory.equippedEmoteId == item.id,
      CosmeticSlot.roomTheme => inventory.equippedRoomThemeId == item.id,
    };
  }

  Future<void> _purchase(CosmeticItem item) async {
    if (_busyItemId != null || !AppConfig.economyPurchasesEnabled) return;
    final copy = ShopCopy.of(context);
    setState(() {
      _busyItemId = item.id;
      _message = null;
    });
    try {
      await widget.economyBackend.purchaseCosmetic(
        uid: widget.uid,
        cosmeticId: item.id,
      );
      if (!mounted) return;
      setState(() => _message = '${copy.itemName(item)} ✓');
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
      final copy = ShopCopy.of(context);
      setState(() => _message = '${copy.itemName(item)} ✓');
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
        title: Text(l10n.shop, style: const TextStyle(fontWeight: FontWeight.w900)),
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
                    return Center(child: Text(l10n.couldNotLoadInventory));
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
    final copy = ShopCopy.of(context);
    final items = _itemsForSection(inventory);
    final heroItem = items.isNotEmpty ? items.first : CosmeticCatalog.featured.first;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            GameSpacing.md,
            GameSpacing.sm,
            GameSpacing.md,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WalletHeader(
                  inventory: inventory,
                  purchasesEnabled: purchasesEnabled,
                ),
                const SizedBox(height: GameSpacing.md),
                _SectionTabs(
                  selected: _section,
                  copy: copy,
                  onChanged: (section) => setState(() => _section = section),
                ),
                const SizedBox(height: GameSpacing.md),
                _FeaturedHero(
                  item: heroItem,
                  name: copy.itemName(heroItem),
                  description: copy.itemDescription(heroItem),
                  copy: copy,
                ),
                if (_message != null) ...[
                  const SizedBox(height: GameSpacing.sm),
                  _MessageBanner(message: _message!),
                ],
                const SizedBox(height: GameSpacing.lg),
                _SectionHeading(
                  title: _sectionTitle(copy),
                  subtitle: _sectionSubtitle(copy),
                ),
                const SizedBox(height: GameSpacing.sm),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(GameSpacing.xl),
                child: Text(
                  copy.noOwned,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GameColors.muted),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              GameSpacing.md,
              0,
              GameSpacing.md,
              GameSpacing.xl,
            ),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: GameSpacing.sm),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CosmeticCard(
                  item: item,
                  itemName: copy.itemName(item),
                  description: copy.itemDescription(item),
                  slotLabel: _slotLabel(item.slot),
                  rarityLabel: _rarityLabel(item.rarity),
                  purchasesEnabled: purchasesEnabled,
                  owned: inventory?.ownedCosmeticIds.contains(item.id) ?? false,
                  equipped:
                      inventory == null ? false : _isEquipped(inventory, item),
                  busy: _busyItemId == item.id,
                  onPurchase: () => _purchase(item),
                  onEquip: () => _equip(item),
                );
              },
            ),
          ),
      ],
    );
  }

  List<CosmeticItem> _itemsForSection(PlayerInventory? inventory) {
    return switch (_section) {
      _ShopSection.featured => CosmeticCatalog.featured,
      _ShopSection.coins =>
        CosmeticCatalog.forPriceType(CosmeticPriceType.coins),
      _ShopSection.prestige =>
        CosmeticCatalog.forPriceType(CosmeticPriceType.prestigeStars),
      _ShopSection.premium =>
        CosmeticCatalog.forPriceType(CosmeticPriceType.premium),
      _ShopSection.owned => inventory == null
          ? const <CosmeticItem>[]
          : CosmeticCatalog.items
              .where((item) => inventory.ownedCosmeticIds.contains(item.id))
              .toList(growable: false),
    };
  }

  String _sectionTitle(ShopCopy copy) => switch (_section) {
        _ShopSection.featured => copy.featured,
        _ShopSection.coins => copy.coins,
        _ShopSection.prestige => copy.prestige,
        _ShopSection.premium => copy.premium,
        _ShopSection.owned => copy.owned,
      };

  String _sectionSubtitle(ShopCopy copy) => switch (_section) {
        _ShopSection.featured => copy.featuredSubtitle,
        _ShopSection.coins => copy.coinSubtitle,
        _ShopSection.prestige => copy.prestigeSubtitle,
        _ShopSection.premium => copy.premiumSubtitle,
        _ShopSection.owned => copy.ownedSubtitle,
      };

  String _slotLabel(CosmeticSlot slot) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return switch (slot) {
      CosmeticSlot.avatar => ar ? 'أفاتار' : 'Avatar',
      CosmeticSlot.avatarFrame => ar ? 'إطار' : 'Frame',
      CosmeticSlot.badge => ar ? 'شارة' : 'Badge',
      CosmeticSlot.profileBackground => ar ? 'خلفية' : 'Background',
      CosmeticSlot.nameStyle => ar ? 'نمط الاسم' : 'Name style',
      CosmeticSlot.matchIntro => ar ? 'دخول المباراة' : 'Match intro',
      CosmeticSlot.victoryEffect => ar ? 'تأثير الفوز' : 'Victory effect',
      CosmeticSlot.rankAura => ar ? 'هالة الرتبة' : 'Rank aura',
      CosmeticSlot.emote => ar ? 'إيموت' : 'Emote',
      CosmeticSlot.roomTheme => ar ? 'ثيم الغرفة' : 'Room theme',
    };
  }

  String _rarityLabel(CosmeticRarity rarity) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return switch (rarity) {
      CosmeticRarity.common => ar ? 'عادي' : 'Common',
      CosmeticRarity.rare => ar ? 'نادر' : 'Rare',
      CosmeticRarity.epic => ar ? 'ملحمي' : 'Epic',
      CosmeticRarity.legendary => ar ? 'أسطوري' : 'Legendary',
      CosmeticRarity.mythic => ar ? 'خرافي' : 'Mythic',
    };
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.inventory, required this.purchasesEnabled});

  final PlayerInventory? inventory;
  final bool purchasesEnabled;

  @override
  Widget build(BuildContext context) {
    final copy = ShopCopy.of(context);
    return Container(
      padding: const EdgeInsets.all(GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.panel),
        border: Border.all(color: GameColors.surfaceStrong),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BalancePill(
              icon: Icons.monetization_on_rounded,
              value: '${inventory?.coins ?? 0}',
              label: copy.coins,
              color: GameColors.rewardGold,
            ),
          ),
          const SizedBox(width: GameSpacing.sm),
          Expanded(
            child: _BalancePill(
              icon: Icons.star_rounded,
              value: '${inventory?.prestigeStars ?? 0}',
              label: copy.prestige,
              color: GameColors.rankLegend,
            ),
          ),
          if (!purchasesEnabled) ...[
            const SizedBox(width: GameSpacing.sm),
            const Icon(Icons.lock_rounded, color: GameColors.muted, size: 20),
          ],
        ],
      ),
    );
  }
}

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({
    required this.selected,
    required this.copy,
    required this.onChanged,
  });

  final _ShopSection selected;
  final ShopCopy copy;
  final ValueChanged<_ShopSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = <_ShopSection, String>{
      _ShopSection.featured: copy.featured,
      _ShopSection.coins: copy.coins,
      _ShopSection.prestige: copy.prestige,
      _ShopSection.premium: copy.premium,
      _ShopSection.owned: copy.owned,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final section in _ShopSection.values) ...[
            ChoiceChip(
              selected: selected == section,
              onSelected: (_) => onChanged(section),
              label: Text(labels[section]!),
            ),
            const SizedBox(width: GameSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _FeaturedHero extends StatelessWidget {
  const _FeaturedHero({
    required this.item,
    required this.name,
    required this.description,
    required this.copy,
  });

  final CosmeticItem item;
  final String name;
  final String description;
  final ShopCopy copy;

  Color get rarityColor => switch (item.rarity) {
        CosmeticRarity.common => GameColors.rarityCommon,
        CosmeticRarity.rare => GameColors.rarityRare,
        CosmeticRarity.epic => GameColors.rarityEpic,
        CosmeticRarity.legendary => GameColors.rarityLegendary,
        CosmeticRarity.mythic => GameColors.rarityMythic,
      };

  @override
  Widget build(BuildContext context) {
    final color = rarityColor;
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GameRadii.panel),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            color.withValues(alpha: 0.18),
            GameColors.surface,
            GameColors.background,
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.50)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: 24),
        ],
      ),
      child: Row(
        children: [
          CosmeticPreview(item: item, rarityColor: color, size: 112),
          const SizedBox(width: GameSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: GameSpacing.xs,
                  runSpacing: GameSpacing.xs,
                  children: [
                    _MiniTag(label: copy.exclusive, color: color),
                    if (item.isAnimated)
                      _MiniTag(label: copy.animated, color: GameColors.accent),
                  ],
                ),
                const SizedBox(height: GameSpacing.sm),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: GameSpacing.xs),
                Text(description, style: const TextStyle(color: GameColors.muted)),
                const SizedBox(height: GameSpacing.sm),
                _PriceLine(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: GameColors.muted)),
      ],
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.sm),
      decoration: BoxDecoration(
        color: GameColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(GameRadii.button),
        border: Border.all(color: GameColors.success.withValues(alpha: 0.30)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: GameColors.success, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _BalancePill extends StatelessWidget {
  const _BalancePill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GameSpacing.sm, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: GameSpacing.xs),
          Flexible(
            child: Text(
              '$value ${label.toUpperCase()}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({
    required this.item,
    required this.itemName,
    required this.description,
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
  final String description;
  final String slotLabel;
  final String rarityLabel;
  final bool purchasesEnabled;
  final bool owned;
  final bool equipped;
  final bool busy;
  final VoidCallback onPurchase;
  final VoidCallback onEquip;

  Color get rarityColor => switch (item.rarity) {
        CosmeticRarity.common => GameColors.rarityCommon,
        CosmeticRarity.rare => GameColors.rarityRare,
        CosmeticRarity.epic => GameColors.rarityEpic,
        CosmeticRarity.legendary => GameColors.rarityLegendary,
        CosmeticRarity.mythic => GameColors.rarityMythic,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final copy = ShopCopy.of(context);
    final color = rarityColor;

    return Container(
      padding: const EdgeInsets.all(GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CosmeticPreview(item: item, rarityColor: color, size: 76),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        itemName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    if (item.isAnimated)
                      _MiniTag(label: copy.animated, color: GameColors.accent),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: GameColors.muted, fontSize: 12),
                ),
                const SizedBox(height: GameSpacing.xs),
                Wrap(
                  spacing: GameSpacing.sm,
                  runSpacing: 4,
                  children: [
                    Text(slotLabel, style: const TextStyle(color: GameColors.muted, fontSize: 11)),
                    Text(
                      rarityLabel,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                    _PriceLine(item: item),
                  ],
                ),
                const SizedBox(height: GameSpacing.sm),
                if (!purchasesEnabled)
                  _StatusPill(label: l10n.locked, color: GameColors.muted)
                else if (equipped)
                  _StatusPill(label: l10n.equipped, color: GameColors.success)
                else
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: busy ? null : (owned ? onEquip : onPurchase),
                      child: busy
                          ? const SizedBox.square(
                              dimension: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(owned ? l10n.equip : l10n.buy),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.item});
  final CosmeticItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item.priceType) {
      CosmeticPriceType.coins => _PriceValue(
          icon: Icons.monetization_on_rounded,
          value: '${item.coinPrice}',
          color: GameColors.rewardGold,
        ),
      CosmeticPriceType.prestigeStars => _PriceValue(
          icon: Icons.star_rounded,
          value: '${item.starPrice}',
          color: GameColors.rankLegend,
        ),
      CosmeticPriceType.premium => _PriceValue(
          icon: Icons.workspace_premium_rounded,
          value: '\$${(item.premiumPriceCents / 100).toStringAsFixed(2)}',
          color: GameColors.rarityEpic,
        ),
      CosmeticPriceType.achievement => const _PriceValue(
          icon: Icons.emoji_events_rounded,
          value: 'Achievement',
          color: GameColors.success,
        ),
      CosmeticPriceType.seasonalPlacement => const _PriceValue(
          icon: Icons.leaderboard_rounded,
          value: 'Season',
          color: GameColors.rankLegend,
        ),
    };
  }
}

class _PriceValue extends StatelessWidget {
  const _PriceValue({required this.icon, required this.value, required this.color});
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 3),
        Text(value, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
      ],
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
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
