/// Utility functions for comparing answer similarity
class AnswerSimilarity {
  /// Calculate similarity score between two answers (0.0 - 1.0)
  /// Uses keyword matching and common word detection
  static double calculateScore(String answer1, String answer2) {
    if (answer1.isEmpty || answer2.isEmpty) return 0.0;
    
    // Normalize answers
    final normalized1 = _normalize(answer1);
    final normalized2 = _normalize(answer2);
    
    // Exact match
    if (normalized1 == normalized2) return 1.0;
    
    // Extract meaningful words (>2 chars)
    final words1 = _extractWords(normalized1);
    final words2 = _extractWords(normalized2);
    
    if (words1.isEmpty || words2.isEmpty) return 0.0;
    
    // Count common words
    final commonWords = words1.intersection(words2);
    final totalUniqueWords = words1.union(words2);
    
    // Jaccard similarity
    final jaccardScore = commonWords.length / totalUniqueWords.length;
    
    // Bonus for exact phrase matches
    final phraseBonus = _calculatePhraseBonus(normalized1, normalized2);
    
    return (jaccardScore + phraseBonus).clamp(0.0, 1.0);
  }
  
  /// Check if answers are considered "synced" (high similarity)
  static bool areSynced(String answer1, String answer2, {double threshold = 0.35}) {
    return calculateScore(answer1, answer2) >= threshold;
  }
  
  /// Get sync level for display
  static SyncLevel getSyncLevel(String answer1, String answer2) {
    final score = calculateScore(answer1, answer2);
    
    if (score >= 0.7) return SyncLevel.perfect;
    if (score >= 0.5) return SyncLevel.high;
    if (score >= 0.35) return SyncLevel.medium;
    return SyncLevel.low;
  }
  
  // --- Private Helpers ---
  
  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }
  
  static Set<String> _extractWords(String text) {
    return text
        .split(' ')
        .where((w) => w.length > 2) // Ignore short words
        .where((w) => !_stopWords.contains(w)) // Ignore stop words
        .toSet();
  }
  
  static double _calculatePhraseBonus(String text1, String text2) {
    // Check for common 2-word phrases
    final phrases1 = _extractPhrases(text1);
    final phrases2 = _extractPhrases(text2);
    
    final commonPhrases = phrases1.intersection(phrases2);
    if (commonPhrases.isEmpty) return 0.0;
    
    return (commonPhrases.length * 0.1).clamp(0.0, 0.3);
  }
  
  static Set<String> _extractPhrases(String text) {
    final words = text.split(' ').where((w) => w.length > 2).toList();
    final phrases = <String>{};
    
    for (int i = 0; i < words.length - 1; i++) {
      phrases.add('${words[i]} ${words[i + 1]}');
    }
    
    return phrases;
  }
  
  // Common Turkish and English stop words
  static const _stopWords = {
    // Turkish
    'bir', 'bu', 've', 'ile', 'de', 'da', 'için', 'gibi', 'daha',
    'çok', 'var', 'ben', 'sen', 'biz', 'siz', 'onlar', 'ama',
    'fakat', 'ancak', 'hem', 'ya', 'veya', 'ise', 'ki', 'ne',
    // English
    'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all',
    'can', 'had', 'her', 'was', 'one', 'our', 'out', 'has',
    'have', 'been', 'will', 'more', 'when', 'who', 'way',
    'its', 'how', 'than', 'them', 'would', 'like', 'into',
  };
}

/// Sync level enum for UI display
enum SyncLevel {
  low(0, '💭', 'Farklı düşünüyorsunuz', null),
  medium(35, '💫', 'Benzer fikirler!', 25),
  high(50, '✨', 'Harika uyum!', 50),
  perfect(70, '🔥', 'Mükemmel senkron!', 75);

  final int minScore;
  final String emoji;
  final String message;
  final int? bonusXp;
  
  const SyncLevel(this.minScore, this.emoji, this.message, this.bonusXp);
  
  bool get hasBonusXp => bonusXp != null && bonusXp! > 0;
}
