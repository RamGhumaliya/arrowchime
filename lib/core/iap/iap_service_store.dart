import 'dart:async';

import 'package:arrowchime/core/iap/iap_service.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;

/// [IapService] on `in_app_purchase` (Play Billing / StoreKit).
///
/// Receipts are not validated on a server (no backend yet; `docs/05` §6 says
/// entitlements come from the IAP provider): the store's own signed state is
/// trusted. Add server validation when Firebase arrives (Phase 9).
class StoreIapService implements IapService {
  new() {
    _sub = iap.InAppPurchase.instance.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) => debugPrint('IAP stream error: $e'),
    );
  }

  late final StreamSubscription<List<iap.PurchaseDetails>> _sub;
  final _controller = StreamController<PurchaseUpdate>.broadcast();
  final Map<String, iap.ProductDetails> _details = {};

  @override
  Stream<PurchaseUpdate> get updates => _controller.stream;

  void _onPurchases(List<iap.PurchaseDetails> purchases) {
    for (final p in purchases) {
      final status = switch (p.status) {
        iap.PurchaseStatus.purchased => PurchaseStatus.purchased,
        iap.PurchaseStatus.restored => PurchaseStatus.restored,
        iap.PurchaseStatus.pending => PurchaseStatus.pending,
        iap.PurchaseStatus.error => PurchaseStatus.failed,
        iap.PurchaseStatus.canceled => PurchaseStatus.canceled,
      };
      _controller.add(
        PurchaseUpdate(
          productId: p.productID,
          status: status,
          transactionId: p.purchaseID,
          error: p.error?.message,
        ),
      );
      if (p.pendingCompletePurchase) {
        unawaited(iap.InAppPurchase.instance.completePurchase(p));
      }
    }
  }

  @override
  Future<bool> isAvailable() => iap.InAppPurchase.instance.isAvailable();

  @override
  Future<List<StoreProduct>> loadProducts(Set<String> ids) async {
    final response = await iap.InAppPurchase.instance.queryProductDetails(ids);
    for (final d in response.productDetails) {
      _details[d.id] = d;
    }
    return [
      for (final d in response.productDetails)
        StoreProduct(id: d.id, title: d.title, price: d.price),
    ];
  }

  @override
  Future<void> buy(String productId, {required bool consumable}) async {
    final details = _details[productId];
    if (details == null) {
      _controller.add(
        PurchaseUpdate(
          productId: productId,
          status: PurchaseStatus.failed,
          error: 'product not loaded',
        ),
      );
      return;
    }
    final param = iap.PurchaseParam(productDetails: details);
    if (consumable) {
      await iap.InAppPurchase.instance.buyConsumable(purchaseParam: param);
    } else {
      await iap.InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    }
  }

  @override
  Future<void> restore() => iap.InAppPurchase.instance.restorePurchases();

  Future<void> dispose() async {
    await _sub.cancel();
    await _controller.close();
  }
}
