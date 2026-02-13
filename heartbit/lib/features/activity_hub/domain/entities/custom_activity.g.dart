// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomActivityImpl _$$CustomActivityImplFromJson(Map<String, dynamic> json) =>
    _$CustomActivityImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] as String?,
      isTemporary: json['isTemporary'] as bool? ?? false,
    );

Map<String, dynamic> _$$CustomActivityImplToJson(
        _$CustomActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'category': instance.category,
      'isTemporary': instance.isTemporary,
    };
