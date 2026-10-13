import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/enamel_tube_painter.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/widgets.dart';

/// The page behind Home (`docs/10` §7, V2 "Clean Line"): the plain page colour
/// with a slow field of faint thin-line arrows drifting across it, like the
/// board in the distance. Reduce Motion: the arrows stand still.
class HomeBackdrop extends StatefulWidget {
  const new({required this.theme, required this.restoration, super.key});

  /// Kept for callers; Home no longer paints a chapter scene.
  final ChapterTheme theme;

  /// Kept for callers.
  final double restoration;

  @override
  State<HomeBackdrop> createState() => _HomeBackdropState();
}

class _HomeBackdropState extends State<HomeBackdrop>
    with SingleTickerProviderStateMixin {
  /// One full drift of the arrow field.
  static final Duration _loop = TBMotion.shimmer * 40;

  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: _loop,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TBMotionScope.reduced(context)) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ColoredBox(
        color: TBColors.page,
        child: CustomPaint(
          size: Size.infinite,
          painter: _ArrowFieldPainter(_drift),
        ),
      ),
    );
  }
}

/// Faint straight arrows in a fixed pattern, drifting right and wrapping.
class _ArrowFieldPainter extends CustomPainter {
  new(this.t) : super(repaint: t);

  final Animation<double> t;

  // (row 0-1, start column 0-1, length in cells, speed multiplier)
  static const List<(double, double, int, double)> _arrows = [
    (0.08, 0.10, 3, 1),
    (0.16, 0.62, 2, 2),
    (0.25, 0.35, 4, 1),
    (0.33, 0.85, 3, 3),
    (0.42, 0.05, 2, 2),
    (0.50, 0.55, 4, 1),
    (0.58, 0.25, 3, 3),
    (0.66, 0.78, 2, 1),
    (0.74, 0.40, 3, 2),
    (0.82, 0.08, 4, 1),
    (0.90, 0.68, 2, 3),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 11;
    final color = TBColors.ink900.withValues(alpha: 0.07);
    final span = size.width + 6 * c;
    for (final (row, start, len, speed) in _arrows) {
      final x = ((start * span + t.value * speed * span) % span) - 3 * c;
      final y = size.height * row;
      EnamelTube.paint(
        canvas,
        [for (var i = 0; i < len; i++) Offset(x + i * c, y)],
        c * 0.8,
        color,
      );
    }
  }

  @override
  bool shouldRepaint(_ArrowFieldPainter old) => false;
}
