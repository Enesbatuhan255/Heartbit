// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyQuestionImpl _$$DailyQuestionImplFromJson(Map<String, dynamic> json) =>
    _$DailyQuestionImpl(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      questionId: json['questionId'] as String,
      questionText: json['questionText'] as String,
      date: json['date'] as String,
      locked: json['locked'] as bool? ?? false,
      user1Answer: json['user1Answer'] as String?,
      user2Answer: json['user2Answer'] as String?,
      user1AnsweredAt: json['user1AnsweredAt'] == null
          ? null
          : DateTime.parse(json['user1AnsweredAt'] as String),
      user2AnsweredAt: json['user2AnsweredAt'] == null
          ? null
          : DateTime.parse(json['user2AnsweredAt'] as String),
      user1Reaction: json['user1Reaction'] as String?,
      user2Reaction: json['user2Reaction'] as String?,
      xpClaimed: json['xpClaimed'] as bool? ?? false,
      syncXpClaimed: json['syncXpClaimed'] as bool? ?? false,
    );

Map<String, dynamic> _$$DailyQuestionImplToJson(_$DailyQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coupleId': instance.coupleId,
      'questionId': instance.questionId,
      'questionText': instance.questionText,
      'date': instance.date,
      'locked': instance.locked,
      'user1Answer': instance.user1Answer,
      'user2Answer': instance.user2Answer,
      'user1AnsweredAt': instance.user1AnsweredAt?.toIso8601String(),
      'user2AnsweredAt': instance.user2AnsweredAt?.toIso8601String(),
      'user1Reaction': instance.user1Reaction,
      'user2Reaction': instance.user2Reaction,
      'xpClaimed': instance.xpClaimed,
      'syncXpClaimed': instance.syncXpClaimed,
    };
