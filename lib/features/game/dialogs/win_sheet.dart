import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/economy/rewards.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_star_row.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Level cleared (`docs/10` §7): ribbon with the level, a brass plaque with the
/// stars, the coins and XP earned, then Next (primary) and Replay (tertiary).
class WinSheet extends StatelessWidget {
  const new({
    required this.levelNumber,
    required this.stars,
    required this.reward,
    required this.onNext,
    required this.onReplay,
    this.animate = true,
    super.key,
  });

  final int levelNumber;
  final int stars;
  final LevelReward reward;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TBSheet(
      title: l10n.winTitle(levelNumber),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: l10n.winStars(stars),
            excludeSemantics: true,
            child: CustomPaint(
              painter: const BrassPainter(radius: TBRadius.r20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TBSpacing.s24,
                  vertical: TBSpacing.s16,
                ),
                child: TBStarRow(filled: stars, animate: animate),
              ),
            ),
          ),
          const SizedBox(height: TBSpacing.s16),
          _RewardRow(
            icon: TBIconId.coin,
            text: l10n.winCoins(reward.coins),
            color: TBColors.butter,
          ),
          const SizedBox(height: TBSpacing.s8),
          _RewardRow(
            icon: TBIconId.trophy,
            text: l10n.winXp(reward.xp),
            color: TBColors.sky,
          ),
          const SizedBox(height: TBSpacing.s24),
          TBButton.primary(
            label: l10n.winNext,
            onPressed: onNext,
            expand: true,
          ),
          const SizedBox(height: TBSpacing.s8),
          TBButton.tertiary(
            label: l10n.winReplay,
            onPressed: onReplay,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  const new({required this.icon, required this.text, required this.color});

  final TBIconId icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TBIcon(icon),
        const SizedBox(width: TBSpacing.s8),
        TBText.counter(text, color: color),
      ],
    );
  }
}
