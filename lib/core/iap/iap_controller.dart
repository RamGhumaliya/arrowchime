import 'dart:async';

import 'package:arrowchime/core/ads/ads_controller.dart';
import 'package:arrowchime/core/iap/iap_service.dart';
import 'package:arrowchime/core/iap/iap_service_store.dart';
import 'package:arrowchime/core/iap/products.dart';
import 'package:arrowchime/core/iap/purchase_fulfillment.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'iap_controller.g.dart';

@Riverpod(keepAlive: true)
IapService iapService(Ref ref) => StoreIapService();

@Riverpod(keepAlive: true)
Products products(Ref ref) => Products(ref.watch(appConfigProvider));

/// What the shop shows after a store event.
enum PurchaseOutcome { thankYou, restored, failed }

/// Listens to the store, fulfils purchases into the save and tells the UI.
class IapController {
  new(this._ref) {
    _sub = _ref.read(iapServiceProvider).updates.listen(_onUpdate);
    _ref.onDispose(() {
      unawaited(_sub.cancel());
      unawaited(_outcomes.close());
    });
  }

  final Ref _ref;
  late final StreamSubscription<PurchaseUpdate> _sub;
  final _outcomes = StreamController<PurchaseOutcome>.broadcast();

  /// "Thank you!" / "didn't go through" events for toasts.
  Stream<PurchaseOutcome> get outcomes => _outcomes.stream;

  /// Store prices by product id (empty when the store is unavailable).
  Future<Map<String, String>> prices() async {
    final service = _ref.read(iapServiceProvider);
    if (!await service.isAvailable()) return const {};
    final ids = {for (final p in _ref.read(productsProvider).all) p.id};
    final loaded = await service.loadProducts(ids);
    return {for (final p in loaded) p.id: p.price};
  }

  Future<void> buy(IapProduct product) => _ref
      .read(iapServiceProvider)
      .buy(product.id, consumable: product.kind == ProductKind.consumable);

  Future<void> restore() => _ref.read(iapServiceProvider).restore();

  void _onUpdate(PurchaseUpdate u) {
    final save = _ref.read(saveControllerProvider.notifier);
    final before = _ref.read(saveControllerProvider);
    final after = PurchaseFulfillment.apply(
      before,
      u,
      _ref.read(productsProvider),
      _ref.read(adPolicyProvider),
      nowMs: _ref.read(clockProvider)().millisecondsSinceEpoch,
    );
    if (!identical(after, before)) save.update((_) => after);
    switch (u.status) {
      case PurchaseStatus.purchased:
        _outcomes.add(PurchaseOutcome.thankYou);
      case PurchaseStatus.restored:
        _outcomes.add(PurchaseOutcome.restored);
      case PurchaseStatus.failed:
        _outcomes.add(PurchaseOutcome.failed);
      case PurchaseStatus.pending:
      case PurchaseStatus.canceled:
        break;
    }
  }
}

@Riverpod(keepAlive: true)
IapController iapController(Ref ref) => IapController(ref);
