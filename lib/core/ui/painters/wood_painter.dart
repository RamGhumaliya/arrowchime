import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/painting.dart';

/// Flat cool-grey slab (`docs/10` §2, V2 "Clean Line"): shelves, tab bars,
/// frames and blocked cells. Kept under its old name so callers do not change.
abstract final class Wood {
  /// Paints a slab filling [size]: a thin darker lip under a flat face.
  static void paint(
    Canvas canvas,
    Size size, {
    double radius = TBRadius.r20,
    List<BoxShadow> elevation = TBElevation.e1,
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
    const lip = TBSizes.buttonLip;
    canvas
      ..drawRRect(slab, Paint()..color = TBMaterials.woodLip)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height - lip),
          Radius.circular(radius),
        ),
        Paint()..color = TBMaterials.woodFace,
      );
  }
}

/// The board backing: a flat rounded rectangle (no felt, no rim). The game
/// itself draws no tray in V2; this remains for the Design Gallery and Home.
abstract final class Felt {
  static void paintTray(
    Canvas canvas,
    Size size, {
    required Color felt,
    double radius = TBRadius.r20,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      Paint()..color = felt,
    );
  }
}
