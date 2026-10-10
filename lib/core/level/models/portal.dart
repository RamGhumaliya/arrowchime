// Freezed redirecting factories keep the type name; the `new` shorthand the
// lint suggests is not supported by freezed 4.
// ignore_for_file: unnecessary_type_name_in_constructor
import 'package:arrowchime/core/level/models/cell.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'portal.freezed.dart';

/// A pair of portal cells: a ray entering one continues out of the other.
@freezed
abstract class Portal with _$Portal {
  const factory Portal({required String id, required Cell a, required Cell b}) =
      _Portal;
}
