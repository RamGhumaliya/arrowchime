/// Colours the placeholder tool paints with. Plain `0xRRGGBB` ints because
/// `dart run` cannot import `package:flutter`.
///
/// They mirror `lib/app/theme/tokens.dart` and `chapter_theme.dart`;
/// `test/tool/placeholder_palette_test.dart` fails if they drift.
abstract final class PlaceholderPalette {
  static const int ink900 = 0x121A2B;
  static const int ink700 = 0x1E2A44;
  static const int ink500 = 0x3A4A6B;
  static const int cream100 = 0xFFF6E6;
  static const int cream300 = 0xF3DFC1;
  static const int teal = 0x19B3A3;
  static const int berry = 0xE5446D;
  static const int butter = 0xFFD15C;
  static const int butterLip = 0xC9952A;
  static const int sky = 0x6EC6FF;

  /// Chapter 1–5: `skyTop`, `skyBottom`, `trayFelt`.
  static const Map<int, (int, int, int)> chapters = {
    1: (0xFFCBA4, 0xB7C9A8, 0xE9E2D0),
    2: (0x2F8F94, 0xF2E4C9, 0xE6D6BC),
    3: (0x2B2A63, 0x8E2F6B, 0x2B2547),
    4: (0x9CC9F0, 0x8E7CC3, 0xDCE7F2),
    5: (0x14204A, 0x145E6B, 0x1C2440),
  };

  /// Cosmetic skin → preview tube colour.
  static const Map<String, int> skins = {
    'candy': 0xE5446D,
    'bamboo': 0x8FB996,
    'brass': 0xC9952A,
    'silk': 0xF2708C,
    'crystal': 0x6EC6FF,
    'galaxy': 0x8E5A9B,
    'neon': 0x30C9C0,
    'paper': 0xF3DFC1,
    'pixel': 0x5BB5E8,
  };
}
