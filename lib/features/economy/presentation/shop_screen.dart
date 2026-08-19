import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/cosmic_background.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../data/cosmetic_catalog.dart';
import '../data/economy_backend.dart';
import '../data/premium_billing_service.dart';
import '../domain/cosmetic_item.dart';
import 'cosmetic_preview.dart';
import 'cosmetic_preview_sheet.dart';
import 'cosmetic_runtime.dart';
import 'shop_copy.dart';

enum _ShopSection { featured, avatars, coins, prestige, premium, owned }

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
    CosmeticCatalog.validate();
    if (_purchasesEnabled) {
      final billing = PremiumBillingService(uid: widget.uid);
      _premiumBilling = billing;
      _premiumSubscription = billing.snapshots.listen((snapshot) {
        if (!mounted) return;
        setState(() => _premiumSnapshot = snapshot);
        if (snapshot.message == 'premium_purchase_verified') {
          setState(() {
            _message = _isArabic
                ? 'تم التحقق من الدفع وإضافة العنصر إلى ملكيتك الدائمة.'
                : 'Payment verified. The item is now permanently owned.';
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
      CosmeticSlot.profileBackground => inventory.equippedProfileBackgroundId == item.id,
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
        case CosmeticPriceType.free:
          await widget.economyBackend.equipCosmetic(
            uid: widget.uid,
            cosmeticId: item.id,
          );
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
          await widget.economyBackend.claimEarnedCosmetic(
            uid: widget.uid,
            cosmeticId: item.id,
          );
      }
      if (!mounted || item.priceType == CosmeticPriceType.premium) return;
      setState(() {
        _message = _isArabic
            ? '${ShopCopy.of(context).itemName(item)} أصبح في ملكيتك.'
            : '${ShopCopy.of(context).itemName(item)} is now owned.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = _isArabic
            ? 'لم يتم منح العنصر. لم ينجح شرط الدفع/الرصيد/النجوم/الإنجاز.'
            : 'The item was not granted. Its payment, balance, Stars, or achievement requirement was not satisfied.';
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
      setState(() {
        _message = _isArabic
            ? 'تم تجهيز ${ShopCopy.of(context).itemName(item)}.'
            : '${ShopCopy.of(context).itemName(item)} equipped.';
      });
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
            ? 'جارٍ التحقق من مشتريات Google Play السابقة واستعادة الملكية.'
            : 'Checking previous Google Play purchases and restoring ownership.';
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

  bool _canAcquire(PlayerInventory inventory, CosmeticItem item) {
    return switch (item.priceType) {
      CosmeticPriceType.free => true,
      CosmeticPriceType.coins => inventory.coins >= item.coinPrice,
      CosmeticPriceType.prestigeStars => inventory.prestigeStars >= item.starPrice,
      CosmeticPriceType.premium => _premiumSnapshot?.products.containsKey(item.id) == true,
      CosmeticPriceType.achievement => true,
      CosmeticPriceType.seasonalPlacement => true,
    };
  }

  String _priceLabel(CosmeticItem item) {
    return switch (item.priceType) {
      CosmeticPriceType.free => _isArabic ? 'مجاني' : 'Free',
      CosmeticPriceType.coins => '${item.coinPrice} ${_isArabic ? 'كوينز' : 'Coins'}',
      CosmeticPriceType.prestigeStars => '${item.starPrice} ★',
      CosmeticPriceType.premium => _premiumSnapshot?.localizedPrice(item.id) ??
          '${(item.premiumPriceCents / 100).toStringAsFixed(2)} SAR*',
      CosmeticPriceType.achievement => _requirementLabel(item),
      CosmeticPriceType.seasonalPlacement => _requirementLabel(item),
    };
  }

  String _requirementLabel(CosmeticItem item) {
    return switch (item.requiredAchievementId) {
      'legendary_once' => _isArabic ? 'الوصول للأسطوري مرة' : 'Reach Legendary once',
      'legendary_x3' => _isArabic ? 'الأسطوري ×3 مواسم' : 'Legendary ×3 seasons',
      'legendary_x5' => _isArabic ? 'الأسطوري ×5 مواسم' : 'Legendary ×5 seasons',
      'wins_100' => _isArabic ? '100 فوز Ranked' : '100 Ranked wins',
      'season_champion' => _isArabic ? 'بطل موسم' : 'Season Champion',
      _ => _isArabic ? 'إنجاز خاص' : 'Special achievement',
    };
  }

  String _actionLabel({
    required CosmeticItem item,
    required bool owned,
    required bool equipped,
    required bool canAcquire,
  }) {
    if (equipped) return _isArabic ? 'مجهز' : 'Equipped';
    if (owned) return _isArabic ? 'تجهيز' : 'Equip';
    if (!_purchasesEnabled) return _isArabic ? 'معاينة فقط الآن' : 'Preview only for now';
    if (!canAcquire && item.priceType != CosmeticPriceType.premium) {
      return _isArabic ? 'المتطلب غير مكتمل' : 'Requirement not met';
    }
    return switch (item.priceType) {
      CosmeticPriceType.free => _isArabic ? 'الحصول مجانًا' : 'Get free',
      CosmeticPriceType.coins => _isArabic ? 'شراء بالكوينز' : 'Buy with Coins',
      CosmeticPriceType.prestigeStars => _isArabic ? 'فتح بالنجوم' : 'Unlock with Stars',
      CosmeticPriceType.premium => _isArabic ? 'شراء عبر Google Play' : 'Buy with Google Play',
      CosmeticPriceType.achievement => _isArabic ? 'تحقق واستلام' : 'Verify & claim',
      CosmeticPriceType.seasonalPlacement => _isArabic ? 'تحقق واستلام' : 'Verify & claim',
    };
  }

  void _preview(
    CosmeticItem item,
    PlayerInventory inventory, {
    required bool inventoryUnavailable,
  }) {
    final owned = inventory.ownedCosmeticIds.contains(item.id);
    final equipped = _isEquipped(inventory, item);
    final canAcquire = _canAcquire(inventory, item);
    final actionLabel = _actionLabel(
      item: item,
      owned: owned,
      equipped: equipped,
      canAcquire: canAcquire,
    );
    showCosmeticPreviewSheet(
      context: context,
      item: item,
      name: ShopCopy.of(context).itemName(item),
      description: ShopCopy.of(context).itemDescription(item),
      priceLabel: _priceLabel(item),
      statusLabel: equipped
          ? (_isArabic ? 'مجهز' : 'Equipped')
          : owned
              ? (_isArabic ? 'مملوك' : 'Owned')
              : (_isArabic ? 'مقفل' : 'Locked'),
      owned: owned,
      equipped: equipped,
      actionEnabled: _purchasesEnabled &&
          !inventoryUnavailable &&
          !equipped &&
          (owned || canAcquire),
      actionLabel: actionLabel,
      onAction: equipped
          ? null
          : () => owned ? _equip(item) : _acquire(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.shop, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          top: false,
          child: StreamBuilder<PlayerInventory?>(
            stream: widget.economyBackend.watchInventory(widget.uid),
            builder: (context, snapshot) {
              final inventory = snapshot.data ??
                  const PlayerInventory(coins: 0, ownedCosmeticIds: <String>{});
              final unavailable = snapshot.hasError ||
                  (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData);
              return _buildContent(inventory, inventoryUnavailable: unavailable);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    PlayerInventory inventory, {
    required bool inventoryUnavailable,
  }) {
    final copy = ShopCopy.of(context);
    final items = _itemsForSection(inventory);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(GameSpacing.md, GameSpacing.sm, GameSpacing.md, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WalletHeader(inventory: inventory),
                const SizedBox(height: GameSpacing.sm),
                _InfoBanner(
                  text: _isArabic
                      ? 'اضغط على أي عنصر — حتى المقفل — لمعاينته بالحجم الكبير كما سيظهر داخل اللعبة.'
                      : 'Tap any item — even locked ones — to preview it at full size as it appears in-game.',
                  emphasis: true,
                ),
                if (inventoryUnavailable || !_purchasesEnabled) ...[
                  const SizedBox(height: GameSpacing.sm),
                  _InfoBanner(
                    text: !_purchasesEnabled
                        ? (_isArabic
                            ? 'المعاينة فعالة بالكامل. الشراء والتجهيز يبقيان مقفلين حتى تشغيل سلطة الخادم الآمنة.'
                            : 'Full preview is active. Buying and equipping remain locked until secure server authority is enabled.')
                        : (_isArabic
                            ? 'تعذر تحديث الملكية الآن؛ المعاينة ما زالت متاحة.'
                            : 'Ownership could not be refreshed; preview remains available.'),
                  ),
                ],
                const SizedBox(height: GameSpacing.md),
                _SectionTabs(
                  selected: _section,
                  copy: copy,
                  arabic: _isArabic,
                  onChanged: (section) => setState(() => _section = section),
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
                Text(_sectionTitle(copy), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(_sectionSubtitle(copy), style: const TextStyle(color: GameColors.muted)),
                const SizedBox(height: GameSpacing.sm),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(copy.noOwned, style: const TextStyle(color: GameColors.muted))),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(GameSpacing.md, 0, GameSpacing.md, 110),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: GameSpacing.sm),
              itemBuilder: (context, index) {
                final item = items[index];
                final owned = inventory.ownedCosmeticIds.contains(item.id);
                final equipped = _isEquipped(inventory, item);
                final canAcquire = _canAcquire(inventory, item);
                return _CosmeticCard(
                  item: item,
                  name: copy.itemName(item),
                  description: copy.itemDescription(item),
                  price: _priceLabel(item),
                  owned: owned,
                  equipped: equipped,
                  busy: _busyItemId == item.id || _premiumSnapshot?.pendingProductId == item.id,
                  actionLabel: _actionLabel(
                    item: item,
                    owned: owned,
                    equipped: equipped,
                    canAcquire: canAcquire,
                  ),
                  actionEnabled: _purchasesEnabled &&
                      !inventoryUnavailable &&
                      !equipped &&
                      (owned || canAcquire),
                  onPreview: () => _preview(
                    item,
                    inventory,
                    inventoryUnavailable: inventoryUnavailable,
                  ),
                  onAction: () => owned ? _equip(item) : _acquire(item),
                );
              },
            ),
          ),
      ],
    );
  }

  List<CosmeticItem> _itemsForSection(PlayerInventory inventory) => switch (_section) {
        _ShopSection.featured => CosmeticCatalog.featured,
        _ShopSection.avatars => CosmeticCatalog.avatars,
        _ShopSection.coins => CosmeticCatalog.forPriceType(CosmeticPriceType.coins),
        _ShopSection.prestige => CosmeticCatalog.forPriceType(CosmeticPriceType.prestigeStars),
        _ShopSection.premium => CosmeticCatalog.forPriceType(CosmeticPriceType.premium),
        _ShopSection.owned => CosmeticCatalog.items
            .where((item) => inventory.ownedCosmeticIds.contains(item.id))
            .toList(growable: false),
      };

  String _sectionTitle(ShopCopy copy) => switch (_section) {
        _ShopSection.featured => copy.featured,
        _ShopSection.avatars => _isArabic ? 'الصور الرمزية' : 'Avatars',
        _ShopSection.coins => copy.coins,
        _ShopSection.prestige => copy.prestige,
        _ShopSection.premium => copy.premium,
        _ShopSection.owned => copy.owned,
      };

  String _sectionSubtitle(ShopCopy copy) => switch (_section) {
        _ShopSection.featured => copy.featuredSubtitle,
        _ShopSection.avatars => _isArabic
            ? '45 شخصية: مجانية، كوينز، بريميوم، نجوم وإنجازات نادرة.'
            : '45 characters: free, Coins, Premium, Stars, and rare achievements.',
        _ShopSection.coins => copy.coinSubtitle,
        _ShopSection.prestige => copy.prestigeSubtitle,
        _ShopSection.premium => copy.premiumSubtitle,
        _ShopSection.owned => copy.ownedSubtitle,
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
  const _BalancePill({required this.icon, required this.value, required this.label, required this.color});
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(GameRadii.card),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
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
    required this.arabic,
    required this.onChanged,
  });
  final _ShopSection selected;
  final ShopCopy copy;
  final bool arabic;
  final ValueChanged<_ShopSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = <_ShopSection, String>{
      _ShopSection.featured: copy.featured,
      _ShopSection.avatars: arabic ? 'الشخصيات' : 'Avatars',
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
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _CosmeticCard extends StatelessWidget {
  const _CosmeticCard({
    required this.item,
    required this.name,
    required this.description,
    required this.price,
    required this.owned,
    required this.equipped,
    required this.busy,
    required this.actionLabel,
    required this.actionEnabled,
    required this.onPreview,
    required this.onAction,
  });

  final CosmeticItem item;
  final String name;
  final String description;
  final String price;
  final bool owned;
  final bool equipped;
  final bool busy;
  final String actionLabel;
  final bool actionEnabled;
  final VoidCallback onPreview;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final color = cosmeticRarityColor(item.rarity);
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return CosmicPanel(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onPreview,
        borderRadius: BorderRadius.circular(GameRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(GameSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'shop-${item.id}',
                child: CosmeticPreview(item: item, rarityColor: color, size: 82),
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        ),
                        const Icon(Icons.zoom_in_rounded, size: 19, color: GameColors.accentBright),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: GameColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      children: [
                        _MiniTag(text: price, color: color),
                        _MiniTag(
                          text: equipped
                              ? (ar ? 'مجهز' : 'Equipped')
                              : owned
                                  ? (ar ? 'مملوك' : 'Owned')
                                  : (ar ? 'قابل للمعاينة' : 'Previewable'),
                          color: equipped || owned ? GameColors.success : GameColors.accentBright,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onPreview,
                            icon: const Icon(Icons.visibility_rounded, size: 17),
                            label: Text(ar ? 'معاينة' : 'Preview'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: busy || !actionEnabled ? null : onAction,
                            child: busy
                                ? const SizedBox.square(
                                    dimension: 15,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(actionLabel, textAlign: TextAlign.center, maxLines: 2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text, this.emphasis = false});
  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return CosmicPanel(
      padding: const EdgeInsets.all(GameSpacing.sm),
      glow: emphasis,
      child: Row(
        children: [
          Icon(
            emphasis ? Icons.visibility_rounded : Icons.info_outline_rounded,
            color: emphasis ? GameColors.accentBright : GameColors.muted,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: emphasis ? GameColors.textSoft : GameColors.muted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
