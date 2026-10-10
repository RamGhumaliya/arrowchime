// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DailyPack {

 int get year;/// `yyyy-mm-dd` (UTC date) → level, in ascending date order.
 Map<String, Level> get levels;
/// Create a copy of DailyPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyPackCopyWith<DailyPack> get copyWith => _$DailyPackCopyWithImpl<DailyPack>(this as DailyPack, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DailyPack;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyPack&&(identical(other.year, _this.year) || other.year == _this.year)&&const DeepCollectionEquality().equals(other.levels, _this.levels));
}


@override
int get hashCode {
  final _this = this as DailyPack;
  return Object.hash(runtimeType,_this.year,const DeepCollectionEquality().hash(_this.levels));
}

@override
String toString() {
  final _this = this as DailyPack;
  return 'DailyPack(year: ${_this.year}, levels: ${_this.levels})';
}


}

/// @nodoc
abstract mixin class $DailyPackCopyWith<$Res>  {
  factory $DailyPackCopyWith(DailyPack value, $Res Function(DailyPack) _then) = _$DailyPackCopyWithImpl;
@useResult
$Res call({
 int year, Map<String, Level> levels
});




}
/// @nodoc
class _$DailyPackCopyWithImpl<$Res>
    implements $DailyPackCopyWith<$Res> {
  _$DailyPackCopyWithImpl(this._self, this._then);

  final DailyPack _self;
  final $Res Function(DailyPack) _then;

/// Create a copy of DailyPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? levels = null,}) {
  return _then(DailyPack(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as Map<String, Level>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyPack].
extension DailyPackPatterns on DailyPack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyPack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyPack value)  $default,){
final _that = this;
switch (_that) {
case _DailyPack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyPack value)?  $default,){
final _that = this;
switch (_that) {
case _DailyPack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  Map<String, Level> levels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyPack() when $default != null:
return $default(_that.year,_that.levels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  Map<String, Level> levels)  $default,) {final _that = this;
switch (_that) {
case _DailyPack():
return $default(_that.year,_that.levels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  Map<String, Level> levels)?  $default,) {final _that = this;
switch (_that) {
case _DailyPack() when $default != null:
return $default(_that.year,_that.levels);case _:
  return null;

}
}

}

/// @nodoc


class _DailyPack extends DailyPack {
  const _DailyPack({required this.year, required this.levels}): super._();
  

@override final  int year;
/// `yyyy-mm-dd` (UTC date) → level, in ascending date order.
@override final  Map<String, Level> levels;

/// Create a copy of DailyPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyPackCopyWith<_DailyPack> get copyWith => __$DailyPackCopyWithImpl<_DailyPack>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyPack&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.levels, levels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,year,const DeepCollectionEquality().hash(levels));
}

@override
String toString() {
    return 'DailyPack(year: $year, levels: $levels)';
}


}

/// @nodoc
abstract mixin class _$DailyPackCopyWith<$Res> implements $DailyPackCopyWith<$Res> {
  factory _$DailyPackCopyWith(_DailyPack value, $Res Function(_DailyPack) _then) = __$DailyPackCopyWithImpl;
@override @useResult
$Res call({
 int year, Map<String, Level> levels
});




}
/// @nodoc
class __$DailyPackCopyWithImpl<$Res>
    implements _$DailyPackCopyWith<$Res> {
  __$DailyPackCopyWithImpl(this._self, this._then);

  final _DailyPack _self;
  final $Res Function(_DailyPack) _then;

/// Create a copy of DailyPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? levels = null,}) {
  return _then(_DailyPack(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as Map<String, Level>,
  ));
}


}

// dart format on
