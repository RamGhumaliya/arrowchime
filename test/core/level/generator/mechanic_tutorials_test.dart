import 'dart:io';

import 'package:arrowchime/core/level/generator/mechanic_tutorials.dart';
import 'package:arrowchime/core/level/level_checker.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mechanic tutorials (docs/03 §5-6: one new idea per level)', () {
    test('five slots: where each mechanic first appears', () {
      expect(MechanicTutorials.slots, hasLength(5));
      expect(MechanicTutorials.at(2, 1), Mechanic.rotator);
      expect(MechanicTutorials.at(3, 1), Mechanic.gateKey);
      expect(MechanicTutorials.at(4, 1), Mechanic.frozen);
      expect(MechanicTutorials.at(5, 1), Mechanic.link);
      expect(MechanicTutorials.at(5, 20), Mechanic.portal);
      expect(MechanicTutorials.at(1, 1), isNull);
      expect(() => MechanicTutorials.build(1, 1), throwsArgumentError);
    });

    for (final entry in MechanicTutorials.slots.entries) {
      final (chapter, index) = entry.key;
      test(
        '${entry.value.name} at ch$chapter L$index is small, single-mechanic '
        'and solvable',
        () {
          final level = MechanicTutorials.build(chapter, index);
          expect(MechanicTutorials.mechanicsOf(level), {entry.value});
          expect(level.arrows.length, inInclusiveRange(5, 12));
          expect(level.width, lessThanOrEqualTo(8));
          expect(level.meta.generatorVersion, MechanicTutorials.version);
          expect(level.id, 'ch${chapter}_l${index.toString().padLeft(3, '0')}');
          final check = LevelChecker.checkLevel(level);
          expect(check.errors, isEmpty);
        },
      );

      test(
        'the shipped pack ch$chapter holds exactly that level at L$index',
        () {
          final pack = PackLoader.parsePack(
            File('assets/levels/ch$chapter.json').readAsStringSync(),
          );
          final shipped = pack.levels[index - 1];
          expect(
            shipped.toJson(),
            MechanicTutorials.build(chapter, index).toJson(),
          );
        },
      );
    }

    test('deterministic: building twice gives the same level', () {
      expect(
        MechanicTutorials.build(3, 1).toJson(),
        MechanicTutorials.build(3, 1).toJson(),
      );
    });

    test('no other level of the chapters is a tutorial', () {
      for (var c = 2; c <= 5; c++) {
        final pack = PackLoader.parsePack(
          File('assets/levels/ch$c.json').readAsStringSync(),
        );
        for (final level in pack.levels) {
          final isSlot = MechanicTutorials.at(c, level.index!) != null;
          expect(
            level.meta.generatorVersion == MechanicTutorials.version,
            isSlot,
          );
        }
      }
    });
  });
}
