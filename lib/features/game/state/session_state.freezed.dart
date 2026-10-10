// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionState {

 Level get level; GameStatus get status; int get hearts; int get initialHearts; int get remaining; int get total; int get stars; int get freeUndosLeft; bool get canUndo; int get freeHintsLeft; int get flowMultiplier; double get flowFill; int get bestFlow; int get taps; int get blockedTaps; int? get hintArrowId;/// Set once the level is won (already paid into the wallet).
 LevelReward? get reward;
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionStateCopyWith<SessionState> get copyWith => _$SessionStateCopyWithImpl<SessionState>(this as SessionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SessionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.hearts, _this.hearts) || other.hearts == _this.hearts)&&(identical(other.initialHearts, _this.initialHearts) || other.initialHearts == _this.initialHearts)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.stars, _this.stars) || other.stars == _this.stars)&&(identical(other.freeUndosLeft, _this.freeUndosLeft) || other.freeUndosLeft == _this.freeUndosLeft)&&(identical(other.canUndo, _this.canUndo) || other.canUndo == _this.canUndo)&&(identical(other.freeHintsLeft, _this.freeHintsLeft) || other.freeHintsLeft == _this.freeHintsLeft)&&(identical(other.flowMultiplier, _this.flowMultiplier) || other.flowMultiplier == _this.flowMultiplier)&&(identical(other.flowFill, _this.flowFill) || other.flowFill == _this.flowFill)&&(identical(other.bestFlow, _this.bestFlow) || other.bestFlow == _this.bestFlow)&&(identical(other.taps, _this.taps) || other.taps == _this.taps)&&(identical(other.blockedTaps, _this.blockedTaps) || other.blockedTaps == _this.blockedTaps)&&(identical(other.hintArrowId, _this.hintArrowId) || other.hintArrowId == _this.hintArrowId)&&(identical(other.reward, _this.reward) || other.reward == _this.reward));
}


@override
int get hashCode {
  final _this = this as SessionState;
  return Object.hash(runtimeType,_this.level,_this.status,_this.hearts,_this.initialHearts,_this.remaining,_this.total,_this.stars,_this.freeUndosLeft,_this.canUndo,_this.freeHintsLeft,_this.flowMultiplier,_this.flowFill,_this.bestFlow,_this.taps,_this.blockedTaps,_this.hintArrowId,_this.reward);
}

@override
String toString() {
  final _this = this as SessionState;
  return 'SessionState(level: ${_this.level}, status: ${_this.status}, hearts: ${_this.hearts}, initialHearts: ${_this.initialHearts}, remaining: ${_this.remaining}, total: ${_this.total}, stars: ${_this.stars}, freeUndosLeft: ${_this.freeUndosLeft}, canUndo: ${_this.canUndo}, freeHintsLeft: ${_this.freeHintsLeft}, flowMultiplier: ${_this.flowMultiplier}, flowFill: ${_this.flowFill}, bestFlow: ${_this.bestFlow}, taps: ${_this.taps}, blockedTaps: ${_this.blockedTaps}, hintArrowId: ${_this.hintArrowId}, reward: ${_this.reward})';
}


}

