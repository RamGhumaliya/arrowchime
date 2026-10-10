import 'package:arrowchime/core/level/engine/events.dart';
import 'package:arrowchime/core/level/engine/rules.dart';
import 'package:arrowchime/core/level/engine/undo.dart';
import 'package:arrowchime/core/level/models/board_layout.dart';
import 'package:arrowchime/core/level/models/board_state.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:arrowchime/core/level/models/level.dart';

enum GameStatus { playing, won, lost }

/// Tunables of one play session.
class EngineOptions {
  const new({
    this.relaxed = false,
    this.hearts,
    this.enableSwitcher = false,
    this.enableSplitter = false,
  });

  /// Relaxed mode: hearts are never lost; stars are capped at two.
  final bool relaxed;

  /// Overrides the level's heart count (remote config `hearts_per_level`).
  final int? hearts;

  /// v1.1 mechanics, off by default (`docs/03` §5).
  final bool enableSwitcher;
  final bool enableSplitter;

  RulesConfig get rules => RulesConfig(
    enableSwitcher: enableSwitcher,
    enableSplitter: enableSplitter,
  );
}

/// Counters for analytics (`level_win` params).
class EngineStats {
  int freedTaps = 0;
  int blockedTaps = 0;
  int frozenTaps = 0;
  int undos = 0;
}

/// The pure, synchronous, deterministic game core (`docs/04` §2).
///
/// `tap` returns the [GameEvent]s a tap caused; presentation replays them.
class GameEngine {
  new(this.level, {this.options = const EngineOptions()})
    : layout = BoardLayout(level),
      _state = BoardState.initial(level),
      _initialHearts = options.hearts ?? level.hearts {
    _hearts = _initialHearts;
  }

  final Level level;
  final EngineOptions options;
  final BoardLayout layout;
  final UndoStack _undo = UndoStack();
  final int _initialHearts;
  final EngineStats stats = EngineStats();

  BoardState _state;
  late int _hearts;

  /// Hearts spent on blocked taps; unlike [hearts] it is never refunded by
  /// [addHeart], so stars stay honest.
  int _heartsLost = 0;
  GameStatus _status = GameStatus.playing;

  /// Current runtime state. Replaced on undo/reset: re-read after those.
  BoardState get state => _state;

  GameStatus get status => _status;

  int get hearts => _hearts;

  int get initialHearts => _initialHearts;

  int get remaining => _state.remaining;

  bool get canUndo => _status == GameStatus.playing && !_undo.isEmpty;

  int get undoDepth => _undo.length;

  /// Stars for the current heart count: 3 hearts left = ★★★, 2 = ★★,
  /// 1 = ★ (generalised to other heart counts as "hearts lost").
  /// Relaxed mode caps at ★★.
  int get stars {
    final lost = _heartsLost;
    final raw = (3 - lost).clamp(1, 3);
    return options.relaxed && raw > 2 ? 2 : raw;
  }

  /// Ids of arrows still on the board, in level order.
  List<int> get remainingIds => [
    for (final i in _state.aliveIndices) layout.idOf(i),
  ];

  /// Whether the arrow with [arrowId] is on the board and free.
  bool isFree(int arrowId) {
    final i = layout.indexById[arrowId];
    return i != null &&
        _state.isAlive(i) &&
        Rules.isFree(_state, i, options.rules);
  }

  /// Ids of all free arrows, in level order.
  List<int> get freeArrowIds => [
    for (final i in Rules.freeArrows(_state, options.rules)) layout.idOf(i),
  ];

  /// Current facing of an arrow on the board (rotators change it).
  Direction? dirOf(int arrowId) {
    final i = layout.indexById[arrowId];
    return i != null && _state.isAlive(i) ? _state.dirOf(i) : null;
  }

  /// Remaining freeze counter of an arrow (0 = not frozen).
  int frozenCounter(int arrowId) {
    final i = layout.indexById[arrowId];
    return i == null ? 0 : _state.frozen[i];
  }

  /// Exit route of an arrow for "Peek" / Route Grid: one list per ray, all the
  /// way to the board edge and through portals, ignoring obstacles so it does
  /// not reveal free/blocked. Empty for unknown or removed ids.
  List<List<Cell>> exitPaths(int arrowId) {
    final i = layout.indexById[arrowId];
    if (i == null || !_state.isAlive(i)) return const [];
    return _cells(
      Rules.exitPaths(_state, i, blocking: false, config: options.rules),
    );
  }

