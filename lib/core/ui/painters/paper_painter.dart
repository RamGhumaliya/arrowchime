import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/inset_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// Lacquered cream paper (`docs/10` §2 / §5): panels, sheets, the win plaque.
///
/// Raised: `e2` shadow (or the elevation you pass), a 4 dp `cream300` bottom
/// bevel, a 2 dp light rim along the top, 2% grain. Recessed: sunk, with an
/// inner shadow (lists, the board tray surround).
abstract final class Paper {
  /// Paints a raised paper slab filling [size].
  static void paintRaised(
    Canvas canvas,
    Size size, {
    double radius = TBRadius.r32,
    List<BoxShadow> elevation = TBElevation.e2,
    Color face = TBColors.cream100,
    Color bevel = TBColors.cream300,
    int grainSeed = 1,
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
    // Bevel-dark underneath, face on top.
    canvas.drawRRect(slab, Paint()..color = bevel);
    final faceRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - TBBevel.panelBevel),
      Radius.circular(radius),
    );
    canvas.drawRRect(faceRRect, Paint()..color = face);
    paintGrain(canvas, faceRRect, seed: grainSeed);

    // Rim light along the top edge (fades out towards the bottom).
    canvas.drawRRect(
      faceRRect.deflate(TBBevel.rimLight / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TBBevel.rimLight
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width * 0.35, size.height),
          [TBShade.white(0.8), TBShade.white(0)],
          const [0, 0.5],
        ),
    );
  }

  /// Paints a recessed paper well filling [size].
  static void paintRecessed(
    Canvas canvas,
    Size size, {
    double radius = TBRadius.r32,
    Color fill = TBColors.cream300,
    int grainSeed = 2,
  }) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    Inset.paint(canvas, rrect, fill: fill);
    paintGrain(canvas, rrect, seed: grainSeed);
  }

  /// Fine deterministic grain, [TBBevel.grainOpacity] strong, clipped to
  /// [rrect].
  static void paintGrain(
    Canvas canvas,
    RRect rrect, {
    required int seed,
    Color color = TBColors.ink900,
  }) {
    final rect = rrect.outerRect;
    final count = (rect.width * rect.height / 40).clamp(0, 2400).toInt();
    final noise = TBNoise(seed);
    final points = <Offset>[
      for (var i = 0; i < count; i++)
        Offset(
          rect.left + noise.next() * rect.width,
          rect.top + noise.next() * rect.height,
        ),
    ];
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawPoints(
        ui.PointMode.points,
        points,
        Paint()
          ..color = color.withValues(alpha: TBBevel.grainOpacity * 2.5)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.square,
      )
      ..restore();
  }
}

/// [CustomPainter] adapter for [Paper].
class PaperPainter extends CustomPainter {
  const new({
    this.recessed = false,
    this.radius = TBRadius.r32,
    this.elevation = TBElevation.e2,
    this.face,
  });

  final bool recessed;
  final double radius;
  final List<BoxShadow> elevation;
  final Color? face;

  @override
  void paint(Canvas canvas, Size size) {
    if (recessed) {
      Paper.paintRecessed(
        canvas,
        size,
        radius: radius,
        fill: face ?? TBColors.cream300,
      );
    } else {
      Paper.paintRaised(
        canvas,
        size,
        radius: radius,
        elevation: elevation,
        face: face ?? TBColors.cream100,
      );
    }
  }

  @override
  bool shouldRepaint(PaperPainter old) =>
      old.recessed != recessed ||
      old.radius != radius ||
      old.elevation != elevation ||
      old.face != face;
}
