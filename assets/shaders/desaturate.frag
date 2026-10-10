// PLACEHOLDER shader (desaturate): replace with the final effect.
#version 460 core
#include <flutter/runtime_effect.glsl>
uniform vec2 uSize;
uniform float uTime;
out vec4 fragColor;
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  fragColor = vec4(vec3(uv.y), 1.0);
}
