// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gen_params.freezed.dart';

/// How many of each mechanic the generator should add on top of the base
/// board (`docs/04` §3.3). Counts are upper bounds: if a mechanic cannot be
/// placed validly the generator silently adds fewer.
@freezed
abstract class MechanicMix with _$MechanicMix {
  const factory MechanicMix({
    /// Colour gates, each with its own key arrow (max 4, one per colour).
    @Default(0) int gates,

    /// Frozen arrows.
    @Default(0) int frozen,

    /// Linked pairs.
    @Default(0) int links,

    /// Portal pairs.
    @Default(0) int portalPairs,

    /// Rotators (single-cell arrows). Needs `singleCellShare > 0`.
    @Default(0) int rotators,
  }) = _MechanicMix;

  const MechanicMix._();

  static const MechanicMix none = MechanicMix();

  bool get isEmpty =>
      gates == 0 &&
      frozen == 0 &&
      links == 0 &&
      portalPairs == 0 &&
      rotators == 0;
}

/// Parameters of `LevelGenerator.generate` (`docs/04` §3.2).
@freezed
abstract class GenParams with _$GenParams {
  const factory GenParams({
    required int width,
    required int height,

    /// `null` = full rectangle; else `height` strings of `width` 0/1 chars.
    List<String>? mask,

    /// Stop when occupied / playable cells reaches this (0.55–0.92).
    @Default(0.7) double targetFill,

    /// Body length range, in cells.
    @Default(2) int lenMin,
    @Default(6) int lenMax,

    /// Length distribution: 0 uniform, `n > 0` favours short bodies (min of
    /// `n + 1` draws), `n < 0` favours long ones (max of `|n| + 1` draws).
    @Default(0) int lenSkew,

    /// Chance an arrow is a single cell (needed for rotators); the other
    /// arrows keep the `lenMin`–`lenMax` range.
    @Default(0.0) double singleCellShare,

    /// Probability that a body turns at each step (0 straight … 1 random).
    @Default(0.4) double windiness,

    /// Chance a new head is drawn towards the board centre.
    @Default(0.3) double centerBias,

    /// Chance a new head is drawn next to existing arrows.
    @Default(0.5) double clusterBias,

    /// Chance a new head is the innermost of a handful of candidates, so the
    /// board is built from the middle outwards. Late arrows then sit near the
    /// edge where their exit ray is still free, which is what lets the fill
    /// reach 0.9+ while staying solvable.
    @Default(0.0) double peelBias,

    /// Consecutive-ish placement failures before giving up.
    @Default(800) int maxFailures,

    /// Hard cap on the number of arrows (onboarding levels), or `null`.
    int? maxArrows,
    @Default(MechanicMix.none) MechanicMix mix,
    @Default(3) int hearts,

    /// Accepted `trapRatio` band for rotator levels.
    @Default(0.0) double trapMin,
    @Default(0.5) double trapMax,

    /// Rotator generate-and-test: attempts per level and search budget.
    @Default(200) int rotatorTries,
    @Default(20000) int searchStateLimit,
  }) = _GenParams;
}
