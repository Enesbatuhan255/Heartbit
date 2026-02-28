import 'package:heartbit/features/games/story_chain/domain/entities/story_chain_session.dart';

class StoryChainValidator {
  static final RegExp _lettersOnly = RegExp(
    r'^[A-Za-z\u00C7\u00E7\u011E\u011F\u0130\u0131\u00D6\u00F6\u015E\u015F\u00DC\u00FC]+$',
  );

  static String normalizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static List<String> splitWords(String text) {
    final normalized = normalizeText(text);
    if (normalized.isEmpty) return const [];
    return normalized
        .split(' ')
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
  }

  static bool isCleanWord(String word) {
    return _lettersOnly.hasMatch(word);
  }

  static String? validateTurn(String text, StoryChainSession session) {
    final normalized = normalizeText(text);
    if (normalized.isEmpty) return 'Metin bos olamaz';

    final words = splitWords(normalized);
    if (words.isEmpty) return 'En az bir kelime yazmalisin';

    for (final word in words) {
      if (!isCleanWord(word)) {
        return 'Sadece harf kullanabilirsin';
      }
    }

    final requiredCount = session.requiredWordCount;
    if (words.length != requiredCount) {
      if (requiredCount == 1) {
        return 'Bu tur tam 1 kelime yazmalisin';
      }
      return 'Bu tur tam $requiredCount kelime yazmalisin';
    }

    return null;
  }
}
