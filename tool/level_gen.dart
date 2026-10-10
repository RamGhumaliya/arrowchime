// Generates level packs (docs/04 §7).
//
//   dart run tool/level_gen.dart --chapter 1 --count 60 --seed 1001 \
//       --out assets/levels/ch1.json
//   dart run tool/level_gen.dart --daily 2027 --out assets/levels/daily_2027.json
//   dart run tool/level_gen.dart --daily 2026 --from 2026-10-10 \
//       --out assets/levels/daily_2026.json
//
// Chapter packs follow the band table + sawtooth in `ChapterPlan`; the pack
// builder searches seeds until each level's difficulty is on target. The same
// flags always produce byte-identical files.
import 'dart:io';

import 'package:arrowchime/core/level/generator/chapter_plan.dart';
import 'package:arrowchime/core/level/generator/daily.dart';
import 'package:arrowchime/core/level/generator/pack_builder.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';

const _usage = '''
Usage:
  dart run tool/level_gen.dart --chapter N [--count 60] [--seed 1001] --out FILE
  dart run tool/level_gen.dart --daily YEAR [--from yyyy-mm-dd] [--to yyyy-mm-dd] --out FILE

  --chapter N   chapter 1-5 (band table and mechanics in lib/core/level/generator/chapter_plan.dart)
  --count N     levels to generate (default 60)
  --seed N      base seed (default 1001)
  --daily YEAR  pre-bake the Daily Knot of that UTC year (UTC dates, from/to default to Jan 1 / Dec 31)
  --out FILE    output path (required)
''';

int main(List<String> args) {
  final flags = _parse(args);
  if (flags == null || flags.containsKey('help')) {
    stderr.write(_usage);
    return flags == null ? 64 : 0;
  }
  final out = flags['out'];
  if (out == null) {
    stderr
      ..writeln('error: --out is required')
      ..write(_usage);
    return 64;
  }
  final sw = Stopwatch()..start();
  if (flags.containsKey('daily')) return _daily(flags, out, sw);
  if (flags.containsKey('chapter')) return _chapter(flags, out, sw);
  stderr
    ..writeln('error: pass --chapter or --daily')
    ..write(_usage);
  return 64;
}

int _chapter(Map<String, String> flags, String out, Stopwatch sw) {
  final chapter = int.tryParse(flags['chapter']!);
  final count = int.tryParse(flags['count'] ?? '60');
  final seed = int.tryParse(flags['seed'] ?? '1001');
  if (chapter == null ||
      !ChapterPlan.bands.containsKey(chapter) ||
      count == null ||
      count < 1 ||
      count > ChapterPlan.levelsPerChapter ||
      seed == null) {
    stderr
      ..writeln('error: invalid --chapter (1-5), --count (1-60) or --seed')
      ..write(_usage);
    return 64;
  }

  final built = PackBuilder.buildChapter(chapter, seed, count: count);
  final pack = LevelPack(
    chapter: chapter,
    levels: [for (final b in built) b.level],
  );
  File(out)
    ..createSync(recursive: true)
    ..writeAsStringSync(PackLoader.encodePack(pack));

  var off = 0;
  for (final b in built) {
    final exempt =
        b.level.meta.generatorVersion?.startsWith('onboarding') ?? false;
    if (!exempt && !b.withinTolerance) {
      off++;
      stderr.writeln(
        'warning: ${b.level.id} score ${b.score} is ${b.error.toStringAsFixed(1)} '
        'from target ${b.target.toStringAsFixed(1)}',
      );
    }
  }
  stdout.writeln(
    'wrote $out: chapter $chapter, ${built.length} levels, seed $seed, '
    '${sw.elapsedMilliseconds} ms, $off outside ±${ChapterPlan.checkTolerance}',
  );
  return off == 0 ? 0 : 1;
}

int _daily(Map<String, String> flags, String out, Stopwatch sw) {
  final year = int.tryParse(flags['daily']!);
  if (year == null) {
    stderr
      ..writeln('error: --daily needs a year')
      ..write(_usage);
    return 64;
  }
  final from = _date(flags['from']) ?? DateTime.utc(year);
  final to = _date(flags['to']) ?? DateTime.utc(year, 12, 31);
  if (from.year != year || to.year != year || to.isBefore(from)) {
    stderr.writeln('error: --from/--to must be dates of $year, from <= to');
    return 64;
  }
  final pack = DailyKnot.buildRange(from, to);
  File(out)
    ..createSync(recursive: true)
    ..writeAsStringSync(PackLoader.encodeDailyPack(pack));
  stdout.writeln(
    'wrote $out: ${pack.levels.length} daily levels '
    '(${DailyKnot.keyFor(from)} .. ${DailyKnot.keyFor(to)}), '
    '${sw.elapsedMilliseconds} ms',
  );
  return 0;
}

DateTime? _date(String? s) {
  if (s == null) return null;
  final d = DateTime.tryParse('${s}T00:00:00Z');
  return d;
}

/// `--key value` and `--key=value`; returns `null` on a stray argument.
Map<String, String>? _parse(List<String> args) {
  final flags = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('--')) return null;
    final eq = a.indexOf('=');
    if (eq > 0) {
      flags[a.substring(2, eq)] = a.substring(eq + 1);
    } else if (a == '--help') {
      flags['help'] = '';
    } else if (i + 1 < args.length) {
      flags[a.substring(2)] = args[++i];
    } else {
      return null;
    }
  }
  return flags;
}
