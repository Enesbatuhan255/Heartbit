// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SwipeSessionImpl _$$SwipeSessionImplFromJson(Map<String, dynamic> json) =>
    _$SwipeSessionImpl(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      selectedCategories: (json['selectedCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      swipedCount: (json['swipedCount'] as num?)?.toInt() ?? 0,
      matchCount: (json['matchCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SwipeSessionImplToJson(_$SwipeSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coupleId': instance.coupleId,
      'selectedCategories': instance.selectedCategories,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'totalCards': instance.totalCards,
      'swipedCount': instance.swipedCount,
      'matchCount': instance.matchCount,
    };

_$SwipeRecordImpl _$$SwipeRecordImplFromJson(Map<String, dynamic> json) =>
    _$SwipeRecordImpl(
      activityId: json['activityId'] as String,
      activityType: json['activityType'] as String,
      userId: json['userId'] as String,
      direction: json['direction'] as String,
      sessionId: json['sessionId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$SwipeRecordImplToJson(_$SwipeRecordImpl instance) =>
    <String, dynamic>{
      'activityId': instance.activityId,
      'activityType': instance.activityType,
      'userId': instance.userId,
      'direction': instance.direction,
      'sessionId': instance.sessionId,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_$ActivityMatchImpl _$$ActivityMatchImplFromJson(Map<String, dynamic> json) =>
    _$ActivityMatchImpl(
      id: json['id'] as String,
      activityId: json['activityId'] as String,
      activityType: json['activityType'] as String,
      activityTitle: json['activityTitle'] as String,
      matchedAt: DateTime.parse(json['matchedAt'] as String),
      status: json['status'] as String? ?? 'pending',
      plannedDate: json['plannedDate'] == null
          ? null
          : DateTime.parse(json['plannedDate'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$ActivityMatchImplToJson(_$ActivityMatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activityId': instance.activityId,
      'activityType': instance.activityType,
      'activityTitle': instance.activityTitle,
      'matchedAt': instance.matchedAt.toIso8601String(),
      'status': instance.status,
      'plannedDate': instance.plannedDate?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };
