import 'package:freezed_annotation/freezed_annotation.dart';

part 'swipe_session.freezed.dart';
part 'swipe_session.g.dart';

/// A swipe session for tracking swipes in a single game
@freezed
class SwipeSession with _$SwipeSession {
  const factory SwipeSession({
    required String id,
    required String coupleId,
    required List<String> selectedCategories,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default(0) int totalCards,
    @Default(0) int swipedCount,
    @Default(0) int matchCount,
  }) = _SwipeSession;

  factory SwipeSession.fromJson(Map<String, dynamic> json) =>
      _$SwipeSessionFromJson(json);
}

/// A single swipe record (blind voting)
@freezed
class SwipeRecord with _$SwipeRecord {
  const factory SwipeRecord({
    required String activityId,
    required String activityType, // 'global' | 'custom'
    required String userId,
    required String direction, // 'right' | 'left'
    required String sessionId,
    required DateTime timestamp,
  }) = _SwipeRecord;

  factory SwipeRecord.fromJson(Map<String, dynamic> json) =>
      _$SwipeRecordFromJson(json);
}

/// A successful match between partners
@freezed
class ActivityMatch with _$ActivityMatch {
  const factory ActivityMatch({
    required String id,
    required String activityId,
    required String activityType, // 'global' | 'custom'
    required String activityTitle,
    required DateTime matchedAt,
    @Default('pending') String status, // 'pending' | 'planned' | 'completed'
    DateTime? plannedDate,
    DateTime? completedAt,
  }) = _ActivityMatch;

  factory ActivityMatch.fromJson(Map<String, dynamic> json) =>
      _$ActivityMatchFromJson(json);
}
