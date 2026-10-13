import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/core/level/support/golden_levels.dart';

/// Runs on a real Android / iOS device (`flutter test integration_test
///`): the same seeds must give byte-identical level JSON as on
/// the Dart VM (`docs/04` §6, `docs/09` §3).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in goldenCases.entries) {
    testWidgets('golden level ${entry.key}', (tester) async {
      expect(levelHash(entry.value()), goldenHashes[entry.key]);
    });
  }
}
