// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Gate {

 Cell get cell; GateColor get color;
/// Create a copy of Gate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GateCopyWith<Gate> get copyWith => _$GateCopyWithImpl<Gate>(this as Gate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Gate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Gate&&(identical(other.cell, _this.cell) || other.cell == _this.cell)&&(identical(other.color, _this.color) || other.color == _this.color));
}


@override
int get hashCode {
  final _this = this as Gate;
  return Object.hash(runtimeType,_this.cell,_this.color);
}

@override
String toString() {
  final _this = this as Gate;
  return 'Gate(cell: ${_this.cell}, color: ${_this.color})';
}


}

/// @nodoc
abstract mixin class $GateCopyWith<$Res>  {
  factory $GateCopyWith(Gate value, $Res Function(Gate) _then) = _$GateCopyWithImpl;
@useResult
$Res call({
 Cell cell, GateColor color
});


$CellCopyWith<$Res> get cell;

}
/// @nodoc
class _$GateCopyWithImpl<$Res>
    implements $GateCopyWith<$Res> {
  _$GateCopyWithImpl(this._self, this._then);

  final Gate _self;
  final $Res Function(Gate) _then;

/// Create a copy of Gate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cell = null,Object? color = null,}) {
  return _then(Gate(
cell: null == cell ? _self.cell : cell // ignore: cast_nullable_to_non_nullable
as Cell,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as GateColor,
  ));
}
/// Create a copy of Gate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get cell {
  
  return $CellCopyWith<$Res>(_self.cell, (value) {
    return _then(_self.copyWith(cell: value));
  });
}
}


/// Adds pattern-matching-related methods to [Gate].
extension GatePatterns on Gate {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Gate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Gate() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Gate value)  $default,){
final _that = this;
switch (_that) {
case _Gate():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Gate value)?  $default,){
final _that = this;
switch (_that) {
case _Gate() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Cell cell,  GateColor color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Gate() when $default != null:
return $default(_that.cell,_that.color);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Cell cell,  GateColor color)  $default,) {final _that = this;
switch (_that) {
case _Gate():
return $default(_that.cell,_that.color);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Cell cell,  GateColor color)?  $default,) {final _that = this;
switch (_that) {
case _Gate() when $default != null:
return $default(_that.cell,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _Gate implements Gate {
  const _Gate({required this.cell, required this.color});
  

@override final  Cell cell;
@override final  GateColor color;

/// Create a copy of Gate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GateCopyWith<_Gate> get copyWith => __$GateCopyWithImpl<_Gate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Gate&&(identical(other.cell, cell) || other.cell == cell)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cell,color);
}

@override
String toString() {
    return 'Gate(cell: $cell, color: $color)';
}


}

/// @nodoc
abstract mixin class _$GateCopyWith<$Res> implements $GateCopyWith<$Res> {
  factory _$GateCopyWith(_Gate value, $Res Function(_Gate) _then) = __$GateCopyWithImpl;
@override @useResult
$Res call({
 Cell cell, GateColor color
});


@override $CellCopyWith<$Res> get cell;

}
/// @nodoc
class __$GateCopyWithImpl<$Res>
    implements _$GateCopyWith<$Res> {
  __$GateCopyWithImpl(this._self, this._then);

  final _Gate _self;
  final $Res Function(_Gate) _then;

/// Create a copy of Gate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cell = null,Object? color = null,}) {
  return _then(_Gate(
cell: null == cell ? _self.cell : cell // ignore: cast_nullable_to_non_nullable
as Cell,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as GateColor,
  ));
}

/// Create a copy of Gate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get cell {
  
  return $CellCopyWith<$Res>(_self.cell, (value) {
    return _then(_self.copyWith(cell: value));
  });
}
}

// dart format on
