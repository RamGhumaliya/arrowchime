import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('band table (docs/04 §5)', () {
    test('values match the doc', () {
      const b = ChapterPlan.bands;
      expect(b.keys, [1, 2, 3, 4, 5]);
      expect((b[1]!.sizeMin, b[1]!.sizeMax), (6, 12));
      expect((b[1]!.scoreMin, b[1]!.scoreMax, b[1]!.bossScore), (10, 35, 45));
      expect((b[2]!.sizeMin, b[2]!.sizeMax), (8, 14));
      expect((b[3]!.fillMin, b[3]!.fillMax), (0.70, 0.85));
      expect((b[4]!.scoreMin, b[4]!.scoreMax, b[4]!.bossScore), (40, 65, 75));
      expect((b[5]!.sizeMin, b[5]!.sizeMax), (14, 22));
      expect((b[5]!.scoreMin, b[5]!.scoreMax, b[5]!.bossScore), (50, 75, 88));
    });
  });

  group('sawtooth', () {
    test('+0 +3 +6 +9 then -8 on every 5th level', () {
      expect(
        [for (var i = 1; i <= 10; i++) ChapterPlan.saw(i)],
        [0, 3, 6, 9, -8, 0, 3, 6, 9, -8],
      );
    });

    test('target = band interpolation + saw, knot +8, boss absolute', () {
      // Chapter 1, level 3: 10 + 25 * 3/60 + 6.
      expect(
        ChapterPlan.targetScore(1, 3),
        closeTo(10 + 25 * 3 / 60 + 6, 1e-9),
      );
      // Knot (level 10): 10 + 25*10/60 + (-8) + 8.
      expect(ChapterPlan.targetScore(1, 10), closeTo(10 + 25 * 10 / 60, 1e-9));
      expect(ChapterPlan.targetScore(1, 60), 45);
      expect(ChapterPlan.targetScore(5, 60), 88);
    });

    test('every target is on the 0–100 scale', () {
      for (final c in ChapterPlan.bands.keys) {
        for (var i = 1; i <= 60; i++) {
          expect(ChapterPlan.targetScore(c, i), inInclusiveRange(0, 100));
        }
      }
    });

    test('difficulty rises over the chapter on average', () {
      for (final c in ChapterPlan.bands.keys) {
        double avg(int from, int to) {
          var s = 0.0;
          for (var i = from; i <= to; i++) {
            s += ChapterPlan.targetScore(c, i);
          }
          return s / (to - from + 1);
        }

        expect(avg(41, 59), greaterThan(avg(1, 19)));
      }
    });
  });

  group('level kinds', () {
    test('knot / boss / breather classification', () {
      expect([
        for (final i in [10, 20, 30, 40, 50]) ChapterPlan.isKnot(i),
      ], everyElement(isTrue));
      expect(ChapterPlan.isKnot(60), isFalse);
      expect(ChapterPlan.isBoss(60), isTrue);
      expect(ChapterPlan.isBoss(59), isFalse);
      expect(ChapterPlan.isBreather(5), isTrue);
      expect(ChapterPlan.isBreather(10), isFalse, reason: 'knot');
      expect(ChapterPlan.isBreather(60), isFalse, reason: 'boss');
      expect(ChapterPlan.isBreather(6), isFalse);
    });

    test('masks: knots cycle shapes, boss is a circle, chapter 1 from L12', () {
      expect(ChapterPlan.maskKind(1, 10), 'heart');
      expect(ChapterPlan.maskKind(1, 20), 'ring');
      expect(ChapterPlan.maskKind(1, 30), 'diamond');
      expect(ChapterPlan.maskKind(1, 40), 'star');
      expect(ChapterPlan.maskKind(1, 50), 'cross');
      expect(ChapterPlan.maskKind(3, 60), 'circle');
      expect(ChapterPlan.maskKind(1, 8), isNull, reason: 'no masks before L12');
      expect(ChapterPlan.maskKind(1, 11), isNull);
      expect(ChapterPlan.maskKind(1, 12), 'diamond');
      expect(ChapterPlan.maskKind(1, 16), 'ring');
      expect(ChapterPlan.maskKind(2, 3), isNotNull);
      expect(ChapterPlan.maskKind(2, 4), isNull);
    });
  });

  group('mechanics budget (docs/03 §5)', () {
    int types(int chapter, int index) {
      final m = ChapterPlan.mixFor(chapter, index);
      return [
        m.gates > 0,
        m.frozen > 0,
        m.links > 0,
        m.portalPairs > 0,
        m.rotators > 0,
      ].where((x) => x).length;
    }

    test('chapter 1 has no mechanics', () {
      for (var i = 1; i <= 60; i++) {
        expect(ChapterPlan.mixFor(1, i).isEmpty, isTrue);
      }
    });

    test('at most 2 types in chapters 2-4 (boss excepted), 3 in chapter 5', () {
      for (var i = 1; i < 60; i++) {
        for (final c in [2, 3, 4]) {
          expect(types(c, i), lessThanOrEqualTo(2), reason: 'ch$c L$i');
        }
        expect(types(5, i), lessThanOrEqualTo(3), reason: 'ch5 L$i');
      }
    });

    test('each chapter introduces its mechanic', () {
      expect(ChapterPlan.mixFor(2, 1).rotators, greaterThan(0));
      expect(ChapterPlan.mixFor(3, 1).gates, greaterThan(0));
      expect(ChapterPlan.mixFor(4, 1).frozen, greaterThan(0));
      expect(ChapterPlan.mixFor(5, 1).links, greaterThan(0));
      expect(ChapterPlan.mixFor(5, 19).portalPairs, 0);
      expect(ChapterPlan.mixFor(5, 20).portalPairs, greaterThan(0));
    });

    test('bosses use every mechanic unlocked so far', () {
      final b5 = ChapterPlan.mixFor(5, 60);
      expect(b5.links, greaterThan(0));
      expect(b5.portalPairs, greaterThan(0));
      expect(b5.frozen, greaterThan(0));
      expect(b5.gates, greaterThan(0));
      expect(b5.rotators, greaterThan(0));
      final b4 = ChapterPlan.mixFor(4, 60);
      expect(b4.frozen > 0 && b4.gates > 0 && b4.rotators > 0, isTrue);
      final b3 = ChapterPlan.mixFor(3, 60);
      expect(b3.gates > 0 && b3.rotators > 0, isTrue);
    });
  });

  group('paramsFor', () {
    test('board grows from level 1 to the boss', () {
      for (final c in ChapterPlan.bands.keys) {
        final b = ChapterPlan.bands[c]!;
        expect(ChapterPlan.paramsFor(c, 1).width, b.sizeMin);
        expect(
          ChapterPlan.paramsFor(c, 59).width,
          greaterThanOrEqualTo(b.sizeMax - 1),
        );
        expect(ChapterPlan.paramsFor(c, 60).width, b.sizeMax + 2);
      }
    });

    test('knots are bigger, breathers smaller', () {
      final knot = ChapterPlan.paramsFor(1, 30);
      final plain = ChapterPlan.paramsFor(1, 31);
      final breather = ChapterPlan.paramsFor(1, 35);
      expect(knot.mask, isNotNull);
      expect(breather.width, lessThanOrEqualTo(plain.width));
      expect(breather.targetFill, lessThan(plain.targetFill));
    });

    test('adapt scales fill and clamps to the allowed range', () {
      final easy = ChapterPlan.paramsFor(2, 30, adapt: -3);
      final hard = ChapterPlan.paramsFor(2, 30, adapt: 3);
      expect(hard.targetFill, greaterThan(easy.targetFill));
      expect(hard.width, greaterThanOrEqualTo(easy.width));
      final clamped = ChapterPlan.paramsFor(2, 30, adapt: 99);
      expect(clamped.targetFill, hard.targetFill);
      expect(
        ChapterPlan.paramsFor(1, 1, adapt: -3).width,
        greaterThanOrEqualTo(5),
      );
      expect(
        ChapterPlan.paramsFor(5, 60, adapt: 3).width,
        lessThanOrEqualTo(24),
      );
    });

    test('rotator chapters ask for single-cell arrows', () {
      expect(ChapterPlan.paramsFor(2, 5).singleCellShare, greaterThan(0));
      expect(ChapterPlan.paramsFor(1, 5).singleCellShare, 0);
    });
  });

  test('ids and melody names', () {
    expect(ChapterPlan.idFor(1, 7), 'ch1_l007');
    expect(ChapterPlan.idFor(5, 60), 'ch5_l060');
    expect(ChapterPlan.melodyFor(1, 1), 'ch1_m01');
    expect(ChapterPlan.melodyFor(2, 12), 'ch2_m12');
    expect(
      ChapterPlan.melodyFor(2, 13),
      'ch2_m01',
      reason: '12 melodies rotate',
    );
  });
}
