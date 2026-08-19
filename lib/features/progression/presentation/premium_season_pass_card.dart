import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/design_tokens.dart';
import '../data/season_pass_billing_service.dart';
import '../domain/season_pass.dart';

class PremiumSeasonPassCard extends StatefulWidget {
  const PremiumSeasonPassCard({
    super.key,
    required this.uid,
    required this.seasonId,
    required this.unlocked,
  });

  final String uid;
  final String seasonId;
  final bool unlocked;

  @override
  State<PremiumSeasonPassCard> createState() => _PremiumSeasonPassCardState();
}

class _PremiumSeasonPassCardState extends State<PremiumSeasonPassCard> {
  SeasonPassBillingService? _billing;
  StreamSubscription<SeasonPassBillingSnapshot>? _subscription;
  SeasonPassBillingSnapshot? _snapshot;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    if (AppConfig.backendPhase == BackendPhase.blaze) {
      final billing = SeasonPassBillingService(
        uid: widget.uid,
        seasonId: widget.seasonId,
      );
      _billing = billing;
      _snapshot = billing.current;
      _subscription = billing.snapshots.listen((snapshot) {
        if (mounted) setState(() => _snapshot = snapshot);
      });
      unawaited(billing.initialize());
    }
  }

  @override
  void didUpdateWidget(covariant PremiumSeasonPassCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seasonId != widget.seasonId) {
      unawaited(_resetBilling());
    }
  }

  Future<void> _resetBilling() async {
    await _subscription?.cancel();
    await _billing?.dispose();
    _subscription = null;
    _billing = null;
    _snapshot = null;
    if (!mounted || AppConfig.backendPhase != BackendPhase.blaze) return;
    final billing = SeasonPassBillingService(
      uid: widget.uid,
      seasonId: widget.seasonId,
    );
    _billing = billing;
    _snapshot = billing.current;
    _subscription = billing.snapshots.listen((snapshot) {
      if (mounted) setState(() => _snapshot = snapshot);
    });
    await billing.initialize();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_billing?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final price = snapshot?.localizedPrice ?? r'$30.00';
    final serverReady = AppConfig.backendPhase == BackendPhase.blaze;

    return CosmicPanel(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: GameColors.cosmicGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: GameShadows.primaryGlow,
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white),
              ),
              const SizedBox(width: GameSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic ? 'Premium Season Pass' : 'Premium Season Pass',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isArabic
                          ? '$price • صالح للموسم الحالي (30 يومًا)'
                          : '$price • Current 30-day season',
                      style: const TextStyle(color: GameColors.rewardGold, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              if (widget.unlocked)
                const Icon(Icons.verified_rounded, color: GameColors.success),
            ],
          ),
          const SizedBox(height: GameSpacing.md),
          Text(
            _isArabic
                ? 'يفتح مسار Premium لهذا الموسم. النجوم لا تُمنح بمجرد الدفع: العب وارفع مستوى الموسم لتحصل على نجمة هيبة دائمة عند المستويات 6 و12 و18 و24 و30 — بحد أقصى 5 نجوم في الموسم.'
                : 'Unlocks this season’s Premium track. Stars are not granted for payment alone: play and level up to earn one permanent Prestige Star at levels 6, 12, 18, 24 and 30 — maximum 5 Stars per season.',
            style: const TextStyle(color: GameColors.muted, height: 1.45),
          ),
          const SizedBox(height: GameSpacing.sm),
          Wrap(
            spacing: GameSpacing.sm,
            runSpacing: GameSpacing.xs,
            children: [
              _BenefitPill(
                icon: Icons.calendar_month_rounded,
                text: _isArabic ? '30 يومًا' : '30 days',
              ),
              _BenefitPill(
                icon: Icons.star_rounded,
                text: _isArabic
                    ? '${SeasonPassPolicy.maxPremiumStarsPerSeason} نجوم كحد أقصى'
                    : 'Up to ${SeasonPassPolicy.maxPremiumStarsPerSeason} Stars',
              ),
              _BenefitPill(
                icon: Icons.monetization_on_rounded,
                text: _isArabic ? 'مكافآت Coins إضافية' : 'Extra Coin rewards',
              ),
            ],
          ),
          const SizedBox(height: GameSpacing.md),
          if (widget.unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: GameColors.success.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(GameRadii.button),
              ),
              child: Text(
                _isArabic
                    ? 'Premium مفعل لهذا الموسم. استمر في التقدم لاستلام المكافآت.'
                    : 'Premium is active for this season. Keep progressing to claim rewards.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: GameColors.success, fontWeight: FontWeight.w800),
              ),
            )
          else if (!serverReady)
            Text(
              _isArabic
                  ? 'الشراء سيُفعّل عند تشغيل خادم Blaze وتهيئة منتج Google Play للإصدار الإنتاجي.'
                  : 'Purchase activates after Blaze authority and the Google Play product are configured for production.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameColors.muted, fontSize: 12),
            )
          else ...[
            FilledButton.icon(
              onPressed: snapshot?.available == true &&
                      snapshot?.product != null &&
                      snapshot?.pending != true
                  ? () => _billing?.buy()
                  : null,
              icon: snapshot?.pending == true
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.shopping_bag_rounded),
              label: Text(
                snapshot?.pending == true
                    ? (_isArabic ? 'جارٍ تنفيذ الشراء…' : 'Purchase pending…')
                    : (_isArabic ? 'فتح Premium — $price' : 'Unlock Premium — $price'),
              ),
            ),
            TextButton.icon(
              onPressed: snapshot?.available == true ? () => _billing?.restore() : null,
              icon: const Icon(Icons.restore_rounded),
              label: Text(_isArabic ? 'استعادة الاشتراك' : 'Restore purchase'),
            ),
            if (snapshot?.message != null)
              Text(
                _message(snapshot!.message!),
                textAlign: TextAlign.center,
                style: const TextStyle(color: GameColors.muted, fontSize: 11),
              ),
          ],
        ],
      ),
    );
  }

  String _message(String code) {
    return switch (code) {
      'season_pass_purchase_verified' =>
        _isArabic ? 'تم التحقق من Premium بنجاح.' : 'Premium verified successfully.',
      'season_pass_purchase_pending' =>
        _isArabic ? 'عملية الشراء قيد المعالجة.' : 'Purchase is pending.',
      'season_pass_store_unavailable' =>
        _isArabic ? 'Google Play غير متاح الآن.' : 'Google Play is unavailable.',
      'season_pass_product_unavailable' =>
        _isArabic ? 'منتج Premium غير مهيأ في Google Play.' : 'Premium product is not configured in Google Play.',
      'season_pass_verification_failed' =>
        _isArabic ? 'تعذر التحقق من الشراء من الخادم.' : 'Server verification failed.',
      _ => _isArabic ? 'تعذر إكمال العملية الآن.' : 'The operation could not be completed right now.',
    };
  }
}

class _BenefitPill extends StatelessWidget {
  const _BenefitPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: GameColors.violet.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(GameRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: GameColors.violet),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: GameColors.violet,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
