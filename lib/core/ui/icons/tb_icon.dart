import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_id.dart';
import 'package:arrowchime/core/ui/icons/tb_icon_shapes.dart';
import 'package:flutter/widgets.dart';

/// A flat icon (`docs/10` §6, V2): solid colour shapes painted in code. Never
/// a Material icon or an emoji (B4).
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

/// Paints [TBIconShapes.partsFor] as flat colour shapes (V2 "Clean Line").
class TBIconPainter extends CustomPainter {
  const new(this.id);

  final TBIconId id;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final scale = Matrix4.diagonal3Values(s, s, 1).storage;
    for (final part in TBIconShapes.partsFor(id)) {
      canvas.drawPath(part.path.transform(scale), Paint()..color = part.color);
    }
  }

  @override
  bool shouldRepaint(TBIconPainter old) => old.id != id;
}
