import 'dart:convert';
import 'dart:io';

import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/save/save_migrations.dart';
import 'package:arrowchime/core/save/save_repository.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  group('SaveData', () {
    test('a new player', () {
      final d = SaveData.initial();
      expect(d.schemaVersion, currentSaveSchema);
      expect(d.coins, 0);
      expect(d.currentLevel, {'1': 1});
      expect(d.starsOf('ch1_l001'), 0);
    });

    test('JSON round trip keeps every nested model', () {
      const d = SaveData(
        stars: {'ch1_l001': 3},
        coins: 120,
        xp: 55,
        streak: StreakState(
          count: 4,
          best: 9,
          lastPlayed: '2026-10-10',
          freezes: 1,
          freezeWeek: '2026-W41',
        ),
        daily: {
          '2026-10-09': DailyResult(
            stars: 2,
            heartsLeft: 2,
            bestFlow: 4,
            seconds: 112,
          ),
        },
        achievements: {'first_note': '2026-10-10'},
        quests: QuestState(
          date: '2026-10-10',
          items: [QuestProgress(id: 'clear5', progress: 2)],
        ),
        settings: SaveSettings(leftHanded: true, colorBlind: 'tritan'),
        stats: PlayStats(arrowsFreed: 12, bestFlow: 5),
        flags: {'adsRemoved': true},
        updatedAt: '2026-10-10T10:00:00.000Z',
      );
      final text = jsonEncode(d.toJson());
      final back = SaveData.fromJson(jsonDecode(text) as Map<String, dynamic>);
      expect(back, d);
    });

    test('unknown or missing keys fall back to defaults', () {
      final d = SaveData.fromJson({'coins': 5, 'future': 'x'});
      expect(d.coins, 5);
      expect(d.settings.musicOn, isTrue);
    });
  });

  group('migrations (docs/09 §4: v1 -> v2)', () {
    test('a v1 save keeps stars and coins and gets a streak object', () {
      final v1 = {
        'schemaVersion': 1,
        'stars': {'ch1_l001': 2},
        'coins': 70,
        'streak': 5,
        'lastPlayed': '2026-10-09',
      };
      final d = SaveData.fromJson(SaveMigrations.migrate(v1));
      expect(d.schemaVersion, 2);
      expect(d.coins, 70);
      expect(d.starsOf('ch1_l001'), 2);
      expect(d.streak.count, 5);
      expect(d.streak.best, 5);
      expect(d.streak.lastPlayed, '2026-10-09');
    });

    test('a save with no version counts as v1; v2 passes through', () {
      expect(SaveMigrations.migrate({'coins': 1})['schemaVersion'], 2);
      final v2 = const SaveData(coins: 9).toJson();
      expect(SaveMigrations.migrate(v2)['coins'], 9);
    });

    test('newer versions are left alone', () {
      expect(SaveMigrations.migrate({'schemaVersion': 9})['schemaVersion'], 9);
    });
  });

  group('SaveRepository', () {
    test('an empty store gives a fresh save', () {
      expect(SaveRepository(MemorySaveStore()).load(), SaveData.initial());
    });

    test('saves alternate slots and load returns the newest', () async {
      final store = MemorySaveStore();
      final repo = SaveRepository(store);
      var d = const SaveData(coins: 1);
      d = await repo.save(d);
      d = await repo.save(d.copyWith(coins: 2));
      d = await repo.save(d.copyWith(coins: 3));
      expect(d.seq, 3);
      expect(store.data.keys, containsAll(SaveRepository.slots));
      expect(SaveRepository(store).load().coins, 3);
    });

    test('a write killed halfway leaves the previous save readable', () async {
      final store = MemorySaveStore();
      final repo = SaveRepository(store);
      var d = await repo.save(const SaveData(coins: 10));
      d = await repo.save(d.copyWith(coins: 20));
      // The kill: the slot being written (seq 3) holds half a JSON.
      store.data[SaveRepository.slots[3 % 2]] = '{"coins": 3';
      expect(SaveRepository(store).load().coins, 20);
    });

    test('garbage, wrong types and future versions are ignored', () async {
      final store = MemorySaveStore()
        ..data['slot0'] = 'not json'
        ..data['slot1'] = '[1,2]';
      expect(SaveRepository(store).load(), SaveData.initial());
      store.data['slot1'] = jsonEncode({'schemaVersion': 99, 'coins': 5});
      expect(SaveRepository(store).load(), SaveData.initial());
    });

    test('an old v1 file loads and is upgraded', () {
      final store = MemorySaveStore()
        ..data['slot0'] = jsonEncode({
          'schemaVersion': 1,
          'coins': 40,
          'stars': {'ch1_l001': 1},
        });
      final d = SaveRepository(store).load();
      expect(d.coins, 40);
      expect(d.schemaVersion, 2);
    });
  });

  group('HiveSaveStore', () {
    test('persists across a reopen (app kill)', () async {
      final dir = Directory.systemTemp.createTempSync('arrowchime_save');
      addTearDown(() => dir.deleteSync(recursive: true));
      var store = await HiveSaveStore.open(dir.path);
      await SaveRepository(store).save(const SaveData(coins: 77, xp: 5));
      await Hive.close();
      store = await HiveSaveStore.open(dir.path);
      final d = SaveRepository(store).load();
      expect(d.coins, 77);
      expect(d.xp, 5);
      await Hive.close();
    });
  });

  group('SaveController', () {
    ProviderContainer make(MemorySaveStore store, {DateTime? now}) {
      final c = ProviderContainer(
        overrides: [
          saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
          clockProvider.overrideWithValue(
            () => now ?? DateTime.utc(2026, 10, 10, 8),
          ),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('update stamps the time and writes 500 ms later', () {
      fakeAsync((async) {
        final store = MemorySaveStore();
        final c = make(store);
        final save = c.read(saveControllerProvider.notifier)
          ..update((d) => d.copyWith(coins: 5))
          ..update((d) => d.copyWith(coins: 9));
        expect(
          c.read(saveControllerProvider).updatedAt,
          '2026-10-10T08:00:00.000Z',
        );
        async.elapse(const Duration(milliseconds: 400));
        expect(store.data, isEmpty);
        async
          ..elapse(const Duration(milliseconds: 200))
          ..flushMicrotasks();
        expect(SaveRepository(store).load().coins, 9);
        expect(c.read(saveControllerProvider).seq, 1);
        expect(save, isNotNull);
      });
    });

    test('flush writes at once (app going to the background)', () async {
      final store = MemorySaveStore();
      final c = make(store);
      c.read(saveControllerProvider.notifier).update((d) => d.copyWith(xp: 3));
      await c.read(saveControllerProvider.notifier).flush();
      expect(SaveRepository(store).load().xp, 3);
    });

    test('a new container loads what the last one saved', () async {
      final store = MemorySaveStore();
      final a = make(store);
      a
          .read(saveControllerProvider.notifier)
          .update((d) => d.copyWith(coins: 42));
      await a.read(saveControllerProvider.notifier).flush();
      final b = make(store);
      expect(b.read(saveControllerProvider).coins, 42);
    });
  });
}
