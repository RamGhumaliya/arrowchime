import 'package:arrowchime/core/assets.dart';
import 'package:arrowchime/core/audio/audio_backend.dart';
import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/audio/feedback_settings.dart';
import 'package:arrowchime/core/audio/melodies.dart';
import 'package:arrowchime/core/audio/melody_player.dart';
import 'package:arrowchime/core/audio/sfx.dart';
import 'package:arrowchime/core/haptics/haptics_service.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('chapter sounds and melodies (docs/07 §1)', () {
    test('notes and instruments match the asset catalog', () {
      for (final s in ChapterSound.all) {
        expect(s.instrument, AudioCatalog.chapterInstrument[s.chapter]);
        expect(s.notes, AudioCatalog.instrumentNotes[s.instrument]);
        expect(s.assets, hasLength(s.notes.length));
        expect(s.tonics, hasLength(3));
      }
      expect(ChapterSound.of(0), ChapterSound.all.first);
      expect(ChapterSound.of(9), ChapterSound.all.last);
    });

    test('12 melodies per chapter, 16 valid notes, resolving to the tonic', () {
      expect(chapterMelodies.keys, [1, 2, 3, 4, 5]);
      for (final entry in chapterMelodies.entries) {
        final s = ChapterSound.of(entry.key);
        expect(entry.value, hasLength(12));
        for (final m in entry.value) {
          expect(m.length, greaterThanOrEqualTo(16));
          expect(m.every((i) => i >= 0 && i < s.length), isTrue);
          expect(s.tonics, contains(m.last), reason: 'ch${entry.key} $m');
          // Stepwise-ish: no leap bigger than a sixth between notes.
          for (var i = 1; i < m.length; i++) {
            expect((m[i] - m[i - 1]).abs(), lessThanOrEqualTo(6));
          }
        }
      }
    });

    test('melodies are distinct and strong beats use chord tones', () {
      for (final entry in chapterMelodies.entries) {
        final s = ChapterSound.of(entry.key);
        expect(
          {for (final m in entry.value) m.join(',')}.length,
          greaterThan(8),
        );
        if (s.pentatonic) continue;
        for (final m in entry.value) {
          for (var i = 0; i < 16; i += 4) {
            expect(s.isChordTone(m[i]), isTrue, reason: 'ch${entry.key} $m');
          }
        }
      }
    });

    test('every sample file exists', () {
      for (final s in ChapterSound.all) {
        for (final a in s.assets) {
          expect(AssetCatalog.all().any((e) => e.path == a), isTrue, reason: a);
        }
      }
    });
  });

  group('MelodyPlayer', () {
    test('plays the melody in order, wrapping around', () {
      final p = MelodyPlayer.forLevel(1, 3);
      final tune = chapterMelodies[1]![2];
      final heard = [for (var i = 0; i < 20; i++) p.next().index];
      expect(heard.take(16), tune);
      expect(heard.skip(16), tune.take(4));
      expect(p.position, 20);
    });

    test('levels rotate through the 12 melodies', () {
      expect(
        MelodyPlayer.forLevel(2, 13).melody,
        MelodyPlayer.forLevel(2, 1).melody,
      );
      expect(
        MelodyPlayer.forLevel(2, 2).melody,
        isNot(MelodyPlayer.forLevel(2, 1).melody),
      );
    });

    test('Flow adds a fifth from x2, a third from x4, sparkle at x5', () {
      final p = MelodyPlayer.forLevel(1, 1);
      final s = p.sound;
      final base = p.melody.first;
      expect(p.harmonyOf(base, 1), isEmpty);
      expect(p.harmonyOf(base, 2), [base + s.fifthSteps]);
      expect(p.harmonyOf(base, 3), [base + s.fifthSteps]);
      expect(p.harmonyOf(base, 4), [base + s.fifthSteps, base + s.thirdSteps]);
      expect(p.harmonyOf(s.length - 1, 5), isEmpty); // nothing above the top
      expect(p.next(flow: 5).sparkle, isTrue);
      expect(p.next().sparkle, isFalse);
    });

    test('long arrows ring heavier', () {
      final p = MelodyPlayer.forLevel(1, 1);
      expect(p.next(arrowLength: 8).heavy, isFalse);
      expect(p.next(arrowLength: 9).heavy, isTrue);
    });

    test('rewind and reset', () {
      final p = MelodyPlayer.forLevel(1, 1)..rewind();
      expect(p.position, 0);
      p
        ..next()
        ..next()
        ..rewind();
      expect(p.position, 1);
      p.reset();
      expect(p.position, 0);
    });

    test('cascade plays what is left, the flourish resolves home', () {
      final p = MelodyPlayer.forLevel(3, 1);
      for (var i = 0; i < 6; i++) {
        p.next();
      }
      final rest = p.cascade();
      expect(rest, p.melody.sublist(6));
      expect(p.position, 16);
      expect(p.cascade(), p.melody, reason: 'a full loop when none is left');
      final run = p.flourish();
      expect(run.first, p.sound.tonics.first);
      expect(run.last, p.sound.tonics[1]);
      expect([
        for (var i = 1; i < run.length; i++) run[i] - run[i - 1],
      ], everyElement(1));
    });
  });

  group('Sfx', () {
    test('ids match the catalog and star() picks the ding', () {
      expect([for (final s in Sfx.values) s.id], AudioCatalog.sfxIds);
      for (final s in Sfx.values) {
        expect(s.asset, AssetCatalog.sfxPath(s.id));
      }
      expect(Sfx.star(1), Sfx.star1);
      expect(Sfx.star(2), Sfx.star2);
      expect(Sfx.star(3), Sfx.star3);
    });
  });

  group('AudioService', () {
    late FakeAudioBackend backend;
    late FeedbackSettings settings;
    late AudioService service;

    setUp(() {
      backend = FakeAudioBackend();
      settings = const FeedbackSettings();
      service = AudioService(backend: backend, settings: () => settings);
    });

    test(
      'entering a chapter loads effects, notes and starts looping music',
      () async {
        await service.enterChapter(1);
        expect(service.isReady, isTrue);
        expect(
          backend.loads,
          containsAll([
            Sfx.arrowBlocked.asset,
            ChapterSound.of(1).assetOf(0),
            AssetCatalog.musicPath(1),
          ]),
        );
        final music = backend.plays.single;
        expect(music.loop, isTrue);
        expect(music.bus, AudioBus.music);
        // Entering again does not restart the music or reload.
        final loads = backend.loads.length;
        await service.enterChapter(1);
        expect(backend.plays, hasLength(1));
        expect(backend.loads, hasLength(loads));
      },
    );

    test('mix defaults of docs/07 §4', () async {
      await service.init();
      expect(backend.busVolume[AudioBus.music], closeTo(0.55, 1e-9));
      expect(backend.busVolume[AudioBus.notes], closeTo(0.90, 1e-9));
      expect(backend.busVolume[AudioBus.sfx], closeTo(0.80, 1e-9));
    });

    test('settings scale or mute the buses', () async {
      await service.init();
      settings = const FeedbackSettings(musicVolume: 0.5, soundVolume: 0.5);
      service.applySettings();
      expect(backend.busVolume[AudioBus.music], closeTo(0.275, 1e-9));
      expect(backend.busVolume[AudioBus.notes], closeTo(0.45, 1e-9));
      settings = const FeedbackSettings(musicOn: false, soundOn: false);
      service.applySettings();
      expect(backend.busVolume[AudioBus.music], 0);
      expect(backend.busVolume[AudioBus.sfx], 0);
    });

    test('sound off plays no notes or effects', () async {
      await service.enterChapter(1);
      backend.plays.clear();
      settings = const FeedbackSettings(soundOn: false);
      service
        ..note(ChapterSound.of(1), 0)
        ..sfx(Sfx.coin);
      expect(backend.plays, isEmpty);
      settings = const FeedbackSettings();
      service
        ..note(ChapterSound.of(1), 0, volume: 0.5, speed: 1.1)
        ..sfx(Sfx.coin, delay: const Duration(milliseconds: 90));
      expect(backend.noteNames, ['C4']);
      expect(backend.sfxNames, ['coin']);
      expect(backend.plays.last.delay, const Duration(milliseconds: 90));
      expect(backend.plays.first.speed, 1.1);
    });

    test('unloaded sounds are skipped quietly', () async {
      await service.init();
      service.sfx(Sfx.coin);
      expect(backend.plays, isEmpty);
    });

    test(
      'ducking fades the music by 30% and restores it over 600 ms',
      () async {
        await service.init();
        service.duck(on: true);
        expect(backend.fades.last.$1, AudioBus.music);
        expect(backend.fades.last.$2, closeTo(0.55 * 0.7, 1e-9));
        expect(backend.fades.last.$3, const Duration(milliseconds: 600));
        service.duck(on: false);
        expect(backend.fades.last.$2, closeTo(0.55, 1e-9));
      },
    );

    test('brighten forwards to the backend', () async {
      await service.init();
      service
        ..brighten(open: true)
        ..brighten(open: false);
      expect(backend.brightness, [true, false]);
    });

    test('leaving a chapter stops the music and frees its notes', () async {
      await service.enterChapter(2);
      await service.leaveChapter();
      expect(backend.stopped, hasLength(1));
      expect(backend.unloads, containsAll(ChapterSound.of(2).assets));
      expect(backend.unloads, isNot(contains(Sfx.coin.asset)));
    });

    test('a failing engine leaves the game silent, not broken', () async {
      final broken = FakeAudioBackend(failInit: true);
      final s = AudioService(backend: broken, settings: () => settings);
      await s.enterChapter(1);
      expect(s.isReady, isFalse);
      s
        ..note(ChapterSound.of(1), 0)
        ..sfx(Sfx.coin)
        ..duck(on: true)
        ..brighten(open: true)
        ..bossSting(1)
        ..applySettings();
      await s.startMusic(1);
      await s.dispose();
      expect(broken.plays, isEmpty);
    });

    test('boss sting plays on the music bus once loaded', () async {
      await service.enterChapter(1);
      await service.preloadSting(1);
      backend.plays.clear();
      service.bossSting(1);
      expect(backend.plays.single.asset, AssetCatalog.stingPath(1));
      settings = const FeedbackSettings(musicOn: false);
      service.bossSting(1);
      expect(backend.plays, hasLength(1));
    });

    test('dispose releases the backend', () async {
      await service.enterChapter(1);
      await service.dispose();
      expect(backend.disposed, isTrue);
      expect(service.isReady, isFalse);
    });

    test('the provider wires settings to the buses', () async {
      final c = ProviderContainer(
        overrides: [
          saveDebounceProvider.overrideWithValue(null),
          audioBackendProvider.overrideWithValue(backend),
        ],
      );
      addTearDown(c.dispose);
      final s = c.read(audioServiceProvider);
      await s.init();
      c.read(feedbackSettingsControllerProvider.notifier).setMusicVolume(0);
      await c.pump(); // Riverpod propagates changes asynchronously
      expect(c.read(feedbackSettingsControllerProvider).musicVolume, 0);
      expect(backend.busVolume[AudioBus.music], 0);
    });
  });

  group('FeedbackSettings', () {
    test('every switch and slider', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(feedbackSettingsControllerProvider.notifier)
        ..setMusicOn(value: false)
        ..setSoundOn(value: false)
        ..setHapticsOn(value: false)
        ..setMusicVolume(2)
        ..setSoundVolume(-1);
      final s = c.read(feedbackSettingsControllerProvider);
      expect(s.musicOn, isFalse);
      expect(s.soundOn, isFalse);
      expect(s.hapticsOn, isFalse);
      expect(s.musicVolume, 1);
      expect(s.soundVolume, 0);
    });
  });

  group('PlatformHaptics', () {
    final calls = <String>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              calls.add(call.arguments as String);
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('maps each kind to the platform call', () async {
      final h = PlatformHaptics(enabled: () => true)
        ..selection()
        ..light()
        ..medium()
        ..heavy();
      await Future<void>.delayed(Duration.zero);
      expect(calls, [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
      calls.clear();
      h.success();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(calls, [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
      ]);
    });

    test('switched off, nothing happens', () async {
      PlatformHaptics(enabled: () => false)
        ..selection()
        ..heavy();
      await Future<void>.delayed(Duration.zero);
      expect(calls, isEmpty);
    });

    test('the provider follows the Haptics setting', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c
          .read(feedbackSettingsControllerProvider.notifier)
          .setHapticsOn(value: false);
      c.read(hapticsProvider).light();
      await Future<void>.delayed(Duration.zero);
      expect(calls, isEmpty);
    });
  });
}
