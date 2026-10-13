import 'dart:ui';

import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/ui/painters/glow_shader.dart';

/// The arrow skins (`docs/06` §6, V2): every arrow is a thin line; a skin
/// recolours it and may add a soft glow behind it. [candy] (shown as "Clean
/// Ink") is the default and follows the board's ink colour.
enum ArrowSkin {
  candy,
  bamboo,
  brass,
  silk,
  crystal,
  galaxy,
  neon,
  paper,
  pixel;

  /// The skin named [id] (`candy` when unknown).
  static ArrowSkin fromId(String id) => ArrowSkin.values.firstWhere(
    (s) => s.name == id,
    orElse: () => ArrowSkin.candy,
  );

  /// The line colour of an arrow whose colour is [base] in this skin. The
  /// default [candy] ("Clean Ink") keeps the board's ink colour.
  Color body(Color base) => switch (this) {
    ArrowSkin.candy => base,
    ArrowSkin.bamboo => const Color(0xFF3F9D62),
    ArrowSkin.brass => TBColors.butterLip,
    ArrowSkin.silk => TBColors.berry,
    ArrowSkin.crystal => TBColors.sky,
    ArrowSkin.galaxy => const Color(0xFF6C5CE7),
    ArrowSkin.neon => TBColors.tangerine,
    ArrowSkin.paper => const Color(0xFFFF7A59),
    ArrowSkin.pixel => TBColors.teal,
  };

  /// Whether the skin glows behind the tube (drawn before the body).
  bool get glows => this == ArrowSkin.neon || this == ArrowSkin.galaxy;

  /// Paints the glow of the tube along [body].
  void paintGlow(Canvas canvas, Path body, double c, Color base) {
    if (!glows) return;
    final blur = this == ArrowSkin.neon ? 0.16 : 0.1;
    // Galaxy uses the glow.frag shader when it is available.
    final shader = this == ArrowSkin.galaxy
        ? GlowShader.shader(body.getBounds().size, base)
        : null;
    if (shader != null) {
      canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = c * 0.4
          ..shader = shader
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * blur),
      );
      shader.dispose();
      return;
    }
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = c * 0.4
        ..color = base.withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * blur),
    );
  }
}
