import 'package:arrowchime/core/level/generator/masks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Flood fill over `'1'` cells; returns the size of the largest component.
int largestComponent(List<String> mask) {
  final h = mask.length;
  final w = mask.first.length;
  final seen = List.generate(h, (_) => List.filled(w, false));
  var best = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (mask[y][x] != '1' || seen[y][x]) continue;
      var size = 0;
      final stack = [(x, y)];
      seen[y][x] = true;
      while (stack.isNotEmpty) {
        final (cx, cy) = stack.removeLast();
        size++;
        for (final (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
          final nx = cx + dx;
          final ny = cy + dy;
          if (nx >= 0 &&
              ny >= 0 &&
              nx < w &&
              ny < h &&
              mask[ny][nx] == '1' &&
              !seen[ny][nx]) {
            seen[ny][nx] = true;
            stack.add((nx, ny));
          }
        }
      }
      if (size > best) best = size;
    }
  }
  return best;
}

void main() {
  const sizes = [6, 8, 10, 12, 16, 22];

  for (final kind in [...Masks.kinds, 'circle']) {
    group(kind, () {
      for (final n in sizes) {
        test('${n}x$n is well formed, mostly connected and non-trivial', () {
          final m = Masks.byName(kind, n, n);
          expect(m, hasLength(n));
          expect(
            m.every((r) => r.length == n && RegExp(r'^[01]+$').hasMatch(r)),
            isTrue,
          );
          final playable = Masks.playable(m, n, n);
          expect(
            playable,
            greaterThanOrEqualTo(n * n ~/ 5),
            reason: 'not tiny',
          );
          expect(playable, lessThan(n * n), reason: 'has void cells');
          // The generator needs a mostly connected board.
          expect(largestComponent(m), greaterThanOrEqualTo(playable * 0.9));
        });
      }
    });
  }

  test('heart, diamond, ring, cross, circle are left-right symmetric', () {
    for (final kind in ['heart', 'diamond', 'ring', 'cross', 'circle']) {
      for (final n in sizes) {
        final m = Masks.byName(kind, n, n);
        for (final row in m) {
          expect(row.split('').reversed.join(), row, reason: '$kind $n');
        }
      }
    }
  });

  test('star is a plausible star: point up, hollow between arms', () {
    final m = Masks.star(16, 16);
    expect(m.first.contains('1') || m[1].contains('1'), isTrue);
    expect(m[8][8], '1', reason: 'centre filled');
    expect(m[3][2], '0', reason: 'notch between the top arm and the left arm');
  });

  test('ring has a hole in the middle', () {
    final m = Masks.ring(12, 12);
    expect(m[6][6], '0');
    expect(m[6][0], '1');
  });

  test('playable counts cells, or the whole board for a null mask', () {
    expect(Masks.playable(null, 4, 5), 20);
    expect(Masks.playable(['101', '111'], 3, 2), 5);
  });

  test('byName rejects unknown names', () {
    expect(() => Masks.byName('pentagon', 8, 8), throwsArgumentError);
  });

  test('masks are deterministic', () {
    for (final kind in Masks.kinds) {
      expect(Masks.byName(kind, 13, 13), Masks.byName(kind, 13, 13));
    }
  });
}
