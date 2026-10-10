import 'dart:math' as math;

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_chapter_card.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/widgets.dart';

/// Full-bleed chapter scene behind Home (`docs/10` §7): the chapter's sky and
/// ridges, restored in colour by [restoration], with soft cloud layers
/// drifting at three speeds as the parallax placeholder. Reduce Motion: the
/// clouds stand still.
class HomeBackdrop extends StatefulWidget {
  const new({required this.theme, required this.restoration, super.key});

  final ChapterTheme theme;
  final double restoration;

  @override
  State<HomeBackdrop> createState() => _HomeBackdropState();
}

class _HomeBackdropState extends State<HomeBackdrop>
    with SingleTickerProviderStateMixin {
  /// One full drift of the cloud layers.
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: ChapterScenePainter(
              chapter: widget.theme,
              restoration: widget.restoration,
              locked: false,
            ),
          ),
          CustomPaint(
            painter: _CloudsPainter(_drift, dark: widget.theme.darkTray),
          ),
        ],
      ),
    );
  }
}

/// Three layers of soft cloud blobs: far (slow, small, faint) to near (fast,
/// big).
class _CloudsPainter extends CustomPainter {
  new(this.t, {required this.dark}) : super(repaint: t);

  final Animation<double> t;
  final bool dark;

  static const List<(double speed, double scale, double alpha, double y)>
  _layers = [(1, 0.5, 0.10, 0.18), (2, 0.8, 0.14, 0.30), (3, 1.2, 0.18, 0.12)];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (speed, scale, alpha, y) in _layers) {
      final paint = Paint()
        ..color = (dark ? TBShade.white(alpha * 0.6) : TBShade.white(alpha));
      final shift = t.value * speed * size.width;
      for (var i = 0; i < 3; i++) {
        final x =
            ((i * size.width / 2.2 + shift) % (size.width * 1.4)) -
            size.width * 0.2;
        final cy = size.height * (y + 0.07 * math.sin(i * 2.1 + speed));
        final r = size.width * 0.10 * scale;
        canvas
          ..drawCircle(Offset(x, cy), r, paint)
          ..drawCircle(Offset(x + r, cy + r * 0.2), r * 0.8, paint)
          ..drawCircle(Offset(x - r, cy + r * 0.3), r * 0.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_CloudsPainter old) => old.dark != dark;
}
