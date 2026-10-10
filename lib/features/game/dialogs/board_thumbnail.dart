import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/features/game/flame/arrow_visuals.dart';
import 'package:arrowchime/features/game/model/board_geometry.dart';
import 'package:flutter/widgets.dart';

/// A small, desaturated picture of the board where the attempt ended (fail
/// sheet, `docs/10` §7). Painted from the level data, not captured.
class BoardThumbnail extends StatelessWidget {
  const new({
    required this.level,
    required this.theme,
    required this.remaining,
    super.key,
  });

  final Level level;
  final ChapterTheme theme;

  /// Ids of the arrows still on the board.
  final Set<int> remaining;

  @override
  Widget build(BuildContext context) {
    final geometry = BoardGeometry(level);
    return AspectRatio(
      aspectRatio: geometry.worldSize.width / geometry.worldSize.height,
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _ThumbnailPainter(level, theme, remaining, geometry),
        ),
      ),
    );
  }
}

class _ThumbnailPainter extends CustomPainter {
  const new(this.level, this.theme, this.remaining, this.geometry);

  final Level level;
  final ChapterTheme theme;
  final Set<int> remaining;
  final BoardGeometry geometry;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / geometry.worldSize.width;
    canvas.scale(scale);
    Felt.paintTray(
      canvas,
      geometry.worldSize,
      felt: TBShade.desaturate(theme.trayFelt, 0.8),
      radius: geometry.cell * 0.5,
    );
    for (final arrow in level.arrows) {
      if (!remaining.contains(arrow.id)) continue;
      EnamelTube.paint(
        canvas,
        [for (final c in arrow.body) geometry.center(c)],
        geometry.cell,
        TBShade.desaturate(ArrowVisuals.arrowColor(arrow, theme), 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_ThumbnailPainter old) =>
      old.level != level || old.remaining != remaining || old.theme != theme;
}