/// @nodoc
abstract mixin class $SessionStateCopyWith<$Res>  {
  factory $SessionStateCopyWith(SessionState value, $Res Function(SessionState) _then) = _$SessionStateCopyWithImpl;
@useResult
$Res call({
 Level level, GameStatus status, int hearts, int initialHearts, int remaining, int total, int stars, int freeUndosLeft, bool canUndo, int freeHintsLeft, int flowMultiplier, double flowFill, int bestFlow, int taps, int blockedTaps, int? hintArrowId, LevelReward? reward
});


$LevelCopyWith<$Res> get level;

}
/// @nodoc
class _$SessionStateCopyWithImpl<$Res>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._self, this._then);

  final SessionState _self;
  final $Res Function(SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? status = null,Object? hearts = null,Object? initialHearts = null,Object? remaining = null,Object? total = null,Object? stars = null,Object? freeUndosLeft = null,Object? canUndo = null,Object? freeHintsLeft = null,Object? flowMultiplier = null,Object? flowFill = null,Object? bestFlow = null,Object? taps = null,Object? blockedTaps = null,Object? hintArrowId = freezed,Object? reward = freezed,}) {
  return _then(SessionState(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,hearts: null == hearts ? _self.hearts : hearts // ignore: cast_nullable_to_non_nullable
as int,initialHearts: null == initialHearts ? _self.initialHearts : initialHearts // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,freeUndosLeft: null == freeUndosLeft ? _self.freeUndosLeft : freeUndosLeft // ignore: cast_nullable_to_non_nullable
as int,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,freeHintsLeft: null == freeHintsLeft ? _self.freeHintsLeft : freeHintsLeft // ignore: cast_nullable_to_non_nullable
as int,flowMultiplier: null == flowMultiplier ? _self.flowMultiplier : flowMultiplier // ignore: cast_nullable_to_non_nullable
as int,flowFill: null == flowFill ? _self.flowFill : flowFill // ignore: cast_nullable_to_non_nullable
as double,bestFlow: null == bestFlow ? _self.bestFlow : bestFlow // ignore: cast_nullable_to_non_nullable
as int,taps: null == taps ? _self.taps : taps // ignore: cast_nullable_to_non_nullable
as int,blockedTaps: null == blockedTaps ? _self.blockedTaps : blockedTaps // ignore: cast_nullable_to_non_nullable
as int,hintArrowId: freezed == hintArrowId ? _self.hintArrowId : hintArrowId // ignore: cast_nullable_to_non_nullable
as int?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as LevelReward?,
  ));
}
/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LevelCopyWith<$Res> get level {
  
  return $LevelCopyWith<$Res>(_self.level, (value) {
    return _then(_self.copyWith(level: value));
  });
}
}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionState value)  $default,){
final _that = this;
switch (_that) {
case _SessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionState value)?  $default,){
final _that = this;
switch (_that) {
case _SessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Level level,  GameStatus status,  int hearts,  int initialHearts,  int remaining,  int total,  int stars,  int freeUndosLeft,  bool canUndo,  int freeHintsLeft,  int flowMultiplier,  double flowFill,  int bestFlow,  int taps,  int blockedTaps,  int? hintArrowId,  LevelReward? reward)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.level,_that.status,_that.hearts,_that.initialHearts,_that.remaining,_that.total,_that.stars,_that.freeUndosLeft,_that.canUndo,_that.freeHintsLeft,_that.flowMultiplier,_that.flowFill,_that.bestFlow,_that.taps,_that.blockedTaps,_that.hintArrowId,_that.reward);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Level level,  GameStatus status,  int hearts,  int initialHearts,  int remaining,  int total,  int stars,  int freeUndosLeft,  bool canUndo,  int freeHintsLeft,  int flowMultiplier,  double flowFill,  int bestFlow,  int taps,  int blockedTaps,  int? hintArrowId,  LevelReward? reward)  $default,) {final _that = this;
switch (_that) {
case _SessionState():
return $default(_that.level,_that.status,_that.hearts,_that.initialHearts,_that.remaining,_that.total,_that.stars,_that.freeUndosLeft,_that.canUndo,_that.freeHintsLeft,_that.flowMultiplier,_that.flowFill,_that.bestFlow,_that.taps,_that.blockedTaps,_that.hintArrowId,_that.reward);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Level level,  GameStatus status,  int hearts,  int initialHearts,  int remaining,  int total,  int stars,  int freeUndosLeft,  bool canUndo,  int freeHintsLeft,  int flowMultiplier,  double flowFill,  int bestFlow,  int taps,  int blockedTaps,  int? hintArrowId,  LevelReward? reward)?  $default,) {final _that = this;
switch (_that) {
case _SessionState() when $default != null:
return $default(_that.level,_that.status,_that.hearts,_that.initialHearts,_that.remaining,_that.total,_that.stars,_that.freeUndosLeft,_that.canUndo,_that.freeHintsLeft,_that.flowMultiplier,_that.flowFill,_that.bestFlow,_that.taps,_that.blockedTaps,_that.hintArrowId,_that.reward);case _:
  return null;

}
}

}

/// @nodoc


class _SessionState extends SessionState {
  const _SessionState({required this.level, required this.status, required this.hearts, required this.initialHearts, required this.remaining, required this.total, required this.stars, required this.freeUndosLeft, required this.canUndo, required this.freeHintsLeft, required this.flowMultiplier, required this.flowFill, required this.bestFlow, required this.taps, required this.blockedTaps, this.hintArrowId, this.reward}): super._();
  

@override final  Level level;
@override final  GameStatus status;
@override final  int hearts;
@override final  int initialHearts;
@override final  int remaining;
@override final  int total;
@override final  int stars;
@override final  int freeUndosLeft;
@override final  bool canUndo;
@override final  int freeHintsLeft;
@override final  int flowMultiplier;
@override final  double flowFill;
@override final  int bestFlow;
@override final  int taps;
@override final  int blockedTaps;
@override final  int? hintArrowId;
/// Set once the level is won (already paid into the wallet).
@override final  LevelReward? reward;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionStateCopyWith<_SessionState> get copyWith => __$SessionStateCopyWithImpl<_SessionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionState&&(identical(other.level, level) || other.level == level)&&(identical(other.status, status) || other.status == status)&&(identical(other.hearts, hearts) || other.hearts == hearts)&&(identical(other.initialHearts, initialHearts) || other.initialHearts == initialHearts)&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.total, total) || other.total == total)&&(identical(other.stars, stars) || other.stars == stars)&&(identical(other.freeUndosLeft, freeUndosLeft) || other.freeUndosLeft == freeUndosLeft)&&(identical(other.canUndo, canUndo) || other.canUndo == canUndo)&&(identical(other.freeHintsLeft, freeHintsLeft) || other.freeHintsLeft == freeHintsLeft)&&(identical(other.flowMultiplier, flowMultiplier) || other.flowMultiplier == flowMultiplier)&&(identical(other.flowFill, flowFill) || other.flowFill == flowFill)&&(identical(other.bestFlow, bestFlow) || other.bestFlow == bestFlow)&&(identical(other.taps, taps) || other.taps == taps)&&(identical(other.blockedTaps, blockedTaps) || other.blockedTaps == blockedTaps)&&(identical(other.hintArrowId, hintArrowId) || other.hintArrowId == hintArrowId)&&(identical(other.reward, reward) || other.reward == reward));
}


