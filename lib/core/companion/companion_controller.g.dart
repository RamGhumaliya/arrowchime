// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(companionController)
final companionControllerProvider = CompanionControllerProvider._();

final class CompanionControllerProvider
    extends
        $FunctionalProvider<
          CompanionController,
          CompanionController,
          CompanionController
        >
    with $Provider<CompanionController> {
  CompanionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'companionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$companionControllerHash();

  @$internal
  @override
  $ProviderElement<CompanionController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompanionController create(Ref ref) {
    return companionController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompanionController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompanionController>(value),
    );
  }
}

String _$companionControllerHash() =>
    r'a14e84c0f3a361ae4b1dc5990cf10fd95dd353c8';
