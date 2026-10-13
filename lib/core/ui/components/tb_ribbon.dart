import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:flutter/widgets.dart';

/// Ribbon colours (`docs/10` §5, §7): tangerine (win), teal, berry (fail).
enum TBRibbonKind { tangerine, teal, berry }

/// A title banner (`docs/10` §5, V2 "Clean Line"): a flat rounded plaque in
/// the kind's colour with white text. In its [compact] form (the level top
/// bar) it is just ink text on the page. Used on Win, Fail and headers.
class TBRibbon extends StatelessWidget {
  const new(
    this.title, {
    this.kind = TBRibbonKind.tangerine,
    this.compact = false,
    super.key,
  });

  final String title;
  final TBRibbonKind kind;

  /// The small title of the level screen's top bar.
  final bool compact;

  Color get _face => switch (kind) {
    TBRibbonKind.tangerine => TBColors.tangerine,
    TBRibbonKind.teal => TBColors.teal,
    TBRibbonKind.berry => TBColors.berry,
  };

  @override
  Widget build(BuildContext context) {
    final titleSize = compact
        ? TBTypography.counter.style.fontSize!
        : TBTypography.title.style.fontSize!;
    final height =
        (compact ? TBSizes.ribbonHeight * 0.75 : TBSizes.ribbonHeight) +
        TBLayout.extraLine(context, titleSize);
    final label = FittedBox(
      fit: BoxFit.scaleDown,
      child: compact
          ? TBText.counter(title)
          : TBText.title(title, color: TBColors.cream100),
    );
    return Semantics(
      header: true,
      label: title,
      excludeSemantics: true,
      child: compact
          ? SizedBox(
              height: height,
              child: Center(child: label),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: _face,
                borderRadius: TBRadius.brPill,
              ),
              child: SizedBox(
                height: height - TBSpacing.s8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TBSpacing.s24,
                  ),
                  child: Center(widthFactor: 1, child: label),
                ),
              ),
            ),
    );
  }
}
