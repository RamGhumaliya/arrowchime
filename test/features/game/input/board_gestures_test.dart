import 'package:arrowchime/features/game/input/board_gestures.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final log = <String>[];
  var hits = false;

  Future<void> pump(WidgetTester tester) async {
    log.clear();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: BoardGestures(
              onTap: (p) {
                log.add('tap');
                return hits;
              },
              onPan: (d) => log.add('pan'),
              onZoom: (f, k) => log.add('zoom ${k > 1 ? 'in' : 'out'}'),
              onPeekStart: (p) => log.add('peek+'),
              onPeekEnd: () => log.add('peek-'),
              onDoubleTapEmpty: (p) => log.add('double'),
              child: const ColoredBox(color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
      ),
    );
  }

  setUp(() => hits = false);

  testWidgets('a quick tap reports immediately', (tester) async {
    await pump(tester);
    await tester.tapAt(const Offset(400, 300));
    expect(log, ['tap']);
  });

  testWidgets('a held finger peeks, and releasing ends the peek', (
    tester,
  ) async {
    await pump(tester);
    final g = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(log, ['peek+']);
    await g.up();
    expect(log, ['peek+', 'peek-']);
  });

  testWidgets('dragging pans and does not tap or peek', (tester) async {
    await pump(tester);
    final g = await tester.startGesture(const Offset(400, 300));
    await g.moveBy(const Offset(30, 0));
    await g.moveBy(const Offset(10, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await g.up();
    expect(log, ['pan', 'pan']);
  });

  testWidgets('two fingers zoom and pan; lifting one keeps panning', (
    tester,
  ) async {
    await pump(tester);
    final a = await tester.startGesture(const Offset(350, 300), pointer: 1);
    final b = await tester.startGesture(const Offset(450, 300), pointer: 2);
    await a.moveTo(const Offset(300, 300));
    await b.moveTo(const Offset(500, 300));
    expect(log, contains('zoom in'));
    await a.moveTo(const Offset(360, 300));
    expect(log, contains('zoom out'));
    await a.up();
    log.clear();
    await b.moveBy(const Offset(40, 0));
    expect(log, ['pan']);
    await b.up();
    expect(log, ['pan']);
  });

  testWidgets('mouse wheel zooms', (tester) async {
    await pump(tester);
    final mouse = TestPointer(1, PointerDeviceKind.mouse)
      ..hover(const Offset(400, 300));
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, -20)));
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 20)));
    expect(log, ['zoom in', 'zoom out']);
  });

  testWidgets('two quick taps on empty felt fit the board', (tester) async {
    await pump(tester);
    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(const Offset(402, 301));
    expect(log, ['tap', 'tap', 'double']);
  });

  testWidgets('slow or distant second taps are plain taps', (tester) async {
    await pump(tester);
    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(const Offset(300, 250));
    expect(log, ['tap', 'tap', 'tap']);
    expect(log, isNot(contains('double')));
  });

  testWidgets('taps that hit an arrow never count as a double tap', (
    tester,
  ) async {
    hits = true;
    await pump(tester);
    await tester.tapAt(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tapAt(const Offset(400, 300));
    expect(log, ['tap', 'tap']);
  });

  testWidgets('a cancelled gesture ends a peek', (tester) async {
    await pump(tester);
    final g = await tester.startGesture(const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 300));
    await g.cancel();
    expect(log, ['peek+', 'peek-']);
  });

  testWidgets('disposing while a finger is down is safe', (tester) async {
    await pump(tester);
    await tester.startGesture(const Offset(400, 300));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 400));
    expect(log, isEmpty);
  });
}
