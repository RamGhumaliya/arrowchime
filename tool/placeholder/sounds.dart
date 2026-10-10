import 'package:arrowchime/core/assets.dart';

import 'wav.dart';

/// Synthesised placeholder sounds for every audio path of the manifest.
abstract final class Sounds {
  /// One placeholder note of [instrument].
  static List<double> note(String instrument, String name) {
    final f = Wav.noteFrequency(name);
    final blip = switch (instrument) {
      'kalimba' => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        harmonics: const [1, 0, 0, 0.25],
        decay: 5,
      ),
      'musicbox' => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        wave: Wave.triangle,
        harmonics: const [1, 0.3, 0.1],
        decay: 3.5,
      ),
      'santoor' => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        wave: Wave.saw,
        harmonics: const [1, 0.4, 0.2],
        amp: 0.35,
      ),
      'celesta' => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        harmonics: const [1, 0, 0.2, 0, 0.1],
        decay: 3,
      ),
      'harp' => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        wave: Wave.triangle,
        harmonics: const [1, 0.4, 0.2],
        decay: 2.5,
      ),
      'marimba' => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        harmonics: const [1, 0, 0, 0.5],
        decay: 7,
      ),
      'pixel' => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        wave: Wave.square,
        amp: 0.3,
        decay: 2,
      ),
      'choir' => Blip(
        start: 0,
        dur: 0.8,
        freq: f,
        harmonics: const [1, 0.3, 0.1],
        attack: 0.12,
        decay: 1.2,
      ),
      _ => Blip(
        start: 0,
        dur: 0.7,
        freq: f,
        harmonics: const [1, 0.5, 0.25, 0.1],
        decay: 3,
      ),
    };
    return render([blip], blip.dur);
  }

  /// A short placeholder loop in the chapter's key.
  static List<double> musicLoop(int chapter) {
    final inst = AudioCatalog.chapterInstrument[chapter]!;
    final notes = AudioCatalog.instrumentNotes[inst]!;
    const pattern = [0, 2, 4, 2, 1, 3, 4, 2, 0, 2, 4, 3];
    final blips = <Blip>[
      for (var i = 0; i < pattern.length; i++)
        Blip(
          start: i * 0.5,
          dur: 1.2,
          freq: Wav.noteFrequency(notes[pattern[i]]),
          wave: Wave.triangle,
          amp: 0.3,
          decay: 1.5,
        ),
      Blip(
        start: 0,
        dur: 6,
        freq: Wav.noteFrequency(notes[0]) / 2,
        amp: 0.12,
        decay: 0.05,
        attack: 0.5,
      ),
    ];
    return render(blips, 6);
  }

  /// A placeholder boss sting: a rising run into a held chord.
  static List<double> bossSting(int chapter) {
    final inst = AudioCatalog.chapterInstrument[chapter]!;
    final notes = AudioCatalog.instrumentNotes[inst]!;
    final blips = <Blip>[
      for (var i = 0; i < 7; i++)
        Blip(
          start: i * 0.35,
          dur: 0.9,
          freq: Wav.noteFrequency(notes[i]),
          wave: Wave.triangle,
          amp: 0.35,
          decay: 3,
        ),
      for (final k in const [0, 2, 4])
        Blip(
          start: 2.6,
          dur: 5.2,
          freq: Wav.noteFrequency(notes[k + 5 > notes.length - 1 ? k : k + 5]),
          amp: 0.25,
          decay: 0.7,
          attack: 0.02,
        ),
    ];
    return render(blips, 8);
  }

  /// A placeholder SFX with the character described in `docs/07` §2.
  static List<double> sfx(String id) {
    Blip b(
      double start,
      double dur,
      double f, {
      double? f2,
      Wave wave = Wave.sine,
      double amp = 0.5,
      double decay = 6,
      List<double> h = const [1],
    }) => Blip(
      start: start,
      dur: dur,
      freq: f,
      freqEnd: f2,
      wave: wave,
      amp: amp,
      decay: decay,
      harmonics: h,
    );

    double n(String name) => Wav.noteFrequency(name);

    final (blips, seconds) = switch (id) {
      'ui_tap' => ([b(0, 0.06, 1200, decay: 40, wave: Wave.triangle)], 0.08),
      'ui_back' => ([b(0, 0.07, 700, decay: 35, wave: Wave.triangle)], 0.09),
      'arrow_touch' => ([b(0, 0.03, 2200, amp: 0.2, decay: 80)], 0.04),
      'arrow_whoosh' => (
        [b(0, 0.25, 0, wave: Wave.noise, amp: 0.25, decay: 8)],
        0.26,
      ),
      'arrow_blocked' => (
        [
          b(0, 0.18, 120, f2: 70, amp: 0.7, decay: 14),
          b(0, 0.1, 0, wave: Wave.noise, amp: 0.15, decay: 30),
        ],
        0.2,
      ),
      'heart_lost' => (
        [
          b(0, 0.3, 1500, f2: 900, amp: 0.3, decay: 9, h: const [1, 0.6]),
          b(0.02, 0.28, 1930, f2: 1100, amp: 0.25, decay: 10),
        ],
        0.32,
      ),
      'rotator_turn' => (
        [
          b(0, 0.04, 900, wave: Wave.square, amp: 0.3, decay: 50),
          b(0.07, 0.04, 700, wave: Wave.square, amp: 0.3, decay: 50),
        ],
        0.13,
      ),
      'gate_open' => (
        [
          b(0, 0.25, 180, f2: 260, wave: Wave.saw, amp: 0.3, decay: 4),
          b(0.15, 0.4, n('E5'), decay: 5),
          b(0.15, 0.4, n('B5'), decay: 5, amp: 0.3),
        ],
        0.6,
      ),
      'key_collect' => (
        [
          for (var i = 0; i < 3; i++)
            b(i * 0.08, 0.3, n(const ['G5', 'C6', 'E6'][i]), decay: 7),
        ],
        0.4,
      ),
      'ice_tick' => (
        [b(0, 0.06, 0, wave: Wave.noise, amp: 0.3, decay: 60)],
        0.07,
      ),
      'ice_break' => (
        [
          b(0, 0.4, 0, wave: Wave.noise, amp: 0.35, decay: 9),
          b(0, 0.25, 2600, f2: 800, amp: 0.2, decay: 12),
        ],
        0.42,
      ),
      'portal_pass' => (
        [
          b(0, 0.35, 300, f2: 1200, amp: 0.35, decay: 4, wave: Wave.triangle),
          b(0.2, 0.3, 1200, f2: 400, amp: 0.25, wave: Wave.triangle),
        ],
        0.5,
      ),
      'flow_up' => (
        [
          for (var i = 0; i < 4; i++)
            b(i * 0.07, 0.25, n(const ['C5', 'E5', 'G5', 'C6'][i]), decay: 8),
        ],
        0.4,
      ),
      'board_clear' => (
        [
          for (final x in const ['C5', 'E5', 'G5', 'C6'])
            b(0, 1, n(x), amp: 0.25, decay: 3, wave: Wave.triangle),
        ],
        1.05,
      ),
      'star_1' => ([b(0, 0.4, n('C6'), decay: 7)], 0.42),
      'star_2' => ([b(0, 0.4, n('E6'), decay: 7)], 0.42),
      'star_3' => ([b(0, 0.5, n('G6'))], 0.52),
      'coin' => (
        [
          b(0, 0.12, n('B6'), decay: 25, wave: Wave.triangle),
          b(0.05, 0.2, n('E7'), decay: 18, wave: Wave.triangle),
        ],
        0.26,
      ),
      'level_fail' => (
        [
          for (var i = 0; i < 3; i++)
            b(
              i * 0.18,
              0.6,
              n(const ['E4', 'C4', 'A3'][i]),
              amp: 0.35,
              decay: 3,
              wave: Wave.triangle,
            ),
        ],
        0.9,
      ),
      'fragment_restore' => (
        [
          for (var i = 0; i < 8; i++)
            b(
              i * 0.06,
              0.35,
              n(const ['C6', 'E6', 'G6', 'A6', 'C6', 'G6', 'E6', 'C6'][i]) *
                  1.5,
              amp: 0.18,
              decay: 9,
            ),
        ],
        0.9,
      ),
      'chest_open' => (
        [
          b(0, 0.35, 90, f2: 160, wave: Wave.saw, amp: 0.25, decay: 3),
          for (var i = 0; i < 4; i++)
            b(
              0.3 + i * 0.07,
              0.3,
              n(const ['C6', 'E6', 'G6', 'C7'][i]),
              decay: 8,
            ),
        ],
        0.8,
      ),
      'daily_complete' => (
        [
          for (var i = 0; i < 5; i++)
            b(
              i * 0.12,
              0.45,
              n(const ['C5', 'E5', 'G5', 'E5', 'C6'][i]),
              amp: 0.35,
              decay: 4,
              wave: Wave.triangle,
            ),
        ],
        1.1,
      ),
      'purchase' => (
        [
          for (var i = 0; i < 5; i++)
            b(
              i * 0.06,
              0.3,
              n(const ['G5', 'B5', 'D6', 'G6', 'B6'][i]),
              decay: 8,
            ),
        ],
        0.65,
      ),
      _ => throw ArgumentError.value(id, 'id', 'unknown sfx'),
    };
    return render(blips, seconds, seed: id.length * 7 + 1);
  }
}
