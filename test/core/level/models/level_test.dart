import 'dart:convert';
import 'dart:io';

import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

Map<String, Object?> base() => levelJson(
  arrows: [
    arrowJson(0, [
      [0, 0],
      [1, 0],
    ], 'R'),
  ],
);

Map<String, Object?> arrowOf(Map<String, Object?> level) =>
    (level['arrows']! as List).first as Map<String, Object?>;

void main() {
  group('Direction', () {
    test('clockwise, opposite, perpendicular', () {
      expect(Direction.up.clockwise, Direction.right);
      expect(Direction.left.clockwise, Direction.up);
      expect(Direction.up.opposite, Direction.down);
      expect(Direction.right.perpendicular, [Direction.down, Direction.up]);
    });

    test('codes round-trip', () {
      for (final d in Direction.values) {
        expect(Direction.fromCode(d.code), d);
      }
      expect(Direction.fromCode('X'), isNull);
    });
  });

  group('Cell', () {
    test('equality, step, adjacency', () {
      expect(const Cell(1, 2), const Cell(1, 2));
      expect(const Cell(1, 2).hashCode, const Cell(1, 2).hashCode);
      expect(const Cell(1, 2), isNot(const Cell(2, 1)));
      expect(const Cell(1, 2).step(Direction.up), const Cell(1, 1));
      expect(const Cell(1, 2).isAdjacentTo(const Cell(1, 3)), isTrue);
      expect(const Cell(1, 2).isAdjacentTo(const Cell(2, 3)), isFalse);
      expect(const Cell(1, 2).toString(), '(1,2)');
    });
  });

  group('enums', () {
    test('lookup by name', () {
      expect(ArrowKind.fromName('key'), ArrowKind.key);
      expect(ArrowKind.fromName('nope'), isNull);
      expect(GateColor.fromName('jade'), GateColor.jade);
      expect(GateColor.fromName('pink'), isNull);
    });
  });

  group('Level.fromJson', () {
    test('parses a minimal level', () {
      final level = Level.fromJson(base());
      expect(level.id, 'fixture');
      expect(level.width, 5);
      expect(level.hearts, 3);
      expect(level.mask, isNull);
      expect(level.arrows.single.tail, const Cell(0, 0));
      expect(level.arrows.single.head, const Cell(1, 0));
      expect(level.meta.solution, isEmpty);
      expect(level.chapter, isNull);
    });

    test('parses every optional field', () {
      final json =
          levelJson(
              arrows: [
                arrowJson(
                  0,
                  [
                    [0, 0],
                  ],
                  'U',
                  kind: 'key',
                  color: 'rose',
                  frozen: 2,
                  link: 'L1',
                ),
              ],
              mask: ['11111', '11111', '11111', '11111', '11111'],
              gates: [gateJson(2, 2, 'rose')],
              portals: [
                portalJson('P1', [1, 1], [3, 3]),
              ],
            )
            ..['chapter'] = 2
            ..['index'] = 7
            ..[r'$schema'] = 'x'
            ..['meta'] = {
              'seed': 5,
              'generatorVersion': '1',
              'difficulty': 12,
              'depth': 3,
              'solution': [0],
              'melody': 'ch1_m01',
              'approved': true,
            };
      (json['arrows']! as List<Map<String, Object?>>).first['skinHint'] = 4;

      final level = Level.fromJson(json);

      expect(level.chapter, 2);
      expect(level.index, 7);
      expect(level.arrows.single.color, GateColor.rose);
      expect(level.arrows.single.frozen, 2);
      expect(level.arrows.single.link, 'L1');
      expect(level.arrows.single.skinHint, 4);
      expect(level.gates.single.cell, const Cell(2, 2));
      expect(level.portals.single.b, const Cell(3, 3));
      expect(level.meta.difficulty, 12.0);
      expect(level.meta.approved, isTrue);
      expect(level.meta.melody, 'ch1_m01');
    });

    test('toJson round-trips', () {
      final json =
          levelJson(
              arrows: [
                arrowJson(
                  0,
                  [
                    [0, 0],
                    [1, 0],
                  ],
                  'R',
                  kind: 'key',
                  color: 'amber',
                  frozen: 3,
                  link: 'L2',
                ),
              ],
              gates: [gateJson(2, 2, 'amber')],
              portals: [
                portalJson('P1', [1, 1], [3, 3]),
              ],
              mask: ['11111', '11111', '11111', '11111', '11111'],
            )
            ..['chapter'] = 1
            ..['index'] = 4
            ..['meta'] = {
              'seed': 9,
              'generatorVersion': 'g',
              'difficulty': 2.5,
              'depth': 1,
              'solution': [0],
              'melody': 'm',
              'approved': false,
            };
      (json['arrows']! as List<Map<String, Object?>>).first['skinHint'] = 1;
      final once = Level.fromJson(json).toJson();
      expect(jsonDecode(jsonEncode(once)), jsonDecode(jsonEncode(json)));
      expect(Level.fromJson(once).toJson(), once);
    });

    test('withMeta replaces only the metadata', () {
      final level = Level.fromJson(base());
      final changed = level.withMeta(const LevelMeta(seed: 1));
      expect(changed.meta.seed, 1);
      expect(changed.id, level.id);
      expect(changed.arrows, same(level.arrows));
    });

    test('isActive honours bounds and mask', () {
      final level = Level.fromJson(
        levelJson(
          arrows: [
            arrowJson(0, [
              [0, 0],
            ], 'L'),
          ],
          mask: ['11111', '11011', '11111', '11111', '11111'],
        ),
      );
      expect(level.isActive(0, 0), isTrue);
      expect(level.isActive(2, 1), isFalse);
      expect(level.isActive(-1, 0), isFalse);
      expect(level.isActive(0, 5), isFalse);
      expect(level.isActive(5, 0), isFalse);
      expect(level.isActive(0, -1), isFalse);
    });

    final bad = <String, void Function(Map<String, Object?>)>{
      'unknown property': (j) => j['bogus'] = 1,
      'schema must be 1': (j) => j['schema'] = 2,
      'level.schema must be an integer': (j) => j['schema'] = 'one',
      'level.id must be a string': (j) => j['id'] = 4,
      'must match': (j) => j['id'] = 'Bad Id',
      'level.width=2 is out of range': (j) => j['width'] = 2,
      'level.height=41 is out of range': (j) => j['height'] = 41,
      'level.hearts=0 is out of range': (j) => j['hearts'] = 0,
      'level.chapter must be an integer': (j) => j['chapter'] = 'x',
      'level.index=0 is out of range': (j) => j['index'] = 0,
      'mask must be null or a list': (j) => j['mask'] = 'x',
      'mask rows': (j) => j['mask'] = ['12'],
      'arrows must be a non-empty list': (j) => j['arrows'] = <Object?>[],
      'arrows[0] must be an object': (j) => j['arrows'] = [1],
      'arrows[0] has unknown property': (j) => arrowOf(j)['x'] = 1,
      'body must be a list of 1–40 cells': (j) => arrowOf(j)['body'] = [],
      'body[0] must be [x, y]': (j) => arrowOf(j)['body'] = [
        [-1, 0],
      ],
      'dir "Q"': (j) => arrowOf(j)['dir'] = 'Q',
      'kind "wizard"': (j) => arrowOf(j)['kind'] = 'wizard',
      'color "pink"': (j) => arrowOf(j)['color'] = 'pink',
      'frozen=0 is out of range': (j) => arrowOf(j)['frozen'] = 0,
      'link must match L<number>': (j) => arrowOf(j)['link'] = 'X1',
      'must match L<number>': (j) => arrowOf(j)['link'] = 5,
      'skinHint=9 is out of range': (j) => arrowOf(j)['skinHint'] = 9,
      'gates must be a list': (j) => j['gates'] = 'x',
      'gates entries must be objects': (j) => j['gates'] = [1],
      'gates[0] has unknown property': (j) => j['gates'] = [
        {
          'cell': [0, 0],
          'color': 'amber',
          'z': 1,
        },
      ],
      'portals[0].id must be a string': (j) => j['portals'] = [
        {
          'id': 1,
          'a': [0, 0],
          'b': [1, 1],
        },
      ],
      'meta must be an object': (j) => j['meta'] = 3,
      'meta.difficulty must be a number': (j) =>
          j['meta'] = {'difficulty': 'x'},
      'meta.solution must be a list of ints': (j) => j['meta'] = {
        'solution': ['a'],
      },
      'meta.approved must be a bool': (j) => j['meta'] = {'approved': 1},
      'meta.melody must be a string': (j) => j['meta'] = {'melody': 1},
      'meta.generatorVersion must be a string': (j) =>
          j['meta'] = {'generatorVersion': 1},
      'meta.seed must be an integer': (j) => j['meta'] = {'seed': 'x'},
    };
    for (final MapEntry(key: fragment, value: mutate) in bad.entries) {
      test('rejects: $fragment', () {
        final json = base();
        mutate(json);
        expect(
          () => Level.fromJson(json),
          throwsA(
            isA<LevelFormatException>().having(
              (e) => e.message,
              'message',
              contains(fragment),
            ),
          ),
        );
      });
    }

    test('a null meta and missing gates/portals are fine', () {
      final json = base()
        ..['meta'] = null
        ..remove('gates')
        ..remove('portals');
      final level = Level.fromJson(json);
      expect(level.gates, isEmpty);
      expect(level.portals, isEmpty);
    });

    test('LevelFormatException prints its message', () {
      expect(
        const LevelFormatException('boom').toString(),
        'LevelFormatException: boom',
      );
    });
  });

  group('LevelPack', () {
    test('parses sample_levels.json (extra keys allowed)', () {
      final json = jsonDecode(
        File('assets/levels/sample_levels.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final pack = LevelPack.fromJson(json);
      expect(pack.levels, hasLength(3));
      expect(pack.chapter, isNull);
      expect(pack.toJson()['levels'], hasLength(3));
    });

    test('keeps the chapter', () {
      final pack = LevelPack.fromJson({
        'schema': 1,
        'chapter': 3,
        'levels': [base()],
      });
      expect(pack.chapter, 3);
      expect(pack.toJson()['chapter'], 3);
    });

    test('rejects malformed packs', () {
      expect(
        () => LevelPack.fromJson({'schema': 2, 'levels': <Object?>[]}),
        throwsA(isA<LevelFormatException>()),
      );
      expect(
        () => LevelPack.fromJson({'schema': 1, 'levels': 'x'}),
        throwsA(isA<LevelFormatException>()),
      );
      expect(
        () => LevelPack.fromJson({
          'schema': 1,
          'levels': [1],
        }),
        throwsA(isA<LevelFormatException>()),
      );
    });
  });
}
