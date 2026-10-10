import 'dart:io';
import 'dart:typed_data';

/// A tiny RGBA canvas that encodes itself as a PNG. Used only by
/// `tool/gen_placeholder_assets.dart` to paint obvious placeholders; never
/// shipped in the app.
class Pixmap {
  new(this.width, this.height) : rgba = Uint8List(width * height * 4);

  final int width;
  final int height;

  /// Straight (non-premultiplied) RGBA, row-major.
  final Uint8List rgba;

  void setPixel(int x, int y, int r, int g, int b, [int a = 255]) {
    final i = (y * width + x) * 4;
    rgba[i] = r;
    rgba[i + 1] = g;
    rgba[i + 2] = b;
    rgba[i + 3] = a;
  }

  /// Composites a colour over the existing pixel (alpha `0..255`).
  void blend(int x, int y, int r, int g, int b, int a) {
    if (x < 0 || y < 0 || x >= width || y >= height || a <= 0) return;
    final i = (y * width + x) * 4;
    final da = rgba[i + 3];
    if (a >= 255 || da == 0) {
      setPixel(x, y, r, g, b, a >= 255 ? 255 : a);
      return;
    }
    final sa = a / 255;
    final dstA = da / 255;
    final outA = sa + dstA * (1 - sa);
    for (var c = 0; c < 3; c++) {
      final s = c == 0 ? r : (c == 1 ? g : b);
      final d = rgba[i + c];
      rgba[i + c] = ((s * sa + d * dstA * (1 - sa)) / outA).round();
    }
    rgba[i + 3] = (outA * 255).round();
  }

  /// Fills the whole canvas, row by row, with `rowColor(y)` → `0xAARRGGBB`.
  void fillRows(int Function(int y) rowColor) {
    for (var y = 0; y < height; y++) {
      final c = rowColor(y);
      final a = (c >> 24) & 0xFF;
      final r = (c >> 16) & 0xFF;
      final g = (c >> 8) & 0xFF;
      final b = c & 0xFF;
      final base = y * width * 4;
      for (var x = 0; x < width; x++) {
        final i = base + x * 4;
        rgba[i] = r;
        rgba[i + 1] = g;
        rgba[i + 2] = b;
        rgba[i + 3] = a;
      }
    }
  }

  /// Fills an axis-aligned rectangle (alpha-composited).
  void fillRect(int x0, int y0, int x1, int y1, int argb) {
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        blend(x, y, r, g, b, a);
      }
    }
  }

  /// Encodes as an 8-bit RGBA PNG (filter type 2 "Up" compresses the
  /// vertical gradients of the chapter layers to a few kilobytes).
  Uint8List toPng() {
    final stride = width * 4;
    final raw = Uint8List(height * (stride + 1));
    for (var y = 0; y < height; y++) {
      final o = y * (stride + 1);
      raw[o] = 2;
      for (var i = 0; i < stride; i++) {
        final cur = rgba[y * stride + i];
        final up = y == 0 ? 0 : rgba[(y - 1) * stride + i];
        raw[o + 1 + i] = (cur - up) & 0xFF;
      }
    }
    final idat = ZLibEncoder(level: 9).convert(raw);
    final out = BytesBuilder(copy: false)
      ..add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
      ..add(_chunk('IHDR', _ihdr()))
      ..add(_chunk('IDAT', idat))
      ..add(_chunk('IEND', const []));
    return out.toBytes();
  }

  List<int> _ihdr() {
    final d = ByteData(13)
      ..setUint32(0, width)
      ..setUint32(4, height)
      ..setUint8(8, 8) // bit depth
      ..setUint8(9, 6) // RGBA
      ..setUint8(10, 0)
      ..setUint8(11, 0)
      ..setUint8(12, 0);
    return d.buffer.asUint8List();
  }

  static List<int> _chunk(String type, List<int> data) {
    final typeBytes = type.codeUnits;
    final b = BytesBuilder()
      ..add((ByteData(4)..setUint32(0, data.length)).buffer.asUint8List())
      ..add(typeBytes)
      ..add(data);
    final crc = _crc32([...typeBytes, ...data]);
    b.add((ByteData(4)..setUint32(0, crc)).buffer.asUint8List());
    return b.toBytes();
  }

  static final List<int> _crcTable = () {
    final t = List<int>.filled(256, 0);
    for (var n = 0; n < 256; n++) {
      var c = n;
      for (var k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
      }
      t[n] = c;
    }
    return t;
  }();

  static int _crc32(List<int> bytes) {
    var c = 0xFFFFFFFF;
    for (final b in bytes) {
      c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
    }
    return c ^ 0xFFFFFFFF;
  }
}

/// `0xAARRGGBB` helpers.
int argb(int r, int g, int b, [int a = 255]) =>
    (a << 24) | (r << 16) | (g << 8) | b;

int withAlpha(int color, int a) => (a << 24) | (color & 0xFFFFFF);

/// Linear mix of two `0xRRGGBB` colours (alpha ignored), `t` in 0..1.
int mixColor(int a, int b, double t) {
  int ch(int shift) {
    final x = (a >> shift) & 0xFF;
    final y = (b >> shift) & 0xFF;
    return (x + (y - x) * t).round().clamp(0, 255);
  }

  return (ch(16) << 16) | (ch(8) << 8) | ch(0);
}
