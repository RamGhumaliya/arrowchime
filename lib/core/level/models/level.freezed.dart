// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'level.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LevelMeta {

 int? get seed; String? get generatorVersion;/// 0–100, or `null` = "compute me".
 double? get difficulty; int? get depth;/// Arrow ids in a valid removal order (linked pairs: first id only).
 List<int> get solution; String? get melody; bool? get approved;
/// Create a copy of LevelMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelMetaCopyWith<LevelMeta> get copyWith => _$LevelMetaCopyWithImpl<LevelMeta>(this as LevelMeta, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LevelMeta;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelMeta&&(identical(other.seed, _this.seed) || other.seed == _this.seed)&&(identical(other.generatorVersion, _this.generatorVersion) || other.generatorVersion == _this.generatorVersion)&&(identical(other.difficulty, _this.difficulty) || other.difficulty == _this.difficulty)&&(identical(other.depth, _this.depth) || other.depth == _this.depth)&&const DeepCollectionEquality().equals(other.solution, _this.solution)&&(identical(other.melody, _this.melody) || other.melody == _this.melody)&&(identical(other.approved, _this.approved) || other.approved == _this.approved));
}


@override
int get hashCode {
  final _this = this as LevelMeta;
  return Object.hash(runtimeType,_this.seed,_this.generatorVersion,_this.difficulty,_this.depth,const DeepCollectionEquality().hash(_this.solution),_this.melody,_this.approved);
}

@override
String toString() {
  final _this = this as LevelMeta;
  return 'LevelMeta(seed: ${_this.seed}, generatorVersion: ${_this.generatorVersion}, difficulty: ${_this.difficulty}, depth: ${_this.depth}, solution: ${_this.solution}, melody: ${_this.melody}, approved: ${_this.approved})';
}


}

