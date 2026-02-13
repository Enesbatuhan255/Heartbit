// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyTaskImpl _$$DailyTaskImplFromJson(Map<String, dynamic> json) =>
    _$DailyTaskImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      rewardXp: (json['rewardXp'] as num).toInt(),
      type: $enumDecode(_$TaskTypeEnumMap, json['type']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$DailyTaskImplToJson(_$DailyTaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'emoji': instance.emoji,
      'rewardXp': instance.rewardXp,
      'type': _$TaskTypeEnumMap[instance.type]!,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$TaskTypeEnumMap = {
  TaskType.mood: 'mood',
  TaskType.pet: 'pet',
  TaskType.social: 'social',
};
