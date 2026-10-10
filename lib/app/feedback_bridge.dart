import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/audio/sfx.dart';
import 'package:arrowchime/core/haptics/haptics_service.dart';
import 'package:arrowchime/core/ui/support/tb_haptics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Routes the component library's press hook ([TBHaptics]) through the
/// [HapticsService] and the `ui_tap` click, so the Haptics and Sound switches
/// in Settings silence buttons too.
class FeedbackBridge extends ConsumerStatefulWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<FeedbackBridge> createState() => _FeedbackBridgeState();
}

class _FeedbackBridgeState extends ConsumerState<FeedbackBridge> {
  late void Function() _selection;
  late void Function() _tick;

  @override
  void initState() {
    super.initState();
    _selection = TBHaptics.selection;
    _tick = TBHaptics.tick;
    final haptics = ref.read(hapticsProvider);
    final audio = ref.read(audioServiceProvider);
    TBHaptics.selection = () {
      haptics.selection();
      audio.sfx(Sfx.uiTap, volume: 0.7);
    };
    TBHaptics.tick = haptics.light;
  }

  @override
  void dispose() {
    TBHaptics.selection = _selection;
    TBHaptics.tick = _tick;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
