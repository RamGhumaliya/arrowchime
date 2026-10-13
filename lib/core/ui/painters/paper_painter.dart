import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/rendering.dart';

/// Flat white card (`docs/10` §2, V2 "Clean Line"): panels, sheets, the win
/// plaque. Raised = a soft shadow and a hairline border; recessed = a flat
/// tinted well.
abstract final class Paper {
  /// Paints a raised card filling [size].
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
    canvas
      ..drawRRect(slab, Paint()..color = face)
      ..drawRRect(
        slab.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = bevel,
      );
  }

  /// Paints a recessed well filling [size].
  static void paintRecessed(
    Canvas canvas,
    Size size, {
    double radius = TBRadius.r32,
    Color fill = TBColors.cream300,
    int grainSeed = 2,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      Paint()..color = fill,
    );
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
