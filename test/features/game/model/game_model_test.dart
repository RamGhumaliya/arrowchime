import 'dart:ui';

import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:arrowchime/features/game/model/flow_tracker.dart';
import 'package:arrowchime/features/game/model/view_transform.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/level/support/fixtures.dart';

void main() {
  group('BoardGeometry', () {
    final g = BoardGeometry(freeTrio());

    test('cell <-> world round trip', () {
      const c = Cell(2, 3);
      expect(g.cellAt(g.center(c)), c);
      expect(g.cellAt(g.topLeft(c) + const Offset(1, 1)), c);
      expect(g.worldSize.width, 5 * g.cell + 2 * g.trayPad);
    });

    test('outside the grid', () {
      expect(g.cellAt(const Offset(1, 1)), isNull);
      expect(g.cellAt(g.gridRect.bottomRight + const Offset(1, 1)), isNull);
      expect(g.cellAt(Offset(g.gridRect.left + 5, -3)), isNull);
      expect(g.nearestCell(const Offset(-50, 999)), const Cell(0, 4));
      expect(g.trayRect.size, g.worldSize);
      expect(g.columns, 5);
      expect(g.rows, 5);
    });
  });

  group('FlowTracker', () {
    var t = Duration.zero;
    late FlowTracker f;
    setUp(() {
      t = Duration.zero;
      f = FlowTracker(now: () => t);
    });

    void tap([int ms = 500]) {
      t += Duration(milliseconds: ms);
      f.onFreed();
    }

    test('multiplier tiers 3/5/7/9', () {
      for (final (taps, m) in [
        (1, 1),
        (2, 1),
        (3, 2),
        (4, 2),
        (5, 3),
        (7, 4),
        (9, 5),
        (12, 5),
      ]) {
        f = FlowTracker(now: () => t);
        for (var i = 0; i < taps; i++) {
          tap();
        }
        expect(f.multiplier, m, reason: '$taps taps');
      }
    });

    test('slow tap, block and reset end the streak', () {
      tap();
      tap();
      tap();
      expect(f.isActive, isTrue);
      t += const Duration(milliseconds: 1600);
      expect(f.streak, 0);
      expect(f.bestMultiplier, 2);
      tap();
      tap();
      f.onBlocked();
      expect(f.streak, 0);
      tap(100);
      f.reset();
      expect(f.bestMultiplier, 1);
      expect(f.isActive, isFalse);
    });

    test('fill runs 0..1 inside a tier', () {
      expect(f.fill, 0);
      tap();
      expect(f.fill, closeTo(1 / 3, 1e-9));
      tap();
      tap();
      expect(f.fill, 0.5);
      tap();
      expect(f.fill, 1);
      for (var i = 0; i < 5; i++) {
        tap();
      }
      expect(f.fill, 1);
    });
  });

  group('ViewTransform (G14)', () {
    ViewTransform make() => ViewTransform(
      worldSize: const Size(400, 400),
      viewport: const Size(332, 600),
    );

    test('starts fit and centred', () {
      final v = make();
      expect(v.isFit, isTrue);
      expect(v.fitZoom, closeTo(0.75, 1e-9));
      expect(v.toScreen(v.boardCenter), const Offset(166, 300));
      expect(v.toWorld(v.toScreen(const Offset(10, 20))).dx, closeTo(10, 1e-9));
    });

    test('zoom is clamped to 1x-4x and keeps the focal point', () {
      final v = make();
      const focal = Offset(250, 200);
      final before = v.toWorld(focal);
      v.zoomAbout(focal, 2);
      expect(v.toWorld(focal).dx, closeTo(before.dx, 1e-6));
      expect(v.toWorld(focal).dy, closeTo(before.dy, 1e-6));
      v.zoomAbout(focal, 99);
      expect(v.multiplier, 4);
      v.zoomAbout(focal, 0.1);
      expect(v.multiplier, 1);
    });

    test('pan is clamped to board + 20%', () {
      final v = make()
        ..zoomAbout(const Offset(166, 300), 4)
        ..panByScreen(const Offset(100000, 100000));
      expect(v.center.dx, greaterThanOrEqualTo(-80));
      v.panByScreen(const Offset(-100000, -100000));
      expect(v.center.dx, lessThanOrEqualTo(480));
      v
        ..fit()
        ..panByScreen(const Offset(500, 500));
      // at 1x the viewport is still narrower than board + 20%, so it can
      // drift only as far as that margin allows
      expect(v.center.dx, closeTo(200 - 58.6667, 1e-3));
      expect(v.isFit, isFalse);
    });

    test('resize keeps the multiplier', () {
      final v = make()
        ..zoomAbout(const Offset(166, 300), 2)
        ..resize(const Size(600, 332));
      expect(v.multiplier, 2);
      expect(v.viewport, const Size(600, 332));
    });
  });
}
