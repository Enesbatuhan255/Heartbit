// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyQuestion _$DailyQuestionFromJson(Map<String, dynamic> json) {
  return _DailyQuestion.fromJson(json);
}

/// @nodoc
mixin _$DailyQuestion {
  String get id =>
      throw _privateConstructorUsedError; // Document ID (date: "2026-01-20")
  String get coupleId => throw _privateConstructorUsedError;
  String get questionId =>
      throw _privateConstructorUsedError; // "q_014" - for analytics, no repeats, premium
  String get questionText => throw _privateConstructorUsedError;
  String get date =>
      throw _privateConstructorUsedError; // UTC date string "yyyy-MM-dd"
  bool get locked =>
      throw _privateConstructorUsedError; // true = no more changes allowed
  String? get user1Answer => throw _privateConstructorUsedError;
  String? get user2Answer => throw _privateConstructorUsedError;
  DateTime? get user1AnsweredAt => throw _privateConstructorUsedError;
  DateTime? get user2AnsweredAt => throw _privateConstructorUsedError;
  String? get user1Reaction =>
      throw _privateConstructorUsedError; // 'heart', 'laugh', 'surprised'
  String? get user2Reaction => throw _privateConstructorUsedError;
  bool get xpClaimed => throw _privateConstructorUsedError; // Base XP claimed
  bool get syncXpClaimed => throw _privateConstructorUsedError;

  /// Serializes this DailyQuestion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyQuestionCopyWith<DailyQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyQuestionCopyWith<$Res> {
  factory $DailyQuestionCopyWith(
          DailyQuestion value, $Res Function(DailyQuestion) then) =
      _$DailyQuestionCopyWithImpl<$Res, DailyQuestion>;
  @useResult
  $Res call(
      {String id,
      String coupleId,
      String questionId,
      String questionText,
      String date,
      bool locked,
      String? user1Answer,
      String? user2Answer,
      DateTime? user1AnsweredAt,
      DateTime? user2AnsweredAt,
      String? user1Reaction,
      String? user2Reaction,
      bool xpClaimed,
      bool syncXpClaimed});
}

/// @nodoc
class _$DailyQuestionCopyWithImpl<$Res, $Val extends DailyQuestion>
    implements $DailyQuestionCopyWith<$Res> {
  _$DailyQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? questionId = null,
    Object? questionText = null,
    Object? date = null,
    Object? locked = null,
    Object? user1Answer = freezed,
    Object? user2Answer = freezed,
    Object? user1AnsweredAt = freezed,
    Object? user2AnsweredAt = freezed,
    Object? user1Reaction = freezed,
    Object? user2Reaction = freezed,
    Object? xpClaimed = null,
    Object? syncXpClaimed = null,
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
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      locked: null == locked
          ? _value.locked
          : locked // ignore: cast_nullable_to_non_nullable
              as bool,
      user1Answer: freezed == user1Answer
          ? _value.user1Answer
          : user1Answer // ignore: cast_nullable_to_non_nullable
              as String?,
      user2Answer: freezed == user2Answer
          ? _value.user2Answer
          : user2Answer // ignore: cast_nullable_to_non_nullable
              as String?,
      user1AnsweredAt: freezed == user1AnsweredAt
          ? _value.user1AnsweredAt
          : user1AnsweredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user2AnsweredAt: freezed == user2AnsweredAt
          ? _value.user2AnsweredAt
          : user2AnsweredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user1Reaction: freezed == user1Reaction
          ? _value.user1Reaction
          : user1Reaction // ignore: cast_nullable_to_non_nullable
              as String?,
      user2Reaction: freezed == user2Reaction
          ? _value.user2Reaction
          : user2Reaction // ignore: cast_nullable_to_non_nullable
              as String?,
      xpClaimed: null == xpClaimed
          ? _value.xpClaimed
          : xpClaimed // ignore: cast_nullable_to_non_nullable
              as bool,
      syncXpClaimed: null == syncXpClaimed
          ? _value.syncXpClaimed
          : syncXpClaimed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyQuestionImplCopyWith<$Res>
    implements $DailyQuestionCopyWith<$Res> {
  factory _$$DailyQuestionImplCopyWith(
          _$DailyQuestionImpl value, $Res Function(_$DailyQuestionImpl) then) =
      __$$DailyQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String coupleId,
      String questionId,
      String questionText,
      String date,
      bool locked,
      String? user1Answer,
      String? user2Answer,
      DateTime? user1AnsweredAt,
      DateTime? user2AnsweredAt,
      String? user1Reaction,
      String? user2Reaction,
      bool xpClaimed,
      bool syncXpClaimed});
}

