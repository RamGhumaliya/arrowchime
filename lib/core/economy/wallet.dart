import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet.g.dart';

/// Soft-currency balance. In-memory until the save system (Phase 6) persists
/// it; coins are never negative and a spend either fully succeeds or does
/// nothing.
@Riverpod(keepAlive: true)
class Wallet extends _$Wallet {
  @override
  int build() => 0;

  /// Adds [coins] (ignored when not positive).
  void add(int coins) {
    if (coins > 0) state += coins;
  }

  /// Spends [price] if the balance covers it. Returns whether it did.
  bool trySpend(int price) {
    if (price < 0 || state < price) return false;
    state -= price;
    return true;
  }
}
