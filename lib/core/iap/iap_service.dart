import 'dart:async';

/// What the store reports about a purchase.
enum PurchaseStatus { purchased, restored, pending, failed, canceled }

/// One store event.
class PurchaseUpdate {
  const new({
    required this.productId,
    required this.status,
    this.transactionId,
    this.error,
  });

  final String productId;
  final PurchaseStatus status;

  /// Store transaction id (null for events without one).
  final String? transactionId;
  final String? error;
}

/// A product as the store describes it (localised price).
class StoreProduct {
  const new({required this.id, required this.title, required this.price});

  final String id;
  final String title;

  /// Formatted by the store, e.g. `$3.99`.
  final String price;
}

/// Purchases behind an interface (`CLAUDE.md` rule 11): the real one is
/// `in_app_purchase` (Play Billing / StoreKit), tests and dev use a fake.
abstract interface class IapService {
  /// Purchase and restore events; the app fulfils them (idempotently).
  Stream<PurchaseUpdate> get updates;

  /// Whether the store can be used on this device.
  Future<bool> isAvailable();

  Future<List<StoreProduct>> loadProducts(Set<String> ids);

  /// Starts the store's purchase flow; the outcome arrives on [updates].
  Future<void> buy(String productId, {required bool consumable});

  /// Asks the store for the player's previous non-consumable purchases.
  Future<void> restore();
}

/// A scriptable [IapService] for tests and development builds. [emit] plays
/// the part of the store.
class FakeIapService implements IapService {
  final _controller = StreamController<PurchaseUpdate>.broadcast();
  bool available = true;
  final List<String> bought = [];
  int restores = 0;

  /// Product id → price shown.
  Map<String, String> prices = {
    'remove_ads': r'$3.99',
    'starter_bundle': r'$6.99',
    'coins_pouch': r'$1.99',
    'coins_chest': r'$7.99',
    'coins_vault': r'$19.99',
    'art_pack': r'$2.99',
  };

  /// When set, [buy] answers with this status (the store sheet's outcome);
  /// `null` leaves it to [emit].
  PurchaseStatus? autoStatus = PurchaseStatus.purchased;
  int _next = 1;

  @override
  Stream<PurchaseUpdate> get updates => _controller.stream;

  void emit(PurchaseUpdate u) => _controller.add(u);

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<List<StoreProduct>> loadProducts(Set<String> ids) async => [
    for (final id in ids)
      if (prices.containsKey(id))
        StoreProduct(id: id, title: id, price: prices[id]!),
  ];

  @override
  Future<void> buy(String productId, {required bool consumable}) async {
    bought.add(productId);
    final status = autoStatus;
    if (status != null) {
      _controller.add(
        PurchaseUpdate(
          productId: productId,
          status: status,
          transactionId: 'tx${_next++}',
        ),
      );
    }
  }

  @override
  Future<void> restore() async => restores++;
}
