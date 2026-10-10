import 'dart:ui';

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/level/models/arrow.dart';

/// Colour choices of the board: key / gate colours map onto the palette
/// (`docs/10` §3.1), ordinary arrows take the chapter's arrow colours.
abstract final class ArrowVisuals {
  static Color gateColor(GateColor c) => switch (c) {
    GateColor.amber => TBColors.butter,
    GateColor.jade => TBColors.teal,
    GateColor.rose => TBColors.berry,
    GateColor.azure => TBColors.sky,
  };

  /// Colour of [arrow] on a board themed [theme].
  static Color arrowColor(
    Arrow arrow,
    ChapterTheme theme, {
    String colorBlind = 'off',
  }) {
    final key = arrow.color;
    if (key != null) return gateColor(key);
    final colors = TBColorBlind.of(colorBlind) ?? theme.arrowColors;
    return colors[(arrow.skinHint ?? arrow.id) % colors.length];
  }

  /// Colour-blind symbol of a gate / key: circle, triangle, square, diamond.
  static Path symbol(GateColor c, Offset center, double r) {
    final p = Path();
    switch (c) {
      case GateColor.amber:
        p.addOval(Rect.fromCircle(center: center, radius: r));
      case GateColor.jade:
        p.addPolygon([
          center + Offset(0, -r),
          center + Offset(r, r * 0.8),
          center + Offset(-r, r * 0.8),
        ], true);
      case GateColor.rose:
        p.addRect(Rect.fromCircle(center: center, radius: r * 0.85));
      case GateColor.azure:
        p.addPolygon([
          center + Offset(0, -r),
          center + Offset(r, 0),
          center + Offset(0, r),
          center + Offset(-r, 0),
        ], true);
    }
    return p;
  }
}
