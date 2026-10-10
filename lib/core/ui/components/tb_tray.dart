import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:flutter/widgets.dart';

/// The board tray (`docs/10` §8): a recessed felt surface in the chapter's
/// tray colour with fabric noise, an inner shadow along the top/left edges
/// and a 6 dp wooden rim. The game board sits on it.
class TBTray extends StatelessWidget {
  const new({required this.chapter, required this.child, super.key});

  final ChapterTheme chapter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrayPainter(felt: chapter.trayFelt),
      child: Padding(
        padding: const EdgeInsets.all(TBBevel.woodRim + TBSpacing.s8),
        child: child,
      ),
    );
  }
}

class _TrayPainter extends CustomPainter {
  const new({required this.felt});

  final Color felt;

  @override
  void paint(Canvas canvas, Size size) =>
      Felt.paintTray(canvas, size, felt: felt);

  @override
  bool shouldRepaint(_TrayPainter old) => old.felt != felt;
}
