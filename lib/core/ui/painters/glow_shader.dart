import 'dart:ui';

import 'package:flutter/foundation.dart';

/// The optional `glow.frag` fragment shader of the Galaxy skin. If it cannot
/// be loaded (a platform without shader support, a missing asset) every caller
/// falls back to the painted glow, so the skin always renders.
abstract final class GlowShader {
  static FragmentProgram? _program;

  /// Whether the shader is loaded.
  static bool get isAvailable => _program != null;

  /// Loads the shader once; failures leave it unavailable.
  static Future<void> load() async {
    if (_program != null) return;
    try {
      _program = await FragmentProgram.fromAsset('assets/shaders/glow.frag');
    } on Object catch (e) {
      debugPrint('glow.frag unavailable, using the painted glow ($e)');
    }
  }

  /// A shader for a glow of [color] over [size]; `null` without the program.
  static Shader? shader(Size size, Color color, {double time = 0}) {
    final program = _program;
    if (program == null) return null;
    return (program.fragmentShader()
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, color.r)
      ..setFloat(4, color.g)
      ..setFloat(5, color.b)
      ..setFloat(6, color.a));
  }
}
