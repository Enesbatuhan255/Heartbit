
import 'package:equatable/equatable.dart';

class CoupleEntity extends Equatable {
  final String id;
  final String user1Id;
  final String user2Id;
  final int totalPoints;
  final int level;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CoupleEntity({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.totalPoints,
    required this.level,
    this.streak = 0,
    this.lastStreakDate,
    this.eggWarmth = 0,
    this.isHatched = false,
    this.lastEggInteraction,
    required this.createdAt,
    required this.updatedAt,
  });

  final int streak;
  final DateTime? lastStreakDate;
  final int eggWarmth; // 0-1000
  final bool isHatched;
  final DateTime? lastEggInteraction;

  @override
  List<Object?> get props => [
        id,
        user1Id,
        user2Id,
        totalPoints,
        level,
        eggWarmth,
        isHatched,
        lastEggInteraction,
        createdAt,
        updatedAt,
      ];
}