/// @nodoc
abstract mixin class $LevelMetaCopyWith<$Res>  {
  factory $LevelMetaCopyWith(LevelMeta value, $Res Function(LevelMeta) _then) = _$LevelMetaCopyWithImpl;
@useResult
$Res call({
 int? seed, String? generatorVersion, double? difficulty, int? depth, List<int> solution, String? melody, bool? approved
});




}
/// @nodoc
class _$LevelMetaCopyWithImpl<$Res>
    implements $LevelMetaCopyWith<$Res> {
  _$LevelMetaCopyWithImpl(this._self, this._then);

  final LevelMeta _self;
  final $Res Function(LevelMeta) _then;

/// Create a copy of LevelMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seed = freezed,Object? generatorVersion = freezed,Object? difficulty = freezed,Object? depth = freezed,Object? solution = null,Object? melody = freezed,Object? approved = freezed,}) {
  return _then(LevelMeta(
seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int?,generatorVersion: freezed == generatorVersion ? _self.generatorVersion : generatorVersion // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double?,depth: freezed == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int?,solution: null == solution ? _self.solution : solution // ignore: cast_nullable_to_non_nullable
as List<int>,melody: freezed == melody ? _self.melody : melody // ignore: cast_nullable_to_non_nullable
as String?,approved: freezed == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [LevelMeta].
extension LevelMetaPatterns on LevelMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelMeta value)  $default,){
final _that = this;
switch (_that) {
case _LevelMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelMeta value)?  $default,){
final _that = this;
switch (_that) {
case _LevelMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? seed,  String? generatorVersion,  double? difficulty,  int? depth,  List<int> solution,  String? melody,  bool? approved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelMeta() when $default != null:
return $default(_that.seed,_that.generatorVersion,_that.difficulty,_that.depth,_that.solution,_that.melody,_that.approved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? seed,  String? generatorVersion,  double? difficulty,  int? depth,  List<int> solution,  String? melody,  bool? approved)  $default,) {final _that = this;
switch (_that) {
case _LevelMeta():
return $default(_that.seed,_that.generatorVersion,_that.difficulty,_that.depth,_that.solution,_that.melody,_that.approved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? seed,  String? generatorVersion,  double? difficulty,  int? depth,  List<int> solution,  String? melody,  bool? approved)?  $default,) {final _that = this;
switch (_that) {
case _LevelMeta() when $default != null:
return $default(_that.seed,_that.generatorVersion,_that.difficulty,_that.depth,_that.solution,_that.melody,_that.approved);case _:
  return null;

}
}

}

/// @nodoc


class _LevelMeta extends LevelMeta {
  const _LevelMeta({this.seed, this.generatorVersion, this.difficulty, this.depth, this.solution = const <int>[], this.melody, this.approved}): super._();
  

@override final  int? seed;
@override final  String? generatorVersion;
/// 0–100, or `null` = "compute me".
@override final  double? difficulty;
@override final  int? depth;
/// Arrow ids in a valid removal order (linked pairs: first id only).
@override@JsonKey() final  List<int> solution;
@override final  String? melody;
@override final  bool? approved;

/// Create a copy of LevelMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelMetaCopyWith<_LevelMeta> get copyWith => __$LevelMetaCopyWithImpl<_LevelMeta>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelMeta&&(identical(other.seed, seed) || other.seed == seed)&&(identical(other.generatorVersion, generatorVersion) || other.generatorVersion == generatorVersion)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.depth, depth) || other.depth == depth)&&const DeepCollectionEquality().equals(other.solution, solution)&&(identical(other.melody, melody) || other.melody == melody)&&(identical(other.approved, approved) || other.approved == approved));
}


@override
int get hashCode {
    return Object.hash(runtimeType,seed,generatorVersion,difficulty,depth,const DeepCollectionEquality().hash(solution),melody,approved);
}

@override
String toString() {
    return 'LevelMeta(seed: $seed, generatorVersion: $generatorVersion, difficulty: $difficulty, depth: $depth, solution: $solution, melody: $melody, approved: $approved)';
}


}

/// @nodoc
abstract mixin class _$LevelMetaCopyWith<$Res> implements $LevelMetaCopyWith<$Res> {
  factory _$LevelMetaCopyWith(_LevelMeta value, $Res Function(_LevelMeta) _then) = __$LevelMetaCopyWithImpl;
@override @useResult
$Res call({
 int? seed, String? generatorVersion, double? difficulty, int? depth, List<int> solution, String? melody, bool? approved
});




}
/// @nodoc
class __$LevelMetaCopyWithImpl<$Res>
    implements _$LevelMetaCopyWith<$Res> {
  __$LevelMetaCopyWithImpl(this._self, this._then);

  final _LevelMeta _self;
  final $Res Function(_LevelMeta) _then;

/// Create a copy of LevelMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seed = freezed,Object? generatorVersion = freezed,Object? difficulty = freezed,Object? depth = freezed,Object? solution = null,Object? melody = freezed,Object? approved = freezed,}) {
  return _then(_LevelMeta(
seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int?,generatorVersion: freezed == generatorVersion ? _self.generatorVersion : generatorVersion // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double?,depth: freezed == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int?,solution: null == solution ? _self.solution : solution // ignore: cast_nullable_to_non_nullable
as List<int>,melody: freezed == melody ? _self.melody : melody // ignore: cast_nullable_to_non_nullable
as String?,approved: freezed == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$Level {

 String get id; int get width; int get height; List<Arrow> get arrows; int? get chapter; int? get index;/// `null` = full rectangle; else `height` strings of length `width`
/// (`'1'` cell, `'0'` void).
 List<String>? get mask; int get hearts; List<Gate> get gates; List<Portal> get portals; LevelMeta get meta;
/// Create a copy of Level
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelCopyWith<Level> get copyWith => _$LevelCopyWithImpl<Level>(this as Level, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Level;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Level&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&const DeepCollectionEquality().equals(other.arrows, _this.arrows)&&(identical(other.chapter, _this.chapter) || other.chapter == _this.chapter)&&(identical(other.index, _this.index) || other.index == _this.index)&&const DeepCollectionEquality().equals(other.mask, _this.mask)&&(identical(other.hearts, _this.hearts) || other.hearts == _this.hearts)&&const DeepCollectionEquality().equals(other.gates, _this.gates)&&const DeepCollectionEquality().equals(other.portals, _this.portals)&&(identical(other.meta, _this.meta) || other.meta == _this.meta));
}


@override
int get hashCode {
  final _this = this as Level;
  return Object.hash(runtimeType,_this.id,_this.width,_this.height,const DeepCollectionEquality().hash(_this.arrows),_this.chapter,_this.index,const DeepCollectionEquality().hash(_this.mask),_this.hearts,const DeepCollectionEquality().hash(_this.gates),const DeepCollectionEquality().hash(_this.portals),_this.meta);
}

@override
String toString() {
  final _this = this as Level;
  return 'Level(id: ${_this.id}, width: ${_this.width}, height: ${_this.height}, arrows: ${_this.arrows}, chapter: ${_this.chapter}, index: ${_this.index}, mask: ${_this.mask}, hearts: ${_this.hearts}, gates: ${_this.gates}, portals: ${_this.portals}, meta: ${_this.meta})';
}


}

/// @nodoc
abstract mixin class $LevelCopyWith<$Res>  {
  factory $LevelCopyWith(Level value, $Res Function(Level) _then) = _$LevelCopyWithImpl;
@useResult
$Res call({
 String id, int width, int height, List<Arrow> arrows, int? chapter, int? index, List<String>? mask, int hearts, List<Gate> gates, List<Portal> portals, LevelMeta meta
});


$LevelMetaCopyWith<$Res> get meta;

}
/// @nodoc
class _$LevelCopyWithImpl<$Res>
    implements $LevelCopyWith<$Res> {
  _$LevelCopyWithImpl(this._self, this._then);

  final Level _self;
  final $Res Function(Level) _then;

/// Create a copy of Level
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? width = null,Object? height = null,Object? arrows = null,Object? chapter = freezed,Object? index = freezed,Object? mask = freezed,Object? hearts = null,Object? gates = null,Object? portals = null,Object? meta = null,}) {
  return _then(Level(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,arrows: null == arrows ? _self.arrows : arrows // ignore: cast_nullable_to_non_nullable
as List<Arrow>,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,mask: freezed == mask ? _self.mask : mask // ignore: cast_nullable_to_non_nullable
as List<String>?,hearts: null == hearts ? _self.hearts : hearts // ignore: cast_nullable_to_non_nullable
as int,gates: null == gates ? _self.gates : gates // ignore: cast_nullable_to_non_nullable
as List<Gate>,portals: null == portals ? _self.portals : portals // ignore: cast_nullable_to_non_nullable
as List<Portal>,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as LevelMeta,
  ));
}
/// Create a copy of Level
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LevelMetaCopyWith<$Res> get meta {
  
  return $LevelMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [Level].
extension LevelPatterns on Level {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Level value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Level() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Level value)  $default,){
final _that = this;
switch (_that) {
case _Level():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Level value)?  $default,){
final _that = this;
switch (_that) {
case _Level() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int width,  int height,  List<Arrow> arrows,  int? chapter,  int? index,  List<String>? mask,  int hearts,  List<Gate> gates,  List<Portal> portals,  LevelMeta meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Level() when $default != null:
return $default(_that.id,_that.width,_that.height,_that.arrows,_that.chapter,_that.index,_that.mask,_that.hearts,_that.gates,_that.portals,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int width,  int height,  List<Arrow> arrows,  int? chapter,  int? index,  List<String>? mask,  int hearts,  List<Gate> gates,  List<Portal> portals,  LevelMeta meta)  $default,) {final _that = this;
switch (_that) {
case _Level():
return $default(_that.id,_that.width,_that.height,_that.arrows,_that.chapter,_that.index,_that.mask,_that.hearts,_that.gates,_that.portals,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int width,  int height,  List<Arrow> arrows,  int? chapter,  int? index,  List<String>? mask,  int hearts,  List<Gate> gates,  List<Portal> portals,  LevelMeta meta)?  $default,) {final _that = this;
switch (_that) {
case _Level() when $default != null:
return $default(_that.id,_that.width,_that.height,_that.arrows,_that.chapter,_that.index,_that.mask,_that.hearts,_that.gates,_that.portals,_that.meta);case _:
  return null;

}
}

}

/// @nodoc


class _Level extends Level {
  const _Level({required this.id, required this.width, required this.height, required this.arrows, this.chapter, this.index, this.mask, this.hearts = 3, this.gates = const <Gate>[], this.portals = const <Portal>[], this.meta = const LevelMeta()}): super._();
  

@override final  String id;
@override final  int width;
@override final  int height;
@override final  List<Arrow> arrows;
@override final  int? chapter;
@override final  int? index;
/// `null` = full rectangle; else `height` strings of length `width`
/// (`'1'` cell, `'0'` void).
@override final  List<String>? mask;
@override@JsonKey() final  int hearts;
@override@JsonKey() final  List<Gate> gates;
@override@JsonKey() final  List<Portal> portals;
@override@JsonKey() final  LevelMeta meta;

/// Create a copy of Level
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelCopyWith<_Level> get copyWith => __$LevelCopyWithImpl<_Level>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Level&&(identical(other.id, id) || other.id == id)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&const DeepCollectionEquality().equals(other.arrows, arrows)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.mask, mask)&&(identical(other.hearts, hearts) || other.hearts == hearts)&&const DeepCollectionEquality().equals(other.gates, gates)&&const DeepCollectionEquality().equals(other.portals, portals)&&(identical(other.meta, meta) || other.meta == meta));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,width,height,const DeepCollectionEquality().hash(arrows),chapter,index,const DeepCollectionEquality().hash(mask),hearts,const DeepCollectionEquality().hash(gates),const DeepCollectionEquality().hash(portals),meta);
}

