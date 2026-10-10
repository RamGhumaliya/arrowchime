import 'package:arrowchime/core/level/level_validator.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

List<String> issuesOf({
  required List<Map<String, Object?>> arrows,
  int width = 5,
  int height = 5,
  List<String>? mask,
  List<Map<String, Object?>> gates = const [],
  List<Map<String, Object?>> portals = const [],
}) => validateLevel(
  Level.fromJson(
    levelJson(
      arrows: arrows,
      width: width,
      height: height,
      mask: mask,
      gates: gates,
      portals: portals,
    ),
  ),
);

void main() {
  group('valid levels', () {
    test('fixtures are valid', () {
      for (final level in [
        freeTrio(),
        blockedPair(),
        rotatorPair(),
        frozenTrio(),
        gateAndKey(),
        linkedPair(),
        portalLevel(),
        rotatorTrap(),
      ]) {
        expect(validateLevel(level), isEmpty, reason: level.id);
      }
    });
  });

  group('structure', () {
    final cases = <String, List<String> Function()>{
      'mask has 2 rows': () => issuesOf(
        mask: ['11111', '11111'],
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
      ),
      'every mask row must have length 5': () => issuesOf(
        mask: ['11111', '11111', '1111', '11111', '11111'],
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
      ),
      'duplicate arrow id 0': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
          arrowJson(0, [
            [4, 4],
          ], 'D'),
        ],
      ),
      'outside the board': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [5, 0],
          ], 'L'),
        ],
      ),
      'masked out': () => issuesOf(
        mask: ['01111', '11111', '11111', '11111', '11111'],
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
      ),
      'body revisits cell': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
            [0, 0],
          ], 'D'),
        ],
      ),
      'overlaps arrow 0': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
          ], 'D'),
          arrowJson(1, [
            [1, 0],
            [2, 0],
          ], 'D'),
        ],
      ),
      'are not adjacent': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [2, 0],
          ], 'D'),
        ],
      ),
      'head points back into its own body': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
            [1, 0],
          ], 'L'),
        ],
      ),
      'rotator must have a single-cell body': () => issuesOf(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
              [1, 0],
            ],
            'R',
            kind: 'rotator',
          ),
        ],
      ),
      'switcher must have a single-cell body': () => issuesOf(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
              [1, 0],
            ],
            'R',
            kind: 'switcher',
          ),
        ],
      ),
      'key arrow needs a colour': () => issuesOf(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
            ],
            'L',
            kind: 'key',
          ),
        ],
      ),
      'only key arrows carry a colour': () => issuesOf(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
            ],
            'L',
            color: 'amber',
          ),
        ],
      ),
      'link L1 has 1 arrows, expected exactly 2': () => issuesOf(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
            ],
            'L',
            link: 'L1',
          ),
        ],
      ),
      'gate at (5,0) is outside': () => issuesOf(
        width: 8,
        mask: ['11111011', '11111111', '11111111', '11111111', '11111111'],
        arrows: [
          arrowJson(0, [
            [0, 4],
          ], 'L'),
        ],
        gates: [gateJson(5, 0, 'amber')],
      ),
      'sits on arrow 0': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        gates: [gateJson(0, 0, 'amber')],
      ),
      'two gates at (2,2)': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        gates: [gateJson(2, 2, 'amber'), gateJson(2, 2, 'jade')],
      ),
      'duplicate portal id P1': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        portals: [
          portalJson('P1', [1, 1], [2, 2]),
          portalJson('P1', [3, 3], [4, 4]),
        ],
      ),
      'ends are the same cell': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        portals: [
          portalJson('P1', [1, 1], [1, 1]),
        ],
      ),
      'portal P1: (0,0) sits on arrow 0': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        portals: [
          portalJson('P1', [0, 0], [2, 2]),
        ],
      ),
      'sits on a gate': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        gates: [gateJson(2, 2, 'amber')],
        portals: [
          portalJson('P1', [1, 1], [2, 2]),
        ],
      ),
      'is reused': () => issuesOf(
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        portals: [
          portalJson('P1', [1, 1], [2, 2]),
          portalJson('P2', [2, 2], [3, 3]),
        ],
      ),
      'portal P1: (9,9) is outside': () => issuesOf(
        width: 10,
        height: 10,
        mask: [for (var y = 0; y < 9; y++) '1111111111', '1111111110'],
        arrows: [
          arrowJson(0, [
            [0, 0],
          ], 'L'),
        ],
        portals: [
          portalJson('P1', [9, 9], [2, 2]),
        ],
      ),
    };
    for (final MapEntry(key: fragment, value: run) in cases.entries) {
      test('reports: $fragment', () {
        final issues = run();
        expect(
          issues.any((i) => i.contains(fragment)),
          isTrue,
          reason: 'got $issues',
        );
      });
    }
  });

  group('rays', () {
    test('an exit ray crossing its own body is rejected', () {
      // U-shaped arrow whose head points back across its own tail.
      final issues = issuesOf(
        arrows: [
          arrowJson(0, [
            [3, 1],
            [3, 2],
            [2, 2],
            [1, 2],
          ], 'U'),
          arrowJson(1, [
            [1, 3],
            [1, 4],
          ], 'D'),
        ],
      );
      expect(issues, isEmpty, reason: 'ray goes up from (1,2): clear');

      final crossing = issuesOf(
        arrows: [
          arrowJson(0, [
            [2, 0],
            [2, 1],
            [3, 1],
            [3, 2],
            [2, 2],
          ], 'U'),
        ],
      );
      expect(
        crossing.any((i) => i.contains('crosses its own body')),
        isTrue,
        reason: '$crossing',
      );
    });

    test('a portal cycle is rejected', () {
      final issues = validateLevel(portalLoopLevel());
      expect(issues.any((i) => i.contains('loops through portals')), isTrue);
    });
  });
}
