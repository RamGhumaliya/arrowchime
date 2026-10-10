/// The three mixing buses of `docs/07` §4.
enum AudioBus {
  music(0.55),
  notes(0.90),
  sfx(0.80);

  new(this.defaultVolume);

  /// Mix level before the player's sliders.
  final double defaultVolume;
}

/// A loaded sound. The backend decides what [handle] is.
class AudioClip {
  const new(this.asset, [this.handle]);

  final String asset;
  final Object? handle;
}

/// A sound that is playing (or scheduled to).
class AudioVoice {
  const new([this.token]);

  final Object? token;
}

/// The thin layer between the game's audio logic and the audio engine, so
/// the logic is testable with a fake and the engine can be swapped
/// (`CLAUDE.md` rule 11). The real one is `SoLoudBackend`.
abstract interface class AudioBackend {
  /// Starts the engine and creates the buses. May throw; the service then
  /// keeps the game silent instead of crashing.
  Future<void> init();

  /// Loads [asset]. [streamed] keeps long music out of RAM.
  Future<AudioClip> load(String asset, {bool streamed = false});

  Future<void> unload(AudioClip clip);

  /// Plays [clip] on [bus] after [delay]. [speed] 1 = normal pitch.
  AudioVoice play(
    AudioClip clip,
    AudioBus bus, {
    double volume = 1,
    double speed = 1,
    Duration delay = Duration.zero,
    bool loop = false,
  });

  void stop(AudioVoice voice);

  void setBusVolume(AudioBus bus, double volume);

  void fadeBusVolume(AudioBus bus, double volume, Duration over);

  /// Opens (true) or dulls (false) the music's high end.
  void setMusicBrightness({required bool open});

  Future<void> dispose();
}
