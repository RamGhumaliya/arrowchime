// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'save_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakState {

/// Days in a row with at least one level played.
 int get count; int get best;/// Local date of the last day played, or `''`.
 String get lastPlayed;/// Streak freezes in stock (one free per week, more for coins).
 int get freezes;/// ISO week (`2026-W41`) the free freeze was last granted.
 String get freezeWeek;
/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakStateCopyWith<StreakState> get copyWith => _$StreakStateCopyWithImpl<StreakState>(this as StreakState, _$identity);

  /// Serializes this StreakState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StreakState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakState&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.best, _this.best) || other.best == _this.best)&&(identical(other.lastPlayed, _this.lastPlayed) || other.lastPlayed == _this.lastPlayed)&&(identical(other.freezes, _this.freezes) || other.freezes == _this.freezes)&&(identical(other.freezeWeek, _this.freezeWeek) || other.freezeWeek == _this.freezeWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StreakState;
  return Object.hash(runtimeType,_this.count,_this.best,_this.lastPlayed,_this.freezes,_this.freezeWeek);
}

@override
String toString() {
  final _this = this as StreakState;
  return 'StreakState(count: ${_this.count}, best: ${_this.best}, lastPlayed: ${_this.lastPlayed}, freezes: ${_this.freezes}, freezeWeek: ${_this.freezeWeek})';
}


}

/// @nodoc
abstract mixin class $StreakStateCopyWith<$Res>  {
  factory $StreakStateCopyWith(StreakState value, $Res Function(StreakState) _then) = _$StreakStateCopyWithImpl;
@useResult
$Res call({
 int count, int best, String lastPlayed, int freezes, String freezeWeek
});




}
/// @nodoc
class _$StreakStateCopyWithImpl<$Res>
    implements $StreakStateCopyWith<$Res> {
  _$StreakStateCopyWithImpl(this._self, this._then);

  final StreakState _self;
  final $Res Function(StreakState) _then;

/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? best = null,Object? lastPlayed = null,Object? freezes = null,Object? freezeWeek = null,}) {
  return _then(StreakState(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,lastPlayed: null == lastPlayed ? _self.lastPlayed : lastPlayed // ignore: cast_nullable_to_non_nullable
as String,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,freezeWeek: null == freezeWeek ? _self.freezeWeek : freezeWeek // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakState].
extension StreakStatePatterns on StreakState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakState value)  $default,){
final _that = this;
switch (_that) {
case _StreakState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakState value)?  $default,){
final _that = this;
switch (_that) {
case _StreakState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  int best,  String lastPlayed,  int freezes,  String freezeWeek)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakState() when $default != null:
return $default(_that.count,_that.best,_that.lastPlayed,_that.freezes,_that.freezeWeek);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  int best,  String lastPlayed,  int freezes,  String freezeWeek)  $default,) {final _that = this;
switch (_that) {
case _StreakState():
return $default(_that.count,_that.best,_that.lastPlayed,_that.freezes,_that.freezeWeek);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  int best,  String lastPlayed,  int freezes,  String freezeWeek)?  $default,) {final _that = this;
switch (_that) {
case _StreakState() when $default != null:
return $default(_that.count,_that.best,_that.lastPlayed,_that.freezes,_that.freezeWeek);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakState implements StreakState {
  const _StreakState({this.count = 0, this.best = 0, this.lastPlayed = '', this.freezes = 0, this.freezeWeek = ''});
  factory _StreakState.fromJson(Map<String, dynamic> json) => _$StreakStateFromJson(json);

/// Days in a row with at least one level played.
@override@JsonKey() final  int count;
@override@JsonKey() final  int best;
/// Local date of the last day played, or `''`.
@override@JsonKey() final  String lastPlayed;
/// Streak freezes in stock (one free per week, more for coins).
@override@JsonKey() final  int freezes;
/// ISO week (`2026-W41`) the free freeze was last granted.
@override@JsonKey() final  String freezeWeek;

/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakStateCopyWith<_StreakState> get copyWith => __$StreakStateCopyWithImpl<_StreakState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakState&&(identical(other.count, count) || other.count == count)&&(identical(other.best, best) || other.best == best)&&(identical(other.lastPlayed, lastPlayed) || other.lastPlayed == lastPlayed)&&(identical(other.freezes, freezes) || other.freezes == freezes)&&(identical(other.freezeWeek, freezeWeek) || other.freezeWeek == freezeWeek));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,count,best,lastPlayed,freezes,freezeWeek);
}

@override
String toString() {
    return 'StreakState(count: $count, best: $best, lastPlayed: $lastPlayed, freezes: $freezes, freezeWeek: $freezeWeek)';
}


}

