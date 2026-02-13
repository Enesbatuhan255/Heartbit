// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SwipeRecordImpl _$$SwipeRecordImplFromJson(Map<String, dynamic> json) =>
    _$SwipeRecordImpl(
      activityId: json['activityId'] as String,
      odCiU4q9nSb: json['odCiU4q9nSb'] as String,
      liked: json['liked'] as bool,
      swipedAt: DateTime.parse(json['swipedAt'] as String),
    );

Map<String, dynamic> _$$SwipeRecordImplToJson(_$SwipeRecordImpl instance) =>
    <String, dynamic>{
      'activityId': instance.activityId,
      'odCiU4q9nSb': instance.odCiU4q9nSb,
      'liked': instance.liked,
      'swipedAt': instance.swipedAt.toIso8601String(),
    };
