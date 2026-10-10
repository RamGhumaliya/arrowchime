import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/painting.dart';

/// Lacquered wood (`docs/10` §2): shelves, tab bars, frames, the tray rim.
///
/// Low gloss: a gentle vertical gradient, a 2 dp light rim on top, a darker
/// lower lip and faint horizontal grain.
abstract final class Wood {
  /// Paints a wooden slab filling [size].
  static void paint(
    Canvas canvas,
    Size size, {
    double radius = TBRadius.r20,
    List<BoxShadow> elevation = TBElevation.e2,
    int grainSeed = 3,
  }) {
    final slab = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    for (final s in elevation) {
      canvas.drawRRect(
        slab.shift(s.offset),
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }
    canvas.drawRRect(slab, Paint()..color = TBMaterials.woodLip);
    final face = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - TBBevel.panelBevel),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      face,
      Paint()
        ..shader = ui.Gradient.linear(
          face.outerRect.topCenter,
          face.outerRect.bottomCenter,
          [TBMaterials.woodHighlight, TBMaterials.woodFace],
          const [0, 0.35],
        ),
    );
    paintGrain(canvas, face, seed: grainSeed);
    canvas.drawRRect(
      face.deflate(TBBevel.rimLight / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TBBevel.rimLight
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width * 0.4, size.height),
          [TBShade.white(0.4), TBShade.white(0)],
          const [0, 0.5],
        ),
    );
  }

  /// Wavy horizontal grain lines (light and dark) clipped to [rrect].
  static void paintGrain(Canvas canvas, RRect rrect, {required int seed}) {
    final rect = rrect.outerRect;
    final noise = TBNoise(seed);
    canvas
      ..save()
      ..clipRRect(rrect);
    final lines = (rect.height / 5).clamp(2, 60).toInt();
    for (var i = 0; i < lines; i++) {
      final y = rect.top + (i + noise.next()) * rect.height / lines;
      final amp = 1 + noise.next() * 2;
      final path = Path()..moveTo(rect.left, y);
      final phase = noise.next() * 6;
      for (var x = rect.left; x <= rect.right; x += 12) {
        path.lineTo(x, y + amp * _wave((x - rect.left) / 40 + phase));
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = (noise.next() > 0.5 ? TBColors.ink900 : TBColors.cream100)
              .withValues(alpha: 0.08),
      );
    }
    canvas.restore();
  }

  /// Cheap triangle wave in -1..1 (no `dart:math`).
  static double _wave(double t) {
    final f = t - t.floorToDouble();
    return f < 0.5 ? f * 4 - 1 : 3 - f * 4;
  }
}

/// The board tray (`docs/10` §8): a recessed felt surface in the chapter's
/// tray colour with fabric noise, an inner shadow along the top/left edges and
/// a 6 dp wooden rim.
abstract final class Felt {
  static void paintTray(
    Canvas canvas,
    Size size, {
    required Color felt,
    double radius = TBRadius.r20,
  }) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    Wood.paint(canvas, size, radius: radius);
    final inner = outer.deflate(TBBevel.woodRim);
    canvas.drawRRect(inner, Paint()..color = felt);
    // Fabric noise: light and dark specks.
    final rect = inner.outerRect;
    final noise = TBNoise(11);
    final count = (rect.width * rect.height / 14).clamp(0, 6000).toInt();
    final light = <Offset>[];
    final dark = <Offset>[];
    for (var i = 0; i < count; i++) {
      final p = Offset(
        rect.left + noise.next() * rect.width,
        rect.top + noise.next() * rect.height,
      );
      (noise.next() > 0.5 ? light : dark).add(p);
    }
    canvas
      ..save()
      ..clipRRect(inner)
      ..drawPoints(
        ui.PointMode.points,
        light,
        Paint()
          ..color = TBShade.white(0.07)
          ..strokeWidth = 1.2,
      )
      ..drawPoints(
        ui.PointMode.points,
        dark,
        Paint()
          ..color = TBShade.ink(0.06)
          ..strokeWidth = 1.2,
      )
      ..restore();
    Inset.paintInnerShadow(canvas, inner, opacity: 0.4);
  }
}
