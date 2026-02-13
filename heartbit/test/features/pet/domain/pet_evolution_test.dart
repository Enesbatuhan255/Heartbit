import 'package:flutter_test/flutter_test.dart';
import 'package:heartbit/features/pet/domain/entities/pet_evolution.dart';

void main() {
  group('PetEvolution XP Logic', () {
    test('totalXpForLevel Calculate correctly for arithmetic progression', () {
      // Level 1: 0 XP
      expect(PetEvolution.totalXpForLevel(1), 0);
      
      // Level 2: Starts at 100 XP (Level 1 needs 100 XP to complete)
      // Arithmetic sum: 1 * 100 = 100
      expect(PetEvolution.totalXpForLevel(2), 100);
      
      // Level 3: Starts at 300 XP (Level 2 needs 200 XP)
      // Sum: 100 + 200 = 300
      expect(PetEvolution.totalXpForLevel(3), 300);
      
      // Level 4: Starts at 600 XP (Level 3 needs 300 XP)
      // Sum: 100 + 200 + 300 = 600
      expect(PetEvolution.totalXpForLevel(4), 600);
    });

    test('levelFromTotalXp Reverse calculates correctly', () {
      // 0 XP -> Level 1
      expect(PetEvolution.levelFromTotalXp(0), 1);
      
      // 99 XP -> Level 1 (almost 2)
      expect(PetEvolution.levelFromTotalXp(99), 1);
      
      // 100 XP -> Level 2
      expect(PetEvolution.levelFromTotalXp(100), 2);
      
      // 299 XP -> Level 2
      expect(PetEvolution.levelFromTotalXp(299), 2);
      
      // 300 XP -> Level 3
      expect(PetEvolution.levelFromTotalXp(300), 3);
      
      // 599 XP -> Level 3
      expect(PetEvolution.levelFromTotalXp(599), 3);
      
      // 600 XP -> Level 4
      expect(PetEvolution.levelFromTotalXp(600), 4);
    });

    test('stageFromLevel Returns correct stage', () {
      expect(PetEvolution.stageFromLevel(1), PetStage.egg);
      expect(PetEvolution.stageFromLevel(4), PetStage.egg);
      
      expect(PetEvolution.stageFromLevel(5), PetStage.baby);
      expect(PetEvolution.stageFromLevel(9), PetStage.baby);
      
      expect(PetEvolution.stageFromLevel(10), PetStage.teen);
      expect(PetEvolution.stageFromLevel(19), PetStage.teen);
      
      expect(PetEvolution.stageFromLevel(20), PetStage.adult);
      expect(PetEvolution.stageFromLevel(50), PetStage.adult);
    });
  });

  group('PetEvolution Mood & Bonus', () {
    test('moodFromHappiness Returns correct mood', () {
      expect(PetEvolution.moodFromHappiness(100), PetMood.happy);
      expect(PetEvolution.moodFromHappiness(80), PetMood.happy);
      
      expect(PetEvolution.moodFromHappiness(79), PetMood.neutral);
      expect(PetEvolution.moodFromHappiness(50), PetMood.neutral);
      
      expect(PetEvolution.moodFromHappiness(49), PetMood.sad);
      expect(PetEvolution.moodFromHappiness(20), PetMood.sad);
      
      expect(PetEvolution.moodFromHappiness(19), PetMood.tired);
      expect(PetEvolution.moodFromHappiness(0), PetMood.tired);
    });

    test('applyMoodBonus Calculates correct multiplier', () {
      const base = 100.0;
      
      // Happy: 1.2x -> 120
      expect(PetEvolution.applyMoodBonus(base, PetMood.happy), 120.0);
      
      // Neutral: 1.0x -> 100
      expect(PetEvolution.applyMoodBonus(base, PetMood.neutral), 100.0);
      
      // Sad: 0.8x -> 80
      expect(PetEvolution.applyMoodBonus(base, PetMood.sad), 80.0);
      
      // Tired: 0.5x -> 50
      expect(PetEvolution.applyMoodBonus(base, PetMood.tired), 50.0);
    });
  });
}
