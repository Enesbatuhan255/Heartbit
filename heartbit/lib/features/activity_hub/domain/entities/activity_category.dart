/// Activity categories for vibe selection
enum ActivityCategory {
  chillHome('chill_home', '🏠', 'Chill @ Home', 'Cozy at-home activities'),
  nightOut('night_out', '🌙', 'Night Out', 'Dinner, bars, events'),
  adventure('adventure', '🏔️', 'Adventure', 'Outdoor, travel, active'),
  spicy('spicy', '🔥', 'Spicy', 'Romantic, intimate');

  final String value;
  final String emoji;
  final String label;
  final String description;

  const ActivityCategory(this.value, this.emoji, this.label, this.description);

  /// Parse from Firestore string value
  static ActivityCategory fromString(String value) {
    return ActivityCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ActivityCategory.chillHome,
    );
  }
}
