import 'package:flutter/painting.dart';

/// Flat recessed surfaces (`docs/10` §5, V2): pill counters, progress tracks,
/// slider grooves, lists. A solid tinted fill; no inner shadow.
abstract final class Inset {
  /// Paints a recessed [rrect] filled with [fill].
  static void paint(
    Canvas canvas,
    RRect rrect, {
    required Color fill,
    double shadowOpacity = 0,
    double rimOpacity = 0,
  }) {
    canvas.drawRRect(rrect, Paint()..color = fill);
  }

  /// Kept for callers; a flat recess has no inner shadow.
  static void paintInnerShadow(
    Canvas canvas,
    RRect rrect, {
    double opacity = 0,
  }) {}
}
