// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arrow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Arrow {

 int get id;/// Ordered tail → head, 4-adjacent cells.
 List<Cell> get body; Direction get dir; ArrowKind get kind; GateColor? get color;/// Initial freeze counter (≥ 1), or `null`.
 int? get frozen;/// Link group id (`L1`…); exactly two arrows share one.
 String? get link; int? get skinHint;
/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArrowCopyWith<Arrow> get copyWith => _$ArrowCopyWithImpl<Arrow>(this as Arrow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Arrow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Arrow&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.body, _this.body)&&(identical(other.dir, _this.dir) || other.dir == _this.dir)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.frozen, _this.frozen) || other.frozen == _this.frozen)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.skinHint, _this.skinHint) || other.skinHint == _this.skinHint));
}


@override
int get hashCode {
  final _this = this as Arrow;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.body),_this.dir,_this.kind,_this.color,_this.frozen,_this.link,_this.skinHint);
}

@override
String toString() {
  final _this = this as Arrow;
  return 'Arrow(id: ${_this.id}, body: ${_this.body}, dir: ${_this.dir}, kind: ${_this.kind}, color: ${_this.color}, frozen: ${_this.frozen}, link: ${_this.link}, skinHint: ${_this.skinHint})';
}


}

/// @nodoc
abstract mixin class $ArrowCopyWith<$Res>  {
  factory $ArrowCopyWith(Arrow value, $Res Function(Arrow) _then) = _$ArrowCopyWithImpl;
@useResult
$Res call({
 int id, List<Cell> body, Direction dir, ArrowKind kind, GateColor? color, int? frozen, String? link, int? skinHint
});




}
/// @nodoc
class _$ArrowCopyWithImpl<$Res>
    implements $ArrowCopyWith<$Res> {
  _$ArrowCopyWithImpl(this._self, this._then);

  final Arrow _self;
  final $Res Function(Arrow) _then;

/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? body = null,Object? dir = null,Object? kind = null,Object? color = freezed,Object? frozen = freezed,Object? link = freezed,Object? skinHint = freezed,}) {
  return _then(Arrow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as List<Cell>,dir: null == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as Direction,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ArrowKind,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as GateColor?,frozen: freezed == frozen ? _self.frozen : frozen // ignore: cast_nullable_to_non_nullable
as int?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,skinHint: freezed == skinHint ? _self.skinHint : skinHint // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Arrow].
extension ArrowPatterns on Arrow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Arrow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Arrow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Arrow value)  $default,){
final _that = this;
switch (_that) {
case _Arrow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Arrow value)?  $default,){
final _that = this;
switch (_that) {
case _Arrow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  List<Cell> body,  Direction dir,  ArrowKind kind,  GateColor? color,  int? frozen,  String? link,  int? skinHint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Arrow() when $default != null:
return $default(_that.id,_that.body,_that.dir,_that.kind,_that.color,_that.frozen,_that.link,_that.skinHint);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  List<Cell> body,  Direction dir,  ArrowKind kind,  GateColor? color,  int? frozen,  String? link,  int? skinHint)  $default,) {final _that = this;
switch (_that) {
case _Arrow():
return $default(_that.id,_that.body,_that.dir,_that.kind,_that.color,_that.frozen,_that.link,_that.skinHint);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  List<Cell> body,  Direction dir,  ArrowKind kind,  GateColor? color,  int? frozen,  String? link,  int? skinHint)?  $default,) {final _that = this;
switch (_that) {
case _Arrow() when $default != null:
return $default(_that.id,_that.body,_that.dir,_that.kind,_that.color,_that.frozen,_that.link,_that.skinHint);case _:
  return null;

}
}

}

/// @nodoc


class _Arrow extends Arrow {
  const _Arrow({required this.id, required this.body, required this.dir, this.kind = ArrowKind.normal, this.color, this.frozen, this.link, this.skinHint}): super._();
  

@override final  int id;
/// Ordered tail → head, 4-adjacent cells.
@override final  List<Cell> body;
@override final  Direction dir;
@override@JsonKey() final  ArrowKind kind;
@override final  GateColor? color;
/// Initial freeze counter (≥ 1), or `null`.
@override final  int? frozen;
/// Link group id (`L1`…); exactly two arrows share one.
@override final  String? link;
@override final  int? skinHint;

/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArrowCopyWith<_Arrow> get copyWith => __$ArrowCopyWithImpl<_Arrow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Arrow&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.body, body)&&(identical(other.dir, dir) || other.dir == dir)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.color, color) || other.color == color)&&(identical(other.frozen, frozen) || other.frozen == frozen)&&(identical(other.link, link) || other.link == link)&&(identical(other.skinHint, skinHint) || other.skinHint == skinHint));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(body),dir,kind,color,frozen,link,skinHint);
}

@override
String toString() {
    return 'Arrow(id: $id, body: $body, dir: $dir, kind: $kind, color: $color, frozen: $frozen, link: $link, skinHint: $skinHint)';
}


}

/// @nodoc
abstract mixin class _$ArrowCopyWith<$Res> implements $ArrowCopyWith<$Res> {
  factory _$ArrowCopyWith(_Arrow value, $Res Function(_Arrow) _then) = __$ArrowCopyWithImpl;
@override @useResult
$Res call({
 int id, List<Cell> body, Direction dir, ArrowKind kind, GateColor? color, int? frozen, String? link, int? skinHint
});




}
/// @nodoc
class __$ArrowCopyWithImpl<$Res>
    implements _$ArrowCopyWith<$Res> {
  __$ArrowCopyWithImpl(this._self, this._then);

  final _Arrow _self;
  final $Res Function(_Arrow) _then;

/// Create a copy of Arrow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? body = null,Object? dir = null,Object? kind = null,Object? color = freezed,Object? frozen = freezed,Object? link = freezed,Object? skinHint = freezed,}) {
  return _then(_Arrow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as List<Cell>,dir: null == dir ? _self.dir : dir // ignore: cast_nullable_to_non_nullable
as Direction,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ArrowKind,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as GateColor?,frozen: freezed == frozen ? _self.frozen : frozen // ignore: cast_nullable_to_non_nullable
as int?,link: freezed == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String?,skinHint: freezed == skinHint ? _self.skinHint : skinHint // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
