import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/cosmetic_catalog.dart';
import '../data/economy_backend.dart';
import '../data/premium_billing_service.dart';
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
  PremiumBillingService? _premiumBilling;
  StreamSubscription<PremiumBillingSnapshot>? _premiumSubscription;
  PremiumBillingSnapshot? _premiumSnapshot;

  bool get _purchasesEnabled => AppConfig.economyPurchasesEnabled;
  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    if (_purchasesEnabled) {
      final billing = PremiumBillingService(uid: widget.uid);
      _premiumBilling = billing;
      _premiumSubscription = billing.snapshots.listen((snapshot) {
        if (!mounted) return;
        setState(() => _premiumSnapshot = snapshot);
        if (snapshot.message == 'premium_purchase_verified') {
          setState(() {
            _message = _isArabic
                ? 'تم تأكيد عملية الشراء وإضافة العنصر إلى حسابك.'
                : 'Purchase verified and added to your account.';
          });
        }
      });
      unawaited(
        billing.initialize(
          CosmeticCatalog.forPriceType(CosmeticPriceType.premium),
        ),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_premiumSubscription?.cancel());
    final billing = _premiumBilling;
    if (billing != null) unawaited(billing.dispose());
    super.dispose();
  }

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

  Future<void> _acquire(CosmeticItem item) async {
    if (_busyItemId != null || !_purchasesEnabled) return;
    setState(() {
      _busyItemId = item.id;
      _message = null;
    });
    try {
      switch (item.priceType) {
        case CosmeticPriceType.coins:
          await widget.economyBackend.purchaseCosmetic(
            uid: widget.uid,
            cosmeticId: item.id,
          );
        case CosmeticPriceType.prestigeStars:
          await widget.economyBackend.unlockPrestigeCosmetic(
            uid: widget.uid,
            cosmeticId: item.id,
          );
        case CosmeticPriceType.premium:
          final billing = _premiumBilling;
          if (billing == null) throw StateError('Premium billing unavailable.');
          await billing.buy(item);
        case CosmeticPriceType.achievement:
        case CosmeticPriceType.seasonalPlacement:
          throw StateError('This cosmetic is earned, not purchased.');
      }
      if (!mounted || item.priceType == CosmeticPriceType.premium) return;
      final copy = ShopCopy.of(context);
      setState(() => _message = '${copy.itemName(item)} ✓');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = _isArabic
            ? 'تعذر إكمال العملية. تحقق من الرصيد أو شروط فتح العنصر وحاول مجددًا.'
            : 'Could not complete this action. Check the balance or unlock requirement and try again.';
      });
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  Future<void> _equip(CosmeticItem item) async {
    if (_busyItemId != null || !_purchasesEnabled) return;
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
      setState(() => _message = _isArabic ? 'تم تجهيز العنصر.' : 'Item equipped.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = AppLocalizations.of(context).equipFailed);
    } finally {
      if (mounted) setState(() => _busyItemId = null);
    }
  }

  Future<void> _restorePremium() async {
    final billing = _premiumBilling;
    if (billing == null) return;
    setState(() => _message = null);
    try {
      await billing.restore();
      if (!mounted) return;
      setState(() {
        _message = _isArabic
            ? 'جارٍ التحقق من مشترياتك السابقة.'
            : 'Checking your previous purchases.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = _isArabic
            ? 'تعذر استعادة المشتريات الآن.'
            : 'Purchases could not be restored right now.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shop, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: StreamBuilder<PlayerInventory?>(
          stream: widget.economyBackend.watchInventory(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(l10n.couldNotLoadInventory));
            }
            final inventory = snapshot.data ??
                const PlayerInventory(coins: 0, ownedCosmeticIds: <String>{});
            return _buildContent(context, inventory);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlayerInventory inventory) {
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
                _WalletHeader(inventory: inventory),
                if (!_purchasesEnabled) ...[
                  const SizedBox(height: GameSpacing.sm),
                  _InfoBanner(
                    text: _isArabic
                        ? 'المتجر جاهز للعرض. عمليات الشراء والتجهيز ستعمل عند تفعيل الخادم الآمن.'
                        : 'The shop is available for preview. Purchases and equipping activate with the secure server.',
                  ),
                ],
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
                  premiumPrice: _premiumSnapshot?.localizedPrice(heroItem.id),
                ),
                if (_section == _ShopSection.premium && _purchasesEnabled) ...[
                  const SizedBox(height: GameSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: _restorePremium,
                      icon: const Icon(Icons.restore_rounded),
                      label: Text(_isArabic ? 'استعادة المشتريات' : 'Restore purchases'),
                    ),
                  ),
                ],
                if (_message != null) ...[
                  const SizedBox(height: GameSpacing.sm),
                  _InfoBanner(text: _message!),
                ],
                const SizedBox(height: GameSpacing.lg),
                Text(
                  _sectionTitle(copy),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  _sectionSubtitle(copy),
                  style: const TextStyle(color: GameColors.muted),
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
                final owned = inventory.ownedCosmeticIds.contains(item.id);
                final canAfford = switch (item.priceType) {
                  CosmeticPriceType.coins => inventory.coins >= item.coinPrice,
                  CosmeticPriceType.prestigeStars =>
                    inventory.prestigeStars >= item.starPrice,
                  CosmeticPriceType.premium =>
                    _premiumSnapshot?.products.containsKey(item.id) == true,
                  CosmeticPriceType.achievement => false,
                  CosmeticPriceType.seasonalPlacement => false,
                };
                return _CosmeticCard(
                  item: item,
                  itemName: copy.itemName(item),
                  description: copy.itemDescription(item),
                  slotLabel: _slotLabel(item.slot),
                  rarityLabel: _rarityLabel(item.rarity),
                  premiumPrice: _premiumSnapshot?.localizedPrice(item.id),
                  purchasesEnabled: _purchasesEnabled,
                  owned: owned,
                  equipped: _isEquipped(inventory, item),
                  canAcquire: canAfford,
                  busy: _busyItemId == item.id ||
                      _premiumSnapshot?.pendingProductId == item.id,
                  onAcquire: () => _acquire(item),
                  onEquip: () => _equip(item),
                );
              },
            ),
          ),
      ],
    );
  }

  List<CosmeticItem> _itemsForSection(PlayerInventory inventory) => switch (_section) {
        _ShopSection.featured => CosmeticCatalog.featured,
        _ShopSection.coins =>
          CosmeticCatalog.forPriceType(CosmeticPriceType.coins),
        _ShopSection.prestige =>
          CosmeticCatalog.forPriceType(CosmeticPriceType.prestigeStars),
        _ShopSection.premium =>
          CosmeticCatalog.forPriceType(CosmeticPriceType.premium),
        _ShopSection.owned => CosmeticCatalog.items
            .where((item) => inventory.ownedCosmeticIds.contains(item.id))
            .toList(growable: false),
      };

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

  String _slotLabel(CosmeticSlot slot) => switch (slot) {
        CosmeticSlot.avatar => _isArabic ? 'أفاتار' : 'Avatar',
        CosmeticSlot.avatarFrame => _isArabic ? 'إطار' : 'Frame',
        CosmeticSlot.badge => _isArabic ? 'شارة' : 'Badge',
        CosmeticSlot.profileBackground => _isArabic ? 'خلفية' : 'Background',
        CosmeticSlot.nameStyle => _isArabic ? 'نمط الاسم' : 'Name style',
        CosmeticSlot.matchIntro => _isArabic ? 'دخول المباراة' : 'Match intro',
        CosmeticSlot.victoryEffect => _isArabic ? 'تأثير الفوز' : 'Victory effect',
        CosmeticSlot.rankAura => _isArabic ? 'هالة الرتبة' : 'Rank aura',
        CosmeticSlot.emote => _isArabic ? 'إيموت' : 'Emote',
        CosmeticSlot.roomTheme => _isArabic ? 'ثيم الغرفة' : 'Room theme',
      };

  String _rarityLabel(CosmeticRarity rarity) => switch (rarity) {
        CosmeticRarity.common => _isArabic ? 'عادي' : 'Common',
        CosmeticRarity.rare => _isArabic ? 'نادر' : 'Rare',
        CosmeticRarity.epic => _isArabic ? 'ملحمي' : 'Epic',
        CosmeticRarity.legendary => _isArabic ? 'أسطوري' : 'Legendary',
        CosmeticRarity.mythic => _isArabic ? 'خرافي' : 'Mythic',
      };
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.inventory});
  final PlayerInventory inventory;

  @override
  Widget build(BuildContext context) {
    final copy = ShopCopy.of(context);
    return Row(
      children: [
        Expanded(
          child: _BalancePill(
            icon: Icons.monetization_on_rounded,
            value: '${inventory.coins}',
            label: copy.coins,
            color: GameColors.rewardGold,
          ),
        ),
        const SizedBox(width: GameSpacing.sm),
        Expanded(
          child: _BalancePill(
            icon: Icons.star_rounded,
            value: '${inventory.prestigeStars}',
            label: copy.prestige,
            color: GameColors.rankLegend,
          ),
        ),
      ],
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
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: color.withValues(alpha: .26)),
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
    this.premiumPrice,
  });
  final CosmeticItem item;
  final String name;
  final String description;
  final ShopCopy copy;
  final String? premiumPrice;

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(item.rarity);
    return Container(
      padding: const EdgeInsets.all(GameSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GameRadii.panel),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: .18), GameColors.surface, GameColors.background],
        ),
        border: Border.all(color: color.withValues(alpha: .5)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: .1), blurRadius: 24)],
      ),
      child: Row(
        children: [
          CosmeticPreview(item: item, rarityColor: color, size: 105),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: GameSpacing.xs,
                  children: [
                    _Tag(label: copy.exclusive, color: color),
                    if (item.isAnimated)
                      _Tag(label: copy.animated, color: GameColors.accent),
                  ],
                ),
                const SizedBox(height: GameSpacing.sm),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: GameColors.muted)),
                const SizedBox(height: GameSpacing.sm),
                _PriceLine(item: item, premiumPrice: premiumPrice),
              ],
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
    required this.canAcquire,
    required this.busy,
    required this.onAcquire,
    required this.onEquip,
    this.premiumPrice,
  });

  final CosmeticItem item;
  final String itemName;
  final String description;
  final String slotLabel;
  final String rarityLabel;
  final String? premiumPrice;
  final bool purchasesEnabled;
  final bool owned;
  final bool equipped;
  final bool canAcquire;
  final bool busy;
  final VoidCallback onAcquire;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _rarityColor(item.rarity);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final earnedOnly = item.priceType == CosmeticPriceType.achievement ||
        item.priceType == CosmeticPriceType.seasonalPlacement;

    String actionLabel() {
      if (owned) return l10n.equip;
      if (earnedOnly) return ar ? 'يُكتسب بالإنجاز' : 'Earn by achievement';
      if (!purchasesEnabled) return l10n.locked;
      if (!canAcquire && item.priceType != CosmeticPriceType.premium) {
        return ar ? 'لم تصل للمتطلب بعد' : 'Requirement not met';
      }
      return switch (item.priceType) {
        CosmeticPriceType.coins => ar ? 'شراء بالكوينز' : 'Buy with Coins',
        CosmeticPriceType.prestigeStars => ar ? 'فتح بالنجوم' : 'Unlock with Stars',
        CosmeticPriceType.premium => ar ? 'شراء' : 'Buy',
        CosmeticPriceType.achievement => '',
        CosmeticPriceType.seasonalPlacement => '',
      };
    }

    return Container(
      padding: const EdgeInsets.all(GameSpacing.md),
      decoration: BoxDecoration(
        color: GameColors.surface,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: color.withValues(alpha: .36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CosmeticPreview(item: item, rarityColor: color, size: 74),
          const SizedBox(width: GameSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: GameColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: GameSpacing.sm,
                  runSpacing: 4,
                  children: [
                    Text(slotLabel, style: const TextStyle(color: GameColors.muted, fontSize: 11)),
                    Text(rarityLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
                    _PriceLine(item: item, premiumPrice: premiumPrice),
                  ],
                ),
                const SizedBox(height: GameSpacing.sm),
                if (equipped)
                  _Status(label: l10n.equipped, color: GameColors.success)
                else
                  SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: busy || earnedOnly || !purchasesEnabled || (!owned && !canAcquire)
                          ? null
                          : (owned ? onEquip : onAcquire),
                      child: busy
                          ? const SizedBox.square(
                              dimension: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(actionLabel()),
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

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.item, this.premiumPrice});
  final CosmeticItem item;
  final String? premiumPrice;

  @override
  Widget build(BuildContext context) {
    return switch (item.priceType) {
      CosmeticPriceType.coins => _Price(
          icon: Icons.monetization_on_rounded,
          value: '${item.coinPrice}',
          color: GameColors.rewardGold,
        ),
      CosmeticPriceType.prestigeStars => _Price(
          icon: Icons.star_rounded,
          value: '${item.starPrice}',
          color: GameColors.rankLegend,
        ),
      CosmeticPriceType.premium => _Price(
          icon: Icons.workspace_premium_rounded,
          value: premiumPrice ?? '\$${(item.premiumPriceCents / 100).toStringAsFixed(2)}',
          color: GameColors.rarityEpic,
        ),
      CosmeticPriceType.achievement => const _Price(
          icon: Icons.emoji_events_rounded,
          value: 'Achievement',
          color: GameColors.success,
        ),
      CosmeticPriceType.seasonalPlacement => const _Price(
          icon: Icons.leaderboard_rounded,
          value: 'Season',
          color: GameColors.rankLegend,
        ),
    };
  }
}

class _Price extends StatelessWidget {
  const _Price({required this.icon, required this.value, required this.color});
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(GameRadii.pill),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GameSpacing.sm),
      decoration: BoxDecoration(
        color: GameColors.accentSoft,
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: GameColors.accent.withValues(alpha: .22)),
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: GameColors.muted, fontSize: 12)),
    );
  }
}

Color _rarityColor(CosmeticRarity rarity) => switch (rarity) {
      CosmeticRarity.common => GameColors.rarityCommon,
      CosmeticRarity.rare => GameColors.rarityRare,
      CosmeticRarity.epic => GameColors.rarityEpic,
      CosmeticRarity.legendary => GameColors.rarityLegendary,
      CosmeticRarity.mythic => GameColors.rarityMythic,
    };
