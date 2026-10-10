import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/meta/meta_actions.dart';
import 'package:arrowchime/core/meta/quests.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_progress_bar.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the daily quests sheet (`docs/10` §7 QUESTS).
Future<void> showQuestsSheet(BuildContext context) =>
    showTBSheet<void>(context, sheet: const QuestsSheet());

/// Three quests with progress bars and Claim buttons, then the chest once all
/// three are claimed. Claim and chest are secondary buttons; the chest is the
/// one primary action when it is ready.
class QuestsSheet extends ConsumerWidget {
  const new({super.key});

  static TBIconId iconOf(QuestMetric m) => switch (m) {
    QuestMetric.levelsCleared => TBIconId.star,
    QuestMetric.flowThree => TBIconId.flame,
    QuestMetric.arrowsFreed => TBIconId.key,
    QuestMetric.perfectClears => TBIconId.trophy,
    QuestMetric.daily => TBIconId.calendar,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final quests = ref.watch(saveControllerProvider.select((s) => s.quests));
    final actions = ref.read(metaActionsProvider);
    return TBSheet(
      title: l10n.questsTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in quests.items) ...[
            _QuestRow(item: item, onClaim: () => actions.claimQuest(item.id)),
            const SizedBox(height: TBSpacing.s12),
          ],
          const SizedBox(height: TBSpacing.s4),
          if (quests.chestOpened)
            TBText.body(l10n.questChestDone, color: TBColors.ink700)
          else
            TBButton.primary(
              label: l10n.questChestOpen,
              expand: true,
              onPressed: Quests.chestReady(quests) ? actions.openChest : null,
            ),
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const new({required this.item, required this.onClaim});

  final QuestProgress item;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final def = Quests.def(item.id);
    final done = Quests.isDone(item);
    return TBPanel.recessed(
      child: Row(
        children: [
          TBIcon(QuestsSheet.iconOf(def.metric)),
          const SizedBox(width: TBSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TBText.body(_title(l10n, item.id), color: TBColors.ink900),
                const SizedBox(height: TBSpacing.s4),
                TBProgressBar(
                  value: item.progress / def.target,
                  semanticLabel: l10n.questProgress(item.progress, def.target),
                  shimmer: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: TBSpacing.s12),
          if (item.claimed)
            const TBIcon(TBIconId.star)
          else if (done)
            TBButton.secondary(label: l10n.questClaim, onPressed: onClaim)
          else
            TBText.counter(l10n.questReward(def.coins)),
        ],
      ),
    );
  }

  static String _title(AppLocalizations l10n, String id) => switch (id) {
    'clear5' => l10n.quest_clear5,
    'clear10' => l10n.quest_clear10,
    'flow3' => l10n.quest_flow3,
    'free100' => l10n.quest_free100,
    'perfect3' => l10n.quest_perfect3,
    _ => l10n.quest_daily1,
  };
}
