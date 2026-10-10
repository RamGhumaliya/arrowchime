import 'package:arrowchime/app/theme/tokens.dart';
import 'package:flutter/widgets.dart';

/// Reduce Motion (`docs/10` §3.5): when the platform asks for it, springs and
/// slides become 160 ms fades.
abstract final class TBMotionScope {
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [normal] unless Reduce Motion is on, then the 160 ms fade duration.
  static Duration duration(BuildContext context, Duration normal) =>
      reduced(context) ? TBMotion.reducedMotionFade : normal;
}
