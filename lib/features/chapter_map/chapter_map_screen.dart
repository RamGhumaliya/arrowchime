import 'dart:math' as math;

import 'package:arrowchime/app/router.dart';
import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/meta/progression.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/ui/components/tb_button.dart';
import 'package:arrowchime/core/ui/components/tb_chapter_card.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_pill.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:arrowchime/core/ui/support/tb_pressable.dart';
import 'package:arrowchime/features/shared/chapter_names.dart';
import 'package:arrowchime/features/shared/screen_frame.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Chapter Map (`docs/10` §7): a horizontal pager of chapter cards with the
/// restoration of each, the focused chapter's 60 level pips and one PLAY.
class ChapterMapScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ChapterMapScreen> createState() => _ChapterMapScreenState();
}

class _ChapterMapScreenState extends ConsumerState<ChapterMapScreen> {
  late PageController _pager;
  late int _page;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final (chapter, _) = Progression.playTarget(
      ref.read(saveControllerProvider),
    );
    _page = chapter - 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    // One card plus a gap per page, whatever the screen width.
    final width = math.min(
      MediaQuery.sizeOf(context).width - 2 * TBLayout.screenMargin(context),
      TBSizes.contentMaxWidth,
    );
    final fraction = ((TBSizes.chapterCardWidth + TBSpacing.s16) / width).clamp(
      0.3,
      1.0,
    );
    _pager = PageController(initialPage: _page, viewportFraction: fraction);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final save = ref.watch(saveControllerProvider);
    final chapter = _page + 1;
    final theme = ChapterTheme.byId(chapter);
    final unlocked = Progression.isChapterUnlocked(save, chapter);
    final next = Progression.nextIndex(save, chapter);
    final stars = Progression.chapterStars(save, chapter);

    return ScreenFrame(
      title: l10n.mapTitle,
      theme: theme,
      onBack: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.home),
      trailing: TBPill(
        icon: TBIconId.coin,
        value: '${save.coins}',
        semanticLabel: l10n.gameCoinsLabel(save.coins),
      ),
      child: Column(
        children: [
          SizedBox(
            height: TBSizes.chapterCardHeight + TBSpacing.s16,
            child: PageView.builder(
              controller: _pager,
              itemCount: Progression.chapters,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final c = i + 1;
                final open = Progression.isChapterUnlocked(save, c);
                final percent = (Progression.restoration(save, c) * 100)
                    .round();
                return Center(
                  child: Semantics(
                    label: open
                        ? l10n.mapChapterSemantics(
                            chapterName(l10n, c),
                            percent,
                          )
                        : l10n.mapChapterLocked(chapterName(l10n, c)),
                    child: TBChapterCard(
                      chapter: ChapterTheme.byId(c),
                      restoration: Progression.restoration(save, c),
                      focused: i == _page,
                      locked: !open,
                      onTap: () => _pager.animateToPage(
                        i,
                        duration: TBMotion.enter,
                        curve: TBMotion.enterCurve,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: TBSpacing.s8),
          _Dots(count: Progression.chapters, index: _page),
          const SizedBox(height: TBSpacing.s8),
          TBText.title(chapterName(l10n, chapter), color: TBColors.cream100),
          TBText.body(
            unlocked ? l10n.mapStars(stars, 180) : l10n.mapLocked,
            color: TBColors.cream100,
          ),
          const SizedBox(height: TBSpacing.s16),
          TBPanel.recessed(
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 1; i <= Progression.levelsPerChapter; i++)
                    _Pip(
                      index: i,
                      stars: save.starsOf(Progression.levelId(chapter, i)),
                      state: !unlocked || i > next
                          ? _PipState.locked
                          : (i == next ? _PipState.next : _PipState.done),
                      onTap: unlocked && i <= next
                          ? () => context.push(
                              AppRoutes.levelPath('ch$chapter', i),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TBSpacing.s16),
          if (unlocked && next <= Progression.levelsPerChapter)
            TBButton.primary(
              label: l10n.mapPlay(next),
              onPressed: () =>
                  context.push(AppRoutes.levelPath('ch$chapter', next)),
            ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const new({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TBSpacing.s4),
              child: SizedBox.square(
                dimension: TBSpacing.s8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == index
                        ? TBColors.tangerine
                        : TBShade.white(0.35),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _PipState { done, next, locked }

/// One level on the strip: brass when cleared (with its stars under it),
/// tangerine for the next one, grey when locked; every 10th is a hexagon-like
/// Knot, the 60th a Boss (the trophy mark).
class _Pip extends StatelessWidget {
  const new({
    required this.index,
    required this.stars,
    required this.state,
    required this.onTap,
  });

  final int index;
  final int stars;
  final _PipState state;
  final VoidCallback? onTap;

  static const double _starSize = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (state) {
      _PipState.done => l10n.mapLevelPip(index, stars),
      _PipState.next => l10n.mapLevelNext(index),
      _PipState.locked => l10n.mapLevelLocked(index),
    };
    return TBPressable(
      onPressed: onTap,
      semanticLabel: label,
      hapticOnPress: onTap != null,
      builder: (context, press) => SizedBox(
        width: TBSizes.minTapTarget,
        height: TBSizes.minTapTarget + TBSpacing.s12,
        child: Transform.translate(
          offset: Offset(0, TBSizes.buttonPressDepth * press.press / 2),
          child: Column(
            children: [
              CustomPaint(
                size: const Size.square(TBSizes.minTapTarget - TBSpacing.s8),
                painter: _PipPainter(
                  state: state,
                  knot: index % 10 == 0,
                  boss: index == Progression.levelsPerChapter,
                ),
                child: SizedBox.square(
                  dimension: TBSizes.minTapTarget - TBSpacing.s8,
                  child: Center(
                    child: TBText.caption(
                      '$index',
                      color: state == _PipState.locked
                          ? TBColors.cream300
                          : TBColors.ink900,
                    ),
                  ),
                ),
              ),
              if (state == _PipState.done)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < stars; i++)
                      const TBIcon(TBIconId.star, size: _starSize),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PipPainter extends CustomPainter {
  const new({required this.state, required this.knot, required this.boss});

  final _PipState state;
  final bool knot;
  final bool boss;

  @override
  void paint(Canvas canvas, Size size) {
    final face = switch (state) {
      _PipState.done => TBMaterials.brassFace,
      _PipState.next => TBColors.tangerine,
      _PipState.locked => TBColors.ink500,
    };
    final rect = Offset.zero & size;
    final shape = knot || boss
        ? RRect.fromRectAndRadius(
            rect.deflate(1),
            const Radius.circular(TBRadius.r12),
          )
        : RRect.fromRectAndRadius(rect, Radius.circular(size.width));
    canvas
      ..drawRRect(
        shape.shift(const Offset(0, 3)),
        Paint()..color = TBShade.bevelDark(face),
      )
      ..drawRRect(shape, Paint()..color = face)
      ..drawRRect(
        shape.deflate(2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = TBShade.white(0.35),
      );
    if (boss) {
      canvas.drawRRect(
        shape.deflate(5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = TBShade.ink(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_PipPainter old) =>
      old.state != state || old.knot != knot || old.boss != boss;
}
