import 'dart:convert';

import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/daily.dart';
import 'package:arrowchime/core/level/generator/gen_params.dart';
import 'package:arrowchime/core/level/generator/onboarding.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/prng.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generator_test.dart' show expectSound;

int blockedCount(Level level) {
  final s = BoardState.initial(level);
  var n = 0;
  for (var i = 0; i < s.alive.length; i++) {
    if (!Rules.isFree(s, i)) n++;
  }
  return n;
}

bool hasBend(Arrow a) {
  for (var i = 2; i < a.body.length; i++) {
    final d1 = (
      a.body[i - 1].x - a.body[i - 2].x,
      a.body[i - 1].y - a.body[i - 2].y,
    );
    final d2 = (a.body[i].x - a.body[i - 1].x, a.body[i].y - a.body[i - 1].y);
    if (d1 != d2) return true;
  }
  return false;
}

void main() {
  group('onboarding table (docs/03 §6)', () {
    final levels = [for (var i = 1; i <= 10; i++) OnboardingLevels.build(i)];

    test('every level is sound and uses no mechanics', () {
      for (final l in levels) {
        expectSound(l, reason: l.id);
        expect(l.gates, isEmpty);
        expect(l.portals, isEmpty);
        expect(
          l.arrows.every(
            (a) =>
                a.kind == ArrowKind.normal &&
                a.frozen == null &&
                a.link == null,
          ),
          isTrue,
          reason: l.id,
        );
        expect(l.chapter, 1);
        expect(l.meta.generatorVersion, OnboardingLevels.version);
        expect(l.meta.melody, ChapterPlan.melodyFor(1, l.index!));
        expect(l.id, ChapterPlan.idFor(1, l.index!));
      }
    });

    test('L1: 3 straight arrows, all free', () {
      expect(levels[0].arrows, hasLength(3));
      expect(blockedCount(levels[0]), 0);
      expect(levels[0].meta.depth, 1);
    });

    test('L2: 4 arrows, exactly 1 blocked', () {
      expect(levels[1].arrows, hasLength(4));
      expect(blockedCount(levels[1]), 1);
    });

    test('L3: 6 arrows with something blocked (hearts)', () {
      expect(levels[2].arrows, hasLength(6));
      expect(blockedCount(levels[2]), greaterThan(0));
    });

    test('L4: 5 arrows, most of them bent (snake arrows)', () {
      expect(levels[3].arrows, hasLength(5));
      expect(levels[3].arrows.where(hasBend).length, greaterThanOrEqualTo(3));
    });

    test('arrow counts of L5-L9 follow the table', () {
      expect(
        [for (var i = 4; i <= 8; i++) levels[i].arrows.length],
        [8, 10, 12, 14, 12],
      );
    });

    test('L8: a 14x14 board (zoom & pan)', () {
      expect((levels[7].width, levels[7].height), (14, 14));
    });

    test('L10: first Knot level is heart shaped', () {
      expect(levels[9].mask, isNotNull);
      expect(levels[9].arrows.length, greaterThanOrEqualTo(12));
    });

    test('building twice gives the same JSON', () {
      for (var i = 1; i <= 10; i++) {
        expect(
          jsonEncode(OnboardingLevels.build(i).toJson()),
          jsonEncode(levels[i - 1].toJson()),
        );
      }
    });

    test('rejects indexes outside 1-10', () {
      expect(() => OnboardingLevels.build(0), throwsRangeError);
      expect(() => OnboardingLevels.build(11), throwsRangeError);
    });
  });

  group('Daily Knot', () {
    final monday = DateTime.utc(2026, 10, 12);

    test('keys and ids', () {
      expect(DailyKnot.keyFor(DateTime.utc(2027, 1, 5)), '2027-01-05');
      expect(DailyKnot.idFor(DateTime.utc(2027, 1, 5)), 'daily_20270105');
    });

    test('uses the UTC date, whatever the time of day', () {
      final a = DailyKnot.levelFor(DateTime.utc(2026, 10, 10, 0, 1));
      final b = DailyKnot.levelFor(DateTime.utc(2026, 10, 10, 23, 59));
      expect(jsonEncode(a.toJson()), jsonEncode(b.toJson()));
      // A non-UTC instant maps to its UTC calendar day.
      final c = DailyKnot.levelFor(DateTime.parse('2026-10-10T23:30:00-05:00'));
      expect(c.id, 'daily_20261011');
    });

    test('seed is the FNV-1a hash of the date and recorded in meta', () {
      final level = DailyKnot.levelFor(DateTime.utc(2026, 10, 10));
      expect(level.meta.seed, dailySeed(DateTime.utc(2026, 10, 10)));
      expect(level.chapter, 0);
      expect(level.index, 283, reason: 'day of the year');
    });

    test('is deterministic', () {
      final d = DateTime.utc(2027, 3, 3);
      expect(
        jsonEncode(DailyKnot.levelFor(d).toJson()),
        jsonEncode(DailyKnot.levelFor(d).toJson()),
      );
    });

    test('difficulty follows the weekday', () {
      final params = [
        for (var i = 0; i < 7; i++)
          DailyKnot.paramsFor(monday.add(Duration(days: i))),
      ];
      expect(params[0].mix.isEmpty, isTrue, reason: 'Monday is plain');
      expect(params[6].mix.gates, greaterThan(0), reason: 'Sunday is hardest');
      for (var i = 1; i < 7; i++) {
        expect(params[i].width, greaterThanOrEqualTo(params[i - 1].width));
        expect(
          params[i].targetFill,
          greaterThanOrEqualTo(params[i - 1].targetFill),
        );
      }
      expect(params[6].targetFill, greaterThan(params[0].targetFill));
      expect(params.every((p) => p.mix.rotators == 0), isTrue);
      expect(params.every((p) => p.mix.portalPairs == 0), isTrue);
    });

    test('one full week is sound', () {
      for (var i = 0; i < 7; i++) {
        final level = DailyKnot.levelFor(monday.add(Duration(days: i)));
        expectSound(level, reason: level.id);
      }
    });

    test('buildRange covers each day once, in order', () {
      final pack = DailyKnot.buildRange(
        DateTime.utc(2026, 12, 29),
        DateTime.utc(2026, 12, 31),
      );
      expect(pack.year, 2026);
      expect(pack.levels.keys, ['2026-12-29', '2026-12-30', '2026-12-31']);
      expect(
        jsonEncode(pack.levels['2026-12-30']!.toJson()),
        jsonEncode(DailyKnot.levelFor(DateTime.utc(2026, 12, 30)).toJson()),
        reason: 'pre-baked level == on-device fallback',
      );
    });

    test('buildRange rejects a range across two years', () {
      expect(
        () => DailyKnot.buildRange(
          DateTime.utc(2026, 12, 31),
          DateTime.utc(2027),
        ),
        throwsArgumentError,
      );
    });

    test('a leap year has 366 days', () {
      final pack = DailyKnot.buildRange(
        DateTime.utc(2028),
        DateTime.utc(2028, 12, 31),
      );
      expect(pack.levels, hasLength(366));
    });
  });

  test('MechanicMix.isEmpty', () {
    expect(MechanicMix.none.isEmpty, isTrue);
    expect(const MechanicMix(links: 1).isEmpty, isFalse);
  });
}
