import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_settings.g.dart';

/// Player preferences that shape the game screen (`docs/03` §8), backed by
/// the save.
class GameSettings {
  const new({
    this.leftHanded = false,
    this.relaxed = false,
    this.gridOn = false,
    this.reduceMotion = 'system',
    this.colorBlind = 'off',
  });

  /// Mirrors the bottom shelf (`docs/03` §3).
  final bool leftHanded;

  /// Relaxed mode: hearts are never lost, stars capped at two.
  final bool relaxed;

  /// Stitched grid lines on the tray.
  final bool gridOn;

  /// `system` follows the OS; `on` always reduces motion.
  final String reduceMotion;

  /// `off`, `deutan` or `tritan`.
  final String colorBlind;

  GameSettings copyWith({
    bool? leftHanded,
    bool? relaxed,
    bool? gridOn,
    String? reduceMotion,
    String? colorBlind,
  }) => GameSettings(
    leftHanded: leftHanded ?? this.leftHanded,
    relaxed: relaxed ?? this.relaxed,
    gridOn: gridOn ?? this.gridOn,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    colorBlind: colorBlind ?? this.colorBlind,
  );
}

@Riverpod(keepAlive: true)
class GameSettingsController extends _$GameSettingsController {
  @override
  GameSettings build() {
    final s = ref.watch(saveControllerProvider.select((d) => d.settings));
    return GameSettings(
      leftHanded: s.leftHanded,
      relaxed: s.relaxed,
      gridOn: s.gridOn,
      reduceMotion: s.reduceMotion,
      colorBlind: s.colorBlind,
    );
  }

  void _set(SaveSettings Function(SaveSettings s) change) => ref
      .read(saveControllerProvider.notifier)
      .update((d) => d.copyWith(settings: change(d.settings)));

  void setLeftHanded({required bool value}) =>
      _set((s) => s.copyWith(leftHanded: value));

  void setRelaxed({required bool value}) =>
      _set((s) => s.copyWith(relaxed: value));

  void toggleGrid() => _set((s) => s.copyWith(gridOn: !s.gridOn));

  /// `system` or `on`.
  void setReduceMotion(String value) =>
      _set((s) => s.copyWith(reduceMotion: value));

  /// `off`, `deutan` or `tritan`.
  void setColorBlind(String value) =>
      _set((s) => s.copyWith(colorBlind: value));
}
