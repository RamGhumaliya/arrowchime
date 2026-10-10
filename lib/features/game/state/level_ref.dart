import 'package:flutter/foundation.dart' show immutable;

/// Which level: chapter 1–5 and index 1–60 inside it. Value-equal so it can
/// key Riverpod families.
@immutable
class LevelRef {
  const new(this.chapter, this.index);

  final int chapter;
  final int index;

  /// 1-based position across all chapters (hint pricing, analytics).
  int get globalIndex => (chapter - 1) * 60 + index;

  /// Route segment of the chapter: `ch1`…
  String get chapterSlug => 'ch$chapter';

  /// Parses route parameters (`ch1`, `7`); `null` when malformed.
  static LevelRef? parse(String? chapter, String? index) {
    final c = int.tryParse((chapter ?? '').replaceFirst('ch', ''));
    final i = int.tryParse(index ?? '');
    if (c == null || i == null || c < 1 || c > 5 || i < 1 || i > 60) {
      return null;
    }
    return LevelRef(c, i);
  }

  @override
  bool operator ==(Object other) =>
      other is LevelRef && other.chapter == chapter && other.index == index;

  @override
  int get hashCode => Object.hash(chapter, index);

  @override
  String toString() => 'LevelRef(ch$chapter, $index)';
}
