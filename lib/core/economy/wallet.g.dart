// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Soft-currency balance, kept in the save (`docs/05` §6). Coins are never
/// negative and a spend either fully succeeds or does nothing.

@ProviderFor(Wallet)
final walletProvider = WalletProvider._();

/// Soft-currency balance, kept in the save (`docs/05` §6). Coins are never
/// negative and a spend either fully succeeds or does nothing.
final class WalletProvider extends $NotifierProvider<Wallet, int> {
  /// Soft-currency balance, kept in the save (`docs/05` §6). Coins are never
  /// negative and a spend either fully succeeds or does nothing.
  WalletProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletHash();

  @$internal
  @override
  Wallet create() => Wallet();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$walletHash() => r'be9acff0468098906f1273cc43ddd61fffc3d3a2';

/// Soft-currency balance, kept in the save (`docs/05` §6). Coins are never
/// negative and a spend either fully succeeds or does nothing.

abstract class _$Wallet extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
