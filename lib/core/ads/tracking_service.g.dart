// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(trackingService)
final trackingServiceProvider = TrackingServiceProvider._();

final class TrackingServiceProvider
    extends
        $FunctionalProvider<TrackingService, TrackingService, TrackingService>
    with $Provider<TrackingService> {
  TrackingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingServiceHash();

  @$internal
  @override
  $ProviderElement<TrackingService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrackingService create(Ref ref) {
    return trackingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingService>(value),
    );
  }
}

String _$trackingServiceHash() => r'af8ce487b1f9880313b68a204153997fb73a7070';
