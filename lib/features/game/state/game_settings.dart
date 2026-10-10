import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_settings.g.dart';

/// Player preferences that shape the game screen. In-memory until the save
/// system (Phase 6) persists them.
class GameSettings {
  const new({
    this.leftHanded = false,
    this.relaxed = false,
    this.gridOn = false,
  });

  /// Mirrors the bottom shelf (`docs/03` §3).
  final bool leftHanded;

  /// Relaxed mode: hearts are never lost, stars capped at two.
  final bool relaxed;

  /// Stitched grid lines on the tray.
  final bool gridOn;

  GameSettings copyWith({bool? leftHanded, bool? relaxed, bool? gridOn}) =>
      GameSettings(
        leftHanded: leftHanded ?? this.leftHanded,
        relaxed: relaxed ?? this.relaxed,
        gridOn: gridOn ?? this.gridOn,
      );
}

@Riverpod(keepAlive: true)
class GameSettingsController extends _$GameSettingsController {
  @override
  GameSettings build() => const GameSettings();

  void setLeftHanded({required bool value}) =>
      state = state.copyWith(leftHanded: value);

  void setRelaxed({required bool value}) =>
      state = state.copyWith(relaxed: value);

  void toggleGrid() => state = state.copyWith(gridOn: !state.gridOn);
}
