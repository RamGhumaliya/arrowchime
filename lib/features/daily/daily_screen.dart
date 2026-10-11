import 'dart:async';

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ads/ads_controller.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/meta/daily_share.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/meta/meta_actions.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:arrowchime/core/meta/streak.dart';
import 'package:arrowchime/core/remote_config/app_config.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/share/share_service.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_sheet.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/components/tb_toast.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:arrowchime/features/daily/share_card.dart';
import 'package:arrowchime/features/game/dialogs/board_thumbnail.dart';
import 'package:arrowchime/features/game/state/level_ref.dart';
import 'package:arrowchime/features/game/state/level_repository.dart';
import 'package:arrowchime/features/shared/screen_frame.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Daily Knot (`docs/10` §7): today's seeded puzzle, one primary button
/// (PLAY TODAY, or Share once it is done), a 30-day calendar where a missed
/// day can be replayed for coins, and the streak with its freezes.
class DailyScreen extends ConsumerWidget {
  const new({super.key});

  /// Height of the board preview.
  static const double _previewHeight = 200;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final save = ref.watch(saveControllerProvider);
    final now = ref.watch(clockProvider)();
    final todayKey = DateKey.utc(now);
    final id = LevelRef.dailyOf(todayKey);
    final level = ref.watch(levelProvider(id));
    final theme = ChapterTheme.byId(id.chapter);
    final result = save.daily[todayKey];

    return ScreenFrame(
      title: l10n.dailyTitle(DateKey.dayOfYear(todayKey)),
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      trailing: TBPill(
        icon: TBIconId.coin,
        value: '${save.coins}',
        semanticLabel: l10n.gameCoinsLabel(save.coins),
      ),
      child: Column(
        children: [
          TBPanel(
            child: Column(
              children: [
                SizedBox(
                  height: _previewHeight,
                  child: level.when(
                    data: (l) => BoardThumbnail(
                      level: l,
                      theme: theme,
                      remaining: {for (final a in l.arrows) a.id},
                    ),
                    loading: () => Center(
                      child: TBText.body(
                        l10n.dailyLoading,
                        color: TBColors.ink700,
                      ),
                    ),
                    error: (_, _) => Center(
                      child: TBText.body(
                        l10n.gameLoadError,
                        color: TBColors.ink700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: TBSpacing.s12),
                if (level.value case final l?)
                  TBText.body(
                    l10n.dailyInfo(l.width, l.arrows.length),
                    color: TBColors.ink900,
                  ),
                if (result != null) ...[
                  const SizedBox(height: TBSpacing.s8),
                  _BestRow(result: result),
                ],
              ],
            ),
          ),
          const SizedBox(height: TBSpacing.s16),
          if (result == null)
            TBButton.primary(
              label: l10n.dailyPlay,
              expand: true,
              onPressed: level.hasValue
                  ? () => context.push(AppRoutes.dailyPlayPath(todayKey))
                  : null,
            )
          else
            TBButton.primary(
              label: l10n.dailyShare,
              expand: true,
              onPressed: level.value == null
                  ? null
                  : () => _share(
                      context,
                      ref,
                      todayKey,
                      result,
                      level.value!,
                      theme,
                    ),
            ),
          const SizedBox(height: TBSpacing.s16),
          _Calendar(save: save, todayKey: todayKey),
          const SizedBox(height: TBSpacing.s16),
          _StreakRow(save: save, now: now),
        ],
      ),
    );
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    String dateKey,
    DailyResult result,
    Level level,
    ChapterTheme theme,
  ) async {
    final l10n = AppLocalizations.of(context);
    final image = await ShareCard.capture(
      context,
      ShareCard(dateKey: dateKey, result: result, level: level, theme: theme),
    );
    await ref
        .read(shareServiceProvider)
        .share(text: DailyShare.text(dateKey, result, level), image: image);
    if (context.mounted) showTBToast(context, l10n.dailyShared);
  }
}

class _BestRow extends StatelessWidget {
  const new({required this.result});

  final DailyResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TBText.caption(l10n.dailyBest, color: TBColors.ink700),
        const SizedBox(width: TBSpacing.s8),
        Semantics(
          label: l10n.dailyHearts(result.heartsLeft),
          excludeSemantics: true,
          child: Row(
            children: [
              for (var i = 0; i < result.heartsLeft; i++)
                const TBIcon(TBIconId.heart, size: TBSpacing.s24),
            ],
          ),
        ),
        const SizedBox(width: TBSpacing.s8),
        const TBIcon(TBIconId.flame, size: TBSpacing.s24),
        TBText.counter('×${result.bestFlow}', color: TBColors.ink900),
      ],
    );
  }
}

class _Calendar extends ConsumerWidget {
  const new({required this.save, required this.todayKey});

  final SaveData save;
  final String todayKey;

