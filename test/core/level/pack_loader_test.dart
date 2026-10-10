import 'dart:convert';
import 'dart:io';

import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/level/pack_loader.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  final samples = File('assets/levels/sample_levels.json').readAsStringSync();

  group('parsePack', () {
    test('loads and validates the sample pack', () {
      final pack = PackLoader.parsePack(samples);
      expect(pack.levels.map((l) => l.id), [
        'sample_tutorial',
        'sample_snake_8x8',
        'sample_gate_frozen_10x10',
      ]);
    });

    test('rejects invalid JSON and non-objects', () {
      expect(
        () => PackLoader.parsePack('{oops'),
        throwsA(
          isA<LevelFormatException>().having(
            (e) => e.message,
            'message',
            startsWith('invalid JSON'),
          ),
        ),
      );
      expect(
        () => PackLoader.parsePack('[1]'),
        throwsA(isA<LevelFormatException>()),
      );
    });

    test('collects rule violations of every level when validating', () {
      final bad = levelJson(
        id: 'bad_one',
        arrows: [
          arrowJson(0, [
            [0, 0],
            [3, 0],
          ], 'D'),
        ],
      );
      final text = jsonEncode({
        'schema': 1,
        'levels': [bad],
      });
      expect(
        () => PackLoader.parsePack(text),
        throwsA(
          isA<LevelFormatException>().having(
            (e) => e.message,
            'message',
            contains('bad_one: arrow 0'),
          ),
        ),
      );
      expect(PackLoader.parsePack(text, validate: false).levels, hasLength(1));
    });
  });

  group('parseLevel', () {
    test('parses a single level', () {
      final text = jsonEncode(
        levelJson(
          arrows: [
            arrowJson(0, [
              [0, 0],
            ], 'L'),
          ],
        ),
      );
      expect(PackLoader.parseLevel(text).arrows, hasLength(1));
    });

    test('validates by default', () {
      final text = jsonEncode(
        levelJson(
          arrows: [
            arrowJson(0, [
              [0, 0],
              [3, 0],
            ], 'L'),
          ],
        ),
      );
      expect(
        () => PackLoader.parseLevel(text),
        throwsA(isA<LevelFormatException>()),
      );
      expect(PackLoader.parseLevel(text, validate: false).arrows, hasLength(1));
    });

    test('rejects non-object JSON', () {
      expect(
        () => PackLoader.parseLevel('3'),
        throwsA(isA<LevelFormatException>()),
      );
    });
  });
}
