import 'package:freezed_annotation/freezed_annotation.dart';

part 'swipe_record.freezed.dart';
part 'swipe_record.g.dart';

/// Represents a single user's swipe decision on an activity
@freezed
class SwipeRecord with _$SwipeRecord {
  const factory SwipeRecord({
    required String activityId,
    required String odCiU4q9nSb,
    required bool liked,
    required DateTime swipedAt,
  }) = _SwipeRecord;

  factory SwipeRecord.fromJson(Map<String, dynamic> json) => _$SwipeRecordFromJson(json);
}
