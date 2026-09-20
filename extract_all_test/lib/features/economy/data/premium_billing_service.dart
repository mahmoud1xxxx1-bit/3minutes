import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../domain/cosmetic_item.dart';

class PremiumBillingSnapshot {
  const PremiumBillingSnapshot({
    required this.available,
    required this.products,
    this.pendingProductId,
    this.message,
  });

  final bool available;
  final Map<String, ProductDetails> products;
  final String? pendingProductId;
  final String? message;

  String? localizedPrice(String productId) => products[productId]?.price;
}

class PremiumBillingService {
  PremiumBillingService({
    required this.uid,
    InAppPurchase? store,
    FirebaseFunctions? functions,
  })  : _store = store ?? InAppPurchase.instance,
        _functions = functions ?? FirebaseFunctions.instanceFor(region: 'me-central2');

  final String uid;
  final InAppPurchase _store;
  final FirebaseFunctions _functions;
  final _controller = StreamController<PremiumBillingSnapshot>.broadcast();
  final Map<String, ProductDetails> _products = <String, ProductDetails>{};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _available = false;
  String? _pendingProductId;
  bool _initialized = false;

  Stream<PremiumBillingSnapshot> get snapshots => _controller.stream;

  PremiumBillingSnapshot get current => PremiumBillingSnapshot(
        available: _available,
        products: Map.unmodifiable(_products),
        pendingProductId: _pendingProductId,
      );

  Future<void> initialize(Iterable<CosmeticItem> premiumItems) async {
    if (_initialized) return;
    _initialized = true;
    _purchaseSubscription = _store.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) => _emit(message: 'premium_purchase_error'),
    );

    _available = await _store.isAvailable();
    if (!_available) {
      _emit(message: 'premium_store_unavailable');
      return;
    }

    final ids = premiumItems
        .where((item) => item.priceType == CosmeticPriceType.premium)
        .map((item) => item.id)
        .toSet();
    if (ids.isEmpty) {
      _emit();
      return;
    }

    final response = await _store.queryProductDetails(ids);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
    _emit(
      message: response.error == null && response.notFoundIDs.isEmpty
          ? null
          : 'premium_products_incomplete',
    );
  }

  Future<void> buy(CosmeticItem item) async {
    if (!_available || item.priceType != CosmeticPriceType.premium) {
      throw StateError('Premium product is unavailable.');
    }
    if (_pendingProductId != null) {
      throw StateError('Another premium purchase is pending.');
    }
    final product = _products[item.id];
    if (product == null) {
      throw StateError('Premium product is not configured in Google Play.');
    }

    _pendingProductId = item.id;
    _emit();
    final started = await _store.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: product,
        applicationUserName: uid,
      ),
    );
    if (!started) {
      _pendingProductId = null;
      _emit(message: 'premium_purchase_not_started');
    }
  }

  Future<void> restore() async {
    if (!_available) return;
    await _store.restorePurchases(applicationUserName: uid);
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        _pendingProductId = purchase.productID;
        _emit(message: 'premium_purchase_pending');
        continue;
      }

      if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        _pendingProductId = null;
        _emit(message: 'premium_purchase_error');
        continue;
      }

      if (purchase.status != PurchaseStatus.purchased &&
          purchase.status != PurchaseStatus.restored) {
        continue;
      }

      final token = purchase.verificationData.serverVerificationData;
      if (token.isEmpty) {
        _pendingProductId = null;
        _emit(message: 'premium_verification_missing');
        continue;
      }

      try {
        await _functions.httpsCallable('verifyPremiumPurchase').call<void>({
          'cosmeticId': purchase.productID,
          'productId': purchase.productID,
          'purchaseToken': token,
        });
        if (purchase.pendingCompletePurchase) {
          await _store.completePurchase(purchase);
        }
        _pendingProductId = null;
        _emit(message: 'premium_purchase_verified');
      } catch (_) {
        // Do not complete the Play purchase until the server has verified and
        // persisted the entitlement. The purchase stream can safely retry it.
        _pendingProductId = null;
        _emit(message: 'premium_verification_failed');
      }
    }
  }

  void _emit({String? message}) {
    if (_controller.isClosed) return;
    _controller.add(
      PremiumBillingSnapshot(
        available: _available,
        products: Map.unmodifiable(_products),
        pendingProductId: _pendingProductId,
        message: message,
      ),
    );
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    await _controller.close();
  }
}
