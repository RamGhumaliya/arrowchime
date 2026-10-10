import 'dart:async';

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/meta/achievements.dart';
import 'package:arrowchime/core/meta/player_level.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_progress_bar.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_tab_bar.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:arrowchime/features/shared/achievement_text.dart';
import 'package:arrowchime/features/shared/screen_frame.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Achievements and Stats (`docs/10` §7): two wooden tabs; badge tiles for
/// the ~30 achievements, locked ones as silhouettes with their progress, and a
/// recessed list of lifetime numbers.
class AchievementsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final save = ref.watch(saveControllerProvider);
    return ScreenFrame(
      title: l10n.achTitle,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      trailing: TBPill(
        icon: TBIconId.coin,
        value: '${save.coins}',
        semanticLabel: l10n.gameCoinsLabel(save.coins),
      ),
      child: Column(
        children: [
          TBTabBar(
            tabs: [
              TBTabItem(icon: TBIconId.trophy, label: l10n.achTabAchievements),
              TBTabItem(icon: TBIconId.quests, label: l10n.achTabStats),
            ],
            selectedIndex: _tab,
            onSelected: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: TBSpacing.s16),
          if (_tab == 0) _Grid(save: save) else _Stats(save: save),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const new({required this.save});

  final SaveData save;

  @override
  Widget build(BuildContext context) {
    final defs = Achievements.all;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = TBSpacing.s12;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final a in defs)
              SizedBox(
                width: tileWidth,
                child: _Tile(def: a, save: save),
              ),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const new({required this.def, required this.save});

  final AchievementDef def;
  final SaveData save;

  static const double _medallion = 48;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = save.achievements[def.id];
    final unlocked = date != null;
    final progress = def.progress(save).clamp(0, def.target);
    final title = achievementTitle(l10n, def.id);
    return TBPressable(
      onPressed: () => _details(context, title, date, progress),
      semanticLabel: unlocked
          ? '$title, ${l10n.achUnlocked(date)}'
          : '$title, ${l10n.achProgress(progress, def.target)}',
      builder: (context, press) => Transform.translate(
        offset: Offset(0, TBSizes.buttonPressDepth * press.press),
        child: TBPanel(
          radius: TBRadius.r20,
          padding: const EdgeInsets.all(TBSpacing.s12),
          child: Column(
            children: [
              Opacity(
                opacity: unlocked ? 1 : 0.4,
                child: CustomPaint(
                  painter: const BrassPainter(radius: TBRadius.pill),
                  child: SizedBox.square(
                    dimension: _medallion,
                    child: Center(child: TBIcon(_icon(def.icon))),
                  ),
                ),
              ),
              const SizedBox(height: TBSpacing.s8),
              TBText.body(
                title,
                color: TBColors.ink900,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: TBSpacing.s8),
              if (!unlocked)
                TBProgressBar(
                  value: progress / def.target,
                  shimmer: false,
                  semanticLabel: l10n.achProgress(progress, def.target),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _details(
    BuildContext context,
    String title,
    String? date,
    int progress,
  ) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      showTBSheet<void>(
        context,
        sheet: TBSheet(
          title: title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TBText.body(
                achievementDescription(l10n, def.id),
                color: TBColors.ink900,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TBSpacing.s12),
              TBText.counter(
                date != null
                    ? l10n.achUnlocked(date)
                    : l10n.achProgress(progress, def.target),
                color: TBColors.ink700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static TBIconId _icon(String name) => TBIconId.values.firstWhere(
    (i) => i.name == name,
    orElse: () => TBIconId.star,
  );
}

class _Stats extends StatelessWidget {
  const new({required this.save});

  final SaveData save;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = save.stats;
    final hours = s.playSeconds ~/ 3600;
    final minutes = (s.playSeconds % 3600) ~/ 60;
    final rows = <(String, String)>[
      (l10n.statPlayerLevel, '${PlayerLevel.of(save.xp)}'),
      (l10n.statArrows, '${s.arrowsFreed}'),
      (l10n.statLevels, '${s.levelsCleared}'),
      (l10n.statStars, '${Progression.totalStars(save)}'),
      (l10n.statPerfect, '${s.perfectClears}'),
      (l10n.statFlow, '×${s.bestFlow}'),
      (l10n.statTime, l10n.statTimeValue(hours, minutes)),
      (l10n.statStreak, l10n.statDays(save.streak.best)),
      (l10n.statDailies, '${s.dailiesPlayed}'),
    ];
    return TBPanel.recessed(
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: TBSpacing.s12),
            Semantics(
              label: '${rows[i].$1}, ${rows[i].$2}',
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TBText.body(rows[i].$1, color: TBColors.ink900),
                  ),
                  TBText.counter(rows[i].$2),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
