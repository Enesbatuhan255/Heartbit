// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swipe_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SwipeSession _$SwipeSessionFromJson(Map<String, dynamic> json) {
  return _SwipeSession.fromJson(json);
}

/// @nodoc
mixin _$SwipeSession {
  String get id => throw _privateConstructorUsedError;
  String get coupleId => throw _privateConstructorUsedError;
  List<String> get selectedCategories => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get totalCards => throw _privateConstructorUsedError;
  int get swipedCount => throw _privateConstructorUsedError;
  int get matchCount => throw _privateConstructorUsedError;

  /// Serializes this SwipeSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SwipeSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SwipeSessionCopyWith<SwipeSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwipeSessionCopyWith<$Res> {
  factory $SwipeSessionCopyWith(
          SwipeSession value, $Res Function(SwipeSession) then) =
      _$SwipeSessionCopyWithImpl<$Res, SwipeSession>;
  @useResult
  $Res call(
      {String id,
      String coupleId,
      List<String> selectedCategories,
      DateTime startedAt,
      DateTime? completedAt,
      int totalCards,
      int swipedCount,
      int matchCount});
}

/// @nodoc
class _$SwipeSessionCopyWithImpl<$Res, $Val extends SwipeSession>
    implements $SwipeSessionCopyWith<$Res> {
  _$SwipeSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SwipeSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? selectedCategories = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? totalCards = null,
    Object? swipedCount = null,
    Object? matchCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coupleId: null == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedCategories: null == selectedCategories
          ? _value.selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalCards: null == totalCards
          ? _value.totalCards
          : totalCards // ignore: cast_nullable_to_non_nullable
              as int,
      swipedCount: null == swipedCount
          ? _value.swipedCount
          : swipedCount // ignore: cast_nullable_to_non_nullable
              as int,
      matchCount: null == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SwipeSessionImplCopyWith<$Res>
    implements $SwipeSessionCopyWith<$Res> {
  factory _$$SwipeSessionImplCopyWith(
          _$SwipeSessionImpl value, $Res Function(_$SwipeSessionImpl) then) =
      __$$SwipeSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String coupleId,
      List<String> selectedCategories,
      DateTime startedAt,
      DateTime? completedAt,
      int totalCards,
      int swipedCount,
      int matchCount});
}

/// @nodoc
class __$$SwipeSessionImplCopyWithImpl<$Res>
    extends _$SwipeSessionCopyWithImpl<$Res, _$SwipeSessionImpl>
    implements _$$SwipeSessionImplCopyWith<$Res> {
  __$$SwipeSessionImplCopyWithImpl(
      _$SwipeSessionImpl _value, $Res Function(_$SwipeSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SwipeSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? selectedCategories = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? totalCards = null,
    Object? swipedCount = null,
    Object? matchCount = null,
  }) {
    return _then(_$SwipeSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coupleId: null == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedCategories: null == selectedCategories
          ? _value._selectedCategories
          : selectedCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalCards: null == totalCards
          ? _value.totalCards
          : totalCards // ignore: cast_nullable_to_non_nullable
              as int,
      swipedCount: null == swipedCount
          ? _value.swipedCount
          : swipedCount // ignore: cast_nullable_to_non_nullable
              as int,
      matchCount: null == matchCount
          ? _value.matchCount
          : matchCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwipeSessionImpl implements _SwipeSession {
  const _$SwipeSessionImpl(
      {required this.id,
      required this.coupleId,
      required final List<String> selectedCategories,
      required this.startedAt,
      this.completedAt,
      this.totalCards = 0,
      this.swipedCount = 0,
      this.matchCount = 0})
      : _selectedCategories = selectedCategories;

  factory _$SwipeSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwipeSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String coupleId;
  final List<String> _selectedCategories;
  @override
  List<String> get selectedCategories {
    if (_selectedCategories is EqualUnmodifiableListView)
      return _selectedCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedCategories);
  }

  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final int totalCards;
  @override
  @JsonKey()
  final int swipedCount;
  @override
  @JsonKey()
  final int matchCount;

  @override
  String toString() {
    return 'SwipeSession(id: $id, coupleId: $coupleId, selectedCategories: $selectedCategories, startedAt: $startedAt, completedAt: $completedAt, totalCards: $totalCards, swipedCount: $swipedCount, matchCount: $matchCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwipeSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.coupleId, coupleId) ||
                other.coupleId == coupleId) &&
            const DeepCollectionEquality()
                .equals(other._selectedCategories, _selectedCategories) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.totalCards, totalCards) ||
                other.totalCards == totalCards) &&
            (identical(other.swipedCount, swipedCount) ||
                other.swipedCount == swipedCount) &&
            (identical(other.matchCount, matchCount) ||
                other.matchCount == matchCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      coupleId,
      const DeepCollectionEquality().hash(_selectedCategories),
      startedAt,
      completedAt,
      totalCards,
      swipedCount,
      matchCount);

  /// Create a copy of SwipeSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SwipeSessionImplCopyWith<_$SwipeSessionImpl> get copyWith =>
      __$$SwipeSessionImplCopyWithImpl<_$SwipeSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SwipeSessionImplToJson(
      this,
    );
  }
}

