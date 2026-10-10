import 'dart:async';

import 'package:arrowchime/core/assets.dart';
import 'package:arrowchime/core/audio/audio_backend.dart';
import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/audio/feedback_settings.dart';
import 'package:arrowchime/core/audio/sfx.dart';
import 'package:arrowchime/core/audio/soloud_backend.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

/// The game's audio (`docs/07`, `docs/05` §5): preloads a chapter, plays notes
/// and effects on their buses, loops the chapter music and ducks it.
///
/// Audio must never break the game: if the engine cannot start (no output
/// device, an emulator without sound) every call becomes a no-op.
class AudioService {
  new({required this._backend, required this._settings});

  final AudioBackend _backend;
  final FeedbackSettings Function() _settings;

  final Map<String, AudioClip> _clips = {};
  final Set<String> _chapterAssets = {};
  Future<void>? _starting;
  bool _ready = false;
  AudioVoice? _music;
  int? _musicChapter;
  double _duck = 1;

  /// How far the music drops for the last three arrows and the flourish.
  static const double duckLevel = 0.7;
  static const Duration duckFade = Duration(milliseconds: 600);

  bool get isReady => _ready;

  /// Starts the engine once; failures leave the service silent.
  Future<void> init() => _starting ??= _start();

  Future<void> _start() async {
    try {
      await _backend.init();
      _ready = true;
      applySettings();
    } on Object catch (e) {
      debugPrint('AudioService: audio unavailable ($e)');
    }
  }

  /// Loads the effects and the notes of [chapter], then starts its music.
  Future<void> enterChapter(int chapter) async {
    await init();
    if (!_ready) return;
    final sound = ChapterSound.of(chapter);
    await _loadAll([for (final sfx in Sfx.values) sfx.asset, ...sound.assets]);
    _chapterAssets
      ..clear()
      ..addAll(sound.assets);
    await startMusic(chapter);
  }

  /// Stops the music and frees the chapter's notes (effects stay loaded).
  Future<void> leaveChapter() async {
    stopMusic();
    final gone = _chapterAssets.toList();
    _chapterAssets.clear();
    for (final asset in gone) {
      final clip = _clips.remove(asset);
      if (clip != null) await _guard(() => _backend.unload(clip));
    }
  }

  Future<void> _loadAll(Iterable<String> assets) async {
    for (final asset in assets) {
      if (_clips.containsKey(asset)) continue;
      try {
        _clips[asset] = await _backend.load(asset);
      } on Object catch (e) {
        debugPrint('AudioService: could not load $asset ($e)');
      }
    }
  }

  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } on Object catch (e) {
      debugPrint('AudioService: $e');
    }
  }

  // --- music ------------------------------------------------------------------

  /// Loops the music of [chapter] (nothing if it already plays).
  Future<void> startMusic(int chapter) async {
    if (!_ready || (_music != null && _musicChapter == chapter)) return;
    stopMusic();
    final asset = AssetCatalog.musicPath(chapter);
    try {
      final clip = _clips[asset] ??= await _backend.load(asset, streamed: true);
      _music = _backend.play(clip, AudioBus.music, loop: true);
      _musicChapter = chapter;
    } on Object catch (e) {
      debugPrint('AudioService: music unavailable ($e)');
    }
  }

  void stopMusic() {
    final voice = _music;
    if (voice != null) _backend.stop(voice);
    _music = null;
    _musicChapter = null;
  }

  /// Ducks the music by 30% (or restores it) over 600 ms.
  void duck({required bool on}) {
    _duck = on ? duckLevel : 1;
    if (!_ready) return;
    _backend.fadeBusVolume(AudioBus.music, _musicLevel, duckFade);
  }

  /// Flow ×5 opens the music's high end for a moment.
  void brighten({required bool open}) {
    if (_ready) _backend.setMusicBrightness(open: open);
  }

  // --- notes and effects ------------------------------------------------------

  /// Plays note [index] of [sound] on the notes bus.
  void note(
    ChapterSound sound,
    int index, {
    double volume = 1,
    double speed = 1,
    Duration delay = Duration.zero,
  }) => _play(sound.assetOf(index), AudioBus.notes, volume, speed, delay);

  void sfx(
    Sfx sfx, {
    double volume = 1,
    double speed = 1,
    Duration delay = Duration.zero,
  }) => _play(sfx.asset, AudioBus.sfx, volume, speed, delay);

  /// The boss-clear theme of [chapter] (8-12 s).
  void bossSting(int chapter) {
    final asset = AssetCatalog.stingPath(chapter);
    final clip = _clips[asset];
    if (!_ready || clip == null || !_settings().musicOn) return;
    _backend.play(clip, AudioBus.music);
  }

  /// Loads the boss sting of [chapter] ahead of time.
  Future<void> preloadSting(int chapter) =>
      _loadAll([AssetCatalog.stingPath(chapter)]);

  void _play(
    String asset,
    AudioBus bus,
    double volume,
    double speed,
    Duration delay,
  ) {
    if (!_ready || !_settings().soundOn) return;
    final clip = _clips[asset];
    if (clip == null) return;
    try {
      _backend.play(clip, bus, volume: volume, speed: speed, delay: delay);
    } on Object catch (e) {
      debugPrint('AudioService: play failed ($e)');
    }
  }

  // --- settings ---------------------------------------------------------------

  double get _musicLevel {
    final s = _settings();
    return s.musicOn ? AudioBus.music.defaultVolume * s.musicVolume * _duck : 0;
  }

  /// Pushes the player's sliders and switches to the buses.
  void applySettings() {
    if (!_ready) return;
    final s = _settings();
    final sound = s.soundOn ? s.soundVolume : 0.0;
    _backend
      ..setBusVolume(AudioBus.music, _musicLevel)
      ..setBusVolume(AudioBus.notes, AudioBus.notes.defaultVolume * sound)
      ..setBusVolume(AudioBus.sfx, AudioBus.sfx.defaultVolume * sound);
  }

  Future<void> dispose() async {
    stopMusic();
    _clips.clear();
    if (_ready) await _guard(_backend.dispose);
    _ready = false;
  }
}

@Riverpod(keepAlive: true)
AudioBackend audioBackend(Ref ref) => SoLoudBackend();

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final service = AudioService(
    backend: ref.watch(audioBackendProvider),
    settings: () => ref.read(feedbackSettingsControllerProvider),
  );
  ref
    ..listen(
      feedbackSettingsControllerProvider,
      (_, _) => service.applySettings(),
    )
    ..onDispose(() => unawaited(service.dispose()));
  return service;
}
