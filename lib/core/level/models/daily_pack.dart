// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:arrowchime/core/level/models/level.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_pack.freezed.dart';

/// Pre-baked Daily Knot levels of one year: `daily_{yyyy}.json`
/// (`docs/04` §1, §6).
///
/// ```text
/// { "schema": 1, "year": 2027, "levels": { "2027-01-01": { level }, ... } }
/// ```
///
/// A file may cover only part of a year (e.g. the first pack starts on the
/// day the game ships).
@Freezed(makeCollectionsUnmodifiable: false, fromJson: false, toJson: false)
abstract class DailyPack with _$DailyPack {
  const factory DailyPack({
    required int year,

    /// `yyyy-mm-dd` (UTC date) → level, in ascending date order.
    required Map<String, Level> levels,
  }) = _DailyPack;

  factory DailyPack.fromJson(Map<String, Object?> json) {
    final schema = json['schema'];
    if (schema != 1) {
      throw LevelFormatException('daily pack.schema must be 1, got $schema');
    }
    final year = json['year'];
    if (year is! int) {
      throw const LevelFormatException('daily pack.year must be an integer');
    }
    final raw = json['levels'];
    if (raw is! Map<String, Object?>) {
      throw const LevelFormatException('daily pack.levels must be an object');
    }
    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    final levels = <String, Level>{};
    for (final e in raw.entries) {
      if (!datePattern.hasMatch(e.key) || !e.key.startsWith('$year-')) {
        throw LevelFormatException(
          'daily pack key "${e.key}" must be a $year-mm-dd date',
        );
      }
      final value = e.value;
      if (value is! Map<String, Object?>) {
        throw LevelFormatException(
          'daily pack.levels["${e.key}"] must be an object',
        );
      }
      levels[e.key] = Level.fromJson(value);
    }
    return DailyPack(year: year, levels: levels);
  }

  const DailyPack._();

  Map<String, Object?> toJson() => {
    'schema': 1,
    'year': year,
    'levels': {for (final e in levels.entries) e.key: e.value.toJson()},
  };
}
