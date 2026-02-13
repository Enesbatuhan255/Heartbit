// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DraftSessionImpl _$$DraftSessionImplFromJson(Map<String, dynamic> json) =>
    _$DraftSessionImpl(
      selectedCategories: (json['selectedCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      budgetLevels: (json['budgetLevels'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      durationTiers: (json['durationTiers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      customActivities: (json['customActivities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      readyUsers: (json['readyUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lobbyUsers: (json['lobbyUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      activeSessionId: json['activeSessionId'] as String?,
      lastUpdated: const TimeStampConverter().fromJson(json['lastUpdated']),
    );

Map<String, dynamic> _$$DraftSessionImplToJson(_$DraftSessionImpl instance) =>
    <String, dynamic>{
      'selectedCategories': instance.selectedCategories,
      'budgetLevels': instance.budgetLevels,
      'durationTiers': instance.durationTiers,
      'customActivities': instance.customActivities,
      'readyUsers': instance.readyUsers,
      'lobbyUsers': instance.lobbyUsers,
      'activeSessionId': instance.activeSessionId,
      'lastUpdated': const TimeStampConverter().toJson(instance.lastUpdated),
    };
