import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_shapes.dart';
import 'package:arrowchime/core/ui/painters/shade.dart';
import 'package:flutter/widgets.dart';

/// A placeholder 3D icon (`docs/10` §6): face + lit top-left rim + shaded
/// bottom-right rim + a specular streak, painted in code until the 3D
/// artist's WebP set replaces it. Never a Material icon or an emoji (B4).
class TBIcon extends StatelessWidget {
  const new(this.id, {this.size = TBSizes.buttonIcon, super.key});

  final TBIconId id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: id.semanticLabel,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: TBIconPainter(id)),
      ),
    );
  }
}

/// Paints [TBIconShapes.partsFor] with the Toybox 3D bevel recipe.
class TBIconPainter extends CustomPainter {
  const new(this.id);

  final TBIconId id;

  /// Bevel thickness as a fraction of the icon size.
  static const double _bevel = 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final scale = Matrix4.diagonal3Values(s, s, 1).storage;
    for (final part in TBIconShapes.partsFor(id)) {
      final path = part.path.transform(scale);
      if (!part.bevel) {
        canvas.drawPath(path, Paint()..color = part.color);
        continue;
      }
      _paintBevelled(canvas, path, part.color, s * _bevel);
    }
  }

  /// Face + bevel-light (top-left) + bevel-dark (bottom-right): the dark fill
  /// shows where the shape shifted up-left no longer covers it; the face is
  /// the overlap of the shape shifted both ways.
  void _paintBevelled(Canvas canvas, Path path, Color face, double d) {
    final light = TBShade.bevelLight(face);
    final dark = TBShade.bevelDark(face);
    canvas
      ..save()
      ..clipPath(path)
      ..drawPath(path, Paint()..color = dark)
      ..drawPath(path.shift(Offset(-d, -d)), Paint()..color = light)
      ..save()
      ..clipPath(path.shift(Offset(-d, -d)))
      ..clipPath(path.shift(Offset(d, d)))
      ..drawPath(path, Paint()..color = face)
      ..restore();

    // Specular streak: a short bright line near the top-left of the part.
    final b = path.getBounds();
    final streak = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        b.left + b.width * 0.2,
        b.top + b.height * 0.18,
        b.width * 0.3,
        (d * 0.8).clamp(1.0, double.infinity),
      ),
      Radius.circular(d),
    );
    canvas
      ..drawRRect(
        streak,
        Paint()..color = TBShade.white(TBBevel.specularOpacity * 0.8),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(TBIconPainter old) => old.id != id;
}
