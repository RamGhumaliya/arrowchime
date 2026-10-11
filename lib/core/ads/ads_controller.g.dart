// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ads_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adsService)
final adsServiceProvider = AdsServiceProvider._();

final class AdsServiceProvider
    extends $FunctionalProvider<AdsService, AdsService, AdsService>
    with $Provider<AdsService> {
  AdsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adsServiceHash();

  @$internal
  @override
  $ProviderElement<AdsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdsService create(Ref ref) {
    return adsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdsService>(value),
    );
  }
}

String _$adsServiceHash() => r'7172c2da80cc441343ecd4b74d7e78f3aff1e450';

@ProviderFor(adPolicy)
final adPolicyProvider = AdPolicyProvider._();

final class AdPolicyProvider
    extends $FunctionalProvider<AdPolicy, AdPolicy, AdPolicy>
    with $Provider<AdPolicy> {
  AdPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adPolicyHash();

  @$internal
  @override
  $ProviderElement<AdPolicy> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdPolicy create(Ref ref) {
    return adPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdPolicy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdPolicy>(value),
    );
  }
}

String _$adPolicyHash() => r'01f9f6d5f5d7f23057bdc7c688c1fdfa74f94250';

@ProviderFor(adsController)
final adsControllerProvider = AdsControllerProvider._();

final class AdsControllerProvider
    extends $FunctionalProvider<AdsController, AdsController, AdsController>
    with $Provider<AdsController> {
  AdsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adsControllerHash();

  @$internal
  @override
  $ProviderElement<AdsController> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdsController create(Ref ref) {
    return adsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdsController>(value),
    );
  }
}

String _$adsControllerHash() => r'4a3ad040ea6f243e17be9442f758a0988ec45181';
