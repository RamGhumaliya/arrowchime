import 'dart:async';

import 'package:arrowchime/core/save/save_data.dart';
import 'package:arrowchime/core/save/save_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'save_controller.g.dart';

/// Local time source (streaks use the player's local date). Tests replace it.
final Provider<DateTime Function()> clockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// Where the save lives. `bootstrap` overrides it with Hive; the default is
/// in memory so tests and previews need no setup.
final Provider<SaveRepository> saveRepositoryProvider =
    Provider<SaveRepository>((ref) => SaveRepository(MemorySaveStore()));

/// How long after the last change the save is written; `null` turns the
/// automatic write off (tests, which would otherwise end with a pending timer).
final Provider<Duration?> saveDebounceProvider = Provider<Duration?>(
  (ref) => SaveController.debounce,
);

/// The player's save: one immutable [SaveData] with `update`, written to the
/// repository 500 ms after the last change and on app pause (`docs/05` §6).
@Riverpod(keepAlive: true)
class SaveController extends _$SaveController {
  static const Duration debounce = Duration(milliseconds: 500);

  Timer? _timer;

  @override
  SaveData build() {
    ref.onDispose(() => _timer?.cancel());
    return ref.watch(saveRepositoryProvider).load();
  }

  /// Applies [change], stamps the time and schedules the write.
  void update(SaveData Function(SaveData current) change) {
    state = change(
      state,
    ).copyWith(updatedAt: ref.read(clockProvider)().toUtc().toIso8601String());
    _timer?.cancel();
    final wait = ref.read(saveDebounceProvider);
    if (wait == null) return;
    _timer = Timer(wait, () => unawaited(flush()));
  }

  /// Writes now (app going to the background, tests).
  Future<void> flush() async {
    _timer?.cancel();
    _timer = null;
    final saved = await ref.read(saveRepositoryProvider).save(state);
    state = saved;
  }
}
