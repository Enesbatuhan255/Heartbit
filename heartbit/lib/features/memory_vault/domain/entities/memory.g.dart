// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemoryImpl _$$MemoryImplFromJson(Map<String, dynamic> json) => _$MemoryImpl(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      imageUrl: json['imageUrl'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      title: json['title'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$$MemoryImplToJson(_$MemoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coupleId': instance.coupleId,
      'imageUrl': instance.imageUrl,
      'date': instance.date.toIso8601String(),
      'description': instance.description,
      'title': instance.title,
      'createdAt': instance.createdAt?.toIso8601String(),
      'createdBy': instance.createdBy,
    };
