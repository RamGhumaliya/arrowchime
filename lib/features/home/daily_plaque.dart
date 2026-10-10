import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// The Daily Knot plaque on Home: a small raised panel with the calendar icon,
/// the title and today's state. Tapping opens the Daily screen.
class DailyPlaque extends StatelessWidget {
  const new({required this.done, required this.onTap, super.key});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = done ? l10n.homeDailyDone : l10n.homeDailyReady;
    return TBPressable(
      onPressed: onTap,
      semanticLabel: '${l10n.homeDaily}, $state',
      builder: (context, press) => Transform.translate(
        offset: Offset(0, TBSizes.buttonPressDepth * press.press),
        child: TBPanel(
          radius: TBRadius.r20,
          padding: const EdgeInsets.symmetric(
            horizontal: TBSpacing.s12,
            vertical: TBSpacing.s8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TBIcon(done ? TBIconId.star : TBIconId.calendar),
              const SizedBox(width: TBSpacing.s8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TBText.caption(l10n.homeDaily, color: TBColors.ink900),
                  TBText.body(state, color: TBColors.ink700),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
