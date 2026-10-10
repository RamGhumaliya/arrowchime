import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test-wide setup: loads the bundled fonts (so goldens show Fredoka / Nunito
/// instead of the blocky test font) and relaxes golden comparison slightly
/// (anti-aliasing differs a little between Windows, macOS and Linux).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('Fredoka', 'assets/fonts/Fredoka.ttf');
  await _loadFont('Nunito', 'assets/fonts/Nunito.ttf');

  final base = goldenFileComparator;
  if (base is LocalFileComparator) {
    goldenFileComparator = _TolerantComparator(
      Uri.parse('${base.basedir}flutter_test_config.dart'),
    );
  }
  await testMain();
}

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
}

/// Passes goldens that differ by at most [tolerance] of their pixels.
class _TolerantComparator extends LocalFileComparator {
  new(super.testFile);

  static const double tolerance = 0.01;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
