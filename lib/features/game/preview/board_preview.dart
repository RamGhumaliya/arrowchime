import 'package:arrowchime/app/theme/chapter_theme.dart';
import 'package:arrowchime/core/level/engine/game_engine.dart';
import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/features/game/flame/arrow_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

/// A live, non-interactive picture of a level (Design Gallery, Level Lab):
/// the real Flame board, with nothing to tap. Shows the mechanics exactly as
/// the game renders them.
class BoardPreview extends StatefulWidget {
  const new({
    required this.level,
    required this.theme,
    this.colorBlind = 'off',
    this.showFps = false,
    super.key,
  });

  final Level level;
  final ChapterTheme theme;
  final String colorBlind;

  /// Draw the frame rate in a corner (Level Lab).
  final bool showFps;

  @override
  State<BoardPreview> createState() => _BoardPreviewState();
}

class _BoardPreviewState extends State<BoardPreview> {
  late ArrowGame _game = _make();

  ArrowGame _make() => ArrowGame(
    engine: GameEngine(widget.level),
    theme: widget.theme,
    reduceMotion: true,
    colorBlind: widget.colorBlind,
    showFps: widget.showFps,
  );

  @override
  void didUpdateWidget(BoardPreview old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level ||
        old.theme != widget.theme ||
        old.colorBlind != widget.colorBlind ||
        old.showFps != widget.showFps) {
      _game = _make();
    }
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(child: GameWidget(game: _game)),
  );
}
