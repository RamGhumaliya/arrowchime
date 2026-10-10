import 'dart:async';

import 'package:arrowchime/core/audio/audio_backend.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// [AudioBackend] on `flutter_soloud` (`docs/05` §5): three mixing buses,
/// scheduled playback for the clear cascade, a low-pass filter on the music.
class SoLoudBackend implements AudioBackend {
  final Map<AudioBus, Bus> _buses = {};

  /// Music is dull until Flow ×5 opens it.
  static const double _closedHz = 3200;
  static const double _openHz = 16000;

  /// Loud play at 10 taps a second stacks note, whoosh and harmony voices;
  /// the default limit of 16 would silently drop sounds.
  static const int _maxVoices = 64;

  @override
  Future<void> init() async {
    // Mix politely with the player's own music (docs/05 §5): ambient on iOS,
    // a game audio-focus request that does not pause others on Android.
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.game,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ),
    );
    await SoLoud.instance.init();
    SoLoud.instance.setMaxActiveVoiceCount(_maxVoices);
    for (final bus in AudioBus.values) {
      _buses[bus] = SoLoud.instance.createMixingBus(name: bus.name)
        ..playOnEngine(volume: bus.defaultVolume);
    }
    final music = _buses[AudioBus.music]!;
    music.filters.biquadFilter.activate();
    _setFilter(music, _closedHz);
  }

  void _setFilter(Bus music, double hz) {
    final handle = music.soundHandle;
    if (handle == null) return;
    music.filters.biquadFilter.type(soundHandle: handle).value = 0;
    music.filters.biquadFilter.frequency(soundHandle: handle).value = hz;
  }

  @override
  Future<AudioClip> load(String asset, {bool streamed = false}) async {
    final source = await SoLoud.instance.loadAsset(
      asset,
      mode: streamed ? LoadMode.disk : LoadMode.memory,
    );
    return AudioClip(asset, source);
  }

  @override
  Future<void> unload(AudioClip clip) async {
    final source = clip.handle;
    if (source is AudioSource && SoLoud.instance.isInitialized) {
      await SoLoud.instance.disposeSource(source);
    }
  }

  @override
  AudioVoice play(
    AudioClip clip,
    AudioBus bus, {
    double volume = 1,
    double speed = 1,
    Duration delay = Duration.zero,
    bool loop = false,
  }) {
    final source = clip.handle! as AudioSource;
    final target = _buses[bus]!;
    final SoundHandle handle;
    if (delay > Duration.zero) {
      handle = target.playScheduled(
        source,
        SoLoud.instance.getEngineTime() + delay,
        volume: volume,
        scale: speed,
      );
    } else {
      handle = target.play(source, volume: volume, scale: speed, looping: loop);
    }
    if (loop) SoLoud.instance.setProtectVoice(handle, true);
    return AudioVoice(handle);
  }

  @override
  void stop(AudioVoice voice) {
    final handle = voice.token;
    if (handle is SoundHandle) unawaited(SoLoud.instance.stop(handle));
  }

  @override
  void setBusVolume(AudioBus bus, double volume) {
    final handle = _buses[bus]?.soundHandle;
    if (handle != null) SoLoud.instance.setVolume(handle, volume);
  }

  @override
  void fadeBusVolume(AudioBus bus, double volume, Duration over) {
    final handle = _buses[bus]?.soundHandle;
    if (handle != null) SoLoud.instance.fadeVolume(handle, volume, over);
  }

  @override
  void setMusicBrightness({required bool open}) {
    final music = _buses[AudioBus.music];
    if (music != null) _setFilter(music, open ? _openHz : _closedHz);
  }

  @override
  Future<void> dispose() async {
    for (final bus in _buses.values) {
      bus.dispose();
    }
    _buses.clear();
    if (SoLoud.instance.isInitialized) await SoLoud.instance.deinitAsync();
  }
}
