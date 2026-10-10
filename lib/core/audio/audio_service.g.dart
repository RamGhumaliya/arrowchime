// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(audioBackend)
final audioBackendProvider = AudioBackendProvider._();

final class AudioBackendProvider
    extends $FunctionalProvider<AudioBackend, AudioBackend, AudioBackend>
    with $Provider<AudioBackend> {
  AudioBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioBackendHash();

  @$internal
  @override
  $ProviderElement<AudioBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioBackend create(Ref ref) {
    return audioBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioBackend>(value),
    );
  }
}

String _$audioBackendHash() => r'f57925520cfb7d82552cde9e62dc914dcc177155';

@ProviderFor(audioService)
final audioServiceProvider = AudioServiceProvider._();

final class AudioServiceProvider
    extends $FunctionalProvider<AudioService, AudioService, AudioService>
    with $Provider<AudioService> {
  AudioServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioServiceHash();

  @$internal
  @override
  $ProviderElement<AudioService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioService create(Ref ref) {
    return audioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioService>(value),
    );
  }
}

String _$audioServiceHash() => r'a13cfe6c8a86ac7318f682e34d00d798bee95ca7';
