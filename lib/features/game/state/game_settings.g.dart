// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GameSettingsController)
final gameSettingsControllerProvider = GameSettingsControllerProvider._();

final class GameSettingsControllerProvider
    extends $NotifierProvider<GameSettingsController, GameSettings> {
  GameSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameSettingsControllerHash();

  @$internal
  @override
  GameSettingsController create() => GameSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameSettings>(value),
    );
  }
}

String _$gameSettingsControllerHash() =>
    r'85398fa9f0cde29c2aca45e7b67bdd69e46e7686';

abstract class _$GameSettingsController extends $Notifier<GameSettings> {
  GameSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<GameSettings, GameSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GameSettings, GameSettings>,
              GameSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
