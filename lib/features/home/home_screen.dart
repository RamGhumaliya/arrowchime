import 'dart:async';

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/meta/meta_actions.dart';
import 'package:arrowchime/core/meta/player_level.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:arrowchime/core/meta/streak.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_icon_button.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:arrowchime/features/home/daily_plaque.dart';
import 'package:arrowchime/features/home/home_backdrop.dart';
import 'package:arrowchime/features/home/streak_badge.dart';
import 'package:arrowchime/features/quests/quests_sheet.dart';
import 'package:arrowchime/features/shared/chapter_names.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home (`docs/10` §7): the chapter scene full-bleed, the player-level and
/// coin pills and settings on top, the Daily plaque and streak flame, one big
/// PLAY button and a wooden shelf of Shop / Collection / Quests.
class HomeScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// PLAY is 72% of the width (`docs/10` §7).
  static const double _playWidth = 0.72;

  @override
  void initState() {
    super.initState();
    // Draw today's quests and this week's free freeze, and bring the chapter's
    // music back after a level.
    unawaited(
      Future.microtask(() {
        ref.read(metaActionsProvider).refreshDay();
        final (chapter, _) = Progression.playTarget(
          ref.read(saveControllerProvider),
        );
        unawaited(ref.read(audioServiceProvider).enterChapter(chapter));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final save = ref.watch(saveControllerProvider);
    final now = ref.watch(clockProvider)();
    final (chapter, index) = Progression.playTarget(save);
    final theme = ChapterTheme.byId(chapter);
    final margin = TBLayout.screenMargin(context);
    final width = MediaQuery.sizeOf(context).width;
    final percent = (Progression.restoration(save, chapter) * 100).round();
    final dailyDone = save.daily.containsKey(DateKey.utc(now));
    final streak = Streak.liveCount(save.streak, DateKey.of(now));

    return Stack(
      fit: StackFit.expand,
      children: [
        HomeBackdrop(
          theme: theme,
          restoration: Progression.restoration(save, chapter),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              margin,
              TBSpacing.s8,
              margin,
              TBSpacing.s16,
            ),
            child: TBCentered(
              maxWidth: TBSizes.sheetMaxWidth,
              child: Column(
                children: [
                  _TopRow(
                    level: PlayerLevel.of(save.xp),
                    coins: save.coins,
                    onLevel: () => context.push(AppRoutes.achievements),
                    onAddCoins: () => context.push(AppRoutes.shop),
                    onSettings: () => context.push(AppRoutes.settings),
                  ),
                  const SizedBox(height: TBSpacing.s12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _ChapterPlaque(
                      label: l10n.homeChapterPlaque(
                        chapterName(l10n, chapter),
                        percent,
                      ),
                      onTap: () => context.push(AppRoutes.chapterMap),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      DailyPlaque(
                        done: dailyDone,
                        onTap: () => context.push(AppRoutes.daily),
                      ),
                      const Spacer(),
                      StreakBadge(count: streak),
                    ],
                  ),
                  const SizedBox(height: TBSpacing.s24),
                  SizedBox(
                    width: (width - 2 * margin) * _playWidth,
                    child: TBButton.primary(
                      label: l10n.homePlay(index),
                      expand: true,
                      onPressed: () => context.push(
                        AppRoutes.levelPath('ch$chapter', index),
                      ),
                    ),
                  ),
                  const SizedBox(height: TBSpacing.s24),
                  _Shelf(
                    onShop: () => context.push(AppRoutes.shop),
                    onCollection: () => context.push(AppRoutes.collection),
                    onQuests: () => showQuestsSheet(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopRow extends StatelessWidget {
  const new({
    required this.level,
    required this.coins,
    required this.onLevel,
    required this.onAddCoins,
    required this.onSettings,
  });

  final int level;
  final int coins;
  final VoidCallback onLevel;
  final VoidCallback onAddCoins;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TBPressable(
            onPressed: onLevel,
            semanticLabel: l10n.homeAchievements,
            builder: (context, _) => TBPill(
              icon: TBIconId.star,
              value: l10n.homePlayerLevel(level),
              semanticLabel: l10n.homePlayerLevel(level),
            ),
          ),
          const SizedBox(width: TBSpacing.s8),
          TBPill(
            icon: TBIconId.coin,
            value: '$coins',
            onAdd: onAddCoins,
            semanticLabel: l10n.gameCoinsLabel(coins),
          ),
          const SizedBox(width: TBSpacing.s8),
          TBIconButton(
            icon: TBIconId.settings,
            semanticLabel: l10n.homeSettings,
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

class _ChapterPlaque extends StatelessWidget {
  const new({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TBPressable(
      onPressed: onTap,
      semanticLabel: label,
      builder: (context, press) => Transform.translate(
        offset: Offset(0, TBSizes.buttonPressDepth * press.press),
        child: TBPanel(
          radius: TBRadius.r20,
          padding: const EdgeInsets.symmetric(
            horizontal: TBSpacing.s16,
            vertical: TBSpacing.s8,
          ),
          child: TBText.body(label, color: TBColors.ink900),
        ),
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  const new({
    required this.onShop,
    required this.onCollection,
    required this.onQuests,
  });

  final VoidCallback onShop;
  final VoidCallback onCollection;
  final VoidCallback onQuests;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CustomPaint(
      painter: const _ShelfPainter(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TBSpacing.s24,
          vertical: TBSpacing.s12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TBIconButton(
              icon: TBIconId.shop,
              semanticLabel: l10n.homeShop,
              onPressed: onShop,
            ),
            TBIconButton(
              icon: TBIconId.collection,
              semanticLabel: l10n.homeCollection,
              onPressed: onCollection,
            ),
            TBIconButton(
              icon: TBIconId.quests,
              semanticLabel: l10n.homeQuests,
              onPressed: onQuests,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShelfPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) => Wood.paint(canvas, size);

  @override
  bool shouldRepaint(_ShelfPainter old) => false;
}
