
import 'package:freezed_annotation/freezed_annotation.dart';
import 'pet_evolution.dart';

part 'pet.freezed.dart';
part 'pet.g.dart';

@freezed
class Pet with _$Pet {
  const Pet._(); // Enable custom getters

  const factory Pet({
    required String id,
    required String coupleId,
    @Default('Baby Egg') String name,
    @Default(1) int level,
    @Default(0.0) double experience,    // XP within current level
    @Default(0.0) double totalXp,       // Total accumulated XP
    @Default(100.0) double hunger,      // 100 = full
    @Default(100.0) double happiness,   // 100 = max happy
    DateTime? lastFed,
    DateTime? lastInteracted,
    PetInteraction? lastInteraction,
  }) = _Pet;

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

  // --- Computed Properties ---

  /// Current evolution stage based on level
  PetStage get stage => PetEvolution.stageFromLevel(level);

  /// Current mood based on happiness
  PetMood get mood => PetEvolution.moodFromHappiness(happiness);

  /// Progress to next level (0.0 - 1.0)
  double get levelProgress {
    final xpForNext = PetEvolution.xpForLevel(level + 1);
    final xpForCurrent = PetEvolution.xpForLevel(level);
    final needed = xpForNext - xpForCurrent;
    if (needed <= 0) return 1.0;
    return (experience / needed).clamp(0.0, 1.0);
  }

  /// XP needed for next level
  int get xpToNextLevel {
    final xpForNext = PetEvolution.xpForLevel(level + 1);
    final xpForCurrent = PetEvolution.xpForLevel(level);
    return (xpForNext - xpForCurrent - experience.toInt()).clamp(0, 10000);
  }

  /// Is pet about to evolve? (within 1 level of next stage)
  bool get isAboutToEvolve {
    final nextStage = PetEvolution.stageFromLevel(level + 1);
    return nextStage != stage;
  }

  /// Calculate actual XP to add with mood modifier
  double calculateXpWithMood(double baseXp) {
    return PetEvolution.applyMoodBonus(baseXp, mood);
  }
}

@freezed
class PetInteraction with _$PetInteraction {
  const factory PetInteraction({
    required String userId,
    required String type, // 'poke', 'love', 'feed'
    required DateTime timestamp,
  }) = _PetInteraction;

  factory PetInteraction.fromJson(Map<String, dynamic> json) => _$PetInteractionFromJson(json);
}