/// @nodoc
abstract mixin class _$StreakStateCopyWith<$Res> implements $StreakStateCopyWith<$Res> {
  factory _$StreakStateCopyWith(_StreakState value, $Res Function(_StreakState) _then) = __$StreakStateCopyWithImpl;
@override @useResult
$Res call({
 int count, int best, String lastPlayed, int freezes, String freezeWeek
});




}
/// @nodoc
class __$StreakStateCopyWithImpl<$Res>
    implements _$StreakStateCopyWith<$Res> {
  __$StreakStateCopyWithImpl(this._self, this._then);

  final _StreakState _self;
  final $Res Function(_StreakState) _then;

/// Create a copy of StreakState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? best = null,Object? lastPlayed = null,Object? freezes = null,Object? freezeWeek = null,}) {
  return _then(_StreakState(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,lastPlayed: null == lastPlayed ? _self.lastPlayed : lastPlayed // ignore: cast_nullable_to_non_nullable
as String,freezes: null == freezes ? _self.freezes : freezes // ignore: cast_nullable_to_non_nullable
as int,freezeWeek: null == freezeWeek ? _self.freezeWeek : freezeWeek // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DailyResult {

 int get stars; int get heartsLeft; int get bestFlow; int get seconds;/// Played as a replay of a missed day (paid for).
 bool get replayed;
/// Create a copy of DailyResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyResultCopyWith<DailyResult> get copyWith => _$DailyResultCopyWithImpl<DailyResult>(this as DailyResult, _$identity);

  /// Serializes this DailyResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DailyResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyResult&&(identical(other.stars, _this.stars) || other.stars == _this.stars)&&(identical(other.heartsLeft, _this.heartsLeft) || other.heartsLeft == _this.heartsLeft)&&(identical(other.bestFlow, _this.bestFlow) || other.bestFlow == _this.bestFlow)&&(identical(other.seconds, _this.seconds) || other.seconds == _this.seconds)&&(identical(other.replayed, _this.replayed) || other.replayed == _this.replayed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DailyResult;
  return Object.hash(runtimeType,_this.stars,_this.heartsLeft,_this.bestFlow,_this.seconds,_this.replayed);
}

@override
String toString() {
  final _this = this as DailyResult;
  return 'DailyResult(stars: ${_this.stars}, heartsLeft: ${_this.heartsLeft}, bestFlow: ${_this.bestFlow}, seconds: ${_this.seconds}, replayed: ${_this.replayed})';
}


}

/// @nodoc
abstract mixin class $DailyResultCopyWith<$Res>  {
  factory $DailyResultCopyWith(DailyResult value, $Res Function(DailyResult) _then) = _$DailyResultCopyWithImpl;
@useResult
$Res call({
 int stars, int heartsLeft, int bestFlow, int seconds, bool replayed
});




}
/// @nodoc
class _$DailyResultCopyWithImpl<$Res>
    implements $DailyResultCopyWith<$Res> {
  _$DailyResultCopyWithImpl(this._self, this._then);

  final DailyResult _self;
  final $Res Function(DailyResult) _then;

/// Create a copy of DailyResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stars = null,Object? heartsLeft = null,Object? bestFlow = null,Object? seconds = null,Object? replayed = null,}) {
  return _then(DailyResult(
stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,heartsLeft: null == heartsLeft ? _self.heartsLeft : heartsLeft // ignore: cast_nullable_to_non_nullable
as int,bestFlow: null == bestFlow ? _self.bestFlow : bestFlow // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,replayed: null == replayed ? _self.replayed : replayed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyResult].
extension DailyResultPatterns on DailyResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyResult value)  $default,){
final _that = this;
switch (_that) {
case _DailyResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyResult value)?  $default,){
final _that = this;
switch (_that) {
case _DailyResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stars,  int heartsLeft,  int bestFlow,  int seconds,  bool replayed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyResult() when $default != null:
return $default(_that.stars,_that.heartsLeft,_that.bestFlow,_that.seconds,_that.replayed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stars,  int heartsLeft,  int bestFlow,  int seconds,  bool replayed)  $default,) {final _that = this;
switch (_that) {
case _DailyResult():
return $default(_that.stars,_that.heartsLeft,_that.bestFlow,_that.seconds,_that.replayed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stars,  int heartsLeft,  int bestFlow,  int seconds,  bool replayed)?  $default,) {final _that = this;
switch (_that) {
case _DailyResult() when $default != null:
return $default(_that.stars,_that.heartsLeft,_that.bestFlow,_that.seconds,_that.replayed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyResult implements DailyResult {
  const _DailyResult({this.stars = 0, this.heartsLeft = 0, this.bestFlow = 1, this.seconds = 0, this.replayed = false});
  factory _DailyResult.fromJson(Map<String, dynamic> json) => _$DailyResultFromJson(json);

@override@JsonKey() final  int stars;
@override@JsonKey() final  int heartsLeft;
@override@JsonKey() final  int bestFlow;
@override@JsonKey() final  int seconds;
/// Played as a replay of a missed day (paid for).
@override@JsonKey() final  bool replayed;

/// Create a copy of DailyResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyResultCopyWith<_DailyResult> get copyWith => __$DailyResultCopyWithImpl<_DailyResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyResult&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.heartsLeft, heartsLeft) || other.heartsLeft == heartsLeft)&&(identical(other.bestFlow, bestFlow) || other.bestFlow == bestFlow)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.replayed, replayed) || other.replayed == replayed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,stars,heartsLeft,bestFlow,seconds,replayed);
}

@override
String toString() {
    return 'DailyResult(stars: $stars, heartsLeft: $heartsLeft, bestFlow: $bestFlow, seconds: $seconds, replayed: $replayed)';
}


}

/// @nodoc
abstract mixin class _$DailyResultCopyWith<$Res> implements $DailyResultCopyWith<$Res> {
  factory _$DailyResultCopyWith(_DailyResult value, $Res Function(_DailyResult) _then) = __$DailyResultCopyWithImpl;
@override @useResult
$Res call({
 int stars, int heartsLeft, int bestFlow, int seconds, bool replayed
});




}
/// @nodoc
class __$DailyResultCopyWithImpl<$Res>
    implements _$DailyResultCopyWith<$Res> {
  __$DailyResultCopyWithImpl(this._self, this._then);

  final _DailyResult _self;
  final $Res Function(_DailyResult) _then;

/// Create a copy of DailyResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stars = null,Object? heartsLeft = null,Object? bestFlow = null,Object? seconds = null,Object? replayed = null,}) {
  return _then(_DailyResult(
stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,heartsLeft: null == heartsLeft ? _self.heartsLeft : heartsLeft // ignore: cast_nullable_to_non_nullable
as int,bestFlow: null == bestFlow ? _self.bestFlow : bestFlow // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,replayed: null == replayed ? _self.replayed : replayed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$QuestProgress {

 String get id; int get progress; bool get claimed;
/// Create a copy of QuestProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestProgressCopyWith<QuestProgress> get copyWith => _$QuestProgressCopyWithImpl<QuestProgress>(this as QuestProgress, _$identity);

  /// Serializes this QuestProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuestProgress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestProgress&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.claimed, _this.claimed) || other.claimed == _this.claimed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuestProgress;
  return Object.hash(runtimeType,_this.id,_this.progress,_this.claimed);
}

@override
String toString() {
  final _this = this as QuestProgress;
  return 'QuestProgress(id: ${_this.id}, progress: ${_this.progress}, claimed: ${_this.claimed})';
}


}

/// @nodoc
abstract mixin class $QuestProgressCopyWith<$Res>  {
  factory $QuestProgressCopyWith(QuestProgress value, $Res Function(QuestProgress) _then) = _$QuestProgressCopyWithImpl;
@useResult
$Res call({
 String id, int progress, bool claimed
});




}
/// @nodoc
class _$QuestProgressCopyWithImpl<$Res>
    implements $QuestProgressCopyWith<$Res> {
  _$QuestProgressCopyWithImpl(this._self, this._then);

  final QuestProgress _self;
  final $Res Function(QuestProgress) _then;

/// Create a copy of QuestProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? progress = null,Object? claimed = null,}) {
  return _then(QuestProgress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,claimed: null == claimed ? _self.claimed : claimed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestProgress].
extension QuestProgressPatterns on QuestProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestProgress value)  $default,){
final _that = this;
switch (_that) {
case _QuestProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestProgress value)?  $default,){
final _that = this;
switch (_that) {
case _QuestProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int progress,  bool claimed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestProgress() when $default != null:
return $default(_that.id,_that.progress,_that.claimed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int progress,  bool claimed)  $default,) {final _that = this;
switch (_that) {
case _QuestProgress():
return $default(_that.id,_that.progress,_that.claimed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int progress,  bool claimed)?  $default,) {final _that = this;
switch (_that) {
case _QuestProgress() when $default != null:
return $default(_that.id,_that.progress,_that.claimed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestProgress implements QuestProgress {
  const _QuestProgress({required this.id, this.progress = 0, this.claimed = false});
  factory _QuestProgress.fromJson(Map<String, dynamic> json) => _$QuestProgressFromJson(json);

@override final  String id;
@override@JsonKey() final  int progress;
@override@JsonKey() final  bool claimed;

/// Create a copy of QuestProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestProgressCopyWith<_QuestProgress> get copyWith => __$QuestProgressCopyWithImpl<_QuestProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestProgressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestProgress&&(identical(other.id, id) || other.id == id)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.claimed, claimed) || other.claimed == claimed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,progress,claimed);
}

@override
String toString() {
    return 'QuestProgress(id: $id, progress: $progress, claimed: $claimed)';
}


}

/// @nodoc
abstract mixin class _$QuestProgressCopyWith<$Res> implements $QuestProgressCopyWith<$Res> {
  factory _$QuestProgressCopyWith(_QuestProgress value, $Res Function(_QuestProgress) _then) = __$QuestProgressCopyWithImpl;
@override @useResult
$Res call({
 String id, int progress, bool claimed
});




}
/// @nodoc
class __$QuestProgressCopyWithImpl<$Res>
    implements _$QuestProgressCopyWith<$Res> {
  __$QuestProgressCopyWithImpl(this._self, this._then);

  final _QuestProgress _self;
  final $Res Function(_QuestProgress) _then;

/// Create a copy of QuestProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? progress = null,Object? claimed = null,}) {
  return _then(_QuestProgress(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,claimed: null == claimed ? _self.claimed : claimed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$QuestState {

/// Local date these quests belong to.
 String get date; List<QuestProgress> get items; bool get chestOpened;
/// Create a copy of QuestState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestStateCopyWith<QuestState> get copyWith => _$QuestStateCopyWithImpl<QuestState>(this as QuestState, _$identity);

  /// Serializes this QuestState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QuestState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestState&&(identical(other.date, _this.date) || other.date == _this.date)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.chestOpened, _this.chestOpened) || other.chestOpened == _this.chestOpened));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QuestState;
  return Object.hash(runtimeType,_this.date,const DeepCollectionEquality().hash(_this.items),_this.chestOpened);
}

@override
String toString() {
  final _this = this as QuestState;
  return 'QuestState(date: ${_this.date}, items: ${_this.items}, chestOpened: ${_this.chestOpened})';
}


}

/// @nodoc
abstract mixin class $QuestStateCopyWith<$Res>  {
  factory $QuestStateCopyWith(QuestState value, $Res Function(QuestState) _then) = _$QuestStateCopyWithImpl;
@useResult
$Res call({
 String date, List<QuestProgress> items, bool chestOpened
});




}
/// @nodoc
class _$QuestStateCopyWithImpl<$Res>
    implements $QuestStateCopyWith<$Res> {
  _$QuestStateCopyWithImpl(this._self, this._then);

  final QuestState _self;
  final $Res Function(QuestState) _then;

/// Create a copy of QuestState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? items = null,Object? chestOpened = null,}) {
  return _then(QuestState(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<QuestProgress>,chestOpened: null == chestOpened ? _self.chestOpened : chestOpened // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestState].
extension QuestStatePatterns on QuestState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestState value)  $default,){
final _that = this;
switch (_that) {
case _QuestState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestState value)?  $default,){
final _that = this;
switch (_that) {
case _QuestState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  List<QuestProgress> items,  bool chestOpened)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestState() when $default != null:
return $default(_that.date,_that.items,_that.chestOpened);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  List<QuestProgress> items,  bool chestOpened)  $default,) {final _that = this;
switch (_that) {
case _QuestState():
return $default(_that.date,_that.items,_that.chestOpened);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  List<QuestProgress> items,  bool chestOpened)?  $default,) {final _that = this;
switch (_that) {
case _QuestState() when $default != null:
return $default(_that.date,_that.items,_that.chestOpened);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestState implements QuestState {
  const _QuestState({this.date = '',  List<QuestProgress> items = const <QuestProgress>[], this.chestOpened = false}): _items = items;
  factory _QuestState.fromJson(Map<String, dynamic> json) => _$QuestStateFromJson(json);

/// Local date these quests belong to.
@override@JsonKey() final  String date;
 final  List<QuestProgress> _items;
@override@JsonKey() List<QuestProgress> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool chestOpened;

/// Create a copy of QuestState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestStateCopyWith<_QuestState> get copyWith => __$QuestStateCopyWithImpl<_QuestState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestState&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.chestOpened, chestOpened) || other.chestOpened == chestOpened));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_items),chestOpened);
}

@override
String toString() {
    return 'QuestState(date: $date, items: $items, chestOpened: $chestOpened)';
}


}

/// @nodoc
abstract mixin class _$QuestStateCopyWith<$Res> implements $QuestStateCopyWith<$Res> {
  factory _$QuestStateCopyWith(_QuestState value, $Res Function(_QuestState) _then) = __$QuestStateCopyWithImpl;
@override @useResult
$Res call({
 String date, List<QuestProgress> items, bool chestOpened
});




}
/// @nodoc
class __$QuestStateCopyWithImpl<$Res>
    implements _$QuestStateCopyWith<$Res> {
  __$QuestStateCopyWithImpl(this._self, this._then);

  final _QuestState _self;
  final $Res Function(_QuestState) _then;

/// Create a copy of QuestState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? items = null,Object? chestOpened = null,}) {
  return _then(_QuestState(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<QuestProgress>,chestOpened: null == chestOpened ? _self.chestOpened : chestOpened // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PlayStats {

 int get arrowsFreed; int get levelsCleared; int get perfectClears;/// Consecutive ★★★ clears (resets on a worse one).
 int get perfectRun; int get bestFlow; int get blockedTaps; int get playSeconds; int get dailiesPlayed; int get hintsUsed;
/// Create a copy of PlayStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayStatsCopyWith<PlayStats> get copyWith => _$PlayStatsCopyWithImpl<PlayStats>(this as PlayStats, _$identity);

  /// Serializes this PlayStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PlayStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayStats&&(identical(other.arrowsFreed, _this.arrowsFreed) || other.arrowsFreed == _this.arrowsFreed)&&(identical(other.levelsCleared, _this.levelsCleared) || other.levelsCleared == _this.levelsCleared)&&(identical(other.perfectClears, _this.perfectClears) || other.perfectClears == _this.perfectClears)&&(identical(other.perfectRun, _this.perfectRun) || other.perfectRun == _this.perfectRun)&&(identical(other.bestFlow, _this.bestFlow) || other.bestFlow == _this.bestFlow)&&(identical(other.blockedTaps, _this.blockedTaps) || other.blockedTaps == _this.blockedTaps)&&(identical(other.playSeconds, _this.playSeconds) || other.playSeconds == _this.playSeconds)&&(identical(other.dailiesPlayed, _this.dailiesPlayed) || other.dailiesPlayed == _this.dailiesPlayed)&&(identical(other.hintsUsed, _this.hintsUsed) || other.hintsUsed == _this.hintsUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PlayStats;
  return Object.hash(runtimeType,_this.arrowsFreed,_this.levelsCleared,_this.perfectClears,_this.perfectRun,_this.bestFlow,_this.blockedTaps,_this.playSeconds,_this.dailiesPlayed,_this.hintsUsed);
}

@override
String toString() {
  final _this = this as PlayStats;
  return 'PlayStats(arrowsFreed: ${_this.arrowsFreed}, levelsCleared: ${_this.levelsCleared}, perfectClears: ${_this.perfectClears}, perfectRun: ${_this.perfectRun}, bestFlow: ${_this.bestFlow}, blockedTaps: ${_this.blockedTaps}, playSeconds: ${_this.playSeconds}, dailiesPlayed: ${_this.dailiesPlayed}, hintsUsed: ${_this.hintsUsed})';
}


}

/// @nodoc
abstract mixin class $PlayStatsCopyWith<$Res>  {
  factory $PlayStatsCopyWith(PlayStats value, $Res Function(PlayStats) _then) = _$PlayStatsCopyWithImpl;
@useResult
$Res call({
 int arrowsFreed, int levelsCleared, int perfectClears, int perfectRun, int bestFlow, int blockedTaps, int playSeconds, int dailiesPlayed, int hintsUsed
});




}
/// @nodoc
class _$PlayStatsCopyWithImpl<$Res>
    implements $PlayStatsCopyWith<$Res> {
  _$PlayStatsCopyWithImpl(this._self, this._then);

  final PlayStats _self;
  final $Res Function(PlayStats) _then;

/// Create a copy of PlayStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? arrowsFreed = null,Object? levelsCleared = null,Object? perfectClears = null,Object? perfectRun = null,Object? bestFlow = null,Object? blockedTaps = null,Object? playSeconds = null,Object? dailiesPlayed = null,Object? hintsUsed = null,}) {
  return _then(PlayStats(
arrowsFreed: null == arrowsFreed ? _self.arrowsFreed : arrowsFreed // ignore: cast_nullable_to_non_nullable
as int,levelsCleared: null == levelsCleared ? _self.levelsCleared : levelsCleared // ignore: cast_nullable_to_non_nullable
as int,perfectClears: null == perfectClears ? _self.perfectClears : perfectClears // ignore: cast_nullable_to_non_nullable
as int,perfectRun: null == perfectRun ? _self.perfectRun : perfectRun // ignore: cast_nullable_to_non_nullable
as int,bestFlow: null == bestFlow ? _self.bestFlow : bestFlow // ignore: cast_nullable_to_non_nullable
as int,blockedTaps: null == blockedTaps ? _self.blockedTaps : blockedTaps // ignore: cast_nullable_to_non_nullable
as int,playSeconds: null == playSeconds ? _self.playSeconds : playSeconds // ignore: cast_nullable_to_non_nullable
as int,dailiesPlayed: null == dailiesPlayed ? _self.dailiesPlayed : dailiesPlayed // ignore: cast_nullable_to_non_nullable
as int,hintsUsed: null == hintsUsed ? _self.hintsUsed : hintsUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayStats].
extension PlayStatsPatterns on PlayStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayStats value)  $default,){
final _that = this;
switch (_that) {
case _PlayStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayStats value)?  $default,){
final _that = this;
switch (_that) {
case _PlayStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int arrowsFreed,  int levelsCleared,  int perfectClears,  int perfectRun,  int bestFlow,  int blockedTaps,  int playSeconds,  int dailiesPlayed,  int hintsUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayStats() when $default != null:
return $default(_that.arrowsFreed,_that.levelsCleared,_that.perfectClears,_that.perfectRun,_that.bestFlow,_that.blockedTaps,_that.playSeconds,_that.dailiesPlayed,_that.hintsUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int arrowsFreed,  int levelsCleared,  int perfectClears,  int perfectRun,  int bestFlow,  int blockedTaps,  int playSeconds,  int dailiesPlayed,  int hintsUsed)  $default,) {final _that = this;
switch (_that) {
case _PlayStats():
return $default(_that.arrowsFreed,_that.levelsCleared,_that.perfectClears,_that.perfectRun,_that.bestFlow,_that.blockedTaps,_that.playSeconds,_that.dailiesPlayed,_that.hintsUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int arrowsFreed,  int levelsCleared,  int perfectClears,  int perfectRun,  int bestFlow,  int blockedTaps,  int playSeconds,  int dailiesPlayed,  int hintsUsed)?  $default,) {final _that = this;
switch (_that) {
case _PlayStats() when $default != null:
return $default(_that.arrowsFreed,_that.levelsCleared,_that.perfectClears,_that.perfectRun,_that.bestFlow,_that.blockedTaps,_that.playSeconds,_that.dailiesPlayed,_that.hintsUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayStats implements PlayStats {
  const _PlayStats({this.arrowsFreed = 0, this.levelsCleared = 0, this.perfectClears = 0, this.perfectRun = 0, this.bestFlow = 1, this.blockedTaps = 0, this.playSeconds = 0, this.dailiesPlayed = 0, this.hintsUsed = 0});
  factory _PlayStats.fromJson(Map<String, dynamic> json) => _$PlayStatsFromJson(json);

@override@JsonKey() final  int arrowsFreed;
@override@JsonKey() final  int levelsCleared;
@override@JsonKey() final  int perfectClears;
/// Consecutive ★★★ clears (resets on a worse one).
@override@JsonKey() final  int perfectRun;
@override@JsonKey() final  int bestFlow;
@override@JsonKey() final  int blockedTaps;
@override@JsonKey() final  int playSeconds;
@override@JsonKey() final  int dailiesPlayed;
@override@JsonKey() final  int hintsUsed;

/// Create a copy of PlayStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayStatsCopyWith<_PlayStats> get copyWith => __$PlayStatsCopyWithImpl<_PlayStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayStats&&(identical(other.arrowsFreed, arrowsFreed) || other.arrowsFreed == arrowsFreed)&&(identical(other.levelsCleared, levelsCleared) || other.levelsCleared == levelsCleared)&&(identical(other.perfectClears, perfectClears) || other.perfectClears == perfectClears)&&(identical(other.perfectRun, perfectRun) || other.perfectRun == perfectRun)&&(identical(other.bestFlow, bestFlow) || other.bestFlow == bestFlow)&&(identical(other.blockedTaps, blockedTaps) || other.blockedTaps == blockedTaps)&&(identical(other.playSeconds, playSeconds) || other.playSeconds == playSeconds)&&(identical(other.dailiesPlayed, dailiesPlayed) || other.dailiesPlayed == dailiesPlayed)&&(identical(other.hintsUsed, hintsUsed) || other.hintsUsed == hintsUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,arrowsFreed,levelsCleared,perfectClears,perfectRun,bestFlow,blockedTaps,playSeconds,dailiesPlayed,hintsUsed);
}

@override
String toString() {
    return 'PlayStats(arrowsFreed: $arrowsFreed, levelsCleared: $levelsCleared, perfectClears: $perfectClears, perfectRun: $perfectRun, bestFlow: $bestFlow, blockedTaps: $blockedTaps, playSeconds: $playSeconds, dailiesPlayed: $dailiesPlayed, hintsUsed: $hintsUsed)';
}


}

/// @nodoc
abstract mixin class _$PlayStatsCopyWith<$Res> implements $PlayStatsCopyWith<$Res> {
  factory _$PlayStatsCopyWith(_PlayStats value, $Res Function(_PlayStats) _then) = __$PlayStatsCopyWithImpl;
@override @useResult
$Res call({
 int arrowsFreed, int levelsCleared, int perfectClears, int perfectRun, int bestFlow, int blockedTaps, int playSeconds, int dailiesPlayed, int hintsUsed
});




}
/// @nodoc
class __$PlayStatsCopyWithImpl<$Res>
    implements _$PlayStatsCopyWith<$Res> {
  __$PlayStatsCopyWithImpl(this._self, this._then);

  final _PlayStats _self;
  final $Res Function(_PlayStats) _then;

/// Create a copy of PlayStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? arrowsFreed = null,Object? levelsCleared = null,Object? perfectClears = null,Object? perfectRun = null,Object? bestFlow = null,Object? blockedTaps = null,Object? playSeconds = null,Object? dailiesPlayed = null,Object? hintsUsed = null,}) {
  return _then(_PlayStats(
arrowsFreed: null == arrowsFreed ? _self.arrowsFreed : arrowsFreed // ignore: cast_nullable_to_non_nullable
as int,levelsCleared: null == levelsCleared ? _self.levelsCleared : levelsCleared // ignore: cast_nullable_to_non_nullable
as int,perfectClears: null == perfectClears ? _self.perfectClears : perfectClears // ignore: cast_nullable_to_non_nullable
as int,perfectRun: null == perfectRun ? _self.perfectRun : perfectRun // ignore: cast_nullable_to_non_nullable
as int,bestFlow: null == bestFlow ? _self.bestFlow : bestFlow // ignore: cast_nullable_to_non_nullable
as int,blockedTaps: null == blockedTaps ? _self.blockedTaps : blockedTaps // ignore: cast_nullable_to_non_nullable
as int,playSeconds: null == playSeconds ? _self.playSeconds : playSeconds // ignore: cast_nullable_to_non_nullable
as int,dailiesPlayed: null == dailiesPlayed ? _self.dailiesPlayed : dailiesPlayed // ignore: cast_nullable_to_non_nullable
as int,hintsUsed: null == hintsUsed ? _self.hintsUsed : hintsUsed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SaveSettings {

 bool get musicOn; bool get soundOn; bool get hapticsOn; double get musicVolume; double get soundVolume; bool get leftHanded; bool get relaxed; bool get gridOn;/// `system` follows the OS, `on` always reduces motion.
 String get reduceMotion;/// `off`, `deutan` (also protan) or `tritan`.
 String get colorBlind;
/// Create a copy of SaveSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveSettingsCopyWith<SaveSettings> get copyWith => _$SaveSettingsCopyWithImpl<SaveSettings>(this as SaveSettings, _$identity);

  /// Serializes this SaveSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SaveSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveSettings&&(identical(other.musicOn, _this.musicOn) || other.musicOn == _this.musicOn)&&(identical(other.soundOn, _this.soundOn) || other.soundOn == _this.soundOn)&&(identical(other.hapticsOn, _this.hapticsOn) || other.hapticsOn == _this.hapticsOn)&&(identical(other.musicVolume, _this.musicVolume) || other.musicVolume == _this.musicVolume)&&(identical(other.soundVolume, _this.soundVolume) || other.soundVolume == _this.soundVolume)&&(identical(other.leftHanded, _this.leftHanded) || other.leftHanded == _this.leftHanded)&&(identical(other.relaxed, _this.relaxed) || other.relaxed == _this.relaxed)&&(identical(other.gridOn, _this.gridOn) || other.gridOn == _this.gridOn)&&(identical(other.reduceMotion, _this.reduceMotion) || other.reduceMotion == _this.reduceMotion)&&(identical(other.colorBlind, _this.colorBlind) || other.colorBlind == _this.colorBlind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SaveSettings;
  return Object.hash(runtimeType,_this.musicOn,_this.soundOn,_this.hapticsOn,_this.musicVolume,_this.soundVolume,_this.leftHanded,_this.relaxed,_this.gridOn,_this.reduceMotion,_this.colorBlind);
}

@override
String toString() {
  final _this = this as SaveSettings;
  return 'SaveSettings(musicOn: ${_this.musicOn}, soundOn: ${_this.soundOn}, hapticsOn: ${_this.hapticsOn}, musicVolume: ${_this.musicVolume}, soundVolume: ${_this.soundVolume}, leftHanded: ${_this.leftHanded}, relaxed: ${_this.relaxed}, gridOn: ${_this.gridOn}, reduceMotion: ${_this.reduceMotion}, colorBlind: ${_this.colorBlind})';
}


}

/// @nodoc
abstract mixin class $SaveSettingsCopyWith<$Res>  {
  factory $SaveSettingsCopyWith(SaveSettings value, $Res Function(SaveSettings) _then) = _$SaveSettingsCopyWithImpl;
@useResult
$Res call({
 bool musicOn, bool soundOn, bool hapticsOn, double musicVolume, double soundVolume, bool leftHanded, bool relaxed, bool gridOn, String reduceMotion, String colorBlind
});




}
/// @nodoc
class _$SaveSettingsCopyWithImpl<$Res>
    implements $SaveSettingsCopyWith<$Res> {
  _$SaveSettingsCopyWithImpl(this._self, this._then);

  final SaveSettings _self;
  final $Res Function(SaveSettings) _then;

/// Create a copy of SaveSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? musicOn = null,Object? soundOn = null,Object? hapticsOn = null,Object? musicVolume = null,Object? soundVolume = null,Object? leftHanded = null,Object? relaxed = null,Object? gridOn = null,Object? reduceMotion = null,Object? colorBlind = null,}) {
  return _then(SaveSettings(
musicOn: null == musicOn ? _self.musicOn : musicOn // ignore: cast_nullable_to_non_nullable
as bool,soundOn: null == soundOn ? _self.soundOn : soundOn // ignore: cast_nullable_to_non_nullable
as bool,hapticsOn: null == hapticsOn ? _self.hapticsOn : hapticsOn // ignore: cast_nullable_to_non_nullable
as bool,musicVolume: null == musicVolume ? _self.musicVolume : musicVolume // ignore: cast_nullable_to_non_nullable
as double,soundVolume: null == soundVolume ? _self.soundVolume : soundVolume // ignore: cast_nullable_to_non_nullable
as double,leftHanded: null == leftHanded ? _self.leftHanded : leftHanded // ignore: cast_nullable_to_non_nullable
as bool,relaxed: null == relaxed ? _self.relaxed : relaxed // ignore: cast_nullable_to_non_nullable
as bool,gridOn: null == gridOn ? _self.gridOn : gridOn // ignore: cast_nullable_to_non_nullable
as bool,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as String,colorBlind: null == colorBlind ? _self.colorBlind : colorBlind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SaveSettings].
extension SaveSettingsPatterns on SaveSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveSettings value)  $default,){
final _that = this;
switch (_that) {
case _SaveSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SaveSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool musicOn,  bool soundOn,  bool hapticsOn,  double musicVolume,  double soundVolume,  bool leftHanded,  bool relaxed,  bool gridOn,  String reduceMotion,  String colorBlind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveSettings() when $default != null:
return $default(_that.musicOn,_that.soundOn,_that.hapticsOn,_that.musicVolume,_that.soundVolume,_that.leftHanded,_that.relaxed,_that.gridOn,_that.reduceMotion,_that.colorBlind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool musicOn,  bool soundOn,  bool hapticsOn,  double musicVolume,  double soundVolume,  bool leftHanded,  bool relaxed,  bool gridOn,  String reduceMotion,  String colorBlind)  $default,) {final _that = this;
switch (_that) {
case _SaveSettings():
return $default(_that.musicOn,_that.soundOn,_that.hapticsOn,_that.musicVolume,_that.soundVolume,_that.leftHanded,_that.relaxed,_that.gridOn,_that.reduceMotion,_that.colorBlind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool musicOn,  bool soundOn,  bool hapticsOn,  double musicVolume,  double soundVolume,  bool leftHanded,  bool relaxed,  bool gridOn,  String reduceMotion,  String colorBlind)?  $default,) {final _that = this;
switch (_that) {
case _SaveSettings() when $default != null:
return $default(_that.musicOn,_that.soundOn,_that.hapticsOn,_that.musicVolume,_that.soundVolume,_that.leftHanded,_that.relaxed,_that.gridOn,_that.reduceMotion,_that.colorBlind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaveSettings implements SaveSettings {
  const _SaveSettings({this.musicOn = true, this.soundOn = true, this.hapticsOn = true, this.musicVolume = 1.0, this.soundVolume = 1.0, this.leftHanded = false, this.relaxed = false, this.gridOn = false, this.reduceMotion = 'system', this.colorBlind = 'off'});
  factory _SaveSettings.fromJson(Map<String, dynamic> json) => _$SaveSettingsFromJson(json);

@override@JsonKey() final  bool musicOn;
@override@JsonKey() final  bool soundOn;
@override@JsonKey() final  bool hapticsOn;
@override@JsonKey() final  double musicVolume;
@override@JsonKey() final  double soundVolume;
@override@JsonKey() final  bool leftHanded;
@override@JsonKey() final  bool relaxed;
@override@JsonKey() final  bool gridOn;
/// `system` follows the OS, `on` always reduces motion.
@override@JsonKey() final  String reduceMotion;
/// `off`, `deutan` (also protan) or `tritan`.
@override@JsonKey() final  String colorBlind;

/// Create a copy of SaveSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveSettingsCopyWith<_SaveSettings> get copyWith => __$SaveSettingsCopyWithImpl<_SaveSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaveSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveSettings&&(identical(other.musicOn, musicOn) || other.musicOn == musicOn)&&(identical(other.soundOn, soundOn) || other.soundOn == soundOn)&&(identical(other.hapticsOn, hapticsOn) || other.hapticsOn == hapticsOn)&&(identical(other.musicVolume, musicVolume) || other.musicVolume == musicVolume)&&(identical(other.soundVolume, soundVolume) || other.soundVolume == soundVolume)&&(identical(other.leftHanded, leftHanded) || other.leftHanded == leftHanded)&&(identical(other.relaxed, relaxed) || other.relaxed == relaxed)&&(identical(other.gridOn, gridOn) || other.gridOn == gridOn)&&(identical(other.reduceMotion, reduceMotion) || other.reduceMotion == reduceMotion)&&(identical(other.colorBlind, colorBlind) || other.colorBlind == colorBlind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,musicOn,soundOn,hapticsOn,musicVolume,soundVolume,leftHanded,relaxed,gridOn,reduceMotion,colorBlind);
}

@override
String toString() {
    return 'SaveSettings(musicOn: $musicOn, soundOn: $soundOn, hapticsOn: $hapticsOn, musicVolume: $musicVolume, soundVolume: $soundVolume, leftHanded: $leftHanded, relaxed: $relaxed, gridOn: $gridOn, reduceMotion: $reduceMotion, colorBlind: $colorBlind)';
}


}

/// @nodoc
abstract mixin class _$SaveSettingsCopyWith<$Res> implements $SaveSettingsCopyWith<$Res> {
  factory _$SaveSettingsCopyWith(_SaveSettings value, $Res Function(_SaveSettings) _then) = __$SaveSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool musicOn, bool soundOn, bool hapticsOn, double musicVolume, double soundVolume, bool leftHanded, bool relaxed, bool gridOn, String reduceMotion, String colorBlind
});




}
/// @nodoc
class __$SaveSettingsCopyWithImpl<$Res>
    implements _$SaveSettingsCopyWith<$Res> {
  __$SaveSettingsCopyWithImpl(this._self, this._then);

  final _SaveSettings _self;
  final $Res Function(_SaveSettings) _then;

/// Create a copy of SaveSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? musicOn = null,Object? soundOn = null,Object? hapticsOn = null,Object? musicVolume = null,Object? soundVolume = null,Object? leftHanded = null,Object? relaxed = null,Object? gridOn = null,Object? reduceMotion = null,Object? colorBlind = null,}) {
  return _then(_SaveSettings(
musicOn: null == musicOn ? _self.musicOn : musicOn // ignore: cast_nullable_to_non_nullable
as bool,soundOn: null == soundOn ? _self.soundOn : soundOn // ignore: cast_nullable_to_non_nullable
as bool,hapticsOn: null == hapticsOn ? _self.hapticsOn : hapticsOn // ignore: cast_nullable_to_non_nullable
as bool,musicVolume: null == musicVolume ? _self.musicVolume : musicVolume // ignore: cast_nullable_to_non_nullable
as double,soundVolume: null == soundVolume ? _self.soundVolume : soundVolume // ignore: cast_nullable_to_non_nullable
as double,leftHanded: null == leftHanded ? _self.leftHanded : leftHanded // ignore: cast_nullable_to_non_nullable
as bool,relaxed: null == relaxed ? _self.relaxed : relaxed // ignore: cast_nullable_to_non_nullable
as bool,gridOn: null == gridOn ? _self.gridOn : gridOn // ignore: cast_nullable_to_non_nullable
as bool,reduceMotion: null == reduceMotion ? _self.reduceMotion : reduceMotion // ignore: cast_nullable_to_non_nullable
as String,colorBlind: null == colorBlind ? _self.colorBlind : colorBlind // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SaveData {

 int get schemaVersion;/// Monotonic write counter: of two storage slots, the higher valid one
/// wins after a crash mid-write.
 int get seq;/// Best stars per level id (`ch1_l007`).
 Map<String, int> get stars;/// Next level to play per chapter (1-60; 61 = chapter finished).
 Map<String, int> get currentLevel; int get coins; int get xp; List<String> get inventory; Map<String, String> get equipped; StreakState get streak;/// Daily Knot results by UTC date (`2026-10-10`).
 Map<String, DailyResult> get daily;/// Achievement id → local date unlocked.
 Map<String, String> get achievements; QuestState get quests; SaveSettings get settings; PlayStats get stats;/// Free-form flags (`adsRemoved`, `onboardingDone`, ...).
 Map<String, bool> get flags; String get updatedAt;
/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaveDataCopyWith<SaveData> get copyWith => _$SaveDataCopyWithImpl<SaveData>(this as SaveData, _$identity);

  /// Serializes this SaveData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SaveData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaveData&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.seq, _this.seq) || other.seq == _this.seq)&&const DeepCollectionEquality().equals(other.stars, _this.stars)&&const DeepCollectionEquality().equals(other.currentLevel, _this.currentLevel)&&(identical(other.coins, _this.coins) || other.coins == _this.coins)&&(identical(other.xp, _this.xp) || other.xp == _this.xp)&&const DeepCollectionEquality().equals(other.inventory, _this.inventory)&&const DeepCollectionEquality().equals(other.equipped, _this.equipped)&&(identical(other.streak, _this.streak) || other.streak == _this.streak)&&const DeepCollectionEquality().equals(other.daily, _this.daily)&&const DeepCollectionEquality().equals(other.achievements, _this.achievements)&&(identical(other.quests, _this.quests) || other.quests == _this.quests)&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&(identical(other.stats, _this.stats) || other.stats == _this.stats)&&const DeepCollectionEquality().equals(other.flags, _this.flags)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SaveData;
  return Object.hash(runtimeType,_this.schemaVersion,_this.seq,const DeepCollectionEquality().hash(_this.stars),const DeepCollectionEquality().hash(_this.currentLevel),_this.coins,_this.xp,const DeepCollectionEquality().hash(_this.inventory),const DeepCollectionEquality().hash(_this.equipped),_this.streak,const DeepCollectionEquality().hash(_this.daily),const DeepCollectionEquality().hash(_this.achievements),_this.quests,_this.settings,_this.stats,const DeepCollectionEquality().hash(_this.flags),_this.updatedAt);
}

@override
String toString() {
  final _this = this as SaveData;
  return 'SaveData(schemaVersion: ${_this.schemaVersion}, seq: ${_this.seq}, stars: ${_this.stars}, currentLevel: ${_this.currentLevel}, coins: ${_this.coins}, xp: ${_this.xp}, inventory: ${_this.inventory}, equipped: ${_this.equipped}, streak: ${_this.streak}, daily: ${_this.daily}, achievements: ${_this.achievements}, quests: ${_this.quests}, settings: ${_this.settings}, stats: ${_this.stats}, flags: ${_this.flags}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SaveDataCopyWith<$Res>  {
  factory $SaveDataCopyWith(SaveData value, $Res Function(SaveData) _then) = _$SaveDataCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, int seq, Map<String, int> stars, Map<String, int> currentLevel, int coins, int xp, List<String> inventory, Map<String, String> equipped, StreakState streak, Map<String, DailyResult> daily, Map<String, String> achievements, QuestState quests, SaveSettings settings, PlayStats stats, Map<String, bool> flags, String updatedAt
});


$StreakStateCopyWith<$Res> get streak;$QuestStateCopyWith<$Res> get quests;$SaveSettingsCopyWith<$Res> get settings;$PlayStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$SaveDataCopyWithImpl<$Res>
    implements $SaveDataCopyWith<$Res> {
  _$SaveDataCopyWithImpl(this._self, this._then);

  final SaveData _self;
  final $Res Function(SaveData) _then;

/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? seq = null,Object? stars = null,Object? currentLevel = null,Object? coins = null,Object? xp = null,Object? inventory = null,Object? equipped = null,Object? streak = null,Object? daily = null,Object? achievements = null,Object? quests = null,Object? settings = null,Object? stats = null,Object? flags = null,Object? updatedAt = null,}) {
  return _then(SaveData(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as Map<String, int>,currentLevel: null == currentLevel ? _self.currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as Map<String, int>,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,inventory: null == inventory ? _self.inventory : inventory // ignore: cast_nullable_to_non_nullable
as List<String>,equipped: null == equipped ? _self.equipped : equipped // ignore: cast_nullable_to_non_nullable
as Map<String, String>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakState,daily: null == daily ? _self.daily : daily // ignore: cast_nullable_to_non_nullable
as Map<String, DailyResult>,achievements: null == achievements ? _self.achievements : achievements // ignore: cast_nullable_to_non_nullable
as Map<String, String>,quests: null == quests ? _self.quests : quests // ignore: cast_nullable_to_non_nullable
as QuestState,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as SaveSettings,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayStats,flags: null == flags ? _self.flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakStateCopyWith<$Res> get streak {
  
  return $StreakStateCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestStateCopyWith<$Res> get quests {
  
  return $QuestStateCopyWith<$Res>(_self.quests, (value) {
    return _then(_self.copyWith(quests: value));
  });
}/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaveSettingsCopyWith<$Res> get settings {
  
  return $SaveSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayStatsCopyWith<$Res> get stats {
  
  return $PlayStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [SaveData].
extension SaveDataPatterns on SaveData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaveData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaveData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaveData value)  $default,){
final _that = this;
switch (_that) {
case _SaveData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaveData value)?  $default,){
final _that = this;
switch (_that) {
case _SaveData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  int seq,  Map<String, int> stars,  Map<String, int> currentLevel,  int coins,  int xp,  List<String> inventory,  Map<String, String> equipped,  StreakState streak,  Map<String, DailyResult> daily,  Map<String, String> achievements,  QuestState quests,  SaveSettings settings,  PlayStats stats,  Map<String, bool> flags,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaveData() when $default != null:
return $default(_that.schemaVersion,_that.seq,_that.stars,_that.currentLevel,_that.coins,_that.xp,_that.inventory,_that.equipped,_that.streak,_that.daily,_that.achievements,_that.quests,_that.settings,_that.stats,_that.flags,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  int seq,  Map<String, int> stars,  Map<String, int> currentLevel,  int coins,  int xp,  List<String> inventory,  Map<String, String> equipped,  StreakState streak,  Map<String, DailyResult> daily,  Map<String, String> achievements,  QuestState quests,  SaveSettings settings,  PlayStats stats,  Map<String, bool> flags,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SaveData():
return $default(_that.schemaVersion,_that.seq,_that.stars,_that.currentLevel,_that.coins,_that.xp,_that.inventory,_that.equipped,_that.streak,_that.daily,_that.achievements,_that.quests,_that.settings,_that.stats,_that.flags,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  int seq,  Map<String, int> stars,  Map<String, int> currentLevel,  int coins,  int xp,  List<String> inventory,  Map<String, String> equipped,  StreakState streak,  Map<String, DailyResult> daily,  Map<String, String> achievements,  QuestState quests,  SaveSettings settings,  PlayStats stats,  Map<String, bool> flags,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SaveData() when $default != null:
return $default(_that.schemaVersion,_that.seq,_that.stars,_that.currentLevel,_that.coins,_that.xp,_that.inventory,_that.equipped,_that.streak,_that.daily,_that.achievements,_that.quests,_that.settings,_that.stats,_that.flags,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaveData extends SaveData {
  const _SaveData({this.schemaVersion = currentSaveSchema, this.seq = 0,  Map<String, int> stars = const <String, int>{},  Map<String, int> currentLevel = const <String, int>{'1' : 1}, this.coins = 0, this.xp = 0,  List<String> inventory = const <String>[],  Map<String, String> equipped = const <String, String>{}, this.streak = const StreakState(),  Map<String, DailyResult> daily = const <String, DailyResult>{},  Map<String, String> achievements = const <String, String>{}, this.quests = const QuestState(), this.settings = const SaveSettings(), this.stats = const PlayStats(),  Map<String, bool> flags = const <String, bool>{}, this.updatedAt = ''}): _stars = stars,_currentLevel = currentLevel,_inventory = inventory,_equipped = equipped,_daily = daily,_achievements = achievements,_flags = flags,super._();
  factory _SaveData.fromJson(Map<String, dynamic> json) => _$SaveDataFromJson(json);

@override@JsonKey() final  int schemaVersion;
/// Monotonic write counter: of two storage slots, the higher valid one
/// wins after a crash mid-write.
@override@JsonKey() final  int seq;
/// Best stars per level id (`ch1_l007`).
 final  Map<String, int> _stars;
/// Best stars per level id (`ch1_l007`).
@override@JsonKey() Map<String, int> get stars {
  if (_stars is EqualUnmodifiableMapView) return _stars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stars);
}

/// Next level to play per chapter (1-60; 61 = chapter finished).
 final  Map<String, int> _currentLevel;
/// Next level to play per chapter (1-60; 61 = chapter finished).
@override@JsonKey() Map<String, int> get currentLevel {
  if (_currentLevel is EqualUnmodifiableMapView) return _currentLevel;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_currentLevel);
}

@override@JsonKey() final  int coins;
@override@JsonKey() final  int xp;
 final  List<String> _inventory;
@override@JsonKey() List<String> get inventory {
  if (_inventory is EqualUnmodifiableListView) return _inventory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inventory);
}

 final  Map<String, String> _equipped;
@override@JsonKey() Map<String, String> get equipped {
  if (_equipped is EqualUnmodifiableMapView) return _equipped;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_equipped);
}

@override@JsonKey() final  StreakState streak;
/// Daily Knot results by UTC date (`2026-10-10`).
 final  Map<String, DailyResult> _daily;
/// Daily Knot results by UTC date (`2026-10-10`).
@override@JsonKey() Map<String, DailyResult> get daily {
  if (_daily is EqualUnmodifiableMapView) return _daily;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_daily);
}

/// Achievement id → local date unlocked.
 final  Map<String, String> _achievements;
/// Achievement id → local date unlocked.
@override@JsonKey() Map<String, String> get achievements {
  if (_achievements is EqualUnmodifiableMapView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_achievements);
}

@override@JsonKey() final  QuestState quests;
@override@JsonKey() final  SaveSettings settings;
@override@JsonKey() final  PlayStats stats;
/// Free-form flags (`adsRemoved`, `onboardingDone`, ...).
 final  Map<String, bool> _flags;
/// Free-form flags (`adsRemoved`, `onboardingDone`, ...).
@override@JsonKey() Map<String, bool> get flags {
  if (_flags is EqualUnmodifiableMapView) return _flags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_flags);
}

@override@JsonKey() final  String updatedAt;

/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaveDataCopyWith<_SaveData> get copyWith => __$SaveDataCopyWithImpl<_SaveData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaveDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaveData&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.seq, seq) || other.seq == seq)&&const DeepCollectionEquality().equals(other.stars, _stars)&&const DeepCollectionEquality().equals(other.currentLevel, _currentLevel)&&(identical(other.coins, coins) || other.coins == coins)&&(identical(other.xp, xp) || other.xp == xp)&&const DeepCollectionEquality().equals(other.inventory, _inventory)&&const DeepCollectionEquality().equals(other.equipped, _equipped)&&(identical(other.streak, streak) || other.streak == streak)&&const DeepCollectionEquality().equals(other.daily, _daily)&&const DeepCollectionEquality().equals(other.achievements, _achievements)&&(identical(other.quests, quests) || other.quests == quests)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.stats, stats) || other.stats == stats)&&const DeepCollectionEquality().equals(other.flags, _flags)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,seq,const DeepCollectionEquality().hash(_stars),const DeepCollectionEquality().hash(_currentLevel),coins,xp,const DeepCollectionEquality().hash(_inventory),const DeepCollectionEquality().hash(_equipped),streak,const DeepCollectionEquality().hash(_daily),const DeepCollectionEquality().hash(_achievements),quests,settings,stats,const DeepCollectionEquality().hash(_flags),updatedAt);
}

@override
String toString() {
    return 'SaveData(schemaVersion: $schemaVersion, seq: $seq, stars: $stars, currentLevel: $currentLevel, coins: $coins, xp: $xp, inventory: $inventory, equipped: $equipped, streak: $streak, daily: $daily, achievements: $achievements, quests: $quests, settings: $settings, stats: $stats, flags: $flags, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SaveDataCopyWith<$Res> implements $SaveDataCopyWith<$Res> {
  factory _$SaveDataCopyWith(_SaveData value, $Res Function(_SaveData) _then) = __$SaveDataCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, int seq, Map<String, int> stars, Map<String, int> currentLevel, int coins, int xp, List<String> inventory, Map<String, String> equipped, StreakState streak, Map<String, DailyResult> daily, Map<String, String> achievements, QuestState quests, SaveSettings settings, PlayStats stats, Map<String, bool> flags, String updatedAt
});


@override $StreakStateCopyWith<$Res> get streak;@override $QuestStateCopyWith<$Res> get quests;@override $SaveSettingsCopyWith<$Res> get settings;@override $PlayStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$SaveDataCopyWithImpl<$Res>
    implements _$SaveDataCopyWith<$Res> {
  __$SaveDataCopyWithImpl(this._self, this._then);

  final _SaveData _self;
  final $Res Function(_SaveData) _then;

/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? seq = null,Object? stars = null,Object? currentLevel = null,Object? coins = null,Object? xp = null,Object? inventory = null,Object? equipped = null,Object? streak = null,Object? daily = null,Object? achievements = null,Object? quests = null,Object? settings = null,Object? stats = null,Object? flags = null,Object? updatedAt = null,}) {
  return _then(_SaveData(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,seq: null == seq ? _self.seq : seq // ignore: cast_nullable_to_non_nullable
as int,stars: null == stars ? _self._stars : stars // ignore: cast_nullable_to_non_nullable
as Map<String, int>,currentLevel: null == currentLevel ? _self._currentLevel : currentLevel // ignore: cast_nullable_to_non_nullable
as Map<String, int>,coins: null == coins ? _self.coins : coins // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,inventory: null == inventory ? _self._inventory : inventory // ignore: cast_nullable_to_non_nullable
as List<String>,equipped: null == equipped ? _self._equipped : equipped // ignore: cast_nullable_to_non_nullable
as Map<String, String>,streak: null == streak ? _self.streak : streak // ignore: cast_nullable_to_non_nullable
as StreakState,daily: null == daily ? _self._daily : daily // ignore: cast_nullable_to_non_nullable
as Map<String, DailyResult>,achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as Map<String, String>,quests: null == quests ? _self.quests : quests // ignore: cast_nullable_to_non_nullable
as QuestState,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as SaveSettings,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayStats,flags: null == flags ? _self._flags : flags // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreakStateCopyWith<$Res> get streak {
  
  return $StreakStateCopyWith<$Res>(_self.streak, (value) {
    return _then(_self.copyWith(streak: value));
  });
}/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuestStateCopyWith<$Res> get quests {
  
  return $QuestStateCopyWith<$Res>(_self.quests, (value) {
    return _then(_self.copyWith(quests: value));
  });
}/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaveSettingsCopyWith<$Res> get settings {
  
  return $SaveSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}/// Create a copy of SaveData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayStatsCopyWith<$Res> get stats {
  
  return $PlayStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on
