// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gen_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MechanicMix {

/// Colour gates, each with its own key arrow (max 4, one per colour).
 int get gates;/// Frozen arrows.
 int get frozen;/// Linked pairs.
 int get links;/// Portal pairs.
 int get portalPairs;/// Rotators (single-cell arrows). Needs `singleCellShare > 0`.
 int get rotators;
/// Create a copy of MechanicMix
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MechanicMixCopyWith<MechanicMix> get copyWith => _$MechanicMixCopyWithImpl<MechanicMix>(this as MechanicMix, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MechanicMix;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MechanicMix&&(identical(other.gates, _this.gates) || other.gates == _this.gates)&&(identical(other.frozen, _this.frozen) || other.frozen == _this.frozen)&&(identical(other.links, _this.links) || other.links == _this.links)&&(identical(other.portalPairs, _this.portalPairs) || other.portalPairs == _this.portalPairs)&&(identical(other.rotators, _this.rotators) || other.rotators == _this.rotators));
}


@override
int get hashCode {
  final _this = this as MechanicMix;
  return Object.hash(runtimeType,_this.gates,_this.frozen,_this.links,_this.portalPairs,_this.rotators);
}

@override
String toString() {
  final _this = this as MechanicMix;
  return 'MechanicMix(gates: ${_this.gates}, frozen: ${_this.frozen}, links: ${_this.links}, portalPairs: ${_this.portalPairs}, rotators: ${_this.rotators})';
}


}

/// @nodoc
abstract mixin class $MechanicMixCopyWith<$Res>  {
  factory $MechanicMixCopyWith(MechanicMix value, $Res Function(MechanicMix) _then) = _$MechanicMixCopyWithImpl;
@useResult
$Res call({
 int gates, int frozen, int links, int portalPairs, int rotators
});




}
/// @nodoc
class _$MechanicMixCopyWithImpl<$Res>
    implements $MechanicMixCopyWith<$Res> {
  _$MechanicMixCopyWithImpl(this._self, this._then);

  final MechanicMix _self;
  final $Res Function(MechanicMix) _then;

/// Create a copy of MechanicMix
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gates = null,Object? frozen = null,Object? links = null,Object? portalPairs = null,Object? rotators = null,}) {
  return _then(MechanicMix(
gates: null == gates ? _self.gates : gates // ignore: cast_nullable_to_non_nullable
as int,frozen: null == frozen ? _self.frozen : frozen // ignore: cast_nullable_to_non_nullable
as int,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as int,portalPairs: null == portalPairs ? _self.portalPairs : portalPairs // ignore: cast_nullable_to_non_nullable
as int,rotators: null == rotators ? _self.rotators : rotators // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MechanicMix].
extension MechanicMixPatterns on MechanicMix {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MechanicMix value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MechanicMix() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MechanicMix value)  $default,){
final _that = this;
switch (_that) {
case _MechanicMix():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MechanicMix value)?  $default,){
final _that = this;
switch (_that) {
case _MechanicMix() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int gates,  int frozen,  int links,  int portalPairs,  int rotators)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MechanicMix() when $default != null:
return $default(_that.gates,_that.frozen,_that.links,_that.portalPairs,_that.rotators);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int gates,  int frozen,  int links,  int portalPairs,  int rotators)  $default,) {final _that = this;
switch (_that) {
case _MechanicMix():
return $default(_that.gates,_that.frozen,_that.links,_that.portalPairs,_that.rotators);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int gates,  int frozen,  int links,  int portalPairs,  int rotators)?  $default,) {final _that = this;
switch (_that) {
case _MechanicMix() when $default != null:
return $default(_that.gates,_that.frozen,_that.links,_that.portalPairs,_that.rotators);case _:
  return null;

}
}

}

/// @nodoc


