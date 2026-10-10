import 'dart:convert';

import 'package:arrowchime/core/level/level_validator.dart';
import 'package:arrowchime/core/level/models/daily_pack.dart';
import 'package:arrowchime/core/level/models/level.dart';

/// Parses and serialises level packs (`assets/levels/ch{N}.json`,
/// `daily_{yyyy}.json`, `sample_levels.json`).
///
/// Pure Dart: callers supply the JSON text (from `rootBundle` in the app, from
/// `File` in the CLI tools).
abstract final class PackLoader {
  /// Parses a pack. With [validate] (default) every level must also pass
  /// `validateLevel`; otherwise a [LevelFormatException] lists all problems.
  static LevelPack parsePack(String jsonText, {bool validate = true}) {
    final decoded = _decode(jsonText, 'pack');
    final pack = LevelPack.fromJson(decoded);
    if (validate) {
      final problems = [
        for (final level in pack.levels)
          for (final issue in validateLevel(level)) '${level.id}: $issue',
      ];
      if (problems.isNotEmpty) {
        throw LevelFormatException(problems.join('\n'));
      }
    }
    return pack;
  }

  /// Parses a single level object from JSON text.
  static Level parseLevel(String jsonText, {bool validate = true}) {
    final level = Level.fromJson(_decode(jsonText, 'level'));
    if (validate) {
      final issues = validateLevel(level);
      if (issues.isNotEmpty) {
        throw LevelFormatException(issues.join('\n'));
      }
    }
    return level;
  }

  /// Parses a `daily_{yyyy}.json` pack; with [validate] every level must also
  /// pass `validateLevel`.
  static DailyPack parseDailyPack(String jsonText, {bool validate = true}) {
    final pack = DailyPack.fromJson(_decode(jsonText, 'daily pack'));
    if (validate) {
      final problems = [
        for (final e in pack.levels.entries)
          for (final issue in validateLevel(e.value)) '${e.key}: $issue',
      ];
      if (problems.isNotEmpty) {
        throw LevelFormatException(problems.join('\n'));
      }
    }
    return pack;
  }

  /// Serialises a chapter pack with one level per line (diff-friendly).
  static String encodePack(LevelPack pack) {
    final head = StringBuffer('{"schema":1');
    if (pack.chapter != null) head.write(',"chapter":${pack.chapter}');
    head.write(',"levels":[');
    final lines = [for (final l in pack.levels) jsonEncode(l.toJson())];
    return '$head\n${lines.join(',\n')}\n]}\n';
  }

  /// Serialises a daily pack with one level per line.
  static String encodeDailyPack(DailyPack pack) {
    final lines = [
      for (final e in pack.levels.entries)
        '${jsonEncode(e.key)}:${jsonEncode(e.value.toJson())}',
    ];
    return '{"schema":1,"year":${pack.year},"levels":{\n'
        '${lines.join(',\n')}\n}}\n';
  }

  static Map<String, Object?> _decode(String text, String what) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (e) {
      throw LevelFormatException('invalid JSON: ${e.message}');
    }
    if (decoded is! Map<String, Object?>) {
      throw LevelFormatException('$what must be a JSON object');
    }
    return decoded;
  }
}
