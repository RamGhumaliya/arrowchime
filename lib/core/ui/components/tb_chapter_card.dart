import 'dart:ui' as ui;

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/icons/tb_icon.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/painters/brass_painter.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/painters/wood_painter.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/widgets.dart';

/// A chapter as a diorama window (`docs/10` §5): the chapter scene inside a
/// thick wooden frame, the restoration percentage on a brass plaque, and a
/// slight perspective tilt (rotateX 4°) that relaxes to 0 when focused.
///
/// The scene is a code-painted placeholder (gradient + ridges) until the
/// artist's dioramas arrive; debug builds label it.
class TBChapterCard extends StatelessWidget {
  const new({
    required this.chapter,
    required this.restoration,
    this.focused = false,
    this.locked = false,
    this.onTap,
    super.key,
  }) : assert(restoration >= 0 && restoration <= 1, 'restoration is 0-1');

  final ChapterTheme chapter;

  /// 0–1 share of the scene restored.
  final double restoration;

  /// The centred card of the chapter map: tilt relaxes to 0.
  final bool focused;

  /// Locked chapters show a desaturated silhouette and a lock.
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reduced = TBMotionScope.reduced(context);
    return Semantics(
      button: onTap != null,
      enabled: !locked,
      label: locked
          ? '${chapter.name}, locked'
          : '${chapter.name}, ${(restoration * 100).round()} percent restored',
      excludeSemantics: true,
      onTap: locked ? null : onTap,
      child: GestureDetector(
        onTap: locked ? null : onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: focused || reduced ? 0 : TBSizes.tiltDegrees),
          duration: TBMotionScope.duration(context, TBMotion.enter),
          curve: TBMotion.enterCurve,
          builder: (context, degrees, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(degrees * 3.14159265 / 180),
            child: child,
          ),
          child: SizedBox(
            width: TBSizes.chapterCardWidth,
            height: TBSizes.chapterCardHeight,
            child: CustomPaint(
              painter: const _FramePainter(),
              child: Padding(
                padding: const EdgeInsets.all(TBSizes.chapterFrame),
                child: ClipRRect(
                  borderRadius: TBRadius.br12,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _ScenePainter(
                          chapter: chapter,
                          restoration: locked ? 0 : restoration,
                          locked: locked,
                        ),
                      ),
                      if (locked)
                        const Center(
                          child: TBIcon(
                            TBIconId.lock,
                            size: TBSizes.buttonIcon * 2,
                          ),
                        ),
                      if (kDebugMode)
                        Positioned(
                          top: TBSpacing.s8,
                          left: TBSpacing.s8,
                          child: TBText.caption(
                            'PLACEHOLDER · ch${chapter.id}/scene',
                            color: TBShade.white(0.8),
                          ),
                        ),
                      Positioned(
                        left: TBSpacing.s12,
                        right: TBSpacing.s12,
                        bottom: TBSpacing.s12,
                        child: _Plaque(
                          name: chapter.name,
                          restoration: restoration,
                          locked: locked,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) =>
      Wood.paint(canvas, size, grainSeed: 9);

  @override
  bool shouldRepaint(_FramePainter old) => false;
}

class _Plaque extends StatelessWidget {
  const new({
    required this.name,
    required this.restoration,
    required this.locked,
  });

  final String name;
  final double restoration;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const BrassPainter(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TBSpacing.s12,
          vertical: TBSpacing.s8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TBText.caption(
                name,
                color: TBColors.cream100,
                maxLines: 1,
              ),
            ),
            TBText.counter(
              locked ? '—' : '${(restoration * 100).round()}%',
              color: TBColors.cream100,
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder diorama: sky gradient, three ridges, and a colour wash that
/// grows with the restoration (grey scene → coloured scene).
class _ScenePainter extends CustomPainter {
  const new({
    required this.chapter,
    required this.restoration,
    required this.locked,
  });

  final ChapterTheme chapter;
  final double restoration;
  final bool locked;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Grey (misty) at 0 restoration, full chapter colour at 1.
    Color tone(Color c) => locked
        ? TBShade.desaturate(c, 0.9)
        : TBShade.desaturate(c, 0.85 * (1 - restoration));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
          tone(chapter.skyTop),
          tone(chapter.skyBottom),
        ]),
    );
    final ridgeColors = [
      Color.lerp(chapter.skyBottom, TBColors.ink900, 0.25)!,
      Color.lerp(chapter.skyBottom, TBColors.ink900, 0.45)!,
      Color.lerp(chapter.skyBottom, TBColors.ink900, 0.65)!,
    ];
    final bases = [0.5, 0.64, 0.78];
    for (var i = 0; i < 3; i++) {
      final base = size.height * bases[i];
      final period = size.width / (1.5 + i);
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width + period; x += period / 2) {
        final up = (x / (period / 2)).round().isEven;
        path.lineTo(x, base - (up ? size.height * 0.07 : 0));
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = tone(ridgeColors[i]));
    }
    if (locked) {
      canvas.drawRect(rect, Paint()..color = TBShade.ink(0.45));
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) =>
      old.chapter != chapter ||
      old.restoration != restoration ||
      old.locked != locked;
}
