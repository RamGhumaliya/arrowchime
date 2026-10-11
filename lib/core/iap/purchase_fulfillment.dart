import 'package:arrowchime/core/ads/ad_policy.dart';
import 'package:arrowchime/core/cosmetics/cosmetics.dart';
import 'package:arrowchime/core/iap/iap_service.dart';
import 'package:arrowchime/core/iap/products.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// Turns store events into changes of the save (`docs/09` §4: purchases are
/// idempotent, restore works on a fresh install). Pure: the clock and the ad
/// policy are passed in.
abstract final class PurchaseFulfillment {
  /// `product:<id>` marks a non-consumable whose coin bonus was paid.
  static String marker(String productId) => 'product:$productId';

  /// Applies [update]; returns the new save, or the same one when nothing
  /// changed (unknown product, repeated transaction, failure, ...).
  static SaveData apply(
    SaveData d,
    PurchaseUpdate update,
    Products products,
    AdPolicy ads, {
    required int nowMs,
  }) {
    final product = products.byId(update.productId);
    if (product == null) return d;
    switch (update.status) {
      case PurchaseStatus.purchased:
        return _purchased(d, update, product, ads, nowMs);
      case PurchaseStatus.restored:
        return product.kind == ProductKind.nonConsumable
            ? _entitlements(d, product, payCoins: !_paid(d, product))
            : d;
      case PurchaseStatus.pending:
      case PurchaseStatus.failed:
      case PurchaseStatus.canceled:
        return d;
    }
  }

  static bool _paid(SaveData d, IapProduct p) =>
      d.purchases.contains(marker(p.id));

  static SaveData _purchased(
    SaveData d,
    PurchaseUpdate update,
    IapProduct product,
    AdPolicy ads,
    int nowMs,
  ) {
    final tx = update.transactionId;
    if (tx != null && d.purchases.contains(tx)) return d;
    final payCoins =
        product.kind == ProductKind.consumable || !_paid(d, product);
    final next = _entitlements(d, product, payCoins: payCoins);
    return next.copyWith(
      purchases: [...next.purchases, ?tx],
      ads: ads.purchaseMade(next.ads, nowMs: nowMs),
    );
  }

  static SaveData _entitlements(
    SaveData d,
    IapProduct product, {
    required bool payCoins,
  }) {
    var next = d;
    if (payCoins && product.coins > 0) {
      next = next.copyWith(coins: next.coins + product.coins);
    }
    if (product.removesAds) {
      next = next.copyWith(flags: {...next.flags, 'adsRemoved': true});
    }
    if (product.cosmetics.isNotEmpty) {
      next = Cosmetics.grant(next, product.cosmetics);
    }
    if (product.kind == ProductKind.nonConsumable && !_paid(next, product)) {
      next = next.copyWith(purchases: [...next.purchases, marker(product.id)]);
    }
    return next;
  }
}
