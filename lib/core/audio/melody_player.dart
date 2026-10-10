import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/audio/melodies.dart';

/// One note to sound for a freed arrow (`docs/07` §1).
class NoteCue {
  const new({
    required this.index,
    required this.harmony,
    required this.sparkle,
    required this.heavy,
  });

  /// Index into `ChapterSound.notes`.
  final int index;

  /// Extra indices sounded under it (fifth at ×2, third at ×4).
  final List<int> harmony;

  /// ×5: every note gets a sparkle layer.
  final bool sparkle;

  /// Long arrows (more than 8 cells) ring heavier.
  final bool heavy;
}

/// Plays a level's melody one note per freed arrow, in order. Which arrow is
/// tapped first does not matter: the tune always comes out right.
class MelodyPlayer {
  new(this.sound, this.melody)
    : assert(melody.length >= 16, 'a melody has at least 16 notes');

  /// The melody of level `levelIndex` in `chapter` (rotated: 12 per chapter).
  factory forLevel(int chapter, int levelIndex) {
    final sound = ChapterSound.of(chapter);
    final all = chapterMelodies[chapter]!;
    return MelodyPlayer(sound, all[(levelIndex - 1) % all.length]);
  }

  final ChapterSound sound;
  final List<int> melody;

  /// Arrows longer than this play the heavier version of their note.
  static const int longArrowCells = 8;

  int _position = 0;

  /// How many notes were played since the start.
  int get position => _position;

  /// Starts the tune over (retry, undo handled by [rewind]).
  void reset() => _position = 0;

  /// Takes one note back (an undone arrow).
  void rewind() {
    if (_position > 0) _position--;
  }

  /// The next note, with the harmony of Flow multiplier [flow] (1 = none).
  NoteCue next({int flow = 1, int arrowLength = 1}) {
    final i = melody[_position % melody.length];
    _position++;
    return NoteCue(
      index: i,
      harmony: harmonyOf(i, flow),
      sparkle: flow >= 5,
      heavy: arrowLength > longArrowCells,
    );
  }

  /// Notes stacked on [i]: a fifth above from ×2, a third as well from ×4.
  List<int> harmonyOf(int i, int flow) {
    final out = <int>[];
    final top = sound.length - 1;
    if (flow >= 2 && i + sound.fifthSteps <= top) out.add(i + sound.fifthSteps);
    if (flow >= 4 && i + sound.thirdSteps <= top) out.add(i + sound.thirdSteps);
    return out;
  }

  /// The notes left until the melody's end, consumed: the board-clear
  /// cascade plays them 90 ms apart.
  List<int> cascade() {
    final remaining = melody.length - (_position % melody.length);
    final out = <int>[
      for (var k = 0; k < remaining; k++)
        melody[(_position + k) % melody.length],
    ];
    _position += remaining;
    return out;
  }

  /// The flourish: a run up the scale from the low tonic to the next one, so
  /// the clear resolves home.
  List<int> flourish() => [
    for (var i = sound.tonics.first; i <= sound.tonics[1]; i++) i,
  ];
}
