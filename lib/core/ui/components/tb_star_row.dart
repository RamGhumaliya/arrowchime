import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/widgets.dart';

/// Three brass-rimmed stars. Empty = a recessed socket with a dim star; each
/// newly earned star stamps in (scale overshoot) with a dust puff, one every
/// 180 ms (GDD §4 "Star award"). Under Reduce Motion they just fade in.
class TBStarRow extends StatefulWidget {
  const new({
    required this.filled,
    this.animate = true,
    this.starSize = TBSizes.starRowStar,
    super.key,
  }) : assert(filled >= 0 && filled <= 3, 'a level has 0-3 stars');

  /// Stars earned, 0–3.
  final int filled;

  /// Play the stamp animation (off for goldens: stars appear filled).
  final bool animate;
  final double starSize;

  @override
  State<TBStarRow> createState() => _TBStarRowState();
}

class _TBStarRowState extends State<TBStarRow> with TickerProviderStateMixin {
  late final List<AnimationController> _stamps = [
    for (var i = 0; i < 3; i++)
      AnimationController(vsync: this, duration: TBMotion.celebrateMin),
  ];

  @override
  void initState() {
    super.initState();
    _run(from: 0);
  }

  @override
  void didUpdateWidget(TBStarRow old) {
    super.didUpdateWidget(old);
    if (widget.filled > old.filled) {
      _run(from: old.filled);
    } else if (widget.filled < old.filled) {
      for (var i = widget.filled; i < 3; i++) {
        _stamps[i].value = 0;
      }
    }
  }

  void _run({required int from}) {
    for (var i = 0; i < 3; i++) {
      final c = _stamps[i];
      if (i >= widget.filled) {
        c.value = 0;
      } else if (i < from || !widget.animate) {
        c.value = 1;
      } else {
        c.value = 0;
        Future<void>.delayed(TBMotion.starStagger * (i - from), () {
          if (mounted) _stamps[i].forward();
        });
      }
    }
  }

  @override
  void dispose() {
    for (final c in _stamps) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = TBMotionScope.reduced(context);
    return Semantics(
      label: '${widget.filled} of 3 stars',
      excludeSemantics: true,
      // Scales down instead of overflowing in narrow containers.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: TBSpacing.s8),
              AnimatedBuilder(
                animation: _stamps[i],
                builder: (context, _) => CustomPaint(
                  size: Size.square(widget.starSize + TBSpacing.s16),
                  painter: _SocketPainter(),
                  foregroundPainter: _PuffPainter(
                    t: _stamps[i].value,
                    reduced: reduced,
                  ),
                  child: SizedBox.square(
                    dimension: widget.starSize + TBSpacing.s16,
                    child: Center(child: _star(i, reduced)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _star(int i, bool reduced) {
    final t = _stamps[i].value;
    final earned = i < widget.filled;
    if (!earned || t == 0) {
      return Opacity(
        opacity: 0.8,
        child: TBIcon(TBIconId.starEmpty, size: widget.starSize),
      );
    }
    if (reduced) {
      return Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: TBIcon(TBIconId.star, size: widget.starSize),
      );
    }
    // Stamp: starts 1.6x, settles at 1 with the release overshoot.
    final scale = 1 + 0.6 * (1 - TBMotion.releaseCurve.transform(t));
    return Transform.scale(
      scale: scale,
      child: TBIcon(TBIconId.star, size: widget.starSize),
    );
  }
}

/// A soft round socket behind each star.
class _SocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2,
      Paint()..color = TBColors.ink900.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(_SocketPainter old) => false;
}

/// Dust puff: six cream specks flying outwards while fading.
class _PuffPainter extends CustomPainter {
  const new({required this.t, required this.reduced});

  final double t;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    if (reduced || t <= 0 || t >= 1) return;
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final fade = 1 - t;
    for (var i = 0; i < 6; i++) {
      final angle = i * 3.14159265 / 3 + 0.4;
      final dist = r * (0.6 + 0.6 * t);
      canvas.drawCircle(
        c + Offset.fromDirection(angle, dist),
        TBSpacing.s4 * (1 - t * 0.5),
        Paint()..color = TBShade.white(0.8 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_PuffPainter old) => old.t != t || old.reduced != reduced;
}
