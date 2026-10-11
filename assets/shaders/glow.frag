// Glow shader for the Galaxy arrow skin (docs/06 §6). PLACEHOLDER quality:
// a slow shimmering band in the arrow's colour; a shader artist replaces it.
// Uniforms: uSize (px), uTime (s), uColor (premultiplied-able RGBA).
#version 460 core
#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float uTime;
uniform vec4 uColor;
out vec4 fragColor;
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float band = 0.5 + 0.5 * sin((uv.x + uv.y) * 9.0 + uTime);
  float a = uColor.a * (0.55 + 0.45 * band);
  fragColor = vec4(uColor.rgb * a, a);
}
