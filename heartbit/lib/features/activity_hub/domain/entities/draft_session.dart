import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'draft_session.freezed.dart';
part 'draft_session.g.dart';

@freezed
class DraftSession with _$DraftSession {
  const factory DraftSession({
    @Default([]) List<String> selectedCategories,
    @Default([]) List<int> budgetLevels,
    @Default([]) List<String> durationTiers,
    @Default([]) List<String> customActivities, // List of titles 
    @Default([]) List<String> readyUsers, // List of user IDs who clicked "Start"
    @Default([]) List<String> lobbyUsers, // List of user IDs currently in lobby
    String? activeSessionId, // Shared session ID for both partners
    @TimeStampConverter() DateTime? lastUpdated,
  }) = _DraftSession;

  factory DraftSession.fromJson(Map<String, dynamic> json) => _$DraftSessionFromJson(json);
}

class TimeStampConverter implements JsonConverter<DateTime?, Object?> {
  const TimeStampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}
