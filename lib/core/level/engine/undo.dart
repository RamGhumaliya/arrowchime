import 'package:arrowchime/core/level/models/board_state.dart';

/// Undo history: a stack of full board snapshots (boards are small).
class UndoStack {
  final List<BoardState> _snapshots = [];

  bool get isEmpty => _snapshots.isEmpty;

  int get length => _snapshots.length;

  /// Stores [snapshot] (the state *before* a removal).
  void push(BoardState snapshot) => _snapshots.add(snapshot);

  /// Removes and returns the most recent snapshot. The stack must not be empty.
  BoardState pop() => _snapshots.removeLast();

  void clear() => _snapshots.clear();
}
