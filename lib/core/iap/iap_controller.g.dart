// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iap_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(iapService)
final iapServiceProvider = IapServiceProvider._();

final class IapServiceProvider
    extends $FunctionalProvider<IapService, IapService, IapService>
    with $Provider<IapService> {
  IapServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapServiceHash();

  @$internal
  @override
  $ProviderElement<IapService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IapService create(Ref ref) {
    return iapService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IapService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IapService>(value),
    );
  }
}

String _$iapServiceHash() => r'8959b4425527ff25024690f272c0595959b903fe';

@ProviderFor(products)
final productsProvider = ProductsProvider._();

final class ProductsProvider
    extends $FunctionalProvider<Products, Products, Products>
    with $Provider<Products> {
  ProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productsHash();

  @$internal
  @override
  $ProviderElement<Products> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Products create(Ref ref) {
    return products(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Products value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Products>(value),
    );
  }
}

String _$productsHash() => r'd1025babf215fc7db39e0c0be3bb4bb0edf9babb';

@ProviderFor(iapController)
final iapControllerProvider = IapControllerProvider._();

final class IapControllerProvider
    extends $FunctionalProvider<IapController, IapController, IapController>
    with $Provider<IapController> {
  IapControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iapControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iapControllerHash();

  @$internal
  @override
  $ProviderElement<IapController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IapController create(Ref ref) {
    return iapController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IapController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IapController>(value),
    );
  }
}

String _$iapControllerHash() => r'6b2a7441090aead06f2d2c4ace78a6fed5e93c82';
