import 'dart:async';

import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/app/theme/tokens.dart';
import 'package:arrowchime/core/audio/audio_service.dart';
import 'package:arrowchime/core/audio/chapter_sound.dart';
import 'package:arrowchime/core/audio/melody_player.dart';
import 'package:arrowchime/core/level/engine/events.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/ui/painters/arrow_skin.dart';
import 'package:arrowchime/core/ui/support/tb_motion_scope.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:arrowchime/features/game/flame/board_themes.dart';
import 'package:arrowchime/features/game/flame/trail_style.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Collection's live preview (`docs/10` §7): a small real board wearing the
/// selected skin, trail, felt and instrument. Tapping it replays a short clear
/// (the arrows fly out, leave their trail and play the melody).
class CollectionPreview extends ConsumerStatefulWidget {
  const new({
    required this.level,
    required this.theme,
    required this.skin,
    required this.trail,
    required this.board,
    required this.instrument,
    super.key,
  });

  final Level level;
  final ChapterTheme theme;
  final String skin;
  final String trail;
  final String board;
  final String instrument;

  @override
  ConsumerState<CollectionPreview> createState() => _CollectionPreviewState();
}

class _CollectionPreviewState extends ConsumerState<CollectionPreview> {
  late ArrowGame _game = _make();
  Timer? _replay;
  int _playing = 0;

  ArrowGame _make() => ArrowGame(
    engine: GameEngine(widget.level),
    theme: BoardThemes.apply(widget.theme, widget.board),
    skin: ArrowSkin.fromId(widget.skin),
    trail: TrailStyle.fromId(widget.trail),
    reduceMotion: TBMotionScope.reduced(context),
  );

  @override
  void initState() {
    super.initState();
    _loadVoice();
  }

  /// The notes of the previewed instrument must be loaded to be heard.
  void _loadVoice() => unawaited(
    ref
        .read(audioServiceProvider)
        .enterChapter(widget.theme.id, instrument: widget.instrument),
  );

  @override
  void didUpdateWidget(CollectionPreview old) {
    super.didUpdateWidget(old);
    if (old.instrument != widget.instrument) _loadVoice();
    if (old.skin != widget.skin ||
        old.trail != widget.trail ||
        old.board != widget.board ||
        old.level != widget.level) {
      _replay?.cancel();
      _game = _make();
    }
  }

  @override
  void dispose() {
    _replay?.cancel();
    super.dispose();
  }

  /// Clears the board along the stored solution, one arrow every 140 ms.
  void _clear() {
    _replay?.cancel();
    final solution = widget.level.meta.solution;
    final engine = GameEngine(widget.level);
    final game = _game..resetBoard();
    final sound = ChapterSound.of(widget.theme.id);
    final melody = MelodyPlayer.forLevel(widget.theme.id, 1);
    final audio = ref.read(audioServiceProvider);
    var i = 0;
    final session = ++_playing;
    _replay = Timer.periodic(TBFeedback.previewStep, (t) {
      if (!mounted || session != _playing || i >= solution.length) {
        t.cancel();
        return;
      }
      final events = engine.tap(solution[i++]);
      game.playEvents(events);
      if (events.any((e) => e is ArrowFreed)) {
        audio.note(sound, melody.next().index, instrument: widget.instrument);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _clear,
      child: GameWidget(game: _game),
    );
  }
}
