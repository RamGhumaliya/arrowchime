// Writes an OBVIOUS PLACEHOLDER at every path of assets/ASSET_MANIFEST.md
// (docs/10 §10, docs/07 §6), so final human-made art and audio can be dropped
// in with zero code changes.
//
//   dart run tool/gen_placeholder_assets.dart            # only missing files
//   dart run tool/gen_placeholder_assets.dart --force    # overwrite everything
//   dart run tool/gen_placeholder_assets.dart --list     # print the manifest
//
// Existing files are never overwritten without --force, so real assets that
// replaced a placeholder are safe. Nothing here fetches or generates
// realistic images: placeholders are token-coloured gradients, flat 3-tone
// shapes and synthesised WAV tones. Extensions come from lib/core/assets.dart.
import 'dart:convert';
import 'dart:io';

import 'package:arrowchime/core/assets.dart';

import 'placeholder/font5x7.dart';
import 'placeholder/palette.dart';
import 'placeholder/pixmap.dart';
import 'placeholder/shapes.dart';
import 'placeholder/sounds.dart';
import 'placeholder/svgs.dart';
import 'placeholder/wav.dart';

const _label = 'PLACEHOLDER';

int main(List<String> args) {
  final force = args.contains('--force');
  if (args.contains('--help')) {
    stdout.writeln(
      'Usage: dart run tool/gen_placeholder_assets.dart [--force] [--list]',
    );
    return 0;
  }
  final entries = AssetCatalog.all();
  if (args.contains('--list')) {
    entries.map((e) => e.path).forEach(stdout.writeln);
    return 0;
  }

  final sw = Stopwatch()..start();
  var written = 0;
  var skipped = 0;
  for (final e in entries) {
    final file = File(e.path);
    if (file.existsSync() && !force) {
      skipped++;
      continue;
    }
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(_render(e));
    written++;
  }
  stdout.writeln(
    '${entries.length} manifest files: $written written, $skipped already '
    'present, ${sw.elapsedMilliseconds} ms',
  );
  return 0;
}

List<int> _render(AssetEntry e) => switch (e.kind) {
  AssetKind.brandingImage => _branding(e).toPng(),
  AssetKind.chapterLayer => _chapterLayer(e).toPng(),
  AssetKind.chapterThumb => _chapterThumb(e).toPng(),
  AssetKind.chapterFragments => utf8.encode(_fragments(e.chapter)),
  AssetKind.uiIcon => _uiIcon(e).toPng(),
  AssetKind.mechanicSvg => utf8.encode(Svgs.forName(e.name)),
  AssetKind.mechanicImage => _iceBlock(e).toPng(),
  AssetKind.cosmeticPreview => _cosmetic(e).toPng(),
  AssetKind.shader => utf8.encode(_shader(e.name)),
  AssetKind.rive => const <int>[],
  AssetKind.lottie => utf8.encode(_lottie),
  AssetKind.music => Wav.encode(Sounds.musicLoop(e.chapter)),
  AssetKind.sting => Wav.encode(Sounds.bossSting(e.chapter)),
  AssetKind.note => Wav.encode(Sounds.note(e.extra, e.name)),
  AssetKind.sfx => Wav.encode(Sounds.sfx(e.name)),
  AssetKind.licence => utf8.encode(_licence(e.name)),
};

// --- images -----------------------------------------------------------------

void _blit(Pixmap dst, Pixmap src, int ox, int oy) {
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final i = (y * src.width + x) * 4;
      dst.blend(
        ox + x,
        oy + y,
        src.rgba[i],
        src.rgba[i + 1],
        src.rgba[i + 2],
        src.rgba[i + 3],
      );
    }
  }
}

int _gradientRow(int top, int bottom, int y, int h) =>
    withAlpha(mixColor(top, bottom, y / (h - 1)), 255);

Pixmap _branding(AssetEntry e) {
  final pm = Pixmap(e.width, e.height);
  switch (e.name) {
    case 'app_icon_ios':
      pm.fillRows(
        (y) => _gradientRow(
          PlaceholderPalette.ink700,
          PlaceholderPalette.ink900,
          y,
          e.height,
        ),
      );
      _blit(
        pm,
        paintIcon(Shapes.disc(), PlaceholderPalette.teal, 640),
        192,
        150,
      );
      _stamp(pm, 0.86);
    case 'app_icon_android_bg':
      pm.fillRows(
        (y) => _gradientRow(
          PlaceholderPalette.teal,
          PlaceholderPalette.ink700,
          y,
          e.height,
        ),
      );
    case 'app_icon_android_fg':
      // Foreground lives inside the 264 px safe zone of the 432 px canvas.
      _blit(
        pm,
        paintIcon(Shapes.disc(), PlaceholderPalette.butter, 264),
        84,
        84,
      );
    case 'logo_wordmark':
      const scale = 14;
      final x = (e.width - Font5x7.widthOf('ARROWCHIME', scale)) ~/ 2;
      Font5x7.draw(
        pm,
        'ARROWCHIME',
        x + 6,
        60 + 6,
        scale,
        withAlpha(PlaceholderPalette.ink900, 90),
      );
      Font5x7.draw(
        pm,
        'ARROWCHIME',
        x,
        60,
        scale,
        withAlpha(PlaceholderPalette.cream100, 255),
      );
      Font5x7.drawCentered(
        pm,
        _label,
        250,
        6,
        withAlpha(PlaceholderPalette.berry, 255),
      );
    case 'splash_mark':
      _blit(pm, paintIcon(Shapes.disc(), PlaceholderPalette.teal, 400), 56, 30);
      Font5x7.drawCentered(
        pm,
        _label,
        450,
        5,
        withAlpha(PlaceholderPalette.berry, 255),
      );
  }
  return pm;
}

