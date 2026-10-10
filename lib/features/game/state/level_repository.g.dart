// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where level packs are read from (swapped in tests).

@ProviderFor(levelBundle)
final levelBundleProvider = LevelBundleProvider._();

/// Where level packs are read from (swapped in tests).

final class LevelBundleProvider
    extends $FunctionalProvider<AssetBundle, AssetBundle, AssetBundle>
    with $Provider<AssetBundle> {
  /// Where level packs are read from (swapped in tests).
  LevelBundleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'levelBundleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$levelBundleHash();

  @$internal
  @override
  $ProviderElement<AssetBundle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetBundle create(Ref ref) {
    return levelBundle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetBundle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetBundle>(value),
    );
  }
}

String _$levelBundleHash() => r'e2d081cecfd12c1c7263543c734ea67ddbe971c6';

/// One chapter pack (`assets/levels/ch{N}.json`), parsed once.

@ProviderFor(levelPack)
final levelPackProvider = LevelPackFamily._();

/// One chapter pack (`assets/levels/ch{N}.json`), parsed once.

final class LevelPackProvider
    extends
        $FunctionalProvider<
          AsyncValue<LevelPack>,
          LevelPack,
          FutureOr<LevelPack>
        >
    with $FutureModifier<LevelPack>, $FutureProvider<LevelPack> {
  /// One chapter pack (`assets/levels/ch{N}.json`), parsed once.
  LevelPackProvider._({
    required LevelPackFamily super.from,
    required int super.argument,
  }) : super(
         retry: _noRetry,
         name: r'levelPackProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$levelPackHash();

  @override
  String toString() {
    return r'levelPackProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LevelPack> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LevelPack> create(Ref ref) {
    final argument = this.argument as int;
    return levelPack(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LevelPackProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$levelPackHash() => r'5059d073949f1e3a0f1bea94d5ded04f55725ad9';

/// One chapter pack (`assets/levels/ch{N}.json`), parsed once.

final class LevelPackFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LevelPack>, int> {
  LevelPackFamily._()
    : super(
        retry: _noRetry,
        name: r'levelPackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// One chapter pack (`assets/levels/ch{N}.json`), parsed once.

  LevelPackProvider call(int chapter) =>
      LevelPackProvider._(argument: chapter, from: this);

  @override
  String toString() => r'levelPackProvider';
}

/// A single level of a chapter pack.

@ProviderFor(level)
final levelProvider = LevelFamily._();

/// A single level of a chapter pack.

final class LevelProvider
    extends $FunctionalProvider<AsyncValue<Level>, Level, FutureOr<Level>>
    with $FutureModifier<Level>, $FutureProvider<Level> {
  /// A single level of a chapter pack.
  LevelProvider._({
    required LevelFamily super.from,
    required LevelRef super.argument,
  }) : super(
         retry: _noRetry,
         name: r'levelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$levelHash();

  @override
  String toString() {
    return r'levelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Level> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Level> create(Ref ref) {
    final argument = this.argument as LevelRef;
    return level(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LevelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$levelHash() => r'cebaaa6d68e7f52f5ce1b1fd2746841d6e0e3f38';

/// A single level of a chapter pack.

final class LevelFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Level>, LevelRef> {
  LevelFamily._()
    : super(
        retry: _noRetry,
        name: r'levelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// A single level of a chapter pack.

  LevelProvider call(LevelRef id) => LevelProvider._(argument: id, from: this);

  @override
  String toString() => r'levelProvider';
}
