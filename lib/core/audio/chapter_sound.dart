import 'dart:math' as math;

import 'package:arrowchime/core/assets.dart';

/// A sample and the speed to play it at.
class NoteVoice {
  const new(this.asset, this.speed);

  final String asset;
  final double speed;
}

/// Instrument and scale of one chapter (`docs/07` §1 "Scales per chapter").
///
/// [notes] lists the playable notes from low to high, named like the sample
/// files (`C4`, `Fs5`: `s` = sharp). A melody is a list of indices into it.
class ChapterSound {
  const new({
    required this.chapter,
    required this.instrument,
    required this.notes,
    required this.tonics,
    required this.fifthSteps,
    required this.thirdSteps,
    required this.pentatonic,
  });

  final int chapter;

  /// Folder under `assets/audio/notes/`.
  final String instrument;
  final List<String> notes;

  /// Indices of the tonic (home note) in [notes]: where a phrase may rest.
  final List<int> tonics;

  /// How many [notes] steps a fifth / a third above is in this scale.
  final int fifthSteps;
  final int thirdSteps;

  /// Pentatonic scales sound pleasant on any order; the others favour chord
  /// tones on strong beats.
  final bool pentatonic;

  int get length => notes.length;

  /// Asset path of the sample for note index [i].
  String assetOf(int i) => AssetCatalog.notePath(instrument, notes[i]);

  /// The note [i] played by the cosmetic [instrument] (`piano`, `marimba`,
  /// `eightbit`, `choir`; `null` / `auto` = this chapter's own instrument).
  ///
  /// The cosmetic instruments only have a C-major-pentatonic sample set, so a
  /// note of another scale plays the nearest sample, transposed by the
  /// playback speed.
  NoteVoice voiceOf(int i, {String? instrument}) {
    final folder = _folder(instrument);
    if (folder == null) return NoteVoice(assetOf(i), 1);
    final available = AudioCatalog.instrumentNotes[folder]!;
    final target = _semitone(notes[i]);
    var best = available.first;
    for (final n in available) {
      if ((_semitone(n) - target).abs() < (_semitone(best) - target).abs()) {
        best = n;
      }
    }
    return NoteVoice(
      AssetCatalog.notePath(folder, best),
      math.pow(2, (target - _semitone(best)) / 12).toDouble(),
    );
  }

  /// Every sample [voiceOf] may use with [instrument] (for preloading).
  Set<String> voiceAssets({String? instrument}) => {
    for (var i = 0; i < notes.length; i++)
      voiceOf(i, instrument: instrument).asset,
  };

  static String? _folder(String? instrument) => switch (instrument) {
    null || 'auto' || '' => null,
    'eightbit' => 'pixel',
    final other =>
      AudioCatalog.instrumentNotes.containsKey(other) ? other : null,
  };

  /// Semitones above C0 of a note name like `C4` or `Fs5` (`s` = sharp).
  static int _semitone(String name) {
    const base = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11};
    var i = 1;
    var s = base[name[0]]!;
    if (name[i] == 's') {
      s++;
      i++;
    }
    return 12 * int.parse(name.substring(i)) + s;
  }

  /// Every sample of this chapter (for preloading).
  List<String> get assets => [
    for (var i = 0; i < notes.length; i++) assetOf(i),
  ];

  /// Whether [i] is a chord tone (root, third or fifth) of the home chord.
  bool isChordTone(int i) {
    if (pentatonic) return true;
    final tonic = tonics.first;
    final degree = (i - tonic) % 7;
    return degree == 0 || degree == 2 || degree == 4;
  }

  static const List<ChapterSound> all = [
    // Misty Garden: kalimba, C major pentatonic, C4-C6.
    ChapterSound(
      chapter: 1,
      instrument: 'kalimba',
      notes: [
        'C4', 'D4', 'E4', 'G4', 'A4', //
        'C5', 'D5', 'E5', 'G5', 'A5', 'C6',
      ],
      tonics: [0, 5, 10],
      fifthSteps: 3,
      thirdSteps: 2,
      pentatonic: true,
    ),
    // Clockwork Town: music box, G major, G4-G6.
    ChapterSound(
      chapter: 2,
      instrument: 'musicbox',
      notes: [
        'G4', 'A4', 'B4', 'C5', 'D5', 'E5', 'Fs5', //
        'G5', 'A5', 'B5', 'C6', 'D6', 'E6', 'Fs6', 'G6',
      ],
      tonics: [0, 7, 14],
      fifthSteps: 4,
      thirdSteps: 2,
      pentatonic: false,
    ),
    // Lantern Bazaar: santoor, D dorian, D4-D6.
    ChapterSound(
      chapter: 3,
      instrument: 'santoor',
      notes: [
        'D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5', //
        'D5', 'E5', 'F5', 'G5', 'A5', 'B5', 'C6', 'D6',
      ],
      tonics: [0, 7, 14],
      fifthSteps: 4,
      thirdSteps: 2,
      pentatonic: false,
    ),
    // Frost Peaks: celesta, A minor pentatonic, A4-A6.
    ChapterSound(
      chapter: 4,
      instrument: 'celesta',
      notes: [
        'A4', 'C5', 'D5', 'E5', 'G5', //
        'A5', 'C6', 'D6', 'E6', 'G6', 'A6',
      ],
      tonics: [0, 5, 10],
      fifthSteps: 3,
      thirdSteps: 1,
      pentatonic: true,
    ),
    // Starlight Observatory: harp, E lydian, E4-E6.
    ChapterSound(
      chapter: 5,
      instrument: 'harp',
      notes: [
        'E4', 'Fs4', 'Gs4', 'As4', 'B4', 'Cs5', 'Ds5', //
        'E5', 'Fs5', 'Gs5', 'As5', 'B5', 'Cs6', 'Ds6', 'E6',
      ],
      tonics: [0, 7, 14],
      fifthSteps: 4,
      thirdSteps: 2,
      pentatonic: false,
    ),
  ];

  /// The sound of chapter [chapter] (1-5).
  static ChapterSound of(int chapter) => all[(chapter - 1).clamp(0, 4)];
}
