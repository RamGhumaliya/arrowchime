import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/ui/components/tb_panel.dart';
import 'package:arrowchime/core/ui/components/tb_ribbon.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/features/game/dialogs/board_thumbnail.dart';
import 'package:arrowchime/l10n/gen/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The picture that goes with the shared Daily Knot text (`docs/10` §7): a
/// paper card with the ribbon "Daily Knot #142", the hearts and Flow of the
/// run, the time, and the finished board's colours.
class ShareCard extends StatelessWidget {
  const new({
    required this.dateKey,
    required this.result,
    required this.level,
    required this.theme,
    super.key,
  });

  /// Logical size of the card (rendered at a higher pixel ratio).
  static const Size size = Size(360, 450);

  final String dateKey;
  final DailyResult result;
  final Level level;
  final ChapterTheme theme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final minutes = result.seconds ~/ 60;
    final seconds = (result.seconds % 60).toString().padLeft(2, '0');
    return SizedBox.fromSize(
      size: size,
      child: TBPanel(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TBRibbon(l10n.dailyTitle(DateKey.dayOfYear(dateKey))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < level.hearts; i++)
                  TBIcon(
                    i < result.heartsLeft
                        ? TBIconId.heart
                        : TBIconId.heartBroken,
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: TBSpacing.s8),
                child: BoardThumbnail(
                  level: level,
                  theme: theme,
                  remaining: {for (final a in level.arrows) a.id},
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TBIcon(TBIconId.flame),
                TBText.counter('×${result.bestFlow}', color: TBColors.ink900),
                const SizedBox(width: TBSpacing.s24),
                TBText.counter('$minutes:$seconds', color: TBColors.ink900),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Paints [card] off-screen and returns it as a PNG. [context] must be in
  /// the widget tree (it provides the overlay, theme and locale).
  static Future<Uint8List?> capture(
    BuildContext context,
    Widget card, {
    double pixelRatio = 3,
  }) async {
    final key = GlobalKey();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -size.width * 2,
        top: 0,
        child: RepaintBoundary(key: key, child: card),
      ),
    );
    overlay.insert(entry);
    try {
      // One frame so the card has laid out and painted.
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      entry.remove();
    }
  }
}
