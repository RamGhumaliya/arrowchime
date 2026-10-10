import 'package:arrowchime/core/level/models/level.dart';
import 'package:arrowchime/core/meta/date_key.dart';
import 'package:arrowchime/core/save/save_data.dart';

/// The Daily Knot result card text (`docs/03` §7):
/// `Arrowchime Daily #142 ❤️❤️🖤 ⚡x4 ⏱1:52` plus an emoji mini-board.
/// This is the only place emoji are allowed (`docs/10` B4): they are share
/// text, not UI.
abstract final class DailyShare {
  static const String _full = '❤️';
  static const String _lost = '🖤';
  static const String _flow = '⚡';
  static const String _clock = '⏱';
  static const List<String> _tiles = ['🟥', '🟧', '🟨', '🟩', '🟦', '🟪'];
  static const String _empty = '⬛';

  /// The headline: `Arrowchime Daily #142 ❤️❤️🖤 ⚡x4 ⏱1:52`.
  static String headline(
    String dateKey,
    DailyResult r, {
    required int totalHearts,
  }) {
    final hearts =
        (_full * r.heartsLeft.clamp(0, totalHearts)) +
        (_lost * (totalHearts - r.heartsLeft.clamp(0, totalHearts)));
    final m = r.seconds ~/ 60;
    final s = (r.seconds % 60).toString().padLeft(2, '0');
    return 'Arrowchime Daily #${DateKey.dayOfYear(dateKey)} $hearts '
        '$_flow'
        'x${r.bestFlow} $_clock$m:$s';
  }

  /// The board as coloured squares: one colour per arrow, black for empty.
  static String miniBoard(Level level) {
    final cell = <(int, int), int>{};
    for (var i = 0; i < level.arrows.length; i++) {
      for (final c in level.arrows[i].body) {
        cell[(c.x, c.y)] = i;
      }
    }
    final rows = <String>[];
    for (var y = 0; y < level.height; y++) {
      final row = StringBuffer();
      for (var x = 0; x < level.width; x++) {
        final i = cell[(x, y)];
        row.write(i == null ? _empty : _tiles[i % _tiles.length]);
      }
      rows.add(row.toString());
    }
    return rows.join('\n');
  }

  /// The full text that is shared.
  static String text(String dateKey, DailyResult r, Level level) =>
      '${headline(dateKey, r, totalHearts: level.hearts)}\n${miniBoard(level)}';
}
