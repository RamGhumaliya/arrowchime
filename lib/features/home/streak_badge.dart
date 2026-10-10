import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/meta/streak.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// The streak flame with its day count (`docs/10` §7). The flame grows with
/// the tier (3 / 7 / 30 / 100 days); at no streak it sits dim.
class StreakBadge extends StatelessWidget {
  const new({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tier = Streak.tierOf(count);
    final size = TBSizes.buttonIcon * (1 + 0.18 * tier);
    return Semantics(
      label: count == 0 ? l10n.homeStreakNone : l10n.homeStreak(count),
      excludeSemantics: true,
      child: Opacity(
        opacity: count == 0 ? 0.55 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TBIcon(TBIconId.flame, size: size),
            TBText.counter('$count'),
          ],
        ),
      ),
    );
  }
}
