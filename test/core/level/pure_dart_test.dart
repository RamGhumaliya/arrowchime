import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `lib/core/level/` is shared with the `tool/` CLI and must stay pure Dart
/// (CLAUDE.md golden rule 2): no Flutter, no `dart:ui`, no `dart:math` Random
/// (determinism rule 4).
void main() {
  final files = Directory('lib/core/level')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('the folder contains source files', () {
    expect(files, isNotEmpty);
  });

  for (final file in files) {
    test('${file.path} has no Flutter / dart:ui / Random imports', () {
      final text = file.readAsStringSync();
      final imports = RegExp(
        r'''^\s*(import|export)\s+['"]([^'"]+)['"]''',
        multiLine: true,
      ).allMatches(text).map((m) => m.group(2)!).toList();

      for (final uri in imports) {
        expect(uri, isNot(startsWith('package:flutter')), reason: file.path);
        expect(uri, isNot(startsWith('package:flame')), reason: file.path);
        expect(uri, isNot(startsWith('package:flutter_')), reason: file.path);
        expect(uri, isNot('dart:ui'), reason: file.path);
        expect(uri, isNot('dart:math'), reason: file.path);
      }
    });
  }
}
