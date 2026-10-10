import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_settings.g.dart';

/// Music, Sound (notes + effects) and Haptics preferences (`docs/07` §4).
/// In memory until the save system (Phase 6) persists them.
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

@Riverpod(keepAlive: true)
class FeedbackSettingsController extends _$FeedbackSettingsController {
  @override
  FeedbackSettings build() => const FeedbackSettings();

  void setMusicOn({required bool value}) =>
      state = state.copyWith(musicOn: value);

  void setSoundOn({required bool value}) =>
      state = state.copyWith(soundOn: value);

  void setHapticsOn({required bool value}) =>
      state = state.copyWith(hapticsOn: value);

  void setMusicVolume(double value) =>
      state = state.copyWith(musicVolume: value.clamp(0.0, 1.0));

  void setSoundVolume(double value) =>
      state = state.copyWith(soundVolume: value.clamp(0.0, 1.0));
}
