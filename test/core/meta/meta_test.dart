import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/meta/achievements.dart';
import 'package:arrowchime/core/meta/daily_share.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/meta/player_level.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:arrowchime/core/meta/quests.dart';
import 'package:arrowchime/core/meta/streak.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:flutter_test/flutter_test.dart';

import '../level/support/fixtures.dart';

WinReport win(
  int chapter,
  int index,
  int stars, {
  int flow = 1,
  int arrows = 10,
}) => WinReport(
  chapter: chapter,
  index: index,
  stars: stars,
  bestFlow: flow,
  arrowsFreed: arrows,
  blockedTaps: 3 - stars,
  seconds: 60,
);

void main() {
  group('DateKey', () {
    test('keys, arithmetic and ISO weeks', () {
      expect(DateKey.of(DateTime(2026, 3, 5)), '2026-03-05');
      expect(DateKey.utc(DateTime.utc(2026, 10, 10, 23, 59)), '2026-10-10');
      expect(DateKey.daysBetween('2026-02-27', '2026-03-02'), 3);
      expect(DateKey.addDays('2026-12-31', 1), '2027-01-01');
      expect(DateKey.dayOfYear('2026-10-10'), 283);
      expect(DateKey.isoWeek('2026-10-10'), '2026-W41');
      expect(DateKey.isoWeek('2027-01-01'), '2026-W53');
      expect(DateKey.isoWeek('2024-12-30'), '2025-W01');
    });
  });

  group('Streak (docs/09 §4)', () {
    test('23:59 then 00:01 the next local day is +1', () {
      var s = Streak.play(const StreakState(), '2026-10-10');
      expect(s.count, 1);
      s = Streak.play(s, '2026-10-10');
      expect(s.count, 1);
      s = Streak.play(s, '2026-10-11');
      expect(s.count, 2);
      expect(s.best, 2);
    });

    test(
      'a skipped day with a freeze keeps the streak and uses the freeze',
      () {
        var s = const StreakState(
          count: 5,
          best: 5,
          lastPlayed: '2026-10-08',
          freezes: 1,
          freezeWeek: '2026-W41',
        );
        s = Streak.play(s, '2026-10-10');
        expect(s.count, 6);
        expect(s.freezes, 0);
      },
    );

    test('a skipped day without a freeze resets to 1', () {
      final s = Streak.play(
        const StreakState(
          count: 5,
          best: 5,
          lastPlayed: '2026-10-08',
          freezeWeek: '2026-W41',
        ),
        '2026-10-10',
      );
      expect(s.count, 1);
      expect(s.best, 5);
    });

    test('two missed days need two freezes', () {
      const base = StreakState(
        count: 5,
        best: 5,
        lastPlayed: '2026-10-07',
        freezes: 1,
        freezeWeek: '2026-W41',
      );
      expect(Streak.play(base, '2026-10-10').count, 1);
      expect(Streak.play(base.copyWith(freezes: 2), '2026-10-10').count, 6);
    });

    test('one free freeze arrives per ISO week, at most two in stock', () {
      var s = Streak.refreshFreezes(const StreakState(), '2026-10-10');
      expect(s.freezes, 1);
      expect(Streak.refreshFreezes(s, '2026-10-11').freezes, 1);
      s = Streak.refreshFreezes(s, '2026-10-12');
      expect(s.freezes, 2);
      s = Streak.refreshFreezes(s, '2026-10-19');
      expect(s.freezes, 2);
    });

    test('the clock moving back does not break or add', () {
      final s = Streak.play(
        const StreakState(
          count: 3,
          best: 3,
          lastPlayed: '2026-10-10',
          freezeWeek: '2026-W41',
        ),
        '2026-10-09',
      );
      expect(s.count, 3);
      expect(s.lastPlayed, '2026-10-09');
    });

    test('tiers, live count, buying freezes', () {
      expect(
        [
          for (final n in [0, 2, 3, 7, 30, 100]) Streak.tierOf(n),
        ],
        [0, 0, 1, 2, 3, 4],
      );
      const s = StreakState(count: 4, lastPlayed: '2026-10-08', freezes: 1);
      expect(Streak.liveCount(const StreakState(), '2026-10-10'), 0);
      expect(Streak.liveCount(s, '2026-10-08'), 4);
      expect(Streak.liveCount(s, '2026-10-09'), 4);
      expect(
        Streak.liveCount(s, '2026-10-10'),
        4,
        reason: 'one missed day, one freeze',
      );
      expect(Streak.liveCount(s, '2026-10-12'), 0);
      expect(Streak.addFreeze(s)!.freezes, 2);
      expect(Streak.addFreeze(s.copyWith(freezes: 2)), isNull);
    });
  });

  group('PlayerLevel', () {
    test('about 8 levels per early level-up, slowing later', () {
      expect(PlayerLevel.needed(1), 240);
      expect(PlayerLevel.needed(2), 270);
      expect(PlayerLevel.of(0), 1);
      expect(PlayerLevel.of(239), 1);
      expect(PlayerLevel.of(240), 2);
      expect(PlayerLevel.of(240 + 270), 3);
      expect(PlayerLevel.progress(300), (60, 270));
    });
  });

  group('Quests', () {
    test('three distinct quests a day, the same for the same date', () {
      final a = Quests.ensureToday(const QuestState(), '2026-10-10');
      final b = Quests.ensureToday(const QuestState(), '2026-10-10');
      expect(a.items, hasLength(3));
      expect(a, b);
      final metrics = {for (final i in a.items) Quests.def(i.id).metric};
      expect(metrics, hasLength(3));
      var different = false;
      for (var d = 11; d < 25; d++) {
        if (Quests.ensureToday(const QuestState(), '2026-10-$d') != a) {
          different = true;
        }
      }
      expect(different, isTrue);
    });

    test('a drawn day is kept; a new day redraws and forgets claims', () {
      var s = Quests.ensureToday(const QuestState(), '2026-10-10');
      s = s.copyWith(
        items: [s.items.first.copyWith(claimed: true), ...s.items.skip(1)],
      );
      expect(Quests.ensureToday(s, '2026-10-10'), s);
      final next = Quests.ensureToday(s, '2026-10-11');
      expect(next.items.every((i) => !i.claimed), isTrue);
      expect(next.chestOpened, isFalse);
    });

    test('progress, claim once, chest after all three', () {
      var s = const QuestState(
        date: '2026-10-10',
        items: [
          QuestProgress(id: 'clear5'),
          QuestProgress(id: 'flow3'),
          QuestProgress(id: 'free100'),
        ],
      );
      s = Quests.advance(s, QuestMetric.levelsCleared, 3);
      expect(s.items.first.progress, 3);
      expect(Quests.claim(s, 'clear5'), isNull, reason: 'not finished');
      s = Quests.advance(s, QuestMetric.levelsCleared, 9);
      expect(s.items.first.progress, 5, reason: 'capped at the target');
      s = Quests.advance(s, QuestMetric.flowThree, 1);
      s = Quests.advance(s, QuestMetric.arrowsFreed, 500);
      expect(Quests.advance(s, QuestMetric.daily, 0), s);
      var coins = 0;
      for (final id in ['clear5', 'flow3', 'free100']) {
        final r = Quests.claim(s, id)!;
        s = r.$1;
        coins += r.$2;
        expect(Quests.claim(s, id), isNull, reason: 'only once');
      }
      expect(coins, 40 + 30 + 50);
      expect(Quests.claim(s, 'nope'), isNull);
      expect(Quests.chestReady(s), isTrue);
      final chest = Quests.openChest(s)!;
      expect(chest.$2, 100);
      expect(Quests.openChest(chest.$1), isNull);
      expect(Quests.chestReady(const QuestState()), isFalse);
    });

    test('rewards stay inside 30-80 coins', () {
      for (final q in Quests.pool) {
        expect(q.coins, inInclusiveRange(30, 80));
      }
    });
  });

  group('Achievements', () {
    test('about 30, unique ids, coins in 50-500', () {
      expect(Achievements.all.length, inInclusiveRange(28, 32));
      expect({
        for (final a in Achievements.all) a.id,
      }, hasLength(Achievements.all.length));
      for (final a in Achievements.all) {
        expect(a.coins, inInclusiveRange(50, 500));
      }
    });

    test('a fresh player has none; counters unlock them', () {
      expect(Achievements.newlyUnlocked(const SaveData()), isEmpty);
      const d = SaveData(
        stats: PlayStats(
          levelsCleared: 10,
          arrowsFreed: 1000,
          bestFlow: 5,
          perfectRun: 10,
        ),
        streak: StreakState(best: 7),
        flags: {'nightOwl': true, 'questChestOpened': true},
      );
      expect(
        Achievements.newlyUnlocked(d),
        containsAll([
          'first_note',
          'levels_10',
          'untangler',
          'maestro',
          'flow_3',
          'perfect_pitch',
          'streak_3',
          'streak_7',
          'night_owl',
          'quest_chest',
        ]),
      );
      expect(
        Achievements.newlyUnlocked(
          d.copyWith(achievements: {'first_note': 'x'}),
        ),
        isNot(contains('first_note')),
      );
    });

    test('chapter and star totals read the stars map', () {
      final stars = {
        for (var i = 1; i <= 60; i++) 'ch2_l${i.toString().padLeft(3, '0')}': 3,
      };
      final d = SaveData(stars: stars);
      expect(
        Achievements.newlyUnlocked(d),
        containsAll(['chapter_2', 'stars_100']),
      );
      expect(Achievements.newlyUnlocked(d), isNot(contains('chapter_1')));
      expect(Achievements.def('maestro').target, 5);
    });
  });

  group('Progression: reading', () {
    test('chapters unlock in order and levels one by one', () {
      var d = const SaveData();
      expect(Progression.isChapterUnlocked(d, 1), isTrue);
      expect(Progression.isChapterUnlocked(d, 2), isFalse);
      expect(Progression.isLevelUnlocked(d, 1, 1), isTrue);
      expect(Progression.isLevelUnlocked(d, 1, 2), isFalse);
      expect(Progression.isLevelUnlocked(d, 2, 1), isFalse);
      d = d.copyWith(currentLevel: {'1': 61});
      expect(Progression.isChapterUnlocked(d, 2), isTrue);
      expect(Progression.isLevelUnlocked(d, 1, 60), isTrue);
      expect(Progression.isLevelUnlocked(d, 2, 1), isTrue);
      expect(Progression.playTarget(d), (2, 1));
      expect(Progression.playTarget(const SaveData()), (1, 1));
      final done = SaveData(
        currentLevel: {for (var c = 1; c <= 5; c++) '$c': 61},
      );
      // The track never ends: the frontier is the next stage.
      expect(Progression.playTarget(done), (6, 1));
    });

    test('restoration, stars and cleared counts per chapter', () {
      const d = SaveData(stars: {'ch1_l001': 3, 'ch1_l002': 1, 'ch2_l001': 2});
      expect(Progression.cleared(d, 1), 2);
      expect(Progression.restoration(d, 1), closeTo(2 / 60, 1e-9));
      expect(Progression.chapterStars(d, 1), 4);
      expect(Progression.totalStars(d), 6);
      expect(Progression.levelId(1, 7), ChapterPlan.idFor(1, 7));
    });
  });

  group('Progression: a win', () {
    test('the first clear pays in full and moves on', () {
      final o = Progression.recordWin(
        const SaveData(),
        win(1, 1, 3, flow: 5),
        today: '2026-10-10',
      );
      expect(o.firstClear, isTrue);
      expect(o.coins, 25 + 10);
      expect(o.xp, 30 + 20);
      expect(o.data.starsOf('ch1_l001'), 3);
      expect(o.data.currentLevel['1'], 2);
      expect(o.data.stats.levelsCleared, 1);
      expect(o.data.stats.perfectClears, 1);
      expect(o.data.stats.perfectRun, 1);
      expect(o.data.stats.bestFlow, 5);
      expect(o.data.streak.count, 1);
      expect(o.achievements, containsAll(['first_note', 'flow_3', 'maestro']));
      // Achievement coins are on top.
      final bonus = o.achievements.fold(
        0,
        (a, id) => a + Achievements.def(id).coins,
      );
      expect(o.data.coins, 35 + bonus + o.levelUps * 100);
    });

    test(
      'a replay with the same stars pays nothing and is not a new clear',
      () {
        final first = Progression.recordWin(
          const SaveData(),
          win(1, 1, 2),
          today: '2026-10-10',
        ).data;
        final again = Progression.recordWin(
          first,
          win(1, 1, 2),
          today: '2026-10-10',
        );
        expect(again.firstClear, isFalse);
        expect(again.improved, isFalse);
        expect(again.coins, 0);
        expect(again.xp, 0);
        expect(again.data.stats.levelsCleared, 1);
        expect(again.data.stats.arrowsFreed, 20, reason: 'arrows still count');
        expect(again.data.currentLevel['1'], 2);
      },
    );

    test('a better result pays only the extra stars; worse never lowers', () {
      final first = Progression.recordWin(
        const SaveData(),
        win(1, 1, 1),
        today: '2026-10-10',
      ).data;
      final better = Progression.recordWin(
        first,
        win(1, 1, 3),
        today: '2026-10-10',
      );
      expect(better.improved, isTrue);
      expect(better.coins, 10);
      expect(better.xp, 20);
      expect(better.data.starsOf('ch1_l001'), 3);
      final worse = Progression.recordWin(
        better.data,
        win(1, 1, 1),
        today: '2026-10-10',
      );
      expect(worse.data.starsOf('ch1_l001'), 3);
      expect(worse.data.stats.perfectRun, 0);
    });

    test(
      'knot and boss levels pay more; the next level never goes backwards',
      () {
        final knot = Progression.recordWin(
          const SaveData(),
          win(1, 10, 3),
          today: '2026-10-10',
        );
        expect(knot.coins, 38);
        expect(knot.data.currentLevel['1'], 11);
        final replay = Progression.recordWin(
          knot.data,
          win(1, 3, 3),
          today: '2026-10-10',
        );
        expect(replay.data.currentLevel['1'], 11);
        final boss = Progression.recordWin(
          const SaveData(),
          win(1, 60, 3),
          today: '2026-10-10',
        );
        expect(boss.coins, 75);
        expect(boss.data.currentLevel['1'], 61);
      },
    );

    test('XP crossing a threshold pays level-up coins', () {
      const d = SaveData(xp: 230);
      final o = Progression.recordWin(d, win(1, 1, 3), today: '2026-10-10');
      expect(o.levelUps, 1);
      expect(PlayerLevel.of(o.data.xp), 2);
      expect(o.data.coins, greaterThanOrEqualTo(25 + 100));
    });

    test('quests advance and the perfect run counts consecutive clears', () {
      var d = const SaveData();
      for (var i = 1; i <= 3; i++) {
        d = Progression.recordWin(
          d,
          win(1, i, 3, flow: 3),
          today: '2026-10-10',
        ).data;
      }
      expect(d.stats.perfectRun, 3);
      expect(d.quests.date, '2026-10-10');
      for (final item in d.quests.items) {
        final def = Quests.def(item.id);
        if (def.metric == QuestMetric.levelsCleared) {
          expect(item.progress, 3);
        }
        if (def.metric == QuestMetric.flowThree) {
          expect(
            item.progress,
            1,
            reason: 'Flow x3 quests count once per level',
          );
        }
      }
    });

    test('winning on consecutive days builds the streak', () {
      var d = Progression.recordWin(
        const SaveData(),
        win(1, 1, 3),
        today: '2026-10-10',
      ).data;
      d = Progression.recordWin(d, win(1, 2, 3), today: '2026-10-11').data;
      expect(d.streak.count, 2);
    });
  });

  group('Progression: the Daily Knot', () {
    const result = DailyResult(
      stars: 3,
      heartsLeft: 3,
      bestFlow: 4,
      seconds: 112,
    );

    test('first play pays 50 + 25 per streak tier and counts', () {
      final o = Progression.recordDaily(
        const SaveData(),
        '2026-10-10',
        result,
        today: '2026-10-10',
        localHour: 14,
      );
      expect(o.coins, 50);
      expect(o.data.daily['2026-10-10'], result);
      expect(o.data.stats.dailiesPlayed, 1);
      expect(o.achievements, contains('daily_1'));
      expect(o.data.flags['nightOwl'], isNull);
      const streaky = SaveData(
        streak: StreakState(
          count: 6,
          best: 6,
          lastPlayed: '2026-10-09',
          freezeWeek: '2026-W41',
        ),
      );
      expect(
        Progression.recordDaily(
          streaky,
          '2026-10-10',
          result,
          today: '2026-10-10',
          localHour: 14,
        ).coins,
        50 + 25 * 2,
      );
    });

    test('playing again does not pay twice; the better result is kept', () {
      final first = Progression.recordDaily(
        const SaveData(),
        '2026-10-10',
        result.copyWith(stars: 1),
        today: '2026-10-10',
        localHour: 9,
      ).data;
      final again = Progression.recordDaily(
        first,
        '2026-10-10',
        result,
        today: '2026-10-10',
        localHour: 9,
      );
      expect(again.coins, 0);
      expect(again.data.daily['2026-10-10']!.stars, 3);
      expect(again.data.stats.dailiesPlayed, 1);
    });

    test('Night Owl at 2 am; replayed days pay nothing', () {
      final night = Progression.recordDaily(
        const SaveData(),
        '2026-10-10',
        result,
        today: '2026-10-10',
        localHour: 2,
      );
      expect(night.data.flags['nightOwl'], isTrue);
      expect(night.achievements, contains('night_owl'));
      final replay = Progression.recordDaily(
        const SaveData(),
        '2026-10-05',
        result.copyWith(replayed: true),
        today: '2026-10-10',
        localHour: 2,
      );
      expect(replay.coins, 0);
      expect(replay.data.flags['nightOwl'], isNull);
      expect(AppConfig.defaults().missedDailyPrice, 100);
    });

    test('the calendar covers 30 days with today last', () {
      const d = SaveData(daily: {'2026-10-09': result});
      final cal = Progression.calendar(d, '2026-10-10');
      expect(cal, hasLength(30));
      expect(cal.last.key, '2026-10-10');
      expect(cal.last.isToday, isTrue);
      expect(cal.last.missed, isFalse);
      expect(cal[28].played, isTrue);
      expect(cal[27].missed, isTrue);
      expect(cal.first.key, '2026-09-11');
    });
  });

  group('DailyShare (docs/09 §4: the card text matches the result)', () {
    test('headline format', () {
      const r = DailyResult(stars: 2, heartsLeft: 2, bestFlow: 4, seconds: 112);
      expect(
        DailyShare.headline('2026-05-22', r, totalHearts: 3),
        'Arrowchime Daily #142 ❤️❤️🖤 ⚡x4 ⏱1:52',
      );
      expect(
        DailyShare.headline(
          '2026-05-22',
          r.copyWith(heartsLeft: 9, seconds: 65),
          totalHearts: 3,
        ),
        'Arrowchime Daily #142 ❤️❤️❤️ ⚡x4 ⏱1:05',
      );
    });

    test('mini board has one square per cell', () {
      final level = freeTrio();
      final board = DailyShare.miniBoard(level);
      final rows = board.split('\n');
      expect(rows, hasLength(level.height));
      expect(rows.first.runes.length, level.width);
      expect(board, contains('🟥'));
      expect(board, contains('⬛'));
      const r = DailyResult(stars: 3, heartsLeft: 3, seconds: 5);
      expect(
        DailyShare.text('2026-05-22', r, level),
        startsWith('Arrowchime Daily #142'),
      );
      expect(DailyShare.text('2026-05-22', r, level), endsWith(board));
    });
  });
}
