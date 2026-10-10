import 'package:arrowchime/core/level/engine/events.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

List<Type> types(List<GameEvent> events) => [
  for (final e in events) e.runtimeType,
];

T only<T extends GameEvent>(List<GameEvent> events) =>
    events.whereType<T>().single;

void main() {
  group('G1 free tap', () {
    test('removes the arrow immediately and emits ArrowFreed', () {
      final engine = GameEngine(freeTrio());
      expect(engine.remaining, 3);
      expect(engine.isFree(0), isTrue);

      final events = engine.tap(0);

      expect(types(events), [ArrowFreed]);
      final freed = only<ArrowFreed>(events);
      expect(freed.arrowId, 0);
      expect(freed.dir, Direction.right);
      expect(freed.viaLink, isFalse);
      expect(freed.paths, [
        [const Cell(2, 1), const Cell(3, 1), const Cell(4, 1)],
      ]);
      expect(engine.remaining, 2);
      expect(engine.remainingIds, [1, 2]);
      expect(engine.status, GameStatus.playing);
      expect(engine.hearts, 3);
      expect(engine.stats.freedTaps, 1);
    });

    test('tapping an already removed or unknown arrow does nothing', () {
      final engine = GameEngine(freeTrio())..tap(0);
      expect(engine.tap(0), isEmpty);
      expect(engine.tap(99), isEmpty);
      expect(engine.isFree(0), isFalse);
      expect(engine.isFree(99), isFalse);
      expect(engine.dirOf(0), isNull);
      expect(engine.dirOf(99), isNull);
      expect(engine.exitPaths(0), isEmpty);
      expect(engine.exitPaths(99), isEmpty);
      expect(engine.frozenCounter(99), 0);
    });

    test('queries: free ids, direction, exit path (peek)', () {
      final engine = GameEngine(blockedPair());
      expect(engine.freeArrowIds, [1]);
      expect(engine.dirOf(0), Direction.right);
      expect(engine.exitPaths(0), [
        [const Cell(2, 0), const Cell(3, 0), const Cell(4, 0)],
      ]);
    });
  });

  group('G2/G3 blocked tap', () {
    test('costs a heart and reports the blocker', () {
      final engine = GameEngine(blockedPair());

      final events = engine.tap(0);

      expect(types(events), [BlockedTap, HeartLost]);
      final b = only<BlockedTap>(events);
      expect(b.arrowId, 0);
      expect(b.blockedArrowId, 0);
      expect(b.blockerType, BlockerType.arrow);
      expect(b.blockerArrowId, 1);
      expect(b.blockerCell, const Cell(3, 0));
      expect(b.distance, 2);
      expect(only<HeartLost>(events).heartsLeft, 2);
      expect(engine.hearts, 2);
      expect(engine.remaining, 2, reason: 'a blocked tap removes nothing');
      expect(engine.stats.blockedTaps, 1);
    });

    test('last heart lost ends the level; later taps are ignored', () {
      final engine = GameEngine(blockedPair(hearts: 1));

      final events = engine.tap(0);

      expect(types(events), [BlockedTap, HeartLost, LevelLost]);
      expect(engine.status, GameStatus.lost);
      expect(engine.hearts, 0);
      expect(engine.tap(1), isEmpty);
      expect(engine.canUndo, isFalse);
      expect(engine.undo(), isEmpty);
    });

    test('reset restores board, hearts and history', () {
      final engine = GameEngine(blockedPair(hearts: 1))
        ..tap(0)
        ..reset();
      expect(engine.status, GameStatus.playing);
      expect(engine.hearts, 1);
      expect(engine.remaining, 2);
      expect(engine.canUndo, isFalse);
      expect(engine.stats.blockedTaps, 0);
      expect(engine.tap(1), isNotEmpty);
    });

    test('blocked by a closed gate reports the gate cell', () {
      final engine = GameEngine(gateAndKey());
      final b = only<BlockedTap>(engine.tap(0));
      expect(b.blockerType, BlockerType.gate);
      expect(b.blockerArrowId, isNull);
      expect(b.blockerCell, const Cell(2, 0));
      expect(b.distance, 1);
    });

    test('a portal cycle blocks forever with no blocker cell arrow', () {
      final engine = GameEngine(portalLoopLevel());
      final b = only<BlockedTap>(engine.tap(0));
      expect(b.blockerType, BlockerType.loop);
      expect(b.blockerArrowId, isNull);
      expect(engine.hearts, 2);
    });
  });

  group('G4 win', () {
    test('last arrow emits LevelWon once; later taps do nothing', () {
      final engine = GameEngine(freeTrio())
        ..tap(0)
        ..tap(1);
      final events = engine.tap(2);

      expect(types(events), [ArrowFreed, LevelWon]);
      final won = only<LevelWon>(events);
      expect(won.stars, 3);
      expect(won.heartsLeft, 3);
      expect(engine.status, GameStatus.won);
      expect(engine.tap(2), isEmpty);
      expect(engine.tap(0), isEmpty);
      expect(engine.canUndo, isFalse);
    });

    test('G5 rapid taps are processed in order against current state', () {
      final engine = GameEngine(blockedPair());
      // Tap blocked arrow 0, then free arrow 1, then arrow 0 again.
      expect(types(engine.tap(0)), [BlockedTap, HeartLost]);
      expect(types(engine.tap(1)), [ArrowFreed]);
      final last = engine.tap(0);
      expect(types(last), [ArrowFreed, LevelWon]);
      expect(only<LevelWon>(last).stars, 2);
    });
  });

  group('stars', () {
    test('3 hearts left = 3 stars, 2 = 2, 1 = 1', () {
      for (final lost in [0, 1, 2]) {
        final engine = GameEngine(blockedPair());
        for (var i = 0; i < lost; i++) {
          engine.tap(0);
        }
        engine.tap(1);
        final events = engine.tap(0);
        expect(only<LevelWon>(events).stars, 3 - lost, reason: 'lost=$lost');
      }
    });

    test('hearts override changes the budget; stars follow hearts lost', () {
      final engine = GameEngine(
        blockedPair(),
        options: const EngineOptions(hearts: 5),
      );
      expect(engine.initialHearts, 5);
      engine.tap(0);
      expect(engine.hearts, 4);
      expect(engine.stars, 2);
    });

    test('stars never drop below one', () {
      final engine = GameEngine(
        blockedPair(),
        options: const EngineOptions(hearts: 9),
      );
      for (var i = 0; i < 8; i++) {
        engine.tap(0);
      }
      expect(engine.hearts, 1);
      expect(engine.stars, 1);
    });
  });

  group('G16 relaxed mode', () {
    test('blocked tap costs no heart; stars capped at two', () {
      final engine = GameEngine(
        blockedPair(),
        options: const EngineOptions(relaxed: true),
      );
      expect(types(engine.tap(0)), [BlockedTap]);
      expect(engine.hearts, 3);
      engine.tap(1);
      final won = only<LevelWon>(engine.tap(0));
      expect(won.stars, 2);
    });

    test('relaxed never loses the level', () {
      final engine = GameEngine(
        blockedPair(hearts: 1),
        options: const EngineOptions(relaxed: true),
      );
      for (var i = 0; i < 5; i++) {
        engine.tap(0);
      }
      expect(engine.status, GameStatus.playing);
    });

    test('a lower star count is not raised by the cap', () {
      final engine = GameEngine(
        blockedPair(hearts: 2),
        options: const EngineOptions(hearts: 2, relaxed: true),
      );
      expect(engine.stars, 2);
    });
  });

  group('G7 rotator', () {
    test('every removal turns each rotator 90 degrees clockwise', () {
      final engine = GameEngine(rotatorPair());
      expect(engine.dirOf(0), Direction.up);
      expect(engine.isFree(0), isFalse, reason: 'blocked by arrow 1');

      final events = engine.tap(1);

      final turned = only<RotatorsTurned>(events);
      expect(turned.dirs, {0: Direction.right});
      expect(engine.dirOf(0), Direction.right);
      expect(engine.isFree(0), isTrue);
    });

    test('directions cycle U, R, D, L, U', () {
      final level = buildLevel(
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
            [0, 0],
          ], 'L'),
          arrowJson(2, [
            [0, 4],
          ], 'L'),
          arrowJson(3, [
            [4, 0],
          ], 'U'),
          arrowJson(4, [
            [4, 4],
          ], 'D'),
        ],
      );
      final engine = GameEngine(level);
      final seen = <Direction>[];
      for (final id in [1, 2, 3, 4]) {
        engine.tap(id);
        seen.add(engine.dirOf(0)!);
      }
      expect(seen, [
        Direction.right,
        Direction.down,
        Direction.left,
        Direction.up,
      ]);
    });
  });

  group('G8 key and gate', () {
    test('removing the key opens every gate of its colour', () {
      final engine = GameEngine(gateAndKey());
      expect(engine.isFree(0), isFalse);

      final events = engine.tap(1);

      final opened = only<GateOpened>(events);
      expect(opened.color, GateColor.amber);
      expect(opened.cells, [const Cell(2, 0)]);
      expect(engine.isFree(0), isTrue);
    });

    test('a key whose colour has no gate opens nothing', () {
      final level = buildLevel(
        arrows: [
          arrowJson(
            0,
            [
              [4, 4],
            ],
            'D',
            kind: 'key',
            color: 'jade',
          ),
          arrowJson(1, [
            [0, 0],
          ], 'L'),
        ],
      );
      final engine = GameEngine(level);
      expect(types(engine.tap(0)), [ArrowFreed]);
    });

    test('a second key of an already open colour opens nothing new', () {
      final level = buildLevel(
        arrows: [
          arrowJson(
            0,
            [
              [4, 4],
            ],
            'D',
            kind: 'key',
            color: 'amber',
          ),
          arrowJson(
            1,
            [
              [0, 4],
            ],
            'D',
            kind: 'key',
            color: 'amber',
          ),
          arrowJson(2, [
            [0, 0],
            [1, 0],
          ], 'R'),
        ],
        gates: [gateJson(2, 0, 'amber')],
      );
      final engine = GameEngine(level);
      expect(types(engine.tap(0)), [ArrowFreed, GateOpened]);
      expect(types(engine.tap(1)), [ArrowFreed]);
    });

    test('a gate of another colour keeps blocking', () {
      final level = buildLevel(
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
            color: 'jade',
          ),
        ],
        gates: [gateJson(2, 0, 'amber')],
      );
      final engine = GameEngine(level)..tap(1);
      expect(engine.isFree(0), isFalse);
    });
  });

  group('G9 frozen', () {
    test('tapping a frozen arrow shakes it and costs no heart', () {
      final engine = GameEngine(frozenTrio());

      final events = engine.tap(0);

      expect(types(events), [FrozenTapped]);
      expect(only<FrozenTapped>(events).counter, 2);
      expect(engine.hearts, 3);
      expect(engine.remaining, 3);
      expect(engine.frozenCounter(0), 2);
      expect(engine.stats.frozenTaps, 1);
    });

    test('each removal ticks the counter down; thawed arrow can leave', () {
      final engine = GameEngine(frozenTrio());

      final first = engine.tap(1);
      expect(only<FrozenTicked>(first).counters, {0: 1});
      final second = engine.tap(2);
      expect(only<FrozenTicked>(second).counters, {0: 0});

      expect(engine.frozenCounter(0), 0);
      expect(types(engine.tap(0)), [ArrowFreed, LevelWon]);
    });
  });

  group('G10 linked pair', () {
    test('one blocked partner makes the tap a blocked tap', () {
      final engine = GameEngine(linkedPair());

      final events = engine.tap(0);

      final b = only<BlockedTap>(events);
      expect(b.arrowId, 0);
      expect(b.blockedArrowId, 1, reason: 'the partner is the blocked one');
      expect(b.blockerArrowId, 2);
      expect(b.distance, 2);
      expect(engine.hearts, 2);
      expect(engine.isFree(0), isFalse);
      expect(engine.isFree(1), isFalse);
    });

    test('when both are free, tapping either moves both', () {
      final engine = GameEngine(linkedPair())..tap(2);

      final events = engine.tap(1);

      expect(types(events), [ArrowFreed, ArrowFreed, LevelWon]);
      final freed = events.whereType<ArrowFreed>().toList();
      expect([for (final f in freed) f.arrowId], [1, 0]);
      expect([for (final f in freed) f.viaLink], [false, true]);
      expect(engine.remaining, 0);
    });

    test('a frozen partner blocks the pair without costing frozen shake', () {
      final level = buildLevel(
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
            frozen: 1,
          ),
          arrowJson(2, [
            [4, 0],
          ], 'U'),
        ],
      );
      final engine = GameEngine(level);

      final events = engine.tap(0);

      final b = only<BlockedTap>(events);
      expect(b.blockerType, BlockerType.frozenPartner);
      expect(b.blockerArrowId, 1);
      expect(b.blockedArrowId, 1);
      expect(b.blockerCell, isNull);
      expect(b.distance, 0);
      expect(engine.hearts, 2);

      engine.tap(2);
      expect(engine.frozenCounter(1), 0);
      expect(types(engine.tap(0)), [ArrowFreed, ArrowFreed, LevelWon]);
    });
  });

  group('G11 portals', () {
    test('ray continues out of the paired portal', () {
      final engine = GameEngine(portalLevel());

      expect(engine.exitPaths(0), [
        [
          const Cell(1, 1),
          const Cell(2, 1),
          const Cell(4, 0),
          const Cell(5, 0),
          const Cell(6, 0),
        ],
      ], reason: 'peek shows the whole route, portal as entry + exit');
      final b = only<BlockedTap>(engine.tap(0));
      expect(b.blockerArrowId, 1);
      expect(b.distance, 3);

      engine.tap(1);
      final freed = only<ArrowFreed>(engine.tap(0));
      expect(freed.paths, [
        [
          const Cell(1, 1),
          const Cell(2, 1),
          const Cell(4, 0),
          const Cell(5, 0),
          const Cell(6, 0),
        ],
      ]);
    });
  });

  group('masks', () {
    test('void cells are empty space the ray flies over', () {
      final level = buildLevel(
        mask: ['11111', '11111', '11011', '11111', '11111'],
        arrows: [
          arrowJson(0, [
            [0, 2],
            [1, 2],
          ], 'R'),
        ],
      );
      final engine = GameEngine(level);
      final freed = only<ArrowFreed>(engine.tap(0));
      expect(freed.paths.single, contains(const Cell(2, 2)));
    });
  });

  group('G6 undo', () {
    test('restores the removed arrow, rotators, counters and gates', () {
      final level = buildLevel(
        arrows: [
          arrowJson(
            0,
            [
              [2, 2],
            ],
            'U',
            kind: 'rotator',
          ),
          arrowJson(
            1,
            [
              [4, 4],
            ],
            'D',
            kind: 'key',
            color: 'amber',
          ),
          arrowJson(
            2,
            [
              [0, 0],
            ],
            'L',
            frozen: 3,
          ),
          arrowJson(3, [
            [0, 3],
            [1, 3],
          ], 'R'),
        ],
        gates: [gateJson(3, 3, 'amber')],
      );
      final engine = GameEngine(level);
      final before = engine.state.key;
      final dirBefore = engine.dirOf(0);

      engine.tap(1);
      expect(engine.canUndo, isTrue);
      expect(engine.undoDepth, 1);
      expect(engine.dirOf(0), isNot(dirBefore));
      expect(engine.frozenCounter(2), 2);

      final events = engine.undo();

      expect(types(events), [UndoApplied]);
      expect(only<UndoApplied>(events).restoredArrowIds, [1]);
      expect(engine.state.key, before);
      expect(engine.dirOf(0), dirBefore);
      expect(engine.frozenCounter(2), 3);
      expect(engine.remaining, 4);
      expect(engine.stats.undos, 1);
      expect(engine.canUndo, isFalse);
    });

    test('does not restore hearts and can be repeated step by step', () {
      final engine = GameEngine(blockedPair())
        ..tap(0) // blocked: -1 heart
        ..tap(1);
      expect(engine.hearts, 2);
      engine.undo();
      expect(engine.hearts, 2, reason: 'hearts are not refunded');
      expect(engine.remaining, 2);
      expect(engine.tap(1), isNotEmpty, reason: 'the arrow can be re-tapped');
    });

    test('restores both arrows of a linked pair', () {
      final engine = GameEngine(linkedPair())
        ..tap(2)
        ..tap(0);
      expect(engine.status, GameStatus.won);
      // Undo is refused once the level is won.
      expect(engine.undo(), isEmpty);
    });

    test('undo of a linked removal brings both back', () {
      final level = buildLevel(
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
            [4, 0],
          ], 'U'),
        ],
      );
      final engine = GameEngine(level)..tap(0);
      expect(engine.remaining, 1);
      final restored = only<UndoApplied>(engine.undo()).restoredArrowIds;
      expect(restored, [0, 1]);
    });

    test('nothing to undo returns no events', () {
      expect(GameEngine(freeTrio()).undo(), isEmpty);
    });
  });

  group('switcher (flag)', () {
    Level switcherLevel() => buildLevel(
      arrows: [
        arrowJson(
          0,
          [
            [2, 2],
          ],
          'U',
          kind: 'switcher',
        ),
        arrowJson(1, [
          [3, 2],
        ], 'R'),
        arrowJson(2, [
          [2, 3],
          [2, 4],
        ], 'D'),
        arrowJson(3, [
          [0, 0],
        ], 'L'),
      ],
    );

    test('flips adjacent single-cell arrows 180 degrees', () {
      final engine = GameEngine(
        switcherLevel(),
        options: const EngineOptions(enableSwitcher: true),
      );

      final events = engine.tap(0);

      expect(only<ArrowsFlipped>(events).dirs, {1: Direction.left});
      expect(engine.dirOf(1), Direction.left);
      expect(engine.dirOf(2), Direction.down, reason: 'two-cell arrow stays');
      expect(engine.dirOf(3), Direction.left, reason: 'not adjacent');
    });

    test('with the flag off a switcher is an ordinary arrow', () {
      final engine = GameEngine(switcherLevel());
      final events = engine.tap(0);
      expect(types(events), [ArrowFreed]);
      expect(engine.dirOf(1), Direction.right);
    });

    test('switchers at the board edge only flip in-bounds neighbours', () {
      final level = buildLevel(
        arrows: [
          arrowJson(
            0,
            [
              [0, 0],
            ],
            'L',
            kind: 'switcher',
          ),
          arrowJson(1, [
            [1, 0],
          ], 'U'),
          arrowJson(2, [
            [0, 1],
          ], 'L'),
        ],
      );
      final engine = GameEngine(
        level,
        options: const EngineOptions(enableSwitcher: true),
      );
      final flipped = only<ArrowsFlipped>(engine.tap(0));
      expect(flipped.dirs, {1: Direction.down, 2: Direction.right});
    });
  });

  group('splitter (flag)', () {
    Level splitterLevel({bool blockLeft = false}) => buildLevel(
      arrows: [
        arrowJson(
          0,
          [
            [2, 2],
          ],
          'U',
          kind: 'splitter',
        ),
        if (blockLeft)
          arrowJson(1, [
            [0, 2],
          ], 'U')
        else
          arrowJson(1, [
            [0, 0],
          ], 'L'),
        if (blockLeft)
          arrowJson(2, [
            [0, 3],
          ], 'D'),
      ],
    );

    test('free only if both perpendicular rays are clear', () {
      final engine = GameEngine(
        splitterLevel(blockLeft: true),
        options: const EngineOptions(enableSplitter: true),
      );
      // Arrow 1 at (0,2) sits on the splitter's left ray and faces up.
      final blocked = only<BlockedTap>(engine.tap(0));
      expect(blocked.blockerArrowId, 1);
    });

    test('exits as two halves along both rays', () {
      final engine = GameEngine(
        splitterLevel(),
        options: const EngineOptions(enableSplitter: true),
      );
      final freed = only<ArrowFreed>(engine.tap(0));
      expect(freed.paths, hasLength(2));
      expect(freed.paths[0], [const Cell(3, 2), const Cell(4, 2)]);
      expect(freed.paths[1], [const Cell(1, 2), const Cell(0, 2)]);
      expect(engine.exitPaths(0), isEmpty, reason: 'already removed');
    });

    test('with the flag off a splitter uses its single ray', () {
      final engine = GameEngine(splitterLevel(blockLeft: true));
      final freed = only<ArrowFreed>(engine.tap(0));
      expect(freed.paths, hasLength(1));
      expect(freed.paths.single, [const Cell(2, 1), const Cell(2, 0)]);
    });
  });
}
