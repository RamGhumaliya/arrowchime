import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  test('copy is independent of the original', () {
    final s = BoardState.initial(blockedPair());
    final c = s.copy();
    Rules.remove(c, 1);
    expect(s.remaining, 2);
    expect(c.remaining, 1);
    expect(s.isAlive(1), isTrue);
    expect(c.isAlive(1), isFalse);
    expect(s.aliveIndices, [0, 1]);
    expect(c.aliveIndices, [0]);
  });

  test('key identifies a state, also beyond 30 arrows', () {
    final level = buildLevel(
      width: 6,
      height: 24,
      arrows: [
        for (var y = 0; y < 24; y++)
          arrowJson(y, [
            [0, y],
          ], 'L'),
        for (var y = 0; y < 24; y++)
          arrowJson(24 + y, [
            [2, y],
          ], 'R'),
      ],
    );
    final s = BoardState.initial(level);
    final c = s.copy();
    expect(c.key, s.key);
    Rules.remove(c, 40);
    expect(c.key, isNot(s.key));
    final d = s.copy();
    Rules.remove(d, 3);
    expect(d.key, isNot(c.key));
  });

  test('key reflects rotator directions and open gates', () {
    final s = BoardState.initial(rotatorPair());
    final turned = s.copy();
    Rules.remove(turned, 1);
    expect(turned.dirOf(0), Direction.right);
    expect(turned.key, isNot(s.key));

    final g = BoardState.initial(gateAndKey());
    final opened = g.copy();
    Rules.remove(opened, 1);
    expect(opened.isGateOpen(0), isTrue);
    expect(opened.key, contains('|1|'));
  });
}
