// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteConfig)
final remoteConfigProvider = RemoteConfigProvider._();

final class RemoteConfigProvider
    extends
        $FunctionalProvider<
          RemoteConfigService,
          RemoteConfigService,
          RemoteConfigService
        >
    with $Provider<RemoteConfigService> {
  RemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigHash();

  @$internal
  @override
  $ProviderElement<RemoteConfigService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteConfigService create(Ref ref) {
    return remoteConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteConfigService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteConfigService>(value),
    );
  }
}

String _$remoteConfigHash() => r'e2c798a0bc76d0526c116046a9709020f50755a2';
