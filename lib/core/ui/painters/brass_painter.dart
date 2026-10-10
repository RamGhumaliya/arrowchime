import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// Brushed brass (`docs/10` §2): star plaques, frames, the restoration
/// plaque, the flow-meter badge.
///
/// A linear metal gradient (light → face → dark → face → light) running
/// along the light direction, a darker rim, and a fine specular line.
abstract final class Brass {
  /// Paints a brass plate in [rrect]. [elevation] draws the drop shadow
  /// (pass `const []` for none).
  static void paint(
    Canvas canvas,
    RRect rrect, {
    List<BoxShadow> elevation = TBElevation.e1,
  }) {
    for (final s in elevation) {
      canvas.drawRRect(
        rrect.shift(s.offset),
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }
    final rect = rrect.outerRect;
    canvas
      ..drawRRect(rrect, Paint()..color = TBMaterials.brassDark)
      ..drawRRect(
        rrect.deflate(TBBevel.plaqueRim),
        Paint()
          ..shader = ui.Gradient.linear(
            rect.topLeft,
            rect.bottomRight,
            [
              TBMaterials.brassLight,
              TBMaterials.brassFace,
              TBMaterials.brassDark,
              TBMaterials.brassFace,
              TBMaterials.brassLight,
            ],
            const [0, 0.28, 0.55, 0.78, 1],
          ),
      )
      // Light rim on the lit edges.
      ..drawRRect(
        rrect.deflate(TBBevel.plaqueRim / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = TBBevel.plaqueRim / 2
          ..shader = ui.Gradient.linear(
            rect.topLeft,
            rect.bottomRight,
            [TBShade.white(0.6), TBShade.white(0)],
            const [0, 0.5],
          ),
      );
    // Fine specular line.
    final inset = rrect.deflate(TBBevel.plaqueRim * 2).outerRect;
    const lineStart = TBSpacing.s8;
    final lineLength = (inset.width * 0.6).clamp(
      0.0,
      TBSpacing.s24 + TBSpacing.s16 - TBSpacing.s8,
    );
    canvas.drawLine(
      inset.topLeft + const Offset(lineStart, 0),
      inset.topLeft + Offset(lineStart + lineLength, 0),
      Paint()
        ..strokeWidth = TBBevel.specularThickness / 2
        ..strokeCap = StrokeCap.round
        ..color = TBShade.white(TBBevel.specularOpacity),
    );
  }
}

/// [CustomPainter] adapter for [Brass].
class BrassPainter extends CustomPainter {
  const new({this.radius = TBRadius.r12});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) => Brass.paint(
    canvas,
    RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
  );

  @override
  bool shouldRepaint(BrassPainter old) => old.radius != radius;
}
