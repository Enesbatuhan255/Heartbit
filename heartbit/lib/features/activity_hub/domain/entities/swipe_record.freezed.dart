// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swipe_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SwipeRecord _$SwipeRecordFromJson(Map<String, dynamic> json) {
  return _SwipeRecord.fromJson(json);
}

/// @nodoc
mixin _$SwipeRecord {
  String get activityId => throw _privateConstructorUsedError;
  String get odCiU4q9nSb => throw _privateConstructorUsedError;
  bool get liked => throw _privateConstructorUsedError;
  DateTime get swipedAt => throw _privateConstructorUsedError;

  /// Serializes this SwipeRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SwipeRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SwipeRecordCopyWith<SwipeRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwipeRecordCopyWith<$Res> {
  factory $SwipeRecordCopyWith(
          SwipeRecord value, $Res Function(SwipeRecord) then) =
      _$SwipeRecordCopyWithImpl<$Res, SwipeRecord>;
  @useResult
  $Res call(
      {String activityId, String odCiU4q9nSb, bool liked, DateTime swipedAt});
}

/// @nodoc
class _$SwipeRecordCopyWithImpl<$Res, $Val extends SwipeRecord>
    implements $SwipeRecordCopyWith<$Res> {
  _$SwipeRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SwipeRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityId = null,
    Object? odCiU4q9nSb = null,
    Object? liked = null,
    Object? swipedAt = null,
  }) {
    return _then(_value.copyWith(
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      odCiU4q9nSb: null == odCiU4q9nSb
          ? _value.odCiU4q9nSb
          : odCiU4q9nSb // ignore: cast_nullable_to_non_nullable
              as String,
      liked: null == liked
          ? _value.liked
          : liked // ignore: cast_nullable_to_non_nullable
              as bool,
      swipedAt: null == swipedAt
          ? _value.swipedAt
          : swipedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SwipeRecordImplCopyWith<$Res>
    implements $SwipeRecordCopyWith<$Res> {
  factory _$$SwipeRecordImplCopyWith(
          _$SwipeRecordImpl value, $Res Function(_$SwipeRecordImpl) then) =
      __$$SwipeRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String activityId, String odCiU4q9nSb, bool liked, DateTime swipedAt});
}

/// @nodoc
class __$$SwipeRecordImplCopyWithImpl<$Res>
    extends _$SwipeRecordCopyWithImpl<$Res, _$SwipeRecordImpl>
    implements _$$SwipeRecordImplCopyWith<$Res> {
  __$$SwipeRecordImplCopyWithImpl(
      _$SwipeRecordImpl _value, $Res Function(_$SwipeRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of SwipeRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activityId = null,
    Object? odCiU4q9nSb = null,
    Object? liked = null,
    Object? swipedAt = null,
  }) {
    return _then(_$SwipeRecordImpl(
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      odCiU4q9nSb: null == odCiU4q9nSb
          ? _value.odCiU4q9nSb
          : odCiU4q9nSb // ignore: cast_nullable_to_non_nullable
              as String,
      liked: null == liked
          ? _value.liked
          : liked // ignore: cast_nullable_to_non_nullable
              as bool,
      swipedAt: null == swipedAt
          ? _value.swipedAt
          : swipedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwipeRecordImpl implements _SwipeRecord {
  const _$SwipeRecordImpl(
      {required this.activityId,
      required this.odCiU4q9nSb,
      required this.liked,
      required this.swipedAt});

  factory _$SwipeRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwipeRecordImplFromJson(json);

  @override
  final String activityId;
  @override
  final String odCiU4q9nSb;
  @override
  final bool liked;
  @override
  final DateTime swipedAt;

  @override
  String toString() {
    return 'SwipeRecord(activityId: $activityId, odCiU4q9nSb: $odCiU4q9nSb, liked: $liked, swipedAt: $swipedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwipeRecordImpl &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.odCiU4q9nSb, odCiU4q9nSb) ||
                other.odCiU4q9nSb == odCiU4q9nSb) &&
            (identical(other.liked, liked) || other.liked == liked) &&
            (identical(other.swipedAt, swipedAt) ||
                other.swipedAt == swipedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, activityId, odCiU4q9nSb, liked, swipedAt);

  /// Create a copy of SwipeRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SwipeRecordImplCopyWith<_$SwipeRecordImpl> get copyWith =>
      __$$SwipeRecordImplCopyWithImpl<_$SwipeRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SwipeRecordImplToJson(
      this,
    );
  }
}

abstract class _SwipeRecord implements SwipeRecord {
  const factory _SwipeRecord(
      {required final String activityId,
      required final String odCiU4q9nSb,
      required final bool liked,
      required final DateTime swipedAt}) = _$SwipeRecordImpl;

  factory _SwipeRecord.fromJson(Map<String, dynamic> json) =
      _$SwipeRecordImpl.fromJson;

  @override
  String get activityId;
  @override
  String get odCiU4q9nSb;
  @override
  bool get liked;
  @override
  DateTime get swipedAt;

  /// Create a copy of SwipeRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwipeRecordImplCopyWith<_$SwipeRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