/// Stamps the PLACEHOLDER label near the bottom of a branding image.
void _stamp(Pixmap pm, double yFraction) {
  Font5x7.drawCentered(
    pm,
    _label,
    (pm.height * yFraction).round(),
    pm.width ~/ 120,
    withAlpha(PlaceholderPalette.cream100, 255),
  );
}

Pixmap _chapterLayer(AssetEntry e) {
  final (skyTop, skyBottom, _) = PlaceholderPalette.chapters[e.chapter]!;
  final pm = Pixmap(e.width, e.height);
  if (e.extra == 'bg_sky') {
    pm.fillRows((y) => _gradientRow(skyTop, skyBottom, y, e.height));
    return pm;
  }
  // Parallax silhouettes: darker, more opaque and lower the nearer the layer.
  final (base, k, alpha, period) = switch (e.extra) {
    'bg_far' => (0.55, 0.25, 120, 360),
    'bg_mid' => (0.68, 0.45, 170, 260),
    'bg_near' => (0.80, 0.65, 210, 190),
    _ => (0.92, 0.80, 240, 130),
  };
  final color = mixColor(skyBottom, PlaceholderPalette.ink900, k);
  final r = (color >> 16) & 0xFF;
  final g = (color >> 8) & 0xFF;
  final b = color & 0xFF;
  final amp = e.height * 0.04;
  for (var x = 0; x < e.width; x++) {
    // Triangle wave ridge, integer-only so it is identical everywhere.
    final phase = (x % period) / period;
    final tri = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
    final top = (e.height * base - amp * tri).round();
    for (var y = top; y < e.height; y++) {
      pm.setPixel(x, y, r, g, b, alpha);
    }
  }
  return pm;
}

Pixmap _chapterThumb(AssetEntry e) {
  final (skyTop, skyBottom, _) = PlaceholderPalette.chapters[e.chapter]!;
  final pm = Pixmap(e.width, e.height)
    ..fillRows((y) => _gradientRow(skyTop, skyBottom, y, e.height));
  // Thick frame hint, like the diorama window.
  const f = 24;
  final frame = withAlpha(PlaceholderPalette.butterLip, 255);
  pm
    ..fillRect(0, 0, e.width, f, frame)
    ..fillRect(0, e.height - f, e.width, e.height, frame)
    ..fillRect(0, 0, f, e.height, frame)
    ..fillRect(e.width - f, 0, e.width, e.height, frame);
  Font5x7.drawCentered(
    pm,
    'CH${e.chapter}',
    180,
    14,
    withAlpha(PlaceholderPalette.cream100, 255),
  );
  Font5x7.drawCentered(
    pm,
    _label,
    330,
    5,
    withAlpha(PlaceholderPalette.cream100, 255),
  );
  return pm;
}

/// 60 fragment rectangles in a 6 x 10 grid; coordinates are normalised
/// (0..1) against the 2048 x 2732 portrait master.
String _fragments(int chapter) {
  final rects = <String>[];
  for (var row = 0; row < 10; row++) {
    for (var col = 0; col < 6; col++) {
      final n = row * 6 + col + 1;
      final id = 'f${n.toString().padLeft(2, '0')}';
      rects.add(
        '{"id":"$id","rect":[${_f(col / 6)},${_f(row / 10)},${_f(1 / 6)},${_f(1 / 10)}]}',
      );
    }
  }
  return '{"chapter":$chapter,"note":"PLACEHOLDER: 60 rects in a 6x10 grid, '
      'normalised x,y,w,h","fragments":[\n${rects.join(',\n')}\n]}\n';
}

String _f(double v) => v.toStringAsFixed(5).replaceFirst(RegExp(r'0+$'), '0');

Pixmap _uiIcon(AssetEntry e) {
  final (sdf, face) = _iconSpec(e.name);
  return paintIcon(sdf, face, e.width);
}