  /// Taps the arrow with [arrowId]. Unknown / removed ids and taps after the
  /// level ended do nothing.
  List<GameEvent> tap(int arrowId) {
    if (_status != GameStatus.playing) return const [];
    final i = layout.indexById[arrowId];
    if (i == null || !_state.isAlive(i)) return const [];

    final freedom = Rules.check(_state, i, options.rules);
    switch (freedom.status) {
      case FreedomStatus.frozen:
        stats.frozenTaps++;
        return [FrozenTapped(arrowId: arrowId, counter: _state.frozen[i])];
      case FreedomStatus.blocked:
        return _blocked(arrowId, freedom);
      case FreedomStatus.free:
        return _free(i);
    }
  }

  /// Restores the board to before the last removal. Hearts are not restored.
  List<GameEvent> undo() {
    if (!canUndo) return const [];
    final before = _undo.pop();
    final restored = [
      for (var i = 0; i < before.alive.length; i++)
        if (before.alive[i] == 1 && !_state.isAlive(i)) layout.idOf(i),
    ];
    _state = before;
    stats.undos++;
    return [UndoApplied(restoredArrowIds: restored)];
  }

  /// Gives one extra heart (the fail sheet's "+1 heart"). A lost level
  /// resumes where it stopped; the hearts already lost still count against the
  /// stars, so an extra heart never earns extra stars.
  void addHeart() {
    if (_status == GameStatus.won) return;
    _hearts++;
    if (_status == GameStatus.lost) _status = GameStatus.playing;
  }

  /// Starts the level over: full board, full hearts, empty undo history.
  void reset() {
    _state = BoardState.fromLayout(layout);
    _hearts = _initialHearts;
    _heartsLost = 0;
    _status = GameStatus.playing;
    _undo.clear();
    stats
      ..freedTaps = 0
      ..blockedTaps = 0
      ..frozenTaps = 0
      ..undos = 0;
  }

  List<GameEvent> _blocked(int arrowId, Freedom freedom) {
    stats.blockedTaps++;
    final hit = freedom.hit!;
    final blockerArrow = hit.arrowIndex >= 0
        ? layout.idOf(hit.arrowIndex)
        : null;
    final events = <GameEvent>[
      BlockedTap(
        arrowId: arrowId,
        blockedArrowId: layout.idOf(freedom.blockedIndex),
        blockerType: hit.type,
        blockerArrowId: blockerArrow,
        blockerCell: hit.cell >= 0 ? layout.cellAt(hit.cell) : null,
        distance: hit.distance,
      ),
    ];
    if (!options.relaxed) {
      _hearts--;
      _heartsLost++;
      events.add(HeartLost(heartsLeft: _hearts));
      if (_hearts <= 0) {
        _status = GameStatus.lost;
        events.add(const LevelLost());
      }
    }
    return events;
  }

  List<GameEvent> _free(int i) {
    stats.freedTaps++;
    _undo.push(_state.copy());

    final partner = layout.partner[i];
    final paths = Rules.exitPaths(_state, i, config: options.rules);
    final dir = _state.dirOf(i);
    final partnerPaths = partner >= 0
        ? Rules.exitPaths(_state, partner, config: options.rules)
        : null;
    final partnerDir = partner >= 0 ? _state.dirOf(partner) : null;

    final effects = Rules.remove(_state, i, options.rules);

    final events = <GameEvent>[
      ArrowFreed(arrowId: layout.idOf(i), dir: dir, paths: _cells(paths)),
      if (partnerPaths != null)
        ArrowFreed(
          arrowId: layout.idOf(partner),
          dir: partnerDir!,
          paths: _cells(partnerPaths),
          viaLink: true,
        ),
      for (final e in effects.openedGates.entries)
        GateOpened(
          color: e.key,
          cells: [for (final c in e.value) layout.cellAt(c)],
        ),
      if (effects.frozenTicked.isNotEmpty)
        FrozenTicked(
          counters: {
            for (final j in effects.frozenTicked)
              layout.idOf(j): _state.frozen[j],
          },
        ),
      if (effects.rotated.isNotEmpty)
        RotatorsTurned(
          dirs: {
            for (final j in effects.rotated) layout.idOf(j): _state.dirOf(j),
          },
        ),
      if (effects.flipped.isNotEmpty)
        ArrowsFlipped(
          dirs: {
            for (final j in effects.flipped) layout.idOf(j): _state.dirOf(j),
          },
        ),
    ];

    if (_state.remaining == 0) {
      _status = GameStatus.won;
      events.add(LevelWon(stars: stars, heartsLeft: _hearts));
    }
    return events;
  }

  List<List<Cell>> _cells(List<List<int>> paths) => [
    for (final p in paths) [for (final c in p) layout.cellAt(c)],
  ];
}
