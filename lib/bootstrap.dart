import 'package:arrowchime/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build flavor, selected by the entrypoint.
enum Flavor { dev, prod }

/// Common start-up. Firebase, Hive, audio and error handlers are added in
/// later phases (`docs/05` §3).
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ArrowchimeApp()));
}
