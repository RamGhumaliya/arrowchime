import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/app/theme/typography.dart';
import 'package:arrowchime/core/ui/components/tb_text.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:arrowchime/core/ui/support/tb_layout.dart';
import 'package:flutter/widgets.dart';

/// Ribbon colours (`docs/10` §5, §7): tangerine (win), teal, berry (fail).
enum TBRibbonKind { tangerine, teal, berry }

/// A title banner of folded fabric: a front band, two folded tails with
/// V-notched ends, and the fold triangles tucking them behind the band.
/// Used on Win, Fail and chapter headers.
class TBRibbon extends StatelessWidget {
  const new(
    this.title, {
    this.kind = TBRibbonKind.tangerine,
    this.compact = false,
    super.key,
  });

  final String title;
  final TBRibbonKind kind;

  /// The small ribbon of the level screen's top bar.
  final bool compact;

  (Color, Color) get _colors => switch (kind) {
    TBRibbonKind.tangerine => (TBColors.tangerine, TBColors.tangerineLip),
    TBRibbonKind.teal => (TBColors.teal, TBColors.tealLip),
    TBRibbonKind.berry => (TBColors.berry, TBShade.bevelDark(TBColors.berry)),
  };

  @override
  Widget build(BuildContext context) {
    final (face, lip) = _colors;
    final base = compact ? TBSizes.ribbonHeight * 0.75 : TBSizes.ribbonHeight;
    final titleSize = compact
        ? TBTypography.counter.style.fontSize!
        : TBTypography.title.style.fontSize!;
    final height = base + TBLayout.extraLine(context, titleSize);
    return Semantics(
      header: true,
      label: title,
      excludeSemantics: true,
      child: CustomPaint(
        painter: _RibbonPainter(face: face, lip: lip),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TBSizes.ribbonFold * 2 + TBSpacing.s12,
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: TBSizes.ribbonFold / 2),
              child: Center(
                widthFactor: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: compact ? TBText.counter(title) : TBText.title(title),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const new({required this.face, required this.lip});

  final Color face;
  final Color lip;

  @override
  void paint(Canvas canvas, Size size) {
    const tail = TBSizes.ribbonFold * 2;
    const fold = TBSizes.ribbonFold;
    final w = size.width;
    final h = size.height;
    final bandBottom = h - fold;

    // Folded tails behind the band, lower and darker, with V-notched ends.
    Path tailPath({required bool left}) {
      final outer = left ? 0.0 : w;
      final inner = left ? tail + fold : w - tail - fold;
      final notch = left ? fold : -fold;
      return Path()
        ..moveTo(outer, fold)
        ..lineTo(inner, fold)
        ..lineTo(inner, h)
        ..lineTo(outer, h)
        ..lineTo(outer + notch, (fold + h) / 2)
        ..close();
    }

    for (final left in [true, false]) {
      final p = tailPath(left: left);
      canvas
        ..drawPath(
          p.shift(const Offset(TBSpacing.s4 / 2, TBSpacing.s4)),
          Paint()..color = TBShade.ink(0.2),
        )
        ..drawPath(p, Paint()..color = lip);
      // Fold triangle: the dark underside where the tail tucks behind.
      final x = left ? tail : w - tail;
      final dx = left ? fold : -fold;
      canvas.drawPath(
        Path()
          ..moveTo(x, bandBottom)
          ..lineTo(x + dx, bandBottom)
          ..lineTo(x + dx, h)
          ..close(),
        Paint()..color = TBShade.bevelDark(lip),
      );
    }

    // Front band.
    final band = RRect.fromRectAndRadius(
      Rect.fromLTRB(tail, 0, w - tail, bandBottom),
      const Radius.circular(TBRadius.r12),
    );
    for (final s in TBElevation.e1) {
      canvas.drawRRect(
        band.shift(s.offset),
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }
    canvas
      ..drawRRect(band, Paint()..color = lip)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(tail, 0, w - tail, bandBottom - TBSpacing.s4),
          const Radius.circular(TBRadius.r12),
        ),
        Paint()..color = face,
      )
      // Light rim on the top edge, and a short specular streak.
      ..drawLine(
        const Offset(tail + TBRadius.r12, TBBevel.rimLight),
        Offset(w - tail - TBRadius.r12, TBBevel.rimLight),
        Paint()
          ..strokeWidth = TBBevel.rimLight
          ..strokeCap = StrokeCap.round
          ..color = TBShade.white(TBBevel.innerHighlightOpacity),
      );
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => old.face != face || old.lip != lip;
}
