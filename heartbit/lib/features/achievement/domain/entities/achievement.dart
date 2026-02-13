
/// Achievement type categories
enum AchievementType {
  pet,        // Pet related achievements
  streak,     // Streak related achievements
  social,     // Partner interaction achievements
  milestone,  // General milestones
}

/// Rarity affects UI styling and rewards
enum AchievementRarity {
  common,     // Easy to get
  rare,       // Moderate effort
  epic,       // Significant effort
  legendary,  // Major accomplishment
}

/// Achievement definition (static, predefined)
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementType type;
  final AchievementRarity rarity;
  final int xpReward;
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.rarity,
    required this.xpReward,
  });
}

/// User's unlocked achievement record
class UnlockedAchievement {
  final String achievementId;
  final DateTime unlockedAt;
  final bool isClaimed; // XP claimed?

  const UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
    this.isClaimed = false,
  });
}

/// Extension for rarity styling
extension AchievementRarityExtension on AchievementRarity {
  String get label {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  String get colorHex {
    switch (this) {
      case AchievementRarity.common:
        return '#9E9E9E'; // Grey
      case AchievementRarity.rare:
        return '#2196F3'; // Blue
      case AchievementRarity.epic:
        return '#9C27B0'; // Purple
      case AchievementRarity.legendary:
        return '#FF9800'; // Orange/Gold
    }
  }
}

/// All predefined achievements
class Achievements {
  static const List<Achievement> all = [
    // --- Pet Achievements ---
    Achievement(
      id: 'first_egg',
      title: 'First Egg',
      description: 'İlk pet\'ini oluştur',
      emoji: '🥚',
      type: AchievementType.pet,
      rarity: AchievementRarity.common,
      xpReward: 10,
    ),
    Achievement(
      id: 'first_evolution',
      title: 'First Evolution',
      description: 'Pet\'in Baby aşamasına ulaştı',
      emoji: '🐣',
      type: AchievementType.pet,
      rarity: AchievementRarity.rare,
      xpReward: 25,
    ),
    Achievement(
      id: 'teen_stage',
      title: 'Growing Up',
      description: 'Pet\'in Teen aşamasına ulaştı',
      emoji: '🐥',
      type: AchievementType.pet,
      rarity: AchievementRarity.rare,
      xpReward: 50,
    ),
    Achievement(
      id: 'pet_master',
      title: 'Pet Master',
      description: 'Pet\'in Adult aşamasına ulaştı',
      emoji: '🐔',
      type: AchievementType.pet,
      rarity: AchievementRarity.epic,
      xpReward: 100,
    ),
    Achievement(
      id: 'pet_level_10',
      title: 'Double Digits',
      description: 'Pet Level 10\'a ulaştı',
      emoji: '🔟',
      type: AchievementType.pet,
      rarity: AchievementRarity.rare,
      xpReward: 30,
    ),

    // --- Streak Achievements ---
    Achievement(
      id: 'streak_3',
      title: 'Getting Started',
      description: '3 gün üst üste görev tamamla',
      emoji: '🔥',
      type: AchievementType.streak,
      rarity: AchievementRarity.common,
      xpReward: 15,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: '7 gün üst üste görev tamamla',
      emoji: '📅',
      type: AchievementType.streak,
      rarity: AchievementRarity.rare,
      xpReward: 35,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Dedicated',
      description: '30 gün üst üste görev tamamla',
      emoji: '💪',
      type: AchievementType.streak,
      rarity: AchievementRarity.epic,
      xpReward: 100,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Legendary Lover',
      description: '100 gün üst üste görev tamamla',
      emoji: '👑',
      type: AchievementType.streak,
      rarity: AchievementRarity.legendary,
      xpReward: 500,
    ),

    // --- Social Achievements ---
    Achievement(
      id: 'first_pair',
      title: 'Connected',
      description: 'Partner ile eşleştin',
      emoji: '❤️',
      type: AchievementType.social,
      rarity: AchievementRarity.common,
      xpReward: 20,
    ),
    Achievement(
      id: 'mood_7_days',
      title: 'Emotional',
      description: '7 gün boyunca mood seç',
      emoji: '🧠',
      type: AchievementType.social,
      rarity: AchievementRarity.rare,
      xpReward: 25,
    ),

    // --- Milestone Achievements ---
    Achievement(
      id: 'first_task',
      title: 'Taskmaster',
      description: 'İlk görevini tamamla',
      emoji: '✅',
      type: AchievementType.milestone,
      rarity: AchievementRarity.common,
      xpReward: 5,
    ),
    Achievement(
      id: 'tasks_50',
      title: 'Busy Bee',
      description: '50 görev tamamla',
      emoji: '🐝',
      type: AchievementType.milestone,
      rarity: AchievementRarity.rare,
      xpReward: 50,
    ),
    Achievement(
      id: 'tasks_100',
      title: 'Centurion',
      description: '100 görev tamamla',
      emoji: '💯',
      type: AchievementType.milestone,
      rarity: AchievementRarity.epic,
      xpReward: 100,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
