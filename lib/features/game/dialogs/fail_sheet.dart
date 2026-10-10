import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/features/game/dialogs/board_thumbnail.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Out of hearts (`docs/10` §7): a desaturated thumbnail of the board, Retry
/// (primary, free, never preceded by an ad), then the two optional ways to
/// keep going: a rewarded ad or coins.
class FailSheet extends StatelessWidget {
  const new({
    required this.level,
    required this.theme,
    required this.remaining,
    required this.heartPrice,
    required this.canAffordHeart,
    required this.onRetry,
    required this.onHeartAd,
    required this.onHeartCoins,
    super.key,
  });

  final Level level;
  final ChapterTheme theme;
  final Set<int> remaining;
  final int heartPrice;
  final bool canAffordHeart;
  final VoidCallback onRetry;
  final VoidCallback onHeartAd;
  final VoidCallback onHeartCoins;

  static const double _thumbnailHeight = 120;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TBSheet(
      title: l10n.failTitle,
      ribbon: TBRibbonKind.berry,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _thumbnailHeight,
            child: BoardThumbnail(
              level: level,
              theme: theme,
              remaining: remaining,
            ),
          ),
          const SizedBox(height: TBSpacing.s12),
          TBText.body(l10n.failCaption, color: TBColors.ink900),
          const SizedBox(height: TBSpacing.s16),
          TBButton.primary(
            label: l10n.failRetry,
            onPressed: onRetry,
            expand: true,
          ),
          const SizedBox(height: TBSpacing.s8),
          TBButton.secondary(
            label: l10n.failHeartAd,
            onPressed: onHeartAd,
            expand: true,
          ),
          const SizedBox(height: TBSpacing.s8),
          TBButton.tertiary(
            label: l10n.failHeartCoins(heartPrice),
            onPressed: canAffordHeart ? onHeartCoins : null,
            expand: true,
          ),
        ],
      ),
    );
  }
}
