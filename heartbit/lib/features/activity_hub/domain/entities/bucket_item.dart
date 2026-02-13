import 'package:freezed_annotation/freezed_annotation.dart';

part 'bucket_item.freezed.dart';
part 'bucket_item.g.dart';

@freezed
class BucketItem with _$BucketItem {
  const factory BucketItem({
    required String id,
    required String activityId,
    required DateTime matchedAt,
    @Default('pending') String status, // pending, planned, completed
    DateTime? plannedDate,
    DateTime? completedAt,
  }) = _BucketItem;

  factory BucketItem.fromJson(Map<String, dynamic> json) => _$BucketItemFromJson(json);
}

extension BucketItemStatusX on BucketItem {
  bool get isPending => status == 'pending';
  bool get isPlanned => status == 'planned';
  bool get isCompleted => status == 'completed';
}
