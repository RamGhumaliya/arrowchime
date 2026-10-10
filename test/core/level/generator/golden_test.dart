import 'package:flutter_test/flutter_test.dart';

import '../support/golden_levels.dart';

/// Determinism lock (`docs/04` §6): fixed inputs => fixed level JSON. If this
/// fails the generator output changed: either a bug, or a deliberate change
/// (bump `LevelGenerator.version`, then run
/// `dart run tool/print_golden_hashes.dart` and update the hashes).
void main() {
  test('every golden case has an expected hash and vice versa', () {
    expect(goldenCases.keys.toSet(), goldenHashes.keys.toSet());
  });

  for (final entry in goldenCases.entries) {
    test('golden: ${entry.key}', () {
      final level = entry.value();
      expect(
        levelHash(level),
        goldenHashes[entry.key],
        reason: 'generator output changed for ${entry.key}',
      );
    });
  }

  test('building a case twice gives the same hash', () {
    for (final entry in goldenCases.entries) {
      expect(levelHash(entry.value()), levelHash(entry.value()));
    }
  });
}
