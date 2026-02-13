// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bucket_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BucketItem _$BucketItemFromJson(Map<String, dynamic> json) {
  return _BucketItem.fromJson(json);
}

/// @nodoc
mixin _$BucketItem {
  String get id => throw _privateConstructorUsedError;
  String get activityId => throw _privateConstructorUsedError;
  DateTime get matchedAt => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, planned, completed
  DateTime? get plannedDate => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this BucketItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BucketItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BucketItemCopyWith<BucketItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BucketItemCopyWith<$Res> {
  factory $BucketItemCopyWith(
          BucketItem value, $Res Function(BucketItem) then) =
      _$BucketItemCopyWithImpl<$Res, BucketItem>;
  @useResult
  $Res call(
      {String id,
      String activityId,
      DateTime matchedAt,
      String status,
      DateTime? plannedDate,
      DateTime? completedAt});
}

/// @nodoc
class _$BucketItemCopyWithImpl<$Res, $Val extends BucketItem>
    implements $BucketItemCopyWith<$Res> {
  _$BucketItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BucketItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? matchedAt = null,
    Object? status = null,
    Object? plannedDate = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      matchedAt: null == matchedAt
          ? _value.matchedAt
          : matchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      plannedDate: freezed == plannedDate
          ? _value.plannedDate
          : plannedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BucketItemImplCopyWith<$Res>
    implements $BucketItemCopyWith<$Res> {
  factory _$$BucketItemImplCopyWith(
          _$BucketItemImpl value, $Res Function(_$BucketItemImpl) then) =
      __$$BucketItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String activityId,
      DateTime matchedAt,
      String status,
      DateTime? plannedDate,
      DateTime? completedAt});
}

/// @nodoc
class __$$BucketItemImplCopyWithImpl<$Res>
    extends _$BucketItemCopyWithImpl<$Res, _$BucketItemImpl>
    implements _$$BucketItemImplCopyWith<$Res> {
  __$$BucketItemImplCopyWithImpl(
      _$BucketItemImpl _value, $Res Function(_$BucketItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of BucketItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? matchedAt = null,
    Object? status = null,
    Object? plannedDate = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_$BucketItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      matchedAt: null == matchedAt
          ? _value.matchedAt
          : matchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      plannedDate: freezed == plannedDate
          ? _value.plannedDate
          : plannedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BucketItemImpl implements _BucketItem {
  const _$BucketItemImpl(
      {required this.id,
      required this.activityId,
      required this.matchedAt,
      this.status = 'pending',
      this.plannedDate,
      this.completedAt});

  factory _$BucketItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BucketItemImplFromJson(json);

  @override
  final String id;
  @override
  final String activityId;
  @override
  final DateTime matchedAt;
  @override
  @JsonKey()
  final String status;
// pending, planned, completed
  @override
  final DateTime? plannedDate;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'BucketItem(id: $id, activityId: $activityId, matchedAt: $matchedAt, status: $status, plannedDate: $plannedDate, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BucketItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.matchedAt, matchedAt) ||
                other.matchedAt == matchedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.plannedDate, plannedDate) ||
                other.plannedDate == plannedDate) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, activityId, matchedAt, status, plannedDate, completedAt);

  /// Create a copy of BucketItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BucketItemImplCopyWith<_$BucketItemImpl> get copyWith =>
      __$$BucketItemImplCopyWithImpl<_$BucketItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BucketItemImplToJson(
      this,
    );
  }
}

abstract class _BucketItem implements BucketItem {
  const factory _BucketItem(
      {required final String id,
      required final String activityId,
      required final DateTime matchedAt,
      final String status,
      final DateTime? plannedDate,
      final DateTime? completedAt}) = _$BucketItemImpl;

  factory _BucketItem.fromJson(Map<String, dynamic> json) =
      _$BucketItemImpl.fromJson;

  @override
  String get id;
  @override
  String get activityId;
  @override
  DateTime get matchedAt;
  @override
  String get status; // pending, planned, completed
  @override
  DateTime? get plannedDate;
  @override
  DateTime? get completedAt;

  /// Create a copy of BucketItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BucketItemImplCopyWith<_$BucketItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
