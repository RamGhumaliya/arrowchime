// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:arrowchime/core/level/models/direction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'arrow.freezed.dart';

/// Arrow behaviour class (`docs/04` §1).
enum ArrowKind {
  normal,
  rotator,
  key,
  switcher,
  splitter;

  static ArrowKind? fromName(String name) {
    for (final k in ArrowKind.values) {
      if (k.name == name) return k;
    }
    return null;
  }
}

/// Gate / key colour. Each also has a symbol for colour-blind play.
enum GateColor {
  amber,
  jade,
  rose,
  azure;

  static GateColor? fromName(String name) {
    for (final c in GateColor.values) {
      if (c.name == name) return c;
    }
    return null;
  }
}

/// An arrow as authored in a level (initial state, immutable).
@Freezed(makeCollectionsUnmodifiable: false)
abstract class Arrow with _$Arrow {
  const factory Arrow({
    required int id,

    /// Ordered tail → head, 4-adjacent cells.
    required List<Cell> body,
    required Direction dir,
    @Default(ArrowKind.normal) ArrowKind kind,
    GateColor? color,

    /// Initial freeze counter (≥ 1), or `null`.
    int? frozen,

    /// Link group id (`L1`…); exactly two arrows share one.
    String? link,
    int? skinHint,
  }) = _Arrow;

  const Arrow._();

  Cell get tail => body.first;
  Cell get head => body.last;
}
