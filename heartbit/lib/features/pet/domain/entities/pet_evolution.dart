
import 'dart:math' as math;

/// Pet Evolution Stages
/// 
/// Level thresholds:
/// - Egg:   Level 1-4   (0-300 XP total)
/// - Baby:  Level 5-9   (400-800 XP total)
/// - Teen:  Level 10-19 (900-1800 XP total)
/// - Adult: Level 20+   (1900+ XP total)
enum PetStage {
  egg,
  baby,
  teen,
  adult,
}

/// Pet Mood States
enum PetMood {
  happy,
  neutral,
  sad,
  tired,
}

/// Extension for PetStage with metadata
extension PetStageExtension on PetStage {
  /// Display emoji for each stage
  String get emoji {
    switch (this) {
      case PetStage.egg:
        return '🥚';
      case PetStage.baby:
        return '🐣';
      case PetStage.teen:
        return '🐥';
      case PetStage.adult:
        return '🐔';
    }
  }

  /// Display name for each stage
  String get displayName {
    switch (this) {
      case PetStage.egg:
        return 'Egg';
      case PetStage.baby:
        return 'Baby';
      case PetStage.teen:
        return 'Teen';
      case PetStage.adult:
        return 'Adult';
    }
  }

  /// Minimum level required for this stage
  int get minLevel {
    switch (this) {
      case PetStage.egg:
        return 1;
      case PetStage.baby:
        return 5;
      case PetStage.teen:
        return 10;
      case PetStage.adult:
        return 20;
    }
  }

  /// Description of the pet at this stage
  String get description {
    switch (this) {
      case PetStage.egg:
        return 'Henüz yumurtadan çıkmadı. Sabırla bekle!';
      case PetStage.baby:
        return 'Yeni doğmuş! Çok ilgiye ihtiyacı var.';
      case PetStage.teen:
        return 'Büyüyor! Artık daha bağımsız.';
      case PetStage.adult:
        return 'Tam olgunlaştı. Senin en iyi arkadaşın!';
    }
  }
}

/// Extension for PetMood with metadata
extension PetMoodExtension on PetMood {
  String get emoji {
    switch (this) {
      case PetMood.happy:
        return '😊';
      case PetMood.neutral:
        return '😐';
      case PetMood.sad:
        return '😢';
      case PetMood.tired:
        return '😴';
    }
  }

  /// XP multiplier based on mood
  /// Happy = 1.2x, Neutral = 1.0x, Sad = 0.8x, Tired = 0.5x
  double get xpMultiplier {
    switch (this) {
      case PetMood.happy:
        return 1.2;
      case PetMood.neutral:
        return 1.0;
      case PetMood.sad:
        return 0.8;
      case PetMood.tired:
        return 0.5;
    }
  }

  /// Happiness drain rate per hour
  double get happinessDrainPerHour {
    switch (this) {
      case PetMood.happy:
        return 2.0;
      case PetMood.neutral:
        return 3.0;
      case PetMood.sad:
        return 5.0;
      case PetMood.tired:
        return 4.0;
    }
  }
}

/// Pet Evolution Calculator
class PetEvolution {
  /// XP required to reach a specific level
  /// Formula: level * 100 (linear for simplicity)
  /// Level 1 → 0 XP, Level 2 → 100 XP, Level 5 → 400 XP, etc.
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    return (level - 1) * 100;
  }

  /// Total XP required from level 1 to target level
  static int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    // Sum of arithmetic sequence: n*(n-1)/2 * 100
    return (level * (level - 1) ~/ 2) * 100;
  }

  /// Calculate level from total accumulated XP
  static int levelFromTotalXp(double totalXp) {
    if (totalXp <= 0) return 1;
    // Simplified: level ≈ (1 + sqrt(1 + 8*totalXp/100)) / 2
    final level = (1 + math.sqrt(1 + 8 * totalXp / 100)) / 2;
    return level.floor().clamp(1, 100);
  }

  /// Get the evolution stage based on level
  static PetStage stageFromLevel(int level) {
    if (level >= 20) return PetStage.adult;
    if (level >= 10) return PetStage.teen;
    if (level >= 5) return PetStage.baby;
    return PetStage.egg;
  }

  /// Calculate mood based on happiness percentage
  static PetMood moodFromHappiness(double happiness) {
    if (happiness >= 80) return PetMood.happy;
    if (happiness >= 50) return PetMood.neutral;
    if (happiness >= 20) return PetMood.sad;
    return PetMood.tired;
  }

  /// Calculate XP to earn with mood modifier applied
  static double applyMoodBonus(double baseXp, PetMood mood) {
    return baseXp * mood.xpMultiplier;
  }

  /// Progress percentage within current level (0.0 - 1.0)
  static double levelProgress(int currentLevel, double currentXp) {
    final xpForCurrentLevel = xpForLevel(currentLevel);
    final xpForNextLevel = xpForLevel(currentLevel + 1);
    final xpNeeded = xpForNextLevel - xpForCurrentLevel;
    
    if (xpNeeded <= 0) return 1.0;
    
    final xpProgress = currentXp - xpForCurrentLevel;
    return (xpProgress / xpNeeded).clamp(0.0, 1.0);
  }
}