@override
String toString() {
    return 'Level(id: $id, width: $width, height: $height, arrows: $arrows, chapter: $chapter, index: $index, mask: $mask, hearts: $hearts, gates: $gates, portals: $portals, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$LevelCopyWith<$Res> implements $LevelCopyWith<$Res> {
  factory _$LevelCopyWith(_Level value, $Res Function(_Level) _then) = __$LevelCopyWithImpl;
@override @useResult
$Res call({
 String id, int width, int height, List<Arrow> arrows, int? chapter, int? index, List<String>? mask, int hearts, List<Gate> gates, List<Portal> portals, LevelMeta meta
});


@override $LevelMetaCopyWith<$Res> get meta;

}
/// @nodoc
class __$LevelCopyWithImpl<$Res>
    implements _$LevelCopyWith<$Res> {
  __$LevelCopyWithImpl(this._self, this._then);

  final _Level _self;
  final $Res Function(_Level) _then;

/// Create a copy of Level
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? width = null,Object? height = null,Object? arrows = null,Object? chapter = freezed,Object? index = freezed,Object? mask = freezed,Object? hearts = null,Object? gates = null,Object? portals = null,Object? meta = null,}) {
  return _then(_Level(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,arrows: null == arrows ? _self.arrows : arrows // ignore: cast_nullable_to_non_nullable
as List<Arrow>,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int?,index: freezed == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int?,mask: freezed == mask ? _self.mask : mask // ignore: cast_nullable_to_non_nullable
as List<String>?,hearts: null == hearts ? _self.hearts : hearts // ignore: cast_nullable_to_non_nullable
as int,gates: null == gates ? _self.gates : gates // ignore: cast_nullable_to_non_nullable
as List<Gate>,portals: null == portals ? _self.portals : portals // ignore: cast_nullable_to_non_nullable
as List<Portal>,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as LevelMeta,
  ));
}

