import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Frame times of a trivial full-screen animation, to tell how fast the
/// device (or emulator) is before judging the board's numbers.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('baseline frame times', (tester) async {
    await tester.pumpWidget(const _Spinner());
    final raster = <double>[];
    void onTimings(List<FrameTiming> timings) {
      for (final t in timings) {
        raster.add(t.rasterDuration.inMicroseconds / 1000);
      }
    }

    SchedulerBinding.instance.addTimingsCallback(onTimings);
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    SchedulerBinding.instance.removeTimingsCallback(onTimings);
    final s = [...raster]..sort();
    // ignore: avoid_print, the numbers are the evidence for the review
    print(
      'BASELINE ${s.length}: raster p50 ${s[s.length ~/ 2].toStringAsFixed(1)} '
      'p90 ${s[(s.length * .9).floor()].toStringAsFixed(1)} ms',
    );
    expect(s, isNotEmpty);
  });
}

class _Spinner extends StatefulWidget {
  const new();

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomPaint(painter: _P(_c), size: Size.infinite),
    );
  }
}

class _P extends CustomPainter {
  new(this.c) : super(repaint: c);

  final Animation<double> c;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF3366FF);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (i / 40),
          size.height * (0.5 + 0.3 * (c.value - .5)),
        ),
        60,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(_P old) => true;
}
