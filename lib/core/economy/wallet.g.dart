// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Soft-currency balance. In-memory until the save system (Phase 6) persists
/// it; coins are never negative and a spend either fully succeeds or does
/// nothing.

@ProviderFor(Wallet)
final walletProvider = WalletProvider._();

/// Soft-currency balance. In-memory until the save system (Phase 6) persists
/// it; coins are never negative and a spend either fully succeeds or does
/// nothing.
final class WalletProvider extends $NotifierProvider<Wallet, int> {
  /// Soft-currency balance. In-memory until the save system (Phase 6) persists
  /// it; coins are never negative and a spend either fully succeeds or does
  /// nothing.
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

String _$walletHash() => r'447e2a40e7f1f6d23a79627ac61c20d531d6e0ff';

/// Soft-currency balance. In-memory until the save system (Phase 6) persists
/// it; coins are never negative and a spend either fully succeeds or does
/// nothing.

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
