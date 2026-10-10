import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/features/game/input/tap_resolver.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/level/support/fixtures.dart';

void main() {
  final geometry = BoardGeometry(freeTrio());
  late TapResolver resolver;

  setUp(() {
    resolver = TapResolver(geometry)
      ..occupied[const Cell(1, 1)] = const CellArrow(7, isHead: false)
      ..occupied[const Cell(2, 1)] = const CellArrow(7, isHead: true)
      ..occupied[const Cell(4, 3)] = const CellArrow(9, isHead: true);
  });

  Offset at(Cell c, [double fx = 0.5, double fy = 0.5]) =>
      geometry.topLeft(c) + Offset(fx * geometry.cell, fy * geometry.cell);

  group('tap assist (G15)', () {
    test('centre of an occupied cell hits it', () {
      expect(resolver.resolve(at(const Cell(1, 1)), screenCell: 40), 7);
      expect(resolver.resolve(at(const Cell(4, 3)), screenCell: 40), 9);
    });

    test('empty cell far from any arrow hits nothing', () {
      expect(resolver.resolve(at(const Cell(0, 4)), screenCell: 40), isNull);
      expect(resolver.resolve(const Offset(1, 1), screenCell: 40), isNull);
    });

    test('edge zone and neighbouring empty cells snap to the nearest', () {
      // 10% into the empty cell (3,1): within 0.8 cell of (2,1)'s centre.
      expect(resolver.resolve(at(const Cell(3, 1), 0.1), screenCell: 40), 7);
      // Edge of the occupied cell towards its neighbour.
      expect(resolver.resolve(at(const Cell(1, 1), 0.95), screenCell: 40), 7);
      // Just outside the radius.
      expect(
        resolver.resolve(at(const Cell(3, 1), 0.9), screenCell: 40),
        isNull,
      );
    });

    test('dense boards widen the radius and prefer heads', () {
      final p = at(const Cell(3, 1));
      expect(resolver.resolve(p, screenCell: 40), isNull);
      expect(resolver.resolve(p, screenCell: 20), 7);
      // Equidistant from a body cell and a head cell: the head wins.
      final mid =
          geometry.center(const Cell(1, 1)) + Offset(geometry.cell / 2, 0);
      expect(resolver.resolve(mid, screenCell: 20), 7);
      resolver.occupied
        ..clear()
        ..[const Cell(1, 1)] = const CellArrow(1, isHead: false)
        ..[const Cell(2, 1)] = const CellArrow(2, isHead: true);
      final between =
          geometry.center(const Cell(1, 1)) + Offset(geometry.cell / 2, 0);
      expect(resolver.resolve(between, screenCell: 20), 2);
    });
  });
}