@override
int get hashCode {
    return Object.hash(runtimeType,level,status,hearts,initialHearts,remaining,total,stars,freeUndosLeft,canUndo,freeHintsLeft,flowMultiplier,flowFill,bestFlow,taps,blockedTaps,hintArrowId,reward);
}

@override
String toString() {
    return 'SessionState(level: $level, status: $status, hearts: $hearts, initialHearts: $initialHearts, remaining: $remaining, total: $total, stars: $stars, freeUndosLeft: $freeUndosLeft, canUndo: $canUndo, freeHintsLeft: $freeHintsLeft, flowMultiplier: $flowMultiplier, flowFill: $flowFill, bestFlow: $bestFlow, taps: $taps, blockedTaps: $blockedTaps, hintArrowId: $hintArrowId, reward: $reward)';
}


}

/// @nodoc
abstract mixin class _$SessionStateCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory _$SessionStateCopyWith(_SessionState value, $Res Function(_SessionState) _then) = __$SessionStateCopyWithImpl;
@override @useResult
$Res call({
 Level level, GameStatus status, int hearts, int initialHearts, int remaining, int total, int stars, int freeUndosLeft, bool canUndo, int freeHintsLeft, int flowMultiplier, double flowFill, int bestFlow, int taps, int blockedTaps, int? hintArrowId, LevelReward? reward
});


@override $LevelCopyWith<$Res> get level;

}
/// @nodoc
class __$SessionStateCopyWithImpl<$Res>
    implements _$SessionStateCopyWith<$Res> {
  __$SessionStateCopyWithImpl(this._self, this._then);

  final _SessionState _self;
  final $Res Function(_SessionState) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? status = null,Object? hearts = null,Object? initialHearts = null,Object? remaining = null,Object? total = null,Object? stars = null,Object? freeUndosLeft = null,Object? canUndo = null,Object? freeHintsLeft = null,Object? flowMultiplier = null,Object? flowFill = null,Object? bestFlow = null,Object? taps = null,Object? blockedTaps = null,Object? hintArrowId = freezed,Object? reward = freezed,}) {
  return _then(_SessionState(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as Level,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,hearts: null == hearts ? _self.hearts : hearts // ignore: cast_nullable_to_non_nullable
as int,initialHearts: null == initialHearts ? _self.initialHearts : initialHearts // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,stars: null == stars ? _self.stars : stars // ignore: cast_nullable_to_non_nullable
as int,freeUndosLeft: null == freeUndosLeft ? _self.freeUndosLeft : freeUndosLeft // ignore: cast_nullable_to_non_nullable
as int,canUndo: null == canUndo ? _self.canUndo : canUndo // ignore: cast_nullable_to_non_nullable
as bool,freeHintsLeft: null == freeHintsLeft ? _self.freeHintsLeft : freeHintsLeft // ignore: cast_nullable_to_non_nullable
as int,flowMultiplier: null == flowMultiplier ? _self.flowMultiplier : flowMultiplier // ignore: cast_nullable_to_non_nullable
as int,flowFill: null == flowFill ? _self.flowFill : flowFill // ignore: cast_nullable_to_non_nullable
as double,bestFlow: null == bestFlow ? _self.bestFlow : bestFlow // ignore: cast_nullable_to_non_nullable
as int,taps: null == taps ? _self.taps : taps // ignore: cast_nullable_to_non_nullable
as int,blockedTaps: null == blockedTaps ? _self.blockedTaps : blockedTaps // ignore: cast_nullable_to_non_nullable
as int,hintArrowId: freezed == hintArrowId ? _self.hintArrowId : hintArrowId // ignore: cast_nullable_to_non_nullable
as int?,reward: freezed == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as LevelReward?,
  ));
}

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LevelCopyWith<$Res> get level {
  
  return $LevelCopyWith<$Res>(_self.level, (value) {
    return _then(_self.copyWith(level: value));
  });
}
}

// dart format on
