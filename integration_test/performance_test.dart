import 'dart:ui';

import 'package:arrowchime/app/app.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:flame/game.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// Frame-time check on a dense board (default: ch5 L60, 24x24, 69 arrows; pick
/// another with `--dart-define=PERF_LEVEL=1/60`, the 14x14 one): idle,
/// pinching to 4x and back, and a burst of taps (`docs/09` perf budget:
/// 60 fps, i.e. frames under 16.7 ms). Run in profile mode on a device:
/// `flutter test integration_test/performance_test.dart --flavor dev --profile`
/// (an emulator only gives an indicative number).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dense board frame times', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArrowchimeApp()));
    await tester.pump(const Duration(milliseconds: 500));
    final context = tester.element(find.byType(Navigator).first);
    final container = ProviderScope.containerOf(context);
    final parts = const String.fromEnvironment(
      'PERF_LEVEL',
      defaultValue: '5/60',
    ).split('/');
    final id = LevelRef(int.parse(parts[0]), int.parse(parts[1]));
    final level = await container.read(levelProvider(id).future);
    GoRouter.of(context).go('/level/${id.chapterSlug}/${id.index}');
    final finder = find.byType(GameWidget<ArrowGame>);
    for (var i = 0; i < 50 && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final game = tester.widget<GameWidget<ArrowGame>>(finder).game!;
    final centre = tester.getCenter(finder);
    final origin = tester.getTopLeft(finder);

    final build = <double>[];
    final raster = <double>[];
    void onTimings(List<FrameTiming> timings) {
      for (final t in timings) {
        build.add(t.buildDuration.inMicroseconds / 1000);
        raster.add(t.rasterDuration.inMicroseconds / 1000);
      }
    }

    SchedulerBinding.instance.addTimingsCallback(onTimings);

    final marks = <String, int>{};
    // Idle at fit, then zoom in and out with a two-finger pinch.
    await tester.pump(const Duration(seconds: 2));
    marks['idle'] = raster.length;
    final a = await tester.startGesture(centre - const Offset(30, 0));
    final b = await tester.startGesture(centre + const Offset(30, 0));
    for (var i = 1; i <= 30; i++) {
      await a.moveTo(centre - Offset(30.0 + i * 4, 0));
      await b.moveTo(centre + Offset(30.0 + i * 4, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await a.up();
    await b.up();
    marks['pinch'] = raster.length;
    game.fitBoard();
    await tester.pump(const Duration(seconds: 1));
    marks['refit'] = raster.length;

    // A burst of taps along the solution.
    for (final arrow in level.meta.solution.take(25)) {
      final comp = game.arrows[arrow];
      if (comp == null) continue;
      await tester.tapAt(origin + game.view.toScreen(comp.headPoint));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(seconds: 1));
    SchedulerBinding.instance.removeTimingsCallback(onTimings);

    double pct(List<double> v, double p) {
      final s = [...v]..sort();
      return s.isEmpty ? 0 : s[((s.length - 1) * p).round()];
    }

    String line(String name, int from, int to) {
      final b = build.sublist(from, to);
      final r = raster.sublist(from, to);
      return '$name n=${b.length} build p50 ${pct(b, .5).toStringAsFixed(1)} '
          'p90 ${pct(b, .9).toStringAsFixed(1)} | raster p50 '
          '${pct(r, .5).toStringAsFixed(1)} p90 ${pct(r, .9).toStringAsFixed(1)} '
          'max ${pct(r, 1).toStringAsFixed(1)} ms';
    }

    // ignore: avoid_print, the numbers are the evidence for the review
    print('FRAMES ${line('idle', 0, marks['idle']!)}');
    // ignore: avoid_print, the numbers are the evidence for the review
    print('FRAMES ${line('pinch', marks['idle']!, marks['pinch']!)}');
    // ignore: avoid_print, the numbers are the evidence for the review
    print('FRAMES ${line('refit', marks['pinch']!, marks['refit']!)}');
    // ignore: avoid_print, the numbers are the evidence for the review
    print('FRAMES ${line('taps', marks['refit']!, build.length)}');
    expect(build, isNotEmpty);
  });
}
