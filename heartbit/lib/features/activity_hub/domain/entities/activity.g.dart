// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityImpl _$$ActivityImplFromJson(Map<String, dynamic> json) =>
    _$ActivityImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      estimatedTime: json['estimatedTime'] as String? ?? '1-2 hours',
      budgetLevel: (json['budgetLevel'] as num?)?.toInt() ?? 2,
      intensityLevel: (json['intensityLevel'] as num?)?.toInt() ?? 2,
      moods:
          (json['moods'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      activityType: json['activityType'] as String? ?? 'global',
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$ActivityImplToJson(_$ActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'estimatedTime': instance.estimatedTime,
      'budgetLevel': instance.budgetLevel,
      'intensityLevel': instance.intensityLevel,
      'moods': instance.moods,
      'tags': instance.tags,
      'activityType': instance.activityType,
      'isActive': instance.isActive,
    };