/// @nodoc
class __$$DailyQuestionImplCopyWithImpl<$Res>
    extends _$DailyQuestionCopyWithImpl<$Res, _$DailyQuestionImpl>
    implements _$$DailyQuestionImplCopyWith<$Res> {
  __$$DailyQuestionImplCopyWithImpl(
      _$DailyQuestionImpl _value, $Res Function(_$DailyQuestionImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coupleId = null,
    Object? questionId = null,
    Object? questionText = null,
    Object? date = null,
    Object? locked = null,
    Object? user1Answer = freezed,
    Object? user2Answer = freezed,
    Object? user1AnsweredAt = freezed,
    Object? user2AnsweredAt = freezed,
    Object? user1Reaction = freezed,
    Object? user2Reaction = freezed,
    Object? xpClaimed = null,
    Object? syncXpClaimed = null,
  }) {
    return _then(_$DailyQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coupleId: null == coupleId
          ? _value.coupleId
          : coupleId // ignore: cast_nullable_to_non_nullable
              as String,
      questionId: null == questionId
          ? _value.questionId
          : questionId // ignore: cast_nullable_to_non_nullable
              as String,
      questionText: null == questionText
          ? _value.questionText
          : questionText // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      locked: null == locked
          ? _value.locked
          : locked // ignore: cast_nullable_to_non_nullable
              as bool,
      user1Answer: freezed == user1Answer
          ? _value.user1Answer
          : user1Answer // ignore: cast_nullable_to_non_nullable
              as String?,
      user2Answer: freezed == user2Answer
          ? _value.user2Answer
          : user2Answer // ignore: cast_nullable_to_non_nullable
              as String?,
      user1AnsweredAt: freezed == user1AnsweredAt
          ? _value.user1AnsweredAt
          : user1AnsweredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user2AnsweredAt: freezed == user2AnsweredAt
          ? _value.user2AnsweredAt
          : user2AnsweredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      user1Reaction: freezed == user1Reaction
          ? _value.user1Reaction
          : user1Reaction // ignore: cast_nullable_to_non_nullable
              as String?,
      user2Reaction: freezed == user2Reaction
          ? _value.user2Reaction
          : user2Reaction // ignore: cast_nullable_to_non_nullable
              as String?,
      xpClaimed: null == xpClaimed
          ? _value.xpClaimed
          : xpClaimed // ignore: cast_nullable_to_non_nullable
              as bool,
      syncXpClaimed: null == syncXpClaimed
          ? _value.syncXpClaimed
          : syncXpClaimed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyQuestionImpl extends _DailyQuestion {
  const _$DailyQuestionImpl(
      {required this.id,
      required this.coupleId,
      required this.questionId,
      required this.questionText,
      required this.date,
      this.locked = false,
      this.user1Answer,
      this.user2Answer,
      this.user1AnsweredAt,
      this.user2AnsweredAt,
      this.user1Reaction,
      this.user2Reaction,
      this.xpClaimed = false,
      this.syncXpClaimed = false})
      : super._();

  factory _$DailyQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyQuestionImplFromJson(json);

  @override
  final String id;
// Document ID (date: "2026-01-20")
  @override
  final String coupleId;
  @override
  final String questionId;
// "q_014" - for analytics, no repeats, premium
  @override
  final String questionText;
  @override
  final String date;
// UTC date string "yyyy-MM-dd"
  @override
  @JsonKey()
  final bool locked;
// true = no more changes allowed
  @override
  final String? user1Answer;
  @override
  final String? user2Answer;
  @override
  final DateTime? user1AnsweredAt;
  @override
  final DateTime? user2AnsweredAt;
  @override
  final String? user1Reaction;
// 'heart', 'laugh', 'surprised'
  @override
  final String? user2Reaction;
  @override
  @JsonKey()
  final bool xpClaimed;
// Base XP claimed
  @override
  @JsonKey()
  final bool syncXpClaimed;

  @override
  String toString() {
    return 'DailyQuestion(id: $id, coupleId: $coupleId, questionId: $questionId, questionText: $questionText, date: $date, locked: $locked, user1Answer: $user1Answer, user2Answer: $user2Answer, user1AnsweredAt: $user1AnsweredAt, user2AnsweredAt: $user2AnsweredAt, user1Reaction: $user1Reaction, user2Reaction: $user2Reaction, xpClaimed: $xpClaimed, syncXpClaimed: $syncXpClaimed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.coupleId, coupleId) ||
                other.coupleId == coupleId) &&
            (identical(other.questionId, questionId) ||
                other.questionId == questionId) &&
            (identical(other.questionText, questionText) ||
                other.questionText == questionText) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.locked, locked) || other.locked == locked) &&
            (identical(other.user1Answer, user1Answer) ||
                other.user1Answer == user1Answer) &&
            (identical(other.user2Answer, user2Answer) ||
                other.user2Answer == user2Answer) &&
            (identical(other.user1AnsweredAt, user1AnsweredAt) ||
                other.user1AnsweredAt == user1AnsweredAt) &&
            (identical(other.user2AnsweredAt, user2AnsweredAt) ||
                other.user2AnsweredAt == user2AnsweredAt) &&
            (identical(other.user1Reaction, user1Reaction) ||
                other.user1Reaction == user1Reaction) &&
            (identical(other.user2Reaction, user2Reaction) ||
                other.user2Reaction == user2Reaction) &&
            (identical(other.xpClaimed, xpClaimed) ||
                other.xpClaimed == xpClaimed) &&
            (identical(other.syncXpClaimed, syncXpClaimed) ||
                other.syncXpClaimed == syncXpClaimed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      coupleId,
      questionId,
      questionText,
      date,
      locked,
      user1Answer,
      user2Answer,
      user1AnsweredAt,
      user2AnsweredAt,
      user1Reaction,
      user2Reaction,
      xpClaimed,
      syncXpClaimed);

  /// Create a copy of DailyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyQuestionImplCopyWith<_$DailyQuestionImpl> get copyWith =>
      __$$DailyQuestionImplCopyWithImpl<_$DailyQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyQuestionImplToJson(
      this,
    );
  }
}

