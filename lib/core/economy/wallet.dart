import 'package:arrowchime/core/save/save_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet.g.dart';

/// Soft-currency balance, kept in the save (`docs/05` §6). Coins are never
/// negative and a spend either fully succeeds or does nothing.
@Riverpod(keepAlive: true)
class Wallet extends _$Wallet {
  @override
  int build() => ref.watch(saveControllerProvider.select((s) => s.coins));

  /// Adds [coins] (ignored when not positive).
  void add(int coins) {
    if (coins <= 0) return;
    ref
        .read(saveControllerProvider.notifier)
        .update((d) => d.copyWith(coins: d.coins + coins));
  }

  /// Spends [price] if the balance covers it. Returns whether it did.
  bool trySpend(int price) {
    final coins = ref.read(saveControllerProvider).coins;
    if (price < 0 || coins < price) return false;
    ref
        .read(saveControllerProvider.notifier)
        .update((d) => d.copyWith(coins: d.coins - price));
    return true;
  }
}
