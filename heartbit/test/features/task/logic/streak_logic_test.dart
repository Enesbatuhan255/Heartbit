import 'package:flutter_test/flutter_test.dart';

/// Helper class that replicates the Streak Validation Logic from TaskRemoteDataSource
class StreakValidator {
  static int validateStreak({
    required int streak,
    required DateTime lastStreakDate,
    required DateTime now,
  }) {
    if (streak == 0) return 0;

    final today = DateTime.utc(now.year, now.month, now.day);
    // Ensure lastStreakDate is treated as UTC for day comparison, matching production logic
    final lastDate = DateTime.utc(lastStreakDate.year, lastStreakDate.month, lastStreakDate.day);
    
    final yesterday = today.subtract(const Duration(days: 1));

    // If lastStreakDate is today or yesterday, streak is valid
    if (lastDate == today || lastDate == yesterday) {
      return streak;
    }

    return 0; // Streak broken
  }
}

void main() {
  group('Streak Validation Logic', () {
    final now = DateTime.utc(2024, 1, 15, 12, 0, 0); // Jan 15th noon UTC

    test('Streak is valid if last update was TODAY', () {
      final lastUpdate = DateTime.utc(2024, 1, 15, 8, 0, 0); // Jan 15th 8am
      
      final result = StreakValidator.validateStreak(
        streak: 5,
        lastStreakDate: lastUpdate,
        now: now,
      );
      
      expect(result, 5);
    });

    test('Streak is valid if last update was YESTERDAY', () {
      final lastUpdate = DateTime.utc(2024, 1, 14, 23, 0, 0); // Jan 14th 11pm
      
      final result = StreakValidator.validateStreak(
        streak: 5,
        lastStreakDate: lastUpdate,
        now: now,
      );
      
      expect(result, 5);
    });

    test('Streak resets if last update was 2 DAYS AGO', () {
      final lastUpdate = DateTime.utc(2024, 1, 13, 23, 0, 0); // Jan 13th 11pm
      // Jan 13 -> Jan 14 (Yesterday) -> Jan 15 (Today). 
      // Missed Jan 14 entirely.
      
      final result = StreakValidator.validateStreak(
        streak: 5,
        lastStreakDate: lastUpdate,
        now: now,
      );
      
      expect(result, 0, reason: 'Should reset because Jan 14 was skipped');
    });

    test('Streak resets if last update was long ago', () {
      final lastUpdate = DateTime.utc(2023, 12, 25);
      
      final result = StreakValidator.validateStreak(
        streak: 10,
        lastStreakDate: lastUpdate,
        now: now,
      );
      
      expect(result, 0);
    });
    
    test('Streak is valid for boundary case (Yesterday early morning)', () {
      final lastUpdate = DateTime.utc(2024, 1, 14, 1, 0, 0); // Jan 14th 1am
      
      final result = StreakValidator.validateStreak(
        streak: 5,
        lastStreakDate: lastUpdate,
        now: now,
      );
      expect(result, 5);
    });
  });
}
