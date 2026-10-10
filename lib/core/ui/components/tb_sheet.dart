import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/widgets.dart';

/// A bottom sheet: a large [TBPanel] with a [TBRibbon] header overlapping its
/// top edge (`docs/10` §5). Show it with [showTBSheet].
class TBSheet extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.ribbon = TBRibbonKind.tangerine,
    super.key,
  });

  final String title;
  final Widget child;
  final TBRibbonKind ribbon;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: TBLayout.screenMargin(context)),
      child: ConstrainedBox(
        // Wide screens (tablets, landscape) get a centred sheet, not a banner.
        constraints: const BoxConstraints(maxWidth: TBSizes.sheetMaxWidth),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: TBSizes.ribbonHeight / 2),
              child: TBPanel(
                elevation: TBElevation.e3,
                padding: EdgeInsets.fromLTRB(
                  TBSpacing.s24,
                  TBSizes.ribbonHeight / 2 + TBSpacing.s16,
                  TBSpacing.s24,
                  TBSpacing.s24 + bottom,
                ),
                child: SizedBox(width: double.infinity, child: child),
              ),
            ),
            TBRibbon(title, kind: ribbon),
          ],
        ),
      ),
    );
  }
}

/// Shows [sheet] over a 55% ink scrim. It slides in with `mEnter` and a slight
/// overshoot (Reduce Motion: a 160 ms fade). Tapping the scrim pops it.
Future<T?> showTBSheet<T>(
  BuildContext context, {
  required Widget sheet,
  bool barrierDismissible = true,
}) {
  return Navigator.of(context).push<T>(
    _SheetRoute<T>(sheet: sheet, barrierDismissible: barrierDismissible),
  );
}

class _SheetRoute<T> extends PopupRoute<T> {
  new({required this.sheet, required this.barrierDismissible});

  final Widget sheet;

  @override
  final bool barrierDismissible;

  @override
  Color get barrierColor => TBLight.scrim;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => TBMotion.enter;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Align(alignment: Alignment.bottomCenter, child: sheet),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (TBMotionScope.reduced(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    final curved = CurvedAnimation(
      parent: animation,
      curve: TBMotion.sheetCurve,
      reverseCurve: TBMotion.enterCurve.flipped,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}
