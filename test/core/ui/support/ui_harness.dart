import 'dart:io';
import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Key of the [RepaintBoundary] that [pumpSurface] wraps its content in.
const Key surfaceKey = ValueKey('ui-test-surface');

/// Surfaces components are shown on (`docs/10` §11 gallery rule).
enum TestSurface { cream, ink, chapter }

Color surfaceColor(TestSurface s) => switch (s) {
  TestSurface.cream => TBColors.cream100,
  TestSurface.ink => TBColors.ink900,
  TestSurface.chapter => const Color(0xFFB7C9A8), // chapter 1 sage (test only)
};

/// Pumps [child] centred on a [surface] of [size] at [dpr]. The returned
/// widget tree has a text direction, media query and the body text style but
/// no Material.
Future<void> pumpSurface(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(240, 120),
  TestSurface surface = TestSurface.cream,
  double dpr = 1,
  bool disableAnimations = false,
  double textScale = 1,
  EdgeInsets padding = const EdgeInsets.all(TBSpacing.s24),
}) async {
  tester.view
    ..devicePixelRatio = dpr
    ..physicalSize = size * dpr;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          devicePixelRatio: dpr,
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: DefaultTextStyle(
          style: TBTypography.body.style,
          child: RepaintBoundary(
            key: surfaceKey,
            child: ColoredBox(
              color: surfaceColor(surface),
              child: Padding(
                padding: padding,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Writes the surface as a PNG (used while developing, to look at the result).
Future<void> saveSurface(WidgetTester tester, String path) async {
  await tester.runAsync(() async {
    final boundary =
        tester.renderObject(find.byKey(surfaceKey)) as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