  static const double _cell = TBSizes.minTapTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final days = Progression.calendar(save, todayKey);
    final lead = DateKey.parse(days.first.key).weekday - 1;
    final weekdays = [
      l10n.weekday1,
      l10n.weekday2,
      l10n.weekday3,
      l10n.weekday4,
      l10n.weekday5,
      l10n.weekday6,
      l10n.weekday7,
    ];
    return TBPanel.recessed(
      child: Column(
        children: [
          TBText.caption(l10n.dailyCalendar, color: TBColors.ink900),
          const SizedBox(height: TBSpacing.s8),
          Table(
            children: [
              TableRow(
                children: [
                  for (final w in weekdays)
                    Center(child: TBText.caption(w, color: TBColors.ink700)),
                ],
              ),
              for (var row = 0; row * 7 - lead < days.length; row++)
                TableRow(
                  children: [
                    for (var col = 0; col < 7; col++)
                      _cellAt(context, ref, days, row * 7 + col - lead),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cellAt(
    BuildContext context,
    WidgetRef ref,
    List<CalendarDay> days,
    int i,
  ) {
    if (i < 0 || i >= days.length) return const SizedBox(height: _cell);
    final day = days[i];
    final l10n = AppLocalizations.of(context);
    final label = day.isToday
        ? l10n.dailyDayToday(day.key)
        : (day.played
              ? l10n.dailyDayPlayed(day.key)
              : l10n.dailyDayMissed(day.key));
    final number = DateKey.parse(day.key).day;
    return TBPressable(
      onPressed: day.missed ? () => _replay(context, ref, day.key) : null,
      semanticLabel: label,
      hapticOnPress: day.missed,
      builder: (context, press) => SizedBox(
        height: _cell,
        child: Center(
          child: CustomPaint(
            size: const Size.square(TBSizes.minTapTarget - TBSpacing.s8),
            painter: _DayPainter(
              played: day.played,
              today: day.isToday,
              pressed: press.press,
            ),
            child: SizedBox.square(
              dimension: TBSizes.minTapTarget - TBSpacing.s8,
              child: Center(
                child: TBText.caption(
                  '$number',
                  color: day.played ? TBColors.ink900 : TBColors.cream300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _replay(BuildContext context, WidgetRef ref, String key) {
    final coins = ref.read(saveControllerProvider).coins;
    unawaited(
      showTBSheet<void>(
        context,
        sheet: _ReplaySheet(
          dateKey: key,
          canAfford: coins >= ref.read(appConfigProvider).missedDailyPrice,
        ),
      ),
    );
  }
}

class _ReplaySheet extends ConsumerWidget {
  const new({required this.dateKey, required this.canAfford});

  final String dateKey;
  final bool canAfford;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final price = ref.watch(appConfigProvider).missedDailyPrice;
    return TBSheet(
      title: l10n.dailyReplayTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TBText.body(l10n.dailyReplayBody(price), color: TBColors.ink900),
          const SizedBox(height: TBSpacing.s16),
          TBButton.primary(
            label: l10n.dailyReplayAction(price),
            expand: true,
            onPressed: canAfford
                ? () {
                    if (ref
                        .read(metaActionsProvider)
                        .payForMissedDaily(dateKey)) {
                      Navigator.of(context).pop();
                      unawaited(context.push(AppRoutes.dailyPlayPath(dateKey)));
                    }
                  }
                : null,
          ),
          if (ref.read(adsControllerProvider).rewardedAvailable) ...[
            const SizedBox(height: TBSpacing.s8),
            TBButton.secondary(
              label: l10n.dailyUnlockAd,
              expand: true,
              onPressed: () async {
                final earned = await ref
                    .read(adsControllerProvider)
                    .showRewarded();
                if (!earned || !context.mounted) return;
                Navigator.of(context).pop();
                unawaited(context.push(AppRoutes.dailyPlayPath(dateKey)));
              },
            ),
          ],
          const SizedBox(height: TBSpacing.s8),
          TBButton.tertiary(
            label: l10n.gameBack,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _DayPainter extends CustomPainter {
  const new({required this.played, required this.today, required this.pressed});

  final bool played;
  final bool today;
  final double pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final face = played ? TBMaterials.brassFace : TBColors.ink500;
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas
      ..drawCircle(
        c + const Offset(0, 2),
        r,
        Paint()..color = TBShade.bevelDark(face),
      )
      ..drawCircle(c + Offset(0, pressed * 2), r, Paint()..color = face);
    if (today) {
      canvas.drawCircle(
        c,
        r + 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = TBColors.tangerine,
      );
    }
  }

  @override
  bool shouldRepaint(_DayPainter old) =>
      old.played != played || old.today != today || old.pressed != pressed;
}

class _StreakRow extends ConsumerWidget {
  const new({required this.save, required this.now});

  final SaveData save;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final count = Streak.liveCount(save.streak, DateKey.of(now));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TBIcon(
              TBIconId.flame,
              size: TBSizes.buttonIcon + Streak.tierOf(count) * TBSpacing.s4,
            ),
            TBText.counter('$count', color: TBColors.cream100),
          ],
        ),
        TBText.caption(
          l10n.dailyFreezes(save.streak.freezes),
          color: TBColors.cream100,
        ),
        if (save.streak.freezes < Streak.maxFreezes)
          TBButton.tertiary(
            label: l10n.dailyBuyFreeze(
              ref.watch(appConfigProvider).streakFreezePrice,
            ),
            onPressed:
                save.coins >= ref.watch(appConfigProvider).streakFreezePrice
                ? () => ref.read(metaActionsProvider).buyFreeze()
                : null,
          ),
      ],
    );
  }
}