abstract class _DailyQuestion extends DailyQuestion {
  const factory _DailyQuestion(
      {required final String id,
      required final String coupleId,
      required final String questionId,
      required final String questionText,
      required final String date,
      final bool locked,
      final String? user1Answer,
      final String? user2Answer,
      final DateTime? user1AnsweredAt,
      final DateTime? user2AnsweredAt,
      final String? user1Reaction,
      final String? user2Reaction,
      final bool xpClaimed,
      final bool syncXpClaimed}) = _$DailyQuestionImpl;
  const _DailyQuestion._() : super._();

  factory _DailyQuestion.fromJson(Map<String, dynamic> json) =
      _$DailyQuestionImpl.fromJson;

  @override
  String get id; // Document ID (date: "2026-01-20")
  @override
  String get coupleId;
  @override
  String get questionId; // "q_014" - for analytics, no repeats, premium
  @override
  String get questionText;
  @override
  String get date; // UTC date string "yyyy-MM-dd"
  @override
  bool get locked; // true = no more changes allowed
  @override
  String? get user1Answer;
  @override
  String? get user2Answer;
  @override
  DateTime? get user1AnsweredAt;
  @override
  DateTime? get user2AnsweredAt;
  @override
  String? get user1Reaction; // 'heart', 'laugh', 'surprised'
  @override
  String? get user2Reaction;
  @override
  bool get xpClaimed; // Base XP claimed
  @override
  bool get syncXpClaimed;

  /// Create a copy of DailyQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyQuestionImplCopyWith<_$DailyQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
