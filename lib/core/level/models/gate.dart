// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:arrowchime/core/level/models/arrow.dart';
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gate.freezed.dart';

/// A colour gate: blocks rays while closed.
@freezed
abstract class Gate with _$Gate {
  const factory Gate({required Cell cell, required GateColor color}) = _Gate;
}
