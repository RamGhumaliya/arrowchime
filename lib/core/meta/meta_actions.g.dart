// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meta_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(metaActions)
final metaActionsProvider = MetaActionsProvider._();

final class MetaActionsProvider
    extends $FunctionalProvider<MetaActions, MetaActions, MetaActions>
    with $Provider<MetaActions> {
  MetaActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metaActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metaActionsHash();

  @$internal
  @override
  $ProviderElement<MetaActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MetaActions create(Ref ref) {
    return metaActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetaActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetaActions>(value),
    );
  }
}

String _$metaActionsHash() => r'b2610dde77f7ee687854ea8f5f8f659eafd5bed0';
