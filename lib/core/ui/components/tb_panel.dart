import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/paper_painter.dart';
import 'package:flutter/widgets.dart';

/// Cream lacquered-paper surface (`docs/10` §5): `r32`, rim light on top,
/// a 4 dp `cream300` bottom bevel, 2% grain, `e2`.
///
/// `raised` panels float; `recessed` panels are sunk (inner shadow) and hold
/// lists and the board tray surround.
class TBPanel extends StatelessWidget {
  const new({
    required this.child,
    this.recessed = false,
    this.padding = const EdgeInsets.all(TBSpacing.s16),
    this.radius = TBRadius.r32,
    this.elevation = TBElevation.e2,
    super.key,
  });

  const new recessed({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(TBSpacing.s16),
    Key? key,
  }) : this(child: child, recessed: true, padding: padding, key: key);

  final Widget child;
  final bool recessed;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<BoxShadow> elevation;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PaperPainter(
        recessed: recessed,
        radius: radius,
        elevation: elevation,
      ),
      child: Padding(
        // The bevel strip sits below the face; keep content above it.
        padding: padding.add(const EdgeInsets.only(bottom: TBBevel.panelBevel)),
        child: child,
      ),
    );
  }
}
