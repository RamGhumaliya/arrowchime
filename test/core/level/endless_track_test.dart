import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/pack_builder.dart';
import 'package:arrowchime/core/level/level_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the endless track (stages beyond the five authored ones)', () {
    test('later stages reuse the last authored band and mechanics', () {
      expect(ChapterPlan.planOf(0), 1);
      expect(ChapterPlan.planOf(5), 5);
      expect(ChapterPlan.planOf(6), 5);
      expect(ChapterPlan.planOf(40), 5);
      expect(ChapterPlan.targetScore(9, 30), ChapterPlan.targetScore(5, 30));
      expect(ChapterPlan.melodyFor(8, 3), 'ch5_m03');
    });

    test('generated levels are valid, solvable and deterministic', () {
      for (final (chapter, index) in const [(6, 7), (6, 30), (12, 45)]) {
        final a = PackBuilder.buildLevel(chapter, index, 1001).level;
        final b = PackBuilder.buildLevel(chapter, index, 1001).level;
        expect(a.toJson(), b.toJson(), reason: 'ch$chapter l$index');
        final result = LevelChecker.checkLevel(a);
        expect(result.errors, isEmpty, reason: 'ch$chapter l$index');
      }
    });

    test('different stages give different levels', () {
      final a = PackBuilder.buildLevel(6, 10, 1001).level;
      final b = PackBuilder.buildLevel(7, 10, 1001).level;
      expect(a.toJson(), isNot(b.toJson()));
    });
  });
}
