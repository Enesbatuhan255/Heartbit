import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String title,
    required String description,
    required String imageUrl,
    required String category,
    @Default('1-2 hours') String estimatedTime,
    @Default(2) int budgetLevel, // 1=Free, 2=$, 3=$$, 4=$$$
    @Default(2) int intensityLevel, // 1=Low, 2=Medium, 3=High
    @Default([]) List<String> moods, // chill, romantic, adventure
    @Default([]) List<String> tags,
    @Default('global') String activityType, // 'global' | 'custom'
    @Default(true) bool isActive,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
}

/// Budget level display helper
extension ActivityBudgetX on Activity {
  String get budgetDisplay {
    switch (budgetLevel) {
      case 1:
        return 'Free';
      case 2:
        return '\$';
      case 3:
        return '\$\$';
      case 4:
        return '\$\$\$';
      default:
        return '\$';
    }
  }

  String get intensityDisplay {
    switch (intensityLevel) {
      case 1:
        return '😌 Chill';
      case 2:
        return '😊 Moderate';
      case 3:
        return '🔥 Intense';
      default:
        return '😊 Moderate';
    }
  }

  String get moodsDisplay => moods.join(' • ');
  
  bool get isGlobal => activityType == 'global';
  bool get isCustom => activityType == 'custom';
}
