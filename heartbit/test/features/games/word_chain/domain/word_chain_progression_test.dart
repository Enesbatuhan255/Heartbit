import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartbit/features/games/word_chain/domain/entities/word_chain_session.dart';
import 'package:heartbit/features/games/word_chain/domain/utils/word_chain_validator.dart';

void main() {
  group('WordChain progression', () {
    test('suffix length thresholds are 1->2->3 at 5 and 10 words', () {
      expect(WordChainSession.suffixLengthForWordCount(0), 1);
      expect(WordChainSession.suffixLengthForWordCount(4), 1);
      expect(WordChainSession.suffixLengthForWordCount(5), 2);
      expect(WordChainSession.suffixLengthForWordCount(9), 2);
      expect(WordChainSession.suffixLengthForWordCount(10), 3);
      expect(WordChainSession.suffixLengthForWordCount(22), 3);
    });

    test('turn seconds are 15/12/10 based on suffix length', () {
      expect(WordChainSession.turnSecondsForSuffixLength(1), 15);
      expect(WordChainSession.turnSecondsForSuffixLength(2), 12);
      expect(WordChainSession.turnSecondsForSuffixLength(3), 10);
      expect(WordChainSession.turnSecondsForSuffixLength(8), 10);
    });

    test('legacy session defaults required fields safely', () {
      final now = Timestamp.fromDate(DateTime(2026, 1, 1));
      final session = WordChainSession.fromMap('s1', {
        'id': 's1',
        'coupleId': 'c1',
        'status': 'playing',
        'mode': 'free',
        'category': null,
        'words': [
          {'word': 'masa', 'userId': 'u1', 'timestamp': 1},
          {'word': 'sahil', 'userId': 'u2', 'timestamp': 2},
          {'word': 'liman', 'userId': 'u1', 'timestamp': 3},
          {'word': 'nar', 'userId': 'u2', 'timestamp': 4},
          {'word': 'roman', 'userId': 'u1', 'timestamp': 5},
        ],
        'currentTurnUserId': 'u2',
        'readyUsers': ['u1', 'u2'],
        'participants': ['u1', 'u2'],
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      });

      expect(session.requiredSuffixLength, 2);
      expect(session.turnSeconds, 12);
      expect(session.jokersRemaining['u1'], 1);
      expect(session.jokersRemaining['u2'], 1);
    });

    test('expectedPrefix and currentStage follow requiredSuffixLength', () {
      final now = Timestamp.fromDate(DateTime(2026, 1, 1));
      final session = WordChainSession.fromMap('s2', {
        'id': 's2',
        'coupleId': 'c1',
        'status': 'playing',
        'mode': 'last_letter',
        'words': [
          {'word': 'araba', 'userId': 'u1', 'timestamp': 1},
        ],
        'requiredSuffixLength': 3,
        'turnSeconds': 10,
        'jokersRemaining': {'u1': 1, 'u2': 1},
        'currentTurnUserId': 'u2',
        'readyUsers': ['u1', 'u2'],
        'participants': ['u1', 'u2'],
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      });

      expect(session.currentStage, 3);
      expect(session.expectedPrefix, 'ABA');
    });

    test('missing participant joker gets default 1', () {
      final now = Timestamp.fromDate(DateTime(2026, 1, 1));
      final session = WordChainSession.fromMap('s3', {
        'id': 's3',
        'coupleId': 'c1',
        'status': 'playing',
        'mode': 'last_letter',
        'words': [
          {'word': 'masa', 'userId': 'u1', 'timestamp': 1},
        ],
        'requiredSuffixLength': 1,
        'turnSeconds': 15,
        'jokersRemaining': {'u1': 0},
        'currentTurnUserId': 'u2',
        'readyUsers': ['u1', 'u2'],
        'participants': ['u1', 'u2'],
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      });

      expect(session.jokersRemaining['u1'], 0);
      expect(session.jokersRemaining['u2'], 1);
    });
  });

  group('WordChainValidator progression', () {
    WordChainSession buildSession({
      required WordChainMode mode,
      required int requiredSuffixLength,
      required List<Map<String, dynamic>> words,
    }) {
      final now = Timestamp.fromDate(DateTime(2026, 1, 1));
      return WordChainSession.fromMap('sv', {
        'id': 'sv',
        'coupleId': 'c1',
        'status': 'playing',
        'mode': WordChainSession.modeToStorage(mode),
        'words': words,
        'requiredSuffixLength': requiredSuffixLength,
        'turnSeconds': 15,
        'jokersRemaining': {'u1': 1, 'u2': 1},
        'currentTurnUserId': 'u1',
        'readyUsers': ['u1', 'u2'],
        'participants': ['u1', 'u2'],
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    test('free mode enforces progressive suffix match', () {
      final session = buildSession(
        mode: WordChainMode.free,
        requiredSuffixLength: 2,
        words: [
          {'word': 'masa', 'userId': 'u1', 'timestamp': 1},
        ],
      );

      expect(WordChainValidator.validate('sahil', session), isNull);

      final invalid = WordChainValidator.validate('kitap', session);
      expect(invalid, isNotNull);
      expect(invalid!, contains('"SA" ile baslamali'));
    });

    test('category mode ignores progressive suffix requirement', () {
      final session = buildSession(
        mode: WordChainMode.category,
        requiredSuffixLength: 3,
        words: [
          {'word': 'araba', 'userId': 'u1', 'timestamp': 1},
        ],
      );

      expect(WordChainValidator.validate('kitap', session), isNull);
    });
  });
}
