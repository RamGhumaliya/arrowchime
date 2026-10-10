// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One attempt at one level: owns the engine, the Flow streak and the hint
/// cache, pays and charges the wallet, and publishes [events] for Flame.

@ProviderFor(GameSession)
final gameSessionProvider = GameSessionFamily._();

/// One attempt at one level: owns the engine, the Flow streak and the hint
/// cache, pays and charges the wallet, and publishes [events] for Flame.
final class GameSessionProvider
    extends $NotifierProvider<GameSession, SessionState> {
  /// One attempt at one level: owns the engine, the Flow streak and the hint
  /// cache, pays and charges the wallet, and publishes [events] for Flame.
  GameSessionProvider._({
    required GameSessionFamily super.from,
    required LevelRef super.argument,
  }) : super(
         retry: null,
         name: r'gameSessionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameSessionHash();

  @override
  String toString() {
    return r'gameSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GameSession create() => GameSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GameSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameSessionHash() => r'3721ac00851f4a2a52cca66cf62aa55454cacd1b';

/// One attempt at one level: owns the engine, the Flow streak and the hint
/// cache, pays and charges the wallet, and publishes [events] for Flame.

final class GameSessionFamily extends $Family
    with
        $ClassFamilyOverride<
          GameSession,
          SessionState,
          SessionState,
          SessionState,
          LevelRef
        > {
  GameSessionFamily._()
    : super(
        retry: null,
        name: r'gameSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One attempt at one level: owns the engine, the Flow streak and the hint
  /// cache, pays and charges the wallet, and publishes [events] for Flame.

  GameSessionProvider call(LevelRef levelRef) =>
      GameSessionProvider._(argument: levelRef, from: this);

  @override
  String toString() => r'gameSessionProvider';
}

/// One attempt at one level: owns the engine, the Flow streak and the hint
/// cache, pays and charges the wallet, and publishes [events] for Flame.

abstract class _$GameSession extends $Notifier<SessionState> {
  late final _$args = ref.$arg as LevelRef;
  LevelRef get levelRef => _$args;

  SessionState build(LevelRef levelRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
