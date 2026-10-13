import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/rendering.dart';

/// A flat round knob (toggle and slider): a thin lip circle under a solid face.
abstract final class Knob {
  /// Lip thickness of the knob.
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
    canvas
      ..drawCircle(lipCenter, faceR, Paint()..color = lipColor)
      ..drawCircle(faceCenter, faceR, Paint()..color = face);
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
