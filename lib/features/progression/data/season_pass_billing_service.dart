import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class SeasonPassBillingSnapshot {
  const SeasonPassBillingSnapshot({
    required this.available,
    this.product,
    this.pending = false,
    this.message,
  });

  final bool available;
  final ProductDetails? product;
  final bool pending;
  final String? message;

  String get localizedPrice => product?.price ?? r'$30.00';
}

class SeasonPassBillingService {
  SeasonPassBillingService({
    required this.uid,
    required this.seasonId,
    InAppPurchase? store,
    FirebaseFunctions? functions,
  })  : _store = store ?? InAppPurchase.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2');

  static const String productId = 'premium_season_pass_30d';
  static const String basePlanId = 'prepaid-30d';

  final String uid;
  final String seasonId;
  final InAppPurchase _store;
  final FirebaseFunctions _functions;
  final _controller = StreamController<SeasonPassBillingSnapshot>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _available = false;
  bool _pending = false;
  bool _initialized = false;
  ProductDetails? _product;

  Stream<SeasonPassBillingSnapshot> get snapshots => _controller.stream;

  SeasonPassBillingSnapshot get current => SeasonPassBillingSnapshot(
        available: _available,
        product: _product,
        pending: _pending,
      );

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _purchaseSubscription = _store.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) => _emit(message: 'season_pass_purchase_error'),
    );

    _available = await _store.isAvailable();
    if (!_available) {
      _emit(message: 'season_pass_store_unavailable');
      return;
    }

    final response = await _store.queryProductDetails(const {productId});
    _product = response.productDetails.where(_matchesApprovedPlan).firstOrNull;
    _emit(
      message: response.error == null && _product != null
          ? null
          : 'season_pass_product_unavailable',
    );
  }

  bool _matchesApprovedPlan(ProductDetails item) {
    if (item.id != productId) return false;
    if (item is! GooglePlayProductDetails) return true;
    final index = item.subscriptionIndex;
    final offers = item.productDetails.subscriptionOfferDetails;
    if (index == null || offers == null || index < 0 || index >= offers.length) {
      return false;
    }
    return offers[index].basePlanId == basePlanId;
  }

  Future<void> buy() async {
    final product = _product;
    if (!_available || product == null) {
      throw StateError('Premium Season Pass is unavailable.');
    }
    if (_pending) throw StateError('Premium Season Pass purchase is pending.');

    _pending = true;
    _emit();
    final purchaseParam = product is GooglePlayProductDetails
        ? GooglePlayPurchaseParam(
            productDetails: product,
            applicationUserName: uid,
            offerToken: product.offerToken,
          )
        : PurchaseParam(productDetails: product, applicationUserName: uid);
    final started = await _store.buyNonConsumable(purchaseParam: purchaseParam);
    if (!started) {
      _pending = false;
      _emit(message: 'season_pass_purchase_not_started');
    }
  }

  Future<void> restore() async {
    if (!_available) return;
    await _store.restorePurchases(applicationUserName: uid);
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases.where((item) => item.productID == productId)) {
      if (purchase.status == PurchaseStatus.pending) {
        _pending = true;
        _emit(message: 'season_pass_purchase_pending');
        continue;
      }
      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        _pending = false;
        _emit(message: 'season_pass_purchase_error');
        continue;
      }
      if (purchase.status != PurchaseStatus.purchased &&
          purchase.status != PurchaseStatus.restored) {
        continue;
      }

      final token = purchase.verificationData.serverVerificationData;
      if (token.isEmpty) {
        _pending = false;
        _emit(message: 'season_pass_verification_missing');
        continue;
      }

      try {
        await _functions.httpsCallable('verifyPremiumSeasonPass').call<void>({
          'seasonId': seasonId,
          'productId': productId,
          'purchaseToken': token,
        });
        if (purchase.pendingCompletePurchase) {
          await _store.completePurchase(purchase);
        }
        _pending = false;
        _emit(message: 'season_pass_purchase_verified');
      } catch (_) {
        _pending = false;
        _emit(message: 'season_pass_verification_failed');
      }
    }
  }

  void _emit({String? message}) {
    if (_controller.isClosed) return;
    _controller.add(
      SeasonPassBillingSnapshot(
        available: _available,
        product: _product,
        pending: _pending,
        message: message,
      ),
    );
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    await _controller.close();
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
