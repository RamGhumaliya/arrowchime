import 'package:flutter/painting.dart';

/// Palette for one chapter world (`docs/06_ART_DIRECTION.md` §4).
///
/// Sky/background gradients and arrow colours are derived from the colour
/// names in the art-direction table; swap hex values here when the artist
/// delivers the final palette. UI chrome stays on `TBColors` in every chapter.
class ChapterTheme {
  const new({
    required this.id,
    required this.name,
    required this.diorama,
    required this.skyTop,
    required this.skyBottom,
    required this.trayFelt,
    required this.arrowColors,
    this.darkTray = false,
    this.flat = false,
    this.ink = const Color(0xFF1B2A41),
    this.accent = const Color(0xFF14B8A6),
  });

  final int id;
  final String name;
  final String diorama;

  /// Background gradient, top to bottom.
  final Color skyTop;
  final Color skyBottom;

  /// Board tray felt colour.
  final Color trayFelt;

  /// The six arrow colours of this chapter.
  final List<Color> arrowColors;

  /// Dark tray ⇒ light arrows (chapters 3 and 5).
  final bool darkTray;

  /// V2 "Clean Line": no tray or scene, one flat background and ink arrows.
  final bool flat;

  /// Arrow line colour on a [flat] board.
  final Color ink;

  /// Highlight colour (taps, hints, progress) on a [flat] board.
  final Color accent;

  /// A copy with another tray (board-theme cosmetics).
  ChapterTheme copyWith({Color? trayFelt, bool? darkTray}) => ChapterTheme(
    id: id,
    name: name,
    diorama: diorama,
    skyTop: skyTop,
    skyBottom: skyBottom,
    trayFelt: trayFelt ?? this.trayFelt,
    arrowColors: arrowColors,
    darkTray: darkTray ?? this.darkTray,
    flat: flat,
    ink: ink,
    accent: accent,
  );

  /// The V2 game board in light mode: white page, navy ink, teal accent.
  /// [skyTop] is the page colour; [arrowColors] is the confetti palette.
  static const ChapterTheme cleanLight = ChapterTheme(
    id: 1,
    name: 'Clean Light',
    diorama: '',
    skyTop: Color(0xFFFFFFFF),
    skyBottom: Color(0xFFFFFFFF),
    trayFelt: Color(0xFFFFFFFF),
    flat: true,
    arrowColors: [
      Color(0xFF14B8A6),
      Color(0xFFFFC94D),
      Color(0xFFFF4D5E),
      Color(0xFF6EC6FF),
      Color(0xFF2F7DF6),
    ],
  );

  /// The V2 game board in dark mode: charcoal page, near-white ink.
  static const ChapterTheme cleanDark = ChapterTheme(
    id: 1,
    name: 'Clean Dark',
    diorama: '',
    skyTop: Color(0xFF10151C),
    skyBottom: Color(0xFF10151C),
    trayFelt: Color(0xFF10151C),
    darkTray: true,
    flat: true,
    ink: Color(0xFFE8EEF6),
    arrowColors: [
      Color(0xFF14B8A6),
      Color(0xFFFFC94D),
      Color(0xFFFF4D5E),
      Color(0xFF6EC6FF),
      Color(0xFF2F7DF6),
    ],
  );

  static const ChapterTheme mistyGarden = ChapterTheme(
    id: 1,
    name: 'Misty Garden',
    diorama: 'Zen garden, koi pond, stone bridge, cherry tree',
    skyTop: Color(0xFFFFCBA4), // dawn peach
    skyBottom: Color(0xFFB7C9A8), // soft sage
    trayFelt: Color(0xFFE9E2D0),
    arrowColors: [
      Color(0xFFFF6F61), // coral
      Color(0xFF8FB996), // sage
      Color(0xFF5BB5E8), // sky
      Color(0xFFF2C14E), // butter
      Color(0xFF8E5A9B), // plum
      Color(0xFF1FA89A), // teal
    ],
  );

  static const ChapterTheme clockworkTown = ChapterTheme(
    id: 2,
    name: 'Clockwork Town',
    diorama: 'Brass rooftops, gears, clocktower',
    skyTop: Color(0xFF2F8F94), // teal dusk
    skyBottom: Color(0xFFF2E4C9), // cream
    trayFelt: Color(0xFFE6D6BC),
    arrowColors: [
      Color(0xFFB8860B), // brass
      Color(0xFF1E9C94), // teal
      Color(0xFFA6482F), // brick
      Color(0xFFF4EBD6), // cream
      Color(0xFF22324F), // navy
      Color(0xFF7FD1B0), // mint
    ],
  );

  static const ChapterTheme lanternBazaar = ChapterTheme(
    id: 3,
    name: 'Lantern Bazaar',
    diorama: 'Night market, paper lanterns, rangoli, marigold garlands',
    skyTop: Color(0xFF2B2A63), // indigo
    skyBottom: Color(0xFF8E2F6B), // magenta glow
    trayFelt: Color(0xFF2B2547),
    darkTray: true,
    arrowColors: [
      Color(0xFFFF9933), // saffron
      Color(0xFFFFB81C), // marigold
      Color(0xFFF2708C), // rose
      Color(0xFF30C9C0), // turquoise
      Color(0xFFFFF8E7), // ivory
      Color(0xFFA8D83F), // lime
    ],
  );

  static const ChapterTheme frostPeaks = ChapterTheme(
    id: 4,
    name: 'Frost Peaks',
    diorama: 'Snowy peaks, aurora, cabin with warm window',
    skyTop: Color(0xFF9CC9F0), // ice blue
    skyBottom: Color(0xFF8E7CC3), // violet aurora
    trayFelt: Color(0xFFDCE7F2),
    arrowColors: [
      Color(0xFF7CC4F2), // ice blue
      Color(0xFFB83A5C), // berry
      Color(0xFFE0A526), // gold
      Color(0xFF2F6F55), // pine
      Color(0xFFB39DDB), // lilac
      Color(0xFF5E6F82), // slate
    ],
  );

  static const ChapterTheme starlightObservatory = ChapterTheme(
    id: 5,
    name: 'Starlight Observatory',
    diorama: 'Domed observatory, brass telescope, nebula',
    skyTop: Color(0xFF14204A), // navy
    skyBottom: Color(0xFF145E6B), // deep teal nebula
    trayFelt: Color(0xFF1C2440),
    darkTray: true,
    arrowColors: [
      Color(0xFF33D1E8), // cyan
      Color(0xFFE040A0), // magenta
      Color(0xFFFFC83D), // gold
      Color(0xFFEFE8DC), // white-pearl
      Color(0xFFFF7A66), // coral
      Color(0xFFB4E33D), // lime
    ],
  );

  static const List<ChapterTheme> all = [
    mistyGarden,
    clockworkTown,
    lanternBazaar,
    frostPeaks,
    starlightObservatory,
  ];

  /// 1-based chapter lookup; falls back to chapter 1.
  static ChapterTheme byId(int id) =>
      all.firstWhere((c) => c.id == id, orElse: () => mistyGarden);
}
