// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BucketItemImpl _$$BucketItemImplFromJson(Map<String, dynamic> json) =>
    _$BucketItemImpl(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      matchedAt: DateTime.parse(json['matchedAt'] as String),
      status: json['status'] as String? ?? 'pending',
      plannedDate: json['plannedDate'] == null
          ? null
          : DateTime.parse(json['plannedDate'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$BucketItemImplToJson(_$BucketItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityId': instance.activityId,
      'matchedAt': instance.matchedAt.toIso8601String(),
      'status': instance.status,
      'plannedDate': instance.plannedDate?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
