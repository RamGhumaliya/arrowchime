import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  group('Rules.check', () {
    test('free / blocked / frozen statuses', () {
      final s = BoardState.initial(blockedPair());
      expect(Rules.check(s, 1).status, FreedomStatus.free);
      final blocked = Rules.check(s, 0);
      expect(blocked.status, FreedomStatus.blocked);
      expect(blocked.hit!.type, BlockerType.arrow);
      expect(blocked.hit!.arrowIndex, 1);
      expect(blocked.blockedIndex, 0);

      final f = BoardState.initial(frozenTrio());
      expect(Rules.check(f, 0).status, FreedomStatus.frozen);
      expect(Rules.check(f, 0).isFree, isFalse);
    });

    test('freeArrows lists only living free arrows', () {
      final s = BoardState.initial(blockedPair());
      expect(Rules.freeArrows(s), [1]);
      Rules.remove(s, 1);
      expect(Rules.freeArrows(s), [0]);
    });

    test('an arrow ignores its own body when a ray passes over it', () {
      final s = BoardState.initial(portalLoopLevel());
      expect(Rules.check(s, 0).hit!.type, BlockerType.loop);
    });
  });

  group('Rules.exitPaths / loopsForever', () {
    test('non-blocking path ignores every obstacle', () {
      final s = BoardState.initial(blockedPair());
      expect(Rules.exitPaths(s, 0, blocking: false).single.length, 3);
      expect(Rules.exitPaths(s, 0).single.length, 1);
    });

    test('detects portal cycles', () {
      expect(
        Rules.loopsForever(BoardState.initial(portalLoopLevel()), 0),
        isTrue,
      );
      expect(Rules.loopsForever(BoardState.initial(portalLevel()), 0), isFalse);
    });

    test('splitter checks both rays for cycles', () {
      final s = BoardState.initial(blockedPair());
      expect(
        Rules.loopsForever(
          s,
          0,
          config: const RulesConfig(enableSplitter: true),
        ),
        isFalse,
      );
    });
  });

  group('Rules.remove', () {
    test('reports every side effect in one result', () {
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
              [2, 2],
            ],
            'U',
            kind: 'rotator',
          ),
          arrowJson(
            2,
            [
              [0, 0],
            ],
            'L',
            frozen: 2,
          ),
        ],
        gates: [gateJson(3, 3, 'amber'), gateJson(3, 4, 'amber')],
      );
      final s = BoardState.initial(level);

      final fx = Rules.remove(s, 0);

      expect(fx.removed, [0]);
      expect(fx.frozenTicked, [2]);
      expect(fx.rotated, [1]);
      expect(fx.openedGates.keys, hasLength(1));
      expect(fx.openedGates.values.single, [3 * 5 + 3, 4 * 5 + 3]);
      expect(fx.flipped, isEmpty);
      expect(s.dirOf(1), Direction.right);
      expect(s.frozen[2], 1);
      expect(s.remaining, 2);
      expect(s.isGateOpen(0), isTrue);
    });
  });

  test('RulesConfig defaults keep v1.1 mechanics off', () {
    const c = RulesConfig();
    expect(c.enableSwitcher, isFalse);
    expect(c.enableSplitter, isFalse);
  });
}