(Sdf, int) _iconSpec(String name) {
  return switch (name) {
    'coin' => (Shapes.disc(), PlaceholderPalette.butter),
    'gem' => (Shapes.diamond(), PlaceholderPalette.sky),
    'heart' => (Shapes.heart(), PlaceholderPalette.berry),
    'heart_broken' => (Shapes.heart(), PlaceholderPalette.ink500),
    'star' => (Shapes.star(), PlaceholderPalette.butter),
    'star_empty' => (Shapes.star(), PlaceholderPalette.cream300),
    'chest' => (Shapes.roundRect(0.85, 0.6, 0.2), PlaceholderPalette.butterLip),
    'key' => (Shapes.ring(0.55, 0.22), PlaceholderPalette.butter),
    'ice' => (Shapes.diamond(0.8), 0xA9DDFF),
    'hint' => (Shapes.disc(0.7), PlaceholderPalette.butter),
    'undo' => (Shapes.ring(), PlaceholderPalette.teal),
    'grid' => (
      Shapes.frame(0.75, 0.75, 0.12, 0.12),
      PlaceholderPalette.cream300,
    ),
    'fit' => (Shapes.frame(0.75, 0.75), PlaceholderPalette.teal),
    'pause' => (Shapes.roundRect(0.45, 0.75, 0.2), PlaceholderPalette.ink500),
    'settings' => (Shapes.hexagon(), PlaceholderPalette.ink500),
    'shop' => (Shapes.roundRect(0.7, 0.75, 0.3), PlaceholderPalette.teal),
    'trophy' => (Shapes.hexagon(0.7), PlaceholderPalette.butter),
    'calendar' => (
      Shapes.roundRect(0.8, 0.7, 0.15),
      PlaceholderPalette.cream300,
    ),
    'flame' => (Shapes.diamond(0.9), PlaceholderPalette.butterLip),
    'share' => (Shapes.ring(0.6, 0.15), PlaceholderPalette.ink500),
    'lock' => (Shapes.roundRect(0.6, 0.55, 0.2), PlaceholderPalette.ink500),
    'bell' => (Shapes.disc(0.65), PlaceholderPalette.butterLip),
    'quests' => (Shapes.roundRect(0.55, 0.8, 0.2), PlaceholderPalette.cream300),
    'back' => (Shapes.roundRect(0.3, 0.7, 0.2), PlaceholderPalette.ink500),
    'collection' => (Shapes.roundRect(0.8, 0.6, 0.15), PlaceholderPalette.teal),
    _ => (Shapes.disc(), PlaceholderPalette.ink500),
  };
}

Pixmap _iceBlock(AssetEntry e) {
  final pm = paintIcon(
    Shapes.roundRect(0.85, 0.85, 0.3),
    PlaceholderPalette.sky,
    e.width,
  );
  for (var i = 3; i < pm.rgba.length; i += 4) {
    pm.rgba[i] = (pm.rgba[i] * 0.7).round();
  }
  return pm;
}

Pixmap _cosmetic(AssetEntry e) => paintIcon(
  Shapes.roundRect(0.9, 0.3, 0.3),
  PlaceholderPalette.skins[e.name]!,
  e.width,
);

// --- text assets ---------------------------------------------------------------

String _shader(String name) {
  final body = name == 'glow'
      ? 'fragColor = vec4(uv.x, uv.y, 0.5 + 0.5 * sin(uTime), 1.0);'
      : 'fragColor = vec4(vec3(uv.y), 1.0);';
  return '// PLACEHOLDER shader ($name): replace with the final effect.\n'
      '#version 460 core\n'
      '#include <flutter/runtime_effect.glsl>\n'
      'uniform vec2 uSize;\n'
      'uniform float uTime;\n'
      'out vec4 fragColor;\n'
      'void main() {\n'
      '  vec2 uv = FlutterFragCoord().xy / uSize;\n'
      '  $body\n'
      '}\n';
}

const String _lottie =
    '{"v":"5.7.0","fr":30,"ip":0,"op":30,"w":200,"h":200,'
    '"nm":"PLACEHOLDER confetti","ddd":0,"assets":[],"layers":[]}\n';

String _licence(String name) => name == 'audio_licences'
    ? '# Audio licences\n\n'
          'Every file under assets/audio/ is a **placeholder** synthesised by '
          '`tool/gen_placeholder_assets.dart` (simple tones, public domain). '
          'Nothing here is final.\n\n'
          'When real audio replaces a placeholder, list it below: '
          'file | source | licence (commercial use + redistribution in a game).\n\n'
          '| File | Source | Licence |\n|---|---|---|\n'
    : '# Art licences\n\n'
          'Every image under assets/images/ is a **placeholder** painted by '
          '`tool/gen_placeholder_assets.dart` (token-coloured gradients and '
          'flat shapes, public domain). Nothing here is final art.\n\n'
          'When real art replaces a placeholder, list it below: '
          'file | creator | licence (work-for-hire / full commercial rights).\n\n'
          '| File | Creator | Licence |\n|---|---|---|\n';
