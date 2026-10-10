import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/painting.dart';

/// Recessed surfaces (`docs/10` §5): pill counters, progress tubes, slider
/// grooves, the board tray, lists. The inside is sunk: an inner shadow along
/// the top and left edges (the key light cannot reach there) and a thin light
/// rim along the bottom and right edge.
abstract final class Inset {
  /// Paints a recessed [rrect] filled with [fill].
  ///
  /// [shadowOpacity] is the strength of the top-left inner shadow;
  /// [rimOpacity] the strength of the bottom-right light rim.
  static void paint(
    Canvas canvas,
    RRect rrect, {
    required Color fill,
    double shadowOpacity = 0.35,
    double rimOpacity = 0.35,
  }) {
    canvas.drawRRect(rrect, Paint()..color = fill);
    paintInnerShadow(canvas, rrect, opacity: shadowOpacity);

    // Light rim on the bottom/right outer edge: a gradient stroke that is
    // visible only towards the bottom-right.
    canvas.drawRRect(
      rrect.deflate(TBBevel.rimLight / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = TBBevel.rimLight
        ..shader = ui.Gradient.linear(
          rrect.outerRect.topLeft,
          rrect.outerRect.bottomRight,
          [TBShade.white(0), TBShade.white(rimOpacity)],
          const [0.45, 1],
        ),
    );
  }

  /// Inner shadow only (no fill), clipped to [rrect].
  static void paintInnerShadow(
    Canvas canvas,
    RRect rrect, {
    double opacity = 0.35,
  }) {
    canvas
      ..save()
      ..clipRRect(rrect);
    final outer = Path()
      ..addRect(rrect.outerRect.inflate(TBSizes.minTapTarget));
    final hole = Path()
      ..addRRect(
        rrect.shift(
          const Offset(TBBevel.innerShadowOffset, TBBevel.innerShadowOffset),
        ),
      );
    canvas
      ..drawPath(
        Path.combine(PathOperation.difference, outer, hole),
        Paint()
          ..color = TBShade.ink(opacity)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            TBBevel.innerShadowBlur / 2,
          ),
      )
      ..restore();
  }
}
