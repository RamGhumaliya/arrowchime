import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/rendering.dart';

/// A round ceramic knob (toggle and slider): a lip circle under a lit face
/// with a top-left specular streak and the `e1` shadow.
abstract final class Knob {
  /// Lip thickness of the knob (half the button lip: knobs are small).
  static const double lip = TBSizes.buttonLip / 2;

  /// Paints a knob of [diameter] with its top-left corner at [origin].
  static void paint(
    Canvas canvas,
    Offset origin,
    double diameter, {
    Color face = TBColors.cream100,
    Color lipColor = TBColors.cream300,
    bool focused = false,
  }) {
    final r = diameter / 2;
    final faceCenter = origin + Offset(r, r - lip / 2);
    final lipCenter = origin + Offset(r, r + lip / 2);
    final faceR = r - lip / 2;
    for (final s in TBElevation.e1) {
      canvas.drawCircle(
        lipCenter + s.offset,
        faceR,
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }
    canvas
      ..drawCircle(lipCenter, faceR, Paint()..color = lipColor)
      ..drawCircle(
        faceCenter,
        faceR,
        Paint()
          ..shader = ui.Gradient.linear(
            faceCenter - Offset(0, faceR),
            faceCenter + Offset(0, faceR),
            [TBShade.lighten(face, TBBevel.faceTopLightness), face],
          ),
      )
      ..drawCircle(
        faceCenter,
        faceR - TBBevel.innerHighlight / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = TBBevel.innerHighlight
          ..shader = ui.Gradient.linear(
            faceCenter - Offset(faceR, faceR),
            faceCenter + Offset(faceR, faceR),
            [TBShade.white(TBBevel.innerHighlightOpacity), TBShade.white(0)],
            const [0, 0.55],
          ),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            faceCenter.dx - faceR * 0.55,
            faceCenter.dy - faceR * 0.55,
            faceR * 0.5,
            TBBevel.specularThickness,
          ),
          const Radius.circular(TBRadius.pill),
        ),
        Paint()..color = TBShade.white(TBBevel.specularOpacity),
      );
    if (focused) {
      canvas.drawCircle(
        faceCenter,
        faceR + TBSizes.focusRing,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = TBSizes.focusRing
          ..color = TBColors.sky,
      );
    }
  }
}