/// Create a copy of Level
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LevelMetaCopyWith<$Res> get meta {
  
  return $LevelMetaCopyWith<$Res>(_self.meta, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}

/// @nodoc
mixin _$LevelPack {

 List<Level> get levels; int? get chapter;
/// Create a copy of LevelPack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LevelPackCopyWith<LevelPack> get copyWith => _$LevelPackCopyWithImpl<LevelPack>(this as LevelPack, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LevelPack;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LevelPack&&const DeepCollectionEquality().equals(other.levels, _this.levels)&&(identical(other.chapter, _this.chapter) || other.chapter == _this.chapter));
}


@override
int get hashCode {
  final _this = this as LevelPack;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.levels),_this.chapter);
}

@override
String toString() {
  final _this = this as LevelPack;
  return 'LevelPack(levels: ${_this.levels}, chapter: ${_this.chapter})';
}


}

/// @nodoc
abstract mixin class $LevelPackCopyWith<$Res>  {
  factory $LevelPackCopyWith(LevelPack value, $Res Function(LevelPack) _then) = _$LevelPackCopyWithImpl;
@useResult
$Res call({
 List<Level> levels, int? chapter
});




}
/// @nodoc
class _$LevelPackCopyWithImpl<$Res>
    implements $LevelPackCopyWith<$Res> {
  _$LevelPackCopyWithImpl(this._self, this._then);

  final LevelPack _self;
  final $Res Function(LevelPack) _then;

/// Create a copy of LevelPack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? levels = null,Object? chapter = freezed,}) {
  return _then(LevelPack(
levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as List<Level>,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LevelPack].
extension LevelPackPatterns on LevelPack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LevelPack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LevelPack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LevelPack value)  $default,){
final _that = this;
switch (_that) {
case _LevelPack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LevelPack value)?  $default,){
final _that = this;
switch (_that) {
case _LevelPack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Level> levels,  int? chapter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LevelPack() when $default != null:
return $default(_that.levels,_that.chapter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Level> levels,  int? chapter)  $default,) {final _that = this;
switch (_that) {
case _LevelPack():
return $default(_that.levels,_that.chapter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Level> levels,  int? chapter)?  $default,) {final _that = this;
switch (_that) {
case _LevelPack() when $default != null:
return $default(_that.levels,_that.chapter);case _:
  return null;

}
}

}

/// @nodoc


class _LevelPack extends LevelPack {
  const _LevelPack({required this.levels, this.chapter}): super._();
  

@override final  List<Level> levels;
@override final  int? chapter;

/// Create a copy of LevelPack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LevelPackCopyWith<_LevelPack> get copyWith => __$LevelPackCopyWithImpl<_LevelPack>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LevelPack&&const DeepCollectionEquality().equals(other.levels, levels)&&(identical(other.chapter, chapter) || other.chapter == chapter));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(levels),chapter);
}

@override
String toString() {
    return 'LevelPack(levels: $levels, chapter: $chapter)';
}


}

/// @nodoc
abstract mixin class _$LevelPackCopyWith<$Res> implements $LevelPackCopyWith<$Res> {
  factory _$LevelPackCopyWith(_LevelPack value, $Res Function(_LevelPack) _then) = __$LevelPackCopyWithImpl;
@override @useResult
$Res call({
 List<Level> levels, int? chapter
});




}
/// @nodoc
class __$LevelPackCopyWithImpl<$Res>
    implements _$LevelPackCopyWith<$Res> {
  __$LevelPackCopyWithImpl(this._self, this._then);

  final _LevelPack _self;
  final $Res Function(_LevelPack) _then;

/// Create a copy of LevelPack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? levels = null,Object? chapter = freezed,}) {
  return _then(_LevelPack(
levels: null == levels ? _self.levels : levels // ignore: cast_nullable_to_non_nullable
as List<Level>,chapter: freezed == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
