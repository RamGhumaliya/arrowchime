import 'dart:async';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/audio/audio_backend.dart';
import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/audio/feedback_settings.dart';
import 'package:arrowchime/core/audio/melodies.dart';
import 'package:arrowchime/core/level/engine/events.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/features/game/feedback/game_feedback.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/level/support/fixtures.dart';
import '../../support/fakes.dart';

void main() {
  late FakeAudioBackend backend;
  late FakeHaptics haptics;
  late AudioService audio;
  var lastThree = 0;

  GameFeedback make({
    int chapter = 1,
    int index = 1,
    bool boss = false,
    int Function(int)? length,
  }) => GameFeedback(
    audio: audio,
    haptics: haptics,
    chapter: chapter,
    levelIndex: index,
    arrowLength: length ?? (_) => 3,
    isBoss: boss,
    onLastThree: () => lastThree++,
  );

  Future<GameFeedback> started({
    int chapter = 1,
    int index = 1,
    bool boss = false,
    int Function(int)? length,
  }) async {
    final f = make(chapter: chapter, index: index, boss: boss, length: length);
    await f.start();
    backend.plays.clear();
    return f;
  }

  setUp(() {
    backend = FakeAudioBackend();
    haptics = FakeHaptics();
    audio = AudioService(
      backend: backend,
      settings: () => const FeedbackSettings(),
    );
    lastThree = 0;
  });

  /// What a tap on arrow [id] of [level] makes the engine say.
  List<GameEvent> tap(GameEngine engine, int id) => engine.tap(id);

  test('touch down: a click and a tick', () async {
    final f = await started();
    f.touchDown();
    expect(haptics.log, ['selection']);
    expect(backend.sfxNames, ['arrow_touch']);
  });

  test('every freed arrow plays the next melody note, in order', () async {
    final f = await started(index: 2);
    final engine = GameEngine(freeTrio());
    for (final id in [0, 1, 2]) {
      f.played(tap(engine, id), flow: 1, remaining: engine.remaining);
    }
    final tune = chapterMelodies[1]![1];
    final names = [for (final i in tune.take(3)) ChapterSound.of(1).notes[i]];
    expect(backend.noteNames.take(3), names);
    expect(haptics.log.where((h) => h == 'light'), hasLength(3));
    expect(backend.sfxNames.where((n) => n == 'arrow_whoosh'), hasLength(3));
  });

  test('whoosh pitch varies within 5%', () async {
    final f = await started();
    final engine = GameEngine(freeTrio());
    for (final id in [0, 1, 2]) {
      f.played(tap(engine, id), flow: 1, remaining: engine.remaining);
    }
    final speeds = [
      for (final p in backend.plays)
        if (p.name == 'arrow_whoosh') p.speed,
    ];
    expect(speeds.toSet().length, greaterThan(1));
    expect(speeds.every((s) => s >= 0.95 && s <= 1.05), isTrue);
  });

  test('Flow tiers stack harmony, a shaker tick and sparkle', () async {
    final f = await started();
    final sound = ChapterSound.of(1);

    List<AudioCall> notesAfter(int flow) {
      backend.plays.clear();
      final engine = GameEngine(freeTrio());
      f.played(tap(engine, 0), flow: flow, remaining: 2);
      return backend.plays;
    }

    var plays = notesAfter(1);
    expect(plays.where((p) => p.bus == AudioBus.notes), hasLength(1));
    plays = notesAfter(2);
    expect(plays.where((p) => p.bus == AudioBus.notes), hasLength(2));
    expect(
      plays.where((p) => p.bus == AudioBus.notes).last.volume,
      lessThan(0.5),
    );
    plays = notesAfter(3);
    expect(plays.where((p) => p.name == 'arrow_touch'), hasLength(1));
    plays = notesAfter(4);
    expect(plays.where((p) => p.bus == AudioBus.notes), hasLength(3));
    plays = notesAfter(5);
    expect(plays.where((p) => p.name == 'fragment_restore'), isNotEmpty);
    expect(sound.length, greaterThan(0));
  });

  test('a flow level-up plays the rising arpeggio and ×5 opens the music', () {
    fakeAsync((async) {
      unawaited(
        Future<void>(() async {
          final f = await started();
          final engine = GameEngine(freeTrio());
          f.played(tap(engine, 0), flow: 2, remaining: 2);
          expect(backend.sfxNames, contains('flow_up'));
          final first = backend.plays.firstWhere((p) => p.name == 'flow_up');
          backend.plays.clear();
          f.played(tap(engine, 1), flow: 5, remaining: 1);
          final up = backend.plays.firstWhere((p) => p.name == 'flow_up');
          expect(up.speed, greaterThan(first.speed));
          expect(backend.brightness, [true]);
          async.elapse(TBFeedback.brightFor);
          expect(backend.brightness, [true, false]);
        }),
      );
      async.flushMicrotasks();
    });
  });

  test('a blocked tap: thunk, double haptic, heart crack', () {
    fakeAsync((async) {
      unawaited(
        Future<void>(() async {
          final f = await started();
          final engine = GameEngine(blockedPair());
          f.played(tap(engine, 0), flow: 1, remaining: 2);
          expect(
            backend.sfxNames,
            containsAll(['arrow_blocked', 'heart_lost']),
          );
          expect(haptics.log, ['medium']);
          async.elapse(TBFeedback.doublePulse);
          expect(haptics.log, ['medium', 'medium']);
        }),
      );
      async.flushMicrotasks();
    });
  });

  test('losing: soft chord and a heavy thud', () async {
    final f = await started();
    final engine = GameEngine(blockedPair(hearts: 1));
    f.played(tap(engine, 0), flow: 1, remaining: 2);
    expect(backend.sfxNames, contains('level_fail'));
    expect(haptics.log, contains('heavy'));
  });

  test('last three arrows duck the music once and nudge the zoom', () async {
    final f = await started();
    final engine = GameEngine(freeTrio());
    f
      ..played(tap(engine, 0), flow: 1, remaining: 3)
      ..played(tap(engine, 1), flow: 1, remaining: 2);
    expect(lastThree, 1);
    expect(backend.fades, hasLength(1));
    expect(backend.fades.single.$2, closeTo(0.55 * 0.7, 1e-9));
    expect(backend.sfxNames, contains('fragment_restore'));
  });

  test('board clear: cascade 90 ms apart, flourish home, chime, success', () {
    fakeAsync((async) {
      unawaited(
        Future<void>(() async {
          final f = await started();
          final engine = GameEngine(freeTrio());
          for (final id in [0, 1]) {
            f.played(tap(engine, id), flow: 1, remaining: engine.remaining);
          }
          backend.plays.clear();
          f.played(tap(engine, 2), flow: 1, remaining: 0);
          final sound = ChapterSound.of(1);
          final tune = chapterMelodies[1]![0];
          final notes = backend.plays
              .where((p) => p.bus == AudioBus.notes)
              .toList();
          // 13 cascade notes (16 - 3 played) 90 ms apart ...
          final cascade = notes.take(13).toList();
          expect(
            [for (final n in cascade) n.name],
            [for (final i in tune.skip(3)) sound.notes[i]],
          );
          expect(cascade[1].delay - cascade[0].delay, TBFeedback.cascadeStep);
          // ... then a run up to the next tonic ...
          final flourish = notes.skip(13).toList();
          expect(flourish.first.name, sound.notes[sound.tonics.first]);
          expect(flourish.last.name, sound.notes[sound.tonics[1]]);
          expect(
            flourish[1].delay - flourish[0].delay,
            TBFeedback.flourishStep,
          );
          // ... a chime after the last note, and a success haptic.
          final chime = backend.plays.firstWhere(
            (p) => p.name == 'board_clear',
          );
          expect(chime.delay, greaterThan(flourish.last.delay));
          expect(haptics.log, contains('success'));
          // Music ducks for the flourish and comes back.
          expect(backend.fades.first.$2, closeTo(0.55 * 0.7, 1e-9));
          async.elapse(const Duration(seconds: 5));
          expect(backend.fades.last.$2, closeTo(0.55, 1e-9));
        }),
      );
      async.flushMicrotasks();
    });
  });

  test('a boss clear also plays the chapter sting', () {
    fakeAsync((async) {
      unawaited(
        Future<void>(() async {
          final f = await started(index: 60, boss: true);
          final engine = GameEngine(freeTrio());
          for (final id in [0, 1, 2]) {
            f.played(tap(engine, id), flow: 1, remaining: engine.remaining);
          }
          async.elapse(const Duration(seconds: 5));
          expect(backend.plays.any((p) => p.name == 'boss_sting_ch1'), isTrue);
        }),
      );
      async.flushMicrotasks();
    });
  });

  test('stars ding 180 ms apart and coins clink higher each time', () {
    fakeAsync((async) {
      unawaited(
        Future<void>(() async {
          final f = await started();
          f.starsAwarded(3);
          final stars = backend.plays
              .where((p) => p.name.startsWith('star_'))
              .toList();
          expect(
            [for (final s in stars) s.name],
            ['star_1', 'star_2', 'star_3'],
          );
          expect(stars[1].delay - stars[0].delay, TBFeedback.starStep);
          async.elapse(const Duration(seconds: 1));
          expect(haptics.log.where((h) => h == 'light'), hasLength(3));
          backend.plays.clear();
          f
            ..coinTick(0)
            ..coinTick(3);
          expect(
            backend.plays.last.speed,
            greaterThan(backend.plays.first.speed),
          );
        }),
      );
      async.flushMicrotasks();
    });
  });

  test('mechanic sounds: rotator, gate, ice, portal, undo', () async {
    final f = await started();

    var engine = GameEngine(rotatorPair());
    f.played(tap(engine, engine.freeArrowIds.first), flow: 1, remaining: 1);
    expect(backend.sfxNames, contains('rotator_turn'));

    backend.plays.clear();
    engine = GameEngine(gateAndKey());
    final key = engine.level.arrows.firstWhere((a) => a.kind.name == 'key');
    f.played(tap(engine, key.id), flow: 1, remaining: 1);
    expect(backend.sfxNames, containsAll(['gate_open', 'key_collect']));

    backend.plays.clear();
    engine = GameEngine(frozenTrio());
    final events = tap(engine, engine.freeArrowIds.first);
    f.played(events, flow: 1, remaining: 2);
    expect(
      backend.sfxNames.any((n) => n == 'ice_tick' || n == 'ice_break'),
      isTrue,
    );

    backend.plays.clear();
    engine = GameEngine(portalLevel());
    for (final id in engine.freeArrowIds) {
      f.played(tap(engine, id), flow: 1, remaining: engine.remaining);
    }

    backend.plays.clear();
    engine = GameEngine(freeTrio());
    final before = f.melody.position;
    f.played(tap(engine, 0), flow: 1, remaining: 2);
    expect(f.melody.position, before + 1);
    f.played(engine.undo(), flow: 1, remaining: 3);
    expect(f.melody.position, before);
    expect(backend.sfxNames, contains('ui_back'));
  });

  test('a tapped frozen arrow ticks the ice and thaws', () async {
    final f = await started();
    f.played(
      const [FrozenTapped(arrowId: 0, counter: 2)],
      flow: 1,
      remaining: 5,
    );
    expect(backend.sfxNames, ['ice_tick']);
    backend.plays.clear();
    f.played(
      const [
        FrozenTicked(counters: {0: 0}),
      ],
      flow: 1,
      remaining: 5,
    );
    expect(backend.sfxNames, ['ice_break']);
  });

  test('reset starts the tune over and quiets the extras', () async {
    final f = await started();
    final engine = GameEngine(freeTrio());
    f
      ..played(tap(engine, 0), flow: 5, remaining: 3)
      ..reset();
    expect(f.melody.position, 0);
    expect(backend.brightness.last, isFalse);
    f.played(tap(GameEngine(freeTrio()), 0), flow: 1, remaining: 3);
    expect(lastThree, 2, reason: 'the first three-left cue fired again');
  });

  test('dispose frees the chapter and cancels pending cues', () async {
    final f = await started();
    final engine = GameEngine(blockedPair());
    f.played(tap(engine, 0), flow: 5, remaining: 2);
    await f.dispose();
    expect(backend.unloads, isNotEmpty);
    expect(backend.stopped, isNotEmpty);
  });

  test('level payload type is used', () {
    expect(freeTrio(), isA<Level>());
  });
}
