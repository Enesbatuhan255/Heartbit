// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      status: json['status'] as String?,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      lastInteraction: json['lastInteraction'] == null
          ? null
          : DateTime.parse(json['lastInteraction'] as String),
      isOnline: json['isOnline'] as bool? ?? false,
      isSleeping: json['isSleeping'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'status': instance.status,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'lastInteraction': instance.lastInteraction?.toIso8601String(),
      'isOnline': instance.isOnline,
      'isSleeping': instance.isSleeping,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
