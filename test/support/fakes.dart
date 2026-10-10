import 'package:arrowchime/core/audio/audio_backend.dart';
import 'package:arrowchime/core/haptics/haptics_service.dart';

/// One thing the fake backend was asked to do.
class AudioCall {
  const new(
    this.asset,
    this.bus, {
    this.volume = 1,
    this.speed = 1,
    this.delay = Duration.zero,
    this.loop = false,
  });

  final String asset;
  final AudioBus bus;
  final double volume;
  final double speed;
  final Duration delay;
  final bool loop;

  /// The file name without folders and extension (`C4`, `arrow_blocked`).
  String get name => asset.split('/').last.split('.').first;

  @override
  String toString() => '$bus:$name@${delay.inMilliseconds}ms';
}

/// Records everything instead of making sound.
class FakeAudioBackend implements AudioBackend {
  new({this.failInit = false});

  final bool failInit;
  final List<AudioCall> plays = [];
  final List<String> loads = [];
  final List<String> unloads = [];
  final Map<AudioBus, double> busVolume = {};
  final List<(AudioBus, double, Duration)> fades = [];
  final List<bool> brightness = [];
  final List<AudioVoice> stopped = [];
  bool initialized = false;
  bool disposed = false;

  @override
  Future<void> init() async {
    if (failInit) throw StateError('no audio device');
    initialized = true;
  }

  @override
  Future<AudioClip> load(String asset, {bool streamed = false}) async {
    loads.add(asset);
    return AudioClip(asset);
  }

  @override
  Future<void> unload(AudioClip clip) async => unloads.add(clip.asset);

  @override
  AudioVoice play(
    AudioClip clip,
    AudioBus bus, {
    double volume = 1,
    double speed = 1,
    Duration delay = Duration.zero,
    bool loop = false,
  }) {
    plays.add(
      AudioCall(
        clip.asset,
        bus,
        volume: volume,
        speed: speed,
        delay: delay,
        loop: loop,
      ),
    );
    return AudioVoice(plays.length);
  }

  @override
  void stop(AudioVoice voice) => stopped.add(voice);

  @override
  void setBusVolume(AudioBus bus, double volume) => busVolume[bus] = volume;

  @override
  void fadeBusVolume(AudioBus bus, double volume, Duration over) =>
      fades.add((bus, volume, over));

  @override
  void setMusicBrightness({required bool open}) => brightness.add(open);

  @override
  Future<void> dispose() async => disposed = true;

  /// Names of the played notes (not effects, not music), in order.
  List<String> get noteNames => [
    for (final p in plays)
      if (p.bus == AudioBus.notes) p.name,
  ];

  List<String> get sfxNames => [
    for (final p in plays)
      if (p.bus == AudioBus.sfx) p.name,
  ];
}

/// Records haptic calls.
class FakeHaptics implements HapticsService {
  final List<String> log = [];

  @override
  void selection() => log.add('selection');

  @override
  void light() => log.add('light');

  @override
  void medium() => log.add('medium');

  @override
  void heavy() => log.add('heavy');

  @override
  void success() => log.add('success');
}
