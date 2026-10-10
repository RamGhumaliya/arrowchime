import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Hearts left on this attempt: full hearts, then broken ones, on a small
/// recessed capsule. Colour is never the only signal: broken hearts have a
/// different shape.
class HeartsRow extends StatelessWidget {
  const new({required this.hearts, required this.total, super.key});

  final int hearts;
  final int total;

  static const double _icon = 24;

  @override
  Widget build(BuildContext context) {
    final shown = total < hearts ? hearts : total;
    return Semantics(
      label: AppLocalizations.of(context).gameHeartsLabel(hearts),
      excludeSemantics: true,
      child: TBPanel.recessed(
        padding: const EdgeInsets.symmetric(
          horizontal: TBSpacing.s8,
          vertical: TBSpacing.s4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < shown; i++)
              TBIcon(
                i < hearts ? TBIconId.heart : TBIconId.heartBroken,
                size: _icon,
              ),
          ],
        ),
      ),
    );
  }
}
