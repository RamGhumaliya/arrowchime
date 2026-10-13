import 'package:flutter/foundation.dart' show immutable;

/// Which level: stage 1… (endless) and index 1–60 inside it, or a Daily Knot.
/// Players only see the global number ([globalIndex]).
/// Value-equal so it can key Riverpod families.
@immutable
class LevelRef {
  const new(this.chapter, this.index, {this.daily});

  /// The Daily Knot of UTC [dateKey] (`2026-10-10`). It looks like a chapter
  /// chosen by the day of the year, so it gets that chapter's colours and
  /// instrument.
  factory dailyOf(String dateKey) {
    final p = dateKey.split('-');
    final date = DateTime.utc(
      int.parse(p[0]),
      int.parse(p[1]),
      int.parse(p[2]),
    );
    final dayOfYear = date.difference(DateTime.utc(date.year)).inDays + 1;
    return LevelRef(1 + dayOfYear % 5, dayOfYear, daily: dateKey);
  }

  final int chapter;
  final int index;

  /// UTC date key when this is a Daily Knot, else `null`.
  final String? daily;

  bool get isDaily => daily != null;

  /// 1-based position across all chapters (hint pricing, analytics).
  int get globalIndex => isDaily ? 999 : (chapter - 1) * 60 + index;

  /// Route segment of the chapter: `ch1`…
  String get chapterSlug => 'ch$chapter';

  /// Parses route parameters (`ch1`, `7`); `null` when malformed.
  static LevelRef? parse(String? chapter, String? index) {
    final c = int.tryParse((chapter ?? '').replaceFirst('ch', ''));
    final i = int.tryParse(index ?? '');
    if (c == null || i == null || c < 1 || c > 9999 || i < 1 || i > 60) {
      return null;
    }
    return LevelRef(c, i);
  }

  @override
  bool operator ==(Object other) =>
      other is LevelRef &&
      other.chapter == chapter &&
      other.index == index &&
      other.daily == daily;

  @override
  int get hashCode => Object.hash(chapter, index, daily);

  @override
  String toString() =>
      isDaily ? 'LevelRef(daily $daily)' : 'LevelRef(ch$chapter, $index)';
}
