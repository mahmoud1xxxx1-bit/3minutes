import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';
import '../domain/cosmetic_item.dart';
import 'cosmetic_runtime.dart';

Future<void> showCosmeticPreviewSheet({
  required BuildContext context,
  required CosmeticItem item,
  required String name,
  required String description,
  required String priceLabel,
  required String statusLabel,
  required bool owned,
  required bool equipped,
  required bool actionEnabled,
  required String actionLabel,
  VoidCallback? onAction,
}) {
  final ar = Localizations.localeOf(context).languageCode == 'ar';
  final color = cosmeticRarityColor(item.rarity);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .9,
          ),
          decoration: const BoxDecoration(
            color: GameColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: GameColors.surfaceStrong,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _rarityLabel(item.rarity, ar),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GameColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(GameRadii.panel),
                    border: Border.all(color: color.withValues(alpha: .35)),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: .12), blurRadius: 24)],
                  ),
                  child: CosmeticAppliedPreview(item: item),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GameColors.surface,
                    borderRadius: BorderRadius.circular(GameRadii.card),
                    border: Border.all(color: GameColors.surfaceStrong),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ar ? 'هكذا سيظهر داخل اللعبة' : 'This is how it appears in-game',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        description,
                        style: const TextStyle(color: GameColors.textSoft, height: 1.45),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(
                            icon: Icons.visibility_rounded,
                            text: ar ? 'معاينة فقط' : 'Preview only',
                            color: GameColors.accentBright,
                          ),
                          _Pill(
                            icon: owned ? Icons.verified_rounded : Icons.lock_outline_rounded,
                            text: statusLabel,
                            color: owned ? GameColors.success : GameColors.muted,
                          ),
                          _Pill(
                            icon: Icons.local_offer_rounded,
                            text: priceLabel,
                            color: color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  ar
                      ? 'فتح المعاينة لا يشتري العنصر ولا يخصم أي رصيد. التملك يحدث فقط بعد تنفيذ زر الشراء/الفتح الصريح والتحقق من الخادم.'
                      : 'Opening preview never buys the item or charges anything. Ownership changes only after an explicit purchase/unlock action and server verification.',
                  style: const TextStyle(color: GameColors.muted, fontSize: 12, height: 1.45),
                ),
                const SizedBox(height: 16),
                if (equipped)
                  const _EquippedBanner()
                else
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: actionEnabled && onAction != null
                          ? () {
                              Navigator.of(sheetContext).pop();
                              onAction();
                            }
                          : null,
                      icon: Icon(owned ? Icons.check_circle_rounded : Icons.lock_open_rounded),
                      label: Text(actionLabel),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(GameRadii.pill),
        border: Border.all(color: color.withValues(alpha: .24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EquippedBanner extends StatelessWidget {
  const _EquippedBanner();

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: GameColors.success.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(GameRadii.button),
        border: Border.all(color: GameColors.success.withValues(alpha: .35)),
      ),
      child: Text(
        ar ? 'مجهز الآن' : 'Currently equipped',
        style: const TextStyle(color: GameColors.success, fontWeight: FontWeight.w900),
      ),
    );
  }
}

String _rarityLabel(CosmeticRarity rarity, bool ar) => switch (rarity) {
      CosmeticRarity.common => ar ? 'عادي' : 'COMMON',
      CosmeticRarity.rare => ar ? 'نادر' : 'RARE',
      CosmeticRarity.epic => ar ? 'ملحمي' : 'EPIC',
      CosmeticRarity.legendary => ar ? 'أسطوري' : 'LEGENDARY',
      CosmeticRarity.mythic => ar ? 'خرافي' : 'MYTHIC',
    };
