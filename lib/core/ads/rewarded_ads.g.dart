// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewarded_ads.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rewardedAds)
final rewardedAdsProvider = RewardedAdsProvider._();

final class RewardedAdsProvider
    extends $FunctionalProvider<RewardedAds, RewardedAds, RewardedAds>
    with $Provider<RewardedAds> {
  RewardedAdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rewardedAdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rewardedAdsHash();

  @$internal
  @override
  $ProviderElement<RewardedAds> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RewardedAds create(Ref ref) {
    return rewardedAds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RewardedAds value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RewardedAds>(value),
    );
  }
}

String _$rewardedAdsHash() => r'8d19b7410aa5f13c770ef46c2edb728fe680ad0d';
