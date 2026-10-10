// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Portal {

 String get id; Cell get a; Cell get b;
/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PortalCopyWith<Portal> get copyWith => _$PortalCopyWithImpl<Portal>(this as Portal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Portal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Portal&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.a, _this.a) || other.a == _this.a)&&(identical(other.b, _this.b) || other.b == _this.b));
}


@override
int get hashCode {
  final _this = this as Portal;
  return Object.hash(runtimeType,_this.id,_this.a,_this.b);
}

@override
String toString() {
  final _this = this as Portal;
  return 'Portal(id: ${_this.id}, a: ${_this.a}, b: ${_this.b})';
}


}

/// @nodoc
abstract mixin class $PortalCopyWith<$Res>  {
  factory $PortalCopyWith(Portal value, $Res Function(Portal) _then) = _$PortalCopyWithImpl;
@useResult
$Res call({
 String id, Cell a, Cell b
});


$CellCopyWith<$Res> get a;$CellCopyWith<$Res> get b;

}
/// @nodoc
class _$PortalCopyWithImpl<$Res>
    implements $PortalCopyWith<$Res> {
  _$PortalCopyWithImpl(this._self, this._then);

  final Portal _self;
  final $Res Function(Portal) _then;

/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? a = null,Object? b = null,}) {
  return _then(Portal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as Cell,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as Cell,
  ));
}
/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get a {
  
  return $CellCopyWith<$Res>(_self.a, (value) {
    return _then(_self.copyWith(a: value));
  });
}/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get b {
  
  return $CellCopyWith<$Res>(_self.b, (value) {
    return _then(_self.copyWith(b: value));
  });
}
}


/// Adds pattern-matching-related methods to [Portal].
extension PortalPatterns on Portal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Portal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Portal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Portal value)  $default,){
final _that = this;
switch (_that) {
case _Portal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Portal value)?  $default,){
final _that = this;
switch (_that) {
case _Portal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Cell a,  Cell b)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Portal() when $default != null:
return $default(_that.id,_that.a,_that.b);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Cell a,  Cell b)  $default,) {final _that = this;
switch (_that) {
case _Portal():
return $default(_that.id,_that.a,_that.b);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Cell a,  Cell b)?  $default,) {final _that = this;
switch (_that) {
case _Portal() when $default != null:
return $default(_that.id,_that.a,_that.b);case _:
  return null;

}
}

}

/// @nodoc


class _Portal implements Portal {
  const _Portal({required this.id, required this.a, required this.b});
  

@override final  String id;
@override final  Cell a;
@override final  Cell b;

/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PortalCopyWith<_Portal> get copyWith => __$PortalCopyWithImpl<_Portal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Portal&&(identical(other.id, id) || other.id == id)&&(identical(other.a, a) || other.a == a)&&(identical(other.b, b) || other.b == b));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,a,b);
}

@override
String toString() {
    return 'Portal(id: $id, a: $a, b: $b)';
}


}

/// @nodoc
abstract mixin class _$PortalCopyWith<$Res> implements $PortalCopyWith<$Res> {
  factory _$PortalCopyWith(_Portal value, $Res Function(_Portal) _then) = __$PortalCopyWithImpl;
@override @useResult
$Res call({
 String id, Cell a, Cell b
});


@override $CellCopyWith<$Res> get a;@override $CellCopyWith<$Res> get b;

}
/// @nodoc
class __$PortalCopyWithImpl<$Res>
    implements _$PortalCopyWith<$Res> {
  __$PortalCopyWithImpl(this._self, this._then);

  final _Portal _self;
  final $Res Function(_Portal) _then;

/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? a = null,Object? b = null,}) {
  return _then(_Portal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,a: null == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as Cell,b: null == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as Cell,
  ));
}

/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get a {
  
  return $CellCopyWith<$Res>(_self.a, (value) {
    return _then(_self.copyWith(a: value));
  });
}/// Create a copy of Portal
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CellCopyWith<$Res> get b {
  
  return $CellCopyWith<$Res>(_self.b, (value) {
    return _then(_self.copyWith(b: value));
  });
}
}

// dart format on
