import 'dart:async';

import 'package:arrowchime/core/save/save_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Writes the save when the app goes to the background or is closed
/// (`docs/05` §6), so nothing is lost to the 500 ms debounce.
class SaveLifecycle extends ConsumerStatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SaveLifecycle> createState() => _SaveLifecycleState();
}

class _SaveLifecycleState extends ConsumerState<SaveLifecycle> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onInactive: _flush,
      onPause: _flush,
      onDetach: _flush,
      onHide: _flush,
    );
  }

  void _flush() => unawaited(ref.read(saveControllerProvider.notifier).flush());

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
