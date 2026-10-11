import 'package:arrowchime/app/app.dart';
import 'package:arrowchime/core/save/save_controller.dart';
import 'package:arrowchime/core/save/save_repository.dart';
import 'package:arrowchime/core/ui/painters/glow_shader.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build flavor, selected by the entrypoint.
enum Flavor { dev, prod }

/// Common start-up: opens the save, then runs the app. Firebase, ads and error
/// handlers are added in later phases (`docs/05` §3).
Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = await HiveSaveStore.openInApp();
  await GlowShader.load();
  runApp(
    ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
      ],
      child: const ArrowchimeApp(),
    ),
  );
}
