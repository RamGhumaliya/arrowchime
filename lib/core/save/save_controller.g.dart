// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The player's save: one immutable [SaveData] with `update`, written to the
/// repository 500 ms after the last change and on app pause (`docs/05` §6).

@ProviderFor(SaveController)
final saveControllerProvider = SaveControllerProvider._();

/// The player's save: one immutable [SaveData] with `update`, written to the
/// repository 500 ms after the last change and on app pause (`docs/05` §6).
final class SaveControllerProvider
    extends $NotifierProvider<SaveController, SaveData> {
  /// The player's save: one immutable [SaveData] with `update`, written to the
  /// repository 500 ms after the last change and on app pause (`docs/05` §6).
  SaveControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveControllerHash();

  @$internal
  @override
  SaveController create() => SaveController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveData>(value),
    );
  }
}

String _$saveControllerHash() => r'78200aa535f3ae05376f2754f9f1045b7cc31c4c';

/// The player's save: one immutable [SaveData] with `update`, written to the
/// repository 500 ms after the last change and on app pause (`docs/05` §6).

abstract class _$SaveController extends $Notifier<SaveData> {
  SaveData build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SaveData, SaveData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SaveData, SaveData>,
              SaveData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
