import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// Responsive helpers (`docs/10` §3.2, `docs/03` §9): the screen side margin
/// is 16 dp on phones and 32 dp on tablets, and wide screens centre their
/// content instead of stretching it.
abstract final class TBLayout {
  /// Shortest side at/above which the device is a tablet.
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide >= TBSizes.tabletShortestSide;

  /// Side margin for the current device class.
  static double screenMargin(BuildContext context) => isTablet(context)
      ? TBSpacing.screenMarginTablet
      : TBSpacing.screenMarginPhone;

  /// How much taller one line of [fontSize] text is at the user's text scale
  /// than at 1x (0 at 1x or below). Components with fixed heights grow by
  /// exactly this, so their nominal size is unchanged at normal text size
  /// and scaled text never clips.
  static double extraLine(
    BuildContext context,
    double fontSize, [
    double lineHeight = 1.25,
  ]) {
    final extra =
        (MediaQuery.textScalerOf(context).scale(fontSize) - fontSize) *
        lineHeight;
    return extra > 0 ? extra : 0;
  }

  /// Height of one line of text at the user's text scale.
  static double scaledLine(
    BuildContext context,
    double fontSize, [
    double lineHeight = 1.25,
  ]) => MediaQuery.textScalerOf(context).scale(fontSize) * lineHeight;
}

/// Centres [child] and caps its width at [maxWidth]
/// (default [TBSizes.contentMaxWidth]).
class TBCentered extends StatelessWidget {
  const new({
    required this.child,
    this.maxWidth = TBSizes.contentMaxWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
