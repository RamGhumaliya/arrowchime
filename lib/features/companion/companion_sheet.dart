import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// What the player chose on the Chime Companion pre-prompt.
enum CompanionChoice { yes, later }

/// The friendly pre-prompt before the system notification permission dialog
/// (`docs/11` §5): says what the Companion is and what it will never do.
/// Resolves to [CompanionChoice.later] when dismissed.
Future<CompanionChoice> showCompanionSheet(BuildContext context) async {
  final choice = await showTBSheet<CompanionChoice>(
    context,
    barrierDismissible: false,
    sheet: const _CompanionSheet(),
  );
  return choice ?? CompanionChoice.later;
}

class _CompanionSheet extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TBSheet(
      title: l10n.companionTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TBText.body(
            l10n.companionBody,
            color: TBColors.ink900,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TBSpacing.s16),
          TBButton.primary(
            label: l10n.companionYes,
            expand: true,
            onPressed: () => Navigator.of(context).pop(CompanionChoice.yes),
          ),
          const SizedBox(height: TBSpacing.s8),
          TBButton.tertiary(
            label: l10n.companionLater,
            expand: true,
            onPressed: () => Navigator.of(context).pop(CompanionChoice.later),
          ),
        ],
      ),
    );
  }
}
