import 'dart:convert';
import 'dart:io';

import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/level_checker.dart';
import 'package:arrowchime/core/level/models/daily_pack.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

Level withMeta(
  Level l, {
  String? version,
  double? difficulty,
  List<int>? solution,
  int? chapter,
  int? index,
}) => l
    .copyWith(chapter: chapter ?? l.chapter, index: index ?? l.index)
    .withMeta(
      LevelMeta(
        generatorVersion: version,
        difficulty: difficulty,
        solution: solution ?? l.meta.solution,
      ),
    );

void main() {
  group('LevelChecker.checkLevel', () {
    test('a sound hand-made level passes', () {
      final r = LevelChecker.checkLevel(
        withMeta(freeTrio(), version: 'handmade', solution: [0, 1, 2]),
      );
      expect(r.errors, isEmpty);
      expect(r.ok, isTrue);
      expect(r.score, closeTo(9.2, 1e-9));
    });

    test('rule violations are reported and stop further checks', () {
      final level = buildLevel(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [3, 0],
          ], 'R'),
        ],
      );
      final r = LevelChecker.checkLevel(level);
      expect(r.ok, isFalse);
      expect(r.errors.single, contains('not adjacent'));
      expect(r.score, isNull);
    });

    test('unsolvable levels fail', () {
      final r = LevelChecker.checkLevel(buildLevel(arrows: deadlockBox()));
      expect(r.errors, contains('level is not solvable'));
    });

    test('rotator levels that exceed the search limit fail as too complex', () {
      final arrows = [
        ...deadlockBox(),
        for (var i = 0; i < 6; i++)
          arrowJson(5 + i, [
            [i + 1, 7],
          ], 'D'),
      ];
      final r = LevelChecker.checkLevel(
        buildLevel(width: 8, height: 8, arrows: arrows),
        searchStateLimit: 10,
      );
      expect(r.errors.single, contains('too complex'));
    });

    test('a wrong meta.solution is caught', () {
      final blocked = LevelChecker.checkLevel(
        withMeta(blockedPair(), version: 'handmade', solution: [0, 1]),
      );
      expect(blocked.errors.single, contains('arrow 0 is not free'));

      final partial = LevelChecker.checkLevel(
        withMeta(blockedPair(), version: 'handmade', solution: [1]),
      );
      expect(partial.errors.single, contains('does not clear the board'));
    });

    test('a stale stored difficulty is caught (not for exempt levels)', () {
      final level = withMeta(freeTrio(), difficulty: 50, solution: [0, 1, 2]);
      expect(
        LevelChecker.checkLevel(level).errors.single,
        contains('is stale'),
      );
      expect(
        LevelChecker.checkLevel(
          withMeta(level, version: 'proto-0.1', difficulty: 50),
        ).errors,
        isEmpty,
      );
    });

    test('the chapter band is enforced for chapter levels', () {
      // freeTrio scores 9.2: way below the chapter 5 level 40 target.
      final level = withMeta(
        freeTrio(),
        chapter: 5,
        index: 40,
        difficulty: 9.2,
        solution: [0, 1, 2],
      );
      final r = LevelChecker.checkLevel(level);
      expect(r.errors.single, contains('is not within ±6.0 of the target'));

      // The same level is fine as chapter 1 level 1 (target ~10).
      final ok = withMeta(
        freeTrio(),
        chapter: 1,
        index: 1,
        difficulty: 9.2,
        solution: [0, 1, 2],
      );
      expect(LevelChecker.checkLevel(ok).errors, isEmpty);
    });

    test('levels without chapter/index (or chapter 0) skip the band', () {
      expect(LevelChecker.checkLevel(freeTrio()).errors, isEmpty);
      expect(
        LevelChecker.checkLevel(withMeta(freeTrio(), chapter: 0, index: 1))
            .errors,
        isEmpty,
      );
    });

    test('isBandExempt looks at the generator version', () {
      for (final v in ['handmade', 'proto-0.1', 'onboarding-1.0']) {
        expect(
          LevelChecker.isBandExempt(withMeta(freeTrio(), version: v)),
          isTrue,
        );
      }
      expect(
        LevelChecker.isBandExempt(withMeta(freeTrio(), version: '1.0.0')),
        isFalse,
      );
      expect(LevelChecker.isBandExempt(freeTrio()), isFalse);
    });
  });

  group('LevelChecker.checkPack', () {
    Level l(String id, {int chapter = 1, int index = 1}) => withMeta(
      freeTrio().copyWith(id: id),
      version: 'handmade',
      chapter: chapter,
      index: index,
    );

    test('a consistent pack passes', () {
      final pack = LevelPack(chapter: 1, levels: [l('a'), l('b', index: 2)]);
      expect(LevelChecker.checkPack(pack, expectedChapter: 1), isEmpty);
    });

    test('duplicate ids, wrong chapter and wrong index are reported', () {
      final pack = LevelPack(
        chapter: 1,
        levels: [l('a'), l('a', chapter: 2, index: 5)],
      );
      final problems = LevelChecker.checkPack(pack, expectedChapter: 1);
      expect(problems.any((p) => p.contains('duplicate id')), isTrue);
      expect(
        problems.any((p) => p.contains('chapter 2 != pack chapter 1')),
        isTrue,
      );
      expect(problems.any((p) => p.contains('index 5 should be 2')), isTrue);
    });

    test('level problems are prefixed with the level id', () {
      final bad = Level.fromJson(
        levelJson(
          id: 'broken',
          arrows: [
            arrowJson(0, [
              [0, 0],
              [3, 0],
            ], 'R'),
          ],
        ),
      );
      final problems = LevelChecker.checkPack(LevelPack(levels: [bad]));
      expect(problems.single, startsWith('broken: '));
    });
  });

  group('LevelChecker.checkDailyPack', () {
    Level day(String key, {String? id}) => withMeta(
      freeTrio().copyWith(id: id ?? 'daily_${key.replaceAll('-', '')}'),
      version: 'handmade',
    );

    test('consecutive days with matching ids pass', () {
      final pack = DailyPack(
        year: 2027,
        levels: {
          '2027-01-01': day('2027-01-01'),
          '2027-01-02': day('2027-01-02'),
        },
      );
      expect(LevelChecker.checkDailyPack(pack), isEmpty);
    });

    test('gaps, bad ids and bad dates are reported', () {
      final pack = DailyPack(
        year: 2027,
        levels: {
          '2027-01-01': day('2027-01-01'),
          '2027-01-03': day('2027-01-03', id: 'wrong_id'),
          '2027-xx-01': day('2027-01-04'),
        },
      );
      final problems = LevelChecker.checkDailyPack(pack);
      expect(problems.any((p) => p.contains('gap after')), isTrue);
      expect(
        problems.any((p) => p.contains('should be daily_20270103')),
        isTrue,
      );
      expect(problems.any((p) => p.contains('not a valid date')), isTrue);
    });

    test('level errors are prefixed with the date', () {
      final pack = DailyPack(
        year: 2027,
        levels: {
          '2027-01-01': day('2027-01-01')
              .copyWith(arrows: buildLevel(arrows: deadlockBox()).arrows),
        },
      );
      expect(
        LevelChecker.checkDailyPack(pack).single,
        startsWith('2027-01-01: '),
      );
    });
  });

  group('shipped packs in assets/levels (what CI checks)', () {
    final dir = Directory('assets/levels');

    LevelPack chapterPack(int n) => PackLoader.parsePack(
      File('assets/levels/ch$n.json').readAsStringSync(),
    );

    for (final n in ChapterPlan.bands.keys) {
      test('ch$n.json: 60 consistent, solvable, on-target levels', () {
        final pack = chapterPack(n);
        expect(pack.chapter, n);
        expect(pack.levels, hasLength(60));
        expect(LevelChecker.checkPack(pack, expectedChapter: n), isEmpty);
      });
    }

    test('ch1 L1-L10 follow the onboarding table', () {
      final pack = chapterPack(1);
      expect(
        [for (var i = 0; i < 10; i++) pack.levels[i].arrows.length].take(4),
        [3, 4, 6, 5],
      );
      expect(pack.levels[9].mask, isNotNull, reason: 'L10 is the heart knot');
      expect(pack.levels[7].width, 14, reason: 'L8 is the 14x14 zoom level');
    });

    test('the daily packs cover the next 366 days from 2026-10-10', () {
      final a = PackLoader.parseDailyPack(
        File('assets/levels/daily_2026.json').readAsStringSync(),
      );
      final b = PackLoader.parseDailyPack(
        File('assets/levels/daily_2027.json').readAsStringSync(),
      );
      expect(a.year, 2026);
      expect(b.year, 2027);
      expect(a.levels.keys.first, '2026-10-10');
      expect(a.levels.keys.last, '2026-12-31');
      expect(b.levels.keys.first, '2027-01-01');
      expect(b.levels.keys.last, '2027-10-10');
      expect(a.levels.length + b.levels.length, 366);
      expect(LevelChecker.checkDailyPack(a), isEmpty);
      expect(LevelChecker.checkDailyPack(b), isEmpty);
    });

    test('the daily packs match the on-device generator exactly', () {
      final b = PackLoader.parseDailyPack(
        File('assets/levels/daily_2027.json').readAsStringSync(),
      );
      for (final key in ['2027-01-01', '2027-05-17', '2027-10-10']) {
        final date = DateTime.parse('${key}T00:00:00Z');
        final fresh = PackLoader.parseLevel(
          jsonEncode(b.levels[key]!.toJson()),
        );
        expect(jsonEncode(fresh.toJson()), jsonEncode(b.levels[key]!.toJson()));
        expect(b.levels[key]!.meta.seed, isNotNull, reason: '$date');
      }
    });

    test('every json in the folder is accounted for', () {
      final names = dir
          .listSync()
          .map((e) => e.uri.pathSegments.last)
          .where((n) => n.endsWith('.json'))
          .toSet();
      expect(
        names,
        containsAll([
          'level.schema.json',
          'sample_levels.json',
          'ch1.json',
          'ch2.json',
          'ch3.json',
          'ch4.json',
          'ch5.json',
          'daily_2026.json',
          'daily_2027.json',
        ]),
      );
    });
  });
}
