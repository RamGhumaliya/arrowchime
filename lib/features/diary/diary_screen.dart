import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/features/shared/screen_frame.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Chime Diary (`docs/11` §5): a calm list of the player's best moments,
/// read straight from the save. The notifications point here.
class DiaryScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final save = ref.watch(saveControllerProvider);
    final stats = save.stats;
    final bestDay = save.companion.bestDayLevels > save.companion.todayLevels
        ? save.companion.bestDayLevels
        : save.companion.todayLevels;
    final entries = <(TBIconId, String, String)>[
      (TBIconId.star, l10n.diaryLevels, '${stats.levelsCleared}'),
      (
        TBIconId.trophy,
        l10n.diaryBestChain,
        l10n.diaryChainValue(stats.bestFlow),
      ),
      (TBIconId.flame, l10n.diaryStreakBest, l10n.diaryDays(save.streak.best)),
      (TBIconId.star, l10n.diaryPerfect, '${stats.perfectClears}'),
      (TBIconId.collection, l10n.diaryBestDay, l10n.diaryLevelsCount(bestDay)),
      (TBIconId.hint, l10n.diaryArrows, '${stats.arrowsFreed}'),
      (
        TBIconId.settings,
        l10n.diaryTime,
        l10n.diaryMinutes(stats.playSeconds ~/ 60),
      ),
    ];
    return ScreenFrame(
      title: l10n.diaryTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      child: Column(
        children: [
          TBText.body(l10n.diaryIntro, color: TBColors.ink700),
          const SizedBox(height: TBSpacing.s16),
          for (final (icon, label, value) in entries) ...[
            Semantics(
              container: true,
              label: '$label: $value',
              excludeSemantics: true,
              child: TBPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: TBSpacing.s16,
                  vertical: TBSpacing.s12,
                ),
                child: Row(
                  children: [
                    TBIcon(icon),
                    const SizedBox(width: TBSpacing.s12),
                    Expanded(child: TBText.body(label, color: TBColors.ink900)),
                    TBText.counter(value),
                  ],
                ),
              ),
            ),
            const SizedBox(height: TBSpacing.s12),
          ],
        ],
      ),
    );
  }
}
