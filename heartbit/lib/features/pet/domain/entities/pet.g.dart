// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PetImpl _$$PetImplFromJson(Map<String, dynamic> json) => _$PetImpl(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      name: json['name'] as String? ?? 'Baby Egg',
      level: (json['level'] as num?)?.toInt() ?? 1,
      experience: (json['experience'] as num?)?.toDouble() ?? 0.0,
      totalXp: (json['totalXp'] as num?)?.toDouble() ?? 0.0,
      hunger: (json['hunger'] as num?)?.toDouble() ?? 100.0,
      happiness: (json['happiness'] as num?)?.toDouble() ?? 100.0,
      lastFed: json['lastFed'] == null
          ? null
          : DateTime.parse(json['lastFed'] as String),
      lastInteracted: json['lastInteracted'] == null
          ? null
          : DateTime.parse(json['lastInteracted'] as String),
      lastInteraction: json['lastInteraction'] == null
          ? null
          : PetInteraction.fromJson(
              json['lastInteraction'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PetImplToJson(_$PetImpl instance) => <String, dynamic>{
      'id': instance.id,
      'coupleId': instance.coupleId,
      'name': instance.name,
      'level': instance.level,
      'experience': instance.experience,
      'totalXp': instance.totalXp,
      'hunger': instance.hunger,
      'happiness': instance.happiness,
      'lastFed': instance.lastFed?.toIso8601String(),
      'lastInteracted': instance.lastInteracted?.toIso8601String(),
      'lastInteraction': instance.lastInteraction,
    };

_$PetInteractionImpl _$$PetInteractionImplFromJson(Map<String, dynamic> json) =>
    _$PetInteractionImpl(
      userId: json['userId'] as String,
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$PetInteractionImplToJson(
        _$PetInteractionImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'type': instance.type,
      'timestamp': instance.timestamp.toIso8601String(),
    };
