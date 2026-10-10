// Prints the golden determinism hashes used by the generator tests:
//
//   dart run tool/print_golden_hashes.dart
//
// Paste the output into `goldenHashes` in
// test/core/level/support/golden_levels.dart, but only after a deliberate
// generator change (also bump LevelGenerator.version).
import 'dart:io';

import '../test/core/level/support/golden_levels.dart';

void main() {
  stdout.writeln('const Map<String, int> goldenHashes = {');
  for (final e in goldenCases.entries) {
    final h = levelHash(e.value());
    stdout.writeln("  '${e.key}': 0x${h.toRadixString(16).toUpperCase()},");
  }
  stdout.writeln('};');
}