class _MechanicMix extends MechanicMix {
  const _MechanicMix({this.gates = 0, this.frozen = 0, this.links = 0, this.portalPairs = 0, this.rotators = 0}): super._();
  

/// Colour gates, each with its own key arrow (max 4, one per colour).
@override@JsonKey() final  int gates;
/// Frozen arrows.
@override@JsonKey() final  int frozen;
/// Linked pairs.
@override@JsonKey() final  int links;
/// Portal pairs.
@override@JsonKey() final  int portalPairs;
/// Rotators (single-cell arrows). Needs `singleCellShare > 0`.
@override@JsonKey() final  int rotators;

/// Create a copy of MechanicMix
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MechanicMixCopyWith<_MechanicMix> get copyWith => __$MechanicMixCopyWithImpl<_MechanicMix>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MechanicMix&&(identical(other.gates, gates) || other.gates == gates)&&(identical(other.frozen, frozen) || other.frozen == frozen)&&(identical(other.links, links) || other.links == links)&&(identical(other.portalPairs, portalPairs) || other.portalPairs == portalPairs)&&(identical(other.rotators, rotators) || other.rotators == rotators));
}


@override
int get hashCode {
    return Object.hash(runtimeType,gates,frozen,links,portalPairs,rotators);
}

@override
String toString() {
    return 'MechanicMix(gates: $gates, frozen: $frozen, links: $links, portalPairs: $portalPairs, rotators: $rotators)';
}


}

