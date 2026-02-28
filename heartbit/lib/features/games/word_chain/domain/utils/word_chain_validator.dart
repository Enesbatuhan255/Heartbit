import 'package:heartbit/features/games/word_chain/domain/entities/word_chain_session.dart';

class WordChainValidator {
  static final RegExp _lettersOnly = RegExp(
    r'^[A-Za-z\u00C7\u00E7\u011E\u011F\u0130\u0131\u00D6\u00F6\u015E\u015F\u00DC\u00FC]+$',
  );

  static bool isAlreadyUsed(String word, Set<String> usedWords) {
    return usedWords.contains(word.toLowerCase().trim());
  }

  static bool isLongEnough(String word) {
    return word.trim().length >= 2;
  }

  static bool isClean(String word) {
    return _lettersOnly.hasMatch(word.trim());
  }

  static bool isValidSuffixMatch(
    String word,
    String? expectedPrefix,
    int requiredSuffixLength,
  ) {
    if (expectedPrefix == null || expectedPrefix.trim().isEmpty) {
      return true;
    }

    final normalized = word.trim().toUpperCase();
    final prefix = expectedPrefix.trim().toUpperCase();
    if (normalized.length < prefix.length) return false;

    final safeRequiredLength = requiredSuffixLength.clamp(1, 3);
    if (prefix.length > safeRequiredLength) {
      return normalized
          .startsWith(prefix.substring(prefix.length - safeRequiredLength));
    }

    return normalized.startsWith(prefix);
  }

  static String? validate(String word, WordChainSession session) {
    final normalized = word.trim();
    if (!isLongEnough(normalized)) return 'En az 2 harf olmali';
    if (!isClean(normalized)) return 'Sadece harf kullanabilirsin';
    if (isAlreadyUsed(normalized, session.usedWords)) {
      return 'Bu kelime zaten kullanildi';
    }

    if (WordChainSession.isProgressiveMode(session.mode)) {
      final expectedPrefix = session.expectedPrefix;
      if (!isValidSuffixMatch(
        normalized,
        expectedPrefix,
        session.requiredSuffixLength,
      )) {
        final expected = expectedPrefix ?? '?';
        return 'Kelime "$expected" ile baslamali';
      }
    }

    return null;
  }
}
