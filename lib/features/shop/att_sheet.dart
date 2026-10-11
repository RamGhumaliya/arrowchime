import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// What the player chose on the pre-prompt.
enum AttChoice { continueToSystem, later }

/// The iOS tracking pre-prompt (`docs/08` §2, `docs/10` §7): a friendly sheet
/// that explains why, shown after level 5, before the system dialog. Resolves
/// to [AttChoice.later] when dismissed.
Future<AttChoice> showAttSheet(BuildContext context) async {
  final choice = await showTBSheet<AttChoice>(
    context,
    barrierDismissible: false,
    sheet: const _AttSheet(),
  );
  return choice ?? AttChoice.later;
}

class _AttSheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TBSheet(
      title: l10n.attTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TBText.body(
            l10n.attBody,
            color: TBColors.ink900,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TBSpacing.s16),
          TBButton.primary(
            label: l10n.attContinue,
            expand: true,
            onPressed: () =>
                Navigator.of(context).pop(AttChoice.continueToSystem),
          ),
          const SizedBox(height: TBSpacing.s8),
          TBButton.tertiary(
            label: l10n.attLater,
            expand: true,
            onPressed: () => Navigator.of(context).pop(AttChoice.later),
          ),
        ],
      ),
    );
  }
}