/// @nodoc
abstract mixin class _$MechanicMixCopyWith<$Res> implements $MechanicMixCopyWith<$Res> {
  factory _$MechanicMixCopyWith(_MechanicMix value, $Res Function(_MechanicMix) _then) = __$MechanicMixCopyWithImpl;
@override @useResult
$Res call({
 int gates, int frozen, int links, int portalPairs, int rotators
});




}
/// @nodoc
class __$MechanicMixCopyWithImpl<$Res>
    implements _$MechanicMixCopyWith<$Res> {
  __$MechanicMixCopyWithImpl(this._self, this._then);

  final _MechanicMix _self;
  final $Res Function(_MechanicMix) _then;

/// Create a copy of MechanicMix
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gates = null,Object? frozen = null,Object? links = null,Object? portalPairs = null,Object? rotators = null,}) {
  return _then(_MechanicMix(
gates: null == gates ? _self.gates : gates // ignore: cast_nullable_to_non_nullable
as int,frozen: null == frozen ? _self.frozen : frozen // ignore: cast_nullable_to_non_nullable
as int,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as int,portalPairs: null == portalPairs ? _self.portalPairs : portalPairs // ignore: cast_nullable_to_non_nullable
as int,rotators: null == rotators ? _self.rotators : rotators // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GenParams {

 int get width; int get height;/// `null` = full rectangle; else `height` strings of `width` 0/1 chars.
 List<String>? get mask;/// Stop when occupied / playable cells reaches this (0.55–0.92).
 double get targetFill;/// Body length range, in cells.
 int get lenMin; int get lenMax;/// Length distribution: 0 uniform, `n > 0` favours short bodies (min of
/// `n + 1` draws), `n < 0` favours long ones (max of `|n| + 1` draws).
 int get lenSkew;/// Chance an arrow is a single cell (needed for rotators); the other
/// arrows keep the `lenMin`–`lenMax` range.
 double get singleCellShare;/// Probability that a body turns at each step (0 straight … 1 random).
 double get windiness;/// Chance a new head is drawn towards the board centre.
 double get centerBias;/// Chance a new head is drawn next to existing arrows.
 double get clusterBias;/// Chance a new head is the innermost of a handful of candidates, so the
/// board is built from the middle outwards. Late arrows then sit near the
/// edge where their exit ray is still free, which is what lets the fill
/// reach 0.9+ while staying solvable.
 double get peelBias;/// Consecutive-ish placement failures before giving up.
 int get maxFailures;/// Hard cap on the number of arrows (onboarding levels), or `null`.
 int? get maxArrows; MechanicMix get mix; int get hearts;/// Accepted `trapRatio` band for rotator levels.
 double get trapMin; double get trapMax;/// Rotator generate-and-test: attempts per level and search budget.
 int get rotatorTries; int get searchStateLimit;
/// Create a copy of GenParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenParamsCopyWith<GenParams> get copyWith => _$GenParamsCopyWithImpl<GenParams>(this as GenParams, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GenParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenParams&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&const DeepCollectionEquality().equals(other.mask, _this.mask)&&(identical(other.targetFill, _this.targetFill) || other.targetFill == _this.targetFill)&&(identical(other.lenMin, _this.lenMin) || other.lenMin == _this.lenMin)&&(identical(other.lenMax, _this.lenMax) || other.lenMax == _this.lenMax)&&(identical(other.lenSkew, _this.lenSkew) || other.lenSkew == _this.lenSkew)&&(identical(other.singleCellShare, _this.singleCellShare) || other.singleCellShare == _this.singleCellShare)&&(identical(other.windiness, _this.windiness) || other.windiness == _this.windiness)&&(identical(other.centerBias, _this.centerBias) || other.centerBias == _this.centerBias)&&(identical(other.clusterBias, _this.clusterBias) || other.clusterBias == _this.clusterBias)&&(identical(other.peelBias, _this.peelBias) || other.peelBias == _this.peelBias)&&(identical(other.maxFailures, _this.maxFailures) || other.maxFailures == _this.maxFailures)&&(identical(other.maxArrows, _this.maxArrows) || other.maxArrows == _this.maxArrows)&&(identical(other.mix, _this.mix) || other.mix == _this.mix)&&(identical(other.hearts, _this.hearts) || other.hearts == _this.hearts)&&(identical(other.trapMin, _this.trapMin) || other.trapMin == _this.trapMin)&&(identical(other.trapMax, _this.trapMax) || other.trapMax == _this.trapMax)&&(identical(other.rotatorTries, _this.rotatorTries) || other.rotatorTries == _this.rotatorTries)&&(identical(other.searchStateLimit, _this.searchStateLimit) || other.searchStateLimit == _this.searchStateLimit));
}


@override
int get hashCode {
  final _this = this as GenParams;
  return Object.hashAll([runtimeType,_this.width,_this.height,const DeepCollectionEquality().hash(_this.mask),_this.targetFill,_this.lenMin,_this.lenMax,_this.lenSkew,_this.singleCellShare,_this.windiness,_this.centerBias,_this.clusterBias,_this.peelBias,_this.maxFailures,_this.maxArrows,_this.mix,_this.hearts,_this.trapMin,_this.trapMax,_this.rotatorTries,_this.searchStateLimit]);
}

@override
String toString() {
  final _this = this as GenParams;
  return 'GenParams(width: ${_this.width}, height: ${_this.height}, mask: ${_this.mask}, targetFill: ${_this.targetFill}, lenMin: ${_this.lenMin}, lenMax: ${_this.lenMax}, lenSkew: ${_this.lenSkew}, singleCellShare: ${_this.singleCellShare}, windiness: ${_this.windiness}, centerBias: ${_this.centerBias}, clusterBias: ${_this.clusterBias}, peelBias: ${_this.peelBias}, maxFailures: ${_this.maxFailures}, maxArrows: ${_this.maxArrows}, mix: ${_this.mix}, hearts: ${_this.hearts}, trapMin: ${_this.trapMin}, trapMax: ${_this.trapMax}, rotatorTries: ${_this.rotatorTries}, searchStateLimit: ${_this.searchStateLimit})';
}


}

/// @nodoc
abstract mixin class $GenParamsCopyWith<$Res>  {
  factory $GenParamsCopyWith(GenParams value, $Res Function(GenParams) _then) = _$GenParamsCopyWithImpl;
@useResult
$Res call({
 int width, int height, List<String>? mask, double targetFill, int lenMin, int lenMax, int lenSkew, double singleCellShare, double windiness, double centerBias, double clusterBias, double peelBias, int maxFailures, int? maxArrows, MechanicMix mix, int hearts, double trapMin, double trapMax, int rotatorTries, int searchStateLimit
});


$MechanicMixCopyWith<$Res> get mix;

}
/// @nodoc
class _$GenParamsCopyWithImpl<$Res>
    implements $GenParamsCopyWith<$Res> {
  _$GenParamsCopyWithImpl(this._self, this._then);

  final GenParams _self;
  final $Res Function(GenParams) _then;

/// Create a copy of GenParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? mask = freezed,Object? targetFill = null,Object? lenMin = null,Object? lenMax = null,Object? lenSkew = null,Object? singleCellShare = null,Object? windiness = null,Object? centerBias = null,Object? clusterBias = null,Object? peelBias = null,Object? maxFailures = null,Object? maxArrows = freezed,Object? mix = null,Object? hearts = null,Object? trapMin = null,Object? trapMax = null,Object? rotatorTries = null,Object? searchStateLimit = null,}) {
  return _then(GenParams(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,mask: freezed == mask ? _self.mask : mask // ignore: cast_nullable_to_non_nullable
as List<String>?,targetFill: null == targetFill ? _self.targetFill : targetFill // ignore: cast_nullable_to_non_nullable
as double,lenMin: null == lenMin ? _self.lenMin : lenMin // ignore: cast_nullable_to_non_nullable
as int,lenMax: null == lenMax ? _self.lenMax : lenMax // ignore: cast_nullable_to_non_nullable
as int,lenSkew: null == lenSkew ? _self.lenSkew : lenSkew // ignore: cast_nullable_to_non_nullable
as int,singleCellShare: null == singleCellShare ? _self.singleCellShare : singleCellShare // ignore: cast_nullable_to_non_nullable
as double,windiness: null == windiness ? _self.windiness : windiness // ignore: cast_nullable_to_non_nullable
as double,centerBias: null == centerBias ? _self.centerBias : centerBias // ignore: cast_nullable_to_non_nullable
as double,clusterBias: null == clusterBias ? _self.clusterBias : clusterBias // ignore: cast_nullable_to_non_nullable
as double,peelBias: null == peelBias ? _self.peelBias : peelBias // ignore: cast_nullable_to_non_nullable
as double,maxFailures: null == maxFailures ? _self.maxFailures : maxFailures // ignore: cast_nullable_to_non_nullable
as int,maxArrows: freezed == maxArrows ? _self.maxArrows : maxArrows // ignore: cast_nullable_to_non_nullable
as int?,mix: null == mix ? _self.mix : mix // ignore: cast_nullable_to_non_nullable
as MechanicMix,hearts: null == hearts ? _self.hearts : hearts // ignore: cast_nullable_to_non_nullable
as int,trapMin: null == trapMin ? _self.trapMin : trapMin // ignore: cast_nullable_to_non_nullable
as double,trapMax: null == trapMax ? _self.trapMax : trapMax // ignore: cast_nullable_to_non_nullable
as double,rotatorTries: null == rotatorTries ? _self.rotatorTries : rotatorTries // ignore: cast_nullable_to_non_nullable
as int,searchStateLimit: null == searchStateLimit ? _self.searchStateLimit : searchStateLimit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of GenParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MechanicMixCopyWith<$Res> get mix {
  
  return $MechanicMixCopyWith<$Res>(_self.mix, (value) {
    return _then(_self.copyWith(mix: value));
  });
}
}


/// Adds pattern-matching-related methods to [GenParams].
extension GenParamsPatterns on GenParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenParams value)  $default,){
final _that = this;
switch (_that) {
case _GenParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenParams value)?  $default,){
final _that = this;
switch (_that) {
case _GenParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int width,  int height,  List<String>? mask,  double targetFill,  int lenMin,  int lenMax,  int lenSkew,  double singleCellShare,  double windiness,  double centerBias,  double clusterBias,  double peelBias,  int maxFailures,  int? maxArrows,  MechanicMix mix,  int hearts,  double trapMin,  double trapMax,  int rotatorTries,  int searchStateLimit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenParams() when $default != null:
return $default(_that.width,_that.height,_that.mask,_that.targetFill,_that.lenMin,_that.lenMax,_that.lenSkew,_that.singleCellShare,_that.windiness,_that.centerBias,_that.clusterBias,_that.peelBias,_that.maxFailures,_that.maxArrows,_that.mix,_that.hearts,_that.trapMin,_that.trapMax,_that.rotatorTries,_that.searchStateLimit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int width,  int height,  List<String>? mask,  double targetFill,  int lenMin,  int lenMax,  int lenSkew,  double singleCellShare,  double windiness,  double centerBias,  double clusterBias,  double peelBias,  int maxFailures,  int? maxArrows,  MechanicMix mix,  int hearts,  double trapMin,  double trapMax,  int rotatorTries,  int searchStateLimit)  $default,) {final _that = this;
switch (_that) {
case _GenParams():
return $default(_that.width,_that.height,_that.mask,_that.targetFill,_that.lenMin,_that.lenMax,_that.lenSkew,_that.singleCellShare,_that.windiness,_that.centerBias,_that.clusterBias,_that.peelBias,_that.maxFailures,_that.maxArrows,_that.mix,_that.hearts,_that.trapMin,_that.trapMax,_that.rotatorTries,_that.searchStateLimit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int width,  int height,  List<String>? mask,  double targetFill,  int lenMin,  int lenMax,  int lenSkew,  double singleCellShare,  double windiness,  double centerBias,  double clusterBias,  double peelBias,  int maxFailures,  int? maxArrows,  MechanicMix mix,  int hearts,  double trapMin,  double trapMax,  int rotatorTries,  int searchStateLimit)?  $default,) {final _that = this;
switch (_that) {
case _GenParams() when $default != null:
return $default(_that.width,_that.height,_that.mask,_that.targetFill,_that.lenMin,_that.lenMax,_that.lenSkew,_that.singleCellShare,_that.windiness,_that.centerBias,_that.clusterBias,_that.peelBias,_that.maxFailures,_that.maxArrows,_that.mix,_that.hearts,_that.trapMin,_that.trapMax,_that.rotatorTries,_that.searchStateLimit);case _:
  return null;

}
}

}

/// @nodoc


class _GenParams implements GenParams {
  const _GenParams({required this.width, required this.height,  List<String>? mask, this.targetFill = 0.7, this.lenMin = 2, this.lenMax = 6, this.lenSkew = 0, this.singleCellShare = 0.0, this.windiness = 0.4, this.centerBias = 0.3, this.clusterBias = 0.5, this.peelBias = 0.0, this.maxFailures = 800, this.maxArrows, this.mix = MechanicMix.none, this.hearts = 3, this.trapMin = 0.0, this.trapMax = 0.5, this.rotatorTries = 200, this.searchStateLimit = 20000}): _mask = mask;
  

@override final  int width;
@override final  int height;
/// `null` = full rectangle; else `height` strings of `width` 0/1 chars.
 final  List<String>? _mask;
/// `null` = full rectangle; else `height` strings of `width` 0/1 chars.
@override List<String>? get mask {
  final value = _mask;
  if (value == null) return null;
  if (_mask is EqualUnmodifiableListView) return _mask;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Stop when occupied / playable cells reaches this (0.55–0.92).
@override@JsonKey() final  double targetFill;
/// Body length range, in cells.
@override@JsonKey() final  int lenMin;
@override@JsonKey() final  int lenMax;
/// Length distribution: 0 uniform, `n > 0` favours short bodies (min of
/// `n + 1` draws), `n < 0` favours long ones (max of `|n| + 1` draws).
@override@JsonKey() final  int lenSkew;
/// Chance an arrow is a single cell (needed for rotators); the other
/// arrows keep the `lenMin`–`lenMax` range.
@override@JsonKey() final  double singleCellShare;
/// Probability that a body turns at each step (0 straight … 1 random).
@override@JsonKey() final  double windiness;
/// Chance a new head is drawn towards the board centre.
@override@JsonKey() final  double centerBias;
/// Chance a new head is drawn next to existing arrows.
@override@JsonKey() final  double clusterBias;
/// Chance a new head is the innermost of a handful of candidates, so the
/// board is built from the middle outwards. Late arrows then sit near the
/// edge where their exit ray is still free, which is what lets the fill
/// reach 0.9+ while staying solvable.
@override@JsonKey() final  double peelBias;
/// Consecutive-ish placement failures before giving up.
@override@JsonKey() final  int maxFailures;
/// Hard cap on the number of arrows (onboarding levels), or `null`.
@override final  int? maxArrows;
@override@JsonKey() final  MechanicMix mix;
@override@JsonKey() final  int hearts;
/// Accepted `trapRatio` band for rotator levels.
@override@JsonKey() final  double trapMin;
@override@JsonKey() final  double trapMax;
/// Rotator generate-and-test: attempts per level and search budget.
@override@JsonKey() final  int rotatorTries;
@override@JsonKey() final  int searchStateLimit;

/// Create a copy of GenParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenParamsCopyWith<_GenParams> get copyWith => __$GenParamsCopyWithImpl<_GenParams>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenParams&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other.mask, _mask)&&(identical(other.targetFill, targetFill) || other.targetFill == targetFill)&&(identical(other.lenMin, lenMin) || other.lenMin == lenMin)&&(identical(other.lenMax, lenMax) || other.lenMax == lenMax)&&(identical(other.lenSkew, lenSkew) || other.lenSkew == lenSkew)&&(identical(other.singleCellShare, singleCellShare) || other.singleCellShare == singleCellShare)&&(identical(other.windiness, windiness) || other.windiness == windiness)&&(identical(other.centerBias, centerBias) || other.centerBias == centerBias)&&(identical(other.clusterBias, clusterBias) || other.clusterBias == clusterBias)&&(identical(other.peelBias, peelBias) || other.peelBias == peelBias)&&(identical(other.maxFailures, maxFailures) || other.maxFailures == maxFailures)&&(identical(other.maxArrows, maxArrows) || other.maxArrows == maxArrows)&&(identical(other.mix, mix) || other.mix == mix)&&(identical(other.hearts, hearts) || other.hearts == hearts)&&(identical(other.trapMin, trapMin) || other.trapMin == trapMin)&&(identical(other.trapMax, trapMax) || other.trapMax == trapMax)&&(identical(other.rotatorTries, rotatorTries) || other.rotatorTries == rotatorTries)&&(identical(other.searchStateLimit, searchStateLimit) || other.searchStateLimit == searchStateLimit));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,width,height,const DeepCollectionEquality().hash(_mask),targetFill,lenMin,lenMax,lenSkew,singleCellShare,windiness,centerBias,clusterBias,peelBias,maxFailures,maxArrows,mix,hearts,trapMin,trapMax,rotatorTries,searchStateLimit]);
}

@override
String toString() {
    return 'GenParams(width: $width, height: $height, mask: $mask, targetFill: $targetFill, lenMin: $lenMin, lenMax: $lenMax, lenSkew: $lenSkew, singleCellShare: $singleCellShare, windiness: $windiness, centerBias: $centerBias, clusterBias: $clusterBias, peelBias: $peelBias, maxFailures: $maxFailures, maxArrows: $maxArrows, mix: $mix, hearts: $hearts, trapMin: $trapMin, trapMax: $trapMax, rotatorTries: $rotatorTries, searchStateLimit: $searchStateLimit)';
}


}

/// @nodoc
abstract mixin class _$GenParamsCopyWith<$Res> implements $GenParamsCopyWith<$Res> {
  factory _$GenParamsCopyWith(_GenParams value, $Res Function(_GenParams) _then) = __$GenParamsCopyWithImpl;
@override @useResult
$Res call({
 int width, int height, List<String>? mask, double targetFill, int lenMin, int lenMax, int lenSkew, double singleCellShare, double windiness, double centerBias, double clusterBias, double peelBias, int maxFailures, int? maxArrows, MechanicMix mix, int hearts, double trapMin, double trapMax, int rotatorTries, int searchStateLimit
});


@override $MechanicMixCopyWith<$Res> get mix;

}
/// @nodoc
class __$GenParamsCopyWithImpl<$Res>
    implements _$GenParamsCopyWith<$Res> {
  __$GenParamsCopyWithImpl(this._self, this._then);

  final _GenParams _self;
  final $Res Function(_GenParams) _then;

/// Create a copy of GenParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? mask = freezed,Object? targetFill = null,Object? lenMin = null,Object? lenMax = null,Object? lenSkew = null,Object? singleCellShare = null,Object? windiness = null,Object? centerBias = null,Object? clusterBias = null,Object? peelBias = null,Object? maxFailures = null,Object? maxArrows = freezed,Object? mix = null,Object? hearts = null,Object? trapMin = null,Object? trapMax = null,Object? rotatorTries = null,Object? searchStateLimit = null,}) {
  return _then(_GenParams(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,mask: freezed == mask ? _self._mask : mask // ignore: cast_nullable_to_non_nullable
as List<String>?,targetFill: null == targetFill ? _self.targetFill : targetFill // ignore: cast_nullable_to_non_nullable
as double,lenMin: null == lenMin ? _self.lenMin : lenMin // ignore: cast_nullable_to_non_nullable
as int,lenMax: null == lenMax ? _self.lenMax : lenMax // ignore: cast_nullable_to_non_nullable
as int,lenSkew: null == lenSkew ? _self.lenSkew : lenSkew // ignore: cast_nullable_to_non_nullable
as int,singleCellShare: null == singleCellShare ? _self.singleCellShare : singleCellShare // ignore: cast_nullable_to_non_nullable
as double,windiness: null == windiness ? _self.windiness : windiness // ignore: cast_nullable_to_non_nullable
as double,centerBias: null == centerBias ? _self.centerBias : centerBias // ignore: cast_nullable_to_non_nullable
as double,clusterBias: null == clusterBias ? _self.clusterBias : clusterBias // ignore: cast_nullable_to_non_nullable
as double,peelBias: null == peelBias ? _self.peelBias : peelBias // ignore: cast_nullable_to_non_nullable
as double,maxFailures: null == maxFailures ? _self.maxFailures : maxFailures // ignore: cast_nullable_to_non_nullable
as int,maxArrows: freezed == maxArrows ? _self.maxArrows : maxArrows // ignore: cast_nullable_to_non_nullable
as int?,mix: null == mix ? _self.mix : mix // ignore: cast_nullable_to_non_nullable
as MechanicMix,hearts: null == hearts ? _self.hearts : hearts // ignore: cast_nullable_to_non_nullable
as int,trapMin: null == trapMin ? _self.trapMin : trapMin // ignore: cast_nullable_to_non_nullable
as double,trapMax: null == trapMax ? _self.trapMax : trapMax // ignore: cast_nullable_to_non_nullable
as double,rotatorTries: null == rotatorTries ? _self.rotatorTries : rotatorTries // ignore: cast_nullable_to_non_nullable
as int,searchStateLimit: null == searchStateLimit ? _self.searchStateLimit : searchStateLimit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of GenParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MechanicMixCopyWith<$Res> get mix {
  
  return $MechanicMixCopyWith<$Res>(_self.mix, (value) {
    return _then(_self.copyWith(mix: value));
  });
}
}

// dart format on
