import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_settings.g.dart';

/// Music, Sound (notes + effects) and Haptics preferences (`docs/07` §4).
class FeedbackSettings {
  const new({
    this.musicOn = true,
    this.soundOn = true,
    this.hapticsOn = true,
    this.musicVolume = 1,
    this.soundVolume = 1,
  });

  final bool musicOn;
  final bool soundOn;
  final bool hapticsOn;

  /// 0-1 sliders, applied on top of each bus's default level.
  final double musicVolume;
  final double soundVolume;

  FeedbackSettings copyWith({
    bool? musicOn,
    bool? soundOn,
    bool? hapticsOn,
    double? musicVolume,
    double? soundVolume,
  }) => FeedbackSettings(
    musicOn: musicOn ?? this.musicOn,
    soundOn: soundOn ?? this.soundOn,
    hapticsOn: hapticsOn ?? this.hapticsOn,
    musicVolume: musicVolume ?? this.musicVolume,
    soundVolume: soundVolume ?? this.soundVolume,
  );
}

/// Backed by the save (`SaveData.settings`), so the choices survive a restart.
@Riverpod(keepAlive: true)
class FeedbackSettingsController extends _$FeedbackSettingsController {
  @override
  FeedbackSettings build() {
    final s = ref.watch(saveControllerProvider.select((d) => d.settings));
    return FeedbackSettings(
      musicOn: s.musicOn,
      soundOn: s.soundOn,
      hapticsOn: s.hapticsOn,
      musicVolume: s.musicVolume,
      soundVolume: s.soundVolume,
    );
  }

  void _set(SaveSettings Function(SaveSettings s) change) => ref
      .read(saveControllerProvider.notifier)
      .update((d) => d.copyWith(settings: change(d.settings)));

  void setMusicOn({required bool value}) =>
      _set((s) => s.copyWith(musicOn: value));

  void setSoundOn({required bool value}) =>
      _set((s) => s.copyWith(soundOn: value));

  void setHapticsOn({required bool value}) =>
      _set((s) => s.copyWith(hapticsOn: value));

  void setMusicVolume(double value) =>
      _set((s) => s.copyWith(musicVolume: value.clamp(0.0, 1.0)));

  void setSoundVolume(double value) =>
      _set((s) => s.copyWith(soundVolume: value.clamp(0.0, 1.0)));
}
