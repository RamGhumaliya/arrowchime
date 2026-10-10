/// Outcome of a solver run.
class SolveResult {
  const new({
    required this.solvable,
    this.solution = const [],
    this.depth,
    this.waveFreeCounts = const [],
    this.waveRemaining = const [],
    this.tooComplex = false,
    this.statesExpanded = 0,
    this.trapRatio = 0,
  });

  /// A removal order exists.
  final bool solvable;

  /// Arrow ids in tap order (for a linked pair, the tapped arrow only).
  final List<int> solution;

  /// Greedy waves; `null` for the search solver.
  final int? depth;

  /// Greedy only: number of free arrows at the start of each wave.
  final List<int> waveFreeCounts;

  /// Greedy only: arrows remaining at the start of each wave.
  final List<int> waveRemaining;

  /// Search solver hit its state limit: treat the level as rejected.
  final bool tooComplex;

  /// Search solver: states expanded.
  final int statesExpanded;

  /// Search solver: fraction of sampled early moves that lead to an
  /// unsolvable board (0 for monotone levels).
  final double trapRatio;
}
