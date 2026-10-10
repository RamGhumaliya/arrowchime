import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_icon_button.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/features/game/hud/hearts_row.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Back button, level ribbon, hearts and coins in one row (`docs/10` §7). The row scales down
/// as a whole on very narrow screens instead of wrapping.
class GameTopBar extends StatelessWidget {
  const new({
    required this.levelNumber,
    required this.hearts,
    required this.totalHearts,
    required this.coins,
    required this.onBack,
    super.key,
  });

  final int levelNumber;
  final int hearts;
  final int totalHearts;
  final int coins;
  final VoidCallback onBack;

  /// Below this width the row shrinks as a whole; above it, the ribbon
  /// takes the free space between the back button and the counters.
  static const double _wide = 480;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final back = TBIconButton(
      icon: TBIconId.back,
      semanticLabel: l10n.gameBack,
      onPressed: onBack,
    );
    final ribbon = TBRibbon(l10n.gameLevelTitle(levelNumber), compact: true);
    final counters = [
      HeartsRow(hearts: hearts, total: totalHearts),
      const SizedBox(width: TBSpacing.s8),
      TBPill(
        icon: TBIconId.coin,
        value: '$coins',
        semanticLabel: l10n.gameCoinsLabel(coins),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wide) {
          return Row(
            children: [
              back,
              Expanded(child: Center(child: ribbon)),
              ...counters,
            ],
          );
        }
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              back,
              const SizedBox(width: TBSpacing.s8),
              ribbon,
              const SizedBox(width: TBSpacing.s8),
              ...counters,
            ],
          ),
        );
      },
    );
  }
}
