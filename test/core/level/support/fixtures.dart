import 'package:arrowchime/core/level/models/level.dart';

/// One arrow as level JSON. [body] is tail → head.
Map<String, Object?> arrowJson(
  int id,
  List<List<int>> body,
  String dir, {
  String kind = 'normal',
  String? color,
  int? frozen,
  String? link,
}) => {
  'id': id,
  'body': body,
  'dir': dir,
  'kind': kind,
  'color': ?color,
  'frozen': ?frozen,
  'link': ?link,
};

/// Level JSON with sensible defaults.
Map<String, Object?> levelJson({
  required List<Map<String, Object?>> arrows,
  int width = 5,
  int height = 5,
  int hearts = 3,
  List<String>? mask,
  List<Map<String, Object?>> gates = const [],
  List<Map<String, Object?>> portals = const [],
  List<int>? solution,
  String id = 'fixture',
}) => {
  'schema': 1,
  'id': id,
  'width': width,
  'height': height,
  'mask': mask,
  'hearts': hearts,
  'arrows': arrows,
  'gates': gates,
  'portals': portals,
  'meta': {'solution': ?solution},
};

Level buildLevel({
  required List<Map<String, Object?>> arrows,
  int width = 5,
  int height = 5,
  int hearts = 3,
  List<String>? mask,
  List<Map<String, Object?>> gates = const [],
  List<Map<String, Object?>> portals = const [],
}) => Level.fromJson(
  levelJson(
    arrows: arrows,
    width: width,
    height: height,
    hearts: hearts,
    mask: mask,
    gates: gates,
    portals: portals,
  ),
);

Map<String, Object?> gateJson(int x, int y, String color) => {
  'cell': [x, y],
  'color': color,
};

Map<String, Object?> portalJson(String id, List<int> a, List<int> b) => {
  'id': id,
  'a': a,
  'b': b,
};

/// Three straight arrows, all free (`sample_tutorial` shape).
Level freeTrio() => buildLevel(
  arrows: [
    arrowJson(0, [
      [0, 1],
      [1, 1],
    ], 'R'),
    arrowJson(1, [
      [2, 4],
      [2, 3],
    ], 'U'),
    arrowJson(2, [
      [4, 4],
      [4, 3],
    ], 'U'),
  ],
);

/// Arrow 0 is blocked by arrow 1 two cells ahead; arrow 1 is free.
Level blockedPair({int hearts = 3}) => buildLevel(
  hearts: hearts,
  arrows: [
    arrowJson(0, [
      [0, 0],
      [1, 0],
    ], 'R'),
    arrowJson(1, [
      [3, 0],
      [3, 1],
    ], 'D'),
  ],
);

/// Rotator at (2,2) facing up, blocked by arrow 1 at (2,0); arrow 1 is free.
Level rotatorPair() => buildLevel(
  arrows: [
    arrowJson(
      0,
      [
        [2, 2],
      ],
      'U',
      kind: 'rotator',
    ),
    arrowJson(1, [
      [2, 0],
    ], 'R'),
  ],
);

/// Arrow 0 frozen for 2 removals; arrows 1 and 2 are free.
Level frozenTrio() => buildLevel(
  arrows: [
    arrowJson(
      0,
      [
        [0, 0],
      ],
      'L',
      frozen: 2,
    ),
    arrowJson(1, [
      [2, 2],
    ], 'U'),
    arrowJson(2, [
      [4, 4],
    ], 'D'),
  ],
);

/// Arrow 0's ray crosses an amber gate; arrow 1 is the amber key.
Level gateAndKey() => buildLevel(
  arrows: [
    arrowJson(0, [
      [0, 0],
      [1, 0],
    ], 'R'),
    arrowJson(
      1,
      [
        [4, 4],
      ],
      'D',
      kind: 'key',
      color: 'amber',
    ),
  ],
  gates: [gateJson(2, 0, 'amber')],
);

/// Linked pair 0 + 1; arrow 1's ray is blocked by arrow 2 (free).
Level linkedPair() => buildLevel(
  arrows: [
    arrowJson(
      0,
      [
        [0, 2],
        [1, 2],
      ],
      'R',
      link: 'L1',
    ),
    arrowJson(
      1,
      [
        [0, 4],
        [1, 4],
      ],
      'R',
      link: 'L1',
    ),
    arrowJson(2, [
      [3, 4],
    ], 'D'),
  ],
);

/// Arrow 0 sends its ray through portal P1 and is blocked by arrow 1 behind
/// the exit.
Level portalLevel() => buildLevel(
  width: 7,
  height: 3,
  arrows: [
    arrowJson(0, [
      [0, 1],
    ], 'R'),
    arrowJson(1, [
      [5, 0],
    ], 'U'),
  ],
  portals: [
    portalJson('P1', [2, 1], [4, 0]),
  ],
);

/// A ray that cycles through two portal pairs forever.
Level portalLoopLevel() => buildLevel(
  height: 3,
  arrows: [
    arrowJson(0, [
      [1, 0],
    ], 'R'),
  ],
  portals: [
    portalJson('P1', [2, 0], [0, 1]),
    portalJson('P2', [1, 1], [0, 0]),
  ],
);

/// Rotator at (2,2) boxed in by four arrows that each point at it. Nothing
/// inside the box can ever move: unsolvable.
List<Map<String, Object?>> deadlockBox({int firstId = 0}) => [
  arrowJson(
    firstId,
    [
      [2, 2],
    ],
    'U',
    kind: 'rotator',
  ),
  arrowJson(firstId + 1, [
    [2, 1],
  ], 'D'),
  arrowJson(firstId + 2, [
    [2, 3],
  ], 'U'),
  arrowJson(firstId + 3, [
    [1, 2],
  ], 'R'),
  arrowJson(firstId + 4, [
    [3, 2],
  ], 'L'),
];

/// Rotator R (id 0, up) with B (id 1, right of it, facing left) and a free
/// distant arrow X (id 2). Tapping X first turns R to face B and deadlocks
/// both; tapping R first is fine: a trap for the search solver.
Level rotatorTrap() => buildLevel(
  arrows: [
    arrowJson(
      0,
      [
        [2, 2],
      ],
      'U',
      kind: 'rotator',
    ),
    arrowJson(1, [
      [3, 2],
    ], 'L'),
    arrowJson(2, [
      [0, 0],
    ], 'L'),
  ],
);