abstract class _SwipeSession implements SwipeSession {
  const factory _SwipeSession(
      {required final String id,
      required final String coupleId,
      required final List<String> selectedCategories,
      required final DateTime startedAt,
      final DateTime? completedAt,
      final int totalCards,
      final int swipedCount,
      final int matchCount}) = _$SwipeSessionImpl;

  factory _SwipeSession.fromJson(Map<String, dynamic> json) =
      _$SwipeSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get coupleId;
  @override
  List<String> get selectedCategories;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;
  @override
  int get totalCards;
  @override
  int get swipedCount;
  @override
  int get matchCount;

  /// Create a copy of SwipeSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwipeSessionImplCopyWith<_$SwipeSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SwipeRecord _$SwipeRecordFromJson(Map<String, dynamic> json) {
  return _SwipeRecord.fromJson(json);
}

/// @nodoc
mixin _$SwipeRecord {
  String get activityId => throw _privateConstructorUsedError;
  String get activityType =>
      throw _privateConstructorUsedError; // 'global' | 'custom'
  String get userId => throw _privateConstructorUsedError;
  String get direction =>
      throw _privateConstructorUsedError; // 'right' | 'left'
  String get sessionId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

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
      {String activityId,
      String activityType,
      String userId,
      String direction,
      String sessionId,
      DateTime timestamp});
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
    Object? activityType = null,
    Object? userId = null,
    Object? direction = null,
    Object? sessionId = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
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
      {String activityId,
      String activityType,
      String userId,
      String direction,
      String sessionId,
      DateTime timestamp});
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
    Object? activityType = null,
    Object? userId = null,
    Object? direction = null,
    Object? sessionId = null,
    Object? timestamp = null,
  }) {
    return _then(_$SwipeRecordImpl(
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      direction: null == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwipeRecordImpl implements _SwipeRecord {
  const _$SwipeRecordImpl(
      {required this.activityId,
      required this.activityType,
      required this.userId,
      required this.direction,
      required this.sessionId,
      required this.timestamp});

  factory _$SwipeRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwipeRecordImplFromJson(json);

  @override
  final String activityId;
  @override
  final String activityType;
// 'global' | 'custom'
  @override
  final String userId;
  @override
  final String direction;
// 'right' | 'left'
  @override
  final String sessionId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SwipeRecord(activityId: $activityId, activityType: $activityType, userId: $userId, direction: $direction, sessionId: $sessionId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwipeRecordImpl &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, activityId, activityType, userId,
      direction, sessionId, timestamp);

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
      required final String activityType,
      required final String userId,
      required final String direction,
      required final String sessionId,
      required final DateTime timestamp}) = _$SwipeRecordImpl;

  factory _SwipeRecord.fromJson(Map<String, dynamic> json) =
      _$SwipeRecordImpl.fromJson;

  @override
  String get activityId;
  @override
  String get activityType; // 'global' | 'custom'
  @override
  String get userId;
  @override
  String get direction; // 'right' | 'left'
  @override
  String get sessionId;
  @override
  DateTime get timestamp;

  /// Create a copy of SwipeRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwipeRecordImplCopyWith<_$SwipeRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityMatch _$ActivityMatchFromJson(Map<String, dynamic> json) {
  return _ActivityMatch.fromJson(json);
}

/// @nodoc
mixin _$ActivityMatch {
  String get id => throw _privateConstructorUsedError;
  String get activityId => throw _privateConstructorUsedError;
  String get activityType =>
      throw _privateConstructorUsedError; // 'global' | 'custom'
  String get activityTitle => throw _privateConstructorUsedError;
  DateTime get matchedAt => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'pending' | 'planned' | 'completed'
  DateTime? get plannedDate => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this ActivityMatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityMatchCopyWith<ActivityMatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityMatchCopyWith<$Res> {
  factory $ActivityMatchCopyWith(
          ActivityMatch value, $Res Function(ActivityMatch) then) =
      _$ActivityMatchCopyWithImpl<$Res, ActivityMatch>;
  @useResult
  $Res call(
      {String id,
      String activityId,
      String activityType,
      String activityTitle,
      DateTime matchedAt,
      String status,
      DateTime? plannedDate,
      DateTime? completedAt});
}

/// @nodoc
class _$ActivityMatchCopyWithImpl<$Res, $Val extends ActivityMatch>
    implements $ActivityMatchCopyWith<$Res> {
  _$ActivityMatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? activityType = null,
    Object? activityTitle = null,
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
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      activityTitle: null == activityTitle
          ? _value.activityTitle
          : activityTitle // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ActivityMatchImplCopyWith<$Res>
    implements $ActivityMatchCopyWith<$Res> {
  factory _$$ActivityMatchImplCopyWith(
          _$ActivityMatchImpl value, $Res Function(_$ActivityMatchImpl) then) =
      __$$ActivityMatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String activityId,
      String activityType,
      String activityTitle,
      DateTime matchedAt,
      String status,
      DateTime? plannedDate,
      DateTime? completedAt});
}

/// @nodoc
class __$$ActivityMatchImplCopyWithImpl<$Res>
    extends _$ActivityMatchCopyWithImpl<$Res, _$ActivityMatchImpl>
    implements _$$ActivityMatchImplCopyWith<$Res> {
  __$$ActivityMatchImplCopyWithImpl(
      _$ActivityMatchImpl _value, $Res Function(_$ActivityMatchImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityMatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityId = null,
    Object? activityType = null,
    Object? activityTitle = null,
    Object? matchedAt = null,
    Object? status = null,
    Object? plannedDate = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(_$ActivityMatchImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      activityTitle: null == activityTitle
          ? _value.activityTitle
          : activityTitle // ignore: cast_nullable_to_non_nullable
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
class _$ActivityMatchImpl implements _ActivityMatch {
  const _$ActivityMatchImpl(
      {required this.id,
      required this.activityId,
      required this.activityType,
      required this.activityTitle,
      required this.matchedAt,
      this.status = 'pending',
      this.plannedDate,
      this.completedAt});

  factory _$ActivityMatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityMatchImplFromJson(json);

  @override
  final String id;
  @override
  final String activityId;
  @override
  final String activityType;
// 'global' | 'custom'
  @override
  final String activityTitle;
  @override
  final DateTime matchedAt;
  @override
  @JsonKey()
  final String status;
// 'pending' | 'planned' | 'completed'
  @override
  final DateTime? plannedDate;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'ActivityMatch(id: $id, activityId: $activityId, activityType: $activityType, activityTitle: $activityTitle, matchedAt: $matchedAt, status: $status, plannedDate: $plannedDate, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityMatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.activityTitle, activityTitle) ||
                other.activityTitle == activityTitle) &&
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
  int get hashCode => Object.hash(runtimeType, id, activityId, activityType,
      activityTitle, matchedAt, status, plannedDate, completedAt);

  /// Create a copy of ActivityMatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityMatchImplCopyWith<_$ActivityMatchImpl> get copyWith =>
      __$$ActivityMatchImplCopyWithImpl<_$ActivityMatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityMatchImplToJson(
      this,
    );
  }
}

abstract class _ActivityMatch implements ActivityMatch {
  const factory _ActivityMatch(
      {required final String id,
      required final String activityId,
      required final String activityType,
      required final String activityTitle,
      required final DateTime matchedAt,
      final String status,
      final DateTime? plannedDate,
      final DateTime? completedAt}) = _$ActivityMatchImpl;

  factory _ActivityMatch.fromJson(Map<String, dynamic> json) =
      _$ActivityMatchImpl.fromJson;

  @override
  String get id;
  @override
  String get activityId;
  @override
  String get activityType; // 'global' | 'custom'
  @override
  String get activityTitle;
  @override
  DateTime get matchedAt;
  @override
  String get status; // 'pending' | 'planned' | 'completed'
  @override
  DateTime? get plannedDate;
  @override
  DateTime? get completedAt;

  /// Create a copy of ActivityMatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityMatchImplCopyWith<_$ActivityMatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
