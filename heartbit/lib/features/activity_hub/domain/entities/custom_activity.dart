import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_activity.freezed.dart';
part 'custom_activity.g.dart';

/// A couple's private custom activity (the "Joker" card)
@freezed
class CustomActivity with _$CustomActivity {
  const factory CustomActivity({
    required String id,
    required String title,
    required String createdBy,
    required DateTime createdAt,
    String? category, // Optional categorization
    @Default(false) bool isTemporary, // true = one-time use only
  }) = _CustomActivity;

  factory CustomActivity.fromJson(Map<String, dynamic> json) =>
      _$CustomActivityFromJson(json);
}
