// Validates level packs (docs/04 §7, docs/09 §3).
//
//   dart run tool/level_check.dart assets/levels/
//   dart run tool/level_check.dart assets/levels/ch1.json
//
// Per level: schema, game rules, solvable, stored solution replays, stored
// difficulty current, difficulty within ±6 of the chapter target. Per pack:
// unique ids, chapter/index consistency. Daily packs: consecutive dates.
// Exits non-zero if anything fails (used in CI).
import 'dart:convert';
import 'dart:io';

import 'package:arrowchime/core/level/level_checker.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';

int main(List<String> args) {
  if (args.length != 1 || args.first == '--help') {
    stderr.writeln('Usage: dart run tool/level_check.dart <dir-or-json-file>');
    return args.isEmpty ? 64 : 0;
  }
  final target = args.first;
  final files = <File>[];
  if (FileSystemEntity.isDirectorySync(target)) {
    files
      ..addAll(
        Directory(target).listSync().whereType<File>().where(
          (f) => f.path.endsWith('.json') && !f.path.contains('schema'),
        ),
      )
      ..sort((a, b) => a.path.compareTo(b.path));
  } else if (File(target).existsSync()) {
    files.add(File(target));
  } else {
    stderr.writeln('error: $target does not exist');
    return 64;
  }
  if (files.isEmpty) {
    stderr.writeln('error: no level JSON files in $target');
    return 64;
  }

  final sw = Stopwatch()..start();
  var failed = 0;
  var levelCount = 0;
  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final text = file.readAsStringSync();
    final List<String> problems;
    var count = 0;
    try {
      final json = jsonDecode(text);
      if (json is Map<String, Object?> && json['levels'] is Map) {
        final pack = PackLoader.parseDailyPack(text, validate: false);
        count = pack.levels.length;
        problems = LevelChecker.checkDailyPack(pack);
      } else {
        final pack = PackLoader.parsePack(text, validate: false);
        count = pack.levels.length;
        final chapter = RegExp(r'^ch(\d+)\.json$').firstMatch(name);
        problems = LevelChecker.checkPack(
          pack,
          expectedChapter: chapter == null
              ? null
              : int.parse(chapter.group(1)!),
        );
      }
    } on LevelFormatException catch (e) {
      stdout.writeln('FAIL $name: ${e.message}');
      failed++;
      continue;
    } on FormatException catch (e) {
      stdout.writeln('FAIL $name: invalid JSON (${e.message})');
      failed++;
      continue;
    }
    levelCount += count;
    if (problems.isEmpty) {
      stdout.writeln('ok   $name ($count levels)');
    } else {
      failed++;
      stdout.writeln('FAIL $name ($count levels)');
      for (final p in problems) {
        stdout.writeln('       $p');
      }
    }
  }
  stdout.writeln(
    '${files.length} files, $levelCount levels, '
    '${sw.elapsedMilliseconds} ms: ${failed == 0 ? 'all passed' : '$failed failed'}',
  );
  return failed == 0 ? 0 : 1;
}
