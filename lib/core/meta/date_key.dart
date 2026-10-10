/// Calendar dates as `yyyy-MM-dd` keys. Streaks and quests use the player's
/// **local** date; the Daily Knot uses the **UTC** date (`docs/03` §7).
abstract final class DateKey {
  /// Key of the calendar day [t] falls on in its own time zone (local time
  /// for `DateTime.now()`, UTC for a UTC value).
  static String of(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${_two(t.month)}-${_two(t.day)}';

  /// Key of the UTC day of [t].
  static String utc(DateTime t) => of(t.toUtc());

  /// The day a key names, as a UTC midnight (day arithmetic is then free of
  /// daylight-saving jumps).
  static DateTime parse(String key) {
    final p = key.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  /// Whole days from [from] to [to] (negative if [to] is earlier).
  static int daysBetween(String from, String to) =>
      parse(to).difference(parse(from)).inDays;

  /// The key [days] after [key].
  static String addDays(String key, int days) =>
      of(parse(key).add(Duration(days: days)));

  /// ISO-8601 week of [key], e.g. `2026-W41` (weeks start on Monday).
  static String isoWeek(String key) {
    final d = parse(key);
    // The Thursday of this week decides the ISO year.
    final thursday = d.add(Duration(days: DateTime.thursday - d.weekday));
    final yearStart = DateTime.utc(thursday.year);
    final week = (thursday.difference(yearStart).inDays ~/ 7) + 1;
    return '${thursday.year}-W${_two(week)}';
  }

  /// Day-of-year number (1-366) of [key], the Daily Knot's "#142".
  static int dayOfYear(String key) {
    final d = parse(key);
    return d.difference(DateTime.utc(d.year)).inDays + 1;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
