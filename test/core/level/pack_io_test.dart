import 'dart:convert';

import 'package:arrowchime/core/level/generator/daily.dart';
import 'package:arrowchime/core/level/models/daily_pack.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  group('encodePack', () {
    test('one level per line, round-trips', () {
      final pack = LevelPack(
        chapter: 2,
        levels: [
          freeTrio(),
          blockedPair().copyWith(id: 'second'),
        ],
      );
      final text = PackLoader.encodePack(pack);
      final lines = text.trimRight().split('\n');
      expect(lines.length, 4, reason: 'header + 2 levels + footer');
      expect(lines.first, '{"schema":1,"chapter":2,"levels":[');
      expect(lines.last, ']}');
      expect(lines[1].endsWith(','), isTrue);
      expect(text.endsWith('\n'), isTrue);

      final back = PackLoader.parsePack(text);
      expect(back.chapter, 2);
      expect(back.levels.map((l) => l.id), ['fixture', 'second']);
      expect(jsonEncode(back.toJson()), jsonEncode(pack.toJson()));
    });

    test('a pack without a chapter omits the key', () {
      final text = PackLoader.encodePack(LevelPack(levels: [freeTrio()]));
      expect(text.startsWith('{"schema":1,"levels":['), isTrue);
    });
  });

  group('daily packs', () {
    final pack = DailyKnot.buildRange(
      DateTime.utc(2026, 12, 30),
      DateTime.utc(2026, 12, 31),
    );

    test('encode / parse round-trips', () {
      final text = PackLoader.encodeDailyPack(pack);
      expect(text.split('\n').length, 5);
      final back = PackLoader.parseDailyPack(text);
      expect(back.year, 2026);
      expect(back.levels.keys, ['2026-12-30', '2026-12-31']);
      expect(jsonEncode(back.toJson()), jsonEncode(pack.toJson()));
    });

    test('validation reports the date of a broken level', () {
      final json = pack.toJson();
      final levels = json['levels']! as Map<String, Object?>;
      final broken = levelJson(
        id: 'daily_20261230',
        arrows: [
          arrowJson(0, [
            [0, 0],
            [3, 0],
          ], 'R'),
        ],
      )..['chapter'] = 0;
      levels['2026-12-30'] = broken;
      expect(
        () => PackLoader.parseDailyPack(jsonEncode(json)),
        throwsA(
          isA<LevelFormatException>().having(
            (e) => e.message,
            'message',
            contains('2026-12-30: arrow 0'),
          ),
        ),
      );
      expect(
        PackLoader.parseDailyPack(jsonEncode(json), validate: false).levels,
        hasLength(2),
      );
    });

    final bad = <String, void Function(Map<String, Object?>)>{
      'schema must be 1': (j) => j['schema'] = 2,
      'year must be an integer': (j) => j['year'] = '2026',
      'levels must be an object': (j) => j['levels'] = [1],
      'must be a 2026-mm-dd date': (j) =>
          (j['levels']! as Map<String, Object?>)['2027-01-01'] = j['levels'],
      'must be a 2026-mm-dd date (format)': (j) =>
          (j['levels']! as Map<String, Object?>)['2026-1-1'] = 1,
      'must be an object': (j) =>
          (j['levels']! as Map<String, Object?>)['2026-12-30'] = 5,
    };
    for (final entry in bad.entries) {
      test('rejects: ${entry.key}', () {
        final json =
            jsonDecode(jsonEncode(pack.toJson())) as Map<String, Object?>;
        entry.value(json);
        expect(
          () => DailyPack.fromJson(json),
          throwsA(isA<LevelFormatException>()),
        );
      });
    }

    test('parseDailyPack rejects non-object JSON', () {
      expect(
        () => PackLoader.parseDailyPack('[]'),
        throwsA(isA<LevelFormatException>()),
      );
    });
  });
}
