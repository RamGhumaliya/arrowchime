import 'dart:convert';

import 'package:arrowchime/core/level/level_validator.dart';
import 'package:arrowchime/core/level/models/level.dart';

/// Parses level packs (`assets/levels/ch{N}.json`, `sample_levels.json`).
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
